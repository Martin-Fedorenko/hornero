extends Node2D
## Nivel de prueba de vuelo: límites de cámara y HUD de depuración.
## El fondo es la escena PampasBackground (parallax).

## Área jugable. La cámara no muestra nada fuera de este rectángulo.
@export var world_rect := Rect2(0, -400, 6000, 2200)
## Escena a la que vuelve al apretar Esc.
@export_file("*.tscn") var menu_scene := "res://Hornero_Menu_Inicio/menu_hornero/menu_inicio.tscn"

@onready var _hornero: Hornero = $Hornero
@onready var _camera: Camera2D = $Hornero/Camera2D
@onready var _status: Label = $HUD/Status
@onready var _vitals_hud: Control = $HUD/Vitales
@onready var _death_screen: Control = $HUD/Muerte


func _ready() -> void:
	_camera.limit_left = int(world_rect.position.x)
	_camera.limit_top = int(world_rect.position.y)
	_camera.limit_right = int(world_rect.end.x)
	_camera.limit_bottom = int(world_rect.end.y)
	_camera.reset_smoothing()
	_vitals_hud.track(_hornero.vitals)
	_hornero.died.connect(_death_screen.show_after_delay)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file(menu_scene)


func _process(_delta: float) -> void:
	_status.text = "Estado: %s   ·   Velocidad: %4.0f px/s   ·   Pitch: %+3.0f°" % [
		Hornero.State.keys()[_hornero.state],
		_hornero.velocity.length(),
		rad_to_deg(_hornero.pitch),
	]
