extends Control
## Menú sobre el juego: pausa (Esc), "HAS MUERTO" y "HAS GANADO".
## Pausa el árbol mientras está abierto; las opciones se eligen con el mouse
## o con el teclado (flechas + Enter), con la misma letra que el menú
## principal.

enum Tipo { PAUSA, MUERTE, VICTORIA }

const MENU_PRINCIPAL := "res://Hornero_Menu_Inicio/menu_hornero/menu_inicio.tscn"
## Colores de las letras del logo "HORNERO" (los mismos del menú principal).
const COLOR_LETRAS := Color("f8dc9c")
const COLOR_SELECCION := Color("fff4d0")
const COLOR_BORDE_LETRAS := Color("5a2e12")
const IMAGEN_DERROTA: Texture2D = preload("res://Hornero_Menu_Inicio/menu_hornero/Hornero ante su nido roto.png")
const IMAGEN_VICTORIA: Texture2D = preload("res://Hornero_Menu_Inicio/menu_hornero/Hornero dormido bajo la luna.png")
## Mismo texto de "Cómo jugar" que el menú principal.
const MenuInicio := preload("res://Hornero_Menu_Inicio/menu_hornero/menu_inicio.gd")
const TextoJuego := preload("res://scripts/ui/texto_juego.gd")

## Segundos que el hornero queda tirado antes de mostrar "HAS FALLADO".
@export var death_delay := 1.0
## Segundos dentro del nido terminado antes de mostrar "HAS GANADO".
@export var victory_delay := 1.0
## Duración del fundido de entrada.
@export var fade_time := 0.4
@export var option_font_size := 36
## Escala de la opción seleccionada.
@export var selected_scale := 1.12
## Duración del fundido de la imagen de fondo al perder o ganar.
@export var end_image_fade_time := 2.5
## Franja horizontal (0-1, izquierda y derecha) donde va el menú al perder o ganar: la zona oscura de la imagen.
@export var end_menu_area := Vector2(0.03, 0.42)
## Tamaño del título al perder o ganar, para que entre en esa franja.
@export var end_title_size := 64
## Tamaño del "Tu tiempo" debajo de "¡HAS GANADO!".
@export var time_font_size := 40

var tipo := Tipo.PAUSA
var _imagen_final: TextureRect
## Al ganar, el tiempo que tardó (con la letra del juego).
var _tiempo: Label
## Al perder o ganar, si no se pudo subir el resultado a Talo.
var _aviso_subida: Label
var _subida_fallida := false
var _anclas_textos: Array[float]
var _offsets_textos: Array[float]
var _tamano_titulo: int
var _ayuda: Control
var _texto_ayuda: RichTextLabel
var _boton_cerrar_ayuda: Button
var _foco_antes_de_ayuda: Control

@onready var _textos: VBoxContainer = $Textos
@onready var _titulo: Label = $Textos/Titulo
@onready var _opciones: VBoxContainer = $Textos/Opciones


func _ready() -> void:
	# Tiene que seguir andando con el juego pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_titulo.add_theme_font_override("font", _fuente())
	# La imagen va debajo del título y las opciones.
	_imagen_final = TextureRect.new()
	_imagen_final.set_anchors_preset(Control.PRESET_FULL_RECT)
	_imagen_final.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_imagen_final.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_imagen_final.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_imagen_final.visible = false
	add_child(_imagen_final)
	move_child(_imagen_final, _textos.get_index())
	_anclas_textos = [_textos.anchor_left, _textos.anchor_right]
	_offsets_textos = [_textos.offset_left, _textos.offset_right]
	_tamano_titulo = _titulo.get_theme_font_size(&"font_size")
	_tiempo = TextoJuego.crear(time_font_size)
	_tiempo.custom_minimum_size = Vector2(0.0, _tiempo.size.y)
	_tiempo.visible = false
	_textos.add_child(_tiempo)
	_textos.move_child(_tiempo, _titulo.get_index() + 1)
	_aviso_subida = Label.new()
	_aviso_subida.text = "No fue posible subir tus estadísticas.
Revisá tu conexión a internet."
	_aviso_subida.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aviso_subida.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_aviso_subida.add_theme_font_size_override("font_size", 20)
	_aviso_subida.add_theme_color_override("font_color", Color("ffb4a6"))
	_aviso_subida.add_theme_color_override("font_outline_color", COLOR_BORDE_LETRAS)
	_aviso_subida.add_theme_constant_override("outline_size", 6)
	_aviso_subida.visible = false
	_textos.add_child(_aviso_subida)
	# El envío puede terminar antes o después de que se abra el menú del final.
	TaloManager.result_upload_finished.connect(_on_resultado_subido)
	_crear_ayuda()


func esta_abierto() -> bool:
	return visible


func abrir_pausa() -> void:
	_abrir(Tipo.PAUSA)


func abrir_muerte() -> void:
	await get_tree().create_timer(death_delay, false).timeout
	_abrir(Tipo.MUERTE)


