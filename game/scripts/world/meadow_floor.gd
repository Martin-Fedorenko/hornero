@tool
class_name MeadowFloor
extends Node2D
## Piso de pastizal armado con `floor_assets.png`: franjas de pasto que se
## funden entre sí, y encima piedras, matas, charcos, etc. repartidos al azar
## (reproducible con `random_seed`). Sólo el piso tiene collider; todo lo
## demás es decoración.
##
## Los charcos se ubican primero y van solos: ninguna otra decoración se
## superpone con ellos.
##
## El origen es el borde izquierdo de la línea de suelo: ahí apoya el hornero
## y ahí se apoyan las decoraciones. Todo lo generado es interno: no se
## guarda en la escena.

@export var width := 6000.0:
	set(value):
		width = value
		_queue_rebuild()
## Profundidad del piso bajo la línea de suelo (collider y relleno de tierra).
@export var depth := 160.0:
	set(value):
		depth = value
		_queue_rebuild()
@export var random_seed := 2026:
	set(value):
		random_seed = value
		_queue_rebuild()
## Piedras grandes cada 1000 px de piso.
@export var rocks_per_1000 := 1.4:
	set(value):
		rocks_per_1000 = value
		_queue_rebuild()
## Decoraciones chicas cada 1000 px de piso.
@export var decor_per_1000 := 16.0:
	set(value):
		decor_per_1000 = value
		_queue_rebuild()
## Charcos cada 1000 px de la zona jugable.
@export var puddles_per_1000 := 0.6:
	set(value):
		puddles_per_1000 = value
		_queue_rebuild()
## Píxeles de cada borde del piso que quedan fuera de la zona jugable (fuera
## de cámara). Ahí no se ponen charcos.
@export var playable_margin := 0.0:
	set(value):
		playable_margin = value
		_queue_rebuild()
## Tramos de x GLOBAL donde no puede ir un charco (troncos de árboles,
## objetos sueltos, etc.). Cada Vector2 es (desde, hasta).
@export var puddle_free_zones: Array[Vector2] = []:
	set(value):
		puddle_free_zones = value
		_queue_rebuild()
@export var soil_color := Color(0.48, 0.34, 0.25):
	set(value):
		soil_color = value
		queue_redraw()
@export var deep_soil_color := Color(0.3, 0.2, 0.15):
	set(value):
		deep_soil_color = value
		queue_redraw()

const ATLAS := preload("res://assets/floor/floor_assets.png")
const FADE_SHADER := preload("res://scripts/world/strip_fade.gdshader")
## Se carga al usarse y no con preload: la bola de barro usa MeadowFloor, y con
## preload la carga daba la vuelta y fallaba ("Parse Error: Busy").
const MUD_SOURCE_SCENE_PATH := "res://objetos_hornero/charco_barro.tscn"
const DRY_PUDDLE_ATLAS := preload("res://assets/floor/Atlas de charcos secos y agrietados.png")

## Franjas de pasto: región en el atlas y fila (relativa a la región) donde
## empieza el pasto macizo. Por encima sólo hay matas sueltas.
const STRIPS := [
	[Rect2(40, 32, 649, 86), 33],
	[Rect2(40, 120, 649, 79), 28],
	[Rect2(40, 206, 649, 90), 39],
	[Rect2(40, 305, 649, 89), 32],
	[Rect2(715, 24, 648, 94), 41],
	[Rect2(715, 119, 648, 80), 30],
	[Rect2(715, 208, 648, 88), 33],
	[Rect2(715, 300, 648, 97), 39],
]
## Ancho de la zona donde dos franjas vecinas se superponen y se funden.
const STRIP_FADE := 110.0
## Altura del pasto macizo sobre la línea de suelo. La banda de pasto mide
## unos 30 px: el hornero apoya a mitad de camino, "dentro" del pasto, así
## lo de atrás queda detrás de él y lo de adelante lo tapa.
const GRASS_ABOVE_GROUND := 18.0
## Desde dónde (bajo la línea de suelo) se dibuja el relleno de tierra.
const SOIL_TOP := 22.0

