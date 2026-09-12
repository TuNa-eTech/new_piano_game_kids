@tool
extends SceneTree

func _init() -> void:
	print("=== TẠO BỘ ASSET PHÍM PIANO 2.5D ĐỘC LẬP CHUẨN XÁC ===")
	var src_path := "res://docs/mock-game-play.jpeg"
	var img := Image.load_from_file(src_path)
	img.convert(Image.FORMAT_RGBA8)

	# 1. Trích xuất 7 Letter Badges (C, D, E, F, G, A, B)
	var badge_centers := [
		Vector2i(212, 512),
		Vector2i(312, 512),
		Vector2i(412, 513),
		Vector2i(511, 512),
		Vector2i(610, 513),
		Vector2i(710, 513),
		Vector2i(810, 512)
	]
	var badge_letters := ["C", "D", "E", "F", "G", "A", "B"]
	var r := 15
	var b_size := r * 2
	
	for i in range(7):
		var center: Vector2i = badge_centers[i]
		var b_img := Image.create(b_size, b_size, false, Image.FORMAT_RGBA8)
		for dy in range(-r, r):
			for dx in range(-r, r):
				var dist := sqrt(float(dx * dx + dy * dy))
				var px: int = center.x + dx
				var py: int = center.y + dy
				var c := img.get_pixel(px, py)
				var alpha := 0.0
				if dist <= float(r) - 1.0:
					alpha = 1.0
				elif dist <= float(r):
					alpha = clampf((float(r) - dist) / 1.0, 0.0, 1.0)
				c.a = alpha
				b_img.set_pixel(dx + r, dy + r, c)
		var b_path := "res://assets/art/badge_note_25d_%s.png" % badge_letters[i]
		b_img.save_png(b_path)
		print("[OK] Đã xuất: ", b_path)

	# 2. Trích xuất 7 Animal Mascots chuẩn xác 100% không dính viền lân cận
	var animal_defs := [
		{"name": "lion", "cx": 218, "cy": 472, "rw": 34, "rh": 28},
		{"name": "bear", "cx": 308, "cy": 472, "rw": 28, "rh": 26},
		{"name": "rabbit", "cx": 406, "cy": 460, "rw": 26, "rh": 38},
		{"name": "cat", "cx": 509, "cy": 472, "rw": 28, "rh": 26},
		{"name": "monkey", "cx": 612, "cy": 472, "rw": 32, "rh": 26},
		{"name": "elephant", "cx": 700, "cy": 472, "rw": 36, "rh": 26},
		{"name": "owl", "cx": 807, "cy": 472, "rw": 26, "rh": 26}
	]

	for a in animal_defs:
		var cx: int = a["cx"]
		var cy: int = a["cy"]
		var rw: int = a["rw"]
		var rh: int = a["rh"]
		var a_w: int = rw * 2
		var a_h: int = rh * 2
		var a_img := Image.create(a_w, a_h, false, Image.FORMAT_RGBA8)
		for dy in range(-rh, rh):
			for dx in range(-rw, rw):
				var px: int = cx + dx
				var py: int = cy + dy
				var c := img.get_pixel(px, py)
				
				# Tọa độ chuẩn hóa elip
				var nx := float(dx) / float(rw)
				var ny := float(dy) / float(rh)
				var dist_el := sqrt(nx * nx + ny * ny)

				# Kiểm tra xem có phải màu phím ngà không:
				var is_ivory := (c.r > 0.87 and c.g > 0.81 and c.b > 0.69 and absf(c.r - c.g) < 0.07)
				
				var alpha := 1.0
				if dist_el > 1.0:
					alpha = 0.0
				elif dist_el > 0.85 and is_ivory:
					alpha = clampf((1.0 - dist_el) / 0.15, 0.0, 1.0) * 0.4
				elif dist_el > 0.70 and is_ivory and (absf(nx) > 0.65 or ny > 0.75 or ny < -0.80):
					alpha = 0.0
				elif dist_el > 0.94:
					alpha = clampf((1.0 - dist_el) / 0.06, 0.0, 1.0)
					
				c.a = c.a * alpha
				a_img.set_pixel(dx + rw, dy + rh, c)
				
		var a_path := "res://assets/art/animal_token_25d_%s.png" % a["name"]
		a_img.save_png(a_path)
		print("[OK] Đã xuất: ", a_path)

	# 3. Trích xuất Phím Đen 2.5D (Black Key) sạch từ Black Key 0 (giữa C và D: X: 247..277, Y: 406..468)
	var bk_rect := Rect2i(247, 406, 31, 62)
	var bk_img := img.get_region(bk_rect)
	for y in range(bk_img.get_height()):
		for x in range(bk_img.get_width()):
			var c := bk_img.get_pixel(x, y)
			# Phím đen màu gỗ nâu tối (lum < 0.35).
			# Nếu c lọt vào màu phím trắng ngà (R > 0.75, G > 0.70):
			if c.r > 0.72 and c.g > 0.68:
				c.a = 0.0
			elif x < 2 or x > bk_img.get_width() - 3 or y < 2 or y > bk_img.get_height() - 3:
				# feathering mép ngoài
				if c.r > 0.50:
					c.a = 0.0
			bk_img.set_pixel(x, y, c)
	bk_img.save_png("res://assets/art/piano_black_key_master_25d.png")
	print("[OK] Đã xuất: piano_black_key_master_25d.png")

	# 4. Trích xuất Khung Bệ Gỗ Console Chuẩn Sạch 100% (Chassis Frame)
	# Từ docs/mock-game-play.jpeg: X: 95..895 (w: 800), Y: 362..570 (h: 208)
	var chassis_img := img.get_region(Rect2i(95, 362, 800, 208))
	var ch_w := chassis_img.get_width()
	var ch_h := chassis_img.get_height()

	# Khử dải lụa ma thuật trên thanh nẹp gỗ phía trên (Y: 0..44, X: 260..640)
	# Bằng cách lấy mẫu vân gỗ thẳng mịn không có xoắn ốc (X: 170..235)
	for y in range(44):
		for x in range(260, 640):
			var sample_x: int = 170 + ((x - 260) % 65)
			var c_wood := chassis_img.get_pixel(sample_x, y)
			chassis_img.set_pixel(x, y, c_wood)

	for y in range(ch_h):
		for x in range(ch_w):
			var c := chassis_img.get_pixel(x, y)
			# Hốc phím đàn sạch: X: 86..746, Y: 44..192 (hoàn toàn rỗng để phím đàn tự render)
			if x >= 86 and x <= 746 and y >= 44 and y <= 192:
				c.a = 0.0
			# Mép viền ngoài bệ gỗ: feathering mượt mà
			if x < 8:
				c.a = minf(c.a, float(x) / 8.0)
			if x > ch_w - 9:
				c.a = minf(c.a, float(ch_w - 1 - x) / 8.0)
			if y > ch_h - 6:
				c.a = minf(c.a, float(ch_h - 1 - y) / 6.0)
			chassis_img.set_pixel(x, y, c)

	chassis_img.save_png("res://assets/art/piano_console_frame_clean_25d.png")
	print("[OK] Đã xuất: piano_console_frame_clean_25d.png")

	quit(0)
