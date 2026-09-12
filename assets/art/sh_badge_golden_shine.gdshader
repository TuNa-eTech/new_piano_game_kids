shader_type canvas_item;

uniform float shine_speed : hint_range(0.5, 4.0) = 1.2;
uniform float shine_width : hint_range(0.05, 0.5) = 0.15;
uniform vec4 shine_color : source_color = vec4(1.0, 1.0, 0.85, 0.6);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (tex_color.a < 0.01) {
        discard;
    }
    
    float progress = mod(TIME * shine_speed, 2.5) - 0.5;
    float line = smoothstep(progress - shine_width, progress, UV.x + UV.y * 0.5) 
               - smoothstep(progress, progress + shine_width, UV.x + UV.y * 0.5);
    
    vec3 result_rgb = mix(tex_color.rgb, shine_color.rgb, line * shine_color.a);
    COLOR = vec4(result_rgb, tex_color.a);
}
