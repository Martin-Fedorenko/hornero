@tool
class_name Arbol
extends Node2D
## Árbol decorativo (sin collider) con bichitos posados en las hojas.
##
## El origen es la base del tronco: se apoya directo sobre la línea de suelo.
## Al jugar reparte `bug_count` bichos en puntos verdes de la copa elegidos
## al azar, y repone cada bicho comido pasado `respawn_time`.

enum Tipo { ANCHO, ALTO, INCLINADO, ESBELTO }

## Textura de cada tipo (recortadas de `tree_asset_new.png`) y x de la base
## del tronco dentro de ella (px).
const TEXTURES := [
	preload("res://assets/tree/arbol_hd_1.png"),
	preload("res://assets/tree/arbol_hd_2.png"),
	preload("res://assets/tree/arbol_hd_3.png"),
	preload("res://assets/tree/arbol_hd_4.png"),
]
const TRUNK_BASE_X := [473.4, 308.0, 263.9, 348.0]
## Las texturas tienen distinta resolución: esto las lleva a un alto parejo
## (el de los dibujos anteriores), así `tree_scale` significa lo mismo.
const TEXTURE_SCALE := [0.737, 0.859, 0.828, 0.981]
## El tronco llega al borde inferior de la imagen: se lo hunde un poco en el
## pasto para que no se vea el corte.
const SINK := 6.0

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
@export var bug_count := 5
## Segundos hasta reponer un bicho comido. 0 = no se repone.
@export var respawn_time := 25.0
## Distancia mínima entre bichos del mismo árbol (px en pantalla).
@export var bug_spacing := 70.0

var _sprite: Sprite2D


func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.centered = false
	add_child(_sprite, false, Node.INTERNAL_MODE_FRONT)
	_update_sprite()
	if Engine.is_editor_hint():
		return
	var bugs := BugSpawner.new()
	bugs.sprite = _sprite
	bugs.bug_count = bug_count
	bugs.respawn_time = respawn_time
	bugs.bug_spacing = bug_spacing
	add_child(bugs, false, Node.INTERNAL_MODE_BACK)


func _update_sprite() -> void:
	if _sprite == null:
		return
	var texture: Texture2D = TEXTURES[tipo]
	_sprite.texture = texture
	_sprite.flip_h = flip
	_sprite.scale = Vector2.ONE * _scale()
	_sprite.position = _image_to_local(Vector2.ZERO) if not flip \
			else _image_to_local(Vector2(texture.get_width(), 0.0))


## Píxel de la imagen → posición local (origen en la base del tronco).
func _image_to_local(pixel: Vector2) -> Vector2:
	var texture: Texture2D = TEXTURES[tipo]
	var from_base := pixel - Vector2(TRUNK_BASE_X[tipo], texture.get_height() - SINK)
	if flip:
		from_base.x = -from_base.x
	return from_base * _scale()


func _scale() -> float:
	return tree_scale * TEXTURE_SCALE[tipo]
