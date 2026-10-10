class_name Hornero
extends CharacterBody2D
## Cuerpo del hornero y su máquina de estados.
##
## Cadena de vuelo:  pitch → rotation → forward → velocity → move_and_slide().
## La física la calculan FlightMotor y GroundMotor; este script decide qué
## estado está activo y aplica el resultado al cuerpo.

signal state_changed(previous: State, current: State)
signal flapped
## El hornero rodó sobre su eje para no quedar panza arriba.
signal rolled_upright
## Cayó al piso sin vida. Ya no se levanta.
signal died

enum State { FLYING, GLIDING, GROUND, FALLING, RECOVERING, DEAD, NESTED }

## Tiempo que el hornero se considera aleteando (FLYING) tras cada aleteo.
@export var flap_state_duration := 0.45
@export_range(0.05, 5.0, 0.05) var flap_sound_duration := 1.0

@export_group("Viento")
## Velocidad (px/s) a partir de la cual se escucha el viento. Planeando suele
## ir a ~650; en picada llega a ~900 y aleteando seguido al máximo, 1100.
@export var wind_speed := 800.0
## Segundos que tarda el viento en llegar a su volumen al pasar wind_speed.
@export var wind_fade_in := 0.6
## Segundos que tarda en apagarse cuando baja de wind_speed.
@export var wind_fade_out := 1.0
@export_group("")
## Cuánto puede pasarse de la vertical antes de rodar para no quedar panza
## arriba (grados). Evita que ruede de ida y vuelta justo en la vertical.
@export_range(0.0, 45.0) var upright_roll_margin_deg := 15.0
## Dibuja el vector forward (amarillo) y la velocidad (celeste).
@export var debug_draw_flight_direction := false:
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
## En el suelo, si se está apretando una dirección. Al darse vuelta caminando
## la velocidad pasa por 0, pero sigue caminando.
var wants_to_walk := false
## Está adentro del nido ya techado: los depredadores no lo pueden atacar.
var sheltered := false

var _flap_time_left := 0.0
## Tras enderezarse, la tecla de dirección que se venía apretando apunta al
## revés; se ignora hasta soltarla para no dar media vuelta sin querer.
var _turn_locked := false
## Al rodar, "nariz arriba" pasa a girar para el otro lado. Mientras se siga
## apretando la misma tecla se invierte, así el giro en pantalla continúa.
var _pitch_inverted := false

@onready var _flight: FlightMotor = $FlightMotor
@onready var _ground: GroundMotor = $GroundMotor
@onready var _debug: CanvasItem = $FlightDebug
@onready var vitals: HorneroVitals = $Vitals
@onready var _flap_audio: AudioStreamPlayer2D = $AleteoAudio
@onready var _flap_audio_timer: Timer = $AleteoAudioTimer
## Al rato de entrar al nido, el hornero canta (la espera está en CantoTimer).
@onready var _song_audio: AudioStreamPlayer2D = $CantoAudio
@onready var _song_timer: Timer = $CantoTimer
@onready var _wind_audio: AudioStreamPlayer = $VientoAudio
## Volumen elegido en el nodo VientoAudio: el fundido sube hasta ahí.
@onready var _wind_volume := _wind_audio.volume_linear


func _ready() -> void:
	_debug.visible = debug_draw_flight_direction
	flapped.connect(_play_flap_sound)
	_flap_audio_timer.timeout.connect(_stop_flap_sound)
	_song_timer.timeout.connect(_song_audio.play)
	_wind_audio.volume_linear = 0.0
	_apply_orientation()


func _play_flap_sound() -> void:
	if _flap_audio.stream == null:
		return
	var audio_length := _flap_audio.stream.get_length()
	var playback_duration := flap_sound_duration
	if audio_length > 0.0:
		playback_duration = minf(playback_duration, audio_length)
	_flap_audio.stop()
	_flap_audio.play()
	_flap_audio_timer.start(playback_duration)


func _stop_flap_sound() -> void:
	_flap_audio.stop()


func _process(delta: float) -> void:
	_update_wind(delta)


## A alta velocidad suena el viento: entra y sale con fundido, así no se
## corta de golpe si la velocidad ronda el umbral.
func _update_wind(delta: float) -> void:
	var fast := velocity.length_squared() > wind_speed * wind_speed and state != State.DEAD
	var target := _wind_volume if fast else 0.0
	# Apagado y sin sonar: no hay nada que actualizar.
	if not fast and not _wind_audio.playing and _wind_audio.volume_linear <= 0.0:
		return
	var fade := wind_fade_in if fast else wind_fade_out
	var step := _wind_volume * delta / maxf(fade, 0.01)
	_wind_audio.volume_linear = move_toward(_wind_audio.volume_linear, target, step)
	if fast and not _wind_audio.playing:
		_wind_audio.play()
	elif not fast and _wind_audio.playing and _wind_audio.volume_linear <= 0.0:
		_wind_audio.stop()


func _physics_process(delta: float) -> void:
	if state == State.NESTED:
		velocity = Vector2.ZERO
		_regenerate_stamina(delta)
		return
	if state == State.DEAD:
		velocity = _ground.integrate(velocity, 0.0, delta)
		move_and_slide()
		return
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
	_regenerate_stamina(delta)


