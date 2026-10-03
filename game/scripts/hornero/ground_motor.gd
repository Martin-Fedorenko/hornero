class_name GroundMotor
extends Node
## Movimiento terrestre: caminar a izquierda/derecha y frenar sin input.

@export var walk_speed := 140.0 ## px/s
@export var walk_acceleration := 900.0 ## px/s²
@export var walk_deceleration := 1400.0 ## px/s²
## Pequeña velocidad hacia abajo que mantiene el contacto con el piso.
@export var floor_stick_speed := 20.0


func integrate(velocity: Vector2, move_input: float, delta: float) -> Vector2:
	var target := target_speed(move_input)
	var rate := walk_acceleration if move_input != 0.0 else walk_deceleration
	velocity.x = move_toward(velocity.x, target, rate * delta)
	velocity.y = floor_stick_speed
	return velocity


func target_speed(move_input: float) -> float:
	return move_input * walk_speed
