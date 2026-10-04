class_name GatoMontes
extends CharacterBody2D

signal agarro_jugador
signal solto_jugador

enum Modo { PASEO, PERSECUCION, ZARPAZO, SALTO, AGARRE, RECUPERACION, RETIRADA }

@export var target: Node2D # Hornero (si queda vacío, lo busca solo)
@export var debug_print := false
@export var debug_draw := false # dibuja la boca, el zarpazo y la altura de salto

@export_group("Inicio")
@export var acomodar_al_piso := true        # al arrancar, lo apoya sobre el piso de abajo
@export var margen_busqueda_arriba := 40.0  # por si quedó un poco metido en el piso
@export var distancia_busqueda_abajo := 2000.0

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
@export var momento_golpe := 0.4            # antes de esto el Hornero puede escapar volando
@export var empuje_zarpazo := Vector2(250, -150)

@export_group("Salto")
@export var altura_salto_max := 300.0       # cuánto puede subir como máximo
@export var altura_salto_min := 60.0
@export var margen_salto := 20.0            # sube un poco más de lo justo
@export var velocidad_salto_x := 500.0      # velocidad horizontal máxima en el salto
@export_range(0.0, 1.0) var anticipacion_salto := 0.8 # 0 = apunta a donde está, 1 = predice
@export var offset_boca := Vector2(10, -30) # solo se usa si no existe el Marker2D "Boca"
@export var cooldown_salto := 1.0

@export_group("Agarre")
@export var tiempo_sujetar := 0.35          # lo sostiene en el piso antes de tirarlo
@export var fuerza_tirada := Vector2(200, 100)
@export var tiempo_max_agarre := 3.0        # seguridad por si nunca aterriza

@export_group("Recuperación")
@export var duracion_recuperacion := 1.5    # después de un ataque fallido

@export_group("Retirada")
@export var retirarse_tras_golpe := true    # después de pegar, se va caminando para el otro lado
@export var duracion_retirada := 3.0        # cuánto camina alejándose antes de volver a pasear
@export var velocidad_retirada := 90.0

@export_group("Grupo")
@export var max_perseguidores := 1          # cuántos gatos pueden atacar a la vez (1 = de a uno)
@export var distancia_separacion := 120.0   # se alejan si otro gato está más cerca que esto
@export var variacion_velocidad := 0.15     # cada gato es hasta 15% más rápido o lento

@export_group("Sonido")
## Suena cuando descubre al Hornero y sale a cazarlo.
@export var sonido_deteccion: AudioStream
## Cada tanto maúlla uno de estos al azar.
@export var maullidos: Array[AudioStream] = []
## Maullido especial que muy de vez en cuando reemplaza al común.
@export var maullido_raro: AudioStream
@export var intervalo_maullido := 5.0
@export_range(0.0, 1.0, 0.0001) var probabilidad_raro := 0.001

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
var _golpe_conecto := false
var _dir_retirada := 1
var _tiempo_en_suelo := 0.0
var _debug_timer := 0.0
var _acomodado := false
var _mult_vel := 1.0
var _ray_borde: RayCast2D
var _colision: CollisionShape2D
var _salto_vel := Vector2.ZERO  # salto calculado por _puede_saltar()
var _salto_facing := 1
var _maullido_timer := 0.0
@onready var _voz: AudioStreamPlayer2D = get_node_or_null("Voz")

@onready var _marker_boca: Marker2D = get_node_or_null("Boca")


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

	# Forma de colisión propia, para detectar contacto real con el Hornero
	for hijo in get_children():
		if hijo is CollisionShape2D:
			_colision = hijo
			break
	if _colision == null:
		push_warning("GatoMontes: no encontré un CollisionShape2D hijo")

	if not _marker_boca:
		push_warning("%s: no tiene Marker2D 'Boca', usa Offset Boca" % name)

	_ray_borde = RayCast2D.new()
	_ray_borde.target_position = Vector2(0, largo_rayo_borde)
	_ray_borde.collision_mask = collision_mask
	_ray_borde.add_exception(self)
	add_child(_ray_borde)

	facing = [-1, 1].pick_random()
	_paseo_dir = facing
	_paseo_timer = randf_range(tiempo_caminar_min, tiempo_caminar_max)
	# Desfasado para que los gatos no maúllen todos a la vez
	_maullido_timer = randf_range(0.0, intervalo_maullido)
	_mult_vel = randf_range(1.0 - variacion_velocidad, 1.0 + variacion_velocidad)


func _exit_tree() -> void:
	# Si el gato desaparece con el Hornero en la boca, lo libera
	if modo == Modo.AGARRE and is_instance_valid(target):
		target.set_physics_process(true)
		target.remove_meta("agarrado_por")


