class_name Bicho
extends Area2D
## Bichito posado en las hojas de un árbol. El hornero lo come al pasarle
## por encima volando (ver HorneroComer) y recupera vida y stamina.
##
## La hoja `insectos_asset.png` tiene un tipo de bicho por fila y 6 cuadros
## de idle por fila. Los SpriteFrames se arman una sola vez y se comparten.

## El bicho fue comido. El árbol lo usa para reponerlo más tarde.
signal eaten
## Terminó de desaparecer: el árbol lo guarda para reusarlo.
signal consumido

enum Tipo { ORUGA, CHICHARRITA, ESCARABAJO, POLILLA }

## Capa de física de los bichos (capa 4). HorneroComer la busca con su máscara.
const LAYER := 1 << 3
const ATLAS := preload("res://assets/tree/insectos_asset.png")
## Cuadro de cada bicho dentro de la hoja: columnas parejas, filas a mano
## porque los bichos no están centrados en una grilla exacta.
const FRAME_SIZE := Vector2(250, 236)
const FIRST_COLUMN_X := 32.0
const ROW_Y := [36.0, 280.0, 520.0, 755.0]
const FRAME_COUNT := 6
const Cercania := preload("res://scripts/world/cercania.gd")
## Píxeles de pantalla más allá del borde en los que ya se anima.
const MARGEN_ACTIVACION := 64.0

static var _frames: SpriteFrames

@export var tipo := Tipo.ORUGA
## Vida que recupera el hornero al comerlo.
@export var heal_amount := 10.0
## Stamina que recupera el hornero al comerlo.
@export var stamina_amount := 15.0
## Tamaño en pantalla respecto de la hoja original.
@export var sprite_scale := 0.2
@export var idle_fps := 7.0

var _eaten := false

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group(&"bichos")
	collision_layer = LAYER
	collision_mask = 0
	monitoring = false
	_sprite.sprite_frames = _shared_frames()
	_sprite.scale = Vector2.ONE * sprite_scale
	_configurar()
	# Lejos de la cámara la animación queda en pausa. Sólo el sprite: el
	# cuerpo sigue activo para que el tween con el que aparece no se trabe.
	var medio := FRAME_SIZE * sprite_scale * 0.5
	Cercania.activar_cerca_de_camara(_sprite, self, Rect2(-medio, medio * 2.0), MARGEN_ACTIVACION)


## Lo deja como recién creado, para reusarlo desde el pool del árbol con
## otro `tipo` y otra posición.
func reiniciar() -> void:
	_eaten = false
	scale = Vector2.ONE
	monitorable = true
	_configurar()


func _configurar() -> void:
	_sprite.play(_animation_name(tipo))
	_sprite.speed_scale = idle_fps / 8.0 * randf_range(0.8, 1.2)
	# Cada bicho arranca en otro cuadro y mira para otro lado.
	_sprite.frame = randi() % FRAME_COUNT
	_sprite.flip_h = randf() < 0.5
	_sprite.rotation = randf_range(-0.5, 0.5)


func can_be_eaten() -> bool:
	return not _eaten


## Lo come el hornero: vuela hacia el pico, se achica y desaparece. Al
## terminar avisa con `consumido`; si nadie lo reusa, se libera.
func eat(beak_position: Vector2) -> void:
	if _eaten:
		return
	_eaten = true
	set_deferred(&"monitorable", false)
	eaten.emit()
	var tween := create_tween().set_parallel()
	tween.tween_property(self, ^"global_position", beak_position, 0.12)
	tween.tween_property(self, ^"scale", Vector2.ZERO, 0.15)
	tween.chain().tween_callback(_terminar)


func _terminar() -> void:
	if consumido.get_connections().is_empty():
		queue_free()
	else:
		consumido.emit()


static func _animation_name(t: Tipo) -> StringName:
	return StringName(Tipo.keys()[t].to_lower())


static func _shared_frames() -> SpriteFrames:
	if _frames != null:
		return _frames
	_frames = SpriteFrames.new()
	_frames.remove_animation(&"default")
	for t: Tipo in Tipo.values():
		var anim := _animation_name(t)
		_frames.add_animation(anim)
		_frames.set_animation_speed(anim, 8.0)
		_frames.set_animation_loop(anim, true)
		for i in FRAME_COUNT:
			var frame := AtlasTexture.new()
			frame.atlas = ATLAS
			frame.region = Rect2(Vector2(FIRST_COLUMN_X + FRAME_SIZE.x * i, ROW_Y[t]), FRAME_SIZE)
			_frames.add_frame(anim, frame)
	return _frames
