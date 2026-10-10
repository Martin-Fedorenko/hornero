class_name Nest
extends AnimatedSprite2D

signal material_delivered(material: StringName)
## Se emite cuando la Cotorra rompe una construcción del nido.
signal construccion_perdida

const MATERIALS: Array[StringName] = [&"paja", &"piedra", &"maderita", &"barro"]
## Mismas etapas que nest_asset.png pero sólo con la pared delantera de las
## tazas abiertas: se dibuja delante del hornero cuando está adentro.
const FRONT_TEXTURE := preload("res://assets/base/nest_front.png")
## Si no recibe daño durante este tiempo, se considera que nadie lo está picando.
const PAUSA_SIN_DANIO := 0.2
const TextoJuego := preload("res://scripts/ui/texto_juego.gd")

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

@export_group("Etapas")
## Materiales que hay que llevar para que el dibujo avance una etapa. En
## Difícil son 2: el nido pide el doble de materiales y el contador los cuenta
## todos. Lo configura main.gd según la dificultad.
@export_range(1, 4) var materiales_por_etapa := 1

@export_group("Resistencia")
## Segundos que tarda una cotorra picando sin parar en romper una construcción.
## Si pican dos a la vez, tardan la mitad. Si dejan de picar antes, la
## construcción queda intacta: cada visita arranca de cero.
@export_range(0.5, 60.0, 0.5, "or_greater") var segundos_por_construccion := 15.0

@export_group("Alerta")
## Color del titileo mientras pican el nido. Valores mayores a 1 hacen que brille.
@export var color_alerta := Color(1.6, 0.3, 0.3)
## Titileos por segundo con la construcción intacta (recién empieza a picar).
@export_range(0.5, 20.0, 0.5) var titileos_min := 3.0
## Titileos por segundo cuando la construcción está por romperse.
@export_range(0.5, 20.0, 0.5) var titileos_max := 10.0

@export_group("Contador")
## Tamaño de la letra del contador en píxeles de la textura (el nido está escalado).
@export var contador_font_size := 68
## Separación entre el borde superior del nido y el contador, en píxeles de la
## textura. Deja lugar abajo para el aviso de la tecla G.
@export var contador_margen := 110.0
## Tamaño de la letra del aviso "Apretá G…" en píxeles de la textura.
@export var aviso_font_size := 50
## Separación entre el borde superior del nido y el aviso, en píxeles de la textura.
@export var aviso_margen := 20.0

@onready var _delivery_area: Area2D = $DeliveryArea
@onready var _aura: Node2D = $DestelloLevantable
var _materiales_recibidos: int = 0
var _occupied := false
var _front := Sprite2D.new()
var _contador: Label
var _aviso: Label

## Resistencia de la construcción de más arriba: 1 = intacta, 0 = se rompe.
var resistencia := 1.0
var _tiempo_sin_danio := PAUSA_SIN_DANIO  # Arranca como "nadie pica"

var _color_normal := Color.WHITE
var _fase_titileo := 0.0
var _estaba_atacado := false
## Radio global del aura (se calcula la primera vez que se pide).
var _radio_aura_global := -1.0


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
	_crear_contador()
	frame_changed.connect(_actualizar_contador)
	_actualizar_contador()
	_crear_aviso()
	_color_normal = self_modulate
	# _process sólo lo copia mientras titila: arranca igual al nido.
	_front.self_modulate = self_modulate
	_delivery_area.body_entered.connect(_on_delivery_body_entered)
	# La zona de entrega es exactamente el círculo del aura.
	var circulo := CircleShape2D.new()
	circulo.radius = float(_aura.get("radio")) * _aura.scale.x
	var forma := _delivery_area.get_node(^"CollisionShape2D") as CollisionShape2D
	forma.shape = circulo
	_delivery_area.position = _aura.position


## ¿Ya recibió todos los materiales (última etapa del nido)?
func esta_completo() -> bool:
	return _materiales_recibidos >= total_construcciones()


## Materiales que pide el nido completo.
func total_construcciones() -> int:
	return (sprite_frames.get_frame_count(&"crecer") - 1) * materiales_por_etapa


## Materiales que tiene ahora (lo que muestra el contador).
func construcciones() -> int:
	return _materiales_recibidos


## ¿El punto (global) está dentro del aura del nido?
func esta_en_aura(punto: Vector2) -> bool:
	# Lo consulta main.gd en cada frame: el radio se calcula una sola vez.
	if _radio_aura_global < 0.0:
		_radio_aura_global = float(_aura.get("radio")) * _aura.global_scale.x
	return _aura.global_position.distance_to(punto) <= _radio_aura_global


