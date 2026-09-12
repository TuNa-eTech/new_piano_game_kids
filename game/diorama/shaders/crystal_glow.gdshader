shader_type canvas_item;

// Hiệu ứng ánh sáng huỳnh quang cyan huyền ảo cho tinh thể thạch anh
uniform vec4 glow_color : source_color = vec4(0.2, 0.9, 0.95, 0.85);
uniform float pulse_speed : hint_range(0.5, 4.0) = 1.8;
uniform float intensity : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	if (tex.a < 0.05) {
		discard;
	}

	float wave = 0.5 + 0.5 * sin(TIME * pulse_speed + UV.y * 3.0);
	vec3 glow = glow_color.rgb * wave * intensity;

	COLOR = vec4(tex.rgb + glow, tex.a);
}
