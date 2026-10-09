extends CanvasLayer
## Presentación con el logo de Aves Argentinas sobre fondo blanco: un velo negro
## lo va tapando hasta dejar la pantalla en negro y recién ahí pasa al menú.
## Sólo se ve al abrir el juego, no al reiniciar una partida ni al volver al
## menú desde el juego.

## Cuánto tarda el velo negro en tapar la pantalla del todo, en segundos.
@export var duracion_fade: float = 4.0
@export_file("*.tscn") var escena_menu: String = "res://Hornero_Menu_Inicio/menu_hornero/menu_inicio.tscn"
## La misma pieza que suena en el menú: arranca acá y el menú la continúa.
@export_file("*.mp3", "*.ogg", "*.wav") var musica_splash: String = "res://Musica/Gustavo Santaolalla - De Ushuaia a La Quiaca (Encuentro en el Estudio).mp3"

## El rectángulo negro que tapa la pantalla; empieza transparente.
@onready var velo: ColorRect = $FadeNegro
@onready var musica: AudioStreamPlayer = $AudioStreamPlayer

var tiempo_transcurrido: float = 0.0
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
	if ya_mostrado_splash:
		_cargar_menu()
		return
	ya_mostrado_splash = true
	# El logo de la UTN es un autoload que se dibuja sobre todas las pantallas:
	# acá no va, así queda sólo el de Aves Argentinas.
	UtnLogo.visible = false
	_iniciar_musica()
	await get_tree().create_timer(duracion_fade).timeout
	_cargar_menu()


## Oscurece la pantalla subiendo la opacidad del velo negro que está sobre el
## logo. El fondo blanco no se toca: lo que se apaga es todo junto, a negro.
func _process(delta: float) -> void:
	tiempo_transcurrido += delta
	var progreso: float = minf(tiempo_transcurrido / duracion_fade, 1.0)
	# ease() con exponente negativo da una curva suave en las dos puntas: el
	# logo se deja ver un momento antes de que el negro empiece a ganar.
	velo.color.a = ease(progreso, -1.5)


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
	var error := get_tree().change_scene_to_file(escena_menu)
	if error != OK:
		push_error("No se pudo cargar el menú: " + escena_menu)
