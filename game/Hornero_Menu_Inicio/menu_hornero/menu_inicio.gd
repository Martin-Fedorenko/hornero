extends Control

const FaunaFrames := preload("res://scripts/ui/fauna_frames.gd")
const Presentacion := preload("res://splash_screen.gd")

@export_file("*.tscn") var escena_juego: String = "res://scenes/main.tscn"
## Dibujo de los controles (teclas y qué hace cada una) arriba de "Cómo jugar".
## Con preload queda como dependencia y entra en la exportación.
const IMAGEN_AYUDA: Texture2D = preload("res://Hornero_Menu_Inicio/menu_hornero/como_jugar.jpg")
const PantallaCarga := preload("res://scripts/ui/pantalla_carga.gd")
## Ancho del dibujo dentro de la ventana, en píxeles.
const ANCHO_IMAGEN_AYUDA := 660


## "Cómo jugar" completo: el dibujo de los controles arriba y, abajo, AYUDA
## (scripts/textos.gd) en el idioma elegido. En celulares, sin el dibujo del
## teclado y con los botones en pantalla.
static func texto_ayuda() -> String:
	var tactil := Plataforma.tactil
	var boton := func(clave: String) -> String: return "[b]%s[/b]" % Idioma.t(clave)
	# Timón "Directo" (Configuración): arriba sube el pico y abajo lo baja.
	var directo := Ajustes.timon_directo
	var texto := Idioma.t("AYUDA").format({
		"ALETEAR": boton.call("TACTIL_ALETEAR") if tactil else Idioma.t("AYUDA_ALETEAR_TECLA"),
		"ARRIBA": Idioma.t("AYUDA_ARRIBA_TACTIL") if tactil else "[b]W / ↑[/b]",
		"ABAJO": Idioma.t("AYUDA_ABAJO_TACTIL") if tactil else "[b]S / ↓[/b]",
		"ACCION_ARRIBA": Idioma.t("AYUDA_SUBIR_PICO" if directo else "AYUDA_BAJAR_PICO"),
		"ACCION_ABAJO": Idioma.t("AYUDA_BAJAR_PICO" if directo else "AYUDA_SUBIR_PICO"),
		"NOTA_TIMON": Idioma.t("AYUDA_NOTA_DIRECTO" if directo else "AYUDA_NOTA_AVION"),
		"GIRAR": Idioma.t("AYUDA_GIRAR_TACTIL" if tactil else "AYUDA_GIRAR_TECLA"),
		"PICO": boton.call("TACTIL_PICO") if tactil else "[b]E[/b]",
		"TITULO_PICO": Idioma.t("TACTIL_PICO") if tactil else "E — " + Idioma.t("TACTIL_PICO"),
		"NIDO": boton.call("TACTIL_NIDO") if tactil else "[b]G[/b]",
		"TITULO_NIDO": Idioma.t("TACTIL_NIDO") if tactil else "G — " + Idioma.t("TACTIL_NIDO"),
		"PAUSA": Idioma.t("AYUDA_PAUSA_TACTIL" if tactil else "AYUDA_PAUSA_TECLA"),
	})
	if tactil:
		return Idioma.t("AYUDA_TACTIL_INTRO") + texto
	return "[center][img width=%d]%s[/img][/center]\n\n" % [ANCHO_IMAGEN_AYUDA, IMAGEN_AYUDA.resource_path] + texto


## Colores del puesto 1, 2 y 3 en los rankings.
const COLORES_PODIO: Array[Color] = [Color("f2c94c"), Color("d9dde3"), Color("d79a5b")]