## Profundidad de los props, según su alto en pantalla: los chicos van
## adelante del hornero (lo tapan al pasar) con la base más abajo que sus
## patas; los grandes van atrás, con la base más arriba.
const FRONT_MAX_HEIGHT := 56.0
## Rango de la base (bajo la línea de suelo) de cada plano.
const FRONT_BASE := Vector2(4.0, 10.0)
const BACK_BASE := Vector2(-15.0, -7.0)
## Capa de dibujo del plano de adelante, por encima del hornero.
const FRONT_Z := 1

## Decoraciones por tipo: [regiones del atlas, peso al sortear, plano].
## "suelo" = adelante o atrás según su tamaño; "plano" = se acuesta sobre la
## banda de pasto, detrás del hornero (charcos, hojas).
const DECOR := {
	"mata_alta": [[
		Rect2(359, 647, 171, 116), Rect2(844, 657, 144, 108), Rect2(1001, 657, 124, 106),
		Rect2(34, 659, 132, 101), Rect2(548, 659, 142, 104), Rect2(704, 672, 122, 90),
		Rect2(1284, 688, 83, 85), Rect2(171, 698, 82, 68), Rect2(261, 693, 89, 70),
	], 5.0, "suelo"],
	"mata": [[
		Rect2(913, 767, 131, 81), Rect2(40, 770, 145, 77), Rect2(287, 774, 102, 74),
		Rect2(505, 776, 88, 72), Rect2(691, 770, 124, 78), Rect2(827, 771, 78, 71),
		Rect2(1064, 775, 105, 73), Rect2(198, 788, 77, 59), Rect2(395, 780, 89, 68),
		Rect2(608, 785, 68, 63), Rect2(1186, 787, 72, 62), Rect2(1275, 782, 79, 66),
	], 6.0, "suelo"],
	"yuyo": [[
		Rect2(918, 930, 63, 66), Rect2(986, 948, 37, 56), Rect2(1031, 951, 37, 63),
		Rect2(1078, 934, 55, 77), Rect2(1151, 932, 119, 60), Rect2(1282, 934, 72, 59),
		Rect2(403, 940, 52, 57),
	], 3.0, "suelo"],
	"arbusto": [[
		Rect2(681, 991, 142, 52), Rect2(836, 1008, 70, 35), Rect2(929, 1007, 98, 36),
		Rect2(1187, 997, 72, 51), Rect2(1131, 1009, 49, 60), Rect2(1272, 1001, 88, 71),
		Rect2(1046, 1016, 72, 93), Rect2(195, 1044, 145, 66), Rect2(361, 1046, 139, 64),
		Rect2(515, 1045, 64, 65), Rect2(674, 1046, 100, 64), Rect2(791, 1048, 70, 61),
		Rect2(599, 1050, 63, 59), Rect2(978, 1058, 63, 52), Rect2(1275, 1077, 76, 33),
	], 4.0, "suelo"],
	"piedrita": [[
		Rect2(717, 525, 144, 53), Rect2(861, 520, 55, 26), Rect2(173, 545, 103, 54),
		Rect2(354, 546, 78, 36), Rect2(614, 549, 72, 37), Rect2(895, 551, 79, 32),
		Rect2(806, 584, 76, 38), Rect2(903, 595, 48, 32), Rect2(184, 610, 88, 34),
	], 3.0, "suelo"],
	"monticulo": [[
		Rect2(162, 1001, 101, 42), Rect2(280, 995, 128, 47), Rect2(421, 1002, 94, 39),
	], 1.2, "suelo"],
	"paja": [[
		Rect2(465, 944, 80, 41), Rect2(559, 941, 92, 44), Rect2(667, 931, 94, 54),
		Rect2(764, 932, 136, 59),
	], 1.2, "plano"],
	"hojas": [[
		Rect2(38, 945, 70, 35), Rect2(163, 940, 91, 45), Rect2(253, 947, 61, 44),
		Rect2(316, 945, 75, 40),
	], 1.2, "plano"],
}
## Charcos: se reparten aparte (ver `puddles_per_1000`) y van solos.
const PUDDLES := [
	Rect2(33, 858, 212, 61), Rect2(782, 858, 224, 62), Rect2(1019, 861, 140, 56),
	Rect2(1204, 860, 159, 51), Rect2(619, 865, 159, 50),
]
## Espacio libre a cada lado de un charco.
const PUDDLE_PADDING := 50.0
## Intentos de reubicar una decoración que cae encima de un charco.
const PLACE_TRIES := 8
## Piedras grandes: decoración, sin collider.
const ROCKS := [
	Rect2(37, 404, 286, 128), Rect2(1135, 416, 233, 119), Rect2(491, 421, 210, 121),
	Rect2(714, 423, 191, 91), Rect2(920, 424, 201, 112), Rect2(336, 439, 153, 91),
]
## Base de las piedras grandes (bajo la línea de suelo): siempre atrás.
const ROCK_BASE := -8.0
## Matas que tapan la unión entre franjas.
const SEAM_COVER := "mata_alta"
## Los objetos acostados se aplastan para verse sobre el plano del suelo.
const FLAT_SQUASH := 0.7
## Altura (bajo la línea de suelo) del centro de lo acostado.
const FLAT_CENTER := -4.0

