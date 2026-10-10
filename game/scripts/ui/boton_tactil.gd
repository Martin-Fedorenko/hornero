class_name BotonTactil
extends Control
## Botón redondo en pantalla para celulares. Mientras el dedo lo aprieta, la
## acción del Input Map queda apretada, igual que la tecla: el juego no
## distingue uno de otro (HorneroInput y los _unhandled_input siguen igual).
##
## Cada botón sigue a su propio dedo (índice del toque), así se pueden apretar
## varios a la vez. Los toques se leen en _input y se marcan como usados para
## que no lleguen a la interfaz; el clic de mouse que el sistema simula con el
## primer dedo lo frena este mismo Control (mouse_filter STOP).
## No procesa nada por cuadro: sólo reacciona a los toques y se redibuja
## cuando cambia de estado.

const TextoJuego := preload("res://scripts/ui/texto_juego.gd")
## Colores del juego (los del panel y las letras de los menús), semitransparentes.
const COLOR_FONDO := Color(0.141, 0.224, 0.212, 0.35)
const COLOR_FONDO_APRETADO := Color(0.898, 0.745, 0.447, 0.45)
const COLOR_BORDE := Color(0.737, 0.647, 0.443, 0.7)
const COLOR_BORDE_APRETADO := Color(1.0, 0.945, 0.757, 0.95)
const COLOR_LETRAS := Color(0.973, 0.863, 0.612, 0.9)
const COLOR_CONTORNO := Color(0.353, 0.18, 0.071, 0.85)

## Acción del Input Map que aprieta.
@export var accion: StringName
@export var texto := ""
## En vez del texto, dibuja el símbolo de pausa (dos barras).
@export var icono_pausa := false
## Cuánto más allá del círculo dibujado se acepta el toque (proporción del radio).
@export var margen_toque := 0.2

## Índice del dedo que lo está apretando; -1 si ninguno.
var _dedo := -1
var _fuente: Font


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	_fuente = TextoJuego.fuente()
	resized.connect(queue_redraw)


func apretado() -> bool:
	return _dedo != -1


## Suelta lo que esté apretando (al pausar, ocultarse o perder el foco).
func soltar() -> void:
	if _dedo == -1:
		return
	_dedo = -1
	_al_soltar()
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var toque := event as InputEventScreenTouch
		if toque.pressed:
			if _dedo == -1 and _toca(toque.position):
				_dedo = toque.index
				_al_tocar(toque.position)
				queue_redraw()
				get_viewport().set_input_as_handled()
		elif toque.index == _dedo:
			# Soltó el dedo (o el sistema canceló el toque).
			soltar()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and (event as InputEventScreenDrag).index == _dedo:
		_al_arrastrar((event as InputEventScreenDrag).position)
		get_viewport().set_input_as_handled()


func _centro_global() -> Vector2:
	return get_global_rect().get_center()


func _radio() -> float:
	return minf(size.x, size.y) * 0.5


func _toca(punto: Vector2) -> bool:
	return punto.distance_to(_centro_global()) <= _radio() * (1.0 + margen_toque)


func _al_tocar(_punto: Vector2) -> void:
	enviar(accion, true)


func _al_arrastrar(_punto: Vector2) -> void:
	pass


func _al_soltar() -> void:
	enviar(accion, false)


## Aprieta o suelta una acción como si fuera su tecla: actualiza el estado de
## Input (is_action_pressed / just_pressed) y llega a los _unhandled_input.
static func enviar(nombre: StringName, apretada: bool) -> void:
	if nombre == &"":
		return
	var evento := InputEventAction.new()
	evento.action = nombre
	evento.pressed = apretada
	evento.strength = 1.0 if apretada else 0.0
	Input.parse_input_event(evento)


func _draw() -> void:
	var centro := size * 0.5
	var radio := _radio()
	if radio <= 0.0:
		return
	_dibujar_base(centro, radio, apretado())
	if icono_pausa:
		var barra := Vector2(radio * 0.18, radio * 0.8)
		for lado in [-1.0, 1.0]:
			var esquina := centro + Vector2(lado * radio * 0.2 - barra.x * 0.5, -barra.y * 0.5)
			draw_rect(Rect2(esquina, barra), COLOR_LETRAS)
	elif texto != "":
		_dibujar_texto(centro, radio)


func _dibujar_base(centro: Vector2, radio: float, resaltado: bool) -> void:
	draw_circle(centro, radio, COLOR_FONDO_APRETADO if resaltado else COLOR_FONDO)
	var grosor := maxf(2.0, radio * 0.05)
	draw_arc(centro, radio - grosor * 0.5, 0.0, TAU, 48,
			COLOR_BORDE_APRETADO if resaltado else COLOR_BORDE, grosor, true)


func _dibujar_texto(centro: Vector2, radio: float) -> void:
	# `texto` es una clave de textos.gd (ALETEAR, PICO, NIDO en el idioma elegido).
	var palabra := tr(texto)
	var letra := maxi(10, roundi(radio * 0.34))
	var ancho := _fuente.get_string_size(palabra, HORIZONTAL_ALIGNMENT_LEFT, -1, letra).x
	# Que entre en el círculo aunque la palabra sea larga.
	if ancho > radio * 1.7:
		letra = maxi(10, floori(letra * radio * 1.7 / ancho))
		ancho = _fuente.get_string_size(palabra, HORIZONTAL_ALIGNMENT_LEFT, -1, letra).x
	var base := centro + Vector2(-ancho * 0.5,
			(_fuente.get_ascent(letra) - _fuente.get_descent(letra)) * 0.5)
	draw_string_outline(_fuente, base, palabra, HORIZONTAL_ALIGNMENT_LEFT, -1, letra,
			maxi(2, roundi(letra * 0.2)), COLOR_CONTORNO)
	draw_string(_fuente, base, palabra, HORIZONTAL_ALIGNMENT_LEFT, -1, letra, COLOR_LETRAS)
