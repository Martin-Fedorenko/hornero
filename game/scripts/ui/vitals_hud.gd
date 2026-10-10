extends Control
## Barras de vida y stamina del hornero sobre el marco de madera de
## `hud_asset.png`. Se dibuja por capas: fondo marrón, relleno de color y,
## encima, el marco (que tiene el hueco de la barra transparente).

const FRAME := preload("res://assets/hud/hud_asset.png")
## Recorte de cada barra dentro de `hud_asset.png`.
const HEALTH_REGION := Rect2(20, 80, 1495, 280)
const STAMINA_REGION := Rect2(20, 400, 1495, 280)
## Hueco transparente de la barra, relativo al recorte.
const HOLE := Rect2(323, 123, 1039, 73)
## Cuánto se mete el relleno debajo del marco, para que no queden bordes.
const HOLE_BLEED := 6.0

@export var health_color := Color("e0361a")
@export var stamina_color := Color("dac126")
## Marrón del interior de los íconos del marco.
@export var background_color := Color("3f2711")
## Ancho en pantalla de cada barra (el alto sale de la proporción del asset).
@export var bar_width := 360.0
@export var bar_separation := -18.0
## Velocidad con la que el relleno alcanza el valor real.
@export var fill_speed := 6.0

var _health_ratio := 1.0
var _stamina_ratio := 1.0
var _shown_health := 1.0
var _shown_stamina := 1.0
## Un StyleBox por color, armado una sola vez: antes se creaban cuatro en
## cada redibujo, y las barras se redibujan casi todo el tiempo al volar.
var _boxes := {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bar_size := _bar_size()
	custom_minimum_size = Vector2(bar_size.x, bar_size.y * 2.0 + bar_separation)
	size = custom_minimum_size
	# Sólo procesa mientras el relleno se acerca al valor real.
	set_process(false)


func track(vitals: HorneroVitals) -> void:
	vitals.health_changed.connect(_on_health_changed)
	vitals.stamina_changed.connect(_on_stamina_changed)
	_on_health_changed(vitals.health, vitals.max_health)
	_on_stamina_changed(vitals.stamina, vitals.max_stamina)
	_shown_health = _health_ratio
	_shown_stamina = _stamina_ratio
	queue_redraw()


func _on_health_changed(current: float, maximum: float) -> void:
	_health_ratio = clampf(current / maximum, 0.0, 1.0) if maximum > 0.0 else 0.0
	set_process(true)


func _on_stamina_changed(current: float, maximum: float) -> void:
	_stamina_ratio = clampf(current / maximum, 0.0, 1.0) if maximum > 0.0 else 0.0
	set_process(true)


func _process(delta: float) -> void:
	var weight := 1.0 - exp(-fill_speed * delta)
	var health := lerpf(_shown_health, _health_ratio, weight)
	var stamina := lerpf(_shown_stamina, _stamina_ratio, weight)
	if not is_equal_approx(health, _shown_health) or not is_equal_approx(stamina, _shown_stamina):
		_shown_health = health
		_shown_stamina = stamina
		queue_redraw()
	else:
		# Ya llegó: no hay nada que animar hasta el próximo cambio.
		set_process(false)


func _draw() -> void:
	var bar_size := _bar_size()
	_draw_bar(Vector2.ZERO, HEALTH_REGION, health_color, _shown_health)
	_draw_bar(Vector2(0.0, bar_size.y + bar_separation), STAMINA_REGION,
			stamina_color, _shown_stamina)


func _draw_bar(origin: Vector2, region: Rect2, fill_color: Color, ratio: float) -> void:
	var scale_factor := bar_width / region.size.x
	var hole := Rect2(origin + HOLE.position * scale_factor, HOLE.size * scale_factor) \
			.grow(HOLE_BLEED * scale_factor)
	_draw_capsule(hole, background_color)
	if ratio > 0.0:
		var fill := hole
		# El relleno nunca es más angosto que su alto, así la punta queda
		# redonda; lo que sobra se esconde a la izquierda, bajo el marco.
		# Así el borde derecho avanza lineal: hole.x + ratio * hole.ancho.
		fill.size.x = lerpf(hole.size.y, hole.size.x, ratio)
		fill.position.x -= (1.0 - ratio) * hole.size.y
		_draw_capsule(fill, fill_color)
	draw_texture_rect_region(FRAME, Rect2(origin, region.size * scale_factor), region)


func _draw_capsule(rect: Rect2, color: Color) -> void:
	var radius := int(rect.size.y * 0.5)
	var box: StyleBoxFlat = _boxes.get(color)
	if box == null:
		box = StyleBoxFlat.new()
		box.bg_color = color
		box.anti_aliasing = true
		_boxes[color] = box
	if box.corner_radius_top_left != radius:
		box.set_corner_radius_all(radius)
	draw_style_box(box, rect)


func _bar_size() -> Vector2:
	return HEALTH_REGION.size * (bar_width / HEALTH_REGION.size.x)
