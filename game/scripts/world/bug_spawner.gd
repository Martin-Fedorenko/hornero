class_name BugSpawner
extends Node2D
## Reparte bichitos sobre las hojas y el tronco de un Sprite2D (un árbol) y
## cada tanto hace aparecer uno nuevo, hasta `max_bugs`.
##
## Los puntos se eligen al azar entre los píxeles verdes (hojas) o marrones
## (tronco) de la textura del sprite, metidos en la zona y no en un borde.

const BUG_SCENE := preload("res://scenes/bicho.tscn")
## Distancia (px de la imagen) que se revisa alrededor de un punto para
## asegurarse de que está metido en el follaje y no en un borde.
const LEAF_MARGIN := 12
const MAX_TRIES := 400

static var _images := {}

## Sprite con la copa del árbol.
@export var sprite: Sprite2D
## Bichos con los que arranca el árbol.
@export var bug_count := 3
## Tope de bichos a la vez en el árbol.
@export var max_bugs := 4
## Segundos (en promedio) entre la aparición de un bicho nuevo. 0 = no aparecen.
@export var spawn_interval := 60.0
## Probabilidad de que un bicho nuevo aparezca en el tronco en vez de las hojas.
@export_range(0.0, 1.0) var trunk_chance := 0.35
## Distancia mínima entre bichos del mismo árbol (px en pantalla).
@export var bug_spacing := 70.0

var _bugs: Array[Bicho] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	# Espera a que el sprite tenga su textura y su transform finales.
	_spawn_all.call_deferred()


func _spawn_all() -> void:
	for i in mini(bug_count, max_bugs):
		_spawn_bug(false)
	_schedule_spawn()


func _schedule_spawn() -> void:
	if spawn_interval <= 0.0:
		return
	var wait := spawn_interval * randf_range(0.9, 1.1)
	get_tree().create_timer(wait, false).timeout.connect(_on_spawn_timeout)


func _on_spawn_timeout() -> void:
	if _bugs.size() < max_bugs:
		_spawn_bug(true)
	_schedule_spawn()


## `pop`: aparece creciendo, para que se note que es nuevo.
func _spawn_bug(pop: bool) -> void:
	var on_trunk := randf() < trunk_chance
	var spot: Variant = _random_spot(on_trunk)
	if spot == null:
		spot = _random_spot(not on_trunk)
	if spot == null:
		return
	var bug: Bicho = BUG_SCENE.instantiate()
	bug.tipo = (randi() % Bicho.Tipo.size()) as Bicho.Tipo
	bug.position = spot
	bug.eaten.connect(_on_bug_eaten.bind(bug))
	add_child(bug)
	_bugs.append(bug)
	if pop:
		bug.scale = Vector2.ZERO
		bug.create_tween().tween_property(bug, ^"scale", Vector2.ONE, 0.35) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_bug_eaten(bug: Bicho) -> void:
	_bugs.erase(bug)


## Punto local al azar sobre hojas (o sobre el tronco), lejos de los otros
## bichos. null si no encuentra lugar.
func _random_spot(on_trunk: bool) -> Variant:
	if not is_instance_valid(sprite) or sprite.texture == null:
		return null
	var image := _image(sprite.texture)
	if image == null:
		return null
	var area := Rect2i(Vector2i.ZERO, image.get_size())
	if sprite.region_enabled:
		area = area.intersection(Rect2i(sprite.region_rect))
	area = area.grow(-LEAF_MARGIN)
	if area.size.x <= 0 or area.size.y <= 0:
		return null
	for i in MAX_TRIES:
		var pixel := Vector2i(
				randi_range(area.position.x, area.end.x - 1),
				randi_range(area.position.y, area.end.y - 1))
		if not _is_deep(image, pixel, on_trunk):
			continue
		var spot := _pixel_to_local(Vector2(pixel))
		if _bugs.any(func(other: Bicho) -> bool: return other.position.distance_to(spot) < bug_spacing):
			continue
		return spot
	return null


## Píxel de la textura → posición local de este nodo.
func _pixel_to_local(pixel: Vector2) -> Vector2:
	var point := pixel
	var size := sprite.texture.get_size()
	if sprite.region_enabled:
		point -= sprite.region_rect.position
		size = sprite.region_rect.size
	if sprite.flip_h:
		point.x = size.x - point.x
	if sprite.flip_v:
		point.y = size.y - point.y
	if sprite.centered:
		point -= size * 0.5
	point += sprite.offset
	return to_local(sprite.global_transform * point)


func _is_deep(image: Image, pixel: Vector2i, on_trunk: bool) -> bool:
	for offset in [Vector2i.ZERO, Vector2i(LEAF_MARGIN, 0), Vector2i(-LEAF_MARGIN, 0),
			Vector2i(0, LEAF_MARGIN), Vector2i(0, -LEAF_MARGIN)]:
		var color := image.get_pixelv(pixel + offset)
		if not (_is_bark(color) if on_trunk else _is_leaf(color)):
			return false
	return true


## Verde oliva de las hojas (rojo y verde parejos, poco azul); descarta el
## tronco y las ramas, que son marrones (bastante menos verde que rojo).
static func _is_leaf(color: Color) -> bool:
	return color.a > 0.9 and color.g > color.r * 0.9 and color.g > color.b * 1.6


## Marrón del tronco y las ramas: bastante más rojo que verde y azul, sin
## llegar a las sombras más oscuras.
static func _is_bark(color: Color) -> bool:
	return color.a > 0.9 and color.r > 0.2 and color.r > color.g * 1.15 and color.r > color.b * 1.4


static func _image(texture: Texture2D) -> Image:
	if not _images.has(texture):
		var image := texture.get_image()
		if image != null and image.is_compressed():
			image.decompress()
		_images[texture] = image
	return _images[texture]
