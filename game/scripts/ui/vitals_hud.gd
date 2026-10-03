extends VBoxContainer
## Barras de vida (roja) y stamina (verde) del hornero.

@export var health_color := Color(0.85, 0.2, 0.18)
@export var stamina_color := Color(0.3, 0.75, 0.25)
@export var background_color := Color(0.1, 0.12, 0.11, 0.6)
@export var bar_size := Vector2(260, 18)

@onready var _health: ProgressBar = $Vida
@onready var _stamina: ProgressBar = $Stamina


func _ready() -> void:
	_style(_health, health_color)
	_style(_stamina, stamina_color)


func track(vitals: HorneroVitals) -> void:
	vitals.health_changed.connect(_update.bind(_health))
	vitals.stamina_changed.connect(_update.bind(_stamina))
	_update(vitals.health, vitals.max_health, _health)
	_update(vitals.stamina, vitals.max_stamina, _stamina)


func _update(current: float, maximum: float, bar: ProgressBar) -> void:
	bar.max_value = maximum
	bar.value = current


func _style(bar: ProgressBar, fill_color: Color) -> void:
	bar.custom_minimum_size = bar_size
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", _box(background_color))
	bar.add_theme_stylebox_override("fill", _box(fill_color))


func _box(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(4)
	return box
