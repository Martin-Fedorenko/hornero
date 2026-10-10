extends CanvasLayer
## Pantalla de carga: tapa todo mientras una escena se carga en otro hilo y
## la abre al terminar. Con change_scene_to_file la carga ocurre en el hilo
## principal y el juego queda congelado sin mostrar nada (la partida tarda
## unos segundos por las texturas grandes).
##
## precargar() arranca la carga en segundo plano antes de que haga falta (el
## menú la pide al abrirse): si ya terminó, la pantalla casi no llega a verse.

const TextoJuego := preload("res://scripts/ui/texto_juego.gd")

## Escena a abrir.
var ruta: String
## Si la carga falla, se llama con el mensaje de error y la pantalla se cierra.
var al_fallar: Callable

var _barra: ProgressBar
var _progreso: Array = []


## Cambia a `escena` sin dejar un frame vacío en el medio. Con
## change_scene_to_packed la escena vieja se saca en un frame y la nueva se
## agrega en el siguiente, y en ese frame se ve sólo el color de fondo del
## proyecto (un celeste claro). Acá la nueva entra en el mismo frame y la
## vieja se libera al final, así nunca queda la pantalla vacía.
static func reemplazar_escena(arbol: SceneTree, escena: PackedScene) -> void:
	var vieja := arbol.current_scene
	var nueva := escena.instantiate()
	arbol.root.add_child(nueva)
	arbol.current_scene = nueva
	if vieja != null:
		vieja.queue_free()


## Empieza a cargar `ruta` en otro hilo, si no se está cargando ya.
static func precargar(ruta_escena: String) -> void:
	if ResourceLoader.load_threaded_get_status(ruta_escena) == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		ResourceLoader.load_threaded_request(ruta_escena)


func _ready() -> void:
	# Debajo del logo de la UTN (capa 100) y encima de todo lo demás.
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	_armar()
	precargar(ruta)


func _armar() -> void:
	var fondo := ColorRect.new()
	fondo.color = Color(0.06, 0.04, 0.02)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	# Tapa el menú: nada de abajo recibe clics mientras carga.
	fondo.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(fondo)

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.add_child(centro)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 18)
	centro.add_child(columna)

	var texto := TextoJuego.crear(44)
	texto.text = "CARGANDO"
	texto.custom_minimum_size = Vector2(420, 0)
	texto.size = Vector2.ZERO
	columna.add_child(texto)

	_barra = ProgressBar.new()
	_barra.custom_minimum_size = Vector2(420, 18)
	_barra.show_percentage = false
	_barra.max_value = 1.0
	var vacia := StyleBoxFlat.new()
	vacia.bg_color = Color("3f2711")
	vacia.set_corner_radius_all(9)
	var llena := StyleBoxFlat.new()
	llena.bg_color = Color("f8dc9c")
	llena.set_corner_radius_all(9)
	_barra.add_theme_stylebox_override("background", vacia)
	_barra.add_theme_stylebox_override("fill", llena)
	columna.add_child(_barra)


func _process(_delta: float) -> void:
	var estado := ResourceLoader.load_threaded_get_status(ruta, _progreso)
	match estado:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if not _progreso.is_empty():
				_barra.value = _progreso[0]
		ResourceLoader.THREAD_LOAD_LOADED:
			_barra.value = 1.0
			set_process(false)
			var escena := ResourceLoader.load_threaded_get(ruta) as PackedScene
			reemplazar_escena(get_tree(), escena)
		_:
			set_process(false)
			if al_fallar.is_valid():
				al_fallar.call("No se pudo cargar " + ruta)
			queue_free()
