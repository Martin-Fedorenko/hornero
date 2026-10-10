extends RigidBody2D

const Pool := preload("res://scripts/world/pool.gd")

## Manchas que dejan las bolas al caer, compartidas por todas: se reusan en
## vez de crear un Sprite2D por bola.
static var _manchas := Pool.new(func() -> Sprite2D: return Sprite2D.new())

var fuente: Node2D
var recogida: bool = false
var entregado: bool = false
var tipo_recurso: StringName = &"barro"
## Pool del que salió (lo asigna el charco). Sin pool, se libera al terminar.
var pool

## Segundos que dura la mancha que deja la bola al caer al piso (el último se desvanece).
@export var duracion_mancha := 5.0
## Ancho en píxeles de la mancha.
@export var ancho_mancha := 64.0

func _ready() -> void:
	# Nunca queda tapada por el pasto y las matas del plano de adelante.
	z_index = MeadowFloor.FRONT_Z + 1
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_al_tocar_cuerpo)
	_quedar_en_charco()

## Para reusarla desde el pool: la deja como recién creada, quieta en el
## charco y disponible para levantar.
func reiniciar() -> void:
	recogida = false
	entregado = false
	rotation = 0.0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	add_to_group(&"levantables")
	_quedar_en_charco()
	reset_physics_interpolation()

func _quedar_en_charco() -> void:
	freeze = true
	collision_layer = 0
	collision_mask = 0

## Ya no está en juego (cayó al piso o se entregó al nido): vuelve al pool.
func liberar() -> void:
	# Fuera del grupo, nadie la puede levantar ni entregar mientras está guardada.
	remove_from_group(&"levantables")
	if pool:
		pool.devolver(self)
	else:
		queue_free()

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
	if not recogida and not entregado and cuerpo.is_in_group(&"suelo") \
			and is_in_group(&"levantables"):
		_dejar_mancha(cuerpo)
		liberar()

## Mancha de barro en el piso, hecha con un charco del atlas del piso achicado.
## Va dentro del piso para quedar sobre el pasto y detrás del hornero.
func _dejar_mancha(suelo: Node) -> void:
	var piso: Node = suelo
	while piso != null and not piso is MeadowFloor:
		piso = piso.get_parent()
	if piso == null:
		piso = get_parent()
	var region: Rect2 = MeadowFloor.PUDDLES.pick_random()
	var mancha: Sprite2D = _manchas.tomar()
	mancha.texture = MeadowFloor.ATLAS
	mancha.region_enabled = true
	mancha.region_rect = region
	mancha.flip_h = randf() < 0.5
	mancha.modulate.a = 1.0
	var escala := ancho_mancha / region.size.x
	mancha.scale = Vector2(escala, escala * 0.8)
	if mancha.get_parent() != piso:
		if mancha.is_inside_tree():
			mancha.reparent(piso, false)
		else:
			piso.add_child(mancha)
	mancha.global_position = global_position + Vector2(0, 8)
	var desvanecer := minf(1.0, duracion_mancha)
	var tween := mancha.create_tween()
	tween.tween_interval(duracion_mancha - desvanecer)
	tween.tween_property(mancha, ^"modulate:a", 0.0, desvanecer)
	tween.tween_callback(_manchas.devolver.bind(mancha))
