extends Node
## Hijo directo de Hornero. Sustituye COMPLETAMENTE la versión con Tween.
@export var alcance: float = 80.0
@export var debug_logs: bool = true
@export var mostrar_puntos: bool = false
@export var usar_pico_automatico: bool = true
@export var intervalo_logs: float = 0.75
@export var escala_picoteo: float = 0.19

const CUADROS: SpriteFrames = preload("res://objetos_hornero/picoteo_frames.tres")
const DEBUG_PICO = preload("res://objetos_hornero/debug_pico.gd")
# Puntas del pico en coordenadas locales de cada nuevo cuadro (640x640).
const PICOS: Array[Vector2] = [
	Vector2(205,-25), Vector2(190,87), Vector2(133,188),
	Vector2(157,207), Vector2(182,108), Vector2(191,-26)]

var objeto: RigidBody2D = null
var ocupado: bool = false
var _reloj: float = 0.0
var _picos_cache: Dictionary = {}
var _imagenes_cache: Dictionary = {}
var _debug: Node2D
var _interpolacion_original: int = 0
@onready var hornero: CharacterBody2D = get_parent() as CharacterBody2D
@onready var sprite: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D")

func _ready() -> void:
	process_priority = 100
	if not InputMap.has_action(&"hornero_interactuar"):
		InputMap.add_action(&"hornero_interactuar")
		var tecla := InputEventKey.new()
		tecla.physical_keycode = KEY_E
		InputMap.action_add_event(&"hornero_interactuar", tecla)
	# Añadir la animación sin sustituir vuelo, caminar, planeo ni reposo.
	sprite.sprite_frames = sprite.sprite_frames.duplicate() as SpriteFrames
	if sprite.sprite_frames.has_animation(&"picotear"):
		sprite.sprite_frames.remove_animation(&"picotear")
	sprite.sprite_frames.add_animation(&"picotear")
	sprite.sprite_frames.set_animation_loop(&"picotear", false)
	sprite.sprite_frames.set_animation_speed(&"picotear", 11.0)
	for i in range(CUADROS.get_frame_count(&"picotear")):
		sprite.sprite_frames.add_frame(&"picotear", CUADROS.get_frame_texture(&"picotear", i))
	_debug = Node2D.new()
	_debug.set_script(DEBUG_PICO)
	_debug.name = "DiagnosticoPico"
	hornero.add_child.call_deferred(_debug)
	_debug.top_level = true
	_debug.z_index = 100
	_log("INICIO | E = recoger/soltar. L = una muestra de diagnóstico.")
	_log("Pico automático=%s. Verde=pico usado; rosa=Marker2D; amarillo=objeto." % usar_pico_automatico)
	sprite.animation_changed.connect(_diagnosticar_cambio_animacion)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"hornero_interactuar") and not event.is_echo():
		interactuar()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_L:
		_imprimir_estado("MANUAL", _error_actual())

func _process(delta: float) -> void:
	# NO mover sprite.position: el gesto ahora está dibujado en los cuadros.
	var error_antes := _error_actual()
	_seguir_pico()
	if is_instance_valid(_debug) and _debug.is_inside_tree():
		_debug.global_transform = Transform2D.IDENTITY
		_debug.visible = mostrar_puntos
		_debug.set("pico", _posicion_pico())
		_debug.set("hay_objeto", is_instance_valid(objeto))
		if is_instance_valid(objeto):
			_debug.set("objeto", objeto.global_position)
		var marker := _marcador()
		_debug.set("hay_marcador", marker != null and sprite.animation != &"picotear")
		if marker != null:
			_debug.set("marcador", _transformar_punto(marker.position))
		_debug.queue_redraw()
	_reloj += delta
	if is_instance_valid(objeto) and _reloj >= maxf(intervalo_logs, 0.25):
		_reloj = 0.0
		_imprimir_estado("SEGUIMIENTO", error_antes)

func _marcador() -> Marker2D:
	var nombre := "PicoCaminar" if sprite.animation == &"caminar" else "Pico"
	return sprite.get_node_or_null(nombre) as Marker2D

func _transformar_punto(punto_local: Vector2) -> Vector2:
	if sprite.flip_h:
		punto_local.x = -punto_local.x
	if sprite.flip_v:
		punto_local.y = -punto_local.y
	return sprite.to_global(punto_local)

func _posicion_pico() -> Vector2:
	if sprite.animation == &"picotear":
		return _transformar_punto(PICOS[clampi(sprite.frame, 0, 5)] + sprite.offset)
	if usar_pico_automatico:
		var textura := sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
		if textura != null:
			var punto := _punta_textura(textura)
			if sprite.centered:
				punto -= textura.get_size() * 0.5
			return _transformar_punto(punto + sprite.offset)
	var marker := _marcador()
	if marker != null:
		return _transformar_punto(marker.position)
	return sprite.global_position

