extends Control
## Cartel de madera fileteado, vacío, que se estira a lo ancho sin deformar
## los adornos: los extremos y el adorno del centro mantienen su forma y sólo
## se estiran los tramos lisos que hay entre ellos. Va detrás de la opción
## seleccionada del menú (show_behind_parent), con la palabra escrita encima.

const TEXTURA: Texture2D = preload("res://Hornero_Menu_Inicio/menu_hornero/Cartel fileteado vacio.png")
## x en la textura: fin del extremo izquierdo, inicio y fin del adorno del
## centro e inicio del extremo derecho.
const CORTES: Array[float] = [589.0, 779.0, 1179.0, 1409.0]
## Franja vertical del panel bordó donde va la palabra, en px de la textura.
const PANEL_Y := Vector2(92.0, 402.0)
## Margen del panel bordó dentro de cada extremo, en px de la textura.
const PANEL_EN_EXTREMOS := Vector2(132.0, 100.0)


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	show_behind_parent = true


## Ancho total para que la palabra (de `ancho_texto` px) entre en el panel,
## con `alto` de cartel.
static func ancho_para(ancho_texto: float, alto: float) -> float:
	var escala := alto / TEXTURA.get_height()
	var fijo := CORTES[0] + (CORTES[2] - CORTES[1]) + (TEXTURA.get_width() - CORTES[3])
	var libre := (PANEL_EN_EXTREMOS.x + PANEL_EN_EXTREMOS.y + CORTES[2] - CORTES[1]) * escala
	return fijo * escala + maxf(ancho_texto - libre, 0.0)


func _draw() -> void:
	var alto := size.y
	var escala := alto / TEXTURA.get_height()
	var ancho_textura := float(TEXTURA.get_width())
	var fijo := (CORTES[0] + CORTES[2] - CORTES[1] + ancho_textura - CORTES[3]) * escala
	var tramo := maxf(size.x - fijo, 0.0) * 0.5
	var partes := [
		[0.0, CORTES[0], CORTES[0] * escala],
		[CORTES[0], CORTES[1], tramo],
		[CORTES[1], CORTES[2], (CORTES[2] - CORTES[1]) * escala],
		[CORTES[2], CORTES[3], tramo],
		[CORTES[3], ancho_textura, (ancho_textura - CORTES[3]) * escala],
	]
	var x := 0.0
	for parte in partes:
		var origen := Rect2(parte[0], 0.0, parte[1] - parte[0], TEXTURA.get_height())
		draw_texture_rect_region(TEXTURA, Rect2(x, 0.0, parte[2], alto), origen)
		x += parte[2]
