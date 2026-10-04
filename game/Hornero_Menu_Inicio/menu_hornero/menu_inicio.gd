extends Control

@export_file("*.tscn") var escena_juego: String = "res://scenes/main.tscn"
# Texto con BBCode, igual que "Cómo jugar". En cada categoría van los tres
# autores, en distinto orden.
@export_multiline var creditos: String = """[b][color=#f8dc9c]DIRECCIÓN DE SONIDO[/color][/b]
Ingeniero Fedorenko Martin · Villadeza Eric · Brian Moulia

[b][color=#f8dc9c]DIRECCIÓN DE IMAGEN, SONIDO, AMBIENTE Y DESARROLLO[/color][/b]
Ingeniero Fedorenko Martin · Villadeza Eric · Brian Moulia

[b][color=#f8dc9c]MOTOR[/color][/b]
Godot Engine

[b][color=#f8dc9c]AGRADECIMIENTOS[/color][/b]
A nuestras novias: la Magíster Cyntia V ♥, la Ingeniera Abril C ♥ y la Ingeniera Arabella B ♥.

Al maestro Gustavo Santaolalla, por crear una obra maestra como "De Ushuaia a La Quiaca". Y perdón por tomarnos el atrevimiento de sumarle el noble cantar del hornero a su pieza.

A la Universidad Tecnológica Nacional, Facultad Regional Buenos Aires, por formarnos como profesionales.

Y sin dudas, a nuestros padres y familia."""

# Texto con BBCode: los títulos usan el dorado del logo (COLOR_LETRAS).
const AYUDA: String = """[b][color=#f8dc9c]OBJETIVO[/color][/b]
Juntá paja, ramitas, piedras y barro y llevalos a tu nido: cada material le suma una etapa. Cuando esté terminado, entrá con [b]G[/b] para ganar. Si el nido queda fuera de pantalla, una flecha te marca dónde está.

[b][color=#f8dc9c]VUELO[/color][/b]
[b]Espacio[/b]: aletear. Cada aletazo te empuja hacia donde apunta el pico (y un poco hacia arriba) y gasta stamina. Desde el piso, despega.
[b]W / ↑[/b]: bajar el pico.   [b]S / ↓[/b]: subir el pico. Funciona como el timón de un avión.
[b]A / D[/b] o [b]← / →[/b]: darte vuelta en el aire.
Cuando no aleteás, planeás: la gravedad siempre tira para abajo y las alas convierten esa caída en avance.
Picar con el pico hacia abajo te hace ganar velocidad; subir el pico cambia esa velocidad por altura.
Si subís el pico demasiado y vas lento, perdés sustentación: el pico se cae y bajás en picada hasta recuperar velocidad.
Podés dar loops: si quedás panza arriba, el hornero rueda solo para enderezarse.

[b][color=#f8dc9c]EN EL PISO[/color][/b]
[b]A / D[/b] o [b]← / →[/b]: caminar.   [b]Espacio[/b]: despegar.
En el piso la stamina se recupera rápido; planeando, de a poco.

[b][color=#f8dc9c]E — PICO[/color][/b]
Cerca de un material, [b]E[/b] lo levanta con el pico. Con algo en el pico, [b]E[/b] lo suelta.
Para entregarlo, soltalo sobre el nido o pasá volando por encima con él.
Cada tanto aparecen bichos en las hojas y los troncos de los árboles. Se comen pasando por encima: devuelven vida y stamina.

[b][color=#f8dc9c]G — NIDO[/color][/b]
Dentro del círculo del nido, [b]G[/b] te mete adentro; otra vez [b]G[/b] te saca.
Adentro recuperás vida y stamina lentamente.
Con el nido techado quedás a salvo: ningún depredador te puede atacar.

[b][color=#f8dc9c]PELIGROS[/color][/b]
[b]Chimango, aguilucho y carancho[/b] atacan desde el aire. Si te agarran, apretá [b]Espacio[/b] varias veces para soltarte; si te sueltan, caés aturdido y perdés vida y stamina.
[b]Gato montés[/b]: acecha en el piso y salta si volás bajo cerca de él.
[b]Cotorra[/b]: pica tu nido y, si la dejás 15 segundos, le rompe una etapa y se va. Acercate para espantarla: si se va antes, no rompe nada.

[b]Esc[/b]: pausa."""
const HISTORIA: String = """[b][color=#f8dc9c]EL PRIMER INGENIERO ARGENTINO[/color][/b]

Cuentan los libros que el primer ingeniero argentino fue Luis Huergo, el que se recibió allá por 1870 y soñó puertos, canales y vías de tren.

Pero los libros no lo saben todo.

Mucho antes de que existieran las universidades, los planos y las reglas de cálculo, en la pampa ya trabajaba otro ingeniero. No tenía título ni diploma, pero tenía un pico firme, alas incansables y un saber que pasaba de padres a hijos. Era un hornero, y en el monte todos lo conocían como [b]Huergo[/b].

Huergo sabía cosas que ningún libro le había enseñado: que el barro tiene que estar húmedo pero no aguado, que la paja y las ramitas lo hacen fuerte como el adobe, que las piedras le dan base, y que la puerta del nido tiene que mirar para el lado contrario al viento. Así, pellada a pellada, levantaba casas de barro que aguantaban tormentas, soles y años enteros.

Pero ser ingeniero en la pampa no es fácil. El chimango, el aguilucho y el carancho vigilan desde el cielo; el gato montés acecha entre los pastos; y la cotorra, envidiosa, viene a picotear la obra ajena.

Ahora te toca a vos ayudar a Huergo: juntá los materiales, esquivá a los que quieren arruinarle el día y terminá el nido antes de que sea tarde.

[i]Moraleja: antes de que el hombre aprendiera a construir, el hornero ya era ingeniero. Y lo sigue siendo, en cada poste y en cada árbol de nuestra tierra.[/i]"""

