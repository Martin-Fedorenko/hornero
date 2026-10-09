extends Control
## Mapa esquemático de distribución aproximada dentro de Sudamérica.

const COLOR_TIERRA := Color("c7c2ae")
const COLOR_MAR := Color("182a28")
const COLOR_RANGO := Color(0.88, 0.18, 0.16, 0.78)
const COLOR_CONTORNO := Color("e8ddc1")

const CONTORNO: Array[Vector2] = [
	Vector2(0.36, 0.02), Vector2(0.51, 0.04), Vector2(0.58, 0.10),
	Vector2(0.77, 0.14), Vector2(0.82, 0.23), Vector2(0.75, 0.31),
	Vector2(0.69, 0.36), Vector2(0.66, 0.47), Vector2(0.61, 0.56),
	Vector2(0.59, 0.68), Vector2(0.54, 0.78), Vector2(0.50, 0.90),
	Vector2(0.45, 0.99), Vector2(0.40, 0.91), Vector2(0.38, 0.80),
	Vector2(0.33, 0.71), Vector2(0.29, 0.59), Vector2(0.25, 0.50),
	Vector2(0.18, 0.40), Vector2(0.15, 0.30), Vector2(0.22, 0.21),
	Vector2(0.28, 0.13), Vector2(0.34, 0.10),
]

const RANGOS := {
	"sudamerica": [[Vector2(0.18, 0.06), Vector2(0.78, 0.15), Vector2(0.75, 0.34), Vector2(0.65, 0.53), Vector2(0.57, 0.68), Vector2(0.50, 0.91), Vector2(0.40, 0.88), Vector2(0.31, 0.61), Vector2(0.18, 0.40)]],
	"amplio": [[Vector2(0.18, 0.07), Vector2(0.77, 0.15), Vector2(0.72, 0.38), Vector2(0.62, 0.57), Vector2(0.56, 0.73), Vector2(0.48, 0.93), Vector2(0.39, 0.84), Vector2(0.30, 0.60), Vector2(0.17, 0.39)]],
	"norte": [[Vector2(0.20, 0.06), Vector2(0.76, 0.14), Vector2(0.75, 0.31), Vector2(0.65, 0.43), Vector2(0.52, 0.49), Vector2(0.39, 0.43), Vector2(0.22, 0.34)]],
	"andino": [[Vector2(0.18, 0.12), Vector2(0.32, 0.16), Vector2(0.35, 0.39), Vector2(0.40, 0.58), Vector2(0.43, 0.76), Vector2(0.47, 0.91), Vector2(0.41, 0.94), Vector2(0.35, 0.77), Vector2(0.31, 0.58), Vector2(0.26, 0.38)]],
	"cono_sur": [[Vector2(0.32, 0.57), Vector2(0.62, 0.56), Vector2(0.59, 0.70), Vector2(0.55, 0.82), Vector2(0.49, 0.96), Vector2(0.41, 0.90), Vector2(0.36, 0.79), Vector2(0.30, 0.67)]],
	"pampas": [[Vector2(0.37, 0.58), Vector2(0.61, 0.57), Vector2(0.59, 0.70), Vector2(0.54, 0.77), Vector2(0.43, 0.74), Vector2(0.35, 0.68)]],
	"rio_plata": [[Vector2(0.43, 0.49), Vector2(0.64, 0.48), Vector2(0.62, 0.66), Vector2(0.56, 0.74), Vector2(0.43, 0.70), Vector2(0.38, 0.59)]],
	"norte_este": [[Vector2(0.37, 0.31), Vector2(0.73, 0.29), Vector2(0.67, 0.51), Vector2(0.59, 0.61), Vector2(0.44, 0.58), Vector2(0.36, 0.47)]],
	"aguaraguazu": [[Vector2(0.31, 0.23), Vector2(0.39, 0.18), Vector2(0.57, 0.17), Vector2(0.69, 0.22), Vector2(0.73, 0.31), Vector2(0.69, 0.42), Vector2(0.64, 0.51), Vector2(0.59, 0.60), Vector2(0.56, 0.69), Vector2(0.48, 0.72), Vector2(0.42, 0.66), Vector2(0.39, 0.56), Vector2(0.36, 0.45), Vector2(0.35, 0.34)]],
	"patagonia": [[Vector2(0.31, 0.70), Vector2(0.56, 0.67), Vector2(0.52, 0.85), Vector2(0.46, 0.98), Vector2(0.40, 0.90), Vector2(0.35, 0.82)]],
	"norte_andes": [[Vector2(0.18, 0.08), Vector2(0.56, 0.08), Vector2(0.58, 0.31), Vector2(0.46, 0.43), Vector2(0.33, 0.40), Vector2(0.22, 0.31)]],
}

var region: String = "sudamerica"


func _ready() -> void:
	custom_minimum_size = Vector2(210, 230)
	queue_redraw()


func set_region(nueva_region: String) -> void:
	region = nueva_region
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), COLOR_MAR, true)
	var area := Rect2(Vector2(10, 8), size - Vector2(20, 18))
	var costa := _escalar_poligono(CONTORNO, area)
	draw_colored_polygon(costa, COLOR_TIERRA)
	for zona: Array in RANGOS.get(region, RANGOS["sudamerica"]):
		draw_colored_polygon(_escalar_poligono(zona, area), COLOR_RANGO)
	var costa_cerrada := costa.duplicate()
	costa_cerrada.append(costa[0])
	draw_polyline(costa_cerrada, COLOR_CONTORNO, 2.0, true)


func _escalar_poligono(puntos: Array, area: Rect2) -> PackedVector2Array:
	var resultado := PackedVector2Array()
	for punto: Vector2 in puntos:
		resultado.append(area.position + punto * area.size)
	return resultado
