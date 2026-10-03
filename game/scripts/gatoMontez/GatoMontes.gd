class_name GatoMontes
extends CharacterBody2D

signal agarro_jugador
signal solto_jugador

enum Modo { PASEO, PERSECUCION, ZARPAZO, SALTO, AGARRE, RECUPERACION }

@export var target: Node2D # Hornero (si queda vacío, lo busca solo)
@export var debug_print := false
@export var debug_draw := false # dibuja la boca y el alcance del zarpazo

@export_group("Paseo")
@export var velocidad_caminar := 70.0
@export var tiempo_caminar_min := 2.0
@export var tiempo_caminar_max := 5.0
@export var tiempo_pausa_min := 0.8
@export var tiempo_pausa_max := 2.0
@export var probabilidad_pausa := 0.4

@export_group("Persecución")
@export var velocidad_correr := 260.0
@export var radio_deteccion := 600.0
@export var tiempo_memoria := 2.0
@export var distancia_minima := 30.0

@export_group("Zarpazo")
@export var radio_zarpazo := 60.0          # distancia horizontal para atacar en tierra
@export var tolerancia_vertical := 50.0     # diferencia de altura aceptada para el zarpazo
@export var duracion_zarpazo := 0.5
@export var momento_golpe := 0.3            # antes de esto el Hornero puede escapar volando
@export var empuje_zarpazo := Vector2(250, -150)

@export_group("Salto")
@export var alcance_salto_x := 220.0        # distancia horizontal máxima para saltar
@export var altura_salto_max := 220.0       # qué tan arriba puede llegar
@export var altura_salto_min := 60.0
@export var margen_salto := 20.0            # salta un poco más alto que el Hornero
@export var velocidad_salto_x := 400.0
@export var radio_agarre := 45.0
@export var offset_boca := Vector2(35, -45) # dónde queda el Hornero agarrado (mirando a la derecha)
@export var cooldown_salto := 1.0

@export_group("Agarre")
@export var tiempo_sujetar := 0.35          # lo sostiene en el piso antes de tirarlo
@export var fuerza_tirada := Vector2(200, 100)
@export var tiempo_max_agarre := 3.0        # seguridad por si nunca aterriza

@export_group("Recuperación")
@export var duracion_recuperacion := 1.5

@export_group("Física")
@export var aceleracion := 1800.0
@export var friccion := 2200.0
@export var gravedad := 1400.0
@export var detectar_bordes := true
@export var distancia_borde := 20.0
@export var largo_rayo_borde := 64.0

var modo := Modo.PASEO
var facing := 1
var _modo_timer := 0.0 # tiempo desde que entró al modo actual
var _paseo_dir := 0
var _paseo_timer := 0.0
var _memoria_timer := 0.0
var _cooldown_salto_timer := 0.0
var _golpe_hecho := false
var _tiempo_en_suelo := 0.0
var _debug_timer := 0.0
var _ray_borde: RayCast2D


func _ready() -> void:
	add_to_group("gatos")

	if not is_instance_valid(target):
		target = get_parent().get_node_or_null("Hornero") as Node2D
	if is_instance_valid(target):
		if target is PhysicsBody2D:
			add_collision_exception_with(target)
	else:
		push_warning("GatoMontes: no tiene target asignado")

	for g in get_tree().get_nodes_in_group("gatos"):
		if g != self and g is PhysicsBody2D:
			add_collision_exception_with(g)

	_ray_borde = RayCast2D.new()
	_ray_borde.target_position = Vector2(0, largo_rayo_borde)
	_ray_borde.collision_mask = collision_mask
	_ray_borde.add_exception(self)
	add_child(_ray_borde)

	facing = [-1, 1].pick_random()
	_paseo_dir = facing
	_paseo_timer = randf_range(tiempo_caminar_min, tiempo_caminar_max)


func _exit_tree() -> void:
	# Si el gato desaparece con el Hornero en la boca, lo libera
	if modo == Modo.AGARRE and is_instance_valid(target):
		target.set_physics_process(true)
		target.remove_meta("agarrado_por")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravedad * delta
	_modo_timer += delta
	_cooldown_salto_timer = maxf(_cooldown_salto_timer - delta, 0.0)

	match modo:
		Modo.PASEO:
			_proc_paseo(delta)
		Modo.PERSECUCION:
			_proc_persecucion(delta)
		Modo.ZARPAZO:
			_proc_zarpazo(delta)
		Modo.SALTO:
			_proc_salto()
		Modo.AGARRE:
			_proc_agarre(delta)
		Modo.RECUPERACION:
			_proc_recuperacion(delta)

	move_and_slide()

	if modo == Modo.AGARRE and is_instance_valid(target):
		target.global_position = _boca()

	if debug_draw:
		queue_redraw()
	_debug(delta)


