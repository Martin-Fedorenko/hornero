extends Node2D

const Cercania := preload("res://scripts/world/cercania.gd")
## Píxeles de pantalla más allá del borde en los que el destello ya se anima.
const MARGEN_ACTIVACION := 64.0

@export_range(12.0, 120.0, 1.0) var radio: float = 22.0
## Resplandor que late detrás del objeto para que se vea en el pasto.
@export var resplandor := true
## Tamaño de las estrellitas que giran alrededor (1 = el tamaño original).
@export_range(0.5, 4.0, 0.1) var escala_destellos := 2.0

## Material aditivo compartido por todos los resplandores: con uno solo,
## Godot puede dibujarlos juntos en vez de uno por uno.
static var _mezcla: CanvasItemMaterial

var _tiempo := 0.0
var _fondo: Node2D
## El objeto (o el nido) al que pertenece; se lee en cada frame.
@onready var _padre: Node = get_parent()


func _ready() -> void:
	if resplandor:
		# Va en su propio nodo, hermano de este y dibujado detrás del padre
		# (el objeto o el nido), para que el brillo quede detrás del dibujo
		# pero delante de lo que esté atrás (el árbol, el pasto). Mezcla
		# aditiva para que brille.
		_fondo = Node2D.new()
		_fondo.name = "Resplandor"
		_fondo.show_behind_parent = true
		_fondo.transform = transform
		if _mezcla == null:
			_mezcla = CanvasItemMaterial.new()
			_mezcla.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		_fondo.material = _mezcla
		_fondo.draw.connect(_dibujar_resplandor)
		# Diferido: el padre todavía está armando sus hijos.
		get_parent().add_child.call_deferred(_fondo)
	_activar_por_cercania.call_deferred()


## Fuera de pantalla no late ni se redibuja: con muchos bichos en los árboles
## esto es lo que más pesa. El enabler cuelga del padre y no de este nodo
## porque este se oculta al recogerse el objeto, y oculto no volvería a
## encenderse.
func _activar_por_cercania() -> void:
	var padre := get_parent() as Node2D
	if padre == null:
		return
	var alcance := Vector2.ONE * (radio + 10.0) * escala_destellos * scale.abs()
	Cercania.activar_cerca_de_camara(
		self, padre, Rect2(position - alcance, alcance * 2.0), MARGEN_ACTIVACION)


func _process(delta: float) -> void:
	_tiempo = fmod(_tiempo + delta, 2.4)
	visible = _padre.get("recogida") != true
	if _fondo:
		_fondo.visible = visible
	if not visible:
		return
	queue_redraw()
	if _fondo:
		_fondo.queue_redraw()


func _exit_tree() -> void:
	if is_instance_valid(_fondo):
		_fondo.queue_free()


func _pulso() -> float:
	return 0.5 + 0.5 * sin(_tiempo * TAU / 2.4)


func _dibujar_resplandor() -> void:
	# Círculos superpuestos: el centro acumula más luz que el borde.
	# 8 capas con el doble de alfa: el mismo brillo con la mitad de círculos.
	var capas := 8
	var pulso := _pulso()
	var crecer := 0.92 + pulso * 0.12
	var color := Color(1.0, 0.8, 0.35, 0.044 + pulso * 0.036)
	for i in capas:
		var t := float(i) / capas
		_fondo.draw_circle(Vector2.ZERO, radio * (1.15 - t * 0.85) * crecer, color)


func _draw() -> void:
	var pulso := _pulso()
	draw_arc(
		Vector2.ZERO,
		radio,
		0.0,
		TAU,
		40,
		Color(1.0, 0.83, 0.37, 0.08 + pulso * 0.08),
		1.5,
		true
	)
	for indice in range(3):
		var fase := fposmod(_tiempo * 0.8 + float(indice) / 3.0, 1.0)
		var brillo := sin(fase * PI)
		if brillo < 0.78 - 0.3 * (escala_destellos - 1.0):
			continue
		var angulo := TAU * float(indice) / 3.0 - PI / 2.0 + _tiempo * 0.18
		var centro := Vector2(cos(angulo), sin(angulo)) * (radio + 3.0 * escala_destellos)
		var tamano := (2.0 + brillo * 2.0) * escala_destellos
		var color := Color(1.0, 0.94, 0.67, brillo)
		var ancho := maxf(1.0, escala_destellos * 0.8)
		draw_line(centro - Vector2(tamano, 0.0), centro + Vector2(tamano, 0.0), color, ancho, true)
		draw_line(centro - Vector2(0.0, tamano), centro + Vector2(0.0, tamano), color, ancho, true)
