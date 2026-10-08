extends Control
## Ventana de detalle de un animal: se abre al hacer clic (o Enter) en su
## ficha de la pestaña Fauna. Mismo estilo que la ventana "Cómo jugar".
##
## Mientras no haya una descripción propia, arma el mismo resumen que ya
## tiene la ficha chica (o el aviso de "Próximamente"). Para poner un texto
## más largo alcanza con agregarle la clave "detalle" (BBCode) al diccionario
## del animal en la constante FAUNA de menu_inicio.gd; esta ventana lo usa
## automáticamente y no hace falta tocar este script.

const TextoJuego := preload("res://scripts/ui/texto_juego.gd")
const FaunaFrames := preload("res://scripts/ui/fauna_frames.gd")
const COLOR_LETRAS := Color("f8dc9c")
const COLOR_BORDE_LETRAS := Color("5a2e12")
const COLOR_TEXTO := Color(0.95, 0.92, 0.83)
const COLOR_PELIGRO := "#ff5a4a"

## Diccionario del animal (una entrada de FAUNA); asignar antes de add_child.
var animal: Dictionary

var _cuadros: Array[Texture2D]
var _dibujo: TextureRect
var _fps := 6.0
var _tiempo := 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var sombra := ColorRect.new()
	sombra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sombra.color = Color(0.02, 0.06, 0.05, 0.85)
	add_child(sombra)

	# Mismo tamaño y posición que la ventana "Cómo jugar" / "Fauna": ancho fijo
	# y centrado (no se estira en pantallas ultrawide), alto según el viewport.
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.1
	panel.anchor_bottom = 0.9
	panel.offset_left = -384.0
	panel.offset_right = 384.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.add_theme_stylebox_override("panel", _caja(Color("243936"), Color("bca571"), 20))
	add_child(panel)

	var margen := MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 16)
	margen.add_theme_constant_override("margin_top", 12)
	margen.add_theme_constant_override("margin_right", 16)
	margen.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margen)

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 16)
	margen.add_child(columna)

	var titulo := Label.new()
	titulo.text = animal.get("nombre", "")
	titulo.add_theme_font_override("font", TextoJuego.fuente())
	titulo.add_theme_font_size_override("font_size", 34)
	titulo.add_theme_color_override("font_color", COLOR_LETRAS)
	titulo.add_theme_color_override("font_outline_color", COLOR_BORDE_LETRAS)
	titulo.add_theme_constant_override("outline_size", 6)
	columna.add_child(titulo)

	if animal.get("proximamente", false):
		columna.add_child(_insignia_proximamente())

	_cuadros = FaunaFrames.cortar(animal["hoja"], animal["columnas"], animal["filas_y"],
			animal["alto"], animal.get("margen_x", 10.0))
	_fps = animal.get("fps", 6.0)
	_dibujo = TextureRect.new()
	_dibujo.custom_minimum_size = Vector2(0, 260)
	_dibujo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_dibujo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_dibujo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_dibujo.texture = _cuadros[0]
	columna.add_child(_dibujo)

	var texto := RichTextLabel.new()
	texto.bbcode_enabled = true
	texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texto.add_theme_color_override("default_color", COLOR_TEXTO)
	texto.add_theme_font_size_override("normal_font_size", 19)
	texto.add_theme_font_size_override("bold_font_size", 19)
	texto.text = _texto_detalle()
	columna.add_child(texto)

	var cerrar := Button.new()
	cerrar.text = "Cerrar"
	cerrar.custom_minimum_size = Vector2(0, 52)
	cerrar.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_estilizar_boton(cerrar)
	cerrar.pressed.connect(func() -> void: queue_free())
	columna.add_child(cerrar)
	cerrar.grab_focus.call_deferred()


## Arma el texto con los campos que el animal tenga cargados: "detalle" (un
## texto más largo, a mano) tiene prioridad; si no, se arma a partir de los
## que estén presentes entre descripcion/habitat/peligro/caza/come (los
## "próximamente" hoy sólo traen descripcion+habitat+peligro). Si no hay
## ninguno, el aviso de "Próximamente".
func _texto_detalle() -> String:
	if animal.has("detalle"):
		return animal["detalle"]
	var partes: Array[String] = []
	if animal.has("descripcion"):
		partes.append(animal["descripcion"])
	if animal.has("habitat"):
		partes.append("[b]Dónde vive:[/b] %s" % animal["habitat"])
	if animal.has("peligro"):
		partes.append("[color=%s][b]¿Peligro de extinción?[/b] %s[/color]" % [COLOR_PELIGRO, animal["peligro"]])
	if animal.has("caza"):
		partes.append("[b]¿Lo cazan?[/b] %s" % animal["caza"])
	if animal.has("come"):
		partes.append("[b]Qué come:[/b] %s" % animal["come"])
	if partes.is_empty():
		return "[i]Todavía no aparece en el juego. Pronto vas a poder encontrarlo en la Pampa.[/i]"
	return "\n\n".join(partes)


func _process(delta: float) -> void:
	_tiempo += delta
	_dibujo.texture = _cuadros[int(_tiempo * _fps) % _cuadros.size()]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		queue_free()


func _insignia_proximamente() -> Control:
	var insignia := PanelContainer.new()
	insignia.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("c97a2b")
	estilo.border_color = Color("f8dc9c")
	estilo.set_border_width_all(1)
	estilo.set_corner_radius_all(5)
	estilo.content_margin_left = 10.0
	estilo.content_margin_right = 10.0
	estilo.content_margin_top = 3.0
	estilo.content_margin_bottom = 3.0
	insignia.add_theme_stylebox_override("panel", estilo)
	var etiqueta := Label.new()
	etiqueta.text = "PRÓXIMAMENTE"
	etiqueta.add_theme_font_size_override("font_size", 13)
	etiqueta.add_theme_color_override("font_color", Color("2a1606"))
	insignia.add_child(etiqueta)
	return insignia


func _estilizar_boton(boton: Button) -> void:
	var fondo := Color("e5be72")
	var letras := Color("24342d")
	boton.add_theme_font_size_override("font_size", 23)
	for color in ["font_color", "font_focus_color"]:
		boton.add_theme_color_override(color, letras)
	for color in ["font_hover_color", "font_pressed_color"]:
		boton.add_theme_color_override(color, Color("25352e"))
	boton.add_theme_stylebox_override("normal", _caja(fondo, Color("bd9c61")))
	boton.add_theme_stylebox_override("hover", _caja(Color("f4d79b"), Color("fff2c4")))
	boton.add_theme_stylebox_override("pressed", _caja(Color("c89a52"), Color("f4d79b")))
	var foco := _caja(Color(0, 0, 0, 0), Color("fff1c1"))
	foco.draw_center = false
	foco.set_border_width_all(3)
	boton.add_theme_stylebox_override("focus", foco)


func _caja(fondo: Color, borde: Color, radio: int = 12) -> StyleBoxFlat:
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
