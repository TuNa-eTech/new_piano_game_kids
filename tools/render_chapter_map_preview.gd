@tool
extends SceneTree

func _init() -> void:
	print("=== RENDERING 2.5D CHAPTER MAP SCREEN PREVIEW (MÀN 04) ===")
	var canvas := Image.create(1280, 720, false, Image.FORMAT_RGBA8)
	canvas.fill(Color("#050806"))

	# 1. Nền Sân Khấu Sách Nổi & Rừng Cổ Tích
	var bg_src := Image.load_from_file("res://assets/art/tex_bg_chapter_forest.png")
	if bg_src != null:
		bg_src.convert(Image.FORMAT_RGBA8)
		bg_src.resize(1280, 720, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect(bg_src, Rect2i(0, 0, 1280, 720), Vector2i.ZERO)

	# 2. Bảng Ruy Băng Gỗ Tiêu Đề 'Chapter Selection Map' ở đỉnh
	var banner_img := Image.load_from_file("res://assets/art/ui_banner_ribbon_title.png")
	if banner_img != null:
		banner_img.convert(Image.FORMAT_RGBA8)
		var bw := 490
		var bh := int(bw * float(banner_img.get_height()) / float(banner_img.get_width()))
		banner_img.resize(bw, bh, Image.INTERPOLATE_LANCZOS)
		var bx := (1280 - bw) / 2
		var by := 12
		_blend_image(canvas, banner_img, Vector2i(bx, by))

	# 3. Ba thẻ chương 2.5D
	var card_rects := [
		Rect2i(int(1280 * 0.170), int(720 * 0.235), int(1280 * (0.355 - 0.170)), int(720 * (0.765 - 0.235))),
		Rect2i(int(1280 * 0.410), int(720 * 0.235), int(1280 * (0.595 - 0.410)), int(720 * (0.765 - 0.235))),
		Rect2i(int(1280 * 0.650), int(720 * 0.235), int(1280 * (0.835 - 0.650)), int(720 * (0.765 - 0.235)))
	]
	var card_paths := [
		"res://assets/art/card_ch1_flute.png",
		"res://assets/art/card_ch2_kalimba.png",
		"res://assets/art/card_ch3_chimes.png"
	]

	for i in 3:
		var c_img := Image.load_from_file(card_paths[i])
		if c_img != null:
			c_img.convert(Image.FORMAT_RGBA8)
			var cr: Rect2i = card_rects[i]
			c_img.resize(cr.size.x, cr.size.y, Image.INTERPOLATE_LANCZOS)
			_blend_image(canvas, c_img, cr.position)

			# Thẻ 1 (Đang mở): Lọ sao thủy tinh trong nôi lá non ở chân thẻ
			if i == 0:
				var cradle_img := Image.load_from_file("res://assets/art/spr_star_jar_cradle.png")
				if cradle_img != null:
					cradle_img.convert(Image.FORMAT_RGBA8)
					var cr_w := int(cr.size.x * 0.74)
					cradle_img.resize(cr_w, cr_w, Image.INTERPOLATE_LANCZOS)
					var cr_x := cr.position.x + (cr.size.x - cr_w) / 2
					var cr_y := cr.position.y + cr.size.y - int(cr_w * 0.70)
					_blend_image(canvas, cradle_img, Vector2i(cr_x, cr_y))

			# Thẻ 3 (Bị khóa): Lớp phủ mờ, Đai da thắt ngang và Ổ khóa đồng hoàng gia
			if i == 2:
				# 1. Lớp phủ mờ bảo vệ
				_dim_card_overlay(canvas, cr)

				# 2. Đai da thắt ngang
				var strap_img := Image.load_from_file("res://assets/art/spr_leather_belt_strap.png")
				if strap_img != null:
					strap_img.convert(Image.FORMAT_RGBA8)
					var strap_w := int(cr.size.x * 1.08)
					var strap_h := int(strap_w * float(strap_img.get_height()) / float(strap_img.get_width()))
					strap_img.resize(strap_w, strap_h, Image.INTERPOLATE_LANCZOS)
					var sx := cr.position.x + (cr.size.x - strap_w) / 2
					var sy := cr.position.y + int(cr.size.y * 0.48) - strap_h / 2
					_blend_image(canvas, strap_img, Vector2i(sx, sy))

				# 3. Ổ khóa đồng hoàng gia
				var lock_img := Image.load_from_file("res://assets/art/spr_padlock_brass.png")
				if lock_img != null:
					lock_img.convert(Image.FORMAT_RGBA8)
					var lw := int(cr.size.x * 0.46)
					var lh := int(lw * float(lock_img.get_height()) / float(lock_img.get_width()))
					lock_img.resize(lw, lh, Image.INTERPOLATE_LANCZOS)
					var lx := cr.position.x + (cr.size.x - lw) / 2
					var ly := cr.position.y + int(cr.size.y * 0.48) - int(lh * 0.48)
					_blend_image(canvas, lock_img, Vector2i(lx, ly))

	# 4. Nút Quay lại góc trái trên
	var back_img := Image.load_from_file("res://assets/art/ui_btn_wood_circle_back.png")
	if back_img != null:
		back_img.convert(Image.FORMAT_RGBA8)
		var bw := int(1280 * (0.098 - 0.018))
		var bh := int(720 * (0.175 - 0.035))
		var sz := mini(bw, bh)
		back_img.resize(sz, sz, Image.INTERPOLATE_LANCZOS)
		var bx := int(1280 * 0.018) + (bw - sz) / 2
		var by := int(720 * 0.035) + (bh - sz) / 2
		_blend_image(canvas, back_img, Vector2i(bx, by))

	# 5. Lọ Sao Thủy Tinh góc phải trên
	var jar_img := Image.load_from_file("res://assets/art/ui_star_jar_top_right.png")
	if jar_img != null:
		jar_img.convert(Image.FORMAT_RGBA8)
		var jw := int(1280 * (0.980 - 0.900))
		var jh := int(720 * (0.175 - 0.035))
		jar_img.resize(jw, jh, Image.INTERPOLATE_LANCZOS)
		var jx := int(1280 * 0.900)
		var jy := int(720 * 0.035)
		_blend_image(canvas, jar_img, Vector2i(jx, jy))

	var out_docs := "res://docs/chapter_map_rendered.png"
	canvas.save_png(out_docs)
	print("[OK] Đã lưu preview kết quả vào: ", out_docs)
	quit(0)


func _dim_card_overlay(canvas: Image, cr: Rect2i) -> void:
	var dim_color := Color(0.05, 0.07, 0.10, 0.48)
	var radius := 22
	for y in range(cr.position.y, cr.position.y + cr.size.y):
		for x in range(cr.position.x, cr.position.x + cr.size.x):
			if x >= 0 and x < canvas.get_width() and y >= 0 and y < canvas.get_height():
				# Kiểm tra bo góc tròn
				var lx := x - cr.position.x
				var ly := y - cr.position.y
				var in_corner := false
				if lx < radius and ly < radius:
					in_corner = (Vector2(lx - radius, ly - radius).length() > radius)
				elif lx > cr.size.x - radius and ly < radius:
					in_corner = (Vector2(lx - (cr.size.x - radius), ly - radius).length() > radius)
				elif lx < radius and ly > cr.size.y - radius:
					in_corner = (Vector2(lx - radius, ly - (cr.size.y - radius)).length() > radius)
				elif lx > cr.size.x - radius and ly > cr.size.y - radius:
					in_corner = (Vector2(lx - (cr.size.x - radius), ly - (cr.size.y - radius)).length() > radius)

				if not in_corner:
					var orig := canvas.get_pixel(x, y)
					canvas.set_pixel(x, y, orig.blend(dim_color))


func _blend_image(dst: Image, src: Image, pos: Vector2i) -> void:
	for sy in src.get_height():
		for sx in src.get_width():
			var dx := pos.x + sx
			var dy := pos.y + sy
			if dx >= 0 and dx < dst.get_width() and dy >= 0 and dy < dst.get_height():
				var src_col := src.get_pixel(sx, sy)
				if src_col.a > 0.001:
					var dst_col := dst.get_pixel(dx, dy)
					dst.set_pixel(dx, dy, dst_col.blend(src_col))
