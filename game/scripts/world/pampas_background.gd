class_name PampasBackground
extends Node2D
## Fondo parallax de llanura pampeana: cielo fijo a la pantalla + capas
## Parallax2D que se repiten solas hacia ambos lados (`repeat_size`).
##
## Las capas están compuestas en coordenadas de pantalla (viewport 1152x720)
## tal como se ven con la cámara en su posición de referencia. Al iniciar,
## cada capa se ancla a esa posición; al subir la cámara, las capas cercanas
## bajan más rápido que las lejanas y el horizonte casi no se mueve.

## Y del borde superior de la cámara (en el mundo) para la que está compuesto
## el fondo. En el laboratorio: cámara apoyada en el límite inferior
## (`world_rect.end.y` - alto del viewport), con el piso en y=560 de pantalla.
@export var reference_camera_top := 1080.0


func _ready() -> void:
	for layer: Parallax2D in find_children("*", "Parallax2D", false):
		layer.scroll_offset.y = layer.scroll_scale.y * reference_camera_top