const COLOR_PELIGRO: String = "#ff5a4a"
# Pestaña "Fauna": hoja de sprites, columnas, inicio en Y de cada fila, alto del recorte y velocidad.
const FAUNA: Array[Dictionary] = [
	{
		"nombre": "Hornero (Furnarius rufus)",
		"hoja": preload("res://assets/hornero/hornero_walk.png"), "columnas": 3, "filas_y": [160, 590], "alto": 300, "fps": 8.0,
		"habitat": "Centro y norte de Argentina, Uruguay, Paraguay, Bolivia y sur de Brasil. Vive en campos, pastizales, plazas y ciudades. Es el Ave Nacional de la Argentina.",
		"peligro": "No está en peligro de extinción (Preocupación menor).",
		"caza": "Casi no se lo caza: es querido en todo el país. Como toda la fauna silvestre, capturarlo es ilegal.",
		"come": "Insectos, larvas, arañas y lombrices que busca caminando por el suelo.",
	},
	{
		"nombre": "Chimango (Milvago chimango)",
		"hoja": preload("res://assets/chimango/chimangwo_walk.png"), "columnas": 6, "filas_y": [200], "alto": 320, "fps": 8.0,
		"habitat": "Sur de Sudamérica: casi toda la Argentina, Chile, Uruguay y sur de Brasil. Campos abiertos, costas y hasta ciudades.",
		"peligro": "No está en peligro de extinción (Preocupación menor).",
		"caza": "Sí, injustamente: algunos lo tratan como plaga y lo matan, aunque ayuda a limpiar el campo de carroña e insectos.",
		"come": "De todo: carroña, insectos, larvas, lombrices, pequeños animales y huevos. Suele seguir a los arados.",
	},
	{
		"nombre": "Aguilucho común (Geranoaetus polyosoma)",
		"hoja": preload("res://assets/Aguilucho/Aguilucho en reposo, seis cuadros.png"), "columnas": 3, "filas_y": [100, 560], "alto": 420, "fps": 4.0,
		"habitat": "Andes y Patagonia, desde Colombia hasta Tierra del Fuego. Estepas, laderas y zonas abiertas.",
		"peligro": "No está en peligro de extinción (Preocupación menor).",
		"caza": "Sí, injustamente: le disparan creyendo que ataca al ganado. También muere electrocutado en tendidos eléctricos.",
		"come": "Roedores, liebres jóvenes, reptiles, aves e insectos grandes. Controla plagas de roedores.",
	},
	{
		"nombre": "Carancho (Caracara plancus)",
		"hoja": preload("res://assets/Carancho/Hoja de sprites del carancho argentino.png"), "columnas": 3, "filas_y": [10, 515], "alto": 490, "fps": 4.0,
		"habitat": "Casi toda Sudamérica y toda la Argentina. Campos abiertos, bordes de rutas y montes.",
		"peligro": "No está en peligro de extinción (Preocupación menor).",
		"caza": "Sí, injustamente: lo envenenan o le disparan acusándolo de atacar corderos, aunque sobre todo come animales ya muertos.",
		"come": "Carroña, insectos, roedores, reptiles, huevos y pichones.",
	},
	{
		"nombre": "Gato montés (Leopardus geoffroyi)",
		"hoja": preload("res://assets/gato_montez/gato_caminando.png"), "columnas": 8, "filas_y": [280], "alto": 180, "fps": 9.0,
		"habitat": "Centro y sur de Sudamérica: gran parte de la Argentina, del monte y el espinal a la pampa y la Patagonia.",
		"peligro": "Hoy no está en peligro de extinción (Preocupación menor), pero la caza para pieles lo diezmó y sigue protegido por CITES.",
		"caza": "Sí, injustamente: durante décadas se exportaron cientos de miles de pieles. Hoy lo matan por atacar gallineros y lo atropellan en las rutas.",
		"come": "Roedores, liebres, aves, reptiles y peces.",
	},
	{
		"nombre": "Cotorra (Myiopsitta monachus)",
		"hoja": preload("res://assets/cotorra/cotorra_walk.png"), "columnas": 6, "filas_y": [210], "alto": 320, "fps": 8.0,
		"habitat": "Centro y norte de Argentina, Uruguay, Paraguay, Bolivia y sur de Brasil. Arma grandes nidos comunitarios de ramitas en árboles y postes.",
		"peligro": "No está en peligro de extinción (Preocupación menor).",
		"caza": "Sí: la declararon plaga agrícola y se la caza y se le destruyen los nidos. También la capturan para venderla como mascota.",
		"come": "Semillas, granos, frutos, brotes, flores y algún insecto.",
	},
]

