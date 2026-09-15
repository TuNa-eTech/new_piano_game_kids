shader_type canvas_item;

// Hiệu ứng lật một tờ giấy của quyển sách tranh (Page Curl).
//
// Mô hình: nếp gấp là một đường thẳng đứng chạy từ MÉP NGOÀI của trang về phía
// gáy sách. Phần giấy nằm bên kia nếp gấp đã bị nhấc lên, cuộn quanh một hình
// trụ rồi gập ngược lại đè lên phần giấy còn phẳng — nên từ ngoài vào trong ta
// thấy đúng bốn vùng:
//
//   ① Sau nếp gấp      : giấy đi rồi, trang mới lộ ra (trong suốt + bóng đổ)
//   ② Cuộn giấy        : nửa hình trụ, có gân sáng ở đỉnh và bóng ở chân nếp
//   ③ Mặt sau tờ giấy  : phần đã gập qua, đậm dần về phía gáy, viền mạ vàng
//   ④ Giấy còn phẳng   : phần chưa bị nhấc
//
// Cả ba vùng giấy đều đục, nên lúc nếp gấp che kín trang là lúc bên gọi tráo
// nội dung (tín hiệu page_half_flipped) mà bé không thấy cú nháy nào.
//
// direction = 1.0  → lật tới: nếp gấp chạy từ mép phải vào gáy bên trái.
// direction = -1.0 → lật lui: soi gương UV theo trục X, mọi phép toán bên dưới
//                    giữ nguyên nhưng ảnh hiện ra lật ngược, nên nếp gấp chạy
//                    từ mép trái sang phải đúng như khi lật ngược một trang.

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float direction : hint_range(-1.0, 1.0) = 1.0;
uniform float curl_radius : hint_range(0.04, 0.3) = 0.10;
uniform float curl_angle : hint_range(-0.3, 0.3) = 0.12;

uniform vec4 page_color : source_color = vec4(0.97, 0.94, 0.86, 1.0);
uniform vec4 back_color : source_color = vec4(0.92, 0.88, 0.78, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.12, 0.08, 0.04, 0.55);
uniform vec4 highlight_color : source_color = vec4(1.0, 0.98, 0.90, 0.45);
uniform vec4 gold_trim_color : source_color = vec4(0.88, 0.72, 0.28, 1.0);

const float PI_F = 3.14159265359;

// Mép ngoài trang giấy: nếp gấp xuất phát đúng ở đây chứ không lơ lửng ngoài
// khung, nếu không cả trang bị phủ giấy ngay từ khung hình đầu tiên.
const float START_POS = 1.0;
// Nếp gấp chạm gáy sách (x = 0) ở khoảng 94% hoạt ảnh rồi mới tan. Quét lố quá
// tay thì trang đã lộ hết từ lúc 70%, ba phần mười cuối cùng của hoạt ảnh trôi
// qua với một khung hình chẳng có gì chuyển động.
const float END_POS = -0.06;

