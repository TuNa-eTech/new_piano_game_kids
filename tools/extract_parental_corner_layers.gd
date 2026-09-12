@tool
extends SceneTree
## Script trích xuất toàn bộ các layer và props từ docs/mock-parental-corner.jpeg
## để phục vụ tái hiện màn hình ParentalCorner 2.5D chuẩn xác 100%.

func _init() -> void:
	print("=== BẮT ĐẦU TRÍCH XUẤT LAYER TỪ docs/mock-parental-corner.jpeg ===")
	var src_path := "res://docs/mock-parental-corner.jpeg"
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
	bg_img.save_png("res://assets/art/bg_parental_corner_forest_25d.png")
	print("[1/6] Đã xuất bg_parental_corner_forest_25d.png")

	# 2. Bàn Gỗ Chạm Khắc Phù Điêu & Bảng Gỗ Trung Tâm (Desk Frame & Relief Bear)
	# Tọa độ X: 210..980 (w: 770), Y: 130..660 (h: 530)
	var desk_rect := Rect2i(210, 130, 770, 530)
	var desk_img := img.get_region(desk_rect)
	_feather_edges(desk_img, 6, 6, 6, 6)
	desk_img.save_png("res://assets/art/parental_wood_desk.png")
	print("[2/6] Đã xuất parental_wood_desk.png")

	# 3. Đĩa Quay Hẹn Giờ Mặt Trăng Ru Ngủ (Bedtime Timer Dial)
	# Tọa độ X: 410..580 (w: 170), Y: 290..560 (h: 270)
	var dial_rect := Rect2i(410, 290, 170, 270)
	var dial_img := img.get_region(dial_rect)
	_feather_edges(dial_img, 6, 6, 6, 6)
	dial_img.save_png("res://assets/art/dial_timer_moon_ring.png")
	print("[3/6] Đã xuất dial_timer_moon_ring.png")

	# 4. Núm Trượt Gỗ Âm Lượng (Volume Slider Knob)
	# Tọa độ X: 300..370 (w: 70), Y: 370..530 (h: 160)
	var slider_rect := Rect2i(300, 370, 70, 160)
	var slider_img := img.get_region(slider_rect)
	_feather_edges(slider_img, 4, 4, 4, 4)
	slider_img.save_png("res://assets/art/ui_slider_wood_thumb.png")
	print("[4/6] Đã xuất ui_slider_wood_thumb.png")

	# 5. Công Tắc Viên Thuốc Gỗ Nhạc Ru Ngủ (Lullaby Pill Toggles)
	# Tọa độ X: 600..695 (w: 95), Y: 335..450 (h: 115)
	var toggle_rect := Rect2i(600, 335, 95, 115)
	var toggle_img := img.get_region(toggle_rect)
	_feather_edges(toggle_img, 4, 4, 4, 4)
	toggle_img.save_png("res://assets/art/ui_toggle_pill_switch.png")
	print("[5/6] Đã xuất ui_toggle_pill_switch.png")

	# 6. Mascot Bé Phù Thủy Ngủ Say Ôm Sư Tử Con (Sleeping Wizard Boy)
	# Tọa độ X: 840..1240 (w: 400), Y: 430..720 (h: 290)
	var boy_rect := Rect2i(840, 430, 400, 290)
	var boy_img := img.get_region(boy_rect)
	_feather_edges(boy_img, 8, 8, 8, 8)
	boy_img.save_png("res://assets/art/char_sleeping_wizard_bed.png")
	print("[6/6] Đã xuất char_sleeping_wizard_bed.png")

	print("=== HOÀN THÀNH XUẤT ASSET MÀN 09 PARENTAL CORNER! ===")
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
