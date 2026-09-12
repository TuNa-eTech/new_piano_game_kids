shader_type canvas_item;
## Shader Phối Cảnh Nghiêng 2.5D & Vệt Sáng Vàng Kim (Level Select Diorama Tilt)
## Dùng cho các nút bục gỗ, tạo cảm giác xúc giác và vệt sáng quét qua

uniform vec2 tilt_offset = vec2(0.0, 0.0);
uniform float tilt_amount : hint_range(0.0, 0.1) = 0.035;
uniform vec4 gold_sheen_color : source_color = vec4(1.0, 0.92, 0.55, 0.80);
uniform float sheen_speed : hint_range(0.2, 3.0) = 1.0;
uniform bool is_active = true;

void vertex() {
	// Biến dạng đỉnh theo tương tác xúc giác
	VERTEX.x += (UV.y - 0.5) * tilt_offset.x * tilt_amount * 100.0;
	VERTEX.y += (UV.x - 0.5) * tilt_offset.y * tilt_amount * 100.0;
}

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	if (is_active && col.a > 0.1) {
		float sweep = sin(UV.x * 3.2 - UV.y * 2.2 + TIME * sheen_speed);
		float sheen = smoothstep(0.72, 0.98, sweep);
		col.rgb += gold_sheen_color.rgb * sheen * 0.40;
	}
	COLOR = col;
}
