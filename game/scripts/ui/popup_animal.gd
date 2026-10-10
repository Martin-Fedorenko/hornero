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
const MapaHabitat := preload("res://scripts/ui/mapa_habitat.gd")
const COLOR_LETRAS := Color("f8dc9c")
const COLOR_BORDE_LETRAS := Color("5a2e12")
const COLOR_TEXTO := Color(0.95, 0.92, 0.83)
const COLOR_PELIGRO := "#ff5a4a"

## Diccionario del animal (una entrada de FAUNA); asignar antes de add_child.
var animal: Dictionary

var _cuadros: Array[Texture2D]
var _dibujo: TextureRect
var _modelos: Array[Dictionary] = []
var _modelo_actual := 0
var _fps := 6.0
var _tiempo := 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var sombra := ColorRect.new()
	sombra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sombra.color = Color(0.02, 0.06, 0.05, 0.85)
	add_child(sombra)

	# Ancho fijo y centrado; el cuerpo interior tiene scroll para pantallas bajas.
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.04
	panel.anchor_bottom = 0.96
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
	var cientifico := Label.new()
	cientifico.text = animal.get("cientifico", "")
	cientifico.add_theme_font_size_override("font_size", 18)
	cientifico.add_theme_color_override("font_color", COLOR_TEXTO)
	columna.add_child(cientifico)

	if animal.get("proximamente", false):
		columna.add_child(_insignia_proximamente())

	var cuerpo := ScrollContainer.new()
	cuerpo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cuerpo.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	columna.add_child(cuerpo)
	var contenido := VBoxContainer.new()
	contenido.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenido.add_theme_constant_override("separation", 12)
	cuerpo.add_child(contenido)

	_cuadros = FaunaFrames.cortar(animal["hoja"], animal["columnas"], animal["filas_y"],
			animal["alto"], animal.get("margen_x", 10.0))
	_fps = animal.get("fps", 6.0)
	_modelos.append(animal)
	for modelo in animal.get("modelos_extra", []):
		_modelos.append(modelo)
	var visuales := HBoxContainer.new()
	visuales.add_theme_constant_override("separation", 12)
	visuales.custom_minimum_size.y = 220
	contenido.add_child(visuales)
	var columna_dibujo := VBoxContainer.new()
	columna_dibujo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columna_dibujo.add_theme_constant_override("separation", 5)
	visuales.add_child(columna_dibujo)
	_dibujo = TextureRect.new()
	_dibujo.custom_minimum_size = Vector2(250, 210)
	_dibujo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dibujo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_dibujo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_dibujo.texture = _cuadros[0]
	columna_dibujo.add_child(_dibujo)
	if _modelos.size() > 1:
		_agregar_selector_modelos(columna_dibujo)
	var mapa_columna := VBoxContainer.new()
	mapa_columna.custom_minimum_size = Vector2(230, 0)
	mapa_columna.add_theme_constant_override("separation", 3)
	visuales.add_child(mapa_columna)
	var titulo_mapa := Label.new()
	titulo_mapa.text = "FAUNA_DISTRIBUCION"
	titulo_mapa.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo_mapa.add_theme_font_size_override("font_size", 16)
	titulo_mapa.add_theme_color_override("font_color", COLOR_LETRAS)
	mapa_columna.add_child(titulo_mapa)
	var mapa := MapaHabitat.new()
	mapa.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mapa.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mapa.set_region(animal.get("mapa", "sudamerica"))
	mapa_columna.add_child(mapa)
	var nota_mapa := Label.new()
	nota_mapa.text = "FAUNA_NOTA_MAPA"
	nota_mapa.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nota_mapa.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nota_mapa.add_theme_font_size_override("font_size", 12)
	nota_mapa.add_theme_color_override("font_color", Color(COLOR_TEXTO, 0.75))
	mapa_columna.add_child(nota_mapa)

	var texto := RichTextLabel.new()
	texto.bbcode_enabled = true
	texto.fit_content = true
	texto.scroll_active = false
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.add_theme_color_override("default_color", COLOR_TEXTO)
	texto.add_theme_font_size_override("normal_font_size", 19)
	texto.add_theme_font_size_override("bold_font_size", 19)
	texto.text = _texto_detalle()
	contenido.add_child(texto)

	var cerrar := Button.new()
	cerrar.text = "CERRAR"
	cerrar.custom_minimum_size = Vector2(0, 52)
	cerrar.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_estilizar_boton(cerrar)
	cerrar.pressed.connect(func() -> void: queue_free())
	columna.add_child(cerrar)
	cerrar.grab_focus.call_deferred()


