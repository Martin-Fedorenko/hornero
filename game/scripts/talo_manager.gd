extends Node
## Integración con Talo (autoload "TaloManager"). Es el único script que habla
## con el plugin: identidad del jugador, estadísticas y rankings.
##
## Identidad: un UUID v4 que se genera la primera vez que se abre el juego y
## no cambia nunca, más el nombre visible que elige el jugador. Los dos se
## guardan en user:// (en Web, Godot lo persiste en IndexedDB). En Talo el
## jugador se identifica con ese UUID.
##
## Modo incógnito (sin nombre): no se envía nada a Talo, así que no suma a las
## estadísticas globales; sólo puede ver los rankings y los globales. Al poner
## nombre usa el mismo UUID de siempre.
##
## Borrar datos no borra nada en Talo (la Game API no lo permite): el jugador
## pasa a un "ciclo" nuevo. Sus stats personales se muestran desde la base
## guardada al borrar, y en los rankings sólo cuentan las entradas de su ciclo
## actual (los leaderboards son Unique + Unique by props, con el ciclo como prop).
##
## Talo nunca es un requisito para jugar: si no responde, se avisa por consola
## y el juego sigue. Las llamadas son asíncronas y no frenan la partida.

## Emitidos al terminar cada consulta (el diccionario es el mismo que devuelve
## la función correspondiente). Útil para UI que no quiere esperar con await.
signal player_stats_loaded(stats: Dictionary)
signal global_stats_loaded(stats: Dictionary)
signal leaderboard_loaded(internal_name: String, ranking: Dictionary)
## El jugador quedó identificado en Talo.
signal identified()
## Terminó el envío del resultado de una partida (victoria o muerte). `ok` es
## false si no se pudo subir todo (sin internet, Talo caído, etc.).
signal result_upload_finished(ok: bool)
## Terminó el borrado de las estadísticas del jugador (reset_player_stats).
signal player_stats_reset(ok: bool)
## Terminó un intento de identificación (para quien lo esperaba en paralelo).
signal _identify_finished(ok: bool)
## Terminaron de enviarse todos los resultados de partida pendientes.
signal _results_sent()

# --- Recursos de Talo (internal names del Dashboard) -------------------------
const STAT_NESTS_BUILT := "nests_built"
const STAT_DEATHS := "deaths"
const LEADERBOARD_EASY := "best_time_easy"
const LEADERBOARD_HARD := "best_time_hard"
## "Servicio" del alias en Talo: el identificador es el UUID local.
const ALIAS_SERVICE := "hornero_uuid"
## Props del jugador en Talo: nombre visible, ciclo actual (sube al borrar
## datos) y valor de cada stat en el último borrado.
const PROP_NAME := "nombre"
const PROP_CYCLE := "ciclo"
const PROP_BASE := {"nests_built": "base_nests_built", "deaths": "base_deaths"}

# --- Identidad local ----------------------------------------------------------
const IDENTITY_PATH := "user://jugador.cfg"
const NAME_MAX_LENGTH := 20
const RANKING_SIZE := 10
## Páginas de Talo (50 entradas cada una) que se recorren para llenar un ranking.
const MAX_RANKING_PAGES := 5

var _player_uuid := ""
var _player_name := ""
var _identifying := false
## Rechazó poner nombre en esta sesión: no se le vuelve a preguntar.
var _incognito := false
## Hay una partida en curso que todavía no registró su resultado. Garantiza que
## una partida sume exactamente una victoria o una muerte.
var _match_open := false
## Resultados de partida que todavía se están enviando a Talo.
var _sending_results := 0
## Mínimo conocido de cada Game Stat global. Talo actualiza el globalValue con
## unos segundos de demora; como los contadores sólo crecen, se muestra el
## mayor entre lo que devuelve Talo y lo que ya sabemos que sumamos.
var _known_global := {}


func _ready() -> void:
	_load_identity()
	if has_local_identity():
		_identify()


# --- Identidad ----------------------------------------------------------------

func get_player_uuid() -> String:
	return _player_uuid


func get_player_name() -> String:
	return _player_name


## Hay UUID y nombre guardados: no hace falta pedir el nombre.
func has_local_identity() -> bool:
	return not _player_uuid.is_empty() and is_valid_name(_player_name)


## Todavía no eligió entre poner nombre o jugar en incógnito.
func needs_identity_choice() -> bool:
	return not has_local_identity() and not _incognito


func is_incognito() -> bool:
	return _incognito


## Juega sin nombre: no se envía ningún dato a Talo.
func play_incognito() -> void:
	_incognito = true


func is_identified() -> bool:
	return Talo.has_identity()


func clean_name(nombre: String) -> String:
	return nombre.strip_edges()


