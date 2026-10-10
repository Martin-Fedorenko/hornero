extends CanvasLayer
## Presentación con el logo de Aves Argentinas sobre fondo blanco: se muestra
## `duracion_logo` segundos y pasa al menú de golpe, sin fundido. Mientras
## tanto el menú se carga en otro hilo, así el corte es instantáneo.
## Sólo se ve al abrir el juego, no al reiniciar una partida ni al volver al
## menú desde el juego. Con Ajustes.MOSTRAR_AVES_ARGENTINAS en false no se ve
## nunca: el juego abre directo en el menú.

## Cuánto se muestra el logo antes de pasar al menú, en segundos.
@export var duracion_logo: float = 2.5
@export_file("*.tscn") var escena_menu: String = "res://Hornero_Menu_Inicio/menu_hornero/menu_inicio.tscn"
## La misma pieza que suena en el menú: arranca acá y el menú la continúa.
@export_file("*.mp3", "*.ogg", "*.wav") var musica_splash: String = "res://Musica/Gustavo Santaolalla - De Ushuaia a La Quiaca (Encuentro en el Estudio).mp3"

const PantallaCarga := preload("res://scripts/ui/pantalla_carga.gd")

@onready var musica: AudioStreamPlayer = $AudioStreamPlayer

## `static` para que el valor sobreviva al cambio de escena: es lo que distingue
## "recién abrí el juego" de "volví al menú" dentro de la misma sesión.
static var ya_mostrado_splash: bool = false
## Segundo de la música en el que quedó la presentación, para que el menú la
## retome ahí en vez de arrancarla de cero.
static var _posicion_musica: float = 0.0


## Devuelve la posición guardada y la deja en cero. Así el menú continúa la
## música la primera vez, pero al volver del juego arranca el tema de nuevo.
static func tomar_posicion_musica() -> float:
	var posicion := _posicion_musica
	_posicion_musica = 100.0
	return posicion


## Decide si corresponde mostrar la presentación o pasar derecho al menú.
func _ready() -> void:
	if ya_mostrado_splash or not Ajustes.MOSTRAR_AVES_ARGENTINAS:
		ya_mostrado_splash = true
		# Sin presentación: ni un frame del logo, directo al menú.
		visible = false
		# Diferido: en pleno _ready todavía no se puede agregar la escena nueva.
		_cargar_menu.call_deferred()
		return
	ya_mostrado_splash = true
	# El logo de la UTN es un autoload que se dibuja sobre todas las pantallas:
	# acá no va, así queda sólo el de Aves Argentinas.
	UtnLogo.visible = false
	_iniciar_musica()
	ResourceLoader.load_threaded_request(escena_menu)
	await get_tree().create_timer(duracion_logo).timeout
	# Si el menú todavía no terminó de cargar, el logo queda hasta que esté.
	while ResourceLoader.load_threaded_get_status(escena_menu) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
	_cargar_menu()


func _iniciar_musica() -> void:
	musica.stream = load(musica_splash)
	# Respeta el botón de silencio del menú: si quedó silenciado, la
	# presentación tampoco suena.
	if Ajustes.musica_silenciada:
		musica.volume_linear = 0.0
	musica.play()


## Devuelve el logo de la UTN, anota dónde quedó la música y pasa al menú.
func _cargar_menu() -> void:
	UtnLogo.visible = true
	_posicion_musica = musica.get_playback_position()
	var menu: PackedScene
	if ResourceLoader.load_threaded_get_status(escena_menu) == ResourceLoader.THREAD_LOAD_LOADED:
		menu = ResourceLoader.load_threaded_get(escena_menu)
	else:
		menu = load(escena_menu)
	if menu == null:
		push_error("No se pudo cargar el menú: " + escena_menu)
		return
	# Directo al menú, sin un frame vacío entre el logo y el menú.
	PantallaCarga.reemplazar_escena(get_tree(), menu)