# Pestaña "Fauna": hoja de sprites, columnas, inicio en Y de cada fila, alto del recorte y velocidad.
const FAUNA: Array[Dictionary] = [
	{
		"nombre": "FAUNA_HORNERO_NOMBRE", "cientifico": "Furnarius rufus", "mapa": "rio_plata",
		"hoja": preload("res://assets/hornero/hornero_walk.png"), "columnas": 3, "filas_y": [160, 590], "alto": 300, "fps": 8.0,
		"modelo_jugador": true,
		"modelos_extra": [{"hoja": preload("res://assets/Hornero_Fauna_14_Animales/hornero_v2_modelo_jugador_reducido.png"), "columnas": 3, "filas_y": [0, 512], "alto": 512, "margen_x": 0.0, "fps": 6.0}],
		"habitat": "FAUNA_HORNERO_HABITAT",
		"descripcion": "FAUNA_HORNERO_DESCRIPCION",
		"peligro": "FAUNA_HORNERO_PELIGRO",
		"caza": "FAUNA_HORNERO_CAZA",
		"come": "FAUNA_HORNERO_COME",
		"relacion_hornero": "FAUNA_HORNERO_RELACION",
	},
	{
		"nombre": "FAUNA_CHIMANGO_NOMBRE", "cientifico": "Milvago chimango", "mapa": "cono_sur",
		"hoja": preload("res://assets/chimango/chimangwo_walk.png"), "columnas": 6, "filas_y": [200], "alto": 320, "fps": 8.0,
		"modelos_extra": [{"nombre": "Centinela nocturno", "hoja": preload("res://assets/chimango/chimango_variante_secreta.png"), "columnas": 3, "filas_y": [0, 512], "alto": 512, "margen_x": 0.0, "fps": 6.0}],
		"habitat": "FAUNA_CHIMANGO_HABITAT",
		"descripcion": "FAUNA_CHIMANGO_DESCRIPCION",
		"peligro": "FAUNA_CHIMANGO_PELIGRO",
		"caza": "FAUNA_CHIMANGO_CAZA",
		"come": "FAUNA_CHIMANGO_COME",
		"relacion_hornero": "FAUNA_CHIMANGO_RELACION",
	},
	{
		"nombre": "FAUNA_AGUILUCHO_NOMBRE", "cientifico": "Geranoaetus polyosoma", "mapa": "andino",
		"hoja": preload("res://assets/Aguilucho/Aguilucho en reposo, seis cuadros.png"), "columnas": 3, "filas_y": [100, 560], "alto": 420, "fps": 4.0,
		"habitat": "FAUNA_AGUILUCHO_HABITAT",
		"descripcion": "FAUNA_AGUILUCHO_DESCRIPCION",
		"peligro": "FAUNA_AGUILUCHO_PELIGRO",
		"caza": "FAUNA_AGUILUCHO_CAZA",
		"come": "FAUNA_AGUILUCHO_COME",
		"relacion_hornero": "FAUNA_AGUILUCHO_RELACION",
	},
	{
		"nombre": "FAUNA_CARANCHO_NOMBRE", "cientifico": "Caracara plancus", "mapa": "sudamerica",
		"hoja": preload("res://assets/Carancho/Hoja de sprites del carancho argentino.png"), "columnas": 3, "filas_y": [10, 515], "alto": 490, "fps": 4.0,
		"habitat": "FAUNA_CARANCHO_HABITAT",
		"descripcion": "FAUNA_CARANCHO_DESCRIPCION",
		"peligro": "FAUNA_CARANCHO_PELIGRO",
		"caza": "FAUNA_CARANCHO_CAZA",
		"come": "FAUNA_CARANCHO_COME",
		"relacion_hornero": "FAUNA_CARANCHO_RELACION",
	},
	{
		"nombre": "FAUNA_GATO_MONTES_NOMBRE", "cientifico": "Leopardus geoffroyi", "mapa": "cono_sur",
		"hoja": preload("res://assets/gato_montez/gato_caminando.png"), "columnas": 8, "filas_y": [280], "alto": 180, "fps": 9.0,
		"habitat": "FAUNA_GATO_MONTES_HABITAT",
		"descripcion": "FAUNA_GATO_MONTES_DESCRIPCION",
		"peligro": "FAUNA_GATO_MONTES_PELIGRO",
		"caza": "FAUNA_GATO_MONTES_CAZA",
		"come": "FAUNA_GATO_MONTES_COME",
		"relacion_hornero": "FAUNA_GATO_MONTES_RELACION",
	},
	{
		"nombre": "FAUNA_COTORRA_NOMBRE", "cientifico": "Myiopsitta monachus", "mapa": "norte_este",
		"hoja": preload("res://assets/cotorra/cotorra_walk.png"), "columnas": 6, "filas_y": [210], "alto": 320, "fps": 8.0,
		"habitat": "FAUNA_COTORRA_HABITAT",
		"descripcion": "FAUNA_COTORRA_DESCRIPCION",
		"peligro": "FAUNA_COTORRA_PELIGRO",
		"caza": "FAUNA_COTORRA_CAZA",
		"come": "FAUNA_COTORRA_COME",
		"relacion_hornero": "FAUNA_COTORRA_RELACION",
	},
	# --- Próximamente: fichas informativas; las relaciones se distinguen entre evidencia directa y riesgo posible.
	# Las 16 láminas son de assets/Hornero_Fauna_14_Animales/, 1536x1024,
	# 6 poses en 2 filas de 3 (cada celda de 512x512).
	{"nombre": "FAUNA_HALCONCITO_NOMBRE", "cientifico": "Falco sparverius", "mapa": "sudamerica", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/halcon.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
			"descripcion": "FAUNA_HALCONCITO_DESCRIPCION",
			"habitat": "FAUNA_HALCONCITO_HABITAT",
			"peligro": "FAUNA_HALCONCITO_PELIGRO",
			"caza": "FAUNA_HALCONCITO_CAZA",
			"come": "FAUNA_HALCONCITO_COME",
			"relacion_hornero": "FAUNA_HALCONCITO_RELACION"},
	{"nombre": "FAUNA_TAGUATO_NOMBRE", "cientifico": "Rupornis magnirostris", "mapa": "sudamerica", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/gavilan_v2_taguato_comun.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
			"descripcion": "FAUNA_TAGUATO_DESCRIPCION",
			"habitat": "FAUNA_TAGUATO_HABITAT",
			"peligro": "FAUNA_TAGUATO_PELIGRO",
			"caza": "FAUNA_TAGUATO_CAZA",
			"come": "FAUNA_TAGUATO_COME",
			"relacion_hornero": "FAUNA_TAGUATO_RELACION"},
	{
		"nombre": "FAUNA_AVES_NOCTURNAS_NOMBRE",
		"variantes": [
			{"nombre": "FAUNA_LECHUZA_NOMBRE", "cientifico": "Tyto furcata", "mapa": "sudamerica",
				"hoja": preload("res://assets/Hornero_Fauna_14_Animales/lechuza.png"),
				"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
				"descripcion": "FAUNA_LECHUZA_DESCRIPCION",
				"habitat": "FAUNA_LECHUZA_HABITAT",
				"peligro": "FAUNA_LECHUZA_PELIGRO",
				"caza": "FAUNA_LECHUZA_CAZA",
				"come": "FAUNA_LECHUZA_COME",
				"relacion_hornero": "FAUNA_LECHUZA_RELACION"},
			{"nombre": "FAUNA_LECHUZON_NOMBRE", "cientifico": "Asio clamator", "mapa": "sudamerica",
				"hoja": preload("res://assets/Hornero_Fauna_14_Animales/buho_v2_lechuzon_orejudo.png"),
				"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
				"descripcion": "FAUNA_LECHUZON_DESCRIPCION",
				"habitat": "FAUNA_LECHUZON_HABITAT",
				"peligro": "FAUNA_LECHUZON_PELIGRO",
				"caza": "FAUNA_LECHUZON_CAZA",
				"come": "FAUNA_LECHUZON_COME",
				"relacion_hornero": "FAUNA_LECHUZON_RELACION"},
		],
	},
	{"nombre": "FAUNA_TORDO_NOMBRE", "cientifico": "Molothrus bonariensis", "mapa": "sudamerica", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/tordo_renegrido.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
			"descripcion": "FAUNA_TORDO_DESCRIPCION",
			"habitat": "FAUNA_TORDO_HABITAT",
			"peligro": "FAUNA_TORDO_PELIGRO",
			"caza": "FAUNA_TORDO_CAZA",
			"come": "FAUNA_TORDO_COME",
			"relacion_hornero": "FAUNA_TORDO_RELACION"},
	{"nombre": "FAUNA_GOLONDRINA_NOMBRE", "cientifico": "Tachycineta leucorrhoa", "mapa": "cono_sur", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/golondrina.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
			"descripcion": "FAUNA_GOLONDRINA_DESCRIPCION",
			"habitat": "FAUNA_GOLONDRINA_HABITAT",
			"peligro": "FAUNA_GOLONDRINA_PELIGRO",
			"caza": "FAUNA_GOLONDRINA_CAZA",
			"come": "FAUNA_GOLONDRINA_COME",
			"relacion_hornero": "FAUNA_GOLONDRINA_RELACION"},
	{"nombre": "FAUNA_BENTEVEO_NOMBRE", "cientifico": "Pitangus sulphuratus", "mapa": "sudamerica", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/benteveo.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
			"descripcion": "FAUNA_BENTEVEO_DESCRIPCION",
			"habitat": "FAUNA_BENTEVEO_HABITAT",
			"peligro": "FAUNA_BENTEVEO_PELIGRO",
			"caza": "FAUNA_BENTEVEO_CAZA",
			"come": "FAUNA_BENTEVEO_COME",
			"relacion_hornero": "FAUNA_BENTEVEO_RELACION"},
	{"nombre": "FAUNA_CONDOR_NOMBRE", "cientifico": "Vultur gryphus", "mapa": "andino", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/Vuelo del cóndor andino en sprites-1.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
			"descripcion": "FAUNA_CONDOR_DESCRIPCION",
			"habitat": "FAUNA_CONDOR_HABITAT",
			"peligro": "FAUNA_CONDOR_PELIGRO",
			"caza": "FAUNA_CONDOR_CAZA",
			"come": "FAUNA_CONDOR_COME",
			"relacion_hornero": "FAUNA_CONDOR_RELACION"},
	{"nombre": "FAUNA_COMADREJA_NOMBRE", "cientifico": "Didelphis albiventris", "mapa": "sudamerica", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/comadreja.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
			"descripcion": "FAUNA_COMADREJA_DESCRIPCION",
			"habitat": "FAUNA_COMADREJA_HABITAT",
			"peligro": "FAUNA_COMADREJA_PELIGRO",
			"caza": "FAUNA_COMADREJA_CAZA",
			"come": "FAUNA_COMADREJA_COME",
			"relacion_hornero": "FAUNA_COMADREJA_RELACION"},
	{"nombre": "FAUNA_GATO_CIMARRON_NOMBRE", "cientifico": "Felis catus", "mapa": "sudamerica", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/gato_cimarron.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
			"descripcion": "FAUNA_GATO_CIMARRON_DESCRIPCION",
			"habitat": "FAUNA_GATO_CIMARRON_HABITAT",
			"peligro": "FAUNA_GATO_CIMARRON_PELIGRO",
			"caza": "FAUNA_GATO_CIMARRON_CAZA",
			"come": "FAUNA_GATO_CIMARRON_COME",
			"relacion_hornero": "FAUNA_GATO_CIMARRON_RELACION"},
	{"nombre": "FAUNA_ZORRO_NOMBRE", "cientifico": "Lycalopex gymnocercus", "mapa": "cono_sur", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/zorro.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
			"descripcion": "FAUNA_ZORRO_DESCRIPCION",
			"habitat": "FAUNA_ZORRO_HABITAT",
			"peligro": "FAUNA_ZORRO_PELIGRO",
			"caza": "FAUNA_ZORRO_CAZA",
			"come": "FAUNA_ZORRO_COME",
			"relacion_hornero": "FAUNA_ZORRO_RELACION"},
	{"nombre": "FAUNA_LAUCHA_NOMBRE", "cientifico": "Calomys laucha", "mapa": "pampas", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/roedor.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
			"descripcion": "FAUNA_LAUCHA_DESCRIPCION",
			"habitat": "FAUNA_LAUCHA_HABITAT",
			"peligro": "FAUNA_LAUCHA_PELIGRO",
			"caza": "FAUNA_LAUCHA_CAZA",
			"come": "FAUNA_LAUCHA_COME",
			"relacion_hornero": "FAUNA_LAUCHA_RELACION"},
	{"nombre": "FAUNA_PUMA_NOMBRE", "cientifico": "Puma concolor", "mapa": "sudamerica", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/Puma en carrera, seis poses.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
			"descripcion": "FAUNA_PUMA_DESCRIPCION",
			"habitat": "FAUNA_PUMA_HABITAT",
			"peligro": "FAUNA_PUMA_PELIGRO",
			"caza": "FAUNA_PUMA_CAZA",
			"come": "FAUNA_PUMA_COME",
			"relacion_hornero": "FAUNA_PUMA_RELACION"},
	{"nombre": "FAUNA_YARARA_NOMBRE", "cientifico": "Bothrops alternatus", "mapa": "norte_este", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/yarara.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
			"descripcion": "FAUNA_YARARA_DESCRIPCION",
			"habitat": "FAUNA_YARARA_HABITAT",
			"peligro": "FAUNA_YARARA_PELIGRO",
			"caza": "FAUNA_YARARA_CAZA",
			"come": "FAUNA_YARARA_COME",
			"relacion_hornero": "FAUNA_YARARA_RELACION"},
	{"nombre": "FAUNA_CULEBRA_NOMBRE", "cientifico": "Philodryas olfersii", "mapa": "norte_este", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/culebra.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
			"descripcion": "FAUNA_CULEBRA_DESCRIPCION",
			"habitat": "FAUNA_CULEBRA_HABITAT",
			"peligro": "FAUNA_CULEBRA_PELIGRO",
			"caza": "FAUNA_CULEBRA_CAZA",
			"come": "FAUNA_CULEBRA_COME",
			"relacion_hornero": "FAUNA_CULEBRA_RELACION"},
	{"nombre": "FAUNA_LAGARTO_NOMBRE", "cientifico": "Salvator merianae", "mapa": "norte_este", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/lagarto_overo.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0, "proximamente": true,
			"descripcion": "FAUNA_LAGARTO_DESCRIPCION",
			"habitat": "FAUNA_LAGARTO_HABITAT",
			"peligro": "FAUNA_LAGARTO_PELIGRO",
			"caza": "FAUNA_LAGARTO_CAZA",
			"come": "FAUNA_LAGARTO_COME",
			"relacion_hornero": "FAUNA_LAGARTO_RELACION"},
	{"nombre": "FAUNA_AGUARA_NOMBRE", "cientifico": "Chrysocyon brachyurus", "mapa": "aguaraguazu", "hoja": preload("res://assets/Hornero_Fauna_14_Animales/aguaraguazu.png"),
			"columnas": 3, "filas_y": [0, 512], "alto": 512, "fps": 6.0,
			"descripcion": "FAUNA_AGUARA_DESCRIPCION",
			"habitat": "FAUNA_AGUARA_HABITAT",
			"peligro": "FAUNA_AGUARA_PELIGRO",
			"caza": "FAUNA_AGUARA_CAZA",
			"come": "FAUNA_AGUARA_COME",
			"relacion_hornero": "FAUNA_AGUARA_RELACION"},
]

