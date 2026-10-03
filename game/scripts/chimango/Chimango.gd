class_name Chimango
extends CharacterBody2D

signal state_changed(previous: State, current: State)
signal flapped

enum State { FLYING, GLIDING, GROUND }
enum Modo { PERSECUCION, PICADA, RECUPERACION }

@export var flap_state_duration := 0.45
@export var debug_draw_flight_direction := true
@export var debug_print := true # imprime posición y estado en Salida
@export var target: Node2D # Asigna al jugador (Hornero) aquí

@export_group("Persecución")
@export var distancia_atras := 140.0      # cuánto se queda detrás del jugador
@export var altura_caza := 90.0           # cuánto más arriba
@export var velocidad_max := 450.0        # cuánto MÁS rápido que el jugador puede ir
@export var aceleracion := 2500.0         # qué tan rápido corrige su rumbo
@export var ganancia_acercamiento := 3.0  # qué tan agresivo va hacia su posición

@export_group("Picada")
@export var radio_para_atacar := 70.0
@export var tiempo_alineado := 0.6
@export var velocidad_picada := 950.0
@export var duracion_picada := 0.8
@export var duracion_recuperacion := 1.2

@export_group("Visual")
@export var pitch_max_deg := 50.0
@export var intervalo_aleteo := 0.3

@export_group("Evasión")
@export var distancia_deteccion := 140.0

var state := State.GLIDING
var modo := Modo.PERSECUCION
var facing := 1
var pitch := 0.0
var forward := Vector2.RIGHT

var _flap_time_left := 0.0
var _flap_timer := 0.0
var _modo_timer := 0.0
var _alineado_timer := 0.0
var _target_prev_pos := Vector2.ZERO
var _target_vel := Vector2.ZERO
var _lado := 1 # hacia dónde se mueve el jugador

func _ready() -> void:
	_apply_orientation()
	# Si no se asignó en el inspector, busca al Hornero como hermano en la escena
	if not is_instance_valid(target):
		target = get_parent().get_node_or_null("Hornero") as Node2D
	if is_instance_valid(target):
		_target_prev_pos = target.global_position
	else:
		push_warning("Chimango: no tiene target asignado")

func _physics_process(delta: float) -> void:
	# Debug: imprime dos veces por segundo
	if debug_print and Engine.get_physics_frames() % 30 == 0:
		print("pos: ", global_position, " vel: ", velocity.round(), " modo: ", Modo.keys()[modo], " target: ", target)

	if not is_instance_valid(target):
		return

	_estimar_velocidad_objetivo(delta)

	var accel := aceleracion
	var deseada := Vector2.ZERO
	match modo:
		Modo.PERSECUCION:
			deseada = _perseguir(delta)
		Modo.PICADA:
			deseada = _picada(delta)
			accel *= 2.5 # la picada es brusca
		Modo.RECUPERACION:
			deseada = _recuperar(delta)

	deseada += _evasion()
	velocity = velocity.move_toward(deseada, accel * delta)
	move_and_slide()

	_actualizar_orientacion()
	_actualizar_aleteo(delta)

# --- Comportamiento ---
func _estimar_velocidad_objetivo(delta: float) -> void:
	var vel_instantanea := (target.global_position - _target_prev_pos) / delta
	_target_vel = _target_vel.lerp(vel_instantanea, 0.2) # suavizado
	_target_prev_pos = target.global_position
	if absf(_target_vel.x) > 30.0:
		_lado = int(signf(_target_vel.x))

func _perseguir(delta: float) -> Vector2:
	var punto := target.global_position + Vector2(-_lado * distancia_atras, -altura_caza)
	var a_punto := punto - global_position
	# Tope relativo: siempre puede ir velocidad_max más rápido que el jugador
	var tope := _target_vel.length() + velocidad_max
	var deseada := (_target_vel + a_punto * ganancia_acercamiento).limit_length(tope)

	if a_punto.length() < radio_para_atacar:
		_alineado_timer += delta
	else:
		_alineado_timer = maxf(_alineado_timer - delta, 0.0)

	if _alineado_timer >= tiempo_alineado:
		_cambiar_modo(Modo.PICADA, duracion_picada)
	return deseada

func _picada(delta: float) -> Vector2:
	_modo_timer -= delta
	var a_objetivo := target.global_position - global_position
	if _modo_timer <= 0.0 or a_objetivo.length() < 20.0:
		_cambiar_modo(Modo.RECUPERACION, duracion_recuperacion)
	return a_objetivo.normalized() * velocidad_picada + _target_vel

func _recuperar(delta: float) -> Vector2:
	_modo_timer -= delta
	if _modo_timer <= 0.0:
		_cambiar_modo(Modo.PERSECUCION, 0.0)
	# Sigue de largo y trepa, acompañando al jugador
	return _target_vel + Vector2(facing * velocidad_max * 0.6, -velocidad_max * 0.5)

func _cambiar_modo(nuevo: Modo, duracion: float) -> void:
	modo = nuevo
	_modo_timer = duracion
	_alineado_timer = 0.0

func _evasion() -> Vector2:
	if velocity.length_squared() > 1.0 and _raycast(velocity.normalized() * distancia_deteccion):
		return Vector2.UP * velocidad_max
	return Vector2.ZERO

func _raycast(hasta: Vector2) -> bool:
	var excluir: Array[RID] = [get_rid()]
	if target is CollisionObject2D:
		excluir.append(target.get_rid())
	var query := PhysicsRayQueryParameters2D.create(
		global_position, global_position + hasta, collision_mask, excluir)
	return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()

# --- Visual ---
func _actualizar_orientacion() -> void:
	if absf(velocity.x) > 20.0:
		facing = int(signf(velocity.x))
	var limite := deg_to_rad(pitch_max_deg)
	pitch = clampf(atan2(-velocity.y, absf(velocity.x)), -limite, limite)
	_apply_orientation()

func _actualizar_aleteo(delta: float) -> void:
	_flap_timer = maxf(_flap_timer - delta, 0.0)
	_flap_time_left = maxf(_flap_time_left - delta, 0.0)
	if modo != Modo.PICADA and _flap_timer <= 0.0:
		_flap_timer = intervalo_aleteo
		_flap_time_left = flap_state_duration
		_set_state(State.FLYING)
		flapped.emit()
	elif _flap_time_left == 0.0:
		_set_state(State.GLIDING)

func is_airborne() -> bool:
	return true

func _set_state(next: State) -> void:
	if next == state:
		return
	var previous := state
	state = next
	state_changed.emit(previous, next)

func _apply_orientation() -> void:
	var base_heading := 0.0 if facing > 0 else PI
	rotation = base_heading - pitch * facing
	forward = Vector2.RIGHT.rotated(rotation)
