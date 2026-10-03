extends AnimatedSprite2D

signal material_delivered(material: StringName)

const MATERIALS: Array[StringName] = [&"paja", &"piedra", &"maderita", &"barro"]

@onready var _delivery_area: Area2D = $DeliveryArea

func _ready() -> void:
	_delivery_area.body_entered.connect(_on_delivery_body_entered)

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
	material_delivered.emit(material)
	body.queue_free()