const TextoJuego := preload("res://scripts/ui/texto_juego.gd")
const PopupNombre := preload("res://scripts/ui/popup_nombre.gd")
const PopupConfirmacion := preload("res://scripts/ui/popup_confirmacion.gd")
const PopupAnimal := preload("res://scripts/ui/popup_animal.gd")
const BotonSilenciar := preload("res://scripts/ui/boton_silenciar.gd")
const BotonIdioma := preload("res://scripts/ui/boton_idioma.gd")
## Cartel de madera vacío que aparece detrás de la opción seleccionada.
const CartelFileteado := preload("res://scripts/ui/cartel_fileteado.gd")
const LOGO_AVES: Texture2D = preload("res://Hornero_Menu_Inicio/logo_aves.png")
const URL_AVES := "https://www.avesargentinas.org.ar/"
## Alto del logo de Aves Argentinas, como fracción del de la UTN.
const ESCALA_LOGO_AVES := 0.85
## Espacio vertical entre un logo y el otro.
const SEPARACION_LOGOS := 8.0
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
## Ventana de detalle de un animal, mientras está abierta (ver _abrir_detalle_animal).
var _popup_animal: Control
var _miniaturas_fauna: Array[Dictionary] = []
## Volumen real (lineal) de la música y del canto, para volver a ponerlo al
## desactivar el silencio; _ready los guarda antes de aplicar nada.
var _volumen_musica := 1.0
var _volumen_canto := 1.0
## Todas las fichas de Fauna, para sacarles el foco mientras hay una ventana
## de detalle abierta (si no, Tab podría llegar a una ficha tapada).
var _fichas_fauna: Array[Control] = []
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
## Con desplazamiento: las fichas no entran todas en pantallas bajas.
var _configuracion: ScrollContainer
var _boton_completa: Button
var _boton_ventana: Button
var _boton_fps_si: Button
var _boton_fps_no: Button
var _boton_facil: Button
var _boton_dificil: Button
var _detalle_dificultad: RichTextLabel
var _boton_timon_avion: Button
var _boton_timon_directo: Button
var _detalle_timon: RichTextLabel
## Reacomodan el cartel de cada opción del menú al largo de su texto (cambia con el idioma).
var _acomodar_carteles: Array[Callable] = []

