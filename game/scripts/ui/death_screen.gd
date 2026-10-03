extends Control
## Cartel de "HAS MUERTO". Aparece un rato después de que el hornero queda
## tirado; Enter reinicia el nivel (Esc al menú lo maneja main.gd).

## Segundos que el hornero queda tirado antes de mostrar el cartel.
@export var delay := 5.0
## Duración del fundido de entrada.
@export var fade_time := 0.6


func _ready() -> void:
	visible = false


func show_after_delay() -> void:
	await get_tree().create_timer(delay).timeout
	modulate.a = 0.0
	visible = true
	create_tween().tween_property(self, "modulate:a", 1.0, fade_time)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	var key := event as InputEventKey
	if key and key.pressed and not key.echo \
			and (key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER):
		get_viewport().set_input_as_handled()
		get_tree().reload_current_scene()
