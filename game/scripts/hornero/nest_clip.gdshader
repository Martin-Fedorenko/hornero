shader_type canvas_item;
// Recorta el dibujo del hornero cuando está en el nido, en coordenadas del
// mundo: 0 = sin recorte, 1 = oculta lo que queda debajo de clip_line (el
// borde delantero del nido abierto), 2 = sólo deja ver lo que cae dentro del
// círculo (la entrada del nido cerrado).

uniform int clip_mode = 0;
uniform float clip_line = 0.0;
uniform vec2 clip_center = vec2(0.0);
uniform float clip_radius = 0.0;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	if (clip_mode == 1 && world_pos.y > clip_line) {
		discard;
	}
	if (clip_mode == 2 && distance(world_pos, clip_center) > clip_radius) {
		discard;
	}
}
