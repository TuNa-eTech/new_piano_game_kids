shader_type canvas_item;

uniform vec4 shimmer_color : source_color = vec4(1.0, 0.95, 0.6, 0.6);
uniform float shimmer_speed : hint_range(0.2, 2.0) = 0.6;
uniform float shimmer_width : hint_range(0.05, 0.4) = 0.18;
uniform float shimmer_interval : hint_range(2.0, 8.0) = 4.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    if (tex.a < 0.01) {
        discard;
    }
    
    // Chu kỳ quét vệt sáng chéo 45 độ
    float progress = mod(TIME * shimmer_speed, shimmer_interval);
    float line_pos = progress * 2.0 - 0.5;
    float dist = abs((UV.x + UV.y * 0.4) - line_pos);
    float shimmer = smoothstep(shimmer_width, 0.0, dist);
    
    vec3 out_rgb = tex.rgb + shimmer_color.rgb * shimmer * shimmer_color.a;
    COLOR = vec4(out_rgb, tex.a);
}
