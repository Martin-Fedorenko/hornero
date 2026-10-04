extends AnimatedSprite2D

signal material_delivered(material: StringName)

const MATERIALS: Array[StringName] = [&"paja", &"piedra", &"maderita", &"barro"]

@onready var _delivery_area: Area2D = $DeliveryArea
@onready var _aura: Node2D = $DestelloLevantable
var _materiales_recibidos: int = 0

func _ready() -> void:
	animation = &"crecer"
	stop()
	frame = 0
	_delivery_area.body_entered.connect(_on_delivery_body_entered)
	# La zona de entrega es exactamente el círculo del aura.
	var circulo := CircleShape2D.new()
	circulo.radius = float(_aura.get("radio")) * _aura.scale.x
	var forma := _delivery_area.get_node(^"CollisionShape2D") as CollisionShape2D
	forma.shape = circulo
	_delivery_area.position = _aura.position


## ¿Ya recibió todos los materiales (última etapa del nido)?
func esta_completo() -> bool:
	return frame >= sprite_frames.get_frame_count(&"crecer") - 1


## ¿El punto (global) está dentro del aura del nido?
func esta_en_aura(punto: Vector2) -> bool:
	var radio_global := float(_aura.get("radio")) * _aura.global_scale.x
	return _aura.global_position.distance_to(punto) <= radio_global


func _physics_process(_delta: float) -> void:
	# Pasar por encima del nido con algo en el pico también lo entrega.
	for body in _delivery_area.get_overlapping_bodies():
		var interaccion := body.get_node_or_null(^"Interaccion")
		if interaccion == null or not interaccion.has_method("entregar_objeto"):
			continue
		var llevado: Variant = interaccion.get("objeto")
		if not is_instance_valid(llevado) or _material_de(llevado) == &"":
			continue
		_entregar(interaccion.entregar_objeto())


func _on_delivery_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"levantables") or body.get("recogida") == true:
		return
	_entregar(body)


## Material del objeto si se puede entregar al nido, o &"" si no.
func _material_de(body: Node2D) -> StringName:
	if not body.is_in_group(&"levantables") or body.get("entregado") == true:
		return &""
	var material_value: Variant = body.get("tipo_recurso")
	if material_value == null:
		return &""
	var material := StringName(material_value)
	return material if MATERIALS.has(material) else &""


func _entregar(body: Node2D) -> void:
	if body == null:
		return
	var material := _material_de(body)
	if material == &"":
		return
	body.set("entregado", true)
	body.set_deferred("collision_layer", 0)
	body.set_deferred("collision_mask", 0)
	_materiales_recibidos += 1
	var ultima_etapa := sprite_frames.get_frame_count(&"crecer") - 1
	frame = mini(_materiales_recibidos, ultima_etapa)
	material_delivered.emit(material)
	body.queue_free()
