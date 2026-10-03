extends Node2D
@onready var bird: CharacterBody2D = $Hornero
var status: Label

func _ready() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_label(layer, "HORNERO", Vector2(42, 28), 34)
	_label(layer, "LABORATORIO DE VUELO  /  SPRITES 2D", Vector2(44, 72), 14)
	_label(layer, "WASD / Flechas: mover     ·     Espacio: mantener planeo", Vector2(44, 111), 18)
	_label(layer, "1  Vuelo     2  Planeo     3  Reposo", Vector2(44, 142), 17)
	status = _label(layer, "", Vector2(44, 651), 17)
	_label(layer, "Movimiento libre · Cambiá a 1 para volver a volar", Vector2(44, 679), 14)
	# Vista comparativa de las tres animaciones.
	var names := [&"vuelo", &"planeo", &"reposo"]
	for i in range(3):
		var preview := AnimatedSprite2D.new()
		preview.sprite_frames = bird.sprite.sprite_frames
		preview.position = Vector2(794 + i * 135, 618)
		preview.scale = Vector2(0.18, 0.18)
		preview.play(names[i])
		add_child(preview)
		_label(layer, String(names[i]).to_upper(), Vector2(758 + i * 135, 678), 12)

func _label(parent: Node, words: String, pos: Vector2, size: int) -> Label:
	var label := Label.new()
	label.text = words
	label.position = pos
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color("#334541"))
	parent.add_child(label)
	return label

func _process(_delta: float) -> void:
	status.text = "MODO: %s   ·   Aleteo: %.0f FPS" % [
		String(bird.sprite.animation).to_upper(), bird.flap_fps]

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1152, 720), Color("#cedbd6"))
	draw_circle(Vector2(1003, 210), 67, Color("#f4e8bf"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 445), Vector2(180, 416), Vector2(350, 446),
		Vector2(550, 411), Vector2(775, 437), Vector2(960, 405),
		Vector2(1152, 430), Vector2(1152, 720), Vector2(0, 720)
	]), Color("#a2b6a6"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 513), Vector2(220, 471), Vector2(490, 509),
		Vector2(740, 475), Vector2(940, 492), Vector2(1152, 465),
		Vector2(1152, 720), Vector2(0, 720)
	]), Color("#839e88"))
	draw_rect(Rect2(0, 573, 1152, 147), Color("#eee6cf"))
	draw_line(Vector2(42, 193), Vector2(360, 193), Color("#839e88"), 2.0)
