extends RefCounted
## Pool de nodos: en vez de liberar un objeto que se crea y se destruye seguido
## (rapaces, bichos, bolas de barro, manchas), se lo guarda apagado para
## reusarlo después.
##
## Guardado, el nodo sigue en su lugar en la escena pero oculto y con
## PROCESS_MODE_DISABLED: no corre _process ni _physics_process, sus tweens y
## animaciones quedan quietos y, si es un cuerpo, sale de la física. Como sigue
## en la escena, se libera con ella; el pool sólo guarda referencias.
##
## Quien lo usa se encarga de reiniciar el estado del nodo reusado: tomar()
## indica con `es_nuevo()` si hay que agregarlo al árbol o reiniciarlo.

## Pools compartidos por escena (PackedScene → pool).
static var _por_escena := {}

var _fabrica: Callable
var _libres: Array[Node] = []


## `fabrica`: crea un nodo nuevo cuando no hay ninguno libre.
func _init(fabrica: Callable) -> void:
	_fabrica = fabrica


## Pool compartido de una escena, para objetos que crean varios dueños (por
## ejemplo, las bolas de todos los charcos).
static func de_escena(escena: PackedScene):
	if not _por_escena.has(escena):
		_por_escena[escena] = new(escena.instantiate)
	return _por_escena[escena]


## Un nodo libre ya encendido (visible y procesando), o uno nuevo fuera del
## árbol si no queda ninguno.
func tomar() -> Node:
	while not _libres.is_empty():
		var nodo: Node = _libres.pop_back()
		# El pool no es dueño: pudo liberarse con su escena.
		if not is_instance_valid(nodo) or nodo.is_queued_for_deletion() \
				or not nodo.is_inside_tree():
			continue
		nodo.process_mode = Node.PROCESS_MODE_INHERIT
		if nodo is CanvasItem:
			(nodo as CanvasItem).show()
		return nodo
	return _fabrica.call()


## Si el nodo que devolvió tomar() hay que agregarlo al árbol (es nuevo) o
## reiniciarlo (es reusado).
static func es_nuevo(nodo: Node) -> bool:
	return not nodo.is_inside_tree()


## Lo apaga y lo guarda para reusar. Diferido: se lo suele devolver desde una
## señal de física, donde no se puede sacar un cuerpo del espacio.
func devolver(nodo: Node) -> void:
	_guardar.call_deferred(nodo)


func _guardar(nodo: Node) -> void:
	if not is_instance_valid(nodo) or nodo.is_queued_for_deletion() or _libres.has(nodo):
		return
	if not nodo.is_inside_tree():
		# Sin árbol no hay escena que lo libere después.
		nodo.queue_free()
		return
	if nodo is CanvasItem:
		(nodo as CanvasItem).hide()
	nodo.process_mode = Node.PROCESS_MODE_DISABLED
	_libres.append(nodo)


## Cuántos nodos hay guardados (para depurar).
func libres() -> int:
	return _libres.size()
