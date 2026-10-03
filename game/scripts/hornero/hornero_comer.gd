class_name HorneroComer
extends Area2D
## Zona del pico del hornero. En vuelo, al apretar E se come el bicho más
## cercano dentro de la zona y recupera vida.
##
## Usa `_input` (antes que `_unhandled_input`) para quedarse con la tecla
## cuando hay un bicho a mano; si no hay, la E sigue de largo hacia
## Interaccion (recoger/soltar materiales).

signal ate(bug: Bicho)

@onready var _hornero: Hornero = get_parent()


func _ready() -> void:
	collision_layer = 0
	collision_mask = Bicho.LAYER
	monitorable = false


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"hornero_interactuar") or event.is_echo():
		return
	if not _can_eat():
		return
	var bug := _closest_bug()
	if bug == null:
		return
	get_viewport().set_input_as_handled()
	_hornero.vitals.heal(bug.heal_amount)
	bug.eat(global_position)
	ate.emit(bug)


## Sólo volando o planeando: aturdido no controla el pico.
func _can_eat() -> bool:
	return _hornero.state == Hornero.State.FLYING or _hornero.state == Hornero.State.GLIDING


func _closest_bug() -> Bicho:
	var best: Bicho = null
	var best_distance := INF
	for area in get_overlapping_areas():
		var bug := area as Bicho
		if bug == null or not bug.can_be_eaten():
			continue
		var distance := global_position.distance_squared_to(bug.global_position)
		if distance < best_distance:
			best = bug
			best_distance = distance
	return best