func is_valid_name(nombre: String) -> bool:
	var limpio := clean_name(nombre)
	return not limpio.is_empty() and limpio.length() <= NAME_MAX_LENGTH


## Guarda el nombre (ya validado) y se identifica en Talo. Devuelve false si el
## nombre no es válido.
func set_player_name(nombre: String) -> bool:
	var limpio := clean_name(nombre)
	if not is_valid_name(limpio):
		return false
	_player_name = limpio
	_incognito = false
	_save_identity()
	if is_identified():
		Talo.current_player.set_prop(PROP_NAME, _player_name)
	else:
		_identify()
	return true


func _load_identity() -> void:
	var archivo := ConfigFile.new()
	if archivo.load(IDENTITY_PATH) == OK:
		_player_uuid = str(archivo.get_value("jugador", "player_uuid", ""))
		_player_name = clean_name(str(archivo.get_value("jugador", "player_name", "")))
	# El UUID se genera una sola vez y se conserva siempre (también en incógnito).
	if not _is_valid_uuid(_player_uuid):
		_player_uuid = _generate_uuid_v4()
		_save_identity()


func _save_identity() -> void:
	var archivo := ConfigFile.new()
	archivo.set_value("jugador", "player_uuid", _player_uuid)
	archivo.set_value("jugador", "player_name", _player_name)
	var error := archivo.save(IDENTITY_PATH)
	if error != OK:
		push_warning("TaloManager: no se pudo guardar %s (error %d)" % [IDENTITY_PATH, error])


## UUID v4 (RFC 4122) con bytes aleatorios criptográficos.
static func _generate_uuid_v4() -> String:
	var b := Crypto.new().generate_random_bytes(16)
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	var hex := b.hex_encode()
	return "%s-%s-%s-%s-%s" % [hex.substr(0, 8), hex.substr(8, 4), hex.substr(12, 4),
			hex.substr(16, 4), hex.substr(20, 12)]


