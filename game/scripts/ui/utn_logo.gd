extends CanvasLayer
## Logo de la UTN en la esquina inferior izquierda de todas las pantallas (autoload).
## En los menús se ve bien; mientras se juega queda casi transparente para no molestar.

const LOGO := preload("res://Hornero_Menu_Inicio/png-transparent-utn-hd-logo.png")
const ESCENA_JUEGO := "res://scenes/main.tscn"
## La imagen trae el fondo a cuadros pintado: lo oscuro es el logo y se pinta de
## `tinte`; lo claro (el fondo) queda transparente.
const SHADER := """
shader_type canvas_item;
uniform vec4 tinte : source_color = vec4(1.0);
void fragment() {
	float luz = dot(texture(TEXTURE, UV).rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(tinte.rgb, tinte.a * (1.0 - smoothstep(0.25, 0.6, luz)) * COLOR.a);
}
"""

@export var alto := 56.0
@export var margen := Vector2(16, 16)
@export var alfa_menu := 0.85
@export var alfa_jugando := 0.12
## Color de las letras del logo "HORNERO".
@export var tinte := Color("f8dc9c")

var _logo: TextureRect
## La escena actual y si es la del juego: la ruta sólo se compara cuando
## cambia la escena, no en cada frame.
var _escena_vista := 0
var _es_juego := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_logo = TextureRect.new()
	_logo.texture = LOGO
	_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ancho := alto * LOGO.get_width() / LOGO.get_height()
	_logo.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_logo.offset_left = margen.x
	_logo.offset_right = margen.x + ancho
	_logo.offset_top = -margen.y - alto
	_logo.offset_bottom = -margen.y
	var shader := Shader.new()
	shader.code = SHADER
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("tinte", tinte)
	_logo.material = material
	_logo.modulate.a = _alfa_objetivo()
	add_child(_logo)


func _process(delta: float) -> void:
	var objetivo := _alfa_objetivo()
	# Ya llegó: no se toca el modulate (cada escritura redibuja el logo).
	if is_equal_approx(_logo.modulate.a, objetivo):
		return
	_logo.modulate.a = move_toward(_logo.modulate.a, objetivo, delta * 2.0)


## Se está jugando cuando la escena es la del juego y no hay ningún menú abierto
## (los menús de pausa, derrota y victoria pausan el árbol).
func _alfa_objetivo() -> float:
	var arbol := get_tree()
	var escena := arbol.current_scene
	var id := escena.get_instance_id() if escena != null else 0
	if id != _escena_vista:
		_escena_vista = id
		_es_juego = escena != null and escena.scene_file_path == ESCENA_JUEGO
	var jugando := _es_juego and not arbol.paused
	return alfa_jugando if jugando else alfa_menu
