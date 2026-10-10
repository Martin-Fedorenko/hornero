class_name Cotorra
extends CharacterBody2D

signal empezo_a_picar(nido: Node2D)
signal dejo_de_picar(nido: Node2D)

enum Modo { AUSENTE, YENDO, PICANDO, HUYENDO }

const Cercania := preload("res://scripts/world/cercania.gd")
## Zona (local) que cuenta para saber si se la ve, y margen en píxeles de
## pantalla más allá del borde en el que ya se anima.
const RECT_VISIBLE := Rect2(-80, -80, 160, 160)
const MARGEN_ACTIVACION := 128.0

@export var nido: Node2D
@export var hornero: Node2D

@export_group("Vuelo")
@export var velocidad_vuelo := 350.0
@export var aceleracion := 900.0
@export var altura_sobre_nido := 40.0  ## Qué tan arriba del nido se queda suspendida
@export var radio_llegada := 15.0

@export_group("Espantar")
@export var radio_espantar := 140.0   ## Si el Hornero se acerca a esta distancia, huye
@export var velocidad_huida := 600.0
@export_range(0.0, 60.0) var angulo_huida := 25.0  ## Grados de ascenso al huir (0 = horizontal)
@export var duracion_huida_max := 8.0  ## Tope de seguridad: desaparece igual pasado este tiempo

@export_group("Aparición")
## Segundos que espera antes de volver. La cuenta solo corre mientras el nido
## tiene al menos una construcción.
@export var tiempo_ausente_min := 8.0
@export var tiempo_ausente_max := 15.0
@export var distancia_aparicion := 1200.0  ## Desde qué distancia del nido aparece

@export_group("Sonido")
## Distancia al Hornero a partir de la cual ya no se la escucha. Más cerca,
## más fuerte; el volumen máximo es el del nodo Voz.
@export var distancia_audible := 900.0

@onready var _notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var _voz: AudioStreamPlayer = get_node_or_null(^"Voz")
@onready var _volumen_max := _voz.volume_linear if _voz else 1.0

var modo := Modo.AUSENTE
var facing := 1
var _timer := 0.0
var _dir_huida := Vector2.ZERO
var _t_hover := 0.0
## Etapa del nido cuando llegó a picar: rompe una sola por visita.
var _frame_al_llegar := 0

func _ready() -> void:
	add_to_group("cotorras")
	# Su IA sigue fuera de cámara (rompe el nido aunque el Hornero esté
	# lejos); sólo la animación se pausa cuando no se la ve.
	var sprite := get_node_or_null(^"AnimatedSprite2D")
	if sprite:
		Cercania.activar_cerca_de_camara(sprite, self, RECT_VISIBLE, MARGEN_ACTIVACION)
	if nido == null:
		push_error("Cotorra: falta asignar 'nido' en el inspector")
	if hornero == null:
		push_error("Cotorra: falta asignar 'hornero' en el inspector")
	_pasar_a_ausente()

func _process(_delta: float) -> void:
	_actualizar_voz()


## Canta mientras está en escena; el volumen sube a medida que se acerca al
## Hornero y baja cuando se aleja.
func _actualizar_voz() -> void:
	if _voz == null:
		return
	if modo == Modo.AUSENTE or hornero == null:
		if _voz.playing:
			_voz.stop()
		return
	var distancia := global_position.distance_to(hornero.global_position)
	var cercania := clampf(1.0 - distancia / distancia_audible, 0.0, 1.0)
	# Al cuadrado: el oído percibe el volumen así, y el cambio se siente parejo.
	_voz.volume_linear = _volumen_max * cercania * cercania
	if not _voz.playing:
		_voz.play()


