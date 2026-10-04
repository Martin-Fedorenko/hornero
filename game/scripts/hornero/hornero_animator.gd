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

@export_group("Nido")
## Puntos del dibujo de reposo, en píxeles de la textura: centro de cabeza y
## pico (lo que asoma por la entrada), lo más alto de la cabeza y las patas.
@export var nest_head := Vector2(366, 256)
@export var nest_top := 222.0
@export var nest_feet := 415.0

const NEST_CLIP_SHADER := preload("res://scripts/hornero/nest_clip.gdshader")

@export_group("Daño")
## Color del parpadeo al recibir daño.
@export var damage_color := Color(1.0, 0.2, 0.2)
@export var damage_blinks := 4
## Duración de cada mitad del parpadeo (rojo y normal), en segundos.
@export var damage_blink_time := 0.12

## Animación de transición en curso (rueda), o vacío. Tiene
## prioridad sobre vuelo y planeo hasta que termina.
var _transition := &""
var _damage_tween: Tween

@onready var _body: Hornero = get_parent()
var _clip_material := ShaderMaterial.new()


func _ready() -> void:
	_clip_material.shader = NEST_CLIP_SHADER
	material = _clip_material
	_body.flapped.connect(_on_flapped)
	_body.rolled_upright.connect(_play_transition.bind(roll_animation))
	animation_finished.connect(_on_animation_finished)
	# Vitals todavía no está listo (es hermano posterior), pero ya se puede conectar.
	(_body.get_node(^"Vitals") as HorneroVitals).damaged.connect(_on_damaged)


func _process(_delta: float) -> void:
	if _body.state != Hornero.State.NESTED:
		clear_clip()
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


## Desplazamiento desde el cuerpo hasta un punto del dibujo de reposo (en
## píxeles de la textura), ya escalado y espejado según hacia dónde mira.
func idle_point_offset(texture_point: Vector2) -> Vector2:
	var half_size := sprite_frames.get_frame_texture(idle_animation, 0).get_size() * 0.5
	var local := (texture_point - half_size + idle_offset) * idle_scale
	return Vector2(local.x * _body.facing, local.y)


## Oculta lo que queda por debajo de world_y (borde de un nido abierto).
func clip_below(world_y: float) -> void:
	_clip_material.set_shader_parameter(&"clip_mode", 1)
	_clip_material.set_shader_parameter(&"clip_line", world_y)


## Sólo deja ver lo que cae dentro del círculo (entrada del nido cerrado).
func clip_to_circle(world_center: Vector2, world_radius: float) -> void:
	_clip_material.set_shader_parameter(&"clip_mode", 2)
	_clip_material.set_shader_parameter(&"clip_center", world_center)
	_clip_material.set_shader_parameter(&"clip_radius", world_radius)


func clear_clip() -> void:
	_clip_material.set_shader_parameter(&"clip_mode", 0)


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


## Parpadea en rojo `damage_blinks` veces.
func _on_damaged(_amount: float) -> void:
	if _damage_tween != null:
		_damage_tween.kill()
	_damage_tween = create_tween()
	for i in damage_blinks:
		_damage_tween.tween_callback(set.bind(&"self_modulate", damage_color))
		_damage_tween.tween_interval(damage_blink_time)
		_damage_tween.tween_callback(set.bind(&"self_modulate", Color.WHITE))
		_damage_tween.tween_interval(damage_blink_time)
