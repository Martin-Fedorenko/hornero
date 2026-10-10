extends Control
## Ventana de confirmación con "Cancelar" y "Aceptar", con el estilo de las
## ventanas del menú. Esc cancela. Emite `respondido` y se cierra sola.

signal respondido(aceptado: bool)

const PopupNombre := preload("res://scripts/ui/popup_nombre.gd")

var titulo := ""
var mensaje := ""
var texto_aceptar := "ACEPTAR"


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var columna := PopupNombre.armar_ventana(self, titulo, mensaje)

	var botones := HBoxContainer.new()
	botones.add_theme_constant_override("separation", 12)
	columna.add_child(botones)
	var cancelar := PopupNombre.boton("CANCELAR", false)
	cancelar.pressed.connect(_responder.bind(false))
	botones.add_child(cancelar)
	var aceptar := PopupNombre.boton(texto_aceptar, true)
	aceptar.pressed.connect(_responder.bind(true))
	botones.add_child(aceptar)

	# Por las dudas, arranca seleccionado "Cancelar".
	cancelar.grab_focus.call_deferred()


func _responder(aceptado: bool) -> void:
	respondido.emit(aceptado)
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_responder(false)
