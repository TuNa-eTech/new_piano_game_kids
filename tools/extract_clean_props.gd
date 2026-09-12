@tool
extends SceneTree

func _init() -> void:
	print("--- Trich xuat sac net cac prop Menu ---")
	var img := Image.load_from_file("res://assets/menu/tex_menu_stage_clean.jpg")
	if img == null:
		printerr("Khong the load stage")
		quit(1)
		return

	# Chuyen doi sang RGBA8 de ho tro kenh do trong suot (alpha channel)
	img.convert(Image.FORMAT_RGBA8)

	var w := img.get_width()
	var h := img.get_height()

	# 1. PLAY BUTTON DISC
	# Center X: 1052, Center Y: 472, Radius: 103 px
	var play_box := Rect2i(938, 350, 228, 250)
	var play_sub := img.get_region(play_box)
	_cutout_play_disc(play_sub)
	play_sub.save_png("res://assets/menu/tex_play_disc.png")
	print("[OK] Xuat tex_play_disc.png")

	# 2. ACCORDION
	# X: 590..832, Y: 504..648 -> Size: 242 x 148
	var acc_box := Rect2i(590, 504, 242, 148)
	var acc_sub := img.get_region(acc_box)
	_cutout_accordion(acc_sub)
	acc_sub.save_png("res://assets/menu/tex_accordion.png")
	print("[OK] Xuat tex_accordion.png")

	# 3. VIOLIN
	# X: 800..900, Y: 492..658 -> Size: 100 x 166
	var vio_box := Rect2i(800, 492, 100, 166)
	var vio_sub := img.get_region(vio_box)
	_cutout_violin(vio_sub)
	vio_sub.save_png("res://assets/menu/tex_violin.png")
	print("[OK] Xuat tex_violin.png")

	quit(0)


static func _cutout_play_disc(img: Image) -> void:
	var iw := img.get_width()
	var ih := img.get_height()
	var center := Vector2(114, 125)
	var radius := 102.0

	for y in ih:
		for x in iw:
			var p := Vector2(x, y)
			var d := p.distance_to(center)
			var a := 1.0

			var in_top_clef := (x >= 95 and x <= 145 and y < 35 and y >= 2)
			var in_bot_clef := (x >= 75 and x <= 130 and y > 215 and y <= 245)

			if d > radius and not in_top_clef and not in_bot_clef:
				var excess := d - radius
				a = clampf(1.0 - excess / 3.0, 0.0, 1.0)
			elif in_top_clef:
				var c := img.get_pixel(x, y)
				var is_gold := (c.r > 0.45 and c.g > 0.35 and c.b < c.r - 0.08)
				a = 1.0 if is_gold else 0.0
			elif in_bot_clef:
				var c := img.get_pixel(x, y)
				var is_gold := (c.r > 0.45 and c.g > 0.35 and c.b < c.r - 0.08)
				a = 1.0 if is_gold else 0.0

			var c := img.get_pixel(x, y)
			c.a *= a
			img.set_pixel(x, y, c)


static func _cutout_accordion(img: Image) -> void:
	var iw := img.get_width()
	var ih := img.get_height()

	var poly: PackedVector2Array = PackedVector2Array([
		Vector2(45, 14),
		Vector2(65, 20),
		Vector2(75, 14),
		Vector2(88, 7),
		Vector2(101, 14),
		Vector2(113, 7),
		Vector2(127, 14),
		Vector2(140, 7),
		Vector2(154, 14),
		Vector2(166, 7),
		Vector2(178, 14),
		Vector2(192, 10),
		Vector2(208, 28),
		Vector2(236, 42),
		Vector2(238, 48),
		Vector2(195, 142),
		Vector2(182, 146),
		Vector2(148, 126),
		Vector2(125, 134),
		Vector2(62, 146),
		Vector2(36, 142),
		Vector2(12, 50),
		Vector2(14, 40),
	])

	for y in ih:
		for x in iw:
			var p := Vector2(x, y)
			var inside := Geometry2D.is_point_in_polygon(p, poly)
			var a := 1.0 if inside else 0.0

			if not inside:
				var min_dist := 999.0
				for i in poly.size():
					var p1 := poly[i]
					var p2 := poly[(i + 1) % poly.size()]
					var seg_dist := _dist_to_segment(p, p1, p2)
					if seg_dist < min_dist:
						min_dist = seg_dist
				if min_dist < 2.5:
					a = clampf(1.0 - min_dist / 2.5, 0.0, 1.0)

			var c := img.get_pixel(x, y)
			c.a *= a
			img.set_pixel(x, y, c)


static func _cutout_violin(img: Image) -> void:
	var iw := img.get_width()
	var ih := img.get_height()

	var poly: PackedVector2Array = PackedVector2Array([
		Vector2(75, 4),
		Vector2(92, 18),
		Vector2(84, 30),
		Vector2(68, 52),
		Vector2(58, 62),
		Vector2(74, 82),
		Vector2(80, 96),
		Vector2(66, 114),
		Vector2(78, 128),
		Vector2(64, 156),
		Vector2(45, 164),
		Vector2(26, 158),
		Vector2(12, 136),
		Vector2(24, 116),
		Vector2(20, 102),
		Vector2(32, 78),
		Vector2(48, 60),
		Vector2(64, 28),
		Vector2(68, 12),
	])

	for y in ih:
		for x in iw:
			var p := Vector2(x, y)
			var inside := Geometry2D.is_point_in_polygon(p, poly)
			var a := 1.0 if inside else 0.0

			if not inside:
				var min_dist := 999.0
				for i in poly.size():
					var p1 := poly[i]
					var p2 := poly[(i + 1) % poly.size()]
					var seg_dist := _dist_to_segment(p, p1, p2)
					if seg_dist < min_dist:
						min_dist = seg_dist
				if min_dist < 2.5:
					a = clampf(1.0 - min_dist / 2.5, 0.0, 1.0)

			var c := img.get_pixel(x, y)
			c.a *= a
			img.set_pixel(x, y, c)


static func _dist_to_segment(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var ab_len_sq := ab.length_squared()
	if ab_len_sq < 0.001:
		return p.distance_to(a)
	var t := clampf((p - a).dot(ab) / ab_len_sq, 0.0, 1.0)
	var proj := a + ab * t
	return p.distance_to(proj)
