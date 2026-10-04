class_name Nest
extends AnimatedSprite2D

signal material_delivered(material: StringName)

const MATERIALS: Array[StringName] = [&"paja", &"piedra", &"maderita", &"barro"]
## Mismas etapas que nest_asset.png pero sólo con la pared delantera de las
## tazas abiertas: se dibuja delante del hornero cuando está adentro.
const FRONT_TEXTURE := preload("res://assets/base/nest_front.png")

@export_group("Hornero adentro")
## Etapas abiertas (taza): altura del borde delantero en el centro, en
## píxeles de la textura. Sirve de referencia para hundir al hornero.
@export var rim_lines: PackedFloat32Array = [222.0, 224.0, 206.0]
## Fracción del alto del hornero que queda debajo del borde en cada etapa
## abierta: cuanto más construido, más se hunde.
@export var hidden_fractions: PackedFloat32Array = [0.2, 0.35, 0.5]
## Centro de la abertura de la taza y cuánto se adelanta la cabeza del
## hornero hacia donde mira, en píxeles de la textura: así la cabeza queda
## dentro de la abertura y no detrás de los cuernos de la pared.
@export var cup_center_x := 190.0
@export var cup_head_reach := 50.0
## Base del nido en píxeles de la textura: nada del hornero asoma por debajo.
@export var bottom_line := 282.0
## Etapas cerradas: centro de la entrada en píxeles de la textura.
@export var hole_centers: PackedVector2Array = [Vector2(192, 166), Vector2(186, 170)]
## Radio de la entrada en píxeles de la textura (un poco menor que el agujero
## dibujado para que no asome nada sobre el borde).
@export var hole_radius := 48.0

@onready var _delivery_area: Area2D = $DeliveryArea
var _materiales_recibidos: int = 0
var _occupied := false
var _front := Sprite2D.new()

func _ready() -> void:
	animation = &"crecer"
	stop()
	frame = 0
	_front.texture = FRONT_TEXTURE
	_front.centered = false
	_front.offset = offset
	_front.region_enabled = true
	_front.z_index = 1
	add_child(_front)
	frame_changed.connect(_update_front)
	_update_front()
	_delivery_area.body_entered.connect(_on_delivery_body_entered)


## El hornero entró o salió: en las tazas abiertas la pared delantera lo tapa.
func set_occupied(occupied: bool) -> void:
	_occupied = occupied
	_update_front()


func _update_front() -> void:
	var stage := sprite_frames.get_frame_texture(animation, frame) as AtlasTexture
	_front.region_rect = stage.region
	_front.visible = _occupied and not is_closed()

## Las primeras etapas son una taza abierta; las últimas, el horno con entrada.
func is_closed() -> bool:
	return frame >= rim_lines.size()


## Altura global del borde delantero en el centro (sólo etapas abiertas).
func rim_global_y() -> float:
	return _texture_to_global(Vector2(0.0, rim_lines[frame])).y


## Dónde va la cabeza del hornero en la taza abierta, según hacia dónde mira.
func cup_head_global_x(facing: int) -> float:
	return _texture_to_global(Vector2(cup_center_x + cup_head_reach * facing, 0.0)).x


func bottom_global_y() -> float:
	return _texture_to_global(Vector2(0.0, bottom_line)).y


func hidden_fraction() -> float:
	return hidden_fractions[mini(frame, hidden_fractions.size() - 1)]


## Centro global de la entrada (sólo etapas cerradas).
func hole_global_center() -> Vector2:
	var index := mini(frame - rim_lines.size(), hole_centers.size() - 1)
	return _texture_to_global(hole_centers[index])


func hole_global_radius() -> float:
	return hole_radius * absf(global_scale.y)


func _texture_to_global(texture_point: Vector2) -> Vector2:
	return to_global(texture_point + offset)


func _on_delivery_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"levantables") or body.get("recogida") == true:
		return
	if body.get("entregado") == true:
		return
	var material_value: Variant = body.get("tipo_recurso")
	if material_value == null:
		return
	var material := StringName(material_value)
	if not MATERIALS.has(material):
		return
	body.set("entregado", true)
	body.set_deferred("collision_layer", 0)
	body.set_deferred("collision_mask", 0)
	_materiales_recibidos += 1
	var ultima_etapa := sprite_frames.get_frame_count(&"crecer") - 1
	frame = mini(_materiales_recibidos, ultima_etapa)
	material_delivered.emit(material)
	body.queue_free()