# ---------- Modos ----------

func _proc_paseo(delta: float) -> void:
	if _hornero_disponible() and _hornero_en_suelo() and _dist() < radio_deteccion:
		_cambiar_modo(Modo.PERSECUCION)
		_memoria_timer = tiempo_memoria
		return
	_mover_horizontal(_paseo(delta), velocidad_caminar, delta)


func _proc_persecucion(delta: float) -> void:
	if not _hornero_disponible():
		_volver_a_pasear()
		return

	if _hornero_en_suelo() and _dist() < radio_deteccion * 1.3:
		_memoria_timer = tiempo_memoria
	else:
		_memoria_timer -= delta
	if _memoria_timer <= 0.0:
		_volver_a_pasear()
		return

	if _puede_zarpazo():
		_golpe_hecho = false
		_cambiar_modo(Modo.ZARPAZO)
		return
	if _puede_saltar():
		_iniciar_salto()
		return

	var dir_x := 0.0
	var dx := target.global_position.x - global_position.x
	if absf(dx) > distancia_minima:
		dir_x = signf(dx)
	if dir_x != 0.0 and detectar_bordes and is_on_floor() and _hay_borde(int(dir_x)):
		facing = int(dir_x)
		dir_x = 0.0
	_mover_horizontal(dir_x, velocidad_correr, delta)


func _proc_zarpazo(delta: float) -> void:
	_mirar_al_hornero()
	velocity.x = move_toward(velocity.x, 0.0, friccion * delta)

	if not _golpe_hecho:
		# Si despegó antes del golpe, salta a buscarlo
		if _puede_saltar():
			_iniciar_salto()
			return
		if _modo_timer >= momento_golpe:
			_golpe_hecho = true
			if _puede_zarpazo():
				_golpear()

	if _modo_timer >= duracion_zarpazo:
		_cambiar_modo(Modo.RECUPERACION)


func _proc_salto() -> void:
	# En el aire no se dirige: conserva el impulso del salto
	if _hornero_disponible() and _boca().distance_to(target.global_position) < radio_agarre:
		_agarrar()
		return
	if _modo_timer > 0.1 and is_on_floor():
		_cambiar_modo(Modo.RECUPERACION) # falló


func _proc_agarre(delta: float) -> void:
	if _modo_timer > 0.1 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, friccion * delta)
		_tiempo_en_suelo += delta
		if _tiempo_en_suelo >= tiempo_sujetar:
			_soltar()
			return
	if _modo_timer >= tiempo_max_agarre:
		_soltar()


func _proc_recuperacion(delta: float) -> void:
	# Se aleja del Hornero caminando
	var dir_x := 0.0
	if is_instance_valid(target):
		dir_x = -signf(target.global_position.x - global_position.x)
	if dir_x != 0.0 and detectar_bordes and is_on_floor() and _hay_borde(int(dir_x)):
		dir_x = 0.0
	_mover_horizontal(dir_x, velocidad_caminar, delta)
	if _modo_timer >= duracion_recuperacion:
		_volver_a_pasear()


# ---------- Ataques ----------

func _puede_zarpazo() -> bool:
	if not (_hornero_disponible() and _hornero_en_suelo()):
		return false
	var dif := target.global_position - global_position
	return absf(dif.x) <= radio_zarpazo and absf(dif.y) <= tolerancia_vertical


func _puede_saltar() -> bool:
	if not is_on_floor() or _cooldown_salto_timer > 0.0:
		return false
	if not _hornero_disponible() or _hornero_en_suelo():
		return false
	var dif := target.global_position - global_position
	return dif.y < 0.0 and -dif.y <= altura_salto_max and absf(dif.x) <= alcance_salto_x


func _iniciar_salto() -> void:
	var dx := target.global_position.x - global_position.x
	var altura := clampf(global_position.y - target.global_position.y + margen_salto,
		altura_salto_min, altura_salto_max)
	var vy := -sqrt(2.0 * gravedad * altura)
	var t := -vy / gravedad # tiempo hasta el punto más alto
	var vx := clampf(dx / t, -velocidad_salto_x, velocidad_salto_x)
	velocity = Vector2(vx, vy)
	if dx != 0.0:
		facing = int(signf(dx))
	_cooldown_salto_timer = cooldown_salto
	_cambiar_modo(Modo.SALTO)