## `tiempo_ms`: lo que tardó en ganar, para mostrarlo debajo del título.
func abrir_victoria(tiempo_ms := -1) -> void:
	await get_tree().create_timer(victory_delay, false).timeout
	_tiempo.text = "Tu tiempo: " + TaloManager.format_time(tiempo_ms)
	_abrir(Tipo.VICTORIA)
	_tiempo.visible = tiempo_ms >= 0 and tipo == Tipo.VICTORIA


func _abrir(nuevo_tipo: Tipo) -> void:
	if visible:
		return
	tipo = nuevo_tipo
	_tiempo.visible = false
	match tipo:
		Tipo.PAUSA:
			_poner_titulo("PAUSA", COLOR_LETRAS)
			_poner_opciones([["Continuar", _continuar], ["Cómo jugar", _mostrar_ayuda],
					["Reiniciar", _volver_a_jugar]])
		Tipo.MUERTE:
			_poner_titulo("HAS FALLADO", Color(0.85, 0.2, 0.18))
			_poner_opciones([["Volver a jugar", _volver_a_jugar]])
		Tipo.VICTORIA:
			_poner_titulo("¡HAS GANADO!", Color("efb760"))
			_poner_opciones([["Volver a jugar", _volver_a_jugar]])
	match tipo:
		Tipo.MUERTE: _preparar_imagen_final(IMAGEN_DERROTA)
		Tipo.VICTORIA: _preparar_imagen_final(IMAGEN_VICTORIA)
		_: _preparar_imagen_final(null)
	get_tree().paused = true
	modulate.a = 0.0
	visible = true
	_actualizar_aviso_subida()
	create_tween().tween_property(self, ^"modulate:a", 1.0, fade_time)
	(_opciones.get_child(0) as Button).grab_focus()


## Al perder o ganar: la imagen va apareciendo de a poco y el menú se corre a la izquierda.
## Sin imagen (pausa), el menú vuelve al centro.
func _on_resultado_subido(ok: bool) -> void:
	_subida_fallida = not ok
	_actualizar_aviso_subida()


func _actualizar_aviso_subida() -> void:
	_aviso_subida.visible = _subida_fallida and visible and tipo != Tipo.PAUSA


func _preparar_imagen_final(imagen: Texture2D) -> void:
	_imagen_final.texture = imagen
	_imagen_final.visible = imagen != null
	if imagen:
		_imagen_final.modulate.a = 0.0
		create_tween().tween_property(_imagen_final, ^"modulate:a", 1.0, end_image_fade_time)
		_textos.anchor_left = end_menu_area.x
		_textos.anchor_right = end_menu_area.y
		_textos.offset_left = 0.0
		_textos.offset_right = 0.0
		_titulo.add_theme_font_size_override("font_size", end_title_size)
	else:
		_textos.anchor_left = _anclas_textos[0]
		_textos.anchor_right = _anclas_textos[1]
		_textos.offset_left = _offsets_textos[0]
		_textos.offset_right = _offsets_textos[1]
		_titulo.add_theme_font_size_override("font_size", _tamano_titulo)


func _poner_titulo(texto: String, color: Color) -> void:
	_titulo.text = texto
	_titulo.add_theme_color_override("font_color", color)


## Las opciones propias del menú y, siempre, las de salir ("Salir al escritorio"
## no va en el navegador, que no puede cerrar la pestaña).
func _poner_opciones(propias: Array) -> void:
	for hijo in _opciones.get_children():
		hijo.queue_free()
		_opciones.remove_child(hijo)
	var salidas := [["Salir al menú", _salir_al_menu]]
	if not OS.has_feature("web"):
		salidas.append(["Salir al escritorio", _salir_al_escritorio])
	for opcion in propias + salidas:
		_opciones.add_child(_boton(opcion[0], opcion[1]))


func _boton(texto: String, accion: Callable) -> Button:
	var boton := Button.new()
	boton.text = texto
	boton.flat = true
	boton.focus_mode = Control.FOCUS_ALL
	boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for estado in ["normal", "hover", "pressed", "disabled", "focus"]:
		boton.add_theme_stylebox_override(estado, StyleBoxEmpty.new())
	boton.add_theme_font_override("font", _fuente())
	boton.add_theme_font_size_override("font_size", option_font_size)
	for color in ["font_color", "font_hover_color", "font_pressed_color"]:
		boton.add_theme_color_override(color, COLOR_LETRAS)
	boton.add_theme_color_override("font_focus_color", COLOR_SELECCION)
	boton.add_theme_color_override("font_hover_pressed_color", COLOR_SELECCION)
	boton.add_theme_color_override("font_outline_color", COLOR_BORDE_LETRAS)
	boton.add_theme_constant_override("outline_size", 10)
	boton.pressed.connect(accion)
	# Pasar el mouse por encima también la selecciona (como en el menú principal).
	boton.mouse_entered.connect(boton.grab_focus)
	boton.resized.connect(func() -> void: boton.pivot_offset = boton.size * 0.5)
	boton.focus_entered.connect(_resaltar.bind(boton, true))
	boton.focus_exited.connect(_resaltar.bind(boton, false))
	return boton


