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

## Segundos que el hornero queda tirado antes de mostrar "HAS FALLADO".
@export var death_delay := 1.0
## Segundos dentro del nido terminado antes de mostrar "HAS GANADO".
@export var victory_delay := 1.0
## Duración del fundido de entrada.
@export var fade_time := 0.4
@export var option_font_size := 36
## Escala de la opción seleccionada.
@export var selected_scale := 1.12

var tipo := Tipo.PAUSA

@onready var _titulo: Label = $Textos/Titulo
@onready var _opciones: VBoxContainer = $Textos/Opciones


func _ready() -> void:
	# Tiene que seguir andando con el juego pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_titulo.add_theme_font_override("font", _fuente())


func esta_abierto() -> bool:
	return visible


func abrir_pausa() -> void:
	_abrir(Tipo.PAUSA)


func abrir_muerte() -> void:
	await get_tree().create_timer(death_delay, false).timeout
	_abrir(Tipo.MUERTE)


func abrir_victoria() -> void:
	await get_tree().create_timer(victory_delay, false).timeout
	_abrir(Tipo.VICTORIA)


func _abrir(nuevo_tipo: Tipo) -> void:
	if visible:
		return
	tipo = nuevo_tipo
	match tipo:
		Tipo.PAUSA:
			_poner_titulo("PAUSA", COLOR_LETRAS)
			_poner_opciones([["Continuar", _continuar]])
		Tipo.MUERTE:
			_poner_titulo("HAS FALLADO", Color(0.85, 0.2, 0.18))
			_poner_opciones([["Volver a jugar", _volver_a_jugar]])
		Tipo.VICTORIA:
			_poner_titulo("¡HAS GANADO!", Color("efb760"))
			_poner_opciones([["Volver a jugar", _volver_a_jugar]])
	get_tree().paused = true
	modulate.a = 0.0
	visible = true
	create_tween().tween_property(self, ^"modulate:a", 1.0, fade_time)
	(_opciones.get_child(0) as Button).grab_focus()


func _poner_titulo(texto: String, color: Color) -> void:
	_titulo.text = texto
	_titulo.add_theme_color_override("font_color", color)


## Las opciones propias del menú y, siempre, las dos de salir.
func _poner_opciones(propias: Array) -> void:
	for hijo in _opciones.get_children():
		hijo.queue_free()
		_opciones.remove_child(hijo)
	for opcion in propias + [["Salir al menú", _salir_al_menu],
			["Salir al escritorio", _salir_al_escritorio]]:
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


func _unhandled_input(event: InputEvent) -> void:
	if visible and tipo == Tipo.PAUSA and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_continuar()


func _continuar() -> void:
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


static func _fuente() -> SystemFont:
	var fuente := SystemFont.new()
	fuente.font_names = PackedStringArray(["Georgia", "Times New Roman", "serif"])
	fuente.font_weight = 700
	return fuente
