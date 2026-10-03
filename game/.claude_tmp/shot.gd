extends SceneTree
func _initialize() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	var bird: CharacterBody2D = main.get_node("Hornero")
	var cam: Camera2D = main.get_node("Hornero/Camera2D")
	# Buscar props de adelante para pararse justo detrás de uno.
	var front: Node = main.get_node("World/Piso").get_child(0, true).get_node("Adelante")
	var xs := [600.0]
	for i in [2, 7]:
		var s: Sprite2D = front.get_child(i)
		xs.append(s.position.x + s.region_rect.size.x * s.scale.x * 0.5)
	var n := 0
	for x in xs:
		bird.position = Vector2(x, 1450)
		bird.knock_down()
		for i in 150:
			await physics_frame
		print("x=", x, " estado=", bird.state, " y=", bird.position.y)
		cam.reset_smoothing()
		await process_frame
		await process_frame
		root.get_texture().get_image().save_png("C:/Users/60099351/AppData/Local/Temp/claude/c--Users-60099351-source-repos-utn-game-jam-2026/427f2ade-177f-428b-bbe0-67f2628629a0/scratchpad/h%d.png" % n)
		n += 1
	quit()
