extends RigidBody2D
## Puede ampliarse a ramas y otros materiales usando el mismo grupo y métodos.
var recogida: bool = false

func recoger() -> void:
	recogida = true
	freeze = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	collision_layer = 0
	collision_mask = 0
	rotation = 0.0

func soltar(donde: Vector2) -> void:
	global_position = donde
	recogida = false
	collision_layer = 2
	collision_mask = 1
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = false
	sleeping = false