void fragment() {
	if (progress <= 0.001) {
		// Lúc không lật thì shader trong suốt hoàn toàn, trang bên dưới sạch sẽ.
		COLOR = vec4(0.0);
	} else {
		vec2 uv = UV;
		if (direction < 0.0) {
			uv.x = 1.0 - uv.x;
		}

		// Xoay nhẹ UV theo curl_angle để nếp gấp hơi chéo như giấy thật
		float cos_a = cos(curl_angle);
		float sin_a = sin(curl_angle);
		vec2 c = vec2(0.5, 0.5);
		vec2 rot_uv = vec2(
			cos_a * (uv.x - c.x) - sin_a * (uv.y - c.y) + c.x,
			sin_a * (uv.x - c.x) + cos_a * (uv.y - c.y) + c.y
		);

		float curl_pos = mix(START_POS, END_POS, progress);
		float d = rot_uv.x - curl_pos;
		float roll_span = curl_radius * PI_F;

		// Chiều dài tờ giấy đã bị nhấc khỏi mặt trang. Mọi vùng giấy đều bị chặn
		// bởi con số này — thiếu nó thì "mặt sau" trải vô tận và phủ kín trang
		// ngay khi vừa bắt đầu lật.
		float lifted = clamp(START_POS - curl_pos, 0.0, 1.0);

		// Giấy hiện ra trong 6% đầu và tan trong 10% cuối, để không có cú nháy
		// đục/trong ở hai đầu hoạt ảnh.
		float fade = smoothstep(0.0, 0.05, progress) * smoothstep(1.0, 0.94, progress);

		vec4 final_color = vec4(0.0);

		if (d > 0.0) {
			// ① Sau nếp gấp: chỉ còn bóng của cuộn giấy hắt lên trang mới.
			float shadow_w = curl_radius * 2.2;
			if (d < shadow_w) {
				float s_fac = pow(1.0 - d / shadow_w, 1.8);
				final_color = vec4(shadow_color.rgb, shadow_color.a * s_fac);
			}
		} else {
			// b: lùi từ nếp gấp về phía gáy, cũng chính là chiều dài giấy đã đi qua.
			float b = -d;
			// Đoạn giấy tương ứng trên tờ gốc — dùng chung cho cả cuộn lẫn mặt sau,
			// nhờ vậy viền mạ vàng ở mép ngoài trang chạy liền mạch qua nếp cuộn.
			float src_x = curl_pos + b;

			if (b <= roll_span && b <= lifted) {
				// ② Cuộn giấy hình trụ
				float angle = b / curl_radius;
				float sin_val = sin(angle);
				float cos_val = cos(angle);

				vec4 surface;
				if (cos_val >= 0.0) {
					// Mặt trước tờ giấy đang cong lên
					surface = page_color;
					surface.a = 1.0;
					float line_y = fract(uv.y * 14.0);
					if (line_y < 0.06 && uv.y > 0.15 && uv.y < 0.85) {
						surface.rgb *= 0.94;
					}
				} else {
					// Mặt sau đang vắt qua đỉnh cuộn
					surface.rgb = back_color.rgb * 0.95;
				}

				// Mọi phép pha màu bên dưới chỉ đụng tới RGB. Pha cả alpha thì
				// gân sáng (alpha 0.45) khoét thủng tờ giấy và trang bên dưới
				// hiện xuyên qua giữa nếp cuộn.
				surface.rgb = mix(surface.rgb, highlight_color.rgb, pow(sin_val, 4.0) * 0.65);
				// Bóng sâu ở chân nếp, chỗ giấy vừa rời mặt trang
				float crease = smoothstep(0.0, 0.15, b / roll_span);
				surface.rgb *= (0.65 + 0.35 * crease);

				if (src_x > 0.96) {
					surface.rgb = mix(surface.rgb, gold_trim_color.rgb, 0.8);
				}
				surface.a = 1.0;
				final_color = surface;
			} else if (b <= lifted) {
				// ③ Mặt sau tờ giấy đã gập hẳn qua, nằm phẳng đè lên phần chưa lật
				float spine_shadow = smoothstep(0.0, 0.25, rot_uv.x);
				vec4 paper = back_color;
				paper.rgb *= (0.85 + 0.15 * spine_shadow);
				if (src_x > 0.97) {
					paper.rgb = mix(paper.rgb, gold_trim_color.rgb, 0.85);
				}
				paper.a = 1.0;
				final_color = paper;
			} else {
				// ④ Giấy còn nằm phẳng, chưa bị nhấc
				vec4 surface = page_color;
				float line_y = fract(uv.y * 14.0);
				if (line_y < 0.05 && uv.y > 0.15 && uv.y < 0.85) {
					surface.rgb *= 0.94;
				}
				// Bóng mờ chạy trước mép giấy sắp bị nhấc
				float pre_shadow = smoothstep(roll_span * 1.5, roll_span, b - lifted);
				surface.rgb *= (1.0 - 0.12 * pre_shadow);
				surface.a = 1.0;
				final_color = surface;
			}
		}

		final_color.a *= fade;
		COLOR = final_color;
	}
}
