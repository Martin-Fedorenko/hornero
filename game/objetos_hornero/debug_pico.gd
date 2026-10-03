extends Node2D
var pico := Vector2.ZERO
var marcador := Vector2.ZERO
var objeto := Vector2.ZERO
var hay_marcador := false
var hay_objeto := false

func _draw() -> void:
	draw_line(pico - Vector2(6,0), pico + Vector2(6,0), Color.LIME_GREEN, 2)
	draw_line(pico - Vector2(0,6), pico + Vector2(0,6), Color.LIME_GREEN, 2)
	if hay_marcador:
		draw_arc(marcador, 5, 0, TAU, 24, Color.MAGENTA, 1.5)
		draw_line(marcador, pico, Color.MAGENTA, 1)
	if hay_objeto:
		draw_arc(objeto, 4, 0, TAU, 20, Color.YELLOW, 1.5)
		draw_line(pico, objeto, Color.YELLOW, 1)
