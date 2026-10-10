extends RefCounted
## Procesamiento por cercanía a la cámara, con el VisibleOnScreenEnabler2D de
## Godot: fuera de la pantalla (más un margen) el nodo objetivo pasa a
## PROCESS_MODE_DISABLED y deja de correr _process, _physics_process, sus
## animaciones, tweens y, si es un cuerpo, su física. Al volver a acercarse se
## reactiva tal como quedó, sin perder estado.
##
## El dibujo fuera de cámara ya lo descarta Godot solo; esto ahorra el
## procesamiento.


## Agrega a `contenedor` un enabler que apaga `objetivo` cuando el rectángulo
## `rect` (local a `contenedor`), agrandado `margen` píxeles de pantalla por
## lado, sale de la cámara.
##
## Ojo: si `contenedor` se oculta (visible = false), el enabler cuenta como
## fuera de pantalla. Si el que se oculta es el propio objetivo, poné el
## enabler en un nodo que no se oculte; si no, nunca vuelve a encenderse.
static func activar_cerca_de_camara(objetivo: Node, contenedor: Node2D,
		rect: Rect2, margen: float) -> VisibleOnScreenEnabler2D:
	var enabler := VisibleOnScreenEnabler2D.new()
	enabler.name = "ProcesoPorCercania"
	# El rect es local: el margen se pasa a esas unidades.
	var escala := contenedor.global_scale.abs() if contenedor.is_inside_tree() \
			else contenedor.scale.abs()
	var margen_local := Vector2(
			margen / maxf(escala.x, 0.001), margen / maxf(escala.y, 0.001))
	enabler.rect = rect.grow_individual(
			margen_local.x, margen_local.y, margen_local.x, margen_local.y)
	# La ruta es relativa al enabler, que queda como hijo de `contenedor`.
	if objetivo == contenedor:
		enabler.enable_node_path = ^".."
	else:
		enabler.enable_node_path = NodePath("../%s" % contenedor.get_path_to(objetivo))
	contenedor.add_child(enabler)
	return enabler
