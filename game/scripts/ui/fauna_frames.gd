extends RefCounted
## Recorta una hoja de sprites de la pestaña Fauna en cuadros. Lo usan tanto
## la ficha chica (menu_inicio.gd) como la ventana de detalle (popup_animal.gd).

## Recorta una franja de alto fijo por fila para que el animal no salte entre
## cuadros. `margen_x`: píxeles descartados a cada lado de cada columna; sirve
## para las hojas en filmina continua, donde el cuadro vecino invade el borde
## (como las de caminata). Las láminas de Hornero_Fauna_14_Animales no tienen
## ese problema: cada pose va en su propia celda, así que usan margen_x = 0.
static func cortar(hoja: Texture2D, columnas: int, filas_y: Array, alto: float, margen_x: float = 10.0) -> Array[Texture2D]:
	var ancho := float(hoja.get_width()) / columnas
	var cuadros: Array[Texture2D] = []
	for y in filas_y:
		for columna in columnas:
			var cuadro := AtlasTexture.new()
			cuadro.atlas = hoja
			cuadro.region = Rect2(columna * ancho + margen_x, y, floorf(ancho) - margen_x * 2.0, alto)
			cuadros.append(cuadro)
	return cuadros
