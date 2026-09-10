shader_type canvas_item;

// Page Curl Shader for Storybook Pop-up Diorama
// Simulates realistic 3D cylindrical paper peeling and rolling from right to left.

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float curl_radius : hint_range(0.04, 0.3) = 0.10;
uniform float curl_angle : hint_range(-0.3, 0.3) = 0.12;

uniform vec4 page_color : source_color = vec4(0.97, 0.94, 0.86, 1.0);
uniform vec4 back_color : source_color = vec4(0.92, 0.88, 0.78, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.12, 0.08, 0.04, 0.55);
uniform vec4 highlight_color : source_color = vec4(1.0, 0.98, 0.90, 0.45);
uniform vec4 gold_trim_color : source_color = vec4(0.88, 0.72, 0.28, 1.0);

void fragment() {
	if (progress <= 0.001) {
		// When not turning, shader is completely transparent so page underneath is clean
		COLOR = vec4(0.0);
	} else {
		vec2 uv = UV;

		// Rotate UV slightly along curl_angle for natural diagonal peel
		float cos_a = cos(curl_angle);
		float sin_a = sin(curl_angle);
		vec2 center_rot = vec2(0.5, 0.5);
		vec2 rot_uv = vec2(
			cos_a * (uv.x - center_rot.x) - sin_a * (uv.y - center_rot.y) + center_rot.x,
			sin_a * (uv.x - center_rot.x) + cos_a * (uv.y - center_rot.y) + center_rot.y
		);

		// Curl line moves from right (rot_uv.x ~ 1.15) to left (rot_uv.x ~ -0.35)
		float start_pos = 1.12;
		float end_pos = -0.35;
		float curl_pos = mix(start_pos, end_pos, progress);

		float d = rot_uv.x - curl_pos;
		float pi = 3.14159265359;
		float roll_circumference = curl_radius * pi;

		vec4 final_color = vec4(0.0);

		// Region 1: Behind the curl line (Left of curl)
		// Here the underneath new page is exposed, with a soft cast shadow under the roll.
		if (d < 0.0) {
			float shadow_dist = -d;
			float shadow_width = curl_radius * 2.2;
			if (shadow_dist < shadow_width) {
				float s_fac = pow(1.0 - shadow_dist / shadow_width, 1.8);
				final_color = vec4(shadow_color.rgb, shadow_color.a * s_fac * (1.0 - progress * 0.4));
			} else {
				final_color = vec4(0.0);
			}

			// Check if the page has curled so far over that the BACK of the page lies here!
			float folded_d = -d;
			if (folded_d >= roll_circumference) {
				// This is the flat backside of the turned page!
				float back_offset = folded_d - roll_circumference;
				vec2 back_uv = uv + vec2(back_offset * 1.6, 0.0);
				if (back_uv.x <= 1.0 && back_uv.y >= 0.0 && back_uv.y <= 1.0) {
					// Paper texture with subtle darkening towards spine
					float spine_shadow = smoothstep(0.0, 0.25, uv.x);
					vec4 paper = back_color * (0.85 + 0.15 * spine_shadow);

					// Gold trim on the outer edge of the back page
					if (back_uv.x > 0.97) {
						paper = mix(paper, gold_trim_color, 0.85);
					}

					// Soft page shading
					paper.a *= smoothstep(1.0, 0.92, progress);
					final_color = paper;
				}
			}
		}
		// Region 2: The cylinder roll itself
		else if (d >= 0.0 && d < roll_circumference) {
			float angle = d / curl_radius; // 0 to pi
			float sin_val = sin(angle);
			float cos_val = cos(angle);

			// Surface normal lighting:
			// When cos_val is positive, we see the front curving up.
			// When cos_val is negative, we see the back wrapping over.
			vec4 surface_color;
			if (cos_val >= 0.0) {
				// Front of page rolling up
				surface_color = page_color;
				// Subtle stave lines hint on front page
				float line_y = fract(uv.y * 14.0);
				if (line_y < 0.06 && uv.y > 0.15 && uv.y < 0.85) {
					surface_color.rgb *= 0.94;
				}
			} else {
				// Back of page curling over
				surface_color = back_color * 0.95;
			}

			// Lighting on the roll:
			// Specular highlight along the crest of the roll cylinder (where angle ~ pi/2)
			float highlight_fac = pow(sin_val, 4.0);
			surface_color = mix(surface_color, highlight_color, highlight_fac * 0.65);

			// Deep shadow in the crease where the paper lifts off
			float crease_shadow = smoothstep(0.0, 0.15, d / roll_circumference);
			surface_color.rgb *= (0.65 + 0.35 * crease_shadow);

			// Outer gold foil rim if near the edge of the turning page
			if (rot_uv.x > 0.96) {
				surface_color = mix(surface_color, gold_trim_color, 0.8);
			}

			// Fade out slightly near completion
			surface_color.a *= smoothstep(1.0, 0.92, progress);
			final_color = surface_color;
		}
		// Region 3: Right of the curl
		// This is the original page still sitting flat, before the curl catches it
		else {
			vec4 surface = page_color;
			// Faint stave lines and paper tone
			float line_y = fract(uv.y * 14.0);
			if (line_y < 0.05 && uv.y > 0.15 && uv.y < 0.85) {
				surface.rgb *= 0.94;
			}

			// Gold rim on right edge of page
			if (uv.x > 0.96) {
				surface = mix(surface, gold_trim_color, 0.85);
			}

			// Pre-curl shadow cast ahead of the lifting edge
			float pre_shadow = smoothstep(roll_circumference * 1.5, roll_circumference, d);
			surface.rgb *= (1.0 - 0.12 * pre_shadow);

			final_color = surface;
		}

		COLOR = final_color;
	}
}
