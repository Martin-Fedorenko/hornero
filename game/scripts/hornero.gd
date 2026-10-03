extends CharacterBody2D
## Prueba de movimiento libre: todavía no simula sustentación ni gravedad.
@export var speed: float = 280.0
@export var acceleration: float = 8500.0
@export var flap_fps: float = 30.0
@export var limit_to_viewport: bool = true
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var mode: StringName = &"vuelo"

func _ready() -> void:
	# Se registran también al instanciar esta escena en otro proyecto.
	_bind(&"hornero_left", [KEY_A, KEY_LEFT])
	_bind(&"hornero_right", [KEY_D, KEY_RIGHT])
	_bind(&"hornero_up", [KEY_W, KEY_UP])
	_bind(&"hornero_down", [KEY_S, KEY_DOWN])
	_bind(&"hornero_glide", [KEY_SPACE])
	sprite.sprite_frames.set_animation_speed(&"vuelo", flap_fps)
	sprite.play(mode)
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	up_direction = Vector2.UP
	floor_snap_length = 6.0

func _bind(action: StringName, keys: Array) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	for key in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key
		InputMap.action_add_event(action, event)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event is InputEventKey:
		match event.physical_keycode:
			KEY_1: mode = &"vuelo"
			KEY_2: mode = &"planeo"

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector(
		&"hornero_left", &"hornero_right",
		&"hornero_up", &"hornero_down"
	)

	var horizontal := Input.get_axis(
		&"hornero_left", &"hornero_right"
	)

	var despegar := (
		is_on_floor()
		and Input.is_action_pressed(&"hornero_up")
	)

	# Elegir cómo se mueve según el contacto con el piso.
	if is_on_floor() and not despegar:
		velocity.x = horizontal * 140.0

		# Pequeña velocidad hacia abajo para mantener el contacto.
		velocity.y = 20.0
	else:
		velocity = velocity.move_toward(
			direction * speed,
			acceleration * delta
		)

		if despegar:
			velocity.y = -speed
			mode = &"vuelo"

	# Resolver el movimiento y actualizar la detección del piso.
	move_and_slide()

	# Elegir la animación DESPUÉS de comprobar las colisiones.
	var animation: StringName

	if is_on_floor():
		sprite.rotation = 0.0

		if horizontal != 0.0:
			sprite.flip_h = horizontal < 0.0
			animation = &"caminar"
		else:
			animation = &"reposo"
	else:
		animation = &"vuelo"

		if mode == &"planeo" or Input.is_action_pressed(&"hornero_glide"):
			animation = &"planeo"

		# Conservar la orientación diagonal durante el vuelo.
		if direction != Vector2.ZERO:
			sprite.rotation = direction.angle()
			sprite.flip_h = direction.x < 0.0

			if sprite.flip_h:
				sprite.rotation += PI

	if limit_to_viewport:
		var size := get_viewport_rect().size
		position.x = clampf(position.x, 70.0, size.x - 70.0)

		# Límite superior. El límite inferior ahora es el piso físico.
		if position.y < 180.0:
			position.y = 180.0
			velocity.y = maxf(velocity.y, 0.0)

	var visual_scale := 0.20 if animation == &"caminar" else 0.24
	sprite.scale = Vector2(visual_scale, visual_scale)
	sprite.play(animation)
