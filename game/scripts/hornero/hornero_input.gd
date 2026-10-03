class_name HorneroInput
extends RefCounted
## Único punto donde se lee el teclado. El resto del código recibe esta foto
## del input y no conoce los nombres de las acciones.

var move := 0.0   ## -1 izquierda, 1 derecha.
var pitch := 0.0  ## 1 nariz arriba, -1 nariz abajo.
var flap := false ## Verdadero sólo en el cuadro en que se presiona.
var fall := false ## Verdadero sólo en el cuadro en que se presiona.


static func read() -> HorneroInput:
	var input := HorneroInput.new()
	input.move = Input.get_axis(&"move_left", &"move_right")
	input.pitch = Input.get_axis(&"pitch_down", &"pitch_up")
	input.flap = Input.is_action_just_pressed(&"flap")
	input.fall = Input.is_action_just_pressed(&"fall")
	return input
