extends Node2D

@export_range(1, 3, 1) var bolas_maximas: int = 3
@export var escena_bola: PackedScene
@export var textura_seca: Texture2D
@export var posicion_bola: Vector2 = Vector2(0, 15)

var bolas_restantes: int = 0
var bola_disponible: RigidBody2D
var dibujo_charco: Sprite2D
var tamano_charco := Vector2.ZERO
var region_charco: Rect2 = Rect2()

func _ready() -> void:
	bolas_restantes = bolas_maximas
	_crear_bola()

## La bola ya no cuelga del charco: si el piso se rearma, se lleva la suya.
func _exit_tree() -> void:
	if is_instance_valid(bola_disponible) and bola_disponible.get("recogida") != true:
		bola_disponible.queue_free()

func configurar_charco(dibujo: Sprite2D, tamano: Vector2) -> void:
	dibujo_charco = dibujo
	tamano_charco = tamano
	region_charco = dibujo.region_rect

func registrar_bola_recogida(bola: RigidBody2D) -> void:
	if bola != bola_disponible:
		return
	bola_disponible = null
	bolas_restantes = maxi(bolas_restantes - 1, 0)
	if bolas_restantes == 0:
		_secar_charco()
	else:
		call_deferred("_crear_bola")

func _secar_charco() -> void:
	if not is_instance_valid(dibujo_charco) or textura_seca == null:
		return
	dibujo_charco.texture = textura_seca
	dibujo_charco.region_enabled = true
	dibujo_charco.region_rect = region_charco
	dibujo_charco.centered = true
	dibujo_charco.position = position
	dibujo_charco.scale = Vector2(
		tamano_charco.x / region_charco.size.x,
		tamano_charco.y / region_charco.size.y)

func _crear_bola() -> void:
	if bolas_restantes <= 0 or is_instance_valid(bola_disponible) or escena_bola == null:
		return
	var nueva_bola := escena_bola.instantiate() as RigidBody2D
	if nueva_bola == null:
		push_error("La escena de bola de barro debe tener un RigidBody2D como raíz.")
		return
	nueva_bola.set("fuente", self)
	bola_disponible = nueva_bola
	# Diferido: el charco nace mientras se arma el piso y la escena todavía no
	# acepta hijos nuevos.
	_colocar_bola.call_deferred(nueva_bola)

## La bola va junto a los demás levantables (hijos de la escena principal) y
## no dentro de las capas del piso, donde quedaría tapada por el pasto.
func _colocar_bola(bola: RigidBody2D) -> void:
	if not is_instance_valid(bola) or not is_inside_tree():
		return
	var escena := get_tree().current_scene
	var vecino: Node = null
	if escena != null:
		for candidato in escena.get_children():
			if candidato != bola and candidato.is_in_group(&"levantables"):
				vecino = candidato
	if vecino != null:
		vecino.add_sibling(bola)
	elif escena != null:
		escena.add_child(bola)
	else:
		get_parent().add_child(bola)
	bola.global_position = global_position + posicion_bola