func _physics_process(delta: float) -> void:
	# En el primer frame de física ya se puede consultar el mundo
	if not _acomodado:
		_acomodado = true
		if acomodar_al_piso:
			_acomodar_al_piso()

	if not is_on_floor():
		velocity.y += gravedad * delta
	_modo_timer += delta
	_cooldown_salto_timer = maxf(_cooldown_salto_timer - delta, 0.0)
	_maullar_cada_tanto(delta)

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
		Modo.RETIRADA:
			_proc_retirada(delta)

	move_and_slide()

	if modo == Modo.AGARRE and is_instance_valid(target):
		var pos := _boca()
		if is_on_floor():
			# Que no quede enterrado mientras lo sujeta en el piso
			pos.y = minf(pos.y, _y_hornero_en_piso())
		target.global_position = pos

	if debug_draw:
		queue_redraw()
	_debug(delta)


# ---------- Modos ----------

func _proc_paseo(delta: float) -> void:
	if _cupo_para_perseguir():
		# Caso 1: el Hornero lo sobrevuela a una distancia alcanzable
		if _puede_saltar():
			_iniciar_salto()
			return
		if _hornero_disponible() and _hornero_en_suelo() and _dist() < radio_deteccion:
			_cambiar_modo(Modo.PERSECUCION)
			_memoria_timer = tiempo_memoria
			return

	var dir := _paseo(delta)
	var sep := _dir_separacion()
	if sep != 0.0 and not (detectar_bordes and is_on_floor() and _hay_borde(int(sep))):
		dir = sep
		_paseo_dir = int(sep)
	_mover_horizontal(dir, velocidad_caminar, delta)


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
		_golpe_conecto = false
		_cambiar_modo(Modo.ZARPAZO)
		return
	# Caso 2: lo venía persiguiendo y el Hornero levantó vuelo
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
				_golpe_conecto = true

	if _modo_timer >= duracion_zarpazo:
		if _golpe_conecto:
			_iniciar_retirada()
		else:
			_cambiar_modo(Modo.RECUPERACION) # falló


func _proc_salto() -> void:
	# En el aire no se dirige: conserva el impulso del salto.
	# Solo lo agarra si los cuerpos se tocan de verdad.
	if _hornero_disponible() and _toca_al_hornero():
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
	# Después de un ataque fallido: se aleja del Hornero, o de otro gato si tiene uno encima
	var dir_x := 0.0
	if is_instance_valid(target):
		dir_x = -signf(target.global_position.x - global_position.x)
	var sep := _dir_separacion()
	if sep != 0.0:
		dir_x = sep
	if dir_x != 0.0 and detectar_bordes and is_on_floor() and _hay_borde(int(dir_x)):
		dir_x = 0.0
	_mover_horizontal(dir_x, velocidad_caminar, delta)
	if _modo_timer >= duracion_recuperacion:
		_volver_a_pasear()


func _proc_retirada(delta: float) -> void:
	# Después de pegar: camina para el otro lado sin atacar
	var dir_x := float(_dir_retirada)
	if is_on_floor():
		var pared := is_on_wall() and get_wall_normal().x * _dir_retirada < 0.0
		if pared or (detectar_bordes and _hay_borde(_dir_retirada)):
			dir_x = 0.0 # no puede seguir: espera ahí en vez de volver
	_mover_horizontal(dir_x, velocidad_retirada, delta)
	if _modo_timer >= duracion_retirada:
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
	_salto_vel = _planear_salto()
	return _salto_vel != Vector2.ZERO


## Calcula el salto para que la boca llegue a donde VA a estar el Hornero
## en el punto más alto. Devuelve Vector2.ZERO si no le alcanza.
func _planear_salto() -> Vector2:
	var vel_obj := Vector2.ZERO
	if target is CharacterBody2D:
		vel_obj = (target as CharacterBody2D).velocity

	var boca := _boca_derecha()
	var objetivo := target.global_position
	var vy := 0.0
	var t := 0.0
	# Dos pasadas: la altura define el tiempo, y el tiempo define dónde va a estar
	for i in 2:
		var subida := global_position.y - objetivo.y + boca.y + margen_salto
		if subida > altura_salto_max:
			return Vector2.ZERO # muy alto
		subida = maxf(subida, altura_salto_min)
		vy = -sqrt(2.0 * gravedad * subida)
		t = -vy / gravedad # tiempo hasta el punto más alto
		objetivo = target.global_position + vel_obj * t * anticipacion_salto

	if objetivo.y >= global_position.y:
		return Vector2.ZERO # no está por encima del gato

	var dir := signf(objetivo.x - global_position.x)
	if dir == 0.0:
		dir = float(facing)
	var dx := objetivo.x - (global_position.x + boca.x * dir)
	var vx := dx / t
	if absf(vx) > velocidad_salto_x:
		return Vector2.ZERO # muy lejos

	_salto_facing = int(dir)
	return Vector2(vx, vy)


