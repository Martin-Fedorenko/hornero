class_name BugSpawner
extends Node2D
## Reparte bichitos sobre las hojas de un Sprite2D (la copa de un árbol) y
## repone cada bicho comido pasado `respawn_time`.
##
## Los puntos se eligen al azar entre los píxeles verdes de la textura del
## sprite, metidos en el follaje y no en un borde.

const BUG_SCENE := preload("res://scenes/bicho.tscn")
## Distancia (px de la imagen) que se revisa alrededor de un punto para
## asegurarse de que está metido en el follaje y no en un borde.
const LEAF_MARGIN := 12
const MAX_TRIES := 400

static var _images := {}

## Sprite con la copa del árbol.
@export var sprite: Sprite2D
@export var bug_count := 3
## Segundos hasta reponer un bicho comido. 0 = no se repone.
@export var respawn_time := 25.0
## Distancia mínima entre bichos del mismo árbol (px en pantalla).
@export var bug_spacing := 70.0

var _bugs: Array[Bicho] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	# Espera a que el sprite tenga su textura y su transform finales.
	_spawn_all.call_deferred()


func _spawn_all() -> void:
	for i in bug_count:
		_spawn_bug()


func _spawn_bug() -> void:
	var spot: Variant = _random_leaf_spot()
	if spot == null:
		return
	var bug: Bicho = BUG_SCENE.instantiate()
	bug.tipo = (randi() % Bicho.Tipo.size()) as Bicho.Tipo
	bug.position = spot
	bug.eaten.connect(_on_bug_eaten.bind(bug))
	add_child(bug)
	_bugs.append(bug)


func _on_bug_eaten(bug: Bicho) -> void:
	_bugs.erase(bug)
	if respawn_time > 0.0:
		get_tree().create_timer(respawn_time, false).timeout.connect(_spawn_bug)


## Punto local al azar sobre hojas, lejos de los otros bichos. null si no
## encuentra lugar.
func _random_leaf_spot() -> Variant:
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
		if not _is_deep_leaf(image, pixel):
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


func _is_deep_leaf(image: Image, pixel: Vector2i) -> bool:
	for offset in [Vector2i.ZERO, Vector2i(LEAF_MARGIN, 0), Vector2i(-LEAF_MARGIN, 0),
			Vector2i(0, LEAF_MARGIN), Vector2i(0, -LEAF_MARGIN)]:
		if not _is_leaf(image.get_pixelv(pixel + offset)):
			return false
	return true


## Verde oliva de las hojas (rojo y verde parejos, poco azul); descarta el
## tronco y las ramas, que son marrones (bastante menos verde que rojo).
static func _is_leaf(color: Color) -> bool:
	return color.a > 0.9 and color.g > color.r * 0.9 and color.g > color.b * 1.6


static func _image(texture: Texture2D) -> Image:
	if not _images.has(texture):
		var image := texture.get_image()
		if image != null and image.is_compressed():
			image.decompress()
		_images[texture] = image
	return _images[texture]
