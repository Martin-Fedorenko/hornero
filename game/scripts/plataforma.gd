extends Node
## En qué plataforma corre el juego (autoload "Plataforma"). Es el único lugar
## que lo decide: el resto sólo pregunta `Plataforma.tactil` para saber si
## van los controles en pantalla.
##
## - Escritorio (Windows) y navegador de escritorio: teclado, sin botones.
## - Android nativo y navegador de celular o tablet (Android / iOS): botones
##   táctiles. La misma exportación web sirve para los dos casos.

enum Tipo { ESCRITORIO, WEB_ESCRITORIO, MOVIL, WEB_MOVIL }

## Para probar los controles táctiles desde el editor sin exportar: con true,
## al correr el juego desde Godot aparecen los botones y el mouse hace de
## dedo. No afecta a las exportaciones. También se fuerzan en cualquier build
## pasándole `--tactil` (ver LEEME.md).
const FORZAR_TACTIL_EN_EDITOR := false
## Pantallas más grandes que esto (pulgadas de diagonal) son tablets: los
## botones se achican un poco para no ocupar de más.
const PULGADAS_TABLET := 8.0
## En celulares (app y navegador) se dibuja a 30 cuadros por segundo: gasta
## la mitad de batería y GPU, y el teléfono no se calienta ni baja la
## velocidad por temperatura. La física sigue a 60 por segundo (2 pasos por
## cuadro), así el juego se comporta igual que en la PC.
const FPS_MOVIL := 30
## Pasos de física como mucho por cuadro en celulares. Si el teléfono no llega
## a 30 FPS, el juego se pone un poco más lento en vez de acumular cada vez
## más física por cuadro y trabarse del todo (Godot permite 8 por defecto).
const MAX_PASOS_FISICA_MOVIL := 4
## Resolución base del juego (Configuración del proyecto → Display → Window).
const RESOLUCION_BASE := Vector2i(1280, 720)

var tipo := Tipo.ESCRITORIO
## Se muestran los controles en pantalla.
var tactil := false

var _aviso_girar: CanvasLayer


## En _init y no en _ready: así ya está decidido antes de que arranque
## cualquier otro autoload o escena.
func _init() -> void:
	tipo = _detectar()
	tactil = tipo == Tipo.MOVIL or tipo == Tipo.WEB_MOVIL or _forzado()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Sólo celulares de verdad: probando los controles táctiles en la PC no se
	# limita, así se ven los FPS reales del juego.
	if es_movil():
		Engine.max_fps = FPS_MOVIL
		Engine.max_physics_steps_per_frame = MAX_PASOS_FISICA_MOVIL
		get_window().size_changed.connect(_actualizar_resolucion)
		_actualizar_resolucion()
	if not tactil:
		# En escritorio no hace falta escuchar arrastres ni el botón "atrás".
		set_process_input(false)
		return
	if _forzado() and tipo != Tipo.MOVIL and tipo != Tipo.WEB_MOVIL:
		# Probando en la PC: el clic del mouse hace de dedo.
		Input.emulate_touch_from_mouse = true
	# En Android el botón "atrás" pausa o cierra la ventana abierta, en vez de
	# cerrar el juego de golpe.
	get_tree().quit_on_go_back = false
	if tipo == Tipo.WEB_MOVIL:
		_crear_aviso_girar()


## Celulares: con pantallas de más resolución que la base (por ejemplo
## 2400x1080), el juego se dibuja a la resolución base (alto de 720; el ancho
## se estira según la pantalla, como siempre) y después se agranda a la
## pantalla. Dibuja la mitad de píxeles o menos, a cambio de que textos y
## sprites se vean un poco menos nítidos. En pantallas chicas se dibuja
## directo a su resolución: agrandar la base y achicarla costaría más.
## Se revisa al cambiar el tamaño (girar el teléfono, la barra del navegador).
func _actualizar_resolucion() -> void:
	var ventana := DisplayServer.window_get_size()
	var grande := ventana.x * ventana.y > RESOLUCION_BASE.x * RESOLUCION_BASE.y
	var modo := Window.CONTENT_SCALE_MODE_VIEWPORT if grande else Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	if get_window().content_scale_mode != modo:
		get_window().content_scale_mode = modo


## Celular o tablet: app de Android/iOS o navegador del teléfono.
func es_movil() -> bool:
	return tipo == Tipo.MOVIL or tipo == Tipo.WEB_MOVIL


func es_web() -> bool:
	return tipo == Tipo.WEB_ESCRITORIO or tipo == Tipo.WEB_MOVIL


## Nombre del control para los avisos en pantalla: la tecla en escritorio o
## el botón táctil en celulares ("E para agarrar" / "PICO para agarrar").
func texto_control(tecla: String, boton: String) -> String:
	return boton if tactil else tecla


## La pantalla está en vertical: se juega en horizontal.
func es_vertical() -> bool:
	var tamano := get_viewport().get_visible_rect().size
	return tamano.y > tamano.x