func _physics_process(delta: float) -> void:
	if nido == null:
		return

	match modo:
		Modo.AUSENTE:
			# Con el nido en su fase inicial no hay nada que romper: la cuenta
			# queda en pausa hasta que tenga al menos una construcción.
			if _nido_tiene_construcciones():
				_timer -= delta
				if _timer <= 0.0:
					_aparecer()
			return
		Modo.YENDO:
			if _debe_irse():
				_huir()
			else:
				_yendo(delta)
		Modo.PICANDO:
			if _debe_irse():
				_huir()
			else:
				_picando(delta)
		Modo.HUYENDO:
			_huyendo(delta)

	# Solo cambiamos hacia dónde mira si se mueve horizontalmente
	if absf(velocity.x) > 20.0:
		facing = signi(int(velocity.x))

	move_and_slide()

# --- Modos ---

func _yendo(delta: float) -> void:
	var a_punto := _punto_nido() - global_position
	var dist := a_punto.length()

	if dist < radio_llegada:
		modo = Modo.PICANDO
		velocity = Vector2.ZERO
		_frame_al_llegar = nido.construcciones()
		empezo_a_picar.emit(nido)
		return

	# Frena a medida que se acerca para no pasarse de largo
	var factor := clampf(dist / 150.0, 0.25, 1.0)
	var deseada := a_punto.normalized() * velocidad_vuelo * factor
	velocity = velocity.move_toward(deseada, aceleracion * delta)

func _picando(delta: float) -> void:
	# Se mantiene suspendida con un leve vaivén
	_t_hover += delta
	var objetivo := _punto_nido() + Vector2(0, sin(_t_hover * 4.0) * 4.0)
	velocity = (objetivo - global_position) * 8.0

	# Le avisa al nido cuántos segundos estuvo picando
	if nido.has_method("recibir_danio"):
		nido.recibir_danio(delta)

	# Ya rompió su etapa en esta visita: se va.
	if nido.construcciones() < _frame_al_llegar:
		_huir()

func _huyendo(delta: float) -> void:
	velocity = velocity.move_toward(_dir_huida * velocidad_huida, aceleracion * 2.0 * delta)
	_timer -= delta

	# Desaparece recién cuando sale de la pantalla
	if not _notifier.is_on_screen() or _timer <= 0.0:
		_pasar_a_ausente()

# --- Transiciones ---

func _huir() -> void:
	if modo == Modo.PICANDO:
		dejo_de_picar.emit(nido)
	modo = Modo.HUYENDO
	_timer = duracion_huida_max

	# Huye hacia el lado contrario al Hornero (si está justo abajo o no hay
	# Hornero asignado, elige al azar)
	var dx := 0.0
	if hornero != null:
		dx = global_position.x - hornero.global_position.x
	var lado := 1.0
	if absf(dx) > 5.0:
		lado = signf(dx)
	elif randf() < 0.5:
		lado = -1.0

	# Diagonal ascendente: principalmente horizontal, un poco hacia arriba
	var ang := deg_to_rad(angulo_huida)
	_dir_huida = Vector2(lado * cos(ang), -sin(ang))

	# Que mire para el lado de la huida desde el primer frame
	facing = int(lado)

func _pasar_a_ausente() -> void:
	modo = Modo.AUSENTE
	velocity = Vector2.ZERO
	hide()
	_timer = randf_range(tiempo_ausente_min, tiempo_ausente_max)

func _aparecer() -> void:
	var lado := -1.0 if randf() < 0.5 else 1.0
	global_position = nido.global_position + Vector2(lado * distancia_aparicion, -300.0)
	velocity = Vector2.ZERO
	show()
	modo = Modo.YENDO

# --- Helpers ---

func _punto_nido() -> Vector2:
	return nido.global_position + Vector2(0, -altura_sobre_nido)

func _espantada() -> bool:
	return hornero != null and global_position.distance_to(hornero.global_position) < radio_espantar

## Se va si la espantan o si el nido ya no tiene nada que romper.
func _debe_irse() -> bool:
	return _espantada() or not _nido_tiene_construcciones()

## Cada material entregado al nido es una construcción (en Difícil hacen
## falta dos para que avance el dibujo); al principio no tiene ninguna.
func _nido_tiene_construcciones() -> bool:
	return nido.construcciones() > 0
