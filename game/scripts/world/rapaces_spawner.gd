class_name RapacesSpawner
extends Node2D
## Mantiene en juego `cantidad` rapaces (chimango, aguilucho, carancho...).
## Cada una se elige al azar entre `escenas`: pueden coincidir o no. Cuando
## una se va de la pantalla, la reemplaza otra al azar, que vuelve a esperar
## su tiempo de ausencia antes de aparecer.

## Escenas de rapaces posibles. Todas usan el comportamiento de Chimango.gd.
@export var escenas: Array[PackedScene] = []
## Cuántas rapaces hay en juego a la vez.
@export_range(0, 10) var cantidad := 1
## A quién cazan. Si queda vacío, cada rapaz busca al Hornero sola.
@export var jugador: Node2D


func _ready() -> void:
	if escenas.is_empty():
		push_error("RapacesSpawner: falta asignar las escenas de rapaces")
		return
	for i in cantidad:
		_nueva_rapaz()


func _nueva_rapaz() -> void:
	var rapaz := escenas.pick_random().instantiate() as Chimango
	if rapaz == null:
		push_error("RapacesSpawner: las escenas deben tener Chimango.gd en la raíz")
		return
	if is_instance_valid(jugador):
		rapaz.target = jugador
	# Arranca escondida y espera su tiempo antes de aparecer. El reemplazo lo
	# maneja este spawner, así que no vuelve por su cuenta.
	rapaz.empezar_ausente = true
	rapaz.reaparecer = false
	add_child(rapaz)
	# Conectado después de add_child: su primer _ocultar() (en _ready) no cuenta.
	rapaz.se_fue.connect(_al_irse.bind(rapaz), CONNECT_ONE_SHOT)


func _al_irse(rapaz: Chimango) -> void:
	_nueva_rapaz()
	# Se borra cuando termina de apagarse su grito.
	get_tree().create_timer(rapaz.fundido_grito + 0.1).timeout.connect(rapaz.queue_free)
