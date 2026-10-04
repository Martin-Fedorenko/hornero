class_name Chimango
extends CharacterBody2D

signal state_changed(previous: State, current: State)
signal flapped
signal aviso_ataque                 # está por lanzarse (para sonido o parpadeo)
signal agarro_jugador
signal forcejeo(progreso: float)    # 0 a 1 mientras el jugador se resiste
signal jugador_escapo
signal solto_jugador
signal se_fue
signal volvio

enum State { FLYING, GLIDING, GROUND }
enum Modo { PERSECUCION, AVISO, PICADA, AGARRE, HUIDA, AUSENTE }

@export var flap_state_duration := 0.45
@export var debug_draw_flight_direction := true
@export var debug_print := false
@export var target: Node2D # Asigna al jugador (Hornero) aquí
@export var empezar_ausente := false # si arranca fuera y aparece a los 20-30 s

@export_group("Persecución")
@export var distancia_atras := 140.0
@export var altura_caza := 90.0
@export var velocidad_max := 450.0        # cuánto MÁS rápido que el jugador puede ir
@export var aceleracion := 2500.0
@export var ganancia_acercamiento := 3.0

@export_group("Ataque")
@export var radio_para_atacar := 70.0
@export var tiempo_alineado := 0.6
@export var tiempo_aviso := 0.5           # ventana para que el jugador reaccione
@export var velocidad_picada := 900.0
@export var giro_picada_deg := 45.0       # cuánto puede corregir en picada (grados/s)
@export_range(0.0, 1.0) var anticipacion := 0.5 # 0 = apunta a donde estás, 1 = predice
@export var duracion_picada := 0.9

@export_group("Agarre")
@export var radio_agarre := 35.0
@export var duracion_agarre := 1.5
@export var presiones_para_escapar := 6
@export var offset_garras := Vector2(30, 25) # x = hacia adelante, y = hacia abajo
@export var velocidad_carga := 350.0

@export_group("Ausencia")
@export var tiempo_ausente_min := 10.0
@export var tiempo_ausente_max := 15.0
@export var velocidad_huida := 700.0
@export var duracion_huida_max := 4.0
@export var margen_pantalla := 120.0

@export_group("Sonido")
## Segundos del grito que se reproducen al aparecer (0 = el audio entero).
@export var duracion_grito := 0.0
## Segundos que tarda el grito en apagarse cuando el chimango se va.
@export var fundido_grito := 2.0

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
var _lado := 1
var _dir_picada := Vector2.RIGHT
var _dir_huida := Vector2.UP
var _presiones := 0

@onready var _grito: AudioStreamPlayer = get_node_or_null("GritoAudio")
@onready var _volumen_grito := _grito.volume_linear if _grito else 1.0
var _fundido: Tween

func _ready() -> void:
	_apply_orientation()
	if not is_instance_valid(target):
		target = get_parent().get_node_or_null("Hornero") as Node2D
	if is_instance_valid(target):
		_target_prev_pos = target.global_position
		if target is PhysicsBody2D:
			add_collision_exception_with(target)
	else:
		push_warning("Chimango: no tiene target asignado")
	if empezar_ausente:
		_ocultar()
	else:
		_gritar()

func _physics_process(delta: float) -> void:
	if debug_print and Engine.get_physics_frames() % 30 == 0:
		print("pos: ", global_position, " modo: ", Modo.keys()[modo], " timer: ", snappedf(_modo_timer, 0.1))

	if modo == Modo.AUSENTE:
		_esperar_ausente(delta)
		return
	if not is_instance_valid(target):
		return

	_estimar_velocidad_objetivo(delta)

	# Si el hornero se metió en el nido techado no hay nada que hacer: se va.
	if _objetivo_refugiado() and (modo == Modo.PERSECUCION or modo == Modo.AVISO \
		or modo == Modo.PICADA):
		_irse()

	var accel := aceleracion
	var deseada := Vector2.ZERO
	match modo:
		Modo.PERSECUCION:
			deseada = _perseguir(delta)
		Modo.AVISO:
			deseada = _aviso(delta)
		Modo.PICADA:
			deseada = _picada(delta)
			accel *= 2.5
		Modo.AGARRE:
			deseada = _cargar(delta)
		Modo.HUIDA:
			deseada = _huir(delta)

	if modo == Modo.AUSENTE: # pudo ocultarse en este frame
		return

	deseada += _evasion()
	velocity = velocity.move_toward(deseada, accel * delta)
	move_and_slide()

	_actualizar_orientacion()
	_actualizar_aleteo(delta)

	if modo == Modo.AGARRE:
		target.global_position = _posicion_garras()