const BOTON_JUGAR: Texture2D = preload("res://Hornero_Menu_Inicio/menu_hornero/Botón Jugar de fileteado porteño-2.png")
const BOTON_AYUDA: Texture2D = preload("res://Hornero_Menu_Inicio/menu_hornero/Botón fileteado porteño_ Cómo jugar-4.png")
const BOTON_HISTORIA: Texture2D = preload("res://Hornero_Menu_Inicio/menu_hornero/Botón Historia estilo fileteado porteño-3.png")
const BOTON_CREDITOS: Texture2D = preload("res://Hornero_Menu_Inicio/menu_hornero/Créditos en madera con fileteado porteño-1.png")
const BOTON_SALIR: Texture2D = preload("res://Hornero_Menu_Inicio/menu_hornero/Botón SALIR con fileteado porteño-5.png")
# Colores de las letras del logo "HORNERO".
const COLOR_LETRAS: Color = Color("f8dc9c")
const COLOR_BORDE_LETRAS: Color = Color("5a2e12")
@export_range(10.0, 30.0, 1.0) var intervalo_canto_minimo := 5.0
@export_range(10.0, 30.0, 1.0) var intervalo_canto_maximo := 10.0

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
var _pestanas: HBoxContainer
var _pestana_historia: Button
var _pestana_fauna: Button
var _fauna: ScrollContainer
# Cada entrada: {"rect": TextureRect, "cuadros": Array[Texture2D], "fps": float}
var _animales: Array[Dictionary] = []
var _tiempo_fauna := 0.0

