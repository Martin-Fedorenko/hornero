class_name HorneroAnimator
extends AnimatedSprite2D
@export var interaccion_picoteo: Node
## Traduce el estado del hornero a animaciones. Sólo lee; nunca toca la física.
## Única excepción: avisa al cuerpo cuando termina la animación de recuperarse.

@export_group("Animaciones")
@export var fly_animation := &"vuelo"
@export var glide_animation := &"planeo"
@export var walk_animation := &"caminar"
@export var idle_animation := &"reposo"
@export var fall_animation := &"caida"
@export var recover_animation := &"recuperarse"
@export var roll_animation := &"rotacion_vertical"
## Muerto queda tirado: la animación de recuperarse congelada en este cuadro.
@export var dead_animation := &"recuperarse"
@export var dead_frame := 0
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
@export var glide_scale := 0.20
@export var glide_offset := Vector2(-12, -12)
@export var fall_scale := 0.26
@export var fall_offset := Vector2(0, 0)
@export var recover_scale := 0.26
@export var recover_offset := Vector2(-20, -91)
@export var roll_scale := 0.44
@export var roll_offset := Vector2(0, 0)

## Animación de transición en curso (rueda), o vacío. Tiene
## prioridad sobre vuelo y planeo hasta que termina.
var _transition := &""

@onready var _body: Hornero = get_parent()


func _ready() -> void:
	_body.flapped.connect(_on_flapped)
	_body.rolled_upright.connect(_play_transition.bind(roll_animation))
	animation_finished.connect(_on_animation_finished)


func _process(_delta: float) -> void:
	if is_instance_valid(interaccion_picoteo):
		if interaccion_picoteo.get("ocupado") == true:
			return
	if _body.is_dead():
		_show_dead()
		return
	var animation_name := _pick_animation()
	_apply_pose(animation_name)
	if animation != animation_name:
		play(animation_name)


func _pick_animation() -> StringName:
	if _transition and _body.is_airborne() and _body.state != Hornero.State.FALLING:
		return _transition
	_transition = &""
	match _body.state:
		Hornero.State.FLYING:
			return fly_animation
		Hornero.State.GLIDING:
			return glide_animation
		Hornero.State.FALLING:
			return fall_animation
		Hornero.State.RECOVERING:
			return recover_animation
		Hornero.State.NESTED:
			return idle_animation
	if _body.wants_to_walk or absf(_body.velocity.x) > walk_threshold:
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
	elif animation_name == glide_animation:
		pose_scale = glide_scale
		pose_offset = glide_offset
	elif animation_name == fall_animation:
		pose_scale = fall_scale
		pose_offset = fall_offset
	elif animation_name == recover_animation:
		pose_scale = recover_scale
		pose_offset = recover_offset
	elif animation_name == roll_animation:
		pose_scale = roll_scale
		pose_offset = roll_offset
	rotation = deg_to_rad(sprite_angle_offset_deg)
	offset = pose_offset
	# El cuerpo gira 180° al mirar a la izquierda; invertir Y deja el dibujo
	# derecho y espejado, y el offset queda espejado junto con él.
	scale = Vector2(pose_scale, pose_scale * _body.facing)


func _show_dead() -> void:
	_apply_pose(dead_animation)
	if animation != dead_animation or is_playing():
		play(dead_animation)
		pause()
		frame = dead_frame


func _on_animation_finished() -> void:
	if animation == recover_animation:
		_body.finish_recovery()
	elif animation == _transition:
		_transition = &""


func _on_flapped() -> void:
	if _transition:
		return # Termina la transición; después sigue aleteando.
	play(fly_animation)
	frame = 0


## La rueda está dibujada en la orientación nueva del cuerpo: va de panza
## arriba a panza abajo.
func _play_transition(animation_name: StringName) -> void:
	_transition = animation_name
	_apply_pose(animation_name)
	play(animation_name)
	frame = 0
