extends Control
## Ventana "Nombre de jugador" que aparece la primera vez, antes de poder jugar.
## Con el mismo estilo que las ventanas del menú principal.
## "Aceptar" comprueba en Talo que nadie más use el nombre y lo guarda en
## TaloManager; sin conexión lo usa sólo en esta sesión. "Rechazar" juega en
## modo incógnito: no se registra nada.
## En celulares el teclado del dispositivo se abre al tocar el campo.

signal aceptado(nombre: String)
signal rechazado()

const TextoJuego := preload("res://scripts/ui/texto_juego.gd")
const COLOR_LETRAS := Color("f8dc9c")
const COLOR_BORDE_LETRAS := Color("5a2e12")
const COLOR_TEXTO := Color(0.95, 0.92, 0.83)
const COLOR_ERROR := Color("ff8a7a")
const TecladoWeb := preload("res://scripts/ui/teclado_web.gd")

var _campo: LineEdit
var _error: Label
var _aceptar: Button
var _rechazar: Button
## Se está consultando en Talo si el nombre ya existe.
var _comprobando := false
## Sólo en el navegador de un celular (ver teclado_web.gd).
var _teclado_web: TecladoWeb


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var columna := armar_ventana(self, "NOMBRE_TITULO", "NOMBRE_DETALLE")

	_campo = LineEdit.new()
	_campo.max_length = TaloManager.NAME_MAX_LENGTH
	_campo.placeholder_text = "NOMBRE_PLACEHOLDER"
	_campo.custom_minimum_size = Vector2(0, 52)
	_campo.add_theme_font_size_override("font_size", 24)
	_campo.add_theme_color_override("font_color", COLOR_TEXTO)
	_campo.add_theme_color_override("font_placeholder_color", Color(COLOR_TEXTO, 0.4))
	_campo.add_theme_color_override("caret_color", COLOR_LETRAS)
	_campo.add_theme_stylebox_override("normal", _caja(Color(0.08, 0.17, 0.15, 0.9), Color("6f6a4a"), 10))
	_campo.add_theme_stylebox_override("focus", _caja(Color(0.08, 0.17, 0.15, 0.9), Color("fff1c1"), 10))
	# Mientras se comprueba el nombre el campo no es editable: con la misma caja
	# (márgenes incluidos) el texto no se mueve.
	_campo.add_theme_stylebox_override("read_only", _caja(Color(0.08, 0.17, 0.15, 0.9), Color("6f6a4a"), 10))
	_campo.add_theme_color_override("font_uneditable_color", Color(COLOR_TEXTO, 0.7))
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
	_rechazar = boton("NOMBRE_RECHAZAR", false)
	_rechazar.pressed.connect(_on_rechazar)
	botones.add_child(_rechazar)
	_aceptar = boton("ACEPTAR", true)
	_aceptar.pressed.connect(_on_aceptar)
	botones.add_child(_aceptar)

	var aviso := Label.new()
	aviso.text = "NOMBRE_AVISO"
	aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	aviso.add_theme_font_size_override("font_size", 15)
	aviso.add_theme_color_override("font_color", Color(COLOR_TEXTO, 0.6))
	columna.add_child(aviso)

	if Plataforma.tipo == Plataforma.Tipo.WEB_MOVIL:
		_teclado_web = TecladoWeb.new()
		_teclado_web.enviado.connect(_on_aceptar)
		_campo.add_child(_teclado_web)
	elif Plataforma.tipo == Plataforma.Tipo.MOVIL:
		_campo.gui_input.connect(_on_campo_tocado)
	else:
		# Con teclado físico se puede escribir de entrada. En celulares no: el
		# teclado del dispositivo se abre recién al tocar el campo.
		_campo.grab_focus.call_deferred()


func _on_aceptar() -> void:
	if _comprobando:
		return
	var nombre := TaloManager.clean_name(_campo.text)
	if nombre.is_empty():
		_mostrar_error("NOMBRE_ERROR_VACIO")
		return
	if not TaloManager.is_valid_name(nombre):
		_mostrar_error(tr("NOMBRE_ERROR_LARGO") % TaloManager.NAME_MAX_LENGTH)
		return
	# Los nombres no se repiten: se consulta en Talo antes de guardarlo. Sin
	# conexión se usa sólo en esta sesión (no se envía nada) y la próxima vez
	# se vuelve a pedir: Talo nunca es un requisito para jugar.
	_set_comprobando(true)
	var ocupado: Variant = await TaloManager.is_name_taken(nombre)
	_set_comprobando(false)
	if ocupado == true:
		_mostrar_error("NOMBRE_ERROR_OCUPADO")
		return
	if ocupado == null:
		TaloManager.set_temporary_player_name(nombre)
	else:
		TaloManager.set_player_name(nombre)
	aceptado.emit(nombre)
	queue_free()


func _mostrar_error(texto: String) -> void:
	_error.text = texto
	# En celulares no se enfoca solo: abriría el teclado sin que lo pidan.
	if not Plataforma.tactil:
		_campo.grab_focus()


## Android / iOS: si el campo ya tenía el foco y se cerró el teclado (botón
## "atrás"), tocarlo de nuevo lo vuelve a abrir.
func _on_campo_tocado(event: InputEvent) -> void:
	var toque: bool = (event is InputEventScreenTouch and not event.pressed) \
			or (event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	if not toque or not _campo.editable:
		return
	if not _campo.has_focus():
		_campo.grab_focus()
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		DisplayServer.virtual_keyboard_show(_campo.text, _campo.get_global_rect(),
				DisplayServer.KEYBOARD_TYPE_DEFAULT, _campo.max_length, _campo.caret_column)


func _set_comprobando(valor: bool) -> void:
	_comprobando = valor
	_campo.editable = not valor
	_aceptar.disabled = valor
	_rechazar.disabled = valor
	_aceptar.text = "NOMBRE_COMPROBANDO" if valor else "ACEPTAR"
	if valor and DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		DisplayServer.virtual_keyboard_hide()
	if _teclado_web:
		_teclado_web.actualizar_zona()


func _on_rechazar() -> void:
	if _comprobando:
		return
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