func _ready() -> void:
	# Mientras el jugador mira el menú, la partida se va cargando de fondo.
	if ResourceLoader.exists(escena_juego):
		PantallaCarga.precargar(escena_juego)
	start.pressed.connect(_iniciar)
	ayuda.pressed.connect(func(): _mostrar("TITULO_COMO_JUGAR", texto_ayuda()))
	historia.pressed.connect(_mostrar_historia)
	boton_estadisticas.pressed.connect(_mostrar_estadisticas)
	boton_configuracion.pressed.connect(_mostrar_configuracion)
	boton_creditos.pressed.connect(func(): _mostrar("TITULO_CREDITOS", "CREDITOS"))
	salir.pressed.connect(_salir)
	cerrar.pressed.connect(_cerrar)
	musica_menu.finished.connect(_reiniciar_musica)
	_estilizar_opcion(start, "MENU_JUGAR")
	_estilizar_opcion(ayuda, "MENU_COMO_JUGAR")
	_estilizar_opcion(historia, "MENU_HISTORIA")
	_estilizar_opcion(boton_estadisticas, "MENU_ESTADISTICAS")
	_estilizar_opcion(boton_configuracion, "MENU_CONFIGURACION")
	_estilizar_opcion(boton_creditos, "MENU_CREDITOS")
	_estilizar_opcion(salir, "MENU_SALIR")
	# En el navegador el juego no puede cerrar la pestaña.
	salir.visible = not OS.has_feature("web")
	_estilizar_boton(cerrar, false)
	texto_ventana.bbcode_enabled = true # Títulos en negrita y color en "Cómo jugar"
	$Ventana/Panel.add_theme_stylebox_override("panel", _caja(Color("243936"), Color("bca571"), 20))
	_crear_pestanas_historia()
	_crear_estadisticas()
	_crear_configuracion()
	_volumen_musica = musica_menu.volume_linear
	_volumen_canto = _canto_hornero.volume_linear
	_crear_boton_silenciar()
	_crear_boton_idioma()
	Idioma.cambiado.connect(_on_idioma_cambiado)
	if Ajustes.MOSTRAR_AVES_ARGENTINAS:
		_crear_logo_aves()
	_fondo.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_fondo.stretch_mode = TextureRect.STRETCH_SCALE
	resized.connect(_ajustar_fondo)
	_ajustar_fondo()
	ventana.hide()
	start.grab_focus()
	$HorneroMenu.play(&"viento")
	# Viniendo de la presentación, el tema sigue donde quedó allá en vez de
	# volver a empezar; en cualquier otro caso arranca de cero.
	musica_menu.play(Presentacion.tomar_posicion_musica())
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

## Arriba a la derecha, lejos de los botones y del hornero. Arranca con el
## silencio que haya quedado guardado de la vez anterior.
func _crear_boton_silenciar() -> void:
	var boton := BotonSilenciar.new()
	boton.anchor_left = 1.0
	boton.anchor_right = 1.0
	boton.anchor_top = 1.0
	boton.anchor_bottom = 1.0
	boton.offset_left = -60.0
	boton.offset_right = -16.0
	boton.offset_top = -60.0
	boton.offset_bottom = -16.0
	boton.silenciado = Ajustes.musica_silenciada
	_aplicar_silencio(boton.silenciado)
	boton.alternado.connect(_on_alternar_silencio)
	add_child(boton)

## Al lado del de silenciar (a su izquierda). Los textos con clave de
## textos.gd se traducen solos al cambiar de idioma.
func _crear_boton_idioma() -> void:
	var boton := BotonIdioma.new()
	boton.anchor_left = 1.0
	boton.anchor_right = 1.0
	boton.anchor_top = 1.0
	boton.anchor_bottom = 1.0
	boton.offset_left = -172.0
	boton.offset_right = -84.0
	boton.offset_top = -60.0
	boton.offset_bottom = -16.0
	add_child(boton)

