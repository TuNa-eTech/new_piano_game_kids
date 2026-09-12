@tool
extends SceneTree
## Script trích xuất và tiền xử lý các layer mỹ thuật 2.5D từ mock-main-menu.jpeg

func _init() -> void:
	print("--- Bắt đầu trích xuất layer 2.5D cho Main Menu ---")
	var dir := DirAccess.open("res://")
	if not dir.dir_exists("assets/menu"):
		dir.make_dir_recursive("assets/menu")

	var src_path := "res://docs/mock-main-menu.jpeg"
	if not FileAccess.file_exists(src_path):
		printerr("Không tìm thấy file nguồn: ", src_path)
		quit(1)
		return

	var img := Image.load_from_file(src_path)
	if img == null:
		printerr("Không tải được ảnh: ", src_path)
		quit(1)
		return

	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	print("Kích thước ảnh nguồn: %d x %d" % [w, h])

	# 1. Trích xuất Nút PLAY (Bục gỗ + Khóa Son + Chữ PLAY)
	# Tọa độ ~ 900..1200 X, 340..660 Y
	var play_rect := Rect2i(int(w * 0.655), int(h * 0.45), int(w * 0.22), int(h * 0.38))
	var play_img := img.get_region(play_rect)
	_apply_circular_feather(play_img, 0.48, 0.08)
	play_img.save_png("res://assets/menu/tex_play_button.png")
	print("[OK] Đã xuất tex_play_button.png: ", play_rect)

	# 2. Trích xuất Cuốn sách trung tâm "MUSIC FOREST" & Đàn Accordion
	var book_rect := Rect2i(int(w * 0.34), int(h * 0.17), int(w * 0.33), int(h * 0.68))
	var book_img := img.get_region(book_rect)
	_apply_rounded_rect_feather(book_img, 0.06)
	book_img.save_png("res://assets/menu/tex_book_center.png")
	print("[OK] Đã xuất tex_book_center.png: ", book_rect)

	# 3. Trích xuất Nhân vật (Bé Phù Thủy & Sư Tử Con)
	var char_rect := Rect2i(int(w * 0.12), int(h * 0.38), int(w * 0.26), int(h * 0.46))
	var char_img := img.get_region(char_rect)
	_apply_rounded_rect_feather(char_img, 0.08)
	char_img.save_png("res://assets/menu/tex_characters.png")
	print("[OK] Đã xuất tex_characters.png: ", char_rect)

	# 4. Trích xuất Nút Levels (Huy hiệu ngôi sao)
	var levels_rect := Rect2i(int(w * 0.015), int(h * 0.03), int(w * 0.10), int(h * 0.19))
	var levels_img := img.get_region(levels_rect)
	_apply_circular_feather(levels_img, 0.46, 0.06)
	levels_img.save_png("res://assets/menu/tex_btn_levels.png")
	print("[OK] Đã xuất tex_btn_levels.png: ", levels_rect)

	# 5. Trích xuất Nút Parents (Huy hiệu mặt trăng)
	var parents_rect := Rect2i(int(w * 0.885), int(h * 0.03), int(w * 0.10), int(h * 0.19))
	var parents_img := img.get_region(parents_rect)
	_apply_circular_feather(parents_img, 0.46, 0.06)
	parents_img.save_png("res://assets/menu/tex_btn_parents.png")
	print("[OK] Đã xuất tex_btn_parents.png: ", parents_rect)

	# 6. Trích xuất Bàn Gỗ & Thảm Rêu Tiền Cảnh
	var desk_rect := Rect2i(0, int(h * 0.72), w, int(h * 0.28))
	var desk_img := img.get_region(desk_rect)
	desk_img.save_png("res://assets/menu/tex_desk_foreground.png")
	print("[OK] Đã xuất tex_desk_foreground.png: ", desk_rect)

	# 7. Trích xuất Tinh thể Pha Lê Cyan (Góc trái)
	var crystal_rect := Rect2i(0, int(h * 0.54), int(w * 0.12), int(h * 0.24))
	var crystal_img := img.get_region(crystal_rect)
	_apply_rounded_rect_feather(crystal_img, 0.1)
	crystal_img.save_png("res://assets/menu/tex_crystal_left.png")
	print("[OK] Đã xuất tex_crystal_left.png: ", crystal_rect)

	# 8. Trích xuất Rương Báu (Góc phải)
	var chest_rect := Rect2i(int(w * 0.89), int(h * 0.58), int(w * 0.11), int(h * 0.20))
	var chest_img := img.get_region(chest_rect)
	_apply_rounded_rect_feather(chest_img, 0.1)
	chest_img.save_png("res://assets/menu/tex_chest_right.png")
	print("[OK] Đã xuất tex_chest_right.png: ", chest_rect)

	print("--- Hoàn tất trích xuất 8 layer mỹ thuật 2.5D ---")
	quit(0)


## Tạo mặt nạ viền mờ bo tròn (Circular Feather Mask)
static func _apply_circular_feather(img: Image, radius_ratio: float, feather_ratio: float) -> void:
	var iw := img.get_width()
	var ih := img.get_height()
	var center := Vector2(iw * 0.5, ih * 0.5)
	var max_r := minf(iw, ih) * radius_ratio
	var feather_dist := minf(iw, ih) * feather_ratio

	for y in ih:
		for x in iw:
			var d := center.distance_to(Vector2(x, y))
			var alpha: float = 1.0
			if d > max_r:
				var excess := d - max_r
				alpha = clampf(1.0 - (excess / feather_dist), 0.0, 1.0)
			var c := img.get_pixel(x, y)
			c.a *= alpha
			img.set_pixel(x, y, c)


## Tạo mặt nạ viền mờ hình chữ nhật (Rounded Rect Feather Mask)
static func _apply_rounded_rect_feather(img: Image, feather_margin_ratio: float) -> void:
	var iw := img.get_width()
	var ih := img.get_height()
	var fx := iw * feather_margin_ratio
	var fy := ih * feather_margin_ratio

	for y in ih:
		for x in iw:
			var dx := minf(float(x), float(iw - 1 - x))
			var dy := minf(float(y), float(ih - 1 - y))
			var ax := clampf(dx / fx, 0.0, 1.0)
			var ay := clampf(dy / fy, 0.0, 1.0)
			var a := ax * ay
			var c := img.get_pixel(x, y)
			c.a *= a
			img.set_pixel(x, y, c)