func _iniciar_salto() -> void:
	velocity = _salto_vel
	facing = _salto_facing
	_cooldown_salto_timer = cooldown_salto
	_cambiar_modo(Modo.SALTO)


## Contacto real: ¿la forma de colisión del gato se superpone con el Hornero?
func _toca_al_hornero() -> bool:
	if _colision == null or _colision.shape == null:
		return false
	if not (target is CollisionObject2D):
		return false
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _colision.shape
	query.transform = _colision.global_transform
	query.collision_mask = (target as CollisionObject2D).collision_layer
	query.exclude = [get_rid()]
	for hit in get_world_2d().direct_space_state.intersect_shape(query, 8):
		if hit.collider == target:
			return true
	return false


## Le saca vida al Hornero igual que el Chimango: take_grab_hit() resta la vida
## y lo tira; si no existe, solo lo tira con knock_down().
func _danar_hornero() -> void:
	if target.has_method("take_grab_hit"):
		target.take_grab_hit()
	elif target.has_method("knock_down"):
		target.knock_down()


func _golpear() -> void:
	if target is CharacterBody2D:
		(target as CharacterBody2D).velocity = Vector2(empuje_zarpazo.x * facing, empuje_zarpazo.y)
	_danar_hornero()


func _agarrar() -> void:
	target.set_meta("agarrado_por", self)
	target.set_physics_process(false) # sin input ni física mientras lo tiene
	if target is CharacterBody2D:
		(target as CharacterBody2D).velocity = Vector2.ZERO
	# Igual que el Chimango: queda en estado de caída mientras lo tiene,
	# así ningún otro enemigo puede agarrarlo
	if target is Hornero:
		(target as Hornero).knock_down()
	_tiempo_en_suelo = 0.0
	_cambiar_modo(Modo.AGARRE)
	agarro_jugador.emit()


func _soltar() -> void:
	if is_instance_valid(target):
		if is_on_floor():
			# Lo apoya sobre el piso antes de devolverle la física
			target.global_position.y = minf(target.global_position.y, _y_hornero_en_piso())
		target.set_physics_process(true)
		target.remove_meta("agarrado_por")
		if target is CharacterBody2D:
			(target as CharacterBody2D).velocity = Vector2(fuerza_tirada.x * facing, fuerza_tirada.y)
		_danar_hornero()
	solto_jugador.emit()
	_iniciar_retirada()


## Después de un golpe exitoso se va caminando para el lado contrario al Hornero.
func _iniciar_retirada() -> void:
	if not retirarse_tras_golpe:
		_cambiar_modo(Modo.RECUPERACION)
		return
	var dir := -facing
	if is_instance_valid(target):
		var dx := target.global_position.x - global_position.x
		if absf(dx) > 1.0:
			dir = -int(signf(dx))
	_dir_retirada = dir
	facing = dir
	_cambiar_modo(Modo.RETIRADA)


# ---------- Grupo ----------

func _esta_atacando() -> bool:
	return modo in [Modo.PERSECUCION, Modo.ZARPAZO, Modo.SALTO, Modo.AGARRE]


func _cupo_para_perseguir() -> bool:
	var n := 0
	for g in get_tree().get_nodes_in_group("gatos"):
		if g != self and g is GatoMontes and (g as GatoMontes)._esta_atacando():
			n += 1
	return n < max_perseguidores


# Hacia dónde alejarse del gato más cercano (0 si no hay ninguno cerca)
func _dir_separacion() -> float:
	var mas_cerca: Node2D = null
	var mejor := distancia_separacion
	for g in get_tree().get_nodes_in_group("gatos"):
		if g == self or not g is Node2D:
			continue
		var otro := g as Node2D
		if absf(otro.global_position.y - global_position.y) > 80.0:
			continue # está en otra plataforma
		var d := absf(otro.global_position.x - global_position.x)
		if d < mejor:
			mejor = d
			mas_cerca = otro
	if mas_cerca == null:
		return 0.0
	var dx := global_position.x - mas_cerca.global_position.x
	if dx == 0.0:
		# Si están exactamente encima, se separan para lados opuestos
		return 1.0 if get_instance_id() > mas_cerca.get_instance_id() else -1.0
	return signf(dx)


# ---------- Piso ----------

