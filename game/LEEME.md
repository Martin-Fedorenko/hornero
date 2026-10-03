# Hornero · laboratorio de vuelo (Godot 4.7)

Prototipo jugable de vuelo y planeo. Abrí `project.godot` y pulsá **F5**.

| Control | Acción |
|---|---|
| ↓ / S, ↑ / W | Nariz arriba / abajo, como un avión. Rotación libre: permite loops |
| Espacio | Aletear; en el suelo, despegar |
| ← / A, → / D | Caminar en el suelo; en el aire, darse vuelta |

## Estructura

```text
scenes/main.tscn            Nivel: piso, paredes, plataformas, cámara, HUD
scenes/hornero.tscn         Hornero (CharacterBody2D)
├── CollisionShape2D        Círculo: no cambia al rotar el cuerpo
├── AnimatedSprite2D        hornero_animator.gd
├── FlightDebug             Flecha amarilla = forward, celeste = velocidad
├── FlightMotor             Física de vuelo y todos sus parámetros
└── GroundMotor             Caminar
scripts/hornero/hornero.gd        Máquina de estados FLYING / GLIDING / GROUND
scripts/hornero/hornero_input.gd  Única lectura del teclado
scripts/world/platform.gd         Rectángulo visible con collider (sólo borde
                                  superior, o sólido con `solid`)
assets/hornero_frames.tres        Animaciones: vuelo, planeo, reposo, caminar
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
