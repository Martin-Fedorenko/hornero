extends Node2D

@export_range(12.0, 120.0, 1.0) var radio: float = 22.0

var _tiempo := 0.0


func _process(delta: float) -> void:
	_tiempo = fmod(_tiempo + delta, 2.4)
	visible = get_parent().get("recogida") != true
	queue_redraw()


func _draw() -> void:
	var pulso := 0.5 + 0.5 * sin(_tiempo * TAU / 2.4)
	draw_arc(
		Vector2.ZERO,
		radio,
		0.0,
		TAU,
		40,
		Color(1.0, 0.83, 0.37, 0.08 + pulso * 0.08),
		1.5,
		true
	)
	for indice in range(3):
		var fase := fposmod(_tiempo * 0.8 + float(indice) / 3.0, 1.0)
		var brillo := sin(fase * PI)
		if brillo < 0.78:
			continue
		var angulo := TAU * float(indice) / 3.0 - PI / 2.0 + _tiempo * 0.18
		var centro := Vector2(cos(angulo), sin(angulo)) * (radio + 3.0)
		var tamano := 2.0 + brillo * 2.0
		var color := Color(1.0, 0.94, 0.67, brillo)
		draw_line(centro - Vector2(tamano, 0.0), centro + Vector2(tamano, 0.0), color, 1.0, true)
		draw_line(centro - Vector2(0.0, tamano), centro + Vector2(0.0, tamano), color, 1.0, true)