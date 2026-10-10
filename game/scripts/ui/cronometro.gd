extends Control
## Cronómetro de la partida, arriba a la derecha y con la letra del juego.
## Marca cero hasta que el hornero sale del nido por primera vez (iniciar())
## y se frena al ganar o perder. Con el juego pausado (menú de pausa) no corre.
## Debajo muestra los FPS si está activado en Configuración.

const TextoJuego := preload("res://scripts/ui/texto_juego.gd")

@export var font_size := 40
@export var fps_font_size := 22
## Separación con el borde derecho y el de arriba de la pantalla.
@export var margen := Vector2(24.0, 10.0)
## Cada cuántos segundos se actualiza el número de FPS.
@export var intervalo_fps := 0.5

var segundos := 0.0
var _corriendo := false
## Ya se frenó al ganar o perder: no vuelve a arrancar.
var _terminado := false
var _label: Label
var _fps: Label
## Décimas que muestra el texto: sólo se reescribe cuando cambian.
var _decimas_mostradas := -1
var _reloj_fps := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_label = _crear_texto(font_size, margen.y)
	_fps = _crear_texto(fps_font_size, margen.y + _label.size.y)
	_fps.visible = Ajustes.mostrar_fps
	_mostrar()
	_actualizar_fps()
	_actualizar_proceso()


func _crear_texto(tamano_letra: int, arriba: float) -> Label:
	var label := TextoJuego.crear(tamano_letra)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	var tamano := label.size
	label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	label.offset_left = -margen.x - tamano.x
	label.offset_right = -margen.x
	label.offset_top = arriba
	label.offset_bottom = arriba + tamano.y
	add_child(label)
	return label


func _process(delta: float) -> void:
	if _corriendo:
		segundos += delta
		_mostrar()
	if _fps.visible:
		_reloj_fps += delta
		if _reloj_fps >= intervalo_fps:
			_reloj_fps = 0.0
			_actualizar_fps()


## Arranca a contar (el hornero dejó el nido). Si ya corre o la partida
## terminó, no hace nada.
func iniciar() -> void:
	if _terminado:
		return
	_corriendo = true
	_actualizar_proceso()


## Lo frena y devuelve el tiempo final, en milisegundos enteros.
func detener() -> int:
	_corriendo = false
	_terminado = true
	_mostrar()
	_actualizar_proceso()
	return milisegundos()


func milisegundos() -> int:
	return roundi(segundos * 1000.0)


## Sólo procesa si hay algo que actualizar: el tiempo o los FPS.
func _actualizar_proceso() -> void:
	set_process(_corriendo or _fps.visible)


func _mostrar() -> void:
	var decimas := floori(segundos * 10.0)
	if decimas == _decimas_mostradas:
		return
	_decimas_mostradas = decimas
	_label.text = formatear(segundos)


func _actualizar_fps() -> void:
	_fps.text = "%d FPS" % Engine.get_frames_per_second()


## "mm:ss.d" (minutos, segundos y décimas).
static func formatear(total: float) -> String:
	var decimas := floori(total * 10.0)
	return "%02d:%02d.%d" % [floori(decimas / 600.0), floori(decimas / 10.0) % 60, decimas % 10]