static func _is_valid_uuid(uuid: String) -> bool:
	var regex := RegEx.create_from_string(
			"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
	return regex.search(uuid) != null


## Identifica al jugador en Talo con su UUID. Si ya hay una identificación en
## curso, espera esa. Devuelve si quedó identificado.
func _identify() -> bool:
	if is_identified():
		return true
	if not has_local_identity():
		return false
	if _identifying:
		return await _identify_finished
	_identifying = true
	var alias: TaloPlayerAlias = await Talo.players.identify(ALIAS_SERVICE, _player_uuid)
	_identifying = false
	var ok := alias != null
	if ok:
		print("TaloManager: jugador identificado (%s, %s)" % [_player_name, _player_uuid])
		if Talo.current_player.get_prop(PROP_NAME) != _player_name:
			Talo.current_player.set_prop(PROP_NAME, _player_name)
		identified.emit()
	else:
		push_warning("TaloManager: no se pudo identificar al jugador (sin conexión con Talo).")
	_identify_finished.emit(ok)
	return ok


# --- Partida: victoria y muerte -----------------------------------------------

## Llamar al comenzar cada partida. Habilita registrar un único resultado.
func start_match() -> void:
	_match_open = true


## Cierra la partida. Devuelve false si ya estaba cerrada (resultado duplicado).
func _close_match() -> bool:
	if not _match_open:
		push_warning("TaloManager: resultado de partida ignorado (ya registrado).")
		return false
	_match_open = false
	return true


## Victoria: suma un nido y envía el tiempo al ranking de su dificultad. El
## ranking es Unique (by props) + Ascending: Talo conserva sólo el mejor tiempo
## del jugador en su ciclo actual.
func register_win(time_ms: int, difficulty: int) -> void:
	if not _close_match() or not has_local_identity():
		return
	_sending_results += 1
	_result_sent(await _send_win(time_ms, difficulty))


func _send_win(time_ms: int, difficulty: int) -> bool:
	if not await _identify():
		push_warning("TaloManager: victoria no registrada en Talo (sin identidad).")
		return false
	var ok := await _track(STAT_NESTS_BUILT)
	var tabla := leaderboard_for(difficulty)
	var resultado: LeaderboardsAPI.AddEntryResult = await Talo.leaderboards.add_entry(
			tabla, float(time_ms), {PROP_CYCLE: _current_cycle()})
	if resultado.success:
		print("TaloManager: %s %s enviado a %s (récord actual %s)" % [
				format_time(time_ms), "es nuevo récord" if resultado.updated else "no superó el récord",
				tabla, format_time(roundi(resultado.entry.score))])
	else:
		push_warning("TaloManager: no se pudo enviar el tiempo a %s." % tabla)
	return ok and resultado.success


## Muerte: suma una muerte. No registra tiempo.
func register_death() -> void:
	if not _close_match() or not has_local_identity():
		return
	_sending_results += 1
	var ok := false
	if await _identify():
		ok = await _track(STAT_DEATHS)
	else:
		push_warning("TaloManager: muerte no registrada en Talo (sin identidad).")
	_result_sent(ok)


func _result_sent(ok: bool) -> void:
	result_upload_finished.emit(ok)
	_sending_results -= 1
	if _sending_results == 0:
		_results_sent.emit()


## Las consultas esperan a que terminen de enviarse los resultados, así una
## partida recién terminada ya aparece en las estadísticas.
func _wait_results_sent() -> void:
	if _sending_results > 0:
		await _results_sent


func _track(stat: String) -> bool:
	var player_stat: TaloPlayerStat = await Talo.stats.track(stat, 1.0)
	if player_stat == null:
		push_warning("TaloManager: no se pudo actualizar %s." % stat)
		return false
	_known_global[stat] = maxi(_known_global.get(stat, 0) + 1,
			roundi(player_stat.stat.global_value))
	print("TaloManager: %s = %d (global %d)" % [stat, roundi(player_stat.value),
			roundi(player_stat.stat.global_value)])
	return true


func leaderboard_for(difficulty: int) -> String:
	return LEADERBOARD_HARD if difficulty == Ajustes.Dificultad.DIFICIL else LEADERBOARD_EASY


# --- Consultas -----------------------------------------------------------------

## {ok, nests_built, deaths, best_time_easy_ms, best_time_hard_ms}. Un mejor
## tiempo es -1 si el jugador todavía no ganó en esa dificultad.
func get_player_stats() -> Dictionary:
	var stats := {ok = false, incognito = not has_local_identity(), nests_built = 0,
			deaths = 0, best_time_easy_ms = -1, best_time_hard_ms = -1}
	await _wait_results_sent()
	# En incógnito no se consultan datos propios.
	if has_local_identity() and await _identify():
		var player_stats: Array[TaloPlayerStat] = await Talo.stats.list_player_stats()
		for player_stat: TaloPlayerStat in player_stats:
			var nombre_stat := player_stat.stat.internal_name
			if not PROP_BASE.has(nombre_stat):
				continue
			# Lo hecho desde el último borrado de datos.
			var valor := maxi(roundi(player_stat.value) - _base(nombre_stat), 0)
			if nombre_stat == STAT_NESTS_BUILT:
				stats.nests_built = valor
			else:
				stats.deaths = valor
		stats.best_time_easy_ms = await _player_best_time(LEADERBOARD_EASY)
		stats.best_time_hard_ms = await _player_best_time(LEADERBOARD_HARD)
		# Sin conexión list_player_stats devuelve [] y no se puede distinguir de
		# "nunca jugó": se usa el último health check de Talo.
		stats.ok = Talo.health_check.get_last_status() != HealthCheckAPI.HealthCheckStatus.FAILED
	player_stats_loaded.emit(stats)
	return stats


func _player_best_time(tabla: String) -> int:
	var entradas: Variant = await _current_entries(tabla, 1, Talo.current_player.id)
	if entradas == null or entradas.is_empty():
		return -1
	return roundi(entradas[0].score)


func _current_cycle() -> String:
	return Talo.current_player.get_prop(PROP_CYCLE, "0") if is_identified() else "0"


func _base(stat: String) -> int:
	return Talo.current_player.get_prop(PROP_BASE[stat], "0").to_int()


## La entrada es del ciclo actual de su jugador y el jugador tiene nombre. Las
## entradas de antes de borrar datos (u otras sin ciclo) no se muestran.
func _is_current_entry(entrada: TaloLeaderboardEntry) -> bool:
	var jugador := entrada.player_alias.player
	var ciclo := entrada.get_prop(PROP_CYCLE)
	return not ciclo.is_empty() and ciclo == jugador.get_prop(PROP_CYCLE, "0") \
			and not jugador.get_prop(PROP_NAME).is_empty()


## Hasta `limit` entradas vigentes, de mejor a peor, recorriendo las páginas
## necesarias (las ocultas no cuentan). null si Talo no respondió.
func _current_entries(tabla: String, limit: int, player_id := "") -> Variant:
	var vigentes: Array[TaloLeaderboardEntry] = []
	for numero in MAX_RANKING_PAGES:
		var opciones := LeaderboardsAPI.GetEntriesOptions.new()
		opciones.page = numero
		opciones.player_id = player_id
		var pagina: LeaderboardsAPI.EntriesPage = await Talo.leaderboards.get_entries(tabla, opciones)
		if pagina == null:
			return null
		for entrada: TaloLeaderboardEntry in pagina.entries:
			if _is_current_entry(entrada):
				vigentes.append(entrada)
				if vigentes.size() >= limit:
					return vigentes
		if pagina.is_last_page:
			break
	return vigentes


## {ok, nests_built, deaths}: los valores globales (suma de todos los jugadores)
## que lleva Talo en cada Game Stat global.
func get_global_stats() -> Dictionary:
	var stats := {ok = false, nests_built = 0, deaths = 0}
	await _wait_results_sent()
	var todos: Array[TaloStat] = await Talo.stats.get_stats()
	for stat: TaloStat in todos:
		if stat.internal_name != STAT_NESTS_BUILT and stat.internal_name != STAT_DEATHS:
			continue
		var valor := maxi(roundi(stat.global_value), _known_global.get(stat.internal_name, 0))
		_known_global[stat.internal_name] = valor
		if stat.internal_name == STAT_NESTS_BUILT:
			stats.nests_built = valor
		else:
			stats.deaths = valor
		stats.ok = true
	global_stats_loaded.emit(stats)
	return stats


func get_easy_leaderboard(limit := RANKING_SIZE) -> Dictionary:
	return await get_leaderboard(LEADERBOARD_EASY, limit)


func get_hard_leaderboard(limit := RANKING_SIZE) -> Dictionary:
	return await get_leaderboard(LEADERBOARD_HARD, limit)


## {ok, entries: [{position, name, time_ms, is_player}]}, de mejor a peor.
func get_leaderboard(tabla: String, limit := RANKING_SIZE) -> Dictionary:
	var ranking := {ok = false, entries = []}
	await _wait_results_sent()
	var entradas: Variant = await _current_entries(tabla, limit)
	if entradas != null:
		ranking.ok = true
		for entrada: TaloLeaderboardEntry in entradas:
			ranking.entries.append({
				position = ranking.entries.size() + 1,
				name = entrada.player_alias.player.get_prop(PROP_NAME),
				time_ms = roundi(entrada.score),
				is_player = entrada.player_alias.service == ALIAS_SERVICE
						and entrada.player_alias.identifier == _player_uuid,
			})
	leaderboard_loaded.emit(tabla, ranking)
	return ranking


# --- Borrar estadísticas ---------------------------------------------------------

## Borra los datos del jugador sin borrar nada en Talo (la Game API no lo
## permite) y sin tocar los globales:
## - stats personales: se guarda como base el valor actual de cada stat;
## - rankings: el ciclo sube y las entradas del ciclo anterior dejan de verse;
## - nombre: se borra (en Talo y local) y queda en modo incógnito.
## El UUID se conserva: al poner un nombre nuevo sigue siendo el mismo jugador.
func reset_player_stats() -> bool:
	var ok := await _reset_player_stats()
	player_stats_reset.emit(ok)
	return ok


func _reset_player_stats() -> bool:
	if not has_local_identity():
		return false
	await _wait_results_sent()
	if await Talo.is_offline() or not await _identify():
		push_warning("TaloManager: no se pudieron borrar los datos (sin conexión).")
		return false
	var valores := {}
	var player_stats: Array[TaloPlayerStat] = await Talo.stats.list_player_stats()
	for player_stat: TaloPlayerStat in player_stats:
		valores[player_stat.stat.internal_name] = roundi(player_stat.value)
	var jugador := Talo.current_player
	var claves: Array = PROP_BASE.values() + [PROP_CYCLE, PROP_NAME]
	var anteriores := {}
	for clave: String in claves:
		anteriores[clave] = jugador.get_prop(clave)
	var ciclo_nuevo := str(_current_cycle().to_int() + 1)
	for stat: String in PROP_BASE:
		jugador.set_prop(PROP_BASE[stat], str(valores.get(stat, 0)), false)
	jugador.set_prop(PROP_CYCLE, ciclo_nuevo, false)
	jugador.delete_prop(PROP_NAME, false)
	var actualizado: TaloPlayer = await Talo.players.update()
	if actualizado == null:
		push_warning("TaloManager: no se pudieron borrar los datos.")
		for clave: String in claves:
			if anteriores[clave].is_empty():
				jugador.delete_prop(clave, false)
			else:
				jugador.set_prop(clave, anteriores[clave], false)
		# Que no se reintente más tarde con el jugador que sigue usando sus datos.
		Talo.continuity_manager.clear_requests()
		return false
	print("TaloManager: datos de %s borrados (ciclo %s)." % [_player_uuid, ciclo_nuevo])
	_player_name = ""
	_incognito = true
	_save_identity()
	return true


# --- Formato -------------------------------------------------------------------

## Milisegundos a "MM:SS.mmm" (92450 → "01:32.450").
@warning_ignore("integer_division")
func format_time(ms: int) -> String:
	if ms < 0:
		return "--:--.---"
	return "%02d:%02d.%03d" % [ms / 60000, (ms / 1000) % 60, ms % 1000]
