shader_type canvas_item;

// Hiệu ứng gió thổi đu đưa mềm mại cho thảm rêu và tán cây diorama
uniform float sway_speed : hint_range(0.5, 4.0) = 1.4;
uniform float sway_amplitude : hint_range(0.0, 15.0) = 3.5;

void vertex() {
	// Chỉ lay động phần trên (UV.y nhỏ), giữ cố định phần gốc bám dưới
	float factor = 1.0 - UV.y;
	VERTEX.x += sin(TIME * sway_speed + VERTEX.y * 0.02) * sway_amplitude * factor;
}
