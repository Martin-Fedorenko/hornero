@tool
class_name GatoAnimator
extends AnimatedSprite2D

@export var base_scale := 1.0
@export var sprite_mira_derecha := true
@export var umbral_quieto := 10.0
@export var alinear_patas_abajo := true # pone el borde inferior del frame sobre el origen

@export_group("Animaciones")
@export var animacion_caminar := &"gatoMontez_caminar"
@export var animacion_correr := &"gatoMontez_correr"
@export var animacion_salto := &"gatoMontez_salto"
@export var animacion_ataque := &"gatoMontez_ataque"
## Frame del salto que se muestra mientras sostiene al Hornero (-1 = el último).
## Es el número que muestra el panel de SpriteFrames (empieza en 0).
@export var frame_agarre := 6

@export_group("Ajuste Caminar")
@export var escala_caminar := 1.0
@export var offset_caminar := Vector2.ZERO

@export_group("Ajuste Correr")
@export var escala_correr := 1.0
@export var offset_correr := Vector2.ZERO

@export_group("Ajuste Salto")
@export var escala_salto := 1.0
@export var offset_salto := Vector2.ZERO

@export_group("Ajuste Ataque")
@export var escala_ataque := 1.0
@export var offset_ataque := Vector2.ZERO

var _body: GatoMontes
var _modo_anterior := -1
var _avisadas := {}
## Animación y cuadro para los que ya se aplicaron escala y offset.
var _anim_ajustada := &""
var _frame_ajustado := -1


func _ready() -> void:
	_aplicar_ajustes()
	if Engine.is_editor_hint():
		return
	_body = get_parent() as GatoMontes
	if _body == null:
		push_error("GatoAnimator: el padre no tiene el script GatoMontes.gd")
		return
	_reproducir(animacion_caminar)


func _process(_delta: float) -> void:
	# En el editor solo aplica los ajustes, para poder acomodar cada animación sin darle play
	if Engine.is_editor_hint() or _body == null:
		_aplicar_ajustes()
		return

	flip_h = (_body.facing < 0) == sprite_mira_derecha

	var m: GatoMontes.Modo = _body.modo
	var cambio: bool = int(m) != _modo_anterior
	_modo_anterior = int(m)

	match m:
		GatoMontes.Modo.ZARPAZO:
			if cambio:
				_reproducir_desde_cero(animacion_ataque)
		GatoMontes.Modo.SALTO:
			if cambio:
				_reproducir_desde_cero(animacion_salto)
		GatoMontes.Modo.AGARRE:
			# Se reasegura cada frame, por si algo lo pisa
			_congelar_frame(animacion_salto, frame_agarre)
		_:
			_movimiento()

	# Escala y offset sólo dependen de la animación y el cuadro: no se recalculan
	# si no cambiaron.
	if animation != _anim_ajustada or frame != _frame_ajustado:
		_aplicar_ajustes()


# ---------- Ajustes por animación ----------

func _aplicar_ajustes() -> void:
	_anim_ajustada = animation
	_frame_ajustado = frame
	var esc := 1.0
	var off := Vector2.ZERO
	if animation == animacion_caminar:
		esc = escala_caminar
		off = offset_caminar
	elif animation == animacion_correr:
		esc = escala_correr
		off = offset_correr
	elif animation == animacion_salto:
		esc = escala_salto
		off = offset_salto
	elif animation == animacion_ataque:
		esc = escala_ataque
		off = offset_ataque

	scale = Vector2.ONE * base_scale * esc

	var base_off := Vector2.ZERO
	if alinear_patas_abajo and sprite_frames and sprite_frames.has_animation(animation):
		if sprite_frames.get_frame_count(animation) > 0:
			var tex := sprite_frames.get_frame_texture(animation, frame)
			if tex:
				base_off.y = -tex.get_height() / 2.0
	offset = base_off + off


# ---------- Reproducción ----------

func _movimiento() -> void:
	if absf(_body.velocity.x) < umbral_quieto:
		_quieto(animacion_caminar)
	elif _body.modo == GatoMontes.Modo.PERSECUCION:
		_reproducir(animacion_correr)
	else:
		_reproducir(animacion_caminar)


func _reproducir(anim: StringName) -> void:
	if not _existe(anim):
		return
	if animation != anim or not is_playing():
		play(anim)


func _reproducir_desde_cero(anim: StringName) -> void:
	if not _existe(anim):
		return
	stop() # stop vuelve al frame 0
	play(anim)


func _congelar_frame(anim: StringName, cual: int) -> void:
	if not _existe(anim):
		return
	if animation != anim:
		animation = anim # cambiar la animación resetea el frame a 0
	var total := sprite_frames.get_frame_count(anim)
	var objetivo := total - 1 if cual < 0 else clampi(cual, 0, total - 1)
	if is_playing():
		pause() # pause conserva el frame
	if frame != objetivo:
		frame = objetivo


func _quieto(anim: StringName) -> void:
	if not _existe(anim):
		return
	if animation != anim:
		animation = anim
	if is_playing():
		stop()


func _existe(anim: StringName) -> bool:
	if sprite_frames and sprite_frames.has_animation(anim):
		return true
	if not _avisadas.has(anim):
		_avisadas[anim] = true
		var disponibles := "ninguna"
		if sprite_frames:
			disponibles = str(sprite_frames.get_animation_names())
		push_error("GatoAnimator: no existe '%s'. Disponibles: %s" % [anim, disponibles])
	return false