func _ready() -> void:
	start.pressed.connect(_iniciar)
	ayuda.pressed.connect(func(): _mostrar("Cómo jugar", AYUDA))
	historia.pressed.connect(_mostrar_historia)
	boton_creditos.pressed.connect(func(): _mostrar("Créditos", creditos))
	salir.pressed.connect(_salir)
	cerrar.pressed.connect(_cerrar)
	musica_menu.finished.connect(_reiniciar_musica)
	_estilizar_boton_con_imagen(start, BOTON_JUGAR, "JUGAR")
	_estilizar_boton_con_imagen(ayuda, BOTON_AYUDA, "CÓMO JUGAR")
	_estilizar_boton_con_imagen(historia, BOTON_HISTORIA, "HISTORIA")
	_estilizar_boton_con_imagen(boton_creditos, BOTON_CREDITOS, "CRÉDITOS")
	_estilizar_boton_con_imagen(salir, BOTON_SALIR, "SALIR")
	_estilizar_boton(cerrar, false)
	texto_ventana.bbcode_enabled = true # Títulos en negrita y color en "Cómo jugar"
	$Ventana/Panel.add_theme_stylebox_override("panel", _caja(Color("243936"), Color("bca571"), 20))
	_crear_pestanas_historia()
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

func _mostrar_historia() -> void:
	_mostrar("Historia", HISTORIA)
	_pestanas.show()
	_elegir_pestana(false)

func _elegir_pestana(fauna: bool) -> void:
	texto_ventana.visible = not fauna
	_fauna.visible = fauna
	titulo_ventana.text = "Fauna" if fauna else "Historia"
	_estilizar_boton(_pestana_historia, not fauna)
	_estilizar_boton(_pestana_fauna, fauna)
	if fauna:
		_fauna.scroll_vertical = 0

func _crear_pestanas_historia() -> void:
	var columna := titulo_ventana.get_parent()
	_pestanas = HBoxContainer.new()
	_pestanas.add_theme_constant_override("separation", 10)
	_pestana_historia = Button.new()
	_pestana_historia.text = "Historia"
	_pestana_fauna = Button.new()
	_pestana_fauna.text = "Fauna"
	for pestana in [_pestana_historia, _pestana_fauna]:
		pestana.custom_minimum_size = Vector2(160, 44)
		pestana.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_pestanas.add_child(pestana)
	_pestana_historia.pressed.connect(_elegir_pestana.bind(false))
	_pestana_fauna.pressed.connect(_elegir_pestana.bind(true))
	columna.add_child(_pestanas)
	columna.move_child(_pestanas, titulo_ventana.get_index() + 1)

	_fauna = ScrollContainer.new()
	_fauna.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_fauna.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var lista := VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista.add_theme_constant_override("separation", 14)
	_fauna.add_child(lista)
	for animal in FAUNA:
		lista.add_child(_crear_ficha(animal))
	columna.add_child(_fauna)
	columna.move_child(_fauna, texto_ventana.get_index() + 1)
	_pestanas.hide()
	_fauna.hide()

