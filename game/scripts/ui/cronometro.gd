extends Control
## Cronómetro de la partida, arriba a la derecha y con la letra del juego.
## Arranca de cero en cada partida y se frena al ganar o perder. Con el juego
## pausado (menú de pausa) no corre.

const TextoJuego := preload("res://scripts/ui/texto_juego.gd")

@export var font_size := 40
## Separación con el borde derecho y el de arriba de la pantalla.
@export var margen := Vector2(24.0, 10.0)

var segundos := 0.0
var _corriendo := true
var _label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_label = TextoJuego.crear(font_size)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	var tamano := _label.size
	_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_label.offset_left = -margen.x - tamano.x
	_label.offset_right = -margen.x
	_label.offset_top = margen.y
	_label.offset_bottom = margen.y + tamano.y
	add_child(_label)
	_mostrar()


func _process(delta: float) -> void:
	if not _corriendo:
		return
	segundos += delta
	_mostrar()


## Lo frena y devuelve el tiempo final, en milisegundos enteros.
func detener() -> int:
	_corriendo = false
	_mostrar()
	return milisegundos()


func milisegundos() -> int:
	return roundi(segundos * 1000.0)


func _mostrar() -> void:
	_label.text = formatear(segundos)


## "mm:ss.d" (minutos, segundos y décimas).
static func formatear(total: float) -> String:
	var decimas := floori(total * 10.0)
	return "%02d:%02d.%d" % [floori(decimas / 600.0), floori(decimas / 10.0) % 60, decimas % 10]
