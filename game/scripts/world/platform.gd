@tool
class_name Platform
extends StaticBody2D
## Rectángulo visible con collider real. El origen es la esquina superior
## izquierda. Por defecto sólo el borde superior es sólido (para posarse);
## con `solid` todo el rectángulo colisiona (piso, paredes).

@export var size := Vector2(400, 120):
	set(value):
		size = value
		_rebuild()
@export var solid := false:
	set(value):
		solid = value
		_rebuild()
## Grosor del collider superior cuando no es sólido.
@export var top_thickness := 8.0:
	set(value):
		top_thickness = value
		_rebuild()
## Permite atravesar el borde superior desde abajo.
@export var one_way := true:
	set(value):
		one_way = value
		_rebuild()
@export var fill_color := Color("#b07a4f"):
	set(value):
		fill_color = value
		queue_redraw()
@export var top_color := Color("#6b8f4e"):
	set(value):
		top_color = value
		queue_redraw()
@export var top_band := 10.0:
	set(value):
		top_band = value
		queue_redraw()

var _collider: CollisionShape2D


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	if not is_inside_tree():
		return
	if solid:
		remove_from_group(&"suelo")
	else:
		add_to_group(&"suelo")
	if _collider == null:
		_collider = CollisionShape2D.new()
		add_child(_collider, false, Node.INTERNAL_MODE_FRONT)
	var shape := RectangleShape2D.new()
	var height := size.y if solid else minf(top_thickness, size.y)
	shape.size = Vector2(size.x, height)
	_collider.shape = shape
	_collider.position = Vector2(size.x, height) * 0.5
	_collider.one_way_collision = one_way and not solid
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), fill_color)
	draw_rect(Rect2(0, 0, size.x, minf(top_band, size.y)), top_color)
