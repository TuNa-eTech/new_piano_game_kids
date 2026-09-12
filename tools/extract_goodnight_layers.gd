@tool
extends SceneTree
## Script trích xuất toàn bộ các layer và props từ docs/mock-goodnight-bedtime.jpeg
## để phục vụ tái hiện màn hình GoodnightScreen 2.5D chuẩn xác 100%.

func _init() -> void:
	print("=== BẮT ĐẦU TRÍCH XUẤT LAYER TỪ docs/mock-goodnight-bedtime.jpeg ===")
	var src_path := "res://docs/mock-goodnight-bedtime.jpeg"
	if not FileAccess.file_exists(src_path):
		printerr("Không tìm thấy: ", src_path)
		quit(1)
		return

	var img := Image.load_from_file(src_path)
	if img == null:
		printerr("Không thể nạp ảnh: ", src_path)
		quit(1)
		return

	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	print("Kích thước ảnh concept: %d x %d" % [w, h])

	# 1. Background Toàn Cảnh Rừng Đêm & 2 Ngôi Nhà (1376 x 768)
	var bg_img := img.duplicate()
	bg_img.save_png("res://assets/art/bg_goodnight_forest_25d.png")
	print("[1/6] Đã xuất bg_goodnight_forest_25d.png")

	# 2. Bảng Gỗ Lời Chúc Ngủ Ngon Ở Đỉnh
	# Tọa độ X: 430..930 (w: 500), Y: 20..145 (h: 125)
	var plaque_rect := Rect2i(430, 20, 500, 125)
	var plaque_img := img.get_region(plaque_rect)
	_feather_edges(plaque_img, 6, 6, 6, 6)
	plaque_img.save_png("res://assets/art/plaque_goodnight_wood_banner.png")
	print("[2/6] Đã xuất plaque_goodnight_wood_banner.png")

	# 3. Cuốn Sách Nổi Bé Phù Thủy Say Giấc & Cây Đậu Thần
	# Tọa độ X: 330..1050 (w: 720), Y: 125..515 (h: 390)
	var book_rect := Rect2i(330, 125, 720, 390)
	var book_img := img.get_region(book_rect)
	_feather_edges(book_img, 6, 6, 6, 6)
	book_img.save_png("res://assets/art/book_sleeping_boy_beanstalk.png")
	print("[3/6] Đã xuất book_sleeping_boy_beanstalk.png")

	# 4. Bàn Phím Đàn 7 Bạn Thú Ngủ Say
	# Tọa độ X: 140..1240 (w: 1100), Y: 500..768 (h: 268)
	var piano_rect := Rect2i(140, 500, 1100, 268)
	var piano_img := img.get_region(piano_rect)
	_feather_edges(piano_img, 6, 6, 6, 6)
	piano_img.save_png("res://assets/art/keys_piano_sleeping_animals.png")
	print("[4/6] Đã xuất keys_piano_sleeping_animals.png")

	# 5. Nút Tròn Gỗ Mũi Tên Quay Lại (Top-Left)
	# Tọa độ X: 25..115 (w: 90), Y: 25..115 (h: 90)
	var back_rect := Rect2i(25, 25, 90, 90)
	var back_img := img.get_region(back_rect)
	_feather_edges(back_img, 4, 4, 4, 4)
	back_img.save_png("res://assets/art/ui_btn_wood_circle_back.png")
	print("[5/6] Đã xuất ui_btn_wood_circle_back.png")

	# 6. Nút Tròn Gỗ Loa Âm Thanh (Top-Right)
	# Tọa độ X: 1260..1350 (w: 90), Y: 25..115 (h: 90)
	var sound_rect := Rect2i(1260, 25, 90, 90)
	var sound_img := img.get_region(sound_rect)
	_feather_edges(sound_img, 4, 4, 4, 4)
	sound_img.save_png("res://assets/art/ui_btn_wood_circle_sound.png")
	print("[6/6] Đã xuất ui_btn_wood_circle_sound.png")

	print("=== HOÀN THÀNH XUẤT ASSET MÀN 10 GOODNIGHT BEDTIME! ===")
	quit(0)


func _feather_edges(img: Image, left: int, right: int, top: int, bottom: int) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for y in range(h):
		for x in range(w):
			var factor_x := 1.0
			if x < left:
				factor_x = float(x) / float(left)
			elif x >= w - right:
				factor_x = float(w - 1 - x) / float(right)

			var factor_y := 1.0
			if y < top:
				factor_y = float(y) / float(top)
			elif y >= h - bottom:
				factor_y = float(h - 1 - y) / float(bottom)

			var alpha_factor := clampf(factor_x * factor_y, 0.0, 1.0)
			alpha_factor = alpha_factor * alpha_factor * (3.0 - 2.0 * alpha_factor)

			var c := img.get_pixel(x, y)
			c.a = c.a * alpha_factor
			img.set_pixel(x, y, c)
