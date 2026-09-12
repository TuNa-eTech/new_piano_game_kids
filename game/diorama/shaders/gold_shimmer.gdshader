shader_type canvas_item;

// Hào quang vàng kim mạ nổi & vệt sáng quét qua biểu tượng Khóa Son / Chữ sách
uniform vec4 shine_color : source_color = vec4(1.0, 0.96, 0.65, 0.9);
uniform float speed : hint_range(0.5, 3.0) = 1.25;
uniform float shine_width : hint_range(0.05, 0.5) = 0.22;
uniform float pulse_intensity : hint_range(0.0, 0.6) = 0.18;
uniform float pulse_speed : hint_range(0.5, 4.0) = 2.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	if (tex.a < 0.03) {
		discard;
	}

	// Nhịp thở phát sáng nhẹ (organic breathing pulse)
	float pulse = (0.5 + 0.5 * sin(TIME * pulse_speed)) * pulse_intensity;

	// Vệt sáng vàng kim quét chéo góc 45 độ
	float shine_line = mod(TIME * speed, 3.8) - 1.2;
	float dist = abs((UV.x + UV.y * 0.45) - shine_line);
	float shine = smoothstep(shine_width, 0.0, dist);

	vec3 final_rgb = tex.rgb + pulse * vec3(0.35, 0.28, 0.08);
	final_rgb += shine * shine_color.rgb * shine_color.a;

	COLOR = vec4(final_rgb, tex.a);
}
