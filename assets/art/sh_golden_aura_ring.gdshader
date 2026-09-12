shader_type canvas_item;
## Shader Vòng Hào Quang Vàng Xoay Động (Golden Aura Ring)
## Áp dụng cho chân bục màn chơi đang chọn (Bục 4 / Vị trí bạn Thỏ)

uniform vec4 aura_color : source_color = vec4(1.0, 0.85, 0.32, 0.95);
uniform vec4 inner_color : source_color = vec4(1.0, 0.96, 0.70, 0.65);
uniform float ring_radius : hint_range(0.2, 0.5) = 0.40;
uniform float ring_thickness : hint_range(0.02, 0.15) = 0.055;
uniform float pulse_speed : hint_range(0.5, 6.0) = 2.6;
uniform float rotation_speed : hint_range(-4.0, 4.0) = 1.4;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	// Phối cảnh elip 2.5D nhìn xiên góc 18 độ
	uv.y *= 1.65;
	float dist = length(uv);

	// Góc xoay
	float angle = atan(uv.y, uv.x) + TIME * rotation_speed;

	// Nhịp thở phập phồng ấm áp
	float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);
	float cur_radius = ring_radius + pulse * 0.03;

	// Tạo độ dày và viền mờ cho vòng tròn
	float ring = smoothstep(cur_radius - ring_thickness, cur_radius, dist)
	           - smoothstep(cur_radius, cur_radius + ring_thickness, dist);

	// Gợn sóng ánh sáng xoay quanh vành hào quang
	float shimmer = 0.75 + 0.25 * sin(angle * 5.0 + TIME * 2.0);

	vec4 col = mix(aura_color, inner_color, pulse) * ring * shimmer;
	col.a *= (0.65 + 0.35 * pulse);

	COLOR = col;
}
