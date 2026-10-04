extends AnimatedSprite2D

signal material_delivered(material: StringName)
## Se emite cuando la Cotorra rompe una construcción del nido.
signal construccion_perdida

const MATERIALS: Array[StringName] = [&"paja", &"piedra", &"maderita", &"barro"]
## Si no recibe daño durante este tiempo, se considera que nadie lo está picando.
const PAUSA_SIN_DANIO := 0.2

@export_group("Resistencia")
## Segundos que tarda una cotorra picando sin parar en romper una construcción.
## Si pican dos a la vez, tardan la mitad.
@export_range(0.5, 60.0, 0.5, "or_greater") var segundos_por_construccion := 10.0
## Segundos que tarda la barra en llenarse sola, desde vacía, cuando nadie pica.
## En 0 no se regenera.
@export_range(0.0, 120.0, 0.5, "or_greater") var segundos_regeneracion := 0.0

@export_group("Alerta")
## Color del titileo mientras pican el nido. Valores mayores a 1 hacen que brille.
@export var color_alerta := Color(1.6, 0.3, 0.3)
## Titileos por segundo con la construcción intacta (recién empieza a picar).
@export_range(0.5, 20.0, 0.5) var titileos_min := 3.0
## Titileos por segundo cuando la construcción está por romperse.
@export_range(0.5, 20.0, 0.5) var titileos_max := 10.0

@onready var _delivery_area: Area2D = $DeliveryArea
@onready var _aura: Node2D = $DestelloLevantable
var _materiales_recibidos: int = 0

## Resistencia de la construcción de más arriba: 1 = intacta, 0 = se rompe.
var resistencia := 1.0
var _tiempo_sin_danio := PAUSA_SIN_DANIO  # Arranca como "nadie pica"

var _color_normal := Color.WHITE
var _fase_titileo := 0.0
var _estaba_atacado := false


func _ready() -> void:
	animation = &"crecer"
	stop()
	frame = 0
	_color_normal = self_modulate
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


## ¿Lo están picando ahora?
func esta_siendo_atacado() -> bool:
	return _tiempo_sin_danio < PAUSA_SIN_DANIO


## La llama la Cotorra en cada frame que pica, con los segundos que pasaron.
func recibir_danio(segundos: float) -> void:
	_tiempo_sin_danio = 0.0
	if frame == 0:
		return  # Sin construcciones no hay nada que romper
	resistencia -= segundos / segundos_por_construccion
	if resistencia <= 0.0:
		_perder_construccion()


func _process(delta: float) -> void:
	_actualizar_titileo(delta)


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
	resistencia = 1.0  # La construcción nueva arranca intacta
	material_delivered.emit(material)
	body.queue_free()


func _perder_construccion() -> void:
	frame -= 1
	# Se iguala al frame por si hubo entregas de más con el nido completo
	_materiales_recibidos = frame
	resistencia = 1.0  # La de abajo arranca llena
	construccion_perdida.emit()


## Si nadie está picando, la barra se recupera de a poco (si está activado).
func _regenerar(delta: float) -> void:
	_tiempo_sin_danio += delta
	if segundos_regeneracion <= 0.0 or _tiempo_sin_danio < PAUSA_SIN_DANIO:
		return
	resistencia = minf(resistencia + delta / segundos_regeneracion, 1.0)


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
