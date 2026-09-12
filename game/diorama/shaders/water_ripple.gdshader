shader_type canvas_item;

// Shader sóng nước ma thuật lăn tăn cho Thẻ Chương 2 (Hồ Nước Kalimba)
uniform float ripple_speed : hint_range(0.5, 4.0) = 1.8;
uniform float wave_frequency : hint_range(5.0, 30.0) = 16.0;
uniform float wave_amplitude : hint_range(0.001, 0.02) = 0.005;
uniform vec4 water_tint : source_color = vec4(0.12, 0.55, 0.75, 0.25);

void fragment() {
	// Biến dạng sóng nước hình elip lan tỏa từ chiếc đàn Kalimba
	vec2 center = vec2(0.5, 0.65);
	vec2 diff = UV - center;
	diff.y *= 1.8; // Tạo tỉ lệ phối cảnh dẹp 2.5D
	float dist = length(diff);

	vec2 wave_uv = UV;
	float wave = sin(dist * wave_frequency - TIME * ripple_speed);
	wave_uv += (diff / (dist + 0.001)) * wave * wave_amplitude * smoothstep(0.45, 0.05, dist);

	vec4 tex = texture(TEXTURE, wave_uv);
	// Hòa trộn màu xanh ngọc bích của mặt nước
	tex.rgb = mix(tex.rgb, tex.rgb + water_tint.rgb, water_tint.a * (0.5 + 0.5 * wave));

	COLOR = tex;
}