func _punta_textura(textura: Texture2D) -> Vector2:
	# Estas hojas miran a la derecha: la punta del pico es su extremo opaco derecho.
	# AtlasTexture requiere sumar margin.position; no basta con dividir la hoja.
	var clave := textura.get_instance_id()
	if _picos_cache.has(clave):
		return _picos_cache[clave]
	var fuente: Texture2D = textura
	var region := Rect2i(Vector2i.ZERO, Vector2i(textura.get_size()))
	var margen := Vector2.ZERO
	if textura is AtlasTexture:
		fuente = textura.atlas
		region = Rect2i(textura.region)
		margen = textura.margin.position
	var id_imagen := fuente.get_instance_id()
	if not _imagenes_cache.has(id_imagen):
		var nueva := fuente.get_image()
		if nueva != null and nueva.is_compressed():
			nueva.decompress()
		_imagenes_cache[id_imagen] = nueva
	var imagen: Image = _imagenes_cache[id_imagen]
	if imagen != null:
		region = region.intersection(Rect2i(Vector2i.ZERO, imagen.get_size()))
		for x in range(region.end.x - 1, region.position.x - 1, -1):
			var suma_y: float = 0.0
			var cantidad: int = 0
			for y in range(region.position.y, region.end.y):
				if imagen.get_pixel(x,y).a > 0.5:
					suma_y += y + 0.5
					cantidad += 1
			if cantidad > 0:
				var resultado := Vector2(x + 0.5, suma_y / cantidad) - Vector2(region.position) + margen
				_picos_cache[clave] = resultado
				return resultado
	var fallback := textura.get_size() * 0.5
	_picos_cache[clave] = fallback
	_log("AVISO: textura sin píxeles opacos; revisar imagen o usar Marker2D.")
	return fallback

func _seguir_pico() -> void:
	if is_instance_valid(objeto):
		objeto.global_position = _posicion_pico()
		objeto.global_rotation = 0.0

func _error_actual() -> float:
	if not is_instance_valid(objeto):
		return 0.0
	return objeto.global_position.distance_to(_posicion_pico())

func _objeto_cercano() -> RigidBody2D:
	var mejor: RigidBody2D = null
	var menor := alcance
	for candidato in get_tree().get_nodes_in_group(&"levantables"):
		if not candidato is RigidBody2D:
			continue
		if not candidato.has_method("recoger") or not candidato.has_method("soltar"):
			continue
		if candidato.get("recogida") == true:
			continue
		var distancia := hornero.global_position.distance_to(candidato.global_position)
		if distancia < menor and _visible(candidato):
			mejor = candidato
			menor = distancia
	return mejor

func _visible(candidato: RigidBody2D) -> bool:
	var query := PhysicsRayQueryParameters2D.create(
		hornero.global_position, candidato.global_position, 1,
		[hornero.get_rid(), candidato.get_rid()])
	return hornero.get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func interactuar() -> void:
	if ocupado:
		return
	ocupado = true
	var posicion_hornero_inicio := hornero.global_position
	var procesaba := hornero.is_physics_processing()
	var animacion_anterior := sprite.animation
	var cuadro_anterior := sprite.frame
	var progreso_anterior := sprite.frame_progress
	var reproducia := sprite.is_playing()
	var procesaba_sprite := sprite.is_processing()
	var escala_anterior := sprite.scale
	var rotacion_anterior := sprite.rotation
	var centrado_anterior := sprite.centered
	var offset_anterior := sprite.offset
	# Reservar 0.61 s para el gesto: evita que hornero.gd pise la animación.
	hornero.set_physics_process(false)
	# El animador del sprite corre en _process y sobrescribe los cuadros del picoteo.
	sprite.set_process(false)
	hornero.velocity = Vector2.ZERO
	_log("POSICION_HORNERO | inicio=%s" % posicion_hornero_inicio)
	var candidato := _objeto_cercano() if not is_instance_valid(objeto) else null
		# La dirección la controla hornero.facing y la rotación del cuerpo.
	sprite.flip_h = false
	sprite.stop()
	sprite.animation = &"picotear"
	sprite.centered = true
	sprite.offset = Vector2.ZERO
		# Compensar el giro del cuerpo cuando mira hacia la izquierda.
	var signo_vertical := -1.0 if int(hornero.get("facing")) < 0 else 1.0
	sprite.scale = Vector2(escala_picoteo, escala_picoteo * signo_vertical)
	if hornero.is_on_floor():
		sprite.rotation = 0.0
	_log("PICOTEO | inicio; objetivo=%s" % (candidato.name if candidato != null else "ninguno / soltar"))
	# Cuadros reales, sin Tween ni desplazamiento de sprite.position.
	for i in range(6):
		sprite.frame = i
		if i == 3:
			_accion_en_contacto()
		_seguir_pico()
		await get_tree().create_timer(0.08 if i == 3 else 0.0045, false).timeout
		_log("POSICION_HORNERO | frame=%d global=%s delta=%s" % [
			i, hornero.global_position, hornero.global_position - posicion_hornero_inicio])
	sprite.scale = escala_anterior
	sprite.rotation = rotacion_anterior
	sprite.centered = centrado_anterior
	sprite.offset = offset_anterior
	sprite.animation = animacion_anterior
	sprite.set_frame_and_progress(cuadro_anterior, progreso_anterior)
	if reproducia:
		sprite.play()
	sprite.set_process(procesaba_sprite)
	_seguir_pico()
	_log("POSICION_HORNERO | fin=%s delta_total=%s" % [
		hornero.global_position, hornero.global_position - posicion_hornero_inicio])
	ocupado = false
	hornero.set_physics_process(procesaba)
	_imprimir_estado("FIN_PICOTEO", _error_actual())

