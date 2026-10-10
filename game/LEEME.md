# Hornero · laboratorio de vuelo (Godot 4.7)

Prototipo jugable de vuelo y planeo. Abrí `project.godot` y pulsá **F5**.

| Control | Acción |
|---|---|
| ↓ / S, ↑ / W | Nariz arriba / abajo, como un avión. Rotación libre: permite loops. Con **Configuración → Timón de vuelo → Directo** se invierte (teclado y palanca táctil, en todas las plataformas) |
| Espacio | Aletear; en el suelo, despegar |
| ← / A, → / D | Caminar en el suelo; en el aire, darse vuelta |
| O | Caer aturdido: sin control hasta el piso, se recupera y vuelve a reposo |
| E | Pico: agarrar / soltar |
| G | Nido: entrar / salir (acción `hornero_nido`) |

## Plataformas y controles táctiles

Un solo proyecto, cuatro versiones. `scripts/plataforma.gd` (autoload
`Plataforma`) decide cuál es y el resto sólo pregunta `Plataforma.tactil`:

| Versión | Detección | Controles |
|---|---|---|
| Windows | ni `web` ni `android` | Teclado, sin botones |
| Web en PC | `web` sin `web_android` / `web_ios` ni user agent de celular | Teclado, sin botones |
| Android | feature `android` | Botones en pantalla |
| Web en celular / tablet | `web_android`, `web_ios` o user agent móvil (iPad incluido) | Botones en pantalla |

Los botones (`scenes/ui/controles_tactiles.tscn`, sólo los crea `main.gd` en
celulares) aprietan las mismas acciones del Input Map que el teclado:
palanca (abajo a la derecha) → `move_left` / `move_right` / `pitch_down` (↑) / `pitch_up` (↓),
ALETEAR (abajo a la izquierda) → `flap`, PICO → `hornero_interactuar`, NIDO → `hornero_nido`,
pausa → `ui_cancel`. Multitouch: cada botón sigue a su dedo. En pausa o con el
teléfono en vertical se ocultan y sueltan todo. En Android el botón "atrás"
hace de Esc.

En celulares (app y navegador) el juego se dibuja a **30 FPS** para gastar
menos batería y GPU; la física sigue a 60 por segundo, así se juega igual que
en la PC (`FPS_MOVIL` en `scripts/plataforma.gd`). En pantallas de más
resolución que 1280x720 se dibuja a la resolución base (alto de 720) y se
agranda a la pantalla (modo de escalado "viewport"): menos píxeles por cuadro,
a cambio de un poco menos de nitidez. Probando con `--tactil` en la PC no se
aplica nada de esto.

### Exportar

`Proyecto → Exportar…`:

- **Windows Desktop** → `../build/windows/Hornero.exe`.
- **Hornero-web** → `release/web/index.html`. Para itch.io: comprimir el
  contenido de `release/web` en un .zip, subirlo como HTML y marcar "This file
  will be played in the browser". La misma exportación sirve en PC y celular.
- **Android** → `../build/android/Hornero.apk`. Requiere configurar una vez en
  `Editor → Configuración del editor → Exportar → Android` el Android SDK y el
  JDK 17; el keystore de debug lo crea Godot. Para publicar, cargar un keystore
  de release en el preset.

### Probar los controles táctiles en la PC

- **Desde el editor:** poner `FORZAR_TACTIL_EN_EDITOR := true` en
  `scripts/plataforma.gd` y pulsar F5: aparecen los botones y el clic hace de
  dedo (un solo dedo a la vez). No afecta a las exportaciones.
- **Cualquier build:** pasar `--tactil` (en el editor: `Proyecto →
  Configuración → Editor → Run → Main Run Args` = `-- --tactil`).
- **Web móvil:** exportar web, abrirla en Chrome y activar el modo dispositivo
  de las DevTools (Ctrl+Shift+M) con un celular elegido; recargar la página.