func _resaltar(boton: Button, seleccionado: bool) -> void:
	var escala := Vector2.ONE * (selected_scale if seleccionado else 1.0)
	create_tween().tween_property(boton, ^"scale", escala, 0.1)


## Ventana de instrucciones (igual a "Cómo jugar" del menú principal), con botón para cerrar.
func _crear_ayuda() -> void:
	_ayuda = Control.new()
	_ayuda.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ayuda.visible = false
	add_child(_ayuda)

	var sombra := ColorRect.new()
	sombra.set_anchors_preset(Control.PRESET_FULL_RECT)
	sombra.color = Color(0.02, 0.06, 0.05, 0.78)
	_ayuda.add_child(sombra)

	var panel := PanelContainer.new()
	# Ancho fijo y centrado, para que en pantallas ultrawide no se estire.
	panel.anchor_left = 0.5
	panel.anchor_top = 0.1
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.9
	panel.offset_left = -384.0
	panel.offset_right = 384.0
	panel.add_theme_stylebox_override("panel", _caja(Color("243936"), Color("bca571"), 20))
	_ayuda.add_child(panel)

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 18)
	panel.add_child(columna)

	var titulo := Label.new()
	titulo.text = "Cómo jugar"
	titulo.add_theme_color_override("font_color", Color(0.98, 0.92, 0.77))
	titulo.add_theme_font_size_override("font_size", 34)
	columna.add_child(titulo)

	var texto := RichTextLabel.new()
	texto.bbcode_enabled = true
	texto.text = MenuInicio.texto_ayuda()
	texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texto.add_theme_color_override("default_color", Color(0.95, 0.92, 0.83))
	texto.add_theme_font_size_override("normal_font_size", 20)
	texto.add_theme_font_size_override("bold_font_size", 20)
	columna.add_child(texto)
	_texto_ayuda = texto

	_boton_cerrar_ayuda = Button.new()
	_boton_cerrar_ayuda.text = "Cerrar"
	_boton_cerrar_ayuda.custom_minimum_size = Vector2(0, 52)
	_boton_cerrar_ayuda.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_boton_cerrar_ayuda.add_theme_font_size_override("font_size", 23)
	for color in ["font_color", "font_focus_color"]:
		_boton_cerrar_ayuda.add_theme_color_override(color, Color("24342d"))
	for color in ["font_hover_color", "font_pressed_color"]:
		_boton_cerrar_ayuda.add_theme_color_override(color, Color("25352e"))
	_boton_cerrar_ayuda.add_theme_stylebox_override("normal", _caja(Color("e5be72"), Color("bd9c61")))
	_boton_cerrar_ayuda.add_theme_stylebox_override("hover", _caja(Color("f4d79b"), Color("fff2c4")))
	_boton_cerrar_ayuda.add_theme_stylebox_override("pressed", _caja(Color("c89a52"), Color("f4d79b")))
	var foco := _caja(Color(0, 0, 0, 0), Color("fff1c1"))
	foco.draw_center = false
	foco.set_border_width_all(3)
	_boton_cerrar_ayuda.add_theme_stylebox_override("focus", foco)
	_boton_cerrar_ayuda.pressed.connect(_cerrar_ayuda)
	columna.add_child(_boton_cerrar_ayuda)


func _mostrar_ayuda() -> void:
	_foco_antes_de_ayuda = get_viewport().gui_get_focus_owner()
	_texto_ayuda.scroll_to_line(0)
	_ayuda.visible = true
	# Que Tab o las flechas no lleguen a las opciones de atrás.
	for boton in _opciones.get_children():
		boton.focus_mode = Control.FOCUS_NONE
	_boton_cerrar_ayuda.grab_focus()


func _cerrar_ayuda() -> void:
	_ayuda.visible = false
	for boton in _opciones.get_children():
		boton.focus_mode = Control.FOCUS_ALL
	if is_instance_valid(_foco_antes_de_ayuda):
		_foco_antes_de_ayuda.grab_focus()


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


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not event.is_action_pressed(&"ui_cancel"):
		return
	if _ayuda.visible:
		get_viewport().set_input_as_handled()
		_cerrar_ayuda()
	elif tipo == Tipo.PAUSA:
		get_viewport().set_input_as_handled()
		_continuar()


func _continuar() -> void:
	_cerrar_ayuda()
	visible = false
	get_tree().paused = false


func _volver_a_jugar() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _salir_al_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_PRINCIPAL)


func _salir_al_escritorio() -> void:
	get_tree().quit()


static func _fuente() -> Font:
	return TextoJuego.fuente()