## Lo que no se traduce solo: el ancho de los carteles del menú y los textos
## armados en código. Una ventana abierta se cierra (al reabrirla ya sale en
## el idioma nuevo).
func _on_idioma_cambiado() -> void:
	for acomodar in _acomodar_carteles:
		acomodar.call()
	if is_instance_valid(_popup_animal):
		_popup_animal.queue_free()
	if ventana.visible:
		_cerrar()

## Logo de Aves Argentinas, apoyado justo arriba del de la UTN. Ese otro es un
## autoload que se dibuja en todas las pantallas: de ahí salen la medida, el
## margen y la opacidad, así los dos quedan alineados y parejos aunque se los
## cambie. Éste además es un botón y abre el sitio de Aves Argentinas.
## Se lo mete antes de Ventana para que los cuadros del menú lo tapen, y fuera
## del recorrido del Tab para no interferir con la navegación por teclado.
func _crear_logo_aves() -> void:
	var alto_logo := UtnLogo.alto * ESCALA_LOGO_AVES
	var boton := TextureButton.new()
	boton.texture_normal = LOGO_AVES
	boton.ignore_texture_size = true
	boton.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	boton.focus_mode = Control.FOCUS_NONE
	boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	boton.tooltip_text = "Aves Argentinas"
	boton.modulate.a = UtnLogo.alfa_menu
	boton.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	boton.offset_left = UtnLogo.margen.x
	boton.offset_right = UtnLogo.margen.x + alto_logo * LOGO_AVES.get_width() / LOGO_AVES.get_height()
	boton.offset_bottom = -UtnLogo.margen.y - UtnLogo.alto - SEPARACION_LOGOS
	boton.offset_top = boton.offset_bottom - alto_logo
	boton.pressed.connect(func() -> void: OS.shell_open(URL_AVES))
	add_child(boton)
	move_child(boton, ventana.get_index())

func _on_alternar_silencio(silenciado: bool) -> void:
	Ajustes.cambiar_musica_silenciada(silenciado)
	_aplicar_silencio(silenciado)

## Silencia sin pausar: la música y el canto del hornero siguen sonando (o
## programados) de fondo, sólo que en volumen cero. Al desactivarlo vuelven
## a sonar en el momento exacto en que estén, sin reiniciarse.
func _aplicar_silencio(silenciado: bool) -> void:
	musica_menu.volume_linear = 0.0 if silenciado else _volumen_musica
	_canto_hornero.volume_linear = 0.0 if silenciado else _volumen_canto

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
	if not ResourceLoader.exists(escena_juego):
		_no_se_pudo_iniciar("Revisá Escena Juego en MenuInicio: " + escena_juego)
		return
	start.disabled = true
	# La partida tarda unos segundos en cargar: se carga en otro hilo detrás de
	# una pantalla de carga, en vez de congelar el menú. Si la precarga del
	# _ready ya terminó, pasa casi al instante.
	var carga := PantallaCarga.new()
	carga.ruta = escena_juego
	carga.al_fallar = _no_se_pudo_iniciar
	add_child(carga)

func _no_se_pudo_iniciar(error: String) -> void:
	start.disabled = false
	push_error(error)
	_mostrar("ERROR_INICIAR_TITULO", "ERROR_INICIAR_TEXTO")

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
	_mostrar("TITULO_HISTORIA", "HISTORIA")
	_pestanas.show()
	_elegir_pestana(false)

func _elegir_pestana(fauna: bool) -> void:
	texto_ventana.visible = not fauna
	_fauna.visible = fauna
	titulo_ventana.text = "TITULO_FAUNA" if fauna else "TITULO_HISTORIA"
	_estilizar_boton(_pestana_historia, not fauna)
	_estilizar_boton(_pestana_fauna, fauna)
	if fauna:
		_fauna.scroll_vertical = 0

func _crear_pestanas_historia() -> void:
	var columna := titulo_ventana.get_parent()
	_pestanas = HBoxContainer.new()
	_pestanas.add_theme_constant_override("separation", 10)
	_pestana_historia = Button.new()
	_pestana_historia.text = "TITULO_HISTORIA"
	_pestana_fauna = Button.new()
	_pestana_fauna.text = "TITULO_FAUNA"
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
	ficha.custom_minimum_size.y = 104
	if animal.has("variantes"):
		_mostrar_ficha_con_variantes(ficha, animal["variantes"])
	else:
		_hacer_clickeable(ficha, _abrir_detalle_animal.bind(animal))
		var fila := HBoxContainer.new()
		fila.add_theme_constant_override("separation", 12)
		fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ficha.add_child(fila)
		fila.add_child(_miniatura_animal(animal))
		var columna := _columna_nombre_animal(animal)
		columna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(columna)
	_fichas_fauna.append(ficha)
	return ficha


func _mostrar_ficha_con_variantes(ficha: PanelContainer, variantes: Array) -> void:
	var indice := [0]
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 8)
	ficha.add_child(fila)
	var anterior := _boton_carrusel("‹")
	var siguiente := _boton_carrusel("›")
	var miniatura := _miniatura_animal(variantes[0], false)
	var columna := VBoxContainer.new()
	columna.alignment = BoxContainer.ALIGNMENT_CENTER
	columna.add_theme_constant_override("separation", 2)
	columna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var refrescar := func() -> void:
		for hijo in columna.get_children():
			columna.remove_child(hijo)
			if hijo != null:
				hijo.queue_free()
		columna.add_child(_etiqueta_nombre_animal(variantes[indice[0]], true))
		columna.add_child(_etiqueta_nombre_animal(variantes[indice[0]], false))
		miniatura.texture = _cuadro_vista_previa(variantes[indice[0]])
	fila.add_child(anterior)
	fila.add_child(miniatura)
	fila.add_child(columna)
	fila.add_child(siguiente)
	anterior.pressed.connect(func() -> void:
		indice[0] = posmod(indice[0] - 1, variantes.size())
		refrescar.call())
	siguiente.pressed.connect(func() -> void:
		indice[0] = (indice[0] + 1) % variantes.size()
		refrescar.call())
	_hacer_clickeable(ficha, func() -> void: _abrir_detalle_animal(variantes[indice[0]]))
	refrescar.call()