func _agregar_selector_modelos(contenedor: Control) -> void:
	var selector := HBoxContainer.new()
	selector.alignment = BoxContainer.ALIGNMENT_CENTER
	selector.add_theme_constant_override("separation", 8)
	var anterior := Button.new()
	anterior.text = "‹"
	anterior.custom_minimum_size = Vector2(38, 34)
	var siguiente := Button.new()
	siguiente.text = "›"
	siguiente.custom_minimum_size = Vector2(38, 34)
	selector.add_child(anterior)
	selector.add_child(siguiente)
	contenedor.add_child(selector)
	anterior.pressed.connect(func() -> void: _seleccionar_modelo(posmod(_modelo_actual - 1, _modelos.size()), true))
	siguiente.pressed.connect(func() -> void: _seleccionar_modelo((_modelo_actual + 1) % _modelos.size(), true))
	if animal.get("modelo_jugador", false) and Ajustes.hornero_modelo_alternativo:
		_modelo_actual = 1
	_seleccionar_modelo(_modelo_actual)


func _seleccionar_modelo(indice: int, guardar_eleccion: bool = false) -> void:
	_modelo_actual = indice
	var modelo := _modelos[indice]
	_cuadros = FaunaFrames.cortar(modelo["hoja"], modelo["columnas"], modelo["filas_y"],
			modelo["alto"], modelo.get("margen_x", animal.get("margen_x", 10.0)))
	_fps = modelo.get("fps", animal.get("fps", 6.0))
	_tiempo = 0.0
	if not _cuadros.is_empty():
		_dibujo.texture = _cuadros[0]
	if guardar_eleccion and animal.get("modelo_jugador", false):
		Ajustes.cambiar_modelo_hornero(indice > 0)


## Arma el texto con los campos que el animal tenga cargados: "detalle" (un
## texto más largo, a mano) tiene prioridad; si no, se arma a partir de los
## que estén presentes entre descripcion/habitat/peligro/caza/come (los
## "próximamente" hoy sólo traen descripcion+habitat+peligro). Si no hay
## ninguno, el aviso de "Próximamente". Los campos son claves de textos.gd.
func _texto_detalle() -> String:
	if animal.has("detalle"):
		return tr(animal["detalle"])
	var partes: Array[String] = []
	if animal.has("descripcion"):
		partes.append(tr(animal["descripcion"]))
	if animal.has("habitat"):
		partes.append("[b]%s[/b] %s" % [tr("FAUNA_DONDE_VIVE"), tr(animal["habitat"])])
	if animal.has("peligro"):
		partes.append("[color=%s][b]%s[/b] %s[/color]" % [COLOR_PELIGRO, tr("FAUNA_PELIGRO"), tr(animal["peligro"])])
	if animal.has("caza"):
		partes.append("[b]%s[/b] %s" % [tr("FAUNA_PRESIONES"), tr(animal["caza"])])
	if animal.has("come"):
		partes.append("[b]%s[/b] %s" % [tr("FAUNA_COME"), tr(animal["come"])])
	if animal.has("relacion_hornero"):
		partes.append("[b]%s[/b] %s" % [tr("FAUNA_RELACION"), tr(animal["relacion_hornero"])])
	if partes.is_empty():
		return tr("FAUNA_PRONTO")
	return "\n\n".join(partes)


func _process(delta: float) -> void:
	_tiempo += delta
	# Sólo se cambia la textura cuando cambia el cuadro (6 por segundo).
	var cuadro := _cuadros[int(_tiempo * _fps) % _cuadros.size()]
	if _dibujo.texture != cuadro:
		_dibujo.texture = cuadro


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
	etiqueta.text = "FAUNA_PROXIMAMENTE"
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
