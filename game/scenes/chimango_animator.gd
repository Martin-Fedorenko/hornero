extends AnimatedSprite2D

@export var base_scale := 0.25
@export var animacion_vuelo := &"vuelo"
@export var animacion_ataque := &"ataque"

@onready var _body: Chimango = get_parent()

var _modo_anterior := -1
var _avisadas := {} # para no repetir errores

func _ready() -> void:
	_reproducir(animacion_vuelo)

func _process(_delta: float) -> void:
	# Invertimos Y cuando mira a la izquierda porque el cuerpo rota 180°
	scale = Vector2(base_scale, base_scale * _body.facing)

	# Solo cambiamos de animación cuando cambia el modo
	if _body.modo != _modo_anterior:
		_modo_anterior = _body.modo
		match _body.modo:
			Chimango.Modo.PICADA:
				_reproducir(animacion_ataque)
			Chimango.Modo.AGARRE:
				_congelar_ultimo_frame(animacion_ataque)
			_:
				_reproducir(animacion_vuelo)

func _reproducir(anim: StringName) -> void:
	if _existe(anim):
		play(anim)

func _congelar_ultimo_frame(anim: StringName) -> void:
	if not _existe(anim):
		return
	animation = anim # cambiar la animación resetea el frame a 0
	frame = sprite_frames.get_frame_count(anim) - 1
	pause() # pause conserva el frame; stop lo volvería a 0

func _existe(anim: StringName) -> bool:
	if sprite_frames and sprite_frames.has_animation(anim):
		return true
	if not _avisadas.has(anim):
		_avisadas[anim] = true
		push_error("ChimangoAnimator: no existe '%s'. Disponibles: %s"
			% [anim, str(sprite_frames.get_animation_names()) if sprite_frames else "ninguna"])
	return false
