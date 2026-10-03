extends Node2D
## Nivel de prueba de vuelo: límites de cámara y HUD de depuración.
## El fondo es la escena PampasBackground (parallax).

const INVENTORY_ORDER: Array[StringName] = [&"paja", &"piedra", &"maderita", &"barro"]
const INVENTORY_ICONS := {
	&"paja": preload("res://objetos_hornero/paja.svg"),
	&"piedra": preload("res://objetos_hornero/piedra.svg"),
	&"maderita": preload("res://objetos_hornero/ramitas.svg"),
	&"barro": preload("res://objetos_hornero/bola_barro.svg"),
}

## Área jugable. La cámara no muestra nada fuera de este rectángulo.
@export var world_rect := Rect2(0, -400, 6000, 2200)

@onready var _hornero: Hornero = $Hornero
@onready var _camera: Camera2D = $Hornero/Camera2D
@onready var _status: Label = $HUD/Status
@onready var _nest: Node = $World/NestTree/Nest

var _inventory_counts := {
	&"paja": 0,
	&"piedra": 0,
	&"maderita": 0,
	&"barro": 0,
}
var _inventory_labels: Dictionary = {}


func _ready() -> void:
	_camera.limit_left = int(world_rect.position.x)
	_camera.limit_top = int(world_rect.position.y)
	_camera.limit_right = int(world_rect.end.x)
	_camera.limit_bottom = int(world_rect.end.y)
	_camera.reset_smoothing()
	_nest.connect(&"material_delivered", _on_material_delivered)
	_create_inventory_hud()


func _process(_delta: float) -> void:
	_status.text = "Estado: %s   ·   Velocidad: %4.0f px/s   ·   Pitch: %+3.0f°" % [
		Hornero.State.keys()[_hornero.state],
		_hornero.velocity.length(),
		rad_to_deg(_hornero.pitch),
	]


func _create_inventory_hud() -> void:
	var panel := PanelContainer.new()
	panel.name = "Inventario"
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -332.0
	panel.offset_right = -18.0
	panel.offset_top = 18.0
	panel.offset_bottom = 72.0
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.12, 0.10, 0.9)
	panel_style.border_color = Color("c6a56b")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(6)
	panel_style.content_margin_left = 9.0
	panel_style.content_margin_right = 9.0
	panel_style.content_margin_top = 5.0
	panel_style.content_margin_bottom = 5.0
	panel.add_theme_stylebox_override("panel", panel_style)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)
	$HUD.add_child(panel)

	for material in INVENTORY_ORDER:
		var slot := HBoxContainer.new()
		slot.add_theme_constant_override("separation", 3)
		var icon := TextureRect.new()
		icon.texture = INVENTORY_ICONS[material]
		icon.custom_minimum_size = Vector2(30.0, 30.0)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.tooltip_text = String(material)
		var count := Label.new()
		count.text = "0"
		count.custom_minimum_size.x = 24.0
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		count.add_theme_font_size_override("font_size", 18)
		count.add_theme_color_override("font_color", Color("fff3d4"))
		slot.add_child(icon)
		slot.add_child(count)
		row.add_child(slot)
		_inventory_labels[material] = count


func _on_material_delivered(material: StringName) -> void:
	if not _inventory_counts.has(material):
		return
	_inventory_counts[material] = int(_inventory_counts[material]) + 1
	var count: Label = _inventory_labels[material]
	count.text = str(_inventory_counts[material])
