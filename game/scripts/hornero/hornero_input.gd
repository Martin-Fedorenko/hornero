class_name HorneroInput
extends RefCounted
## Único punto donde se lee el teclado. El resto del código recibe esta foto
## del input y no conoce los nombres de las acciones.

var move := 0.0   ## -1 izquierda, 1 derecha.
var pitch := 0.0  ## 1 nariz arriba, -1 nariz abajo.
var flap := false ## Verdadero sólo en el cuadro en que se presiona.
var fall := false ## Verdadero sólo en el cuadro en que se presiona.

## Foto del frame de física en curso. Es siempre el mismo objeto: se lee una
## sola vez por frame aunque la pidan el hornero y la rapaz que lo tiene
## agarrado, y no se crea uno nuevo en cada frame. Se usa en el momento y no
## se guarda: en el frame siguiente cambia.
static var _foto := HorneroInput.new()
static var _frame_foto := -1


static func read() -> HorneroInput:
	var frame := Engine.get_physics_frames()
	if _frame_foto == frame:
		return _foto
	_frame_foto = frame
	_foto.move = Input.get_axis(&"move_left", &"move_right")
	_foto.pitch = Input.get_axis(&"pitch_down", &"pitch_up")
	# Timón "Directo" (Configuración): arriba sube el pico.
	if Ajustes.timon_directo:
		_foto.pitch = -_foto.pitch
	_foto.flap = Input.is_action_just_pressed(&"flap")
	_foto.fall = Input.is_action_just_pressed(&"fall")
	return _foto
