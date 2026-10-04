extends Control
## Flecha en el borde de la pantalla que apunta al nido cuando éste queda
## fuera de cámara. Titila en rojo mientras alguna Cotorra lo está picando.

const TEXTURE := preload("res://assets/hud/arrow_assets.png")
## Flecha verde (con el nido en la cola) dentro de `arrow_assets.png`. La
## hoja trae también una versión roja a la derecha, sin usar por ahora.
const REGION := Rect2(43, 124, 1034, 446)
## Punta de la flecha dentro de la hoja (la flecha mira a +X).
const TIP := Vector2(1076, 358)
## Largo de la flecha en el asset, de la cola a la punta.
const TEXTURE_LENGTH := 1033.0

## Nodo al que apunta la flecha (el nido).
@export var target: Node2D
## Distancia de la punta al borde de la pantalla.
@export var edge_margin := 24.0
## Largo de la flecha en pantalla.
@export var arrow_length := 170.0
## Cuánto puede salirse el nido de la pantalla antes de mostrar la flecha.
@export var visibility_margin := 40.0

@export_group("Alerta")
## Color del parpadeo mientras atacan el nido. Los valores por encima de 1
## hacen que el rojo quede vivo sobre la madera en vez de oscurecerla.
@export var alert_color := Color(1.6, 0.3, 0.3)
## Cuántas veces por segundo titila (0 = rojo fijo).
@export var blinks_per_second := 3.0

var _angle := 0.0
var _tip_position := Vector2.ZERO
var _under_attack := false
var _alert_time := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()


func _process(delta: float) -> void:
	if not is_instance_valid(target):
		hide()
		return
	var screen := get_viewport_rect()
	var target_on_screen := get_viewport().get_canvas_transform() * target.global_position
	if screen.grow(visibility_margin).has_point(target_on_screen):
		hide()
		return
	var center := screen.get_center()
	var direction := (target_on_screen - center).normalized()
	var half := screen.size * 0.5 - Vector2(edge_margin, edge_margin)
	# Escala la dirección hasta tocar el rectángulo interior de la pantalla.
	var scale_x := half.x / absf(direction.x) if direction.x != 0.0 else INF
	var scale_y := half.y / absf(direction.y) if direction.y != 0.0 else INF
	_angle = direction.angle()
	_tip_position = center + direction * minf(scale_x, scale_y)
	_update_alert(delta)
	show()
	queue_redraw()


func _draw() -> void:
	var scale_factor := arrow_length / TEXTURE_LENGTH
	# Con la punta en el origen y la flecha rotada hacia el nido. Si apunta a
	# la izquierda se espeja en Y para que el nido no quede boca abajo.
	var flip := -1.0 if absf(_angle) > PI * 0.5 else 1.0
	draw_set_transform(_tip_position, _angle, Vector2(scale_factor, scale_factor * flip))
	draw_texture_rect_region(TEXTURE, Rect2(REGION.position - TIP, REGION.size), REGION, _current_color())
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _update_alert(delta: float) -> void:
	var attacked := _is_nest_attacked()
	if attacked and not _under_attack:
		_alert_time = 0.0  # Que arranque en rojo apenas empieza el ataque
	_under_attack = attacked
	_alert_time += delta


## true si alguna Cotorra está picando el nido en este momento.
func _is_nest_attacked() -> bool:
	for node in get_tree().get_nodes_in_group("cotorras"):
		var cotorra := node as Cotorra
		if cotorra and cotorra.modo == Cotorra.Modo.PICANDO:
			return true
	return false


func _current_color() -> Color:
	if not _under_attack:
		return Color.WHITE
	# Primera mitad de cada ciclo en rojo, segunda mitad con el color normal.
	if fmod(_alert_time * blinks_per_second, 1.0) < 0.5:
		return alert_color
	return Color.WHITE
