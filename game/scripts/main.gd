extends Node2D
## Nivel de prueba de vuelo: fondo, límites de cámara y HUD de depuración.

## Área jugable. La cámara no muestra nada fuera de este rectángulo.
@export var world_rect := Rect2(0, -400, 6000, 2200)
@export var sky_color := Color("#c9dcd7")
@export var far_hills_color := Color("#a2b6a6")
@export var near_hills_color := Color("#839e88")

@onready var _hornero: Hornero = $Hornero
@onready var _camera: Camera2D = $Hornero/Camera2D
@onready var _status: Label = $HUD/Status


func _ready() -> void:
	_camera.limit_left = int(world_rect.position.x)
	_camera.limit_top = int(world_rect.position.y)
	_camera.limit_right = int(world_rect.end.x)
	_camera.limit_bottom = int(world_rect.end.y)
	_camera.reset_smoothing()


func _process(_delta: float) -> void:
	_status.text = "Estado: %s   ·   Velocidad: %4.0f px/s   ·   Pitch: %+3.0f°" % [
		Hornero.State.keys()[_hornero.state],
		_hornero.velocity.length(),
		rad_to_deg(_hornero.pitch),
	]


func _draw() -> void:
	draw_rect(world_rect, sky_color)
	_draw_hills(world_rect.end.y - 520.0, 90.0, 0.0011, far_hills_color)
	_draw_hills(world_rect.end.y - 380.0, 60.0, 0.0023, near_hills_color)


## Silueta ondulada que cubre todo el ancho del mundo hasta el fondo.
func _draw_hills(base_y: float, amplitude: float, frequency: float, color: Color) -> void:
	var points := PackedVector2Array()
	var step := 80.0
	var x := world_rect.position.x
	while x <= world_rect.end.x + step:
		var wave := sin(x * frequency) + 0.5 * sin(x * frequency * 2.7 + 1.3)
		points.append(Vector2(x, base_y - wave * amplitude))
		x += step
	points.append(Vector2(world_rect.end.x + step, world_rect.end.y))
	points.append(Vector2(world_rect.position.x, world_rect.end.y))
	draw_colored_polygon(points, color)