func _crear_ficha(animal: Dictionary) -> Control:
	var ficha := PanelContainer.new()
	ficha.add_theme_stylebox_override("panel", _caja(Color(0.08, 0.17, 0.15, 0.9), Color("6f6a4a"), 12))
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 18)
	ficha.add_child(fila)

	var cuadros := _cortar_hoja(animal["hoja"], animal["columnas"], animal["filas_y"], animal["alto"])
	var dibujo := TextureRect.new()
	dibujo.custom_minimum_size = Vector2(190, 150)
	dibujo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dibujo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dibujo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dibujo.texture = cuadros[0]
	fila.add_child(dibujo)
	_animales.append({"rect": dibujo, "cuadros": cuadros, "fps": animal["fps"]})

	var texto := RichTextLabel.new()
	texto.bbcode_enabled = true
	texto.fit_content = true
	texto.scroll_active = false
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.add_theme_color_override("default_color", Color(0.95, 0.92, 0.83))
	texto.add_theme_font_size_override("normal_font_size", 17)
	texto.add_theme_font_size_override("bold_font_size", 17)
	texto.text = "[b][color=#f8dc9c]%s[/color][/b]\n[b]Dónde vive:[/b] %s\n[color=%s][b]¿Peligro de extinción?[/b] %s[/color]\n[b]¿Lo cazan?[/b] %s\n[b]Qué come:[/b] %s" % [
		animal["nombre"], animal["habitat"], COLOR_PELIGRO, animal["peligro"], animal["caza"], animal["come"]]
	fila.add_child(texto)
	return ficha

# Recorta una franja de alto fijo por fila para que el animal no salte entre cuadros.
func _cortar_hoja(hoja: Texture2D, columnas: int, filas_y: Array, alto: float) -> Array[Texture2D]:
	var ancho := float(hoja.get_width()) / columnas
	var cuadros: Array[Texture2D] = []
	for y in filas_y:
		for columna in columnas:
			var cuadro := AtlasTexture.new()
			cuadro.atlas = hoja
			# Se descartan unos píxeles por lado: el pico o la cola del cuadro vecino a veces invade la celda.
			cuadro.region = Rect2(columna * ancho + 10.0, y, floorf(ancho) - 20.0, alto)
			cuadros.append(cuadro)
	return cuadros

func _process(delta: float) -> void:
	if _fauna == null or not _fauna.is_visible_in_tree():
		return
	_tiempo_fauna += delta
	for animal in _animales:
		var cuadros: Array[Texture2D] = animal["cuadros"]
		animal["rect"].texture = cuadros[int(_tiempo_fauna * animal["fps"]) % cuadros.size()]

func _cerrar() -> void:
	ventana.hide()
	_pestanas.hide()
	_fauna.hide()
	texto_ventana.show()
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

# Sólo el botón seleccionado muestra el cartel fileteado; el resto, la palabra.
func _estilizar_boton_con_imagen(boton: Button, imagen: Texture2D, texto: String) -> void:
	boton.expand_icon = true
	boton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boton.custom_minimum_size = Vector2(0, 100)
	for estado in ["normal", "hover", "pressed", "disabled", "focus"]:
		boton.add_theme_stylebox_override(estado, StyleBoxEmpty.new())
	var fuente := SystemFont.new()
	fuente.font_names = PackedStringArray(["Georgia", "Times New Roman", "serif"])
	fuente.font_weight = 700
	boton.add_theme_font_override("font", fuente)
	boton.add_theme_font_size_override("font_size", 36)
	for color in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		boton.add_theme_color_override(color, COLOR_LETRAS)
	boton.add_theme_color_override("font_outline_color", COLOR_BORDE_LETRAS)
	boton.add_theme_constant_override("outline_size", 10)
	var actualizar := func() -> void:
		var seleccionado := boton.has_focus()
		boton.icon = imagen if seleccionado else null
		boton.text = "" if seleccionado else texto
	boton.focus_entered.connect(actualizar)
	boton.focus_exited.connect(actualizar)
	# Pasar el mouse por encima también lo selecciona.
	boton.mouse_entered.connect(func() -> void:
		if boton.focus_mode != Control.FOCUS_NONE:
			boton.grab_focus())
	actualizar.call()