- **Celular real sin exportar a mano:** con el teléfono conectado por USB y
  depuración activada, el botón de Android de la barra del editor (Remote
  Debug) instala y corre el juego en un clic. Ahí se prueba el multitouch.

## Idiomas (español / inglés)

Todos los textos que se ven en el juego están en `scripts/textos.gd`, cada uno
con su versión en español (Argentina) y en inglés (Estados Unidos). El
autoload `Idioma` (`scripts/idioma.gd`) los carga en el `TranslationServer` de
Godot y aplica el idioma guardado en `Ajustes` (`user://ajustes.cfg`). Se
cambia con el botón **ES / EN** del menú principal, al lado del de silenciar.

- En el código y en las escenas se usa la **clave** (`"MENU_JUGAR"`), no el
  texto. Un `Label`, `Button` o `RichTextLabel` con una clave en `text` se
  traduce solo y se actualiza al cambiar de idioma. Por eso en el editor se
  ven las claves.
- Textos armados en código (con `%s`): `tr("CLAVE") % valor` o
  `Idioma.t("CLAVE")` desde funciones estáticas.
- "Cómo jugar" (`AYUDA`) tiene `{MARCAS}` que completa `texto_ayuda()` en
  `menu_inicio.gd` según teclado/pantalla táctil y el timón elegido.

## Estructura

```text
scenes/main.tscn            Nivel: piso, paredes, plataformas, cámara, HUD
scenes/nest_tree.tscn       Árbol (tree_asset.png). El origen es la base del
                            tronco, sobre el piso. En main.tscn lleva de hijo
                            al nido, que se puede mover libremente
scenes/nest.tscn            Nido de hornero (nest_asset.png), animación "crecer".
                            El origen es la base del nido
scenes/hornero.tscn         Hornero (CharacterBody2D)
├── CollisionShape2D        Círculo: no cambia al rotar el cuerpo
├── AnimatedSprite2D        hornero_animator.gd
├── FlightDebug             Flecha amarilla = forward, celeste = velocidad
├── FlightMotor             Física de vuelo y todos sus parámetros
└── GroundMotor             Caminar
scripts/hornero/hornero.gd        Máquina de estados FLYING / GLIDING / GROUND /
                                  FALLING / RECOVERING
scripts/hornero/hornero_input.gd  Única lectura del teclado
scripts/world/platform.gd         Rectángulo visible con collider (sólo borde
                                  superior, o sólido con `solid`)
scripts/world/meadow_floor.gd     Piso de pastizal con assets/floor/floor_assets.png:
                                  franjas de pasto fundidas entre sí
                                  (strip_fade.gdshader) y piedras, matas y charcos
                                  al azar según `random_seed`. Sólo el piso colisiona
assets/hornero/                   Sprites del hornero
├── hornero_frames.tres           Animaciones: vuelo, planeo, reposo, caminar,
│                                 caida, recuperarse
└── hornero_recover_frames.png    Cuadros de hornero_recover.png separados
                                  (en el original se superponen)
```

## Modelo de vuelo

`pitch → rotation → forward → velocity → move_and_slide()`

- `forward = Vector2.RIGHT.rotated(rotation)`. Mirando a la izquierda el
  cuerpo gira 180° y el sprite se invierte en Y para quedar derecho.
- La gravedad suma velocidad hacia abajo; la sustentación gira la velocidad
  hacia `forward` sin cambiar su módulo, y es proporcional al flujo de aire
  a lo largo del cuerpo. Por debajo de `stall_speed` entra en pérdida y la
  nariz cae sola. La resistencia del aire quita energía: subir cuesta
  velocidad, bajar la devuelve.
- El aleteo suma `flap_impulse` en la dirección `forward + arriba` y
  cancela parte de la caída.

Los parámetros se ajustan en el Inspector de los nodos `FlightMotor`,
`GroundMotor`, `AnimatedSprite2D` (poses) y `Camera2D` (en `main.tscn`).
