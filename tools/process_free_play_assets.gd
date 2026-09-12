@tool
extends SceneTree
## Script trích xuất và tối ưu hóa các asset 2.5D cho Màn 03 từ mock-free-play.jpeg và các asset đã sinh.

func _init() -> void:
	print("=== BẮT ĐẦU XỬ LÝ VÀ TRÍCH XUẤT ASSET MÀN 03 FREE PLAY ===")
	var mock_path := "res://docs/mock-free-play.jpeg"
	var mock_img := Image.load_from_file(mock_path)
	if mock_img == null:
		printerr("Lỗi: Không tìm thấy ", mock_path)
		quit(1)
		return

	mock_img.convert(Image.FORMAT_RGBA8)
	var mw := mock_img.get_width()
	var mh := mock_img.get_height()
	print("Kích thước mock-free-play.jpeg: %d x %d" % [mw, mh])

	# 1. Trích xuất Thanh 4 Nhạc Cụ Gỗ (Top Instrument Bar) từ mock-free-play.jpeg
	# Thanh nằm ở giữa trên đỉnh: X khoảng 380..996 (w: 616), Y khoảng 10..136 (h: 126)
	var bar_rect := Rect2i(380, 10, 616, 126)
	var bar_img := mock_img.get_region(bar_rect)
	_apply_feather_and_chroma(bar_img, Color("#103036"), 0.22, 0.04)
	bar_img.save_png("res://assets/art/ui_bar_instruments_freeplay.png")
	print("[OK] Đã xuất ui_bar_instruments_freeplay.png: ", bar_rect)

	# 2. Trích xuất Cây Đậu Thần Âm Nhạc (Musical Beanstalk) trang phải
	# X khoảng 680..1020 (w: 340), Y khoảng 130..495 (h: 365)
	var beanstalk_rect := Rect2i(680, 130, 340, 365)
	var beanstalk_img := mock_img.get_region(beanstalk_rect)
	_apply_rounded_rect_feather(beanstalk_img, 0.05)
	beanstalk_img.save_png("res://assets/art/musical_beanstalk_stage.png")
	print("[OK] Đã xuất musical_beanstalk_stage.png: ", beanstalk_rect)

	# 3. Trích xuất Khung Bong Bóng Thoại ("Thỏa thích sáng tác nhạc nào! 🎵")
	# X khoảng 385..685 (w: 300), Y khoảng 160..265 (h: 105)
	var speech_rect := Rect2i(385, 160, 300, 105)
	var speech_img := mock_img.get_region(speech_rect)
	_apply_white_bubble_alpha(speech_img)
	speech_img.save_png("res://assets/art/speech_bubble_freeplay.png")
	print("[OK] Đã xuất speech_bubble_freeplay.png: ", speech_rect)

	# 4. Trích xuất Bé Phù Thủy Đeo Kính Sao Chơi Đàn Cầu Vồng (Trang trái)
	# X khoảng 390..700 (w: 310), Y khoảng 250..495 (h: 245)
	var wizard_rect := Rect2i(390, 250, 310, 245)
	var wizard_img := mock_img.get_region(wizard_rect)
	_apply_rounded_rect_feather(wizard_img, 0.04)
	wizard_img.save_png("res://assets/art/wizard_star_rainbow_piano.png")
	print("[OK] Đã xuất wizard_star_rainbow_piano.png: ", wizard_rect)

	# 5. Xử lý Bong Bóng Xà Phòng Âm Nhạc từ generated asset
	var bubble_src := "/Users/anhtu/.gemini/antigravity/brain/0373f0d1-4c62-416e-8235-931255c8f2bc/soap_bubbles_notes_1789139749096.jpg"
	if FileAccess.file_exists(bubble_src):
		var b_img := Image.load_from_file(bubble_src)
		if b_img != null:
			b_img.convert(Image.FORMAT_RGBA8)
			_remove_white_background(b_img, 0.92, 0.12)
			b_img.save_png("res://assets/art/vfx_bubbles_notes.png")
			print("[OK] Đã xuất vfx_bubbles_notes.png từ generated AI asset!")

	# 6. Xử lý Thanh Nhạc Cụ 4 Slots chất lượng cao từ generated asset
	var topbar_src := "/Users/anhtu/.gemini/antigravity/brain/0373f0d1-4c62-416e-8235-931255c8f2bc/freeplay_top_bar_1789139730724.jpg"
	if FileAccess.file_exists(topbar_src):
		var tb_img := Image.load_from_file(topbar_src)
		if tb_img != null:
			tb_img.convert(Image.FORMAT_RGBA8)
			_remove_white_background(tb_img, 0.94, 0.08)
			tb_img.save_png("res://assets/art/ui_top_bar_wood_hd.png")
			print("[OK] Đã xuất ui_top_bar_wood_hd.png từ generated AI asset!")

	print("=== HOÀN THÀNH XỬ LÝ TOÀN BỘ ASSET MÀN 03! ===")
	quit(0)


func _remove_white_background(img: Image, threshold: float, feather: float) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			# Tính độ sáng trung bình
			var brightness := (c.r + c.g + c.b) / 3.0
			var diff := absf(c.r - c.g) + absf(c.g - c.b) # Độ bão hòa màu
			if brightness > threshold and diff < 0.1:
				var alpha := clampf((1.0 - brightness) / feather, 0.0, 1.0)
				c.a = alpha
				img.set_pixel(x, y, c)


func _apply_white_bubble_alpha(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			# Nền ngoài khung thoại là màu trang sách/rừng tối
			if c.r < 0.85 and c.g < 0.85:
				var edge_fade := clampf((c.r + c.g) * 0.5, 0.0, 1.0)
				if edge_fade < 0.7:
					c.a = 0.0
					img.set_pixel(x, y, c)


func _apply_feather_and_chroma(img: Image, key_color: Color, tol: float, feather_ratio: float) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var feather_px := minf(w, h) * feather_ratio

	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			var dist := Vector3(c.r - key_color.r, c.g - key_color.g, c.b - key_color.b).length()
			if dist < tol:
				c.a = clampf((dist - (tol * 0.5)) / (tol * 0.5), 0.0, 1.0)

			var dist_x := minf(float(x), float(w - 1 - x))
			var dist_y := minf(float(y), float(h - 1 - y))
			var edge_dist := minf(dist_x, dist_y)

			if edge_dist < feather_px:
				var alpha := clampf(edge_dist / feather_px, 0.0, 1.0)
				c.a = minf(c.a, alpha * alpha * (3.0 - 2.0 * alpha))

			img.set_pixel(x, y, c)


func _apply_rounded_rect_feather(img: Image, feather_ratio: float) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var feather_px := minf(w, h) * feather_ratio

	for y in range(h):
		for x in range(w):
			var dist_x := minf(float(x), float(w - 1 - x))
			var dist_y := minf(float(y), float(h - 1 - y))
			var edge_dist := minf(dist_x, dist_y)

			if edge_dist < feather_px:
				var c := img.get_pixel(x, y)
				var alpha := clampf(edge_dist / feather_px, 0.0, 1.0)
				c.a = c.a * (alpha * alpha * (3.0 - 2.0 * alpha))
				img.set_pixel(x, y, c)