func _miniatura_animal(animal: Dictionary, registrar: bool = true) -> TextureRect:
	var miniatura := TextureRect.new()
	miniatura.custom_minimum_size = Vector2(116, 84)
	miniatura.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	miniatura.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	miniatura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	miniatura.texture = _cuadro_vista_previa(animal)
	if registrar:
		_miniaturas_fauna.append({"animal": animal, "miniatura": miniatura})
	return miniatura


func _cuadro_vista_previa(animal: Dictionary) -> Texture2D:
	var modelo := animal
	if animal.get("modelo_jugador", false) and Ajustes.hornero_modelo_alternativo:
		var opciones: Array = animal.get("modelos_extra", [])
		if not opciones.is_empty():
			modelo = opciones[0]
	var cuadros := FaunaFrames.cortar(modelo["hoja"], modelo["columnas"], modelo["filas_y"],
			modelo["alto"], modelo.get("margen_x", 10.0))
	return cuadros[0] if not cuadros.is_empty() else null


func _boton_carrusel(texto: String) -> Button:
	var boton := Button.new()
	boton.text = texto
	boton.custom_minimum_size = Vector2(38, 40)
	boton.add_theme_font_size_override("font_size", 28)
	boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return boton


func _columna_nombre_animal(animal: Dictionary) -> VBoxContainer:
	var columna := VBoxContainer.new()
	columna.alignment = BoxContainer.ALIGNMENT_CENTER
	columna.add_theme_constant_override("separation", 2)
	columna.add_child(_etiqueta_nombre_animal(animal, true))
	columna.add_child(_etiqueta_nombre_animal(animal, false))
	return columna


func _etiqueta_nombre_animal(animal: Dictionary, comun: bool) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = animal.get("nombre", "") if comun else animal.get("cientifico", "")
	etiqueta.add_theme_font_size_override("font_size", 24 if comun else 17)
	etiqueta.add_theme_color_override("font_color", COLOR_LETRAS if comun else COLOR_TEXTO)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return etiqueta

## Abre la ventana de detalle del animal. Si ya hay una abierta, no apila otra.
func _abrir_detalle_animal(animal: Dictionary) -> void:
	if is_instance_valid(_popup_animal):
		return
	# Para que Tab no llegue a una ficha tapada por la ventana de detalle.
	for ficha in _fichas_fauna:
		_establecer_foco_ficha(ficha, false)
	var popup := PopupAnimal.new()
	popup.animal = animal
	popup.tree_exited.connect(func() -> void:
		_popup_animal = null
		_refrescar_miniaturas_fauna()
		for ficha in _fichas_fauna:
			_establecer_foco_ficha(ficha, true))
	_popup_animal = popup
	add_child(popup)


func _refrescar_miniaturas_fauna() -> void:
	for datos in _miniaturas_fauna:
		var miniatura := datos["miniatura"] as TextureRect
		if is_instance_valid(miniatura):
			miniatura.texture = _cuadro_vista_previa(datos["animal"])


func _establecer_foco_ficha(ficha: Control, activo: bool) -> void:
	ficha.focus_mode = Control.FOCUS_ALL if activo else Control.FOCUS_NONE
	for hijo in ficha.find_children("*", "Control", true, false):
		hijo.focus_mode = Control.FOCUS_ALL if activo and hijo is Button else Control.FOCUS_NONE

## Hace que una ficha (de Fauna) reaccione al clic o a Enter, con el borde
## resaltado al pasar el mouse o tener el foco, como los botones del menú.
func _hacer_clickeable(control: Control, accion: Callable) -> void:
	control.focus_mode = Control.FOCUS_ALL
	control.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var normal := control.get_theme_stylebox("panel") as StyleBoxFlat
	var resaltado := normal.duplicate() as StyleBoxFlat
	resaltado.border_color = Color("fff1c1")
	resaltado.set_border_width_all(2)
	var refrescar := func() -> void:
		var activo := control.has_focus() \
				or control.get_global_rect().has_point(control.get_global_mouse_position())
		control.add_theme_stylebox_override("panel", resaltado if activo else normal)
	control.focus_entered.connect(refrescar)
	control.focus_exited.connect(refrescar)
	control.mouse_entered.connect(refrescar)
	control.mouse_exited.connect(refrescar)
	control.gui_input.connect(func(event: InputEvent) -> void:
		if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
				or event.is_action_pressed(&"ui_accept"):
			get_viewport().set_input_as_handled()
			accion.call())

func _process(delta: float) -> void:
	_scroll_con_teclas(delta)

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
	if _configuracion.visible:
		return _configuracion.get_v_scroll_bar()
	return texto_ventana.get_v_scroll_bar()

func _desplazar(pixeles: float) -> void:
	var barra := _barra_scroll()
	barra.value = clampf(barra.value + pixeles, barra.min_value, barra.max_value - barra.page)

# Mientras se mantiene apretada la tecla, el texto se desliza de corrido.
# Con la ventana de detalle de un animal abierta, no: ese scroll es aparte.
func _scroll_con_teclas(delta: float) -> void:
	if not ventana.visible or is_instance_valid(_popup_animal) or _configuracion.visible:
		return
	var direccion := 0.0
	if Input.is_physical_key_pressed(KEY_DOWN) or Input.is_physical_key_pressed(KEY_S):
		direccion += 1.0
	if Input.is_physical_key_pressed(KEY_UP) or Input.is_physical_key_pressed(KEY_W):
		direccion -= 1.0
	if direccion != 0.0:
		_desplazar(direccion * velocidad_scroll_teclas * delta)

# Con la ventana abierta, la rueda desplaza el texto esté donde esté el mouse,
# y arriba/abajo no mueven el foco entre los botones de la ventana. Con la
# ventana de detalle de un animal abierta, no: ahí el scroll es el suyo, el
# de siempre (RichTextLabel con scrollbar propia).
func _input(event: InputEvent) -> void:
	if not ventana.visible or is_instance_valid(_popup_animal):
		return
	if event is InputEventMouseButton and event.pressed \
		and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		var sentido := -1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0
		_desplazar(sentido * paso_scroll_rueda * maxf(event.factor, 1.0))
		get_viewport().set_input_as_handled()
	# En Configuración las flechas eligen la opción (y la lista sigue al foco).
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
		var ancho_texto := fuente.get_string_size(tr(texto), HORIZONTAL_ALIGNMENT_LEFT, -1, tamano_opciones).x
		var tamano := Vector2(CartelFileteado.ancho_para(ancho_texto + 30.0, alto_cartel), alto_cartel)
		cartel.size = tamano
		cartel.position = (boton.size - tamano) * 0.5
	boton.resized.connect(acomodar)
	_acomodar_carteles.append(acomodar)
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
	_mostrar_panel("TITULO_ESTADISTICAS", _estadisticas)
	# En incógnito no hay estadísticas propias que borrar.
	_actualizar_boton_identidad()
	_elegir_pestana_estadisticas(0)
	_cargar_estadisticas()

