class_name HorneroAnimator
extends AnimatedSprite2D
## Traduce el estado del hornero a animaciones. Sólo lee; nunca toca la física.

@export_group("Animaciones")
@export var fly_animation := &"vuelo"
@export var glide_animation := &"planeo"
@export var walk_animation := &"caminar"
@export var idle_animation := &"reposo"
## Velocidad horizontal mínima para considerar que camina (px/s).
@export var walk_threshold := 5.0

@export_group("Orientación del dibujo")
## Ángulo del dibujo respecto del eje +X. Los sprites del hornero miran a la
## derecha, así que es 0. Si se reemplazan por sprites que miren a otro lado,
## se corrige sólo acá.
@export_range(-180.0, 180.0) var sprite_angle_offset_deg := 0.0

@export_group("Poses")
## Escala y desplazamiento (en píxeles de textura) de cada pose, para que el
## cuerpo del dibujo coincida con el collider y las patas toquen el piso.
@export var flight_scale := 0.24
@export var flight_offset := Vector2(20, -46)
@export var walk_scale := 0.20
@export var walk_offset := Vector2(-4, -142)
@export var idle_scale := 0.24
@export var idle_offset := Vector2(-6, -89)

@onready var _body: Hornero = get_parent()


func _ready() -> void:
	_body.flapped.connect(_on_flapped)


func _process(_delta: float) -> void:
	var animation_name := _pick_animation()
	_apply_pose(animation_name)
	if animation != animation_name:
		play(animation_name)


func _pick_animation() -> StringName:
	match _body.state:
		Hornero.State.FLYING:
			return fly_animation
		Hornero.State.GLIDING:
			return glide_animation
	if absf(_body.velocity.x) > walk_threshold:
		return walk_animation
	return idle_animation


func _apply_pose(animation_name: StringName) -> void:
	var pose_scale := flight_scale
	var pose_offset := flight_offset
	if animation_name == walk_animation:
		pose_scale = walk_scale
		pose_offset = walk_offset
	elif animation_name == idle_animation:
		pose_scale = idle_scale
		pose_offset = idle_offset
	rotation = deg_to_rad(sprite_angle_offset_deg)
	offset = pose_offset
	# El cuerpo gira 180° al mirar a la izquierda; invertir Y deja el dibujo
	# derecho y espejado, y el offset queda espejado junto con él.
	scale = Vector2(pose_scale, pose_scale * _body.facing)


func _on_flapped() -> void:
	play(fly_animation)
	frame = 0
