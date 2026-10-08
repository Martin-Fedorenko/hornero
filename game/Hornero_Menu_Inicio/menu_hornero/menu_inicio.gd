extends Control

@export_file("*.tscn") var escena_juego: String = "res://scenes/main.tscn"
# Texto con BBCode, igual que "Cómo jugar". En cada categoría van los tres
# autores, en distinto orden.
@export_multiline var creditos: String = """
[b][color=#f8dc9c]DIRECCIÓN DE IMAGEN, SONIDO, AMBIENTE Y DESARROLLO[/color][/b]
Ingeniero Fedorenko Martin · Villadeza Eric · Brian Moulia

[b][color=#f8dc9c]MOTOR[/color][/b]
Godot Engine

[b][color=#f8dc9c]AGRADECIMIENTOS[/color][/b]
A nuestras novias: la Magíster Cyntia V, la Ingeniera Abril C y la Ingeniera Arabella B.

Al maestro Gustavo Santaolalla, por crear una obra maestra como "De Ushuaia a La Quiaca". Y perdón por tomarnos el atrevimiento de sumarle el noble cantar del hornero a su pieza.

A la Universidad Tecnológica Nacional, Facultad Regional Buenos Aires, por formarnos como profesionales.

Y sin dudas, a nuestros padres y familia.

No queremos dejar de agradecer al noble Hornero, nuestra fuente de inspiración."""