## Zona de la pantalla (en coordenadas del juego) libre de muescas, cámaras y
## bordes redondeados. En escritorio y en la web es la pantalla entera.
func area_segura() -> Rect2:
	var visible_rect := get_viewport().get_visible_rect()
	if tipo != Tipo.MOVIL:
		return visible_rect
	var ventana := Vector2(DisplayServer.window_get_size())
	var segura := Rect2(DisplayServer.get_display_safe_area())
	if ventana.x <= 0.0 or ventana.y <= 0.0 or segura.size.x <= 0.0 or segura.size.y <= 0.0:
		return visible_rect
	segura.position -= Vector2(DisplayServer.window_get_position())
	var escala := visible_rect.size / ventana
	var resultado := Rect2(visible_rect.position + segura.position * escala, segura.size * escala)
	resultado = resultado.intersection(visible_rect)
	return resultado if resultado.has_area() else visible_rect


## Factor para el tamaño de los botones según la pantalla física: en tablets
## se achican. Sólo en Android nativo se conoce la pantalla real.
func escala_botones() -> float:
	if tipo != Tipo.MOVIL:
		return 1.0
	var dpi := DisplayServer.screen_get_dpi()
	if dpi <= 0:
		return 1.0
	var pulgadas := Vector2(DisplayServer.screen_get_size()).length() / dpi
	return 0.8 if pulgadas > PULGADAS_TABLET else 1.0


func _detectar() -> Tipo:
	if OS.has_feature("android") or OS.has_feature("ios"):
		return Tipo.MOVIL
	if not OS.has_feature("web"):
		return Tipo.ESCRITORIO
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		return Tipo.WEB_MOVIL
	return Tipo.WEB_MOVIL if _navegador_movil() else Tipo.WEB_ESCRITORIO


## Respaldo de las etiquetas web_android / web_ios: el iPad con Safari se
## presenta como una Mac, y se lo reconoce porque tiene pantalla táctil. Una
## notebook con pantalla táctil no dice "Mobile" ni es Mac: queda escritorio.
func _navegador_movil() -> bool:
	var resultado: Variant = JavaScriptBridge.eval("""(function () {
		var ua = navigator.userAgent || "";
		if (/Android|iPhone|iPad|iPod|Mobile|Silk|Kindle/i.test(ua)) return true;
		return navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1;
	})()""", true)
	return resultado == true


func _forzado() -> bool:
	if FORZAR_TACTIL_EN_EDITOR and OS.has_feature("editor"):
		return true
	return "--tactil" in OS.get_cmdline_user_args() or "--tactil" in OS.get_cmdline_args()


func _notification(what: int) -> void:
	# Botón "atrás" de Android: lo mismo que Esc (pausa / cerrar ventana).
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and tactil:
		for apretada in [true, false]:
			var evento := InputEventAction.new()
			evento.action = &"ui_cancel"
			evento.pressed = apretada
			Input.parse_input_event(evento)


## Arrastrar el dedo sobre un texto largo (Cómo jugar, Historia, fichas) lo
## desplaza. Los ScrollContainer ya lo hacen solos; los RichTextLabel con su
## propia barra, no. Sólo llegan acá los arrastres que nadie usó antes (los
## botones táctiles del juego marcan los suyos como usados).
func _input(event: InputEvent) -> void:
	if not event is InputEventScreenDrag:
		return
	var control := get_viewport().gui_get_hovered_control()
	while control != null and not control is RichTextLabel:
		control = control.get_parent_control()
	if control == null or not (control as RichTextLabel).scroll_active:
		return
	var barra := (control as RichTextLabel).get_v_scroll_bar()
	if barra.visible:
		barra.value -= (event as InputEventScreenDrag).relative.y


## En el navegador del celular no se puede trabar la orientación: si está en
## vertical, se pide girarlo.
func _crear_aviso_girar() -> void:
	_aviso_girar = CanvasLayer.new()
	_aviso_girar.layer = 120
	var fondo := ColorRect.new()
	fondo.color = Color("243936")
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_aviso_girar.add_child(fondo)
	var texto := Label.new()
	texto.text = "GIRAR_TELEFONO"
	texto.set_anchors_preset(Control.PRESET_FULL_RECT)
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.add_theme_font_override("font", load("res://scripts/ui/texto_juego.gd").fuente())
	texto.add_theme_font_size_override("font_size", 64)
	texto.add_theme_color_override("font_color", Color("f8dc9c"))
	texto.add_theme_color_override("font_outline_color", Color("5a2e12"))
	texto.add_theme_constant_override("outline_size", 14)
	fondo.add_child(texto)
	add_child(_aviso_girar)
	get_viewport().size_changed.connect(_actualizar_aviso_girar)
	_actualizar_aviso_girar()


func _actualizar_aviso_girar() -> void:
	_aviso_girar.visible = es_vertical()
