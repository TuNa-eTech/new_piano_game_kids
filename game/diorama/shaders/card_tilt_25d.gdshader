shader_type canvas_item;

// Biến dạng phối cảnh 2.5D & Vệt sáng vàng kim quét qua thẻ chương
uniform vec2 tilt_offset = vec2(0.0, 0.0); // Độ nghiêng từ con trỏ/cảm ứng (-1.0 -> 1.0)
uniform float tilt_factor : hint_range(0.0, 0.15) = 0.045;
uniform vec4 gold_sheen_color : source_color = vec4(1.0, 0.92, 0.55, 0.85);
uniform float sheen_speed : hint_range(0.2, 2.0) = 0.8;
uniform float sheen_width : hint_range(0.05, 0.4) = 0.18;
uniform bool is_unlocked = true;

void vertex() {
	// Biến dạng đỉnh tạo cảm giác thẻ 3D nghiêng về phía người chạm
	VERTEX.x += (UV.y - 0.5) * tilt_offset.x * tilt_factor * 120.0;
	VERTEX.y += (UV.x - 0.5) * tilt_offset.y * tilt_factor * 120.0;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	if (tex.a < 0.02) {
		discard;
	}

	vec3 final_rgb = tex.rgb;

	// Vệt sáng vàng kim quét qua thẻ đang mở khóa
	if (is_unlocked) {
		float sweep = mod(TIME * sheen_speed, 4.0) - 1.5;
		float dist = abs((UV.x * 1.2 + UV.y * 0.6) - sweep);
		float sheen = smoothstep(sheen_width, 0.0, dist);
		final_rgb += sheen * gold_sheen_color.rgb * gold_sheen_color.a * 0.45;
	}

	COLOR = vec4(final_rgb, tex.a);
}
