class_name FlightMotor
extends Node
## Física de vuelo simplificada basada en velocidad, gravedad y el vector
## forward del cuerpo. No mueve al cuerpo: recibe y devuelve vectores.
##
## Modelo:
## - La gravedad siempre suma velocidad hacia abajo.
## - La sustentación gira la velocidad hacia forward sin cambiar su módulo
##   (no crea energía). Su fuerza depende del flujo de aire a lo largo del
##   cuerpo: con poca velocidad hacia adelante el ave entra en pérdida.
## - La resistencia del aire quita energía. Subir cambia velocidad por altura;
##   bajar cambia altura por velocidad.

@export_group("Gravedad")
@export var gravity := 900.0 ## px/s²
@export var max_fall_speed := 900.0 ## px/s
@export var max_flight_speed := 1100.0 ## px/s

@export_group("Planeo")
## Velocidad de giro de la velocidad hacia forward con sustentación plena (rad/s).
@export var lift_turn_rate := 3.5
## Flujo de aire hacia adelante necesario para tener sustentación plena (px/s).
@export var stall_speed := 260.0
## Fracción de velocidad que se pierde por segundo.
@export_range(0.0, 2.0, 0.01) var air_drag := 0.3

@export_group("Rotación")
## Velocidad con la que ↑/↓ cambian el ángulo (grados/s).
@export var rotation_speed_deg := 180.0
## Si está activo, la inclinación se limita a ±max_pitch_deg. Desactivado
## permite rotar 360° (loops y backflips).
@export var limit_pitch := false
@export_range(5.0, 89.0) var max_pitch_deg := 60.0
## En pérdida la nariz cae hacia la dirección de movimiento (grados/s).
@export var stall_nose_drop_deg := 110.0

@export_group("Aleteo")
@export var flap_impulse := 330.0 ## px/s sumados en cada aleteo
## Cuánto de "arriba" se mezcla con forward para la dirección del aleteo.
@export_range(0.0, 3.0, 0.05) var flap_lift_bias := 1.0
## Fracción de la velocidad de caída que cancela un aleteo.
@export_range(0.0, 1.0, 0.05) var flap_fall_cancel := 0.5
## Inclinación inicial al despegar desde el suelo (grados).
@export var takeoff_pitch_deg := 25.0

@export_group("Giro")
## Fracción de la velocidad horizontal que se conserva al darse vuelta en el aire.
@export_range(0.0, 1.0, 0.05) var turn_speed_keep := 0.4


## Avanza la velocidad un paso de física.
func integrate(velocity: Vector2, forward: Vector2, delta: float) -> Vector2:
	velocity.y += gravity * delta
	velocity = _apply_lift(velocity, forward, delta)
	velocity -= velocity * air_drag * delta
	velocity = velocity.limit_length(max_flight_speed)
	velocity.y = minf(velocity.y, max_fall_speed)
	return velocity


## Nuevo pitch a partir del input y de la pérdida de sustentación.
## facing: 1 derecha, -1 izquierda. Pitch positivo = nariz arriba.
func update_pitch(pitch: float, pitch_input: float, velocity: Vector2,
		forward: Vector2, facing: int, delta: float) -> float:
	pitch += pitch_input * deg_to_rad(rotation_speed_deg) * delta
	var stall := 1.0 - lift_factor(velocity, forward)
	if stall > 0.0 and velocity.length_squared() > 1.0:
		var motion_pitch := atan2(-velocity.y, velocity.x * facing)
		var max_step := deg_to_rad(stall_nose_drop_deg) * stall * delta
		pitch += clampf(angle_difference(pitch, motion_pitch), -max_step, max_step)
	if limit_pitch:
		var limit := deg_to_rad(max_pitch_deg)
		return clampf(pitch, -limit, limit)
	return wrapf(pitch, -PI, PI)


## Impulso de aleteo: hacia forward con un sesgo hacia arriba.
func flap(velocity: Vector2, forward: Vector2) -> Vector2:
	if velocity.y > 0.0:
		velocity.y *= 1.0 - flap_fall_cancel
	var direction := (forward + Vector2.UP * flap_lift_bias).normalized()
	return velocity + direction * flap_impulse


## Media vuelta en el aire: invierte y amortigua la velocidad horizontal.
func turn_around(velocity: Vector2) -> Vector2:
	velocity.x *= -turn_speed_keep
	return velocity


func takeoff_pitch() -> float:
	return deg_to_rad(takeoff_pitch_deg)


## 0 = en pérdida, 1 = sustentación plena.
func lift_factor(velocity: Vector2, forward: Vector2) -> float:
	var airflow := maxf(velocity.dot(forward), 0.0)
	return clampf(airflow / stall_speed, 0.0, 1.0)


func _apply_lift(velocity: Vector2, forward: Vector2, delta: float) -> Vector2:
	var lift := lift_factor(velocity, forward)
	if lift <= 0.0:
		return velocity
	var angle_of_attack := velocity.angle_to(forward)
	var max_turn := lift_turn_rate * lift * delta
	return velocity.rotated(clampf(angle_of_attack, -max_turn, max_turn))
