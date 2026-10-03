extends Control

@export_file("*.tscn") var escena_juego: String = "res://scenes/main.tscn"
@export_multiline var creditos: String = "Un proyecto en desarrollo.\n\nMotor: Godot Engine\nIlustraciones de prototipo: El Brian - Ingeniero Fedorenko - Villadeza Eric."

const AYUDA: String = "VUELO\nWASD o flechas: moverse.\nW / flecha arriba: despegar desde el piso.\nS / flecha abajo: descender.\nEspacio: mantener planeo.\n1: vuelo.   2: planeo fijo.\n\nEN EL PISO\nA/D o flechas izquierda/derecha: caminar.\nAl soltar las teclas, el hornero queda quieto.\n\nINTERACTUAR\nE: picotear y recoger una piedra cercana.\nSi llevás una piedra, E la suelta."

@onready var start: Button = $Contenido/Columna/Start
@onready var ayuda: Button = $Contenido/Columna/ComoJugar
@onready var boton_creditos: Button = $Contenido/Columna/Creditos
@onready var salir: Button = $Contenido/Columna/Salir
@onready var ventana: Control = $Ventana
@onready var titulo_ventana: Label = $Ventana/Panel/Margen/Columna/Titulo
@onready var texto_ventana: RichTextLabel = $Ventana/Panel/Margen/Columna/Texto
@onready var cerrar: Button = $Ventana/Panel/Margen/Columna/Cerrar
var foco_anterior: Control

func _ready() -> void:
	start.pressed.connect(_iniciar)
	ayuda.pressed.connect(func(): _mostrar("Cómo jugar", AYUDA))
	boton_creditos.pressed.connect(func(): _mostrar("Créditos", creditos))
	salir.pressed.connect(_salir)
	cerrar.pressed.connect(_cerrar)
	for boton in [start, ayuda, boton_creditos, salir, cerrar]:
		_estilizar_boton(boton, boton == start)
	$Ventana/Panel.add_theme_stylebox_override("panel", _caja(Color("243936"), Color("bca571"), 20))
	ventana.hide()
	start.grab_focus()
	$HorneroMenu.play(&"viento")

func _iniciar() -> void:
	start.disabled = true
	var error := get_tree().change_scene_to_file(escena_juego)
	if error != OK:
		start.disabled = false
		push_error("Revisá Escena Juego en MenuInicio: " + escena_juego)
		_mostrar("No se pudo iniciar", "La escena de juego todavía no está disponible.")

func _salir() -> void:
	get_tree().quit()

func _mostrar(titulo: String, texto: String) -> void:
	foco_anterior = get_viewport().gui_get_focus_owner()
	titulo_ventana.text = titulo
	texto_ventana.text = texto
	texto_ventana.scroll_to_line(0)
	ventana.show()
	# Evitar llegar a los botones detrás del cuadro usando Tab.
	for boton in [start, ayuda, boton_creditos, salir]:
		boton.focus_mode = Control.FOCUS_NONE
	cerrar.grab_focus()

func _cerrar() -> void:
	ventana.hide()
	for boton in [start, ayuda, boton_creditos, salir]:
		boton.focus_mode = Control.FOCUS_ALL
	if is_instance_valid(foco_anterior):
		foco_anterior.grab_focus()
	else:
		start.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and ventana.visible:
		_cerrar()
		get_viewport().set_input_as_handled()

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

func _estilizar_boton(boton: Button, principal: bool) -> void:
	var fondo := Color("e5be72") if principal else Color(0.08, 0.17, 0.15, 0.90)
	var letras := Color("24342d") if principal else Color("f8edcf")
	boton.add_theme_font_size_override("font_size", 23)
	boton.add_theme_color_override("font_color", letras)
	boton.add_theme_color_override("font_hover_color", Color("25352e"))
	boton.add_theme_color_override("font_pressed_color", Color("25352e"))
	boton.add_theme_color_override("font_focus_color", letras)
	boton.add_theme_stylebox_override("normal", _caja(fondo, Color("bd9c61")))
	boton.add_theme_stylebox_override("hover", _caja(Color("f4d79b"), Color("fff2c4")))
	boton.add_theme_stylebox_override("pressed", _caja(Color("c89a52"), Color("f4d79b")))
	var foco := _caja(Color(0,0,0,0), Color("fff1c1"))
	foco.draw_center = false
	foco.set_border_width_all(3)
	boton.add_theme_stylebox_override("focus", foco)
