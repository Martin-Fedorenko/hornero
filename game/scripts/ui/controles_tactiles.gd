extends CanvasLayer
## Controles en pantalla para celulares y navegadores de celular (sólo los
## crea main.gd cuando Plataforma.tactil). Pulgar derecho: la palanca para
## caminar y dirigir el vuelo. Pulgar izquierdo: aletear, el pico y el nido, en
## arco alrededor del botón grande. Arriba al centro: pausa.
##
## Se acomodan al tamaño de la pantalla (y a sus zonas seguras) sólo cuando
## éste cambia; no hacen nada por cuadro. Con el juego en pausa (menú de
## pausa, derrota o victoria) o el teléfono en vertical se ocultan y sueltan
## todo, así no queda ninguna acción apretada.

## Tamaños (diámetro) y separación pensados para una pantalla de 1280x720;
## se escalan con la pantalla.
@export var diametro_palanca := 250.0
@export var diametro_aletear := 170.0
@export var diametro_accion := 112.0
@export var diametro_pausa := 72.0
## Distancia al borde de la pantalla.
@export var margen := 40.0
## Distancia extra de la palanca al borde derecho, así el pulgar no queda
## contra el canto del teléfono.
@export var margen_palanca_derecha := 90.0
## Espacio entre el botón de aletear y los que lo rodean.
@export var separacion := 18.0
## Ángulos (grados; 0 = derecha, 270 = arriba) de PICO y NIDO alrededor de
## ALETEAR: un arco que el pulgar recorre sin estirarse.
@export var angulo_pico := 345.0
@export var angulo_nido := 285.0

var _pausado := false
var _vertical := false

@onready var _palanca: BotonTactil = $Raiz/Palanca
@onready var _aletear: BotonTactil = $Raiz/Aletear
@onready var _pico: BotonTactil = $Raiz/Pico
@onready var _nido: BotonTactil = $Raiz/Nido
@onready var _pausa: BotonTactil = $Raiz/Pausa
@onready var _botones: Array[BotonTactil] = [_palanca, _aletear, _pico, _nido, _pausa]


func _ready() -> void:
	get_viewport().size_changed.connect(_acomodar)
	_acomodar()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PAUSED:
			_pausado = true
			_actualizar_visibilidad()
		NOTIFICATION_UNPAUSED:
			_pausado = false
			_actualizar_visibilidad()
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED:
			# Llamada, cambio de app: al volver no tiene que seguir aleteando.
			_soltar_todo()


func _acomodar() -> void:
	var area := Plataforma.area_segura()
	var pantalla := get_viewport().get_visible_rect().size
	_vertical = pantalla.y > pantalla.x
	var escala := clampf(minf(pantalla.x / 1280.0, pantalla.y / 720.0), 0.75, 1.5) \
			* Plataforma.escala_botones()
	var borde := margen * escala

	var palanca := diametro_palanca * escala
	_ubicar(_palanca, Vector2(area.end.x - borde - margen_palanca_derecha * escala - palanca * 0.5,area.end.y - borde - palanca * 0.5), palanca)

	var aletear := diametro_aletear * escala
	var centro_aletear := Vector2(area.position.x + borde + aletear * 0.5, area.end.y - borde - aletear * 0.5)
	_ubicar(_aletear, centro_aletear, aletear)

	var accion := diametro_accion * escala
	var distancia := (aletear + accion) * 0.5 + separacion * escala
	_ubicar(_pico, centro_aletear + Vector2.from_angle(deg_to_rad(angulo_pico)) * distancia, accion)
	_ubicar(_nido, centro_aletear + Vector2.from_angle(deg_to_rad(angulo_nido)) * distancia, accion)

	var pausa := diametro_pausa * escala
	_ubicar(_pausa, Vector2(area.get_center().x, area.position.y + borde * 0.5 + pausa * 0.5), pausa)
	_actualizar_visibilidad()


func _ubicar(boton: Control, centro: Vector2, diametro: float) -> void:
	boton.size = Vector2(diametro, diametro)
	boton.position = centro - boton.size * 0.5


func _actualizar_visibilidad() -> void:
	var mostrar := not _pausado and not _vertical
	if not mostrar:
		_soltar_todo()
	visible = mostrar
	# Ocultos no escuchan toques: los menús quedan libres para el dedo.
	for boton in _botones:
		boton.set_process_input(mostrar)


func _soltar_todo() -> void:
	for boton in _botones:
		boton.soltar()