# Texto con BBCode: los títulos usan el dorado del logo (COLOR_LETRAS).
const AYUDA: String = """[b][color=#f8dc9c]OBJETIVO[/color][/b]
Juntá paja, ramitas, piedras y barro y llevalos a tu nido: cada material le suma una etapa. Cuando esté terminado, entrá con [b]G[/b] para ganar. Si el nido queda fuera de pantalla, una flecha te marca dónde está.
Arriba a la derecha corre el tiempo de la partida: al ganar te muestra cuánto tardaste.

[b][color=#f8dc9c]DIFICULTAD[/color][/b] (se elige en Configuración)
[b]Fácil[/b]: Perfecto para horneros principiantes.
[b]Difícil[/b]: Solo para veteranos de la Pampa.

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
Algunos árboles tienen ramitas apoyadas en las ramas: agarralas con [b]E[/b] al pasar volando.
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


## Dibujo de los controles (teclas y qué hace cada una) arriba de "Cómo jugar".
## Con preload queda como dependencia y entra en la exportación.
const IMAGEN_AYUDA: Texture2D = preload("res://Hornero_Menu_Inicio/menu_hornero/como_jugar.jpg")
## Ancho del dibujo dentro de la ventana, en píxeles.
const ANCHO_IMAGEN_AYUDA := 660


## "Cómo jugar" completo: el dibujo de los controles arriba y, abajo, AYUDA.
static func texto_ayuda() -> String:
	return "[center][img width=%d]%s[/img][/center]\n\n" % [ANCHO_IMAGEN_AYUDA, IMAGEN_AYUDA.resource_path] + AYUDA


const HISTORIA: String = """[b][color=#f8dc9c]EL PRIMER INGENIERO ARGENTINO[/color][/b]

Cuentan los libros que el primer ingeniero argentino fue Luis Huergo, el que se recibió allá por 1870 y soñó puertos, canales y vías de tren.

Pero los libros no lo saben todo.

Mucho antes de que existieran las universidades, los planos y las reglas de cálculo, en la pampa ya trabajaba otro ingeniero. No tenía título ni diploma, pero tenía un pico firme, alas incansables y un saber que pasaba de padres a hijos. Era un hornero, y en el monte todos lo conocían como [b]Huergo[/b].

Huergo sabía cosas que ningún libro le había enseñado: que el barro tiene que estar húmedo pero no aguado, que la paja y las ramitas lo hacen fuerte como el adobe, que las piedras le dan base, y que la puerta del nido tiene que mirar para el lado contrario al viento. Así, pellada a pellada, levantaba casas de barro que aguantaban tormentas, soles y años enteros.

Pero ser ingeniero en la pampa no es fácil. El chimango, el aguilucho y el carancho vigilan desde el cielo; el gato montés acecha entre los pastos; y la cotorra, envidiosa, viene a picotear la obra ajena.

Ahora te toca a vos ayudar a Huergo: juntá los materiales, esquivá a los que quieren arruinarle el día y terminá el nido antes de que sea tarde.

[i]Moraleja: antes de que el hombre aprendiera a construir, el hornero ya era ingeniero. Y lo sigue siendo, en cada poste y en cada árbol de nuestra tierra.[/i]"""

## Colores del puesto 1, 2 y 3 en los rankings.
const COLORES_PODIO: Array[Color] = [Color("f2c94c"), Color("d9dde3"), Color("d79a5b")]

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
	# --- Próximamente: todavía no están en el juego. Falta escribir hábitat,
	# peligro de extinción, caza y qué come de cada uno (ver mensaje del chat).
	# Las 16 láminas son de assets/Hornero_Fauna_14_Animales/, 1536x1024,
	# 6 poses en 2 filas de 3 (cada celda de 512x512).
	{"nombre": "Halcón", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/halcon.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
	{"nombre": "Gavilán", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/gavilan.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
	{"nombre": "Lechuza", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/lechuza.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
	{"nombre": "Búho", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/buho.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
	{"nombre": "Tordo renegrido", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/tordo_renegrido.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
	{"nombre": "Golondrina", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/golondrina.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
	{"nombre": "Benteveo", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/benteveo.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
	{"nombre": "Cóndor andino", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/Vuelo del cóndor andino en sprites-1.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
	{"nombre": "Comadreja", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/comadreja.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
	{"nombre": "Gato cimarrón", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/gato_cimarron.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
	{"nombre": "Zorro gris", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/zorro.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
	{"nombre": "Ratón de campo", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/roedor.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
	{"nombre": "Puma", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/Puma en carrera, seis poses.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
	{"nombre": "Yarará", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/yarara.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
	{"nombre": "Culebra arborícola", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/culebra.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
	{"nombre": "Lagarto overo", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/lagarto_overo.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true},
]

const TextoJuego := preload("res://scripts/ui/texto_juego.gd")
const PopupNombre := preload("res://scripts/ui/popup_nombre.gd")
const PopupConfirmacion := preload("res://scripts/ui/popup_confirmacion.gd")
## Cartel de madera vacío que aparece detrás de la opción seleccionada.
const CartelFileteado := preload("res://scripts/ui/cartel_fileteado.gd")
# Colores de las letras del logo "HORNERO".
const COLOR_LETRAS: Color = Color("f8dc9c")
const COLOR_BORDE_LETRAS: Color = Color("5a2e12")
## Letras de la opción seleccionada, sobre el cartel.
const COLOR_SELECCION: Color = Color("fff4d0")
const COLOR_TEXTO: Color = Color(0.95, 0.92, 0.83)
## Alto de cada botón del menú: entran los siete en 720 px de alto.
@export var alto_boton := 76.0
## Alto del cartel de la opción seleccionada (un poco más que el botón).
@export var alto_cartel := 94.0
## Tamaño de la letra de las opciones: el mismo, seleccionadas o no.
@export var tamano_opciones := 36
@export_range(10.0, 30.0, 1.0) var intervalo_canto_minimo := 5.0
@export_range(10.0, 30.0, 1.0) var intervalo_canto_maximo := 10.0
## Píxeles por segundo al desplazar el texto de la ventana con flechas o W/S.
@export var velocidad_scroll_teclas := 600.0
## Píxeles por cada paso de la rueda del mouse.
@export var paso_scroll_rueda := 60.0
## Centro del hornero sobre el techo del nido, en píxeles de la imagen de fondo.
@export var hornero_en_fondo := Vector2(1238, 295)
## Escala del hornero por cada píxel de la imagen de fondo.
@export var escala_hornero_en_fondo := 0.392
## Píxeles de la imagen (desde arriba) que siempre se ven, para no cortarle la cabeza
## al hornero en pantallas muy anchas.
@export var margen_superior_fondo := 40.0

@onready var start: Button = $Contenido/Columna/Start
@onready var ayuda: Button = $Contenido/Columna/ComoJugar
@onready var historia: Button = $Contenido/Columna/Historia
@onready var boton_estadisticas: Button = $Contenido/Columna/Estadisticas
@onready var boton_configuracion: Button = $Contenido/Columna/Configuracion
@onready var boton_creditos: Button = $Contenido/Columna/Creditos
@onready var salir: Button = $Contenido/Columna/Salir
@onready var musica_menu: AudioStreamPlayer = $MusicaMenu
@onready var _canto_hornero: AudioStreamPlayer = $CantoHornero
@onready var _temporizador_canto: Timer = $TemporizadorCantoHornero
@onready var ventana: Control = $Ventana
@onready var titulo_ventana: Label = $Ventana/Panel/Margen/Columna/Titulo
@onready var texto_ventana: RichTextLabel = $Ventana/Panel/Margen/Columna/Texto
@onready var cerrar: Button = $Ventana/Panel/Margen/Columna/Cerrar
@onready var _fondo: TextureRect = $Fondo
@onready var _hornero: AnimatedSprite2D = $HorneroMenu
var foco_anterior: Control
var _pestanas: HBoxContainer
var _pestana_historia: Button
var _pestana_fauna: Button
var _fauna: ScrollContainer
# Cada entrada: {"rect": TextureRect, "cuadros": Array[Texture2D], "fps": float}
var _animales: Array[Dictionary] = []
var _tiempo_fauna := 0.0
# Ventana "Estadísticas": pestañas arriba y una página por pestaña.
var _estadisticas: VBoxContainer
var _scroll_estadisticas: ScrollContainer
var _pestanas_estadisticas: Array[Button] = []
var _paginas_estadisticas: Array[Control] = []
var _contenedor_paginas: VBoxContainer
var _pestana_estadisticas_actual := 0
var _aviso_estadisticas: Label
var _boton_borrar: Button
## Se borraron los datos: al cerrar Estadísticas se vuelve a pedir el nombre.
var _pedir_nombre_al_cerrar := false
# Ventana "Configuración".
var _configuracion: VBoxContainer
var _boton_completa: Button
var _boton_ventana: Button
var _boton_facil: Button
var _boton_dificil: Button
var _detalle_dificultad: RichTextLabel

func _ready() -> void:
	start.pressed.connect(_iniciar)
	ayuda.pressed.connect(func(): _mostrar("Cómo jugar", texto_ayuda()))
	historia.pressed.connect(_mostrar_historia)
	boton_estadisticas.pressed.connect(_mostrar_estadisticas)
	boton_configuracion.pressed.connect(_mostrar_configuracion)
	boton_creditos.pressed.connect(func(): _mostrar("Créditos", creditos))
	salir.pressed.connect(_salir)
	cerrar.pressed.connect(_cerrar)
	musica_menu.finished.connect(_reiniciar_musica)
	_estilizar_opcion(start, "JUGAR")
	_estilizar_opcion(ayuda, "CÓMO JUGAR")
	_estilizar_opcion(historia, "HISTORIA")
	_estilizar_opcion(boton_estadisticas, "ESTADÍSTICAS")
	_estilizar_opcion(boton_configuracion, "CONFIGURACIÓN")
	_estilizar_opcion(boton_creditos, "CRÉDITOS")
	_estilizar_opcion(salir, "SALIR")
	# En el navegador el juego no puede cerrar la pestaña.
	salir.visible = not OS.has_feature("web")
	_estilizar_boton(cerrar, false)
	texto_ventana.bbcode_enabled = true # Títulos en negrita y color en "Cómo jugar"
	$Ventana/Panel.add_theme_stylebox_override("panel", _caja(Color("243936"), Color("bca571"), 20))
	_crear_pestanas_historia()
	_crear_estadisticas()
	_crear_configuracion()
	_fondo.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_fondo.stretch_mode = TextureRect.STRETCH_SCALE
	resized.connect(_ajustar_fondo)
	_ajustar_fondo()
	ventana.hide()
	start.grab_focus()
	$HorneroMenu.play(&"viento")
	musica_menu.play()
	_iniciar_canto_ambiental()
	# Los datos de Talo llegan de a poco: cada uno rellena su pestaña.
	TaloManager.player_stats_loaded.connect(_on_estadisticas_personales)
	TaloManager.global_stats_loaded.connect(_on_estadisticas_globales)
	TaloManager.leaderboard_loaded.connect(_on_ranking)
	# La primera vez, antes de poder jugar, se pide el nombre.
	TaloManager.player_stats_reset.connect(_on_estadisticas_borradas)
	if TaloManager.needs_identity_choice():
		_pedir_nombre()

# El fondo cubre toda la pantalla sin deformarse (sobra imagen de los costados o de
# arriba y abajo, según la pantalla) y el hornero se ubica sobre el nido de la imagen,
# así queda encima del nido en cualquier proporción (notebook, 4:3, ultrawide).
func _ajustar_fondo() -> void:
	var imagen := _fondo.texture.get_size()
	var escala := maxf(size.x / imagen.x, size.y / imagen.y)
	var dibujado := imagen * escala
	var origen := (size - dibujado) * 0.5
	# Al recortar arriba y abajo, no subir tanto la imagen que se corte la cabeza del hornero.
	origen.y = clampf(maxf(origen.y, -margen_superior_fondo * escala), size.y - dibujado.y, 0.0)
	_fondo.position = origen
	_fondo.size = dibujado
	_hornero.position = origen + hornero_en_fondo * escala
	_hornero.scale = Vector2.ONE * escala_hornero_en_fondo * escala

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
	if TaloManager.needs_identity_choice():
		_pedir_nombre()
		return
	start.disabled = true
	var error := get_tree().change_scene_to_file(escena_juego)
	if error != OK:
		start.disabled = false
		push_error("Revisá Escena Juego en MenuInicio: " + escena_juego)
		_mostrar("No se pudo iniciar", "La escena de juego todavía no está disponible.")

## Popup "Nombre de jugador": tapa el menú hasta que se acepta un nombre válido.
func _pedir_nombre() -> void:
	for boton in _botones_menu():
		boton.focus_mode = Control.FOCUS_NONE
	var popup := PopupNombre.new()
	popup.aceptado.connect(_on_nombre_aceptado.unbind(1))
	popup.rechazado.connect(_on_nombre_aceptado)
	add_child(popup)

func _on_nombre_aceptado() -> void:
	_pedir_nombre_al_cerrar = false
	# Pedido desde Estadísticas ("Crear nombre"): se queda en la ventana.
	if ventana.visible and _estadisticas.visible:
		_actualizar_boton_identidad()
		_cargar_estadisticas()
		_boton_borrar.grab_focus()
		return
	for boton in _botones_menu():
		boton.focus_mode = Control.FOCUS_ALL
	start.grab_focus()

func _salir() -> void:
	get_tree().quit()

func _mostrar(titulo: String, texto: String) -> void:
	foco_anterior = get_viewport().gui_get_focus_owner()
	titulo_ventana.text = titulo
	texto_ventana.text = texto
	texto_ventana.scroll_to_line(0)
	ventana.show()
	# Evitar llegar a los botones detrás del cuadro usando Tab.
	for boton in _botones_menu():
		boton.focus_mode = Control.FOCUS_NONE
	cerrar.grab_focus()

func _botones_menu() -> Array[Button]:
	return [start, ayuda, historia, boton_estadisticas, boton_configuracion, boton_creditos, salir]

## Ventana con un panel propio (estadísticas, configuración) en lugar del texto.
func _mostrar_panel(titulo: String, panel: Control) -> void:
	_mostrar(titulo, "")
	texto_ventana.hide()
	panel.show()

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

	var columna_texto := VBoxContainer.new()
	columna_texto.add_theme_constant_override("separation", 6)
	columna_texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(columna_texto)

	# Todavía no está en el juego: insignia arriba y, en vez de la ficha
	# completa, un aviso. Falta escribir hábitat/peligro/caza/come.
	if animal.get("proximamente", false):
		columna_texto.add_child(_insignia_proximamente())

	var texto := RichTextLabel.new()
	texto.bbcode_enabled = true
	texto.fit_content = true
	texto.scroll_active = false
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.add_theme_color_override("default_color", Color(0.95, 0.92, 0.83))
	texto.add_theme_font_size_override("normal_font_size", 17)
	texto.add_theme_font_size_override("bold_font_size", 17)
	if animal.get("proximamente", false):
		texto.text = "[b][color=#f8dc9c]%s[/color][/b]\n[i]Todavía no aparece en el juego. Pronto vas a poder encontrarlo en la Pampa.[/i]" % animal["nombre"]
	else:
		texto.text = "[b][color=#f8dc9c]%s[/color][/b]\n[b]Dónde vive:[/b] %s\n[color=%s][b]¿Peligro de extinción?[/b] %s[/color]\n[b]¿Lo cazan?[/b] %s\n[b]Qué come:[/b] %s" % [
			animal["nombre"], animal["habitat"], COLOR_PELIGRO, animal["peligro"], animal["caza"], animal["come"]]
	columna_texto.add_child(texto)
	return ficha

## Cartelito "PRÓXIMAMENTE" para los animales que todavía no están en el juego.
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
	var etiqueta := _texto(13, Color("2a1606"))
	etiqueta.text = "PRÓXIMAMENTE"
	insignia.add_child(etiqueta)
	return insignia

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
	_scroll_con_teclas(delta)
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
	_estadisticas.hide()
	_boton_borrar.hide()
	_configuracion.hide()
	texto_ventana.show()
	if _pedir_nombre_al_cerrar:
		_pedir_nombre_al_cerrar = false
		_pedir_nombre()
		return
	for boton in _botones_menu():
		boton.focus_mode = Control.FOCUS_ALL
	if is_instance_valid(foco_anterior):
		foco_anterior.grab_focus()
	else:
		start.grab_focus()

## Barra vertical de lo que se está leyendo en la ventana (texto o fauna).
func _barra_scroll() -> VScrollBar:
	if _fauna.visible:
		return _fauna.get_v_scroll_bar()
	if _estadisticas.visible:
		return _scroll_estadisticas.get_v_scroll_bar()
	return texto_ventana.get_v_scroll_bar()

func _desplazar(pixeles: float) -> void:
	var barra := _barra_scroll()
	barra.value = clampf(barra.value + pixeles, barra.min_value, barra.max_value - barra.page)

# Mientras se mantiene apretada la tecla, el texto se desliza de corrido.
func _scroll_con_teclas(delta: float) -> void:
	if not ventana.visible:
		return
	var direccion := 0.0
	if Input.is_physical_key_pressed(KEY_DOWN) or Input.is_physical_key_pressed(KEY_S):
		direccion += 1.0
	if Input.is_physical_key_pressed(KEY_UP) or Input.is_physical_key_pressed(KEY_W):
		direccion -= 1.0
	if direccion != 0.0:
		_desplazar(direccion * velocidad_scroll_teclas * delta)

# Con la ventana abierta, la rueda desplaza el texto esté donde esté el mouse,
# y arriba/abajo no mueven el foco entre los botones de la ventana.
func _input(event: InputEvent) -> void:
	if not ventana.visible:
		return
	if event is InputEventMouseButton and event.pressed \
		and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		var sentido := -1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0
		_desplazar(sentido * paso_scroll_rueda * maxf(event.factor, 1.0))
		get_viewport().set_input_as_handled()
	# En Configuración no hay nada que desplazar: las flechas eligen la opción.
	elif event is InputEventKey and event.physical_keycode in [KEY_UP, KEY_DOWN, KEY_W, KEY_S] \
			and not _configuracion.visible:
		get_viewport().set_input_as_handled()

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
# La opción seleccionada muestra el cartel de madera fileteado detrás de la
# palabra, que mantiene su tamaño. El cartel se estira según el largo de la
# palabra, así todas las opciones (también las nuevas) lo tienen.
func _estilizar_opcion(boton: Button, texto: String) -> void:
	boton.text = texto
	boton.custom_minimum_size = Vector2(0, alto_boton)
	for estado in ["normal", "hover", "pressed", "disabled", "focus"]:
		boton.add_theme_stylebox_override(estado, StyleBoxEmpty.new())
	var fuente := TextoJuego.fuente()
	boton.add_theme_font_override("font", fuente)
	boton.add_theme_font_size_override("font_size", tamano_opciones)
	boton.add_theme_color_override("font_outline_color", COLOR_BORDE_LETRAS)
	boton.add_theme_constant_override("outline_size", 10)
	var cartel := CartelFileteado.new()
	boton.add_child(cartel)
	var acomodar := func() -> void:
		var ancho_texto := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano_opciones).x
		var tamano := Vector2(CartelFileteado.ancho_para(ancho_texto + 30.0, alto_cartel), alto_cartel)
		cartel.size = tamano
		cartel.position = (boton.size - tamano) * 0.5
	boton.resized.connect(acomodar)
	acomodar.call()
	var actualizar := func() -> void:
		var seleccionado := boton.has_focus()
		cartel.visible = seleccionado
		for color in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
			boton.add_theme_color_override(color, COLOR_SELECCION if seleccionado else COLOR_LETRAS)
	boton.focus_entered.connect(actualizar)
	boton.focus_exited.connect(actualizar)
	# Pasar el mouse por encima también lo selecciona.
	boton.mouse_entered.connect(func() -> void:
		if boton.focus_mode != Control.FOCUS_NONE:
			boton.grab_focus())
	actualizar.call()


# --- Estadísticas -----------------------------------------------------------

func _mostrar_estadisticas() -> void:
	_mostrar_panel("Estadísticas", _estadisticas)
	# En incógnito no hay estadísticas propias que borrar.
	_actualizar_boton_identidad()
	_elegir_pestana_estadisticas(0)
	_cargar_estadisticas()

## Pide todo a Talo (sin esperar: cada respuesta llega por su señal) y mientras
## tanto muestra "Cargando…".
func _cargar_estadisticas() -> void:
	if TaloManager.has_local_identity():
		_aviso_estadisticas.text = "Jugando como %s" % TaloManager.get_player_name()
	else:
		_aviso_estadisticas.text = "Modo incógnito · tus partidas no se guardan"
	for i in _paginas_estadisticas.size():
		_poner_pagina(i, _pagina_mensaje(_titulo_estadisticas(i), "Cargando…"))
	TaloManager.get_player_stats()
	TaloManager.get_global_stats()
	TaloManager.get_easy_leaderboard()
	TaloManager.get_hard_leaderboard()

func _titulo_estadisticas(indice: int) -> String:
	return ["Tus partidas", "Todos los horneros", "Ranking Global · Fácil",
			"Ranking Global · Difícil"][indice]

func _on_estadisticas_personales(stats: Dictionary) -> void:
	if stats.incognito:
		_poner_pagina(0, _pagina_mensaje(_titulo_estadisticas(0),
				"Estás jugando en modo incógnito: tus estadísticas no se guardan."))
		return
	if not stats.ok:
		_poner_pagina(0, _pagina_sin_conexion(0))
		return
	_poner_pagina(0, _pagina_datos(_titulo_estadisticas(0), [
		["Nidos construidos", str(stats.nests_built)],
		["Muertes", str(stats.deaths)],
		["Mejor tiempo fácil", TaloManager.format_time(stats.best_time_easy_ms)],
		["Mejor tiempo difícil", TaloManager.format_time(stats.best_time_hard_ms)],
	]))

func _on_estadisticas_globales(stats: Dictionary) -> void:
	if not stats.ok:
		_poner_pagina(1, _pagina_sin_conexion(1))
		return
	_poner_pagina(1, _pagina_datos(_titulo_estadisticas(1), [
		["Nidos construidos", str(stats.nests_built)],
		["Muertes", str(stats.deaths)],
	]))

func _on_ranking(tabla: String, ranking: Dictionary) -> void:
	var indice := 2 if tabla == TaloManager.LEADERBOARD_EASY else 3
	if not ranking.ok:
		_poner_pagina(indice, _pagina_sin_conexion(indice))
	elif ranking.entries.is_empty():
		_poner_pagina(indice, _pagina_mensaje(_titulo_estadisticas(indice),
				"Todavía nadie terminó un nido en esta dificultad."))
	else:
		_poner_pagina(indice, _pagina_ranking(_titulo_estadisticas(indice), ranking.entries))

## Cambia la página `indice` por `pagina`, en el mismo lugar y respetando la pestaña elegida.
func _poner_pagina(indice: int, pagina: Control) -> void:
	_contenedor_paginas.add_child(pagina)
	if indice < _paginas_estadisticas.size():
		var vieja := _paginas_estadisticas[indice]
		_contenedor_paginas.move_child(pagina, vieja.get_index())
		vieja.queue_free()
		_paginas_estadisticas[indice] = pagina
	else:
		_paginas_estadisticas.append(pagina)
	pagina.visible = indice == _pestana_estadisticas_actual

func _pagina_sin_conexion(indice: int) -> Control:
	return _pagina_mensaje(_titulo_estadisticas(indice),
			"No se pudo conectar con el servidor. Probá de nuevo más tarde.")

func _pagina_mensaje(titulo: String, mensaje: String) -> Control:
	var ficha := _ficha()
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 12)
	ficha.add_child(columna)
	columna.add_child(_titulo_pagina(titulo))
	var texto := _texto(20, COLOR_TEXTO)
	texto.text = mensaje
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	columna.add_child(texto)
	return ficha

## Pestañas Personal / Global / Ranking Global Fácil / Ranking Global Difícil,
## con los datos de Talo.
func _crear_estadisticas() -> void:
	var columna := titulo_ventana.get_parent()
	_estadisticas = VBoxContainer.new()
	_estadisticas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_estadisticas.add_theme_constant_override("separation", 14)

	var pestanas := HBoxContainer.new()
	pestanas.add_theme_constant_override("separation", 8)
	_estadisticas.add_child(pestanas)
	for nombre in ["Personal", "Global", "Ranking Fácil", "Ranking Difícil"]:
		var pestana := Button.new()
		pestana.text = nombre
		pestana.custom_minimum_size = Vector2(0, 44)
		pestana.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pestana.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		pestana.pressed.connect(_elegir_pestana_estadisticas.bind(_pestanas_estadisticas.size()))
		pestanas.add_child(pestana)
		_pestanas_estadisticas.append(pestana)

	_scroll_estadisticas = ScrollContainer.new()
	_scroll_estadisticas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll_estadisticas.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_estadisticas.add_child(_scroll_estadisticas)
	_contenedor_paginas = VBoxContainer.new()
	_contenedor_paginas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll_estadisticas.add_child(_contenedor_paginas)
	for i in 4:
		_poner_pagina(i, _pagina_mensaje(_titulo_estadisticas(i), "Cargando…"))

	_aviso_estadisticas = _texto(15, Color(COLOR_TEXTO, 0.6))
	_aviso_estadisticas.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_estadisticas.add_child(_aviso_estadisticas)

	# "Borrar estadísticas", a la derecha del título de la ventana.
	# A la derecha del título de la ventana: "Borrar estadísticas" o, en
	# incógnito, "Crear nombre".
	_boton_borrar = Button.new()
	_boton_borrar.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_estilizar_boton(_boton_borrar, false)
	_boton_borrar.add_theme_font_size_override("font_size", 17)
	_boton_borrar.pressed.connect(_on_boton_identidad)
	titulo_ventana.add_child(_boton_borrar)
	_boton_borrar.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_boton_borrar.grow_vertical = Control.GROW_DIRECTION_BOTH
	_boton_borrar.hide()

	columna.add_child(_estadisticas)
	columna.move_child(_estadisticas, texto_ventana.get_index() + 1)
	_estadisticas.hide()

## Con nombre: "Borrar estadísticas" (en rojo). En incógnito: "Crear nombre" (dorado).
func _actualizar_boton_identidad() -> void:
	var con_nombre := TaloManager.has_local_identity()
	_boton_borrar.text = "Borrar estadísticas" if con_nombre else "Crear nombre"
	for color in ["font_color", "font_focus_color"]:
		_boton_borrar.add_theme_color_override(color, Color("ffb4a6") if con_nombre else COLOR_LETRAS)
	_boton_borrar.disabled = false
	_boton_borrar.show()
	# Se reacomoda al ancho del texto nuevo, pegado a la derecha.
	_boton_borrar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT, Control.PRESET_MODE_MINSIZE)

func _on_boton_identidad() -> void:
	if TaloManager.has_local_identity():
		_confirmar_borrado()
	else:
		_pedir_nombre()

func _confirmar_borrado() -> void:
	var popup := PopupConfirmacion.new()
	popup.titulo = "Borrar estadísticas"
	popup.mensaje = "Se borran tu nombre, tus nidos construidos, tus muertes y tus tiempos de los rankings. Las estadísticas globales no cambian. No se puede deshacer."
	popup.respondido.connect(_on_confirmacion_borrado)
	add_child(popup)

func _on_confirmacion_borrado(aceptado: bool) -> void:
	_boton_borrar.grab_focus()
	if not aceptado:
		return
	_boton_borrar.disabled = true
	_aviso_estadisticas.text = "Borrando tus estadísticas…"
	TaloManager.reset_player_stats()

func _on_estadisticas_borradas(ok: bool) -> void:
	_boton_borrar.disabled = false
	if not _estadisticas.visible or not ventana.visible:
		# Ya cerró Estadísticas mientras se borraba: se pide el nombre ahora.
		if ok:
			_pedir_nombre()
		return
	if ok:
		_pedir_nombre_al_cerrar = true
		_actualizar_boton_identidad()
		_cargar_estadisticas()
		_aviso_estadisticas.text = "Tus datos se borraron. Ahora estás en modo incógnito."
	else:
		_aviso_estadisticas.text = "No fue posible borrar tus estadísticas. Revisá tu conexión a internet."

func _elegir_pestana_estadisticas(indice: int) -> void:
	_pestana_estadisticas_actual = indice
	for i in _paginas_estadisticas.size():
		_paginas_estadisticas[i].visible = i == indice
		_estilizar_pestana(_pestanas_estadisticas[i], i == indice)
	_scroll_estadisticas.scroll_vertical = 0

## Como las pestañas de Historia, pero con menos relleno: entran las cuatro.
func _estilizar_pestana(pestana: Button, activa: bool) -> void:
	_estilizar_boton(pestana, activa)
	pestana.add_theme_font_size_override("font_size", 19)
	for estado in ["normal", "hover", "pressed", "focus"]:
		var estilo := pestana.get_theme_stylebox(estado) as StyleBoxFlat
		estilo.content_margin_left = 8.0
		estilo.content_margin_right = 8.0

## Tabla de dos columnas (dato y valor) dentro de una ficha como las de Fauna.
func _pagina_datos(titulo: String, datos: Array) -> Control:
	var ficha := _ficha()
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 12)
	ficha.add_child(columna)
	columna.add_child(_titulo_pagina(titulo))
	var tabla := GridContainer.new()
	tabla.columns = 2
	tabla.add_theme_constant_override("h_separation", 24)
	tabla.add_theme_constant_override("v_separation", 10)
	columna.add_child(tabla)
	for dato in datos:
		var nombre := _texto(20, COLOR_TEXTO)
		nombre.text = dato[0]
		nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tabla.add_child(nombre)
		var valor := _texto(20, COLOR_LETRAS)
		valor.text = dato[1]
		valor.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		tabla.add_child(valor)
	return ficha

## Ranking: puesto, nombre y tiempo; filas alternadas, el podio en color y la
## fila del jugador resaltada. `filas`: entradas de TaloManager.get_leaderboard().
func _pagina_ranking(titulo: String, filas: Array) -> Control:
	var ficha := _ficha()
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 4)
	ficha.add_child(columna)
	columna.add_child(_titulo_pagina(titulo))
	columna.add_child(_fila_ranking("#", "Nombre", "Tiempo", COLOR_LETRAS, Color(0, 0, 0, 0)))
	for i in filas.size():
		var color := COLORES_PODIO[i] if i < COLORES_PODIO.size() else COLOR_TEXTO
		var fondo := Color(1, 1, 1, 0.06) if i % 2 == 0 else Color(0, 0, 0, 0)
		var fila: Dictionary = filas[i]
		var nombre: String = fila.name
		if fila.is_player:
			fondo = Color(COLOR_LETRAS, 0.18)
			nombre += " (vos)"
		columna.add_child(_fila_ranking(str(fila.position), nombre,
				TaloManager.format_time(fila.time_ms), color, fondo))
	return ficha

func _fila_ranking(puesto: String, nombre: String, tiempo: String, color: Color, fondo: Color) -> Control:
	var fila := PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = fondo
	estilo.set_corner_radius_all(6)
	estilo.content_margin_left = 12.0
	estilo.content_margin_right = 12.0
	estilo.content_margin_top = 5.0
	estilo.content_margin_bottom = 5.0
	fila.add_theme_stylebox_override("panel", estilo)
	var celdas := HBoxContainer.new()
	celdas.add_theme_constant_override("separation", 16)
	fila.add_child(celdas)
	var columna_puesto := _texto(20, color)
	columna_puesto.text = puesto
	columna_puesto.custom_minimum_size = Vector2(44, 0)
	celdas.add_child(columna_puesto)
	var columna_nombre := _texto(20, color)
	columna_nombre.text = nombre
	columna_nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columna_nombre.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	celdas.add_child(columna_nombre)
	var columna_tiempo := _texto(20, color)
	columna_tiempo.text = tiempo
	columna_tiempo.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	celdas.add_child(columna_tiempo)
	return fila

func _ficha() -> PanelContainer:
	var ficha := PanelContainer.new()
	ficha.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ficha.add_theme_stylebox_override("panel", _caja(Color(0.08, 0.17, 0.15, 0.9), Color("6f6a4a"), 12))
	return ficha

## Título dorado con la letra del juego, como las palabras del menú.
func _titulo_pagina(texto: String) -> Label:
	var titulo := _texto(26, COLOR_LETRAS)
	titulo.text = texto
	titulo.add_theme_font_override("font", TextoJuego.fuente())
	titulo.add_theme_color_override("font_outline_color", COLOR_BORDE_LETRAS)
	titulo.add_theme_constant_override("outline_size", 6)
	return titulo

func _texto(tamano: int, color: Color) -> Label:
	var etiqueta := Label.new()
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	return etiqueta

# --- Configuración ----------------------------------------------------------

func _mostrar_configuracion() -> void:
	_mostrar_panel("Configuración", _configuracion)
	# Refleja la ventana real: en el navegador se puede salir con Esc.
	var modo := DisplayServer.window_get_mode()
	var completa := modo == DisplayServer.WINDOW_MODE_FULLSCREEN 			or modo == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	_actualizar_pantalla(completa)
	_actualizar_dificultad()
	(_boton_completa if completa else _boton_ventana).grab_focus()

## Pantalla (Completa / Ventana) y dificultad (Fácil / Difícil). Se guardan en Ajustes.
func _crear_configuracion() -> void:
	var columna := titulo_ventana.get_parent()
	_configuracion = VBoxContainer.new()
	_configuracion.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_configuracion.add_theme_constant_override("separation", 14)

	var ficha_pantalla := _ficha()
	_configuracion.add_child(ficha_pantalla)
	var pantalla := VBoxContainer.new()
	pantalla.add_theme_constant_override("separation", 12)
	ficha_pantalla.add_child(pantalla)
	pantalla.add_child(_titulo_pagina("Pantalla"))
	var opciones_pantalla := HBoxContainer.new()
	opciones_pantalla.add_theme_constant_override("separation", 10)
	pantalla.add_child(opciones_pantalla)
	_boton_completa = Button.new()
	_boton_completa.text = "Completa"
	_boton_ventana = Button.new()
	_boton_ventana.text = "Ventana"
	for boton in [_boton_completa, _boton_ventana]:
		boton.custom_minimum_size = Vector2(0, 48)
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		opciones_pantalla.add_child(boton)
	_boton_completa.pressed.connect(_elegir_pantalla.bind(true))
	_boton_ventana.pressed.connect(_elegir_pantalla.bind(false))

	var ficha_dificultad := _ficha()
	_configuracion.add_child(ficha_dificultad)
	var dificultad := VBoxContainer.new()
	dificultad.add_theme_constant_override("separation", 12)
	ficha_dificultad.add_child(dificultad)
	dificultad.add_child(_titulo_pagina("Dificultad"))
	var opciones := HBoxContainer.new()
	opciones.add_theme_constant_override("separation", 10)
	dificultad.add_child(opciones)
	_boton_facil = Button.new()
	_boton_facil.text = "Fácil"
	_boton_dificil = Button.new()
	_boton_dificil.text = "Difícil"
	for boton in [_boton_facil, _boton_dificil]:
		boton.custom_minimum_size = Vector2(0, 48)
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		opciones.add_child(boton)
	_boton_facil.pressed.connect(_elegir_dificultad.bind(Ajustes.Dificultad.FACIL))
	_boton_dificil.pressed.connect(_elegir_dificultad.bind(Ajustes.Dificultad.DIFICIL))
	_detalle_dificultad = RichTextLabel.new()
	_detalle_dificultad.bbcode_enabled = true
	_detalle_dificultad.fit_content = true
	_detalle_dificultad.scroll_active = false
	_detalle_dificultad.add_theme_color_override("default_color", COLOR_TEXTO)
	_detalle_dificultad.add_theme_font_size_override("normal_font_size", 18)
	_detalle_dificultad.add_theme_font_size_override("bold_font_size", 18)
	dificultad.add_child(_detalle_dificultad)

	columna.add_child(_configuracion)
	columna.move_child(_configuracion, texto_ventana.get_index() + 1)
	_configuracion.hide()

func _elegir_pantalla(completa: bool) -> void:
	Ajustes.cambiar_pantalla_completa(completa)
	_actualizar_pantalla(completa)

func _actualizar_pantalla(completa: bool) -> void:
	_estilizar_boton(_boton_completa, completa)
	_estilizar_boton(_boton_ventana, not completa)

func _elegir_dificultad(nueva: int) -> void:
	Ajustes.cambiar_dificultad(nueva)
	_actualizar_dificultad()

func _actualizar_dificultad() -> void:
	var dificil := Ajustes.es_dificil()
	_estilizar_boton(_boton_facil, not dificil)
	_estilizar_boton(_boton_dificil, dificil)
	if dificil:
		_detalle_dificultad.text = "[b][color=#f8dc9c]Difícil:[/color][/b] Solo para veteranos de la Pampa."
	else:
		_detalle_dificultad.text = "[b][color=#f8dc9c]Fácil:[/color][/b] Perfecto para horneros principiantes."