# --- Persecución y ataque ---
func _estimar_velocidad_objetivo(delta: float) -> void:
	var vel_instantanea := (target.global_position - _target_prev_pos) / delta
	_target_vel = _target_vel.lerp(vel_instantanea, 0.2)
	_target_prev_pos = target.global_position
	if absf(_target_vel.x) > 30.0:
		_lado = int(signf(_target_vel.x))

func _perseguir(delta: float) -> Vector2:
	var punto := target.global_position + Vector2(-_lado * distancia_atras, -altura_caza)
	var a_punto := punto - global_position
	var tope := _target_vel.length() + velocidad_max
	var deseada := (_target_vel + a_punto * ganancia_acercamiento).limit_length(tope)

	if a_punto.length() < radio_para_atacar and _puede_agarrar():
		_alineado_timer += delta
	else:
		_alineado_timer = maxf(_alineado_timer - delta, 0.0)

	if _alineado_timer >= tiempo_alineado:
		_cambiar_modo(Modo.AVISO, tiempo_aviso)
		aviso_ataque.emit()
	return deseada

func _aviso(delta: float) -> Vector2:
	_modo_timer -= delta
	if _modo_timer <= 0.0:
		_iniciar_picada()
	# Se queda acompañando al jugador y sube un poco, como tomando impulso
	return _target_vel + Vector2(0.0, -80.0)

func _iniciar_picada() -> void:
	# Apunta a donde va a estar el jugador, no a donde está
	var distancia := global_position.distance_to(target.global_position)
	var tiempo := distancia / velocidad_picada
	var predicho := target.global_position + _target_vel * tiempo * anticipacion
	_dir_picada = global_position.direction_to(predicho)
	_cambiar_modo(Modo.PICADA, duracion_picada)

func _picada(delta: float) -> Vector2:
	_modo_timer -= delta
	var a_objetivo := target.global_position - global_position
	# Corrección limitada: si el jugador esquiva bruscamente, no puede seguirlo
	var max_giro := deg_to_rad(giro_picada_deg) * delta
	_dir_picada = _dir_picada.rotated(clampf(_dir_picada.angle_to(a_objetivo), -max_giro, max_giro))

	if a_objetivo.length() < radio_agarre and _puede_agarrar():
		_agarrar()
	elif _modo_timer <= 0.0:
		_irse() # falló
	return _dir_picada * velocidad_picada

# --- Agarre ---
func _objetivo_refugiado() -> bool:
	return target is Hornero and (target as Hornero).sheltered

func _puede_agarrar() -> bool:
	if _objetivo_refugiado():
		return false
	if target is Hornero:
		var h := target as Hornero
		return h.state != Hornero.State.FALLING and h.state != Hornero.State.RECOVERING \
			and h.state != Hornero.State.DEAD
	return true

func _agarrar() -> void:
	_cambiar_modo(Modo.AGARRE, duracion_agarre)
	_presiones = 0
	target.set_physics_process(false)
	if target is CharacterBody2D:
		(target as CharacterBody2D).velocity = Vector2.ZERO
	if target is Hornero:
		(target as Hornero).knock_down()
	agarro_jugador.emit()

func _cargar(delta: float) -> Vector2:
	_modo_timer -= delta
	# Forcejeo: cada aleteo del jugador suma para soltarse
	if HorneroInput.read().flap:
		_presiones += 1
		forcejeo.emit(float(_presiones) / presiones_para_escapar)
		if _presiones >= presiones_para_escapar:
			_escapar()
			return velocity
	if _modo_timer <= 0.0:
		_soltar()
	return Vector2(facing, -0.5).normalized() * velocidad_carga