func is_airborne() -> bool:
	return state != State.GROUND and state != State.RECOVERING \
		and state != State.DEAD and state != State.NESTED


func is_dead() -> bool:
	return state == State.DEAD


## Aturde al hornero: cae sin control hasta tocar el piso y se recupera.
func knock_down() -> void:
	if state == State.FALLING or state == State.RECOVERING or state == State.DEAD:
		return
	pitch = 0.0
	_apply_orientation()
	_set_state(State.FALLING)


## Recupera el control cuando el hornero escapa del agarre del chimango.
func escape_capture(escape_velocity: Vector2) -> void:
	if state == State.DEAD:
		return
	pitch = 0.0
	velocity = escape_velocity
	_apply_orientation()
	_set_state(State.GLIDING)


## covered: el nido ya tiene techo, así que adentro queda protegido.
func enter_nest(nest_position: Vector2, covered := false) -> void:
	if state == State.FALLING or state == State.RECOVERING or state == State.DEAD:
		return
	sheltered = covered
	global_position = nest_position
	velocity = Vector2.ZERO
	pitch = 0.0
	wants_to_walk = false
	_apply_orientation()
	_set_state(State.NESTED)


func exit_nest(exit_position: Vector2) -> void:
	if state != State.NESTED:
		return
	global_position = exit_position
	velocity = Vector2.ZERO
	pitch = 0.0
	_apply_orientation()
	_set_state(State.GLIDING)


## Lo agarró un depredador y lo soltó: recibe daño y cae aturdido.
func take_grab_hit() -> void:
	vitals.take_damage(vitals.grab_damage)
	knock_down()


## La llama el animador cuando termina la animación de recuperarse.
func finish_recovery() -> void:
	if state == State.RECOVERING:
		_set_state(State.GROUND)


# --- Aire ---------------------------------------------------------------

func _air_step(input: HorneroInput, delta: float) -> void:
	if _turn_locked and (input.move == 0.0 or signf(input.move) == facing):
		_turn_locked = false
	if not _turn_locked and input.move != 0.0 and signf(input.move) != facing:
		facing = int(signf(input.move))
		velocity = _flight.turn_around(velocity)
	if input.pitch == 0.0:
		_pitch_inverted = false
	var pitch_input := -input.pitch if _pitch_inverted else input.pitch
	pitch = _flight.update_pitch(pitch, pitch_input, velocity, forward, facing, delta)
	if absf(pitch) > PI / 2.0 + deg_to_rad(upright_roll_margin_deg):
		_roll_upright(input)
	_apply_orientation()
	if input.flap and vitals.can_flap():
		_flap()
	velocity = _flight.integrate(velocity, forward, delta)


func _flap() -> void:
	vitals.spend_flap()
	velocity = _flight.flap(velocity, forward)
	_flap_time_left = flap_state_duration
	_set_state(State.FLYING)
	flapped.emit()


## Pasada la vertical quedaría panza arriba: rueda sobre su eje. Invierte
## facing y refleja el pitch, así rotation, forward y velocity no cambian;
## sólo el dibujo pasa a tener la panza hacia abajo.
func _roll_upright(input: HorneroInput) -> void:
	facing = -facing
	pitch = wrapf(PI - pitch, -PI, PI)
	_turn_locked = true
	if input.pitch != 0.0:
		_pitch_inverted = not _pitch_inverted
	rolled_upright.emit()


# --- Caída ---------------------------------------------------------------

## Sin input: sólo gravedad y resistencia del aire, sin sustentación.
func _fall_step(delta: float) -> void:
	velocity = _flight.integrate_fall(velocity, delta)


func _recover_step(delta: float) -> void:
	velocity = _ground.integrate(velocity, 0.0, delta)


# --- Suelo ---------------------------------------------------------------

func _ground_step(input: HorneroInput, delta: float) -> void:
	wants_to_walk = input.move != 0.0
	if input.flap and vitals.can_flap():
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
	wants_to_walk = input.move != 0.0
	_set_state(State.GROUND)


func _crash_land() -> void:
	velocity.y = 0.0
	if vitals.health <= 0.0:
		_set_state(State.DEAD)
		died.emit()
		return
	if vitals.drain_on_crash:
		vitals.drain_stamina()
	_set_state(State.RECOVERING)


# --- Stamina -------------------------------------------------------------

## En el suelo recupera mucho, planeando un poco; aleteando o caído, nada.
func _regenerate_stamina(delta: float) -> void:
	match state:
		State.GROUND:
			vitals.regenerate(vitals.ground_regen, delta)
		State.GLIDING:
			vitals.regenerate(vitals.glide_regen, delta)
		State.NESTED:
			vitals.regenerate(vitals.nest_regen, delta)
			vitals.heal(vitals.nest_heal * delta)


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
	if next == State.NESTED:
		_song_timer.start()
	else:
		sheltered = false
		_song_timer.stop()
		_song_audio.stop()
	state_changed.emit(previous, next)


## Única fuente de verdad de la orientación: pitch + facing → rotation → forward.
## Mirando a la izquierda el cuerpo gira 180°; el sprite compensa invirtiéndose.
func _apply_orientation() -> void:
	var base_heading := 0.0 if facing > 0 else PI
	rotation = base_heading - pitch * facing
	forward = Vector2.RIGHT.rotated(rotation)
