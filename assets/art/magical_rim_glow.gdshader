shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.3, 1.0, 0.8, 1.0);
uniform float pulse_speed : hint_range(0.5, 5.0) = 2.5;
uniform float glow_intensity : hint_range(0.2, 2.0) = 1.0;
uniform float rim_threshold : hint_range(0.01, 0.4) = 0.15;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    if (tex.a < 0.01) {
        discard;
    }
    
    // Nhịp thở phát sáng (breathing pulse)
    float pulse = 0.65 + 0.35 * sin(TIME * pulse_speed);
    
    // Tính viền hào quang từ gradient alpha
    float rim = smoothstep(0.0, rim_threshold, tex.a) * (1.0 - smoothstep(rim_threshold, 0.8, tex.a));
    vec3 result_rgb = tex.rgb + glow_color.rgb * rim * pulse * glow_intensity;
    
    COLOR = vec4(result_rgb, tex.a);
}
