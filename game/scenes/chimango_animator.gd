extends AnimatedSprite2D

@export var base_scale := 0.25
## Frame de "vuelo" que se muestra en picada (alas plegadas). Elegí el que mejor quede.
@export var frame_picada := 0

@onready var _body: Chimango = get_parent()

func _ready() -> void:
	_body.flapped.connect(_on_flapped)
	play("vuelo")

func _process(_delta: float) -> void:
	# Invertimos Y cuando mira a la izquierda porque el cuerpo rota 180°
	scale = Vector2(base_scale, base_scale * _body.facing)

	if _body.modo == Chimango.Modo.PICADA:
		# Alas plegadas: congelamos un frame
		if is_playing():
			stop()
		frame = frame_picada
	elif not is_playing():
		play("vuelo")

func _on_flapped() -> void:
	# Solo arrancamos si estaba frenada; no reiniciamos un aleteo en curso
	if not is_playing():
		play("vuelo")