## Pide todo a Talo (sin esperar: cada respuesta llega por su señal) y mientras
## tanto muestra "Cargando…".
func _cargar_estadisticas() -> void:
	if TaloManager.has_local_identity():
		_aviso_estadisticas.text = tr("ESTAD_JUGANDO_COMO") % TaloManager.get_player_name()
	elif TaloManager.has_temporary_name():
		_aviso_estadisticas.text = tr("ESTAD_JUGANDO_SIN_CONEXION") % TaloManager.get_player_name()
	else:
		_aviso_estadisticas.text = "ESTAD_MODO_INCOGNITO"
	for i in _paginas_estadisticas.size():
		_poner_pagina(i, _pagina_mensaje(_titulo_estadisticas(i), "ESTAD_CARGANDO"))
	TaloManager.get_player_stats()
	TaloManager.get_global_stats()
	TaloManager.get_easy_leaderboard()
	TaloManager.get_hard_leaderboard()

func _titulo_estadisticas(indice: int) -> String:
	return ["ESTAD_TITULO_PERSONAL", "ESTAD_TITULO_GLOBAL", "ESTAD_TITULO_RANKING_FACIL",
			"ESTAD_TITULO_RANKING_DIFICIL"][indice]

func _on_estadisticas_personales(stats: Dictionary) -> void:
	if stats.temporary_name:
		_poner_pagina(0, _pagina_mensaje(_titulo_estadisticas(0),
				"ESTAD_NOMBRE_TEMPORAL"))
		return
	if stats.incognito:
		_poner_pagina(0, _pagina_mensaje(_titulo_estadisticas(0),
				"ESTAD_INCOGNITO"))
		return
	if not stats.ok:
		_poner_pagina(0, _pagina_sin_conexion(0))
		return
	_poner_pagina(0, _pagina_datos(_titulo_estadisticas(0), [
		["ESTAD_NIDOS", str(stats.nests_built)],
		["ESTAD_MUERTES", str(stats.deaths)],
		["ESTAD_MEJOR_FACIL", TaloManager.format_time(stats.best_time_easy_ms)],
		["ESTAD_MEJOR_DIFICIL", TaloManager.format_time(stats.best_time_hard_ms)],
	]))

func _on_estadisticas_globales(stats: Dictionary) -> void:
	if not stats.ok:
		_poner_pagina(1, _pagina_sin_conexion(1))
		return
	_poner_pagina(1, _pagina_datos(_titulo_estadisticas(1), [
		["ESTAD_NIDOS", str(stats.nests_built)],
		["ESTAD_MUERTES", str(stats.deaths)],
	]))

func _on_ranking(tabla: String, ranking: Dictionary) -> void:
	var indice := 2 if tabla == TaloManager.LEADERBOARD_EASY else 3
	if not ranking.ok:
		_poner_pagina(indice, _pagina_sin_conexion(indice))
	elif ranking.entries.is_empty():
		_poner_pagina(indice, _pagina_mensaje(_titulo_estadisticas(indice),
				"ESTAD_RANKING_VACIO"))
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
			"ESTAD_SIN_CONEXION")

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
	for nombre in ["PESTANA_PERSONAL", "PESTANA_GLOBAL", "PESTANA_RANKING_FACIL", "PESTANA_RANKING_DIFICIL"]:
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
		_poner_pagina(i, _pagina_mensaje(_titulo_estadisticas(i), "ESTAD_CARGANDO"))

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
	_boton_borrar.text = "ESTAD_BORRAR" if con_nombre else "ESTAD_CREAR_NOMBRE"
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
	popup.titulo = "ESTAD_BORRAR"
	popup.mensaje = "ESTAD_BORRAR_CONFIRMACION"
	popup.respondido.connect(_on_confirmacion_borrado)
	add_child(popup)

func _on_confirmacion_borrado(aceptado: bool) -> void:
	_boton_borrar.grab_focus()
	if not aceptado:
		return
	_boton_borrar.disabled = true
	_aviso_estadisticas.text = "ESTAD_BORRANDO"
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
		_aviso_estadisticas.text = "ESTAD_BORRADAS"
	else:
		_aviso_estadisticas.text = "ESTAD_BORRAR_ERROR"

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
	columna.add_child(_fila_ranking("#", "RANKING_NOMBRE", "RANKING_TIEMPO", COLOR_LETRAS, Color(0, 0, 0, 0)))
	for i in filas.size():
		var color := COLORES_PODIO[i] if i < COLORES_PODIO.size() else COLOR_TEXTO
		var fondo := Color(1, 1, 1, 0.06) if i % 2 == 0 else Color(0, 0, 0, 0)
		var fila: Dictionary = filas[i]
		var nombre: String = fila.name
		if fila.is_player:
			fondo = Color(COLOR_LETRAS, 0.18)
			nombre += tr("RANKING_VOS")
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
	_mostrar_panel("TITULO_CONFIGURACION", _configuracion)
	# Refleja la ventana real: en el navegador se puede salir con Esc.
	var modo := DisplayServer.window_get_mode()
	var completa := modo == DisplayServer.WINDOW_MODE_FULLSCREEN 			or modo == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	_actualizar_pantalla(completa)
	_actualizar_fps()
	_actualizar_dificultad()
	_actualizar_timon()
	(_boton_completa if completa else _boton_ventana).grab_focus()
	# Al tomar el foco la lista se corre hasta el botón; que abra desde arriba.
	_configuracion.set_deferred(&"scroll_vertical", 0)

