# Hornero · laboratorio de vuelo (Godot 4.7)

Prototipo jugable de vuelo y planeo. Abrí `project.godot` y pulsá **F5**.

| Control | Acción |
|---|---|
| ↓ / S, ↑ / W | Nariz arriba / abajo, como un avión. Rotación libre: permite loops |
| Espacio | Aletear; en el suelo, despegar |
| ← / A, → / D | Caminar en el suelo; en el aire, darse vuelta |
| O | Caer aturdido: sin control hasta el piso, se recupera y vuelve a reposo |

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
