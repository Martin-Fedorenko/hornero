class_name HorneroVitals
extends Node
## Vida y stamina del hornero. No sabe nada de estados ni de input: el
## cuerpo le dice cuánto recuperar y cuándo gastar.

signal health_changed(current: float, maximum: float)
signal stamina_changed(current: float, maximum: float)
## Recibió daño (se emite antes que `died`).
signal damaged(amount: float)
signal died

@export_group("Vida")
@export var max_health := 100.0
## Daño que recibe cuando un chimango lo agarra y lo suelta.
@export var grab_damage := 25.0
## Vida que recupera por segundo mientras descansa en el nido.
@export var nest_heal := 2.0

@export_group("Stamina")
@export var max_stamina := 100.0
## Stamina que cuesta cada aleteo (también el despegue).
@export var flap_cost := 1.0
## Recuperación por segundo mientras planea.
@export var glide_regen := 7.0
## Recuperación por segundo mientras está en el suelo.
@export var ground_regen := 80.0
## Recuperación por segundo mientras descansa en el nido.
@export var nest_regen := 10.0
## Si está activo, al caer al piso tras ser derribado pierde stamina.
@export var drain_on_crash := true
## Fracción de la stamina actual que pierde en esa caída (0.5 = la mitad).
@export_range(0.0, 1.0) var crash_stamina_loss := 0.5

var health := 0.0
var stamina := 0.0


func _ready() -> void:
	health = max_health
	stamina = max_stamina


func can_flap() -> bool:
	return stamina >= flap_cost


func spend_flap() -> void:
	_set_stamina(stamina - flap_cost)


func regenerate(rate: float, delta: float) -> void:
	if rate > 0.0 and stamina < max_stamina:
		_set_stamina(stamina + rate * delta)


## Caída tras ser derribado: pierde `crash_stamina_loss` de la stamina actual.
func drain_stamina() -> void:
	_set_stamina(stamina * (1.0 - crash_stamina_loss))


func take_damage(amount: float) -> void:
	if health <= 0.0 or amount <= 0.0:
		return
	health = maxf(health - amount, 0.0)
	health_changed.emit(health, max_health)
	damaged.emit(amount)
	if health == 0.0:
		died.emit()


## Recupera vida (comer bichos). Muerto ya no se cura.
func heal(amount: float) -> void:
	if health <= 0.0 or amount <= 0.0 or health >= max_health:
		return
	health = minf(health + amount, max_health)
	health_changed.emit(health, max_health)


## Recupera stamina de golpe (comer bichos).
func restore_stamina(amount: float) -> void:
	if health > 0.0 and amount > 0.0 and stamina < max_stamina:
		_set_stamina(stamina + amount)


func _set_stamina(value: float) -> void:
	stamina = clampf(value, 0.0, max_stamina)
	stamina_changed.emit(stamina, max_stamina)
