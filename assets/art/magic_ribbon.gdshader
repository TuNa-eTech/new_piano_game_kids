shader_type canvas_item;

uniform vec4 ribbon_color : source_color = vec4(0.3, 0.9, 1.0, 0.9);
uniform vec4 core_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flow_speed : hint_range(0.5, 4.0) = 2.0;
uniform float wave_freq : hint_range(1.0, 10.0) = 4.0;
uniform float wave_amp : hint_range(0.01, 0.2) = 0.05;

void fragment() {
    vec2 uv = UV;
    // Tạo sóng sin uốn lượn theo thời gian
    float wave = sin(uv.x * wave_freq - TIME * flow_speed) * wave_amp;
    float dist_to_center = abs((uv.y + wave) - 0.5);
    
    // Gradient từ tâm sáng trắng ra viền màu ngọc
    float core = smoothstep(0.08, 0.0, dist_to_center);
    float glow = smoothstep(0.45, 0.0, dist_to_center);
    
    vec4 col = mix(ribbon_color, core_color, core);
    col.a *= glow;
    
    COLOR = col;
}
