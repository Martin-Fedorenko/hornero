extends AnimatedSprite2D

@export var base_scale := 0.25
@export var animacion_vuelo := &"volar"
@export var animacion_picar := &"picar"
## Marcalo si el dibujo original mira hacia la derecha
@export var sprite_mira_derecha := false

@onready var _body: Cotorra = get_parent()

func _ready() -> void:
	scale = Vector2.ONE * base_scale
	_verificar(animacion_vuelo)
	_verificar(animacion_picar)

func _process(_delta: float) -> void:
	flip_h = (_body.facing < 0) == sprite_mira_derecha

	var deseada := animacion_picar if _body.modo == Cotorra.Modo.PICANDO else animacion_vuelo

	# Si no está en la animación correcta, o se frenó, la (re)arrancamos
	if animation != deseada or not is_playing():
		_reproducir(deseada)

func _reproducir(anim: StringName) -> void:
	if sprite_frames and sprite_frames.has_animation(anim):
		play(anim)

func _verificar(anim: StringName) -> void:
	if sprite_frames == null:
		push_error("CotorraAnimator: no tiene SpriteFrames asignado")
	elif not sprite_frames.has_animation(anim):
		push_error("CotorraAnimator: no existe '%s'. Disponibles: %s"
			% [anim, sprite_frames.get_animation_names()])
