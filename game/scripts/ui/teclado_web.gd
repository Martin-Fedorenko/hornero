extends Node
## Teclado del celular para un LineEdit cuando el juego corre en el navegador
## de un celular o tablet. Se agrega como hijo del LineEdit.
##
## El navegador (sobre todo Safari en iOS) sólo abre el teclado si se enfoca un
## <input> de la página dentro del mismo toque del usuario. Godot procesa los
## toques un cuadro después, así que no llega a tiempo. Por eso se pone un
## <input> invisible en la página: al tocar la zona del campo, JavaScript lo
## enfoca en ese mismo toque y el texto que se escribe se copia al LineEdit.

## Enter en el teclado del celular.
signal enviado()

const JS_PREPARAR := """(function () {
	if (window.horneroTeclado) return;
	var input = document.createElement("input");
	input.type = "text";
	input.autocomplete = "off";
	input.setAttribute("autocorrect", "off");
	input.spellcheck = false;
	// 16px evita que iOS haga zoom al enfocarlo.
	input.style.cssText = "position:fixed;left:0;top:0;width:1px;height:1px;opacity:0;" +
		"border:0;padding:0;font-size:16px;";
	document.body.appendChild(input);
	var t = { input: input, zona: null, valor: "", max: 0, onInput: null, onEnter: null };
	var canvas = document.getElementById("canvas") || document.querySelector("canvas");
	canvas.addEventListener("touchend", function (e) {
		var z = t.zona;
		if (!z || !e.changedTouches.length) return;
		var r = canvas.getBoundingClientRect();
		var toque = e.changedTouches[0];
		var x = (toque.clientX - r.left) / r.width;
		var y = (toque.clientY - r.top) / r.height;
		if (x < z[0] || x > z[0] + z[2] || y < z[1] || y > z[1] + z[3]) return;
		input.value = t.valor;
		input.maxLength = t.max > 0 ? t.max : 524288;
		input.focus();
	}, { passive: true });
	input.addEventListener("input", function () {
		if (t.onInput) t.onInput(input.value);
	});
	input.addEventListener("keydown", function (e) {
		if (e.key !== "Enter") return;
		e.preventDefault();
		input.blur();
		if (t.onEnter) t.onEnter(input.value);
	});
	window.horneroTeclado = t;
})();"""

var _campo: LineEdit
var _teclado: JavaScriptObject
# Hay que guardar las callbacks: si se liberan, JavaScript no puede llamarlas.
var _al_escribir: JavaScriptObject
var _al_enviar: JavaScriptObject


func _ready() -> void:
	_campo = get_parent() as LineEdit
	JavaScriptBridge.eval(JS_PREPARAR, true)
	_teclado = JavaScriptBridge.get_interface("horneroTeclado")
	_al_escribir = JavaScriptBridge.create_callback(_on_escrito)
	_al_enviar = JavaScriptBridge.create_callback(_on_enviado)
	_teclado.onInput = _al_escribir
	_teclado.onEnter = _al_enviar
	# Godot no abre su propio teclado: lo abre el <input> de la página.
	_campo.virtual_keyboard_enabled = false
	_campo.text_changed.connect(_pasar_texto.unbind(1))
	_campo.item_rect_changed.connect(_actualizar_zona)
	get_viewport().size_changed.connect(_actualizar_zona)
	_pasar_texto()
	_actualizar_zona.call_deferred()


func _exit_tree() -> void:
	if _teclado == null:
		return
	_teclado.zona = null
	_teclado.onInput = null
	_teclado.onEnter = null
	JavaScriptBridge.eval("window.horneroTeclado.input.blur();", true)


## Llamar si el campo se oculta o deja de ser editable: entonces tocarlo no
## abre el teclado (y si estaba abierto, se cierra).
func actualizar_zona() -> void:
	_actualizar_zona()


## Zona del campo en la pantalla, de 0 a 1 respecto del canvas.
func _actualizar_zona() -> void:
	if not is_inside_tree():
		return
	if not _campo.is_visible_in_tree() or not _campo.editable:
		JavaScriptBridge.eval("window.horneroTeclado.zona = null; window.horneroTeclado.input.blur();", true)
		return
	var ventana := Vector2(DisplayServer.window_get_size())
	if ventana.x <= 0.0 or ventana.y <= 0.0:
		return
	var rect := _campo.get_viewport().get_final_transform() \
			* (_campo.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, _campo.size))
	JavaScriptBridge.eval("window.horneroTeclado.zona = [%f, %f, %f, %f];" % [
			rect.position.x / ventana.x, rect.position.y / ventana.y,
			rect.size.x / ventana.x, rect.size.y / ventana.y], true)


func _pasar_texto() -> void:
	JavaScriptBridge.eval("window.horneroTeclado.valor = %s; window.horneroTeclado.max = %d;" % [
			JSON.stringify(_campo.text), _campo.max_length], true)


func _on_escrito(args: Array) -> void:
	var texto := str(args[0])
	if _campo.max_length > 0:
		texto = texto.left(_campo.max_length)
	if texto == _campo.text:
		return
	# Igual que si se hubiera escrito en el LineEdit (avisa con text_changed).
	_campo.text = texto
	_campo.caret_column = texto.length()
	_campo.text_changed.emit(texto)


func _on_enviado(_args: Array) -> void:
	enviado.emit()
