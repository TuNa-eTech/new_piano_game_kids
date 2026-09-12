shader_type canvas_item;

// Shader Bong Bóng Xà Phòng Ngũ Sắc Chứa Nốt Nhạc (docs/mock-free-play.jpeg)
// Mô phỏng màng mỏng óng ánh (Thin-film iridescence), Fresnel rim glow và biến dạng nhẹ (wobble).

uniform float wobble_speed : hint_range(0.5, 5.0) = 2.0;
uniform float wobble_amplitude : hint_range(0.0, 0.1) = 0.03;
uniform float rainbow_speed : hint_range(0.1, 3.0) = 0.8;
uniform float rim_power : hint_range(0.5, 6.0) = 2.5;
uniform vec4 rim_tint : source_color = vec4(0.85, 0.95, 1.0, 1.0);

void vertex() {
	// Gợn sóng hình học nhẹ mô phỏng bong bóng phập phồng trong không khí
	vec2 center = vec2(0.5, 0.5);
	vec2 dir = VERTEX - center;
	float dist = length(dir);
	float wave = sin(TIME * wobble_speed + dist * 12.0) * wobble_amplitude;
	VERTEX += dir * wave;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	// Khoảng cách từ tâm UV (0.5, 0.5)
	vec2 center = vec2(0.5, 0.5);
	float dist = length(UV - center) * 2.0; // 0 ở tâm, 1 ở viền tròn
	
	if (dist > 1.0) {
		discard;
	}
	
	// Hiệu ứng viền Fresnel (mỏng và sáng ở rìa ngoài)
	float fresnel = pow(clamp(dist, 0.0, 1.0), rim_power);
	
	// Màu cầu vồng ngũ sắc theo góc và thời gian
	float angle = atan(UV.y - 0.5, UV.x - 0.5);
	float rainbow_phase = angle / 6.28318 + TIME * rainbow_speed * 0.2;
	vec3 rainbow = vec3(
		0.5 + 0.5 * cos(rainbow_phase * 6.28318 + 0.0),
		0.5 + 0.5 * cos(rainbow_phase * 6.28318 + 2.094),
		0.5 + 0.5 * cos(rainbow_phase * 6.28318 + 4.188)
	);
	
	// Điểm phản chiếu ánh sáng (Specular glint ở góc trên bên trái)
	vec2 glint_pos = vec2(0.35, 0.35);
	float glint_dist = length(UV - glint_pos);
	float glint = smoothstep(0.15, 0.02, glint_dist) * 0.9;
	
	// Trộn màu: tâm trong suốt cho phép nhìn xuyên qua nốt nhạc bên trong
	vec3 base_col = mix(tex.rgb, rainbow, fresnel * 0.7);
	base_col += vec3(glint);
	
	float alpha = clamp(tex.a * 0.3 + fresnel * 0.75 + glint, 0.0, 1.0);
	COLOR = vec4(base_col * rim_tint.rgb, alpha);
}
