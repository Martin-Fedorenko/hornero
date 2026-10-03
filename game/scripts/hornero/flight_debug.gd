extends Node2D
## Dibuja el vector forward (amarillo) y la velocidad (celeste) del hornero
## en coordenadas de mundo, para comprobar que coinciden con el dibujo.

@export var forward_length := 70.0
## Píxeles dibujados por cada px/s de velocidad.
@export var velocity_scale := 0.12
@export var forward_color := Color(1.0, 0.85, 0.1)
@export var velocity_color := Color(0.1, 0.75, 1.0)
@export var line_width := 3.0

@onready var _body: Hornero = get_parent()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	# Deshacer la rotación del cuerpo: se dibuja con ejes de mundo.
	draw_set_transform(Vector2.ZERO, -global_rotation)
	_draw_arrow(_body.forward * forward_length, forward_color)
	_draw_arrow(_body.velocity * velocity_scale, velocity_color)


func _draw_arrow(vector: Vector2, color: Color) -> void:
	if vector.length() < 2.0:
		return
	draw_line(Vector2.ZERO, vector, color, line_width, true)
	var head := vector.normalized() * 10.0
	draw_line(vector, vector - head.rotated(0.5), color, line_width, true)
	draw_line(vector, vector - head.rotated(-0.5), color, line_width, true)
