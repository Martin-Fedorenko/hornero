extends RefCounted
## Etiquetas con la letra del juego: el contador del nido y los avisos de teclas.

const ANCHO := 600.0


## Label centrado en x = 0 dentro de una caja de ANCHO; ubicarlo con `ubicar`.
static func crear(font_size: int) -> Label:
	var fuente := SystemFont.new()
	fuente.font_names = PackedStringArray(["Georgia", "Times New Roman", "serif"])
	fuente.font_weight = 700
	var label := Label.new()
	label.add_theme_font_override("font", fuente)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("f8dc9c"))
	label.add_theme_color_override("font_outline_color", Color("5a2e12"))
	# El contorno acompaña al tamaño de la letra (24 era para 110).
	label.add_theme_constant_override("outline_size", roundi(font_size * 24.0 / 110.0))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.size = Vector2(ANCHO, font_size * 1.5)
	return label


## Posición para que el borde inferior del texto quede en `base`, centrado en x.
static func ubicar(label: Label, base: Vector2) -> Vector2:
	return base - Vector2(label.size.x * 0.5, label.size.y)