## ¿Lo están picando ahora?
func esta_siendo_atacado() -> bool:
	return _tiempo_sin_danio < PAUSA_SIN_DANIO


## La llama la Cotorra en cada frame que pica, con los segundos que pasaron.
func recibir_danio(segundos: float) -> void:
	_tiempo_sin_danio = 0.0
	if _materiales_recibidos == 0:
		return  # Sin construcciones no hay nada que romper
	resistencia -= segundos / segundos_por_construccion
	if resistencia <= 0.0:
		_perder_construccion()


func _process(delta: float) -> void:
	# Sin ataque y con el color ya normal no hay nada que titilar.
	if not _estaba_atacado and not esta_siendo_atacado():
		return
	_actualizar_titileo(delta)
	# La pared delantera (cuando el hornero está adentro) titila con el resto
	_front.self_modulate = self_modulate


func _physics_process(delta: float) -> void:
	_regenerar(delta)

	# Pasar por encima del nido con algo en el pico también lo entrega.
	for body in _delivery_area.get_overlapping_bodies():
		var interaccion := body.get_node_or_null(^"Interaccion")
		if interaccion == null or not interaccion.has_method("entregar_objeto"):
			continue
		var llevado: Variant = interaccion.get("objeto")
		if not is_instance_valid(llevado) or _material_de(llevado) == &"":
			continue
		_entregar(interaccion.entregar_objeto())



## El hornero entró o salió: en las tazas abiertas la pared delantera lo tapa.
func set_occupied(occupied: bool) -> void:
	_occupied = occupied
	_update_front()


func _update_front() -> void:
	var stage := sprite_frames.get_frame_texture(animation, frame) as AtlasTexture
	_front.region_rect = stage.region
	_front.visible = _occupied and not is_closed()

## Contador "construcciones/total" arriba del nido, con la fuente del juego.
func _crear_contador() -> void:
	_contador = TextoJuego.crear(contador_font_size)
	_contador.z_index = 2
	_contador.position = TextoJuego.ubicar(_contador, Vector2(0.0, offset.y - contador_margen))
	add_child(_contador)


## Aviso de la tecla G entre el nido y el contador; arranca oculto.
func _crear_aviso() -> void:
	_aviso = TextoJuego.crear(aviso_font_size)
	_aviso.z_index = 2
	_aviso.position = TextoJuego.ubicar(_aviso, Vector2(0.0, offset.y - aviso_margen))
	_aviso.visible = false
	add_child(_aviso)


## Muestra el aviso arriba del nido; con texto vacío lo oculta.
func mostrar_aviso(texto: String) -> void:
	_aviso.text = texto
	_aviso.visible = texto != ""


func _actualizar_contador() -> void:
	_contador.text = "%d/%d" % [_materiales_recibidos, total_construcciones()]


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
	_materiales_recibidos = mini(_materiales_recibidos + 1, total_construcciones())
	_mostrar_etapa()
	resistencia = 1.0  # La construcción nueva arranca intacta
	material_delivered.emit(material)
	# Los que se reusan (las bolas de barro) vuelven a su pool.
	if body.has_method("liberar"):
		body.call("liberar")
	else:
		body.queue_free()


func _perder_construccion() -> void:
	_materiales_recibidos -= 1
	_mostrar_etapa()
	resistencia = 1.0  # La de abajo arranca llena
	construccion_perdida.emit()


## El dibujo avanza una etapa cada `materiales_por_etapa` materiales.
func _mostrar_etapa() -> void:
	frame = floori(float(_materiales_recibidos) / materiales_por_etapa)
	# El contador cambia aunque el dibujo no.
	_actualizar_contador()


## Las etapas no quedan a medio romper: si nadie está picando, la
## construcción vuelve a estar intacta.
func _regenerar(delta: float) -> void:
	_tiempo_sin_danio += delta
	if _tiempo_sin_danio >= PAUSA_SIN_DANIO:
		resistencia = 1.0


## Titila en rojo mientras lo pican; más rápido cuanto menos resistencia queda.
func _actualizar_titileo(delta: float) -> void:
	if not esta_siendo_atacado():
		self_modulate = _color_normal
		_estaba_atacado = false
		return

	if not _estaba_atacado:
		_fase_titileo = 0.0  # Arranca en rojo apenas empieza a picar
		_estaba_atacado = true

	var frecuencia := lerpf(titileos_max, titileos_min, resistencia)
	_fase_titileo += delta * frecuencia
	var en_rojo := fmod(_fase_titileo, 1.0) < 0.5
	self_modulate = color_alerta if en_rojo else _color_normal
