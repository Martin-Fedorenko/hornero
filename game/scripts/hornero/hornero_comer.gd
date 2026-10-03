class_name HorneroComer
extends Area2D
## Zona del pico del hornero. En vuelo, cualquier bicho que toque se lo come
## al pasar y recupera un poco de vida y stamina.

signal ate(bug: Bicho)

@onready var _hornero: Hornero = get_parent()


func _ready() -> void:
	collision_layer = 0
	collision_mask = Bicho.LAYER
	monitorable = false


## Se revisa cada cuadro (y no con area_entered) para que también se coma un
## bicho que ya estaba en la zona cuando despegó o dejó de estar aturdido.
func _physics_process(_delta: float) -> void:
	if not _can_eat():
		return
	for area in get_overlapping_areas():
		var bug := area as Bicho
		if bug != null and bug.can_be_eaten():
			_eat(bug)


func _eat(bug: Bicho) -> void:
	_hornero.vitals.heal(bug.heal_amount)
	_hornero.vitals.restore_stamina(bug.stamina_amount)
	bug.eat(global_position)
	ate.emit(bug)


## Sólo volando o planeando: aturdido no controla el pico.
func _can_eat() -> bool:
	return _hornero.state == Hornero.State.FLYING or _hornero.state == Hornero.State.GLIDING