func _acomodar_al_piso() -> void:
	var space := get_world_2d().direct_space_state
	var desde := global_position + Vector2(0, -margen_busqueda_arriba)
	var hasta := global_position + Vector2(0, distancia_busqueda_abajo)
	var q := PhysicsRayQueryParameters2D.create(desde, hasta, collision_mask)

	var excluir: Array[RID] = [get_rid()]
	for g in get_tree().get_nodes_in_group("gatos"):
		if g is CollisionObject2D:
			excluir.append((g as CollisionObject2D).get_rid())
	if target is CollisionObject2D:
		excluir.append((target as CollisionObject2D).get_rid())
	q.exclude = excluir

	var hit := space.intersect_ray(q)
	if hit.is_empty():
		push_warning("%s: no encontró piso debajo para acomodarse" % name)
		return
	global_position.y = hit.position.y - _borde_inferior(self)
	velocity = Vector2.ZERO


# Distancia desde el origen de un nodo hasta la base de su colisión
func _borde_inferior(nodo: Node2D) -> float:
	for c in nodo.get_children():
		if c is CollisionShape2D and c.shape and not c.disabled:
			var r: Rect2 = c.shape.get_rect()
			return (r.end.y * c.scale.y + c.position.y) * nodo.scale.y
	return 0.0


# Y donde tiene que quedar el Hornero para estar parado sobre el piso del gato
func _y_hornero_en_piso() -> float:
	var piso_y := global_position.y + _borde_inferior(self)
	return piso_y - _borde_inferior(target)


# ---------- Utilidades ----------

func _cambiar_modo(nuevo: Modo) -> void:
	# Descubrió al Hornero: deja de pasear y sale a perseguirlo o a saltarle
	if modo == Modo.PASEO and (nuevo == Modo.PERSECUCION or nuevo == Modo.SALTO):
		_sonar(sonido_deteccion)
	modo = nuevo
	_modo_timer = 0.0


# ---------- Sonido ----------

func _maullar_cada_tanto(delta: float) -> void:
	_maullido_timer -= delta
	if _maullido_timer > 0.0:
		return
	_maullido_timer = intervalo_maullido
	# Si todavía está sonando otra cosa (el enojo, por ejemplo), espera al próximo
	if _voz == null or _voz.playing:
		return
	if maullido_raro != null and randf() < probabilidad_raro:
		_sonar(maullido_raro)
	elif not maullidos.is_empty():
		_sonar(maullidos.pick_random())


func _sonar(sonido: AudioStream) -> void:
	if _voz == null or sonido == null:
		return
	_voz.stream = sonido
	_voz.play()


func _volver_a_pasear() -> void:
	_cambiar_modo(Modo.PASEO)
	_nuevo_tramo_paseo()


func _mover_horizontal(dir_x: float, vel: float, delta: float) -> void:
	if dir_x != 0.0:
		velocity.x = move_toward(velocity.x, dir_x * vel * _mult_vel, aceleracion * delta)
		facing = int(dir_x)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friccion * delta)


func _mirar_al_hornero() -> void:
	if not is_instance_valid(target):
		return
	var dx := target.global_position.x - global_position.x
	if absf(dx) > 1.0:
		facing = int(signf(dx))


# Posición de la boca relativa al gato, mirando a la derecha.
# Usa el Marker2D "Boca" si existe; si no, Offset Boca.
func _boca_derecha() -> Vector2:
	var o := offset_boca
	if _marker_boca:
		o = _marker_boca.position
	return Vector2(absf(o.x), o.y)


func _offset_boca_local() -> Vector2:
	var o := _boca_derecha()
	return Vector2(o.x * facing, o.y)


func _boca() -> Vector2:
	return global_position + _offset_boca_local()


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
		# Adentro del nido techado está a salvo
		return h.state != Hornero.State.FALLING and h.state != Hornero.State.RECOVERING \
			and h.state != Hornero.State.DEAD and not h.sheltered
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
	# Punto donde queda el Hornero agarrado
	draw_circle(_offset_boca_local(), 6.0, Color(1, 0, 0, 0.8))
	draw_line(Vector2.ZERO, Vector2(radio_zarpazo * facing, 0), Color.YELLOW, 2.0)
	# Altura máxima de salto
	draw_line(Vector2(-40, -altura_salto_max), Vector2(40, -altura_salto_max), Color.GREEN, 2.0)


func _debug(delta: float) -> void:
	if not debug_print:
		return
	_debug_timer += delta
	if _debug_timer >= 0.5:
		_debug_timer = 0.0
		print(name, " modo: ", Modo.keys()[modo], " pos: ", global_position,
			" hornero en suelo: ", _hornero_en_suelo(), " disponible: ", _hornero_disponible())
