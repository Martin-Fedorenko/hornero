extends CanvasLayer
## Ícono de wifi tachado arriba a la izquierda, en todas las pantallas, mientras
## no hay conexión con Talo. Lo crea TaloManager y lo muestra con `mostrar`.
## Se dibuja a mano, sin fuentes ni imágenes, como el botón de silencio.

const COLOR_ICONO := Color("f8dc9c")
const COLOR_TACHADO := Color("ff8a7a")
const COLOR_SOMBRA := Color(0.02, 0.06, 0.05, 0.55)
const TAMANO := Vector2(44, 44)
const MARGEN := Vector2(16, 16)

var _icono: Control


func _ready() -> void:
	layer = 110
	process_mode = Node.PROCESS_MODE_ALWAYS
	_icono = Control.new()
	_icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icono.size = TAMANO
	_icono.draw.connect(_dibujar)
	add_child(_icono)
	get_viewport().size_changed.connect(_ubicar)
	_ubicar()
	visible = false


func mostrar(sin_conexion: bool) -> void:
	visible = sin_conexion
	if sin_conexion:
		_ubicar()


## Arriba a la izquierda, dentro de la zona segura (muescas de los celulares).
func _ubicar() -> void:
	_icono.position = Plataforma.area_segura().position + MARGEN


func _dibujar() -> void:
	var lado := TAMANO.x
	_icono.draw_circle(TAMANO * 0.5, lado * 0.5, COLOR_SOMBRA)
	# Tres ondas y el punto, abiertos hacia arriba.
	var origen := Vector2(lado * 0.5, lado * 0.74)
	var grosor := maxf(2.0, lado * 0.08)
	for i in 3:
		var radio := lado * (0.16 + i * 0.13)
		_icono.draw_arc(origen, radio, deg_to_rad(-135), deg_to_rad(-45), 10, COLOR_ICONO, grosor, true)
	_icono.draw_circle(origen, grosor * 0.8, COLOR_ICONO)
	# La raya que lo tacha.
	_icono.draw_line(Vector2(lado * 0.22, lado * 0.2), Vector2(lado * 0.78, lado * 0.8),
			COLOR_TACHADO, grosor * 1.2, true)
