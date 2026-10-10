class_name RapacesSpawner
extends Node2D
## Hace aparecer las rapaces (chimango, aguilucho, carancho...) en grupos de
## `cantidad`. Con una sola, cuando se va de la pantalla la reemplaza otra al
## azar, que espera su tiempo de ausencia antes de aparecer.
##
## Con más de una aparecen siempre juntas: todas a la vez, cada una desde un
## costado distinto de la pantalla, y de especies distintas (sin repetir el
## grupo anterior). Cuando se fueron todas, llega el grupo siguiente.

const Pool := preload("res://scripts/world/pool.gd")

## Escenas de rapaces posibles. Todas usan el comportamiento de Chimango.gd.
@export var escenas: Array[PackedScene] = []
## Cuántas rapaces hay en juego a la vez.
@export_range(0, 10) var cantidad := 1
## A quién cazan. Si queda vacío, cada rapaz busca al Hornero sola.
@export var jugador: Node2D
## Con más de una rapaz: segundos (mín, máx) que espera cada grupo antes de
## aparecer. Más corto que la ausencia de una sola: vuelven más seguido.
@export var espera_grupo := Vector2(6.0, 9.0)
## Con una sola rapaz: segundos (mín, máx) que tarda en volver. Negativo: usa
## el tiempo de ausencia propio de cada rapaz.
@export var ausencia := Vector2(-1.0, -1.0)

## Rapaces del grupo actual que todavía no se fueron.
var _en_juego := 0
## Índices de `escenas` del grupo anterior, para no repetirlo.
var _grupo_anterior: Array = []
## Rapaces que ya se fueron, guardadas por escena para reusarlas en vez de
## crear y liberar una por grupo (PackedScene → Pool).
var _pools := {}
## Tiempo de ausencia (mín, máx) propio de cada escena, para devolvérselo a
## una rapaz reusada que quedó con la espera de otro grupo.
var _ausencia_original := {}


func _pool_de(escena: PackedScene) -> Pool:
	if not _pools.has(escena):
		_pools[escena] = Pool.new(escena.instantiate)
	return _pools[escena]


func _ready() -> void:
	if escenas.is_empty():
		push_error("RapacesSpawner: falta asignar las escenas de rapaces")
		return
	_nuevo_grupo()


func _nuevo_grupo() -> void:
	if cantidad <= 0:
		return
	var grupo := _elegir_especies()
	_grupo_anterior = grupo
	# Todas esperan lo mismo: aparecen juntas.
	var espera := randf_range(espera_grupo.x, espera_grupo.y)
	if cantidad <= 1:
		espera = randf_range(ausencia.x, ausencia.y) if ausencia.x >= 0.0 else -1.0
	for i in grupo.size():
		_nueva_rapaz(escenas[grupo[i]], _lado_de(i), espera)


## Índices de `escenas` para el grupo: distintos entre sí mientras alcancen
## las especies, y un grupo distinto del anterior.
func _elegir_especies() -> Array:
	var indices := range(escenas.size())
	var grupo: Array = []
	for intento in 10:
		indices.shuffle()
		grupo = indices.slice(0, mini(cantidad, indices.size()))
		while grupo.size() < cantidad:
			grupo.append(indices.pick_random())
		var ordenado := grupo.duplicate()
		ordenado.sort()
		var anterior := _grupo_anterior.duplicate()
		anterior.sort()
		if cantidad <= 1 or ordenado != anterior or escenas.size() <= cantidad:
			break
	return grupo


## Con una sola rapaz entra por cualquier lado; con varias, se turnan la
## izquierda y la derecha para que lleguen desde lugares distintos.
func _lado_de(indice: int) -> int:
	if cantidad <= 1:
		return 0
	return -1 if indice % 2 == 0 else 1


## `espera` < 0: usa el tiempo de ausencia propio de la rapaz.
func _nueva_rapaz(escena: PackedScene, lado: int, espera: float) -> void:
	var nodo: Node = _pool_de(escena).tomar()
	var rapaz := nodo as Chimango
	if rapaz == null:
		push_error("RapacesSpawner: las escenas deben tener Chimango.gd en la raíz")
		nodo.queue_free()
		return
	var nueva := Pool.es_nuevo(rapaz)
	if nueva and not _ausencia_original.has(escena):
		_ausencia_original[escena] = Vector2(rapaz.tiempo_ausente_min, rapaz.tiempo_ausente_max)
	if is_instance_valid(jugador):
		rapaz.target = jugador
	# Arranca escondida y espera su tiempo antes de aparecer. El reemplazo lo
	# maneja este spawner, así que no vuelve por su cuenta.
	rapaz.empezar_ausente = true
	rapaz.reaparecer = false
	rapaz.lado_entrada = lado
	if espera >= 0.0:
		rapaz.tiempo_ausente_min = espera
		rapaz.tiempo_ausente_max = espera
	else:
		# Una reusada pudo quedar con la espera de un grupo anterior.
		rapaz.tiempo_ausente_min = _ausencia_original[escena].x
		rapaz.tiempo_ausente_max = _ausencia_original[escena].y
	if nueva:
		add_child(rapaz)
	else:
		rapaz.reiniciar()
	_en_juego += 1
	# Conectado después de add_child / reiniciar: su primer _ocultar() no cuenta.
	rapaz.se_fue.connect(_al_irse.bind(rapaz, escena), CONNECT_ONE_SHOT)


func _al_irse(rapaz: Chimango, escena: PackedScene) -> void:
	_en_juego -= 1
	# Se guarda para reusar cuando termina de apagarse su grito.
	get_tree().create_timer(rapaz.fundido_grito + 0.1).timeout.connect(
			_pool_de(escena).devolver.bind(rapaz))
	# El grupo siguiente llega cuando se fueron todas.
	if _en_juego <= 0:
		_nuevo_grupo()
