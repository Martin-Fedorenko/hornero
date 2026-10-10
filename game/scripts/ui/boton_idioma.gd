extends Control
## Botón para cambiar el idioma (español / inglés), al lado del de silenciar en
## el menú. Muestra "ES / EN" con el idioma actual resaltado; al apretarlo pasa
## al otro. Igual que el de silenciar, se dibuja a mano.

const TextoJuego := preload("res://scripts/ui/texto_juego.gd")
const COLOR_NORMAL := Color("f8dc9c")
const COLOR_RESALTADO := Color("fff1c1")
const COLOR_BORDE := Color("5a2e12")
## Opacidad del idioma que no está elegido.
const ALFA_APAGADO := 0.4
const TAMANO_LETRA := 22

var _fuente: Font


func _ready() -> void:
	custom_minimum_size = Vector2(84, 44)
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = "TOOLTIP_IDIOMA"
	_fuente = TextoJuego.fuente()
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	Idioma.cambiado.connect(queue_redraw)


func _gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
			or event.is_action_pressed(&"ui_accept"):
		get_viewport().set_input_as_handled()
		Idioma.cambiar(Idioma.siguiente())


func _draw() -> void:
	var activo := has_focus() or get_global_rect().has_point(get_global_mouse_position())
	var color := COLOR_RESALTADO if activo else COLOR_NORMAL
	var partes: Array[String] = []
	for codigo in Idioma.IDIOMAS:
		if not partes.is_empty():
			partes.append(" / ")
		partes.append(codigo.to_upper())
	var anchos: Array[float] = []
	var total := 0.0
	for parte in partes:
		anchos.append(_fuente.get_string_size(parte, HORIZONTAL_ALIGNMENT_LEFT, -1, TAMANO_LETRA).x)
		total += anchos[-1]
	var x := (size.x - total) * 0.5
	var y := (size.y + _fuente.get_ascent(TAMANO_LETRA) - _fuente.get_descent(TAMANO_LETRA)) * 0.5
	for i in partes.size():
		var elegido := partes[i] == Idioma.actual().to_upper()
		var color_parte := Color(color, 1.0 if elegido else ALFA_APAGADO)
		var base := Vector2(x, y)
		draw_string_outline(_fuente, base, partes[i], HORIZONTAL_ALIGNMENT_LEFT, -1, TAMANO_LETRA,
				4, Color(COLOR_BORDE, color_parte.a))
		draw_string(_fuente, base, partes[i], HORIZONTAL_ALIGNMENT_LEFT, -1, TAMANO_LETRA, color_parte)
		x += anchos[i]