func _accion_en_contacto() -> void:
	if is_instance_valid(objeto):
		var lado := -1.0 if sprite.flip_h else 1.0
		var destino := _posicion_pico() + Vector2(24.0*lado, -12.0).rotated(sprite.global_rotation)
		var query := PhysicsRayQueryParameters2D.create(
			hornero.global_position, destino, 1, [hornero.get_rid(), objeto.get_rid()])
		var hit := hornero.get_world_2d().direct_space_state.intersect_ray(query)
		if not hit.is_empty():
			destino = hit["position"] + hit["normal"] * 12.0
		_log("SOLTAR | %s -> %s" % [objeto.name, destino])
		objeto.call("soltar", destino)
		objeto.physics_interpolation_mode = _interpolacion_original
		objeto.reset_physics_interpolation()
		objeto = null
		return
	var cercano := _objeto_cercano()
	if cercano == null:
		_log("SIN_OBJETO | ningún levantable visible dentro de %.1f px" % alcance)
		return
	objeto = cercano
	_interpolacion_original = objeto.physics_interpolation_mode
	objeto.call("recoger")
	# Asegurar que la simulación no desplace una carga sostenida.
	objeto.freeze = true
	objeto.linear_velocity = Vector2.ZERO
	objeto.angular_velocity = 0.0
	objeto.collision_layer = 0
	objeto.collision_mask = 0
	objeto.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	_seguir_pico()
	objeto.reset_physics_interpolation()
	_imprimir_estado("RECOGER", _error_actual())
	for hijo in objeto.get_children():
		if hijo is Node2D:
			_log("HIJO_OBJETO | %s tipo=%s posicion_local=%s escala=%s" % [hijo.name, hijo.get_class(), hijo.position, hijo.scale])

func _imprimir_estado(evento: String, error_antes: float) -> void:
	if not debug_logs:
		return
	var marker := _marcador()
	var pos_marker: String = str(marker.position) if marker != null else "no existe"
	var fuente := "cuadro_picoteo" if sprite.animation == &"picotear" else ("auto_contorno" if usar_pico_automatico else "Marker2D")
	var pos_obj := str(objeto.global_position) if is_instance_valid(objeto) else "ninguno"
	print("[PICO][%s] fuente=%s anim=%s frame=%d flip_h=%s escala=%s offset=%s centrado=%s" % [evento, fuente, sprite.animation, sprite.frame, sprite.flip_h, sprite.scale, sprite.offset, sprite.centered])
	print("  pico_global=%s objeto_global=%s error_antes=%.2fpx error_ahora=%.2fpx marcador_local=%s" % [_posicion_pico(), pos_obj, error_antes, _error_actual(), pos_marker])
	if marker != null and sprite.animation != &"picotear":
		print("  marcador_global=%s distancia_marcador_al_pico=%.2fpx" % [_transformar_punto(marker.position), _transformar_punto(marker.position).distance_to(_posicion_pico())])
	if is_instance_valid(objeto):
		print("  freeze=%s velocidad=%s layer=%d mask=%d" % [objeto.freeze, objeto.linear_velocity, objeto.collision_layer, objeto.collision_mask])

func _log(texto: String) -> void:
	if debug_logs:
		print("[PICO] " + texto)
		
func _diagnosticar_cambio_animacion() -> void:
	if not ocupado:
		return

	print(
		"[ANIMACION DURANTE INTERACCION] anim=",
		sprite.animation,
		" | frame=", sprite.frame,
		" | facing=", hornero.get("facing"),
		" | rotacion_cuerpo=", hornero.rotation_degrees,
		" | flip_h=", sprite.flip_h,
		" | escala=", sprite.scale
	)

	if sprite.animation != &"picotear":
		print("[PICOTEO INTERRUMPIDO] Revisar esta pila de llamadas:")
		print_stack()
