extends Node
## Configuración del jugador (autoload "Ajustes"): dificultad y pantalla
## completa. Se guarda en user:// y se aplica al arrancar el juego.

enum Dificultad { FACIL, DIFICIL }

const RUTA := "user://ajustes.cfg"
## Lo que cambia según la dificultad.
const GATOS := { Dificultad.FACIL: 6, Dificultad.DIFICIL: 10 }
## De esos gatos, cuántos van cerca del árbol del nido.
const GATOS_CERCA_NIDO := { Dificultad.FACIL: 1, Dificultad.DIFICIL: 2 }
const RAPACES := { Dificultad.FACIL: 1, Dificultad.DIFICIL: 1 }
## Segundos (mín, máx) que la rapaz tarda en volver después de irse. En difícil
## vuelve más seguido.
const AUSENCIA_RAPAZ := { Dificultad.FACIL: Vector2(10.0, 15.0), Dificultad.DIFICIL: Vector2(5.0, 8.0) }
## Materiales que hay que llevar para que el nido avance una etapa del dibujo.
const MATERIALES_POR_ETAPA := { Dificultad.FACIL: 1, Dificultad.DIFICIL: 2 }

var dificultad := Dificultad.FACIL
var pantalla_completa := true


func _ready() -> void:
	var archivo := ConfigFile.new()
	if archivo.load(RUTA) == OK:
		dificultad = clampi(int(archivo.get_value("juego", "dificultad", dificultad)),
				Dificultad.FACIL, Dificultad.DIFICIL) as Dificultad
		pantalla_completa = bool(archivo.get_value("pantalla", "completa", pantalla_completa))
	# En el navegador la pantalla completa sólo se puede pedir con un clic.
	if not OS.has_feature("web"):
		_aplicar_pantalla()


func es_dificil() -> bool:
	return dificultad == Dificultad.DIFICIL


func cantidad_gatos() -> int:
	return GATOS[dificultad]


func cantidad_gatos_cerca_nido() -> int:
	return GATOS_CERCA_NIDO[dificultad]


func cantidad_rapaces() -> int:
	return RAPACES[dificultad]


func ausencia_rapaz() -> Vector2:
	return AUSENCIA_RAPAZ[dificultad]


func materiales_por_etapa() -> int:
	return MATERIALES_POR_ETAPA[dificultad]


func cambiar_dificultad(nueva: int) -> void:
	dificultad = clampi(nueva, Dificultad.FACIL, Dificultad.DIFICIL) as Dificultad
	_guardar()


func cambiar_pantalla_completa(completa: bool) -> void:
	pantalla_completa = completa
	_aplicar_pantalla()
	_guardar()


func _aplicar_pantalla() -> void:
	var modo := DisplayServer.WINDOW_MODE_FULLSCREEN if pantalla_completa \
			else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != modo:
		DisplayServer.window_set_mode(modo)


func _guardar() -> void:
	var archivo := ConfigFile.new()
	archivo.set_value("juego", "dificultad", dificultad)
	archivo.set_value("pantalla", "completa", pantalla_completa)
	archivo.save(RUTA)
