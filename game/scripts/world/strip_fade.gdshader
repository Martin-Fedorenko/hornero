shader_type canvas_item;
// Funde el borde izquierdo (en pantalla) de una franja de piso con la
// anterior: el alfa sube de 0 a 1 a lo largo de `fade_width` píxeles.

uniform float fade_width = 96.0;
// Región del atlas que dibuja el Sprite2D, en píxeles.
uniform float region_x = 0.0;
uniform float region_w = 1.0;
uniform bool flipped = false;

void fragment() {
	float x = UV.x * float(textureSize(TEXTURE, 0).x) - region_x;
	if (flipped) {
		x = region_w - x;
	}
	COLOR.a *= smoothstep(0.0, fade_width, x);
}
