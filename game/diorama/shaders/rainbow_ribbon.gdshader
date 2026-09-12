shader_type canvas_item;

// Shader Dải Lụa Cầu Vồng Âm Nhạc (docs/mock-free-play.jpeg)
// Tạo dải màu cầu vồng phát quang cuộn trôi theo nhịp nhạc, viền mềm mại.

uniform float scroll_speed : hint_range(-5.0, 5.0) = 1.2;
uniform float frequency : hint_range(1.0, 10.0) = 3.5;
uniform float emission_strength : hint_range(1.0, 3.0) = 1.6;
uniform float alpha_edge_feather : hint_range(0.01, 0.4) = 0.15;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	// Trôi UV x theo thời gian
	float u = UV.x - TIME * scroll_speed * 0.2;
	
	// Dải quang phổ 7 màu cầu vồng (Red -> Violet)
	float phase = fract(u * frequency);
	vec3 rainbow = vec3(
		0.5 + 0.5 * sin(phase * 6.28318 + 0.0),
		0.5 + 0.5 * sin(phase * 6.28318 + 2.094),
		0.5 + 0.5 * sin(phase * 6.28318 + 4.188)
	);
	
	// Độ phát sáng lấp lánh (Shimmer pulse)
	float shimmer = 0.85 + 0.15 * sin(TIME * 4.0 + UV.x * 10.0);
	vec3 final_color = rainbow * shimmer * emission_strength * tint.rgb;
	
	// Làm mềm biên trên dưới (y edge feathering)
	float edge_dist = min(UV.y, 1.0 - UV.y);
	float edge_alpha = smoothstep(0.0, alpha_edge_feather, edge_dist);
	
	// Đọc texture gốc nếu có (khuông nhạc hoặc nốt sao)
	vec4 tex = texture(TEXTURE, UV);
	float alpha = tex.a * edge_alpha * tint.a;
	
	COLOR = vec4(final_color, alpha);
}
