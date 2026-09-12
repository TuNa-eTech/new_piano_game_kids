shader_type canvas_item;

uniform vec4 ray_color : source_color = vec4(1.0, 0.85, 0.35, 0.45);
uniform float ray_count : hint_range(4.0, 32.0) = 16.0;
uniform float rotate_speed : hint_range(-5.0, 5.0) = 0.4;
uniform float inner_fade : hint_range(0.0, 1.0) = 0.15;

void fragment() {
    vec2 center = UV - vec2(0.5);
    float dist = length(center);
    float angle = atan(center.y, center.x) + TIME * rotate_speed;
    
    float rays = sin(angle * ray_count) * 0.5 + 0.5;
    float fade = smoothstep(0.5, inner_fade, dist);
    
    COLOR = vec4(ray_color.rgb, ray_color.a * rays * fade);
}
