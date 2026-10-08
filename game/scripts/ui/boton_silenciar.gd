extends Control
## Botón para silenciar/activar el sonido (música y ambiente) del menú.
## Dibuja su propio ícono de parlante a mano, sin depender de ninguna fuente
## ni imagen: se ve igual en escritorio y en la web.

signal alternado(silenciado: bool)

const COLOR_NORMAL := Color("f8dc9c")
const COLOR_RESALTADO := Color("fff1c1")

## No silencia nada por sí solo: quien lo usa escucha `alternado` y aplica
## el silencio donde corresponda (ver _aplicar_silencio en menu_inicio.gd).
var silenciado := false:
	set(valor):
		silenciado = valor
		queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(44, 44)
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = "Silenciar / activar el sonido"
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)


func _gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
			or event.is_action_pressed(&"ui_accept"):
		get_viewport().set_input_as_handled()
		silenciado = not silenciado
		alternado.emit(silenciado)


func _draw() -> void:
	var activo := has_focus() or get_global_rect().has_point(get_global_mouse_position())
	var color := COLOR_RESALTADO if activo else COLOR_NORMAL
	var alto := size.y
	var medio := alto * 0.5
	# La caja del parlante...
	var ancho_caja := size.x * 0.26
	draw_rect(Rect2(0.0, medio - alto * 0.16, ancho_caja, alto * 0.32), color)
	# ...y el cono, abierto hacia la derecha.
	var cono := PackedVector2Array([
		Vector2(ancho_caja, medio - alto * 0.16),
		Vector2(ancho_caja, medio + alto * 0.16),
		Vector2(ancho_caja + size.x * 0.22, medio + alto * 0.40),
		Vector2(ancho_caja + size.x * 0.22, medio - alto * 0.40),
	])
	draw_colored_polygon(cono, color)
	var grosor := maxf(2.0, size.x * 0.07)
	var inicio_x := ancho_caja + size.x * 0.24
	if silenciado:
		# Una cruz en vez de las ondas.
		draw_line(Vector2(inicio_x, medio - alto * 0.22), Vector2(size.x - 2.0, medio + alto * 0.22), color, grosor, true)
		draw_line(Vector2(inicio_x, medio + alto * 0.22), Vector2(size.x - 2.0, medio - alto * 0.22), color, grosor, true)
	else:
		# Dos ondas concéntricas.
		var origen := Vector2(inicio_x, medio)
		for i in 2:
			var radio := size.x * (0.14 + i * 0.16)
			draw_arc(origen, radio, -0.85, 0.85, 10, color, grosor, true)
