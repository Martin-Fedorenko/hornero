extends Control

@export_file("*.tscn") var escena_juego: String = "res://scenes/main.tscn"
@export_multiline var creditos: String = "Un proyecto en desarrollo.\n\nMotor: Godot Engine\nIlustraciones de prototipo: El Brian - Ingeniero Fedorenko - Villadeza Eric."

const AYUDA: String = "VUELO\nWASD o flechas: moverse.\nW / flecha arriba: despegar desde el piso.\nS / flecha abajo: descender.\nEspacio: mantener planeo.\n1: vuelo.   2: planeo fijo.\n\nEN EL PISO\nA/D o flechas izquierda/derecha: caminar.\nAl soltar las teclas, el hornero queda quieto.\n\nINTERACTUAR\nE: picotear y recoger una piedra cercana.\nSi llevás una piedra, E la suelta."
const HISTORIA: String = "El hornero necesita reunir paja, ramitas, piedras y barro para construir su nido. Vuela por las pampas, recoge materiales y debe volver al nido para entregarlos, mientras el chimango acecha desde el cielo."

const BOTON_JUGAR: Texture2D = preload("res://Hornero_Menu_Inicio/menu_hornero/Botón Jugar de fileteado porteño-2.png")
const BOTON_AYUDA: Texture2D = preload("res://Hornero_Menu_Inicio/menu_hornero/Botón fileteado porteño_ Cómo jugar-4.png")
const BOTON_HISTORIA: Texture2D = preload("res://Hornero_Menu_Inicio/menu_hornero/Botón Historia estilo fileteado porteño-3.png")
const BOTON_CREDITOS: Texture2D = preload("res://Hornero_Menu_Inicio/menu_hornero/Créditos en madera con fileteado porteño-1.png")
const BOTON_SALIR: Texture2D = preload("res://Hornero_Menu_Inicio/menu_hornero/Botón SALIR con fileteado porteño-5.png")
@export_range(10.0, 30.0, 1.0) var intervalo_canto_minimo := 10.0
@export_range(10.0, 30.0, 1.0) var intervalo_canto_maximo := 30.0

@onready var start: Button = $Contenido/Columna/Start
@onready var ayuda: Button = $Contenido/Columna/ComoJugar
@onready var historia: Button = $Contenido/Columna/Historia
@onready var boton_creditos: Button = $Contenido/Columna/Creditos
@onready var salir: Button = $Contenido/Columna/Salir
@onready var musica_menu: AudioStreamPlayer = $MusicaMenu
@onready var _canto_hornero: AudioStreamPlayer = $CantoHornero
@onready var _temporizador_canto: Timer = $TemporizadorCantoHornero
@onready var ventana: Control = $Ventana
@onready var titulo_ventana: Label = $Ventana/Panel/Margen/Columna/Titulo
@onready var texto_ventana: RichTextLabel = $Ventana/Panel/Margen/Columna/Texto
@onready var cerrar: Button = $Ventana/Panel/Margen/Columna/Cerrar
var foco_anterior: Control

func _ready() -> void:
	start.pressed.connect(_iniciar)
	ayuda.pressed.connect(func(): _mostrar("Cómo jugar", AYUDA))
	historia.pressed.connect(func(): _mostrar("Historia", HISTORIA))
	boton_creditos.pressed.connect(func(): _mostrar("Créditos", creditos))
	salir.pressed.connect(_salir)
	cerrar.pressed.connect(_cerrar)
	musica_menu.finished.connect(_reiniciar_musica)
	_estilizar_boton_con_imagen(start, BOTON_JUGAR)
	_estilizar_boton_con_imagen(ayuda, BOTON_AYUDA)
	_estilizar_boton_con_imagen(historia, BOTON_HISTORIA)
	_estilizar_boton_con_imagen(boton_creditos, BOTON_CREDITOS)
	_estilizar_boton_con_imagen(salir, BOTON_SALIR)
	_estilizar_boton(cerrar, false)
	$Ventana/Panel.add_theme_stylebox_override("panel", _caja(Color("243936"), Color("bca571"), 20))
	ventana.hide()
	start.grab_focus()
	$HorneroMenu.play(&"viento")
	musica_menu.play()
	_iniciar_canto_ambiental()

func _reiniciar_musica() -> void:
	musica_menu.play()

func _iniciar_canto_ambiental() -> void:
	_temporizador_canto.timeout.connect(_reproducir_canto)
	_programar_siguiente_canto()

func _programar_siguiente_canto() -> void:
	var minimo := minf(intervalo_canto_minimo, intervalo_canto_maximo)
	var maximo := maxf(intervalo_canto_minimo, intervalo_canto_maximo)
	_temporizador_canto.start(randf_range(minimo, maximo))

func _reproducir_canto() -> void:
	_canto_hornero.play()
	_programar_siguiente_canto()

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
	for boton in [start, ayuda, historia, boton_creditos, salir]:
		boton.focus_mode = Control.FOCUS_NONE
	cerrar.grab_focus()

func _cerrar() -> void:
	ventana.hide()
	for boton in [start, ayuda, historia, boton_creditos, salir]:
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

func _estilizar_boton_con_imagen(boton: Button, imagen: Texture2D) -> void:
	boton.text = ""
	boton.icon = imagen
	boton.expand_icon = true
	boton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boton.custom_minimum_size = Vector2(0, 100)
	boton.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	boton.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	boton.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	boton.add_theme_stylebox_override("disabled", StyleBoxEmpty.new())
	var foco := StyleBoxFlat.new()
	foco.bg_color = Color(0, 0, 0, 0)
	foco.border_color = Color("fff1c1")
	foco.set_border_width_all(2)
	foco.set_corner_radius_all(8)
	boton.add_theme_stylebox_override("focus", foco)
	boton.mouse_entered.connect(func(): boton.modulate = Color(1.08, 1.06, 0.96))
	boton.mouse_exited.connect(func(): boton.modulate = Color.WHITE)
