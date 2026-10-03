class_name Hornero
extends CharacterBody2D
## Cuerpo del hornero y su máquina de estados.
##
## Cadena de vuelo:  pitch → rotation → forward → velocity → move_and_slide().
## La física la calculan FlightMotor y GroundMotor; este script decide qué
## estado está activo y aplica el resultado al cuerpo.

signal state_changed(previous: State, current: State)
signal flapped

enum State { FLYING, GLIDING, GROUND, FALLING, RECOVERING }

## Tiempo que el hornero se considera aleteando (FLYING) tras cada aleteo.
@export var flap_state_duration := 0.45
## Dibuja el vector forward (amarillo) y la velocidad (celeste).
@export var debug_draw_flight_direction := true:
	set(value):
		debug_draw_flight_direction = value
		if is_node_ready():
			_debug.visible = value

var state := State.GLIDING
## 1 mira a la derecha, -1 a la izquierda.
var facing := 1
## Inclinación en radianes respecto de la horizontal. Positivo = nariz arriba.
var pitch := 0.0
## Vector unitario hacia donde apunta el cuerpo. Siempre RIGHT rotado por rotation.
var forward := Vector2.RIGHT

var _flap_time_left := 0.0

@onready var _flight: FlightMotor = $FlightMotor
@onready var _ground: GroundMotor = $GroundMotor
@onready var _debug: CanvasItem = $FlightDebug


func _ready() -> void:
	_debug.visible = debug_draw_flight_direction
	_apply_orientation()


func _physics_process(delta: float) -> void:
	var input := HorneroInput.read()
	if input.fall:
		knock_down()
	match state:
		State.GROUND:
			_ground_step(input, delta)
		State.FALLING:
			_fall_step(delta)
		State.RECOVERING:
			_recover_step(delta)
		_:
			_air_step(input, delta)
	move_and_slide()
	_resolve_contacts(input, delta)


func is_airborne() -> bool:
	return state != State.GROUND and state != State.RECOVERING


## Aturde al hornero: cae sin control hasta tocar el piso y se recupera.
func knock_down() -> void:
	if state == State.FALLING or state == State.RECOVERING:
		return
	pitch = 0.0
	_apply_orientation()
	_set_state(State.FALLING)


## La llama el animador cuando termina la animación de recuperarse.
func finish_recovery() -> void:
	if state == State.RECOVERING:
		_set_state(State.GROUND)


# --- Aire ---------------------------------------------------------------

func _air_step(input: HorneroInput, delta: float) -> void:
	if input.move != 0.0 and signf(input.move) != facing:
		facing = int(signf(input.move))
		velocity = _flight.turn_around(velocity)
	pitch = _flight.update_pitch(pitch, input.pitch, velocity, forward, facing, delta)
	_apply_orientation()
	if input.flap:
		_flap()
	velocity = _flight.integrate(velocity, forward, delta)


func _flap() -> void:
	velocity = _flight.flap(velocity, forward)
	_flap_time_left = flap_state_duration
	_set_state(State.FLYING)
	flapped.emit()


# --- Caída ---------------------------------------------------------------

## Sin input: sólo gravedad y resistencia del aire, sin sustentación.
func _fall_step(delta: float) -> void:
	velocity = _flight.integrate_fall(velocity, delta)


func _recover_step(delta: float) -> void:
	velocity = _ground.integrate(velocity, 0.0, delta)


# --- Suelo ---------------------------------------------------------------

func _ground_step(input: HorneroInput, delta: float) -> void:
	if input.flap:
		_take_off()
		return
	if input.move != 0.0:
		facing = int(signf(input.move))
		_apply_orientation()
	velocity = _ground.integrate(velocity, input.move, delta)


func _take_off() -> void:
	pitch = _flight.takeoff_pitch()
	_apply_orientation()
	_flap()


func _land(input: HorneroInput) -> void:
	# Tras un loop puede venir invertido: queda mirando hacia donde apunta el pico.
	if forward.x != 0.0:
		facing = int(signf(forward.x))
	pitch = 0.0
	_apply_orientation()
	velocity = Vector2(_ground.target_speed(input.move), 0.0)
	_set_state(State.GROUND)


func _crash_land() -> void:
	velocity.y = 0.0
	_set_state(State.RECOVERING)


# --- Transiciones ---------------------------------------------------------

## Decide el estado a partir de lo que reportó la física en move_and_slide().
func _resolve_contacts(input: HorneroInput, delta: float) -> void:
	_flap_time_left = maxf(_flap_time_left - delta, 0.0)
	if is_on_floor():
		if state == State.FALLING:
			_crash_land()
		elif is_airborne():
			_land(input)
	elif state == State.GROUND:
		_set_state(State.GLIDING) # Caminó fuera de un borde.
	elif state == State.RECOVERING:
		_set_state(State.FALLING)
	elif state == State.FLYING and _flap_time_left == 0.0:
		_set_state(State.GLIDING)


func _set_state(next: State) -> void:
	if next == state:
		return
	var previous := state
	state = next
	state_changed.emit(previous, next)


## Única fuente de verdad de la orientación: pitch + facing → rotation → forward.
## Mirando a la izquierda el cuerpo gira 180°; el sprite compensa invirtiéndose.
func _apply_orientation() -> void:
	var base_heading := 0.0 if facing > 0 else PI
	rotation = base_heading - pitch * facing
	forward = Vector2.RIGHT.rotated(rotation)
