extends RigidBody2D

var fuente: Node2D
var recogida: bool = false
var entregado: bool = false
var tipo_recurso: StringName = &"barro"

func _ready() -> void:
	# Nunca queda tapada por el pasto y las matas del plano de adelante.
	z_index = MeadowFloor.FRONT_Z + 1
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_al_tocar_cuerpo)
	freeze = true
	collision_layer = 0
	collision_mask = 0

func recoger() -> void:
	if recogida:
		return
	recogida = true
	if is_instance_valid(fuente):
		fuente.registrar_bola_recogida(self)

func soltar(donde: Vector2) -> void:
	global_position = donde
	recogida = false
	collision_layer = 2
	collision_mask = 1
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = false
	sleeping = false

func _al_tocar_cuerpo(cuerpo: Node) -> void:
	if not recogida and cuerpo.is_in_group(&"suelo"):
		queue_free()