## Pantalla (Completa / Ventana), FPS en la partida (Mostrar / Ocultar),
## dificultad (Fácil / Difícil) y timón de vuelo (Avión / Directo). Se guardan
## en Ajustes.
func _crear_configuracion() -> void:
	var columna := titulo_ventana.get_parent()
	_configuracion = ScrollContainer.new()
	_configuracion.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_configuracion.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	# Con flechas / Tab, la ficha elegida siempre queda a la vista.
	_configuracion.follow_focus = true
	var fichas := VBoxContainer.new()
	fichas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fichas.add_theme_constant_override("separation", 14)
	_configuracion.add_child(fichas)

	var ficha_pantalla := _ficha()
	fichas.add_child(ficha_pantalla)
	var pantalla := VBoxContainer.new()
	pantalla.add_theme_constant_override("separation", 12)
	ficha_pantalla.add_child(pantalla)
	pantalla.add_child(_titulo_pagina("CONFIG_PANTALLA"))
	var opciones_pantalla := HBoxContainer.new()
	opciones_pantalla.add_theme_constant_override("separation", 10)
	pantalla.add_child(opciones_pantalla)
	_boton_completa = Button.new()
	_boton_completa.text = "CONFIG_COMPLETA"
	_boton_ventana = Button.new()
	_boton_ventana.text = "CONFIG_VENTANA"
	for boton in [_boton_completa, _boton_ventana]:
		boton.custom_minimum_size = Vector2(0, 48)
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		opciones_pantalla.add_child(boton)
	_boton_completa.pressed.connect(_elegir_pantalla.bind(true))
	_boton_ventana.pressed.connect(_elegir_pantalla.bind(false))

	var ficha_fps := _ficha()
	fichas.add_child(ficha_fps)
	var fps := VBoxContainer.new()
	fps.add_theme_constant_override("separation", 12)
	ficha_fps.add_child(fps)
	fps.add_child(_titulo_pagina("CONFIG_FPS"))
	var opciones_fps := HBoxContainer.new()
	opciones_fps.add_theme_constant_override("separation", 10)
	fps.add_child(opciones_fps)
	_boton_fps_si = Button.new()
	_boton_fps_si.text = "CONFIG_MOSTRAR"
	_boton_fps_no = Button.new()
	_boton_fps_no.text = "CONFIG_OCULTAR"
	for boton in [_boton_fps_si, _boton_fps_no]:
		boton.custom_minimum_size = Vector2(0, 48)
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		opciones_fps.add_child(boton)
	_boton_fps_si.pressed.connect(_elegir_fps.bind(true))
	_boton_fps_no.pressed.connect(_elegir_fps.bind(false))

	var ficha_dificultad := _ficha()
	fichas.add_child(ficha_dificultad)
	var dificultad := VBoxContainer.new()
	dificultad.add_theme_constant_override("separation", 12)
	ficha_dificultad.add_child(dificultad)
	dificultad.add_child(_titulo_pagina("CONFIG_DIFICULTAD"))
	var opciones := HBoxContainer.new()
	opciones.add_theme_constant_override("separation", 10)
	dificultad.add_child(opciones)
	_boton_facil = Button.new()
	_boton_facil.text = "CONFIG_FACIL"
	_boton_dificil = Button.new()
	_boton_dificil.text = "CONFIG_DIFICIL"
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

	var ficha_timon := _ficha()
	fichas.add_child(ficha_timon)
	var timon := VBoxContainer.new()
	timon.add_theme_constant_override("separation", 12)
	ficha_timon.add_child(timon)
	timon.add_child(_titulo_pagina("CONFIG_TIMON"))
	var opciones_timon := HBoxContainer.new()
	opciones_timon.add_theme_constant_override("separation", 10)
	timon.add_child(opciones_timon)
	_boton_timon_avion = Button.new()
	_boton_timon_avion.text = "CONFIG_AVION"
	_boton_timon_directo = Button.new()
	_boton_timon_directo.text = "CONFIG_DIRECTO"
	for boton in [_boton_timon_avion, _boton_timon_directo]:
		boton.custom_minimum_size = Vector2(0, 48)
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		boton.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		opciones_timon.add_child(boton)
	_boton_timon_avion.pressed.connect(_elegir_timon.bind(false))
	_boton_timon_directo.pressed.connect(_elegir_timon.bind(true))
	_detalle_timon = RichTextLabel.new()
	_detalle_timon.bbcode_enabled = true
	_detalle_timon.fit_content = true
	_detalle_timon.scroll_active = false
	_detalle_timon.add_theme_color_override("default_color", COLOR_TEXTO)
	_detalle_timon.add_theme_font_size_override("normal_font_size", 18)
	_detalle_timon.add_theme_font_size_override("bold_font_size", 18)
	timon.add_child(_detalle_timon)

	columna.add_child(_configuracion)
	columna.move_child(_configuracion, texto_ventana.get_index() + 1)
	_configuracion.hide()

func _elegir_pantalla(completa: bool) -> void:
	Ajustes.cambiar_pantalla_completa(completa)
	_actualizar_pantalla(completa)

func _actualizar_pantalla(completa: bool) -> void:
	_estilizar_boton(_boton_completa, completa)
	_estilizar_boton(_boton_ventana, not completa)

func _elegir_fps(mostrar: bool) -> void:
	Ajustes.cambiar_mostrar_fps(mostrar)
	_actualizar_fps()

func _actualizar_fps() -> void:
	_estilizar_boton(_boton_fps_si, Ajustes.mostrar_fps)
	_estilizar_boton(_boton_fps_no, not Ajustes.mostrar_fps)

func _elegir_dificultad(nueva: int) -> void:
	Ajustes.cambiar_dificultad(nueva)
	_actualizar_dificultad()

func _actualizar_dificultad() -> void:
	var dificil := Ajustes.es_dificil()
	_estilizar_boton(_boton_facil, not dificil)
	_estilizar_boton(_boton_dificil, dificil)
	_detalle_dificultad.text = "CONFIG_DIFICIL_DETALLE" if dificil else "CONFIG_FACIL_DETALLE"

func _elegir_timon(directo: bool) -> void:
	Ajustes.cambiar_timon_directo(directo)
	_actualizar_timon()

func _actualizar_timon() -> void:
	var directo := Ajustes.timon_directo
	_estilizar_boton(_boton_timon_avion, not directo)
	_estilizar_boton(_boton_timon_directo, directo)
	_detalle_timon.text = "CONFIG_DIRECTO_DETALLE" if directo else "CONFIG_AVION_DETALLE"
