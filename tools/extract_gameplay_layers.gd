@tool
extends SceneTree
## Script trích xuất và tối ưu hóa các asset UI/Gameplay 2.5D từ docs/mock-game-play.jpeg

func _init() -> void:
	print("--- Bắt đầu trích xuất UI & Props từ docs/mock-game-play.jpeg ---")
	var src_path := "res://docs/mock-game-play.jpeg"
	if not FileAccess.file_exists(src_path):
		printerr("Không tìm thấy: ", src_path)
		quit(1)
		return

	var img := Image.load_from_file(src_path)
	if img == null:
		printerr("Lỗi nạp ảnh: ", src_path)
		quit(1)
		return

	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	print("Kích thước ảnh nguồn: %d x %d" % [w, h])

	# 1. Trích xuất Thanh 5 Nhạc Cụ Góc Trái Trên (Top Instrument Bar)
	# Tọa độ pixel ~ X: 12..372 (w: 360), Y: 8..92 (h: 84)
	var bar_rect := Rect2i(12, 8, 360, 84)
	var bar_img := img.get_region(bar_rect)
	_apply_rounded_rect_feather(bar_img, 0.08)
	bar_img.save_png("res://assets/art/ui_bar_instruments_gameplay.png")
	print("[OK] Đã xuất ui_bar_instruments_gameplay.png: ", bar_rect)

	# 2. Trích xuất Bảng Điểm Gỗ (SCORE: 1250 / COMBO: 15)
	# Tọa độ pixel ~ X: 760..916 (w: 156), Y: 14..86 (h: 72)
	var score_rect := Rect2i(760, 14, 156, 72)
	var score_img := img.get_region(score_rect)
	_apply_rounded_rect_feather(score_img, 0.09)
	score_img.save_png("res://assets/art/ui_board_score_combo.png")
	print("[OK] Đã xuất ui_board_score_combo.png: ", score_rect)

	# 3. Trích xuất Nút Menu Nhà Nấm (Cottage Menu Button)
	# Tọa độ pixel ~ X: 932..1008 (w: 76), Y: 12..102 (h: 90)
	var menu_rect := Rect2i(932, 12, 76, 90)
	var menu_img := img.get_region(menu_rect)
	_apply_rounded_rect_feather(menu_img, 0.06)
	menu_img.save_png("res://assets/art/ui_btn_menu_cottage.png")
	print("[OK] Đã xuất ui_btn_menu_cottage.png: ", menu_rect)

	# 4. Trích xuất Nút Levels Ngôi Sao (Levels Star Button)
	# Tọa độ pixel ~ X: 932..1008 (w: 76), Y: 118..202 (h: 84)
	var levels_rect := Rect2i(932, 118, 76, 84)
	var levels_img := img.get_region(levels_rect)
	_apply_rounded_rect_feather(levels_img, 0.06)
	levels_img.save_png("res://assets/art/ui_btn_levels_star.png")
	print("[OK] Đã xuất ui_btn_levels_star.png: ", levels_rect)

	# 5. Trích xuất Rương Cỏ Góc Phải Dưới (Ground Chest)
	# Tọa độ pixel ~ X: 934..1012 (w: 78), Y: 340..420 (h: 80)
	var chest_rect := Rect2i(934, 340, 78, 80)
	var chest_img := img.get_region(chest_rect)
	_apply_rounded_rect_feather(chest_img, 0.08)
	chest_img.save_png("res://assets/art/chest_ground_mock.png")
	print("[OK] Đã xuất chest_ground_mock.png: ", chest_rect)

	print("--- Hoàn thành trích xuất asset gameplay! ---")
	quit(0)


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
