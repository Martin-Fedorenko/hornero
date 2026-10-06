extends RigidBody2D
## Puede ampliarse a ramas y otros materiales usando el mismo grupo y métodos.
var recogida: bool = false
var entregado: bool = false
@export var tipo_recurso: StringName = &"piedra"
## Apoyado en la rama de un árbol: queda quieto en el aire hasta que el
## hornero lo agarra. Si después lo suelta, cae como cualquier otro.
@export var en_arbol: bool = false

func _ready() -> void:
	# Nunca queda tapado por el pasto y las matas del plano de adelante.
	z_index = MeadowFloor.FRONT_Z + 1
	if en_arbol:
		freeze = true

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
