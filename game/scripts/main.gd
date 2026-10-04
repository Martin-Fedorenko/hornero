extends Node2D
## Nivel de prueba de vuelo: límites de cámara y HUD.
## El fondo es la escena PampasBackground (parallax).

const NestArrow := preload("res://scripts/ui/nest_arrow.gd")

## Área jugable. La cámara no muestra nada fuera de este rectángulo.
@export var world_rect := Rect2(0, -400, 12000, 2065)
@export var nest_perch_offset := Vector2(0, -18)
@export var nest_exit_distance := 180.0

@onready var _hornero: Hornero = $Hornero
@onready var _camera: Camera2D = $Hornero/Camera2D
@onready var _nest: AnimatedSprite2D = $World/NestTree/Nest
@onready var _vitals_hud: Control = $HUD/Vitales
@onready var _menu: Control = $HUD/MenuJuego


func _ready() -> void:
	_camera.limit_left = int(world_rect.position.x)
	_camera.limit_top = int(world_rect.position.y)
	_camera.limit_right = int(world_rect.end.x)
	_camera.limit_bottom = int(world_rect.end.y)
	_camera.reset_smoothing()
	_create_nest_arrow()
	_vitals_hud.track(_hornero.vitals)
	_hornero.died.connect(_menu.abrir_muerte)


func _create_nest_arrow() -> void:
	var arrow := NestArrow.new()
	arrow.name = "FlechaNido"
	arrow.target = _nest
	$HUD.add_child(arrow)
	# Debajo del menú de pausa / muerte / victoria.
	$HUD.move_child(arrow, _menu.get_index())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		if not _menu.esta_abierto() and not _hornero.is_dead():
			_menu.abrir_pausa()
		return
	if event is InputEventKey and event.pressed and not event.echo \
		and event.physical_keycode == KEY_G:
		_toggle_nest_pose()
		get_viewport().set_input_as_handled()


func _toggle_nest_pose() -> void:
	if _hornero.state == Hornero.State.NESTED:
		var exit_position := _nest.global_position + Vector2(
			nest_exit_distance * _hornero.facing, 0.0)
		_hornero.exit_nest(exit_position)
		return
	if _hornero.state == Hornero.State.FALLING \
		or _hornero.state == Hornero.State.RECOVERING \
		or _hornero.state == Hornero.State.DEAD:
		return
	if not _nest.esta_en_aura(_hornero.global_position):
		return
	_hornero.enter_nest(_nest.global_position + nest_perch_offset)
	# Entrar al nido terminado gana la partida.
	if _nest.esta_completo():
		_menu.abrir_victoria()