func _escapar() -> void:
	target.set_physics_process(true)
	if target is Hornero:
		(target as Hornero).escape_capture(Vector2(-facing * 150.0, -300.0))
	elif target is CharacterBody2D:
		# Sale impulsado hacia atrás y arriba, con control
		(target as CharacterBody2D).velocity = Vector2(-facing * 150.0, -300.0)
	jugador_escapo.emit()
	_irse()

func _soltar() -> void:
	target.set_physics_process(true)
	if target is CharacterBody2D:
		(target as CharacterBody2D).velocity = velocity
	if target.has_method("take_grab_hit"):
		target.take_grab_hit()
	elif target.has_method("knock_down"):
		target.knock_down()
	solto_jugador.emit()
	_irse()

func _posicion_garras() -> Vector2:
	var local := Vector2(offset_garras.x * facing, offset_garras.y)
	return global_position + local.rotated(-pitch * facing)

# --- Huida, ausencia y regreso ---
func _irse() -> void:
	# Se aleja del lado contrario al jugador y hacia arriba
	var lado_huida := signf(global_position.x - target.global_position.x)
	if lado_huida == 0.0:
		lado_huida = facing
	_dir_huida = Vector2(lado_huida, -0.6).normalized()
	_cambiar_modo(Modo.HUIDA, duracion_huida_max)

func _huir(delta: float) -> Vector2:
	_modo_timer -= delta
	if _fuera_de_pantalla() or _modo_timer <= 0.0:
		_ocultar()
		return Vector2.ZERO
	# Le sumamos la velocidad del jugador para salir de cámara aunque él se mueva
	return _target_vel + _dir_huida * velocidad_huida

func _ocultar() -> void:
	visible = false
	velocity = Vector2.ZERO
	_apagar_grito()
	_cambiar_modo(Modo.AUSENTE, randf_range(tiempo_ausente_min, tiempo_ausente_max))
	se_fue.emit()

func _esperar_ausente(delta: float) -> void:
	_modo_timer -= delta
	if _modo_timer <= 0.0 and is_instance_valid(target):
		_reaparecer()

func _reaparecer() -> void:
	global_position = _punto_de_entrada()
	_target_prev_pos = target.global_position
	_target_vel = Vector2.ZERO
	velocity = global_position.direction_to(target.global_position) * 300.0
	visible = true
	_cambiar_modo(Modo.PERSECUCION, 0.0)
	_gritar()
	volvio.emit()

## Avisa con su grito que llegó. Se escucha aunque entre desde fuera de cámara.
func _gritar() -> void:
	if _grito == null or _grito.stream == null:
		return
	if _fundido:
		_fundido.kill()
	_grito.volume_linear = _volumen_grito
	_grito.play()
	if duracion_grito > 0.0:
		get_tree().create_timer(duracion_grito).timeout.connect(_grito.stop)

## Baja el volumen del grito hasta silenciarlo, en vez de cortarlo de golpe.
func _apagar_grito() -> void:
	if _grito == null or not _grito.playing:
		return
	if _fundido:
		_fundido.kill()
	_fundido = create_tween()
	_fundido.tween_property(_grito, ^"volume_linear", 0.0, fundido_grito)
	_fundido.tween_callback(_grito.stop)

func _area_pantalla() -> Rect2:
	var tam := get_viewport_rect().size
	var cam := get_viewport().get_camera_2d()
	if cam:
		tam /= cam.zoom
		return Rect2(cam.get_screen_center_position() - tam / 2.0, tam)
	return Rect2(target.global_position - tam / 2.0, tam)

func _fuera_de_pantalla() -> bool:
	return not _area_pantalla().grow(margen_pantalla).has_point(global_position)

func _punto_de_entrada() -> Vector2:
	var r := _area_pantalla()
	var alto_medio := r.get_center().y
	match randi() % 3:
		0: # izquierda, mitad superior
			return Vector2(r.position.x - margen_pantalla, randf_range(r.position.y, alto_medio))
		1: # derecha, mitad superior
			return Vector2(r.end.x + margen_pantalla, randf_range(r.position.y, alto_medio))
		_: # arriba
			return Vector2(randf_range(r.position.x, r.end.x), r.position.y - margen_pantalla)

func _cambiar_modo(nuevo: Modo, duracion: float) -> void:
	modo = nuevo
	_modo_timer = duracion
	_alineado_timer = 0.0

# --- Evasión ---
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
