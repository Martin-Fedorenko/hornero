@tool
class_name Arbol
extends Node2D
## Árbol decorativo (sin collider) con bichitos posados en las hojas.
##
## El origen es la base del tronco: se apoya directo sobre la línea de suelo.
## Al jugar reparte `bug_count` bichos en puntos verdes de la copa elegidos
## al azar, y repone cada bicho comido pasado `respawn_time`.

enum Tipo { ANCHO, ALTO, INCLINADO, ESBELTO }

## Textura de cada tipo y x de la base del tronco dentro de ella (px).
const TEXTURES := [
	preload("res://assets/tree/arbol_1.png"),
	preload("res://assets/tree/arbol_2.png"),
	preload("res://assets/tree/arbol_3.png"),
	preload("res://assets/tree/arbol_4.png"),
]
const TRUNK_BASE_X := [283.0, 224.7, 144.0, 218.3]
## El tronco llega al borde inferior de la imagen: se lo hunde un poco en el
## pasto para que no se vea el corte.
const SINK := 6.0
const BUG_SCENE := preload("res://scenes/bicho.tscn")
## Distancia (px de la imagen) que se revisa alrededor de un punto para
## asegurarse de que está metido en el follaje y no en un borde.
const LEAF_MARGIN := 12
const MAX_TRIES := 400

static var _images := {}

@export var tipo := Tipo.ANCHO:
	set(value):
		tipo = value
		_update_sprite()
@export var tree_scale := 2.0:
	set(value):
		tree_scale = value
		_update_sprite()
@export var flip := false:
	set(value):
		flip = value
		_update_sprite()

@export_group("Bichos")
@export var bug_count := 3
## Segundos hasta reponer un bicho comido. 0 = no se repone.
@export var respawn_time := 25.0
## Distancia mínima entre bichos del mismo árbol (px en pantalla).
@export var bug_spacing := 70.0

var _sprite: Sprite2D
var _bugs: Array[Bicho] = []


func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.centered = false
	add_child(_sprite, false, Node.INTERNAL_MODE_FRONT)
	_update_sprite()
	if Engine.is_editor_hint():
		return
	for i in bug_count:
		_spawn_bug()


func _update_sprite() -> void:
	if _sprite == null:
		return
	var texture: Texture2D = TEXTURES[tipo]
	_sprite.texture = texture
	_sprite.flip_h = flip
	_sprite.scale = Vector2.ONE * tree_scale
	_sprite.position = _image_to_local(Vector2.ZERO) if not flip \
			else _image_to_local(Vector2(texture.get_width(), 0.0))


## Píxel de la imagen → posición local (origen en la base del tronco).
func _image_to_local(pixel: Vector2) -> Vector2:
	var texture: Texture2D = TEXTURES[tipo]
	var from_base := pixel - Vector2(TRUNK_BASE_X[tipo], texture.get_height() - SINK)
	if flip:
		from_base.x = -from_base.x
	return from_base * tree_scale


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
	var image := _image()
	if image == null:
		return null
	var size := image.get_size()
	for i in MAX_TRIES:
		var pixel := Vector2i(
				randi_range(LEAF_MARGIN, size.x - 1 - LEAF_MARGIN),
				randi_range(LEAF_MARGIN, size.y - 1 - LEAF_MARGIN))
		if not _is_deep_leaf(image, pixel):
			continue
		var spot := _image_to_local(Vector2(pixel))
		if _bugs.any(func(other: Bicho) -> bool: return other.position.distance_to(spot) < bug_spacing):
			continue
		return spot
	return null


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


func _image() -> Image:
	if not _images.has(tipo):
		var image: Image = TEXTURES[tipo].get_image()
		if image != null and image.is_compressed():
			image.decompress()
		_images[tipo] = image
	return _images[tipo]
