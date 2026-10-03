# Hornero: sprites y prueba en Godot 4

Primera versión para prototipar el personaje. El PNG tiene transparencia real.
Los dibujos fueron generados con IA; se configuraron recortes y márgenes por
cuadro para reducir el movimiento involuntario de la cabeza. Hay pequeñas
variaciones de forma entre cuadros: es una base de prototipo, todavía no una
animación pulida a mano.

## Probar en un minuto

1. Descomprimí el ZIP completo.
2. Abrí Godot 4.x, edición Standard (no hace falta .NET).
3. En el administrador de proyectos, elegí **Importar** y seleccioná
   `hornero_godot/project.godot`.
4. Abrí el proyecto y esperá la importación del PNG.
5. Pulsá **F6** con `scenes/main.tscn` abierta, o **F5** para ejecutar el proyecto.

| Control | Resultado |
|---|---|
| Flechas o WASD | Movimiento libre en ocho direcciones |
| 1 | Ciclo de vuelo: seis cuadros, 12 FPS |
| Espacio, mantenido | Pose de planeo mientras está activo el modo vuelo |
| 2 | Mantener la pose de planeo |
| 3 | Mostrar pose de reposo y detener el movimiento |

La vista inferior muestra las tres animaciones simultáneamente. El hornero
se refleja al moverse a la izquierda. Planeo y reposo son poses de un cuadro,
no ciclos animados completos. Para volver a moverte desde reposo, pulsá 1 o 2.

## Qué contiene

- `assets/hornero_sheet.png`: ocho dibujos en una sola imagen transparente.
- `assets/hornero_frames.tres`: recurso SpriteFrames con animaciones listas.
- `assets/atlas_regions.json`: coordenadas de cada recorte y sus márgenes.
- `scenes/hornero.tscn`: personaje reutilizable con AnimatedSprite2D y colisión.
- `scripts/hornero.gd`: movimiento, cambio de orientación y animaciones.
- `scenes/main.tscn`: escena de prueba.
- `scripts/main.gd`: fondo simple y controles visibles.

Orden de los dibujos: fila superior de izquierda a derecha = cuadros 0 a 3;
fila inferior = cuadros 4 a 7. Cuadros 0–5: vuelo; 6: planeo; 7: reposo.

## Usarlo en tu propio proyecto

Copiá las carpetas `assets`, `scenes` y `scripts` dentro de tu proyecto,
conservando las rutas relativas. Si ya existen archivos con los mismos
nombres, mové este paquete a una subcarpeta y corregí las rutas `res://`
de sus recursos antes de usarlo.

Arrastrá `scenes/hornero.tscn` sobre tu nivel. El personaje registra sus
controles al iniciar. En niveles con cámara o mapas mayores a la ventana,
desactivá **Limit To Viewport** en el Inspector del nodo Hornero.

Para utilizar solo las imágenes, agregá un nodo **AnimatedSprite2D** y
arrastrá `assets/hornero_frames.tres` a **Sprite Frames**. Seleccioná
`vuelo` y activá su reproducción automática. Usá escala **0.24, 0.24**
como punto de partida; cada cuadro tiene un lienzo lógico de 512 × 512.

**Usá el recurso .tres incluido en lugar del recorte automático 4 × 2**:
la hoja generada mide 1774 × 887 y los dibujos no coinciden exactamente
con celdas iguales. Los AtlasTexture incluidos ya tienen recortes y
márgenes individuales. No hace falta editar el PNG.

## Ajustes sencillos

- Seleccioná Hornero: **Speed** cambia la velocidad de desplazamiento.
- **Acceleration** cambia cuánto tarda en acelerar y frenar.
- **Flap FPS** cambia la velocidad del aleteo al ejecutar.
- En AnimatedSprite2D → Sprite Frames podés editar el orden de los cuadros.
- `flip_h` invierte la imagen para mirar a la izquierda.

El desplazamiento es una prueba sencilla de control. No incluye física de
vuelo con empuje y gravedad, recolección, enemigos ni aterrizaje automático.
El reposo es una pose de inspección que se muestra donde esté el personaje.
El cuerpo de colisión está preparado, pero esta escena no contiene obstáculos.

Referencia oficial:
https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html
