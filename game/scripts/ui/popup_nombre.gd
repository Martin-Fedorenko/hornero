extends Control
## Ventana "Nombre de jugador" que aparece la primera vez, antes de poder jugar.
## Con el mismo estilo que las ventanas del menú principal.
## "Aceptar" guarda el nombre en TaloManager (y genera el UUID); "Rechazar"
## juega en modo incógnito: no se genera UUID ni se registra nada.

signal aceptado(nombre: String)
signal rechazado()

const TextoJuego := preload("res://scripts/ui/texto_juego.gd")
const COLOR_LETRAS := Color("f8dc9c")
const COLOR_BORDE_LETRAS := Color("5a2e12")
const COLOR_TEXTO := Color(0.95, 0.92, 0.83)
const COLOR_ERROR := Color("ff8a7a")

var _campo: LineEdit
var _error: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var columna := armar_ventana(self, "Nombre de jugador", "Así vas a aparecer en los rankings.")

	_campo = LineEdit.new()
	_campo.max_length = TaloManager.NAME_MAX_LENGTH
	_campo.placeholder_text = "Tu nombre"
	_campo.custom_minimum_size = Vector2(0, 52)
	_campo.add_theme_font_size_override("font_size", 24)
	_campo.add_theme_color_override("font_color", COLOR_TEXTO)
	_campo.add_theme_color_override("font_placeholder_color", Color(COLOR_TEXTO, 0.4))
	_campo.add_theme_color_override("caret_color", COLOR_LETRAS)
	_campo.add_theme_stylebox_override("normal", _caja(Color(0.08, 0.17, 0.15, 0.9), Color("6f6a4a"), 10))
	_campo.add_theme_stylebox_override("focus", _caja(Color(0.08, 0.17, 0.15, 0.9), Color("fff1c1"), 10))
	_campo.text_submitted.connect(_on_aceptar.unbind(1))
	_campo.text_changed.connect(func(_texto: String) -> void: _error.text = "")
	columna.add_child(_campo)

	_error = Label.new()
	_error.add_theme_font_size_override("font_size", 17)
	_error.add_theme_color_override("font_color", COLOR_ERROR)
	columna.add_child(_error)

	var botones := HBoxContainer.new()
	botones.add_theme_constant_override("separation", 12)
	columna.add_child(botones)
	var rechazar := boton("Rechazar", false)
	rechazar.pressed.connect(_on_rechazar)
	botones.add_child(rechazar)
	var aceptar := boton("Aceptar", true)
	aceptar.pressed.connect(_on_aceptar)
	botones.add_child(aceptar)

	var aviso := Label.new()
	aviso.text = "Si rechazás, jugás en modo incógnito: no se guardan tus estadísticas, pero podés ver los rankings."
	aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	aviso.add_theme_font_size_override("font_size", 15)
	aviso.add_theme_color_override("font_color", Color(COLOR_TEXTO, 0.6))
	columna.add_child(aviso)

	_campo.grab_focus.call_deferred()


func _on_aceptar() -> void:
	var nombre := TaloManager.clean_name(_campo.text)
	if nombre.is_empty():
		_error.text = "Escribí un nombre."
		_campo.grab_focus()
		return
	if not TaloManager.set_player_name(nombre):
		_error.text = "Máximo %d caracteres." % TaloManager.NAME_MAX_LENGTH
		_campo.grab_focus()
		return
	aceptado.emit(nombre)
	queue_free()


func _on_rechazar() -> void:
	TaloManager.play_incognito()
	rechazado.emit()
	queue_free()


## Esc no la cierra: hay que elegir Aceptar o Rechazar.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()


## Sombra sobre toda la pantalla y una ventana centrada con título y detalle.
## Devuelve la columna de la ventana, para agregarle el resto.
static func armar_ventana(raiz: Control, titulo: String, detalle: String) -> VBoxContainer:
	var sombra := ColorRect.new()
	sombra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sombra.color = Color(0.02, 0.06, 0.05, 0.78)
	raiz.add_child(sombra)

	# Centrado en el medio de la pantalla, con ancho fijo (como "Cómo jugar").
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	raiz.add_child(centro)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 0)
	panel.add_theme_stylebox_override("panel", _caja(Color("243936"), Color("bca571"), 20))
	centro.add_child(panel)

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 16)
	panel.add_child(columna)

	var etiqueta_titulo := Label.new()
	etiqueta_titulo.text = titulo
	etiqueta_titulo.add_theme_font_override("font", TextoJuego.fuente())
	etiqueta_titulo.add_theme_font_size_override("font_size", 34)
	etiqueta_titulo.add_theme_color_override("font_color", COLOR_LETRAS)
	etiqueta_titulo.add_theme_color_override("font_outline_color", COLOR_BORDE_LETRAS)
	etiqueta_titulo.add_theme_constant_override("outline_size", 6)
	columna.add_child(etiqueta_titulo)

	var etiqueta_detalle := Label.new()
	etiqueta_detalle.text = detalle
	etiqueta_detalle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta_detalle.add_theme_font_size_override("font_size", 18)
	etiqueta_detalle.add_theme_color_override("font_color", Color(COLOR_TEXTO, 0.8))
	columna.add_child(etiqueta_detalle)
	return columna


## Botón como los del menú: dorado el principal, verde oscuro el secundario.
static func boton(texto: String, principal: bool) -> Button:
	var nuevo := Button.new()
	nuevo.text = texto
	nuevo.custom_minimum_size = Vector2(0, 52)
	nuevo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nuevo.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	nuevo.add_theme_font_size_override("font_size", 23)
	var letras := Color("24342d") if principal else Color("f8edcf")
	for color in ["font_color", "font_focus_color"]:
		nuevo.add_theme_color_override(color, letras)
	for color in ["font_hover_color", "font_pressed_color"]:
		nuevo.add_theme_color_override(color, Color("25352e"))
	var fondo := Color("e5be72") if principal else Color(0.08, 0.17, 0.15, 0.9)
	nuevo.add_theme_stylebox_override("normal", _caja(fondo, Color("bd9c61")))
	nuevo.add_theme_stylebox_override("hover", _caja(Color("f4d79b"), Color("fff2c4")))
	nuevo.add_theme_stylebox_override("pressed", _caja(Color("c89a52"), Color("f4d79b")))
	var foco := _caja(Color(0, 0, 0, 0), Color("fff1c1"))
	foco.draw_center = false
	foco.set_border_width_all(3)
	nuevo.add_theme_stylebox_override("focus", foco)
	return nuevo


static func _caja(fondo: Color, borde: Color, radio: int = 12) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = fondo
	estilo.border_color = borde
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(radio)
	estilo.content_margin_left = 22.0
	estilo.content_margin_right = 22.0
	estilo.content_margin_top = 10.0
	estilo.content_margin_bottom = 10.0
	return estilo
