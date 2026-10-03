shader_type canvas_item;
// Perspectiva atmosférica: acerca el color del sprite al del aire lejano.
// Se usa en árboles y arbustos sueltos para que coincidan con su franja.

uniform vec4 haze_color : source_color = vec4(0.62, 0.72, 0.74, 1.0);
uniform float haze : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, haze_color.rgb, haze);
}
