@tool
extends SceneTree

func _init() -> void:
	print("=== TRÍCH XUẤT TOÀN BỘ ASSET PIANO 2.5D TÁCH BẠCH 100% ===")
	var src_path := "res://docs/mock-game-play.jpeg"
	var img := Image.load_from_file(src_path)
	img.convert(Image.FORMAT_RGBA8)

	# 1. Trích xuất 7 Huy hiệu Nốt tròn 3D (Letter Badges C, D, E, F, G, A, B)
	# Tọa độ Y trong mock-game-play.jpeg: Y ~ 514..546 (đường kính ~ 32px)
	# Tọa độ tâm X của 7 nốt:
	# C: 206, D: 304, E: 402, F: 500, G: 597, A: 694, B: 791
	var badge_centers := [206, 304, 402, 500, 597, 694, 791]
	var badge_names := ["C", "D", "E", "F", "G", "A", "B"]
	var badge_radius := 18 # bán kính 18px -> đường kính 36px
	
	for i in range(7):
		var cx: int = badge_centers[i]
		var cy: int = 530
		var b_img := Image.create(badge_radius * 2, badge_radius * 2, false, Image.FORMAT_RGBA8)
		for dy in range(-badge_radius, badge_radius):
			for dx in range(-badge_radius, badge_radius):
				var dist := sqrt(float(dx * dx + dy * dy))
				var px: int = cx + dx
				var py: int = cy + dy
				var c := img.get_pixel(px, py)
				if dist <= float(badge_radius) - 1.5:
					c.a = 1.0
				elif dist <= float(badge_radius):
					c.a = (float(badge_radius) - dist) / 1.5
				else:
					c.a = 0.0
				b_img.set_pixel(dx + badge_radius, dy + badge_radius, c)
		var out_path := "res://assets/art/note_badge_3d_%s.png" % badge_names[i]
		b_img.save_png(out_path)
		print("[OK] Đã xuất note_badge_3d_%s.png" % badge_names[i])

	# 2. Trích xuất 7 Linh vật Thú 2.5D Sạch 100% (Lion, Bear, Rabbit, Cat, Monkey, Elephant, Owl)
	# Tọa độ Y: Y ~ 450..514
	# Bán kính trích xuất an toàn không chạm vào mép phím hoặc phím lân cận
	var animal_configs := [
		{"name": "lion", "cx": 206, "cy": 482, "rw": 28, "rh": 28},
		{"name": "bear", "cx": 304, "cy": 485, "rw": 24, "rh": 24},
		{"name": "rabbit", "cx": 402, "cy": 472, "rw": 26, "rh": 34}, # tai thỏ cao hơn
		{"name": "cat", "cx": 500, "cy": 485, "rw": 25, "rh": 24},
		{"name": "monkey", "cx": 597, "cy": 485, "rw": 29, "rh": 24}, # tai khỉ bè sang 2 bên
		{"name": "elephant", "cx": 694, "cy": 484, "rw": 32, "rh": 26}, # tai voi rộng
		{"name": "owl", "cx": 791, "cy": 485, "rw": 24, "rh": 25},
	]

	for cfg in animal_configs:
		var cx: int = cfg["cx"]
		var cy: int = cfg["cy"]
		var rw: int = cfg["rw"]
		var rh: int = cfg["rh"]
		var a_img := Image.create(rw * 2, rh * 2, false, Image.FORMAT_RGBA8)
		for dy in range(-rh, rh):
			for dx in range(-rw, rw):
				var px: int = cx + dx
				var py: int = cy + dy
				var c := img.get_pixel(px, py)
				# Khử màu ngà nền của phím piano xung quanh thú
				# Màu nền ngà phím: R > 0.88, G > 0.84, B > 0.74, độ chênh R-B < 0.22
				var is_ivory_key := (c.r > 0.86 and c.g > 0.80 and c.b > 0.68 and absf(c.r - c.g) < 0.08)
				
				# Tính khoảng cách hình elip tới mép
				var nx := float(dx) / float(rw)
				var ny := float(dy) / float(rh)
				var dist_ellipse := sqrt(nx * nx + ny * ny)

				if dist_ellipse > 1.0:
					c.a = 0.0
				elif is_ivory_key and dist_ellipse > 0.75:
					# Vùng rìa ngoài có màu phím ngà -> làm trong suốt
					var fade := (dist_ellipse - 0.75) / 0.25
					c.a = maxf(0.0, 1.0 - fade)
				elif dist_ellipse > 0.92:
					c.a = (1.0 - dist_ellipse) / 0.08
				else:
					c.a = 1.0

				a_img.set_pixel(dx + rw, dy + rh, c)
		var a_path := "res://assets/art/avatar_%s_clean_25d.png" % cfg["name"]
		a_img.save_png(a_path)
		print("[OK] Đã xuất avatar_%s_clean_25d.png" % cfg["name"])

	# 3. Trích xuất Phím Đen 3D Chuẩn (Black Key 2.5D) từ Black Key 0 (giữa C và D: X: 246..276, Y: 406..468)
	# Black key 0 hoàn toàn không bị dính dải lụa ma thuật!
	var bk_rect := Rect2i(246, 406, 30, 62)
	var bk_img := img.get_region(bk_rect)
	# Bo tròn nhẹ cạnh và khử nền ngoài
	for y in range(bk_img.get_height()):
		for x in range(bk_img.get_width()):
			var c := bk_img.get_pixel(x, y)
			# Nếu là màu phím trắng lọt vào góc (c.r > 0.7, c.g > 0.6):
			if c.r > 0.65 and c.g > 0.60:
				c.a = 0.0
			bk_img.set_pixel(x, y, c)
	bk_img.save_png("res://assets/art/piano_black_key_clean_25d.png")
	print("[OK] Đã xuất piano_black_key_clean_25d.png")

	quit(0)
