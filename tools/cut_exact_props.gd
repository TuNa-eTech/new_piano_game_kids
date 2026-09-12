@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://assets/menu/tex_menu_stage_clean.jpg")
	img.convert(Image.FORMAT_RGBA8)

	var vio_rect := Rect2i(800, 492, 100, 166)
	var vio_sub := img.get_region(vio_rect)
	_cut_exact_violin(vio_sub)
	vio_sub.save_png("res://assets/menu/tex_violin.png")
	print("[OK] Da xuat tex_violin.png V4!")
	quit(0)

static func _cut_exact_violin(img: Image) -> void:
	var iw := img.get_width()
	var ih := img.get_height()

	var poly: PackedVector2Array = PackedVector2Array([
		Vector2(82, 8),    # Dinh cuon go
		Vector2(90, 15),
		Vector2(86, 24),
		Vector2(75, 34),   # Pegbox phai
		Vector2(64, 56),   # Can dan phai (loai bo hoan toan mang xanh)
		Vector2(68, 78),   # Vai phai
		Vector2(76, 94),
		Vector2(66, 112),  # Eo phai
		Vector2(74, 128),  # Thung duoi phai
		Vector2(66, 150),
		Vector2(48, 162),  # Day duoi
		Vector2(36, 160),
		Vector2(14, 138),  # Thung duoi trai
		Vector2(12, 122),
		Vector2(20, 106),  # Eo trai
		Vector2(26, 96),   # Bo vai trai
		Vector2(38, 86),
		Vector2(48, 76),   # Can dan trai
		Vector2(58, 52),   # Canh trai can dan
		Vector2(68, 30),   # Pegbox trai
		Vector2(74, 12),   # Cuon go trai
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
					var d := _dist_to_seg(p, p1, p2)
					if d < min_dist:
						min_dist = d
				if min_dist < 1.8:
					a = clampf(1.0 - min_dist / 1.8, 0.0, 1.0)

			var c := img.get_pixel(x, y)
			c.a *= a
			img.set_pixel(x, y, c)

static func _dist_to_seg(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var ab_len_sq := ab.length_squared()
	if ab_len_sq < 0.001:
		return p.distance_to(a)
	var t := clampf((p - a).dot(ab) / ab_len_sq, 0.0, 1.0)
	var proj := a + ab * t
	return p.distance_to(proj)
