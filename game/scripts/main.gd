extends Node2D
## Nivel de prueba de vuelo: límites de cámara y HUD.
## El fondo es la escena PampasBackground (parallax).

const NestArrow := preload("res://scripts/ui/nest_arrow.gd")

## Área jugable. La cámara no muestra nada fuera de este rectángulo.
@export var world_rect := Rect2(0, -400, 12000, 2065)
@export var nest_exit_distance := 180.0

@onready var _hornero: Hornero = $Hornero
@onready var _hornero_animator: HorneroAnimator = $Hornero/AnimatedSprite2D
@onready var _camera: Camera2D = $Hornero/Camera2D
@onready var _nest: Nest = $World/NestTree/Nest
@onready var _vitals_hud: Control = $HUD/Vitales
@onready var _menu: Control = $HUD/MenuJuego

## Ya salió / entró al nido con G alguna vez: el aviso de esa acción no vuelve.
var _exited_nest_once := false
var _entered_nest_once := false


func _ready() -> void:
	_camera.limit_left = int(world_rect.position.x)
	_camera.limit_top = int(world_rect.position.y)
	_camera.limit_right = int(world_rect.end.x)
	_camera.limit_bottom = int(world_rect.end.y)
	_create_nest_arrow()
	_vitals_hud.track(_hornero.vitals)
	_hornero.died.connect(_menu.abrir_muerte)
	_hornero.state_changed.connect(_on_hornero_state_changed)
	# Si el nido crece o pierde una etapa con el hornero adentro, se reacomoda.
	_nest.material_delivered.connect(_on_nest_changed.unbind(1))
	_nest.construccion_perdida.connect(_on_nest_changed)
	# La partida arranca con el hornero en su nido: sale con G.
	_perch_in_nest()
	_camera.reset_smoothing()


func _create_nest_arrow() -> void:
	var arrow := NestArrow.new()
	arrow.name = "FlechaNido"
	arrow.target = _nest
	$HUD.add_child(arrow)
	# Debajo del menú de pausa / muerte / victoria.
	$HUD.move_child(arrow, _menu.get_index())


func _process(_delta: float) -> void:
	_update_nest_hint()


## Arriba del nido: cómo salir si está adentro, o cómo entrar si puede hacerlo.
## Cada aviso deja de mostrarse una vez que el jugador usó esa acción.
func _update_nest_hint() -> void:
	if _hornero.state == Hornero.State.NESTED:
		_nest.mostrar_aviso("" if _exited_nest_once else "G para salir")
	elif _can_enter_nest() and not _entered_nest_once:
		_nest.mostrar_aviso("G para entrar")
	else:
		_nest.mostrar_aviso("")


func _can_enter_nest() -> bool:
	if _hornero.state == Hornero.State.FALLING \
		or _hornero.state == Hornero.State.RECOVERING \
		or _hornero.state == Hornero.State.DEAD:
		return false
	return _nest.esta_en_aura(_hornero.global_position)


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
		_exited_nest_once = true
		return
	if not _can_enter_nest():
		return
	_perch_in_nest()
	_entered_nest_once = true
	# Entrar al nido terminado gana la partida.
	if _nest.esta_completo():
		_menu.abrir_victoria()


## Acomoda al hornero en el nido según lo construido: en la taza abierta se
## hunde más cuanto más alta es la pared (la pared delantera lo tapa); en el
## horno cerrado sólo asoma la cabeza por la entrada y queda protegido.
func _perch_in_nest() -> void:
	if _nest.is_closed():
		var hole := _nest.hole_global_center()
		_hornero.enter_nest(hole - _hornero_animator.idle_point_offset(_hornero_animator.nest_head), true)
		_hornero_animator.clip_to_circle(hole, _nest.hole_global_radius())
		return
	var rim_y := _nest.rim_global_y()
	var top := _hornero_animator.idle_point_offset(Vector2(0.0, _hornero_animator.nest_top)).y
	var feet := _hornero_animator.idle_point_offset(Vector2(0.0, _hornero_animator.nest_feet)).y
	var sink := (feet - top) * _nest.hidden_fraction()
	var head_x := _hornero_animator.idle_point_offset(_hornero_animator.nest_head).x
	_hornero.enter_nest(Vector2(_nest.cup_head_global_x(_hornero.facing) - head_x, rim_y - feet + sink))
	_hornero_animator.clip_below(_nest.bottom_global_y())


func _on_hornero_state_changed(_previous: Hornero.State, current: Hornero.State) -> void:
	_nest.set_occupied(current == Hornero.State.NESTED)


func _on_nest_changed() -> void:
	if _hornero.state == Hornero.State.NESTED:
		_perch_in_nest()
