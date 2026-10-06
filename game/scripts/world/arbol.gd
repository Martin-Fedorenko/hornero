@tool
class_name Arbol
extends Node2D
## Árbol decorativo (sin collider) con bichitos posados en las hojas.
##
## El origen es la base del tronco: se apoya directo sobre la línea de suelo.
## Al jugar reparte `bug_count` bichos en las hojas y el tronco, y cada tanto
## (`spawn_interval`) aparece uno nuevo, hasta `max_bugs`.

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
@export var bug_count := 2
## Tope de bichos a la vez en el árbol.
@export var max_bugs := 4
## Segundos (en promedio) entre la aparición de un bicho nuevo. 0 = no aparecen.
@export var spawn_interval := 60.0
## Probabilidad de que un bicho nuevo aparezca en el tronco en vez de las hojas.
@export_range(0.0, 1.0) var trunk_chance := 0.35
## Distancia mínima entre bichos del mismo árbol (px en pantalla).
@export var bug_spacing := 70.0

@export_group("Ramitas")
## Ramitas apoyadas en las ramas, para agarrarlas volando. Cada partida van
## en un lugar distinto.
@export_range(0, 3) var ramitas := 0
## Fracción del alto del árbol, desde la copa, donde pueden ir: así quedan
## arriba, en las ramas, y no en la base del tronco.
@export_range(0.1, 1.0) var ramitas_altura := 0.6

const RAMITAS_SCENE := preload("res://objetos_hornero/ramitas.tscn")

var _sprite: Sprite2D
var _bugs: BugSpawner


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
	bugs.max_bugs = max_bugs
	bugs.spawn_interval = spawn_interval
	bugs.trunk_chance = trunk_chance
	bugs.bug_spacing = bug_spacing
	add_child(bugs, false, Node.INTERNAL_MODE_BACK)
	_bugs = bugs
	# Como los bichos: espera a que el sprite tenga su transform final.
	_poner_ramitas.call_deferred()


## Cada ramita va sobre una rama (o, si no hay lugar, entre las hojas). Se
## agregan a la escena, junto a los demás levantables, para que se dibujen
## delante del árbol.
func _poner_ramitas() -> void:
	var escena := get_tree().current_scene
	var destino: Node = escena if escena != null else get_parent()
	for i in ramitas:
		var spot: Variant = _bugs.random_spot_on_top(true, ramitas_altura)
		if spot == null:
			spot = _bugs.random_spot_on_top(false, ramitas_altura)
		if spot == null:
			continue
		var ramita := RAMITAS_SCENE.instantiate() as RigidBody2D
		ramita.set("en_arbol", true)
		destino.add_child(ramita)
		ramita.global_position = _bugs.to_global(spot)


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
