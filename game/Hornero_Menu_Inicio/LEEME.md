# Menú de inicio del hornero · Godot 4

## Agregarlo a tu proyecto

1. Copiá la carpeta menu_hornero completa junto a project.godot.
   Godot debe mostrar res://menu_hornero/menu_inicio.tscn.
2. Abrí esa escena desde Sistema de archivos. Es una escena independiente:
   NO la arrastres dentro de Laboratorio ni dentro de Hornero.
3. Seleccioná el nodo raíz MenuInicio y mirá el Inspector.
4. Escena Juego apunta por defecto a res://scenes/main.tscn (tu Laboratorio).
   Si tu escena se llama distinto, arrastrala a ese campo.
5. Personalizá el campo Créditos en ese mismo Inspector.
6. Guardá y probá el menú con F6 (ejecutar escena actual).
7. Para que F5 abra primero el menú: clic derecho en menu_inicio.tscn,
   en el panel Sistema de archivos, y elegí Establecer como escena principal
   / Set as Main Scene. También podés configurarlo en Proyecto > Ajustes
   del proyecto > Aplicación > Ejecutar > Escena principal.

La escena de juego debe seguir apuntando a scenes/main.tscn. No configures
Escena Juego con menu_inicio.tscn porque Start volvería al mismo menú.

## Resultado de los botones

- Start: cambia a la escena de juego.
- Cómo jugar: muestra los controles vigentes, incluida E para levantar/soltar.
- Créditos: muestra el texto editable del Inspector.
- Salir: cierra la aplicación. En el editor, detiene la ejecución del juego.
- Volver o Escape: cierra el cuadro de ayuda o créditos.

Funciona con mouse y con flechas/Tab + Enter. Salir está orientado al juego
de escritorio: una exportación web no puede cerrar la pestaña del navegador.

## Dónde modificar cada cosa

- Fondo: menu_hornero/fondo_menu.png.
- Título y subtítulo: nodos Contenido/Columna/Titulo y Subtitulo.
- Etiquetas de botones: propiedad Text de cada Button.
- Instrucciones: constante AYUDA en menu_inicio.gd.
- Texto de créditos y ruta del juego: Inspector de MenuInicio.
- Colores y bordes: funciones _estilizar_boton y _caja del script.

Los botones son controles reales, separados de la imagen de fondo. La escena
contiene los nodos; el script conecta sus señales pressed con las funciones.
Start utiliza get_tree().change_scene_to_file(escena_juego).
Salir utiliza get_tree().quit().

## Escala de pantalla

Preparado para la demo de 1152 × 720, con viewport Stretch Mode = canvas_items.
El fondo conserva su proporción y cubre la ventana (puede recortarse un poco).
Las posiciones de los paneles usan anclas para acompañar el tamaño del viewport.
Si partís de otro proyecto, configurá un viewport de 1152 × 720 y stretch
canvas_items en Ajustes del proyecto > Display > Window.

No modifica el controlador del hornero ni agrega un menú de pausa.
La opción Start inicia la escena de juego desde su estado inicial.

## Arte

Fondo generado con ImageGen. Prompt de diseño: hornero canela musculoso y
caricaturesco, posado sobre el techo de su nido de barro en una rama, paisaje
argentino al amanecer, estilo 2D de contornos definidos, protagonista a la
derecha y zona izquierda oscura despejada para cuatro botones; sin texto
ni interfaz incorporados en la ilustración.
