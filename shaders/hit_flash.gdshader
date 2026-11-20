shader_type canvas_item;
// Mixes everything drawn toward flash_color. HitFlash animates `flash` from 1 to 0 on each hit.

uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, flash_color.rgb, flash);
}