var _content: Node2D
var _layers := {}
## Tramos de x local ocupados por charcos (con su margen), como Vector2(desde, hasta).
var _puddle_spans: Array[Vector2] = []
var _rebuild_queued := false


func _ready() -> void:
	_rebuild()


func _draw() -> void:
	# Tierra bajo las franjas de pasto, que son finitas.
	var left := -STRIP_FADE
	var right := width + STRIP_FADE
	draw_polygon(
		PackedVector2Array([Vector2(left, SOIL_TOP), Vector2(right, SOIL_TOP),
				Vector2(right, depth), Vector2(left, depth)]),
		PackedColorArray([soil_color, soil_color, deep_soil_color, deep_soil_color]))


func _queue_rebuild() -> void:
	if _rebuild_queued or not is_inside_tree():
		return
	_rebuild_queued = true
	_rebuild.call_deferred()


func _rebuild() -> void:
	_rebuild_queued = false
	if _content != null:
		_content.queue_free()
	_content = Node2D.new()
	add_child(_content, false, Node.INTERNAL_MODE_FRONT)
	_layers.clear()
	# Orden de dibujo, de atrás hacia adelante. Todo queda detrás del hornero.
	for layer_name in ["pasto", "plano", "atras", "piedras", "adelante"]:
		var layer := Node2D.new()
		layer.name = layer_name.capitalize()
		_content.add_child(layer)
		_layers[layer_name] = layer
	_layers["adelante"].z_index = FRONT_Z

	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed
	_add_ground_body()
	var seams := _add_strips(rng)
	_add_puddles(rng)
	for seam in seams:
		_add_decor(rng, SEAM_COVER, seam, false)
	_add_rocks(rng)
	var count := roundi(width / 1000.0 * decor_per_1000)
	for i in count:
		_add_decor(rng, _pick_kind(rng), rng.randf_range(0.0, width))
	queue_redraw()


func _add_ground_body() -> void:
	var body := StaticBody2D.new()
	body.name = "Collider"
	body.add_to_group(&"suelo")
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, depth)
	var collider := CollisionShape2D.new()
	collider.shape = shape
	collider.position = shape.size * 0.5
	body.add_child(collider)
	_content.add_child(body)


## Pone franjas hasta cubrir el ancho y devuelve la x del centro de cada unión.
func _add_strips(rng: RandomNumberGenerator) -> Array[float]:
	var seams: Array[float] = []
	var x := -STRIP_FADE
	var previous := -1
	while x < width + STRIP_FADE:
		var index := rng.randi_range(0, STRIPS.size() - 1)
		if index == previous:
			index = (index + 1) % STRIPS.size()
		previous = index
		var region: Rect2 = STRIPS[index][0]
		var flip := rng.randf() < 0.5
		var sprite := _sprite(region, flip)
		sprite.position = Vector2(x, -GRASS_ABOVE_GROUND - float(STRIPS[index][1]))
		if x > -STRIP_FADE:
			sprite.material = _fade_material(region, flip)
			seams.append(x + STRIP_FADE * 0.5)
		_layers["pasto"].add_child(sprite)
		x += region.size.x - STRIP_FADE
	return seams


