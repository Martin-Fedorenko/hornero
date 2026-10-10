extends BotonTactil
## Palanca de dirección: la perilla sigue al dedo (hasta el borde de la base)
## y muestra hacia dónde se está apretando. Aprieta las mismas acciones que
## las flechas del teclado, enteras como una tecla: la jugabilidad no cambia.
## En las diagonales aprieta dos a la vez, como dos teclas.

const IZQUIERDA := 1
const DERECHA := 2
const ARRIBA := 4
const ABAJO := 8

## Las mismas acciones que las flechas del teclado. Arriba baja el pico y
## abajo lo sube (como el timón de un avión), igual que W / S.
@export var accion_izquierda: StringName = &"move_left"
@export var accion_derecha: StringName = &"move_right"
@export var accion_arriba: StringName = &"pitch_down"
@export var accion_abajo: StringName = &"pitch_up"
## Centro muerto (proporción del radio): ahí no aprieta ninguna dirección.
@export_range(0.0, 0.9) var zona_muerta := 0.22
## Cuánto tiene que apuntar el dedo hacia un eje para apretarlo (0-1). Con 0.5
## cada dirección ocupa ±60° y las diagonales, la franja de 30° a 60°: así, al
## subir o bajar el pico, un dedo un poco corrido no da vuelta al hornero.
@export_range(0.1, 0.95) var umbral_eje := 0.5
## Tamaño de la perilla (proporción del radio de la base).
@export_range(0.1, 0.8) var tamano_perilla := 0.4

## Direcciones apretadas ahora (suma de IZQUIERDA, DERECHA, ARRIBA, ABAJO).
var _direcciones := 0
## Dónde está la perilla, relativa al centro.
var _perilla := Vector2.ZERO


func _al_tocar(punto: Vector2) -> void:
	_mover(punto)


func _al_arrastrar(punto: Vector2) -> void:
	_mover(punto)


func _al_soltar() -> void:
	_perilla = Vector2.ZERO
	_poner(0)
	queue_redraw()


func _mover(punto: Vector2) -> void:
	var desde_centro := punto - _centro_global()
	# La perilla llega hasta el borde de la base, aunque el dedo salga.
	_perilla = desde_centro.limit_length(_radio() * (1.0 - tamano_perilla))
	_poner(_direcciones_de(desde_centro))
	queue_redraw()


func _direcciones_de(desde_centro: Vector2) -> int:
	if desde_centro.length() < _radio() * zona_muerta:
		return 0
	var sentido := desde_centro.normalized()
	var resultado := 0
	if sentido.x < -umbral_eje:
		resultado |= IZQUIERDA
	elif sentido.x > umbral_eje:
		resultado |= DERECHA
	if sentido.y < -umbral_eje:
		resultado |= ARRIBA
	elif sentido.y > umbral_eje:
		resultado |= ABAJO
	return resultado


## Aprieta y suelta sólo las direcciones que cambiaron.
func _poner(nuevas: int) -> void:
	if nuevas == _direcciones:
		return
	var cambiadas := nuevas ^ _direcciones
	_direcciones = nuevas
	for par in [[IZQUIERDA, accion_izquierda], [DERECHA, accion_derecha],
			[ARRIBA, accion_arriba], [ABAJO, accion_abajo]]:
		if cambiadas & par[0]:
			enviar(par[1], bool(nuevas & par[0]))


func _draw() -> void:
	var centro := size * 0.5
	var radio := _radio()
	if radio <= 0.0:
		return
	_dibujar_base(centro, radio, false)
	# Marcas en los cuatro sentidos, para que se lea como palanca de dirección.
	for sentido in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		draw_circle(centro + sentido * radio * 0.8, maxf(2.0, radio * 0.035), COLOR_BORDE)
	var grosor := maxf(3.0, radio * 0.07)
	# Arco iluminado del lado hacia el que se está apretando.
	if _direcciones != 0:
		var angulo := _perilla.angle()
		draw_arc(centro, radio - grosor, angulo - 0.5, angulo + 0.5, 16,
				COLOR_BORDE_APRETADO, grosor, true)
	var perilla := centro + _perilla
	var radio_perilla := radio * tamano_perilla
	draw_circle(perilla, radio_perilla,
			COLOR_FONDO_APRETADO if apretado() else Color(COLOR_LETRAS, 0.45))
	draw_arc(perilla, radio_perilla, 0.0, TAU, 32,
			COLOR_BORDE_APRETADO if apretado() else COLOR_BORDE, maxf(2.0, radio * 0.04), true)
