class_name GatoSpawner
extends Node2D
## Genera varios gatos repartidos a lo largo del mapa, apoyados en el suelo.

@export var escena_gato: PackedScene
@export var jugador: Node2D
@export var cantidad := 4
@export_group("Rango del mapa")
@export var x_inicio := 0.0
@export var x_fin := 5000.0
@export_group("Ubicación")
@export var distancia_minima_jugador := 400.0 # no aparece encima del Hornero
@export var altura_busqueda := 3000.0         # cuánto arriba y abajo busca el suelo
@export_flags_2d_physics var capa_suelo := 1  # capa de colisión del suelo
@export var offset_pies := 0.0                # subilo si el gato queda enterrado

func _ready() -> void:
	# Esperamos un frame de física para que el suelo esté registrado
	await get_tree().physics_frame
	spawnear()

func spawnear() -> void:
	if escena_gato == null:
		push_error("GatoSpawner: falta asignar la escena del gato")
		return
	var ancho_tramo := (x_fin - x_inicio) / cantidad
	for i in cantidad:
		var desde_x := x_inicio + ancho_tramo * i
		var x := _elegir_x(desde_x, desde_x + ancho_tramo)
		var suelo: Variant = _buscar_suelo(x)
		if suelo == null:
			push_warning("GatoSpawner: no encontré suelo en x = %d" % x)
			continue
		_crear_gato(suelo)

func _elegir_x(desde: float, hasta: float) -> float:
	# Hasta 10 intentos para no caer cerca del jugador
	var x := randf_range(desde, hasta)
	for intento in 10:
		if not is_instance_valid(jugador) \
				or absf(x - jugador.global_position.x) >= distancia_minima_jugador:
			break
		x = randf_range(desde, hasta)
	return x

func _buscar_suelo(x: float) -> Variant:
	var desde := Vector2(x, global_position.y - altura_busqueda)
	var hasta := Vector2(x, global_position.y + altura_busqueda)
	var query := PhysicsRayQueryParameters2D.create(desde, hasta, capa_suelo)
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
	return hit.position

func _crear_gato(punto_suelo: Vector2) -> void:
	var gato := escena_gato.instantiate() as Node2D
	# Posicionamos ANTES de agregarlo, así su _ready ya arranca en el lugar correcto
	gato.position = get_parent().to_local(punto_suelo - Vector2(0.0, offset_pies))
	if is_instance_valid(jugador) and "target" in gato:
		gato.target = jugador
	get_parent().add_child(gato)