func _fade_material(region: Rect2, flip: bool) -> ShaderMaterial:
	var fade := ShaderMaterial.new()
	fade.shader = FADE_SHADER
	fade.set_shader_parameter("fade_width", STRIP_FADE)
	fade.set_shader_parameter("region_x", region.position.x)
	fade.set_shader_parameter("region_w", region.size.x)
	fade.set_shader_parameter("flipped", flip)
	return fade


## Un charco por tramo parejo de la zona jugable, lejos de las zonas
## prohibidas. Los tramos que ocupa quedan reservados.
func _add_puddles(rng: RandomNumberGenerator) -> void:
	_puddle_spans.clear()
	var from := playable_margin
	var to := width - playable_margin
	var count := roundi((to - from) / 1000.0 * puddles_per_1000)
	if count <= 0:
		return
	var forbidden: Array[Vector2] = []
	for zone in puddle_free_zones:
		forbidden.append(zone - Vector2.ONE * position.x)
	var slot := (to - from) / count
	for i in count:
		var region: Rect2 = PUDDLES[rng.randi_range(0, PUDDLES.size() - 1)]
		var scale_factor := rng.randf_range(0.9, 1.1)
		var size := region.size * Vector2(scale_factor, scale_factor * FLAT_SQUASH)
		# Tramos donde puede empezar el charco sin pisar una zona prohibida.
		var free: Array[Vector2] = [Vector2(from + slot * i + PUDDLE_PADDING,
				from + slot * (i + 1) - PUDDLE_PADDING - size.x)]
		for zone in forbidden:
			free = _subtract(free, Vector2(zone.x - size.x - PUDDLE_PADDING, zone.y + PUDDLE_PADDING))
		var x: Variant = _random_in(rng, free)
		if x == null:
			continue
		var sprite := _sprite(region, rng.randf() < 0.5)
		sprite.scale = size / region.size
		sprite.position = Vector2(x, FLAT_CENTER - size.y * 0.5)
		_layers["plano"].add_child(sprite)
		_puddle_spans.append(Vector2(x - PUDDLE_PADDING, x + size.x + PUDDLE_PADDING))
		# El script del charco no es @tool: en el editor sería un placeholder
		# sin métodos. Tampoco hace falta, sólo da barro al jugar.
		if Engine.is_editor_hint():
			continue
		var source := (load(MUD_SOURCE_SCENE_PATH) as PackedScene).instantiate()
		source.call("configurar_charco", sprite, size)
		source.set("textura_seca", DRY_PUDDLE_ATLAS)
		source.set("posicion_bola", Vector2(0, -14))
		source.position = sprite.position + size * 0.5
		_layers["plano"].add_child(source)


## Le quita a cada tramo la parte que se superpone con `cut`.
func _subtract(spans: Array[Vector2], cut: Vector2) -> Array[Vector2]:
	var result: Array[Vector2] = []
	for span in spans:
		if cut.y <= span.x or cut.x >= span.y:
			result.append(span)
			continue
		if cut.x > span.x:
			result.append(Vector2(span.x, cut.x))
		if cut.y < span.y:
			result.append(Vector2(cut.y, span.y))
	return result


## x al azar dentro de los tramos (pesando por largo). null si no hay lugar.
func _random_in(rng: RandomNumberGenerator, spans: Array[Vector2]) -> Variant:
	var total := 0.0
	for span in spans:
		total += maxf(span.y - span.x, 0.0)
	if total <= 0.0:
		return null
	var roll := rng.randf() * total
	for span in spans:
		var length := maxf(span.y - span.x, 0.0)
		if roll <= length:
			return span.x + roll
		roll -= length
	return spans[-1].y


