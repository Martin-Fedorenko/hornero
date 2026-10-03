extends Node2D
## Nivel de prueba de vuelo: límites de cámara y HUD de depuración.
## El fondo es la escena PampasBackground (parallax).

## Área jugable. La cámara no muestra nada fuera de este rectángulo.
@export var world_rect := Rect2(0, -400, 6000, 2200)

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