func _golpear() -> void:
	if target is CharacterBody2D:
		(target as CharacterBody2D).velocity = Vector2(empuje_zarpazo.x * facing, empuje_zarpazo.y)
	if target.has_method("knock_down"):
		target.knock_down()


func _agarrar() -> void:
	target.set_meta("agarrado_por", self)
	target.set_physics_process(false) # sin input ni física mientras lo tiene
	if target is CharacterBody2D:
		(target as CharacterBody2D).velocity = Vector2.ZERO
	_tiempo_en_suelo = 0.0
	_cambiar_modo(Modo.AGARRE)
	agarro_jugador.emit()


func _soltar() -> void:
	if is_instance_valid(target):
		target.set_physics_process(true)
		target.remove_meta("agarrado_por")
		if target is CharacterBody2D:
			(target as CharacterBody2D).velocity = Vector2(fuerza_tirada.x * facing, fuerza_tirada.y)
		if target.has_method("knock_down"):
			target.knock_down()
	solto_jugador.emit()
	_cambiar_modo(Modo.RECUPERACION)


# ---------- Utilidades ----------

func _cambiar_modo(nuevo: Modo) -> void:
	modo = nuevo
	_modo_timer = 0.0


func _volver_a_pasear() -> void:
	_cambiar_modo(Modo.PASEO)
	_nuevo_tramo_paseo()


func _mover_horizontal(dir_x: float, vel: float, delta: float) -> void:
	if dir_x != 0.0:
		velocity.x = move_toward(velocity.x, dir_x * vel, aceleracion * delta)
		facing = int(dir_x)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friccion * delta)


func _mirar_al_hornero() -> void:
	if not is_instance_valid(target):
		return
	var dx := target.global_position.x - global_position.x
	if absf(dx) > 1.0:
		facing = int(signf(dx))


func _boca() -> Vector2:
	return global_position + Vector2(offset_boca.x * facing, offset_boca.y)


func _dist() -> float:
	return global_position.distance_to(target.global_position)


func _hornero_disponible() -> bool:
	if not is_instance_valid(target):
		return false
	# Si otro gato ya lo tiene agarrado, no está disponible
	if target.has_meta("agarrado_por") and target.get_meta("agarrado_por") != self:
		return false
	if target is Hornero:
		var h := target as Hornero
		return h.state != Hornero.State.FALLING and h.state != Hornero.State.RECOVERING
	return true


func _hornero_en_suelo() -> bool:
	if target is CharacterBody2D:
		return (target as CharacterBody2D).is_on_floor()
	return false


func _paseo(delta: float) -> float:
	_paseo_timer -= delta
	if _paseo_timer <= 0.0:
		_nuevo_tramo_paseo()

	if _paseo_dir != 0 and is_on_floor():
		var pared_adelante := is_on_wall() and get_wall_normal().x * _paseo_dir < 0.0
		var borde_adelante := detectar_bordes and _hay_borde(_paseo_dir)
		if pared_adelante or borde_adelante:
			_paseo_dir = -_paseo_dir

	return float(_paseo_dir)


func _nuevo_tramo_paseo() -> void:
	if _paseo_dir != 0 and randf() < probabilidad_pausa:
		_paseo_dir = 0
		_paseo_timer = randf_range(tiempo_pausa_min, tiempo_pausa_max)
	else:
		_paseo_dir = [-1, 1].pick_random()
		_paseo_timer = randf_range(tiempo_caminar_min, tiempo_caminar_max)


func _hay_borde(dir: int) -> bool:
	_ray_borde.position = Vector2(dir * distancia_borde, 0)
	_ray_borde.force_raycast_update()
	return not _ray_borde.is_colliding()


func _draw() -> void:
	if not debug_draw:
		return
	draw_circle(Vector2(offset_boca.x * facing, offset_boca.y), radio_agarre, Color(1, 0, 0, 0.3))
	draw_line(Vector2.ZERO, Vector2(radio_zarpazo * facing, 0), Color.YELLOW, 2.0)


func _debug(delta: float) -> void:
	if not debug_print:
		return
	_debug_timer += delta
	if _debug_timer >= 0.5:
		_debug_timer = 0.0
		print(name, " modo: ", Modo.keys()[modo], " pos: ", global_position,
			" hornero en suelo: ", _hornero_en_suelo(), " disponible: ", _hornero_disponible())