func _overlaps_any(span: Vector2, spans: Array[Vector2]) -> bool:
	for other in spans:
		if span.x < other.y and other.x < span.y:
			return true
	return false


## ¿El tramo [desde, hasta] (x local) pisa algún charco?
func _on_puddle(from_x: float, to_x: float) -> bool:
	return _overlaps_any(Vector2(from_x, to_x), _puddle_spans)


## Una piedra por tramo parejo, en una posición al azar dentro del tramo.
func _add_rocks(rng: RandomNumberGenerator) -> void:
	var count := roundi(width / 1000.0 * rocks_per_1000)
	if count <= 0:
		return
	var slot := width / count
	var order := range(ROCKS.size())
	for i in count:
		if i % ROCKS.size() == 0:
			_shuffle(rng, order)
		var region: Rect2 = ROCKS[order[i % ROCKS.size()]]
		var x := slot * i + rng.randf_range(0.0, maxf(slot - region.size.x, 0.0))
		var tries := 0
		while _on_puddle(x, x + region.size.x) and tries < PLACE_TRIES:
			x = slot * i + rng.randf_range(0.0, maxf(slot - region.size.x, 0.0))
			tries += 1
		if _on_puddle(x, x + region.size.x):
			continue
		var sprite := _sprite(region, rng.randf() < 0.5)
		sprite.position = Vector2(x, ROCK_BASE - region.size.y)
		_layers["piedras"].add_child(sprite)


## Agrega una decoración del tipo dado, centrada en `center_x`, con la base
## apoyada en el plano que le corresponde por tamaño. Si cae sobre un charco
## y `can_move` es true, prueba otras x al azar; si no, no la pone.
func _add_decor(rng: RandomNumberGenerator, kind: String, center_x: float,
		can_move := true) -> void:
	var data: Array = DECOR[kind]
	var regions: Array = data[0]
	var region: Rect2 = regions[rng.randi_range(0, regions.size() - 1)]
	var flat: bool = data[2] == "plano"
	var scale_factor := rng.randf_range(0.8, 1.05)
	var sprite := _sprite(region, rng.randf() < 0.5)
	if flat:
		sprite.scale = Vector2(scale_factor, scale_factor * FLAT_SQUASH)
	else:
		sprite.scale = Vector2.ONE * scale_factor
	var size := region.size * sprite.scale
	var x := clampf(center_x - size.x * 0.5, 0.0, width - size.x)
	var tries := 0
	while _on_puddle(x, x + size.x) and can_move and tries < PLACE_TRIES:
		x = clampf(rng.randf_range(0.0, width) - size.x * 0.5, 0.0, width - size.x)
		tries += 1
	if _on_puddle(x, x + size.x):
		sprite.free()
		return
	var layer := "plano"
	var base_y := FLAT_CENTER + size.y * 0.5
	if not flat:
		var front := size.y <= FRONT_MAX_HEIGHT
		layer = "adelante" if front else "atras"
		var base_range := FRONT_BASE if front else BACK_BASE
		base_y = rng.randf_range(base_range.x, base_range.y)
	sprite.position = Vector2(x, base_y - size.y)
	_layers[layer].add_child(sprite)


func _pick_kind(rng: RandomNumberGenerator) -> String:
	var total := 0.0
	for kind: String in DECOR:
		total += float(DECOR[kind][1])
	var roll := rng.randf() * total
	for kind: String in DECOR:
		roll -= float(DECOR[kind][1])
		if roll <= 0.0:
			return kind
	return DECOR.keys()[-1]


## Fisher-Yates con el generador propio, para que `random_seed` lo determine todo.
func _shuffle(rng: RandomNumberGenerator, items: Array) -> void:
	for i in range(items.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = items[i]
		items[i] = items[j]
		items[j] = tmp


func _sprite(region: Rect2, flip: bool) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = ATLAS
	sprite.centered = false
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.region_filter_clip_enabled = true
	sprite.flip_h = flip
	return sprite
