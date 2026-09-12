shader_type canvas_item;

// Shader Dây Đèn Cổ Tích Nhấp Nháy (Fairy String Lights - docs/mock-free-play.jpeg)
// Điều khiển các bóng đèn giăng mắc trên tán cây nhấp nháy đa sắc xen kẽ.

uniform float blink_speed : hint_range(0.5, 6.0) = 2.4;
uniform float min_brightness : hint_range(0.1, 0.8) = 0.35;
uniform float glow_boost : hint_range(1.0, 3.0) = 1.8;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	if (tex.a < 0.05) {
		discard;
	}
	
	// Tính toán nhịp nháy lệch pha theo vị trí ngang UV.x (để các bóng đèn không chớp cùng lúc)
	float phase_offset = UV.x * 25.0 + UV.y * 10.0;
	float blink = sin(TIME * blink_speed + phase_offset);
	float brightness = mix(min_brightness, glow_boost, 0.5 + 0.5 * blink);
	
	// Tăng độ rực rỡ của các bóng đèn phát sáng
	vec3 lit_color = tex.rgb * brightness;
	
	COLOR = vec4(lit_color, tex.a);
}
