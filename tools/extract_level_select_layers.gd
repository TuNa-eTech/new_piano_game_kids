@tool
extends SceneTree
## Script trích xuất toàn bộ các layer và props từ docs/mock-level-select.jpeg
## để phục vụ tái hiện màn hình Level Select 2.5D Diorama chuẩn xác 100%.

func _init() -> void:
	print("=== BẮT ĐẦU TRÍCH XUẤT LAYER TỪ docs/mock-level-select.jpeg ===")
	var src_path := "res://docs/mock-level-select.jpeg"
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

	# 1. Background Toàn Cảnh Rừng Cổ Tích & 2 Ngôi Nhà (1376 x 768)
	var bg_img := img.duplicate()
	bg_img.save_png("res://assets/art/bg_level_select_forest_25d.png")
	print("[1/9] Đã xuất bg_level_select_forest_25d.png (Toàn cảnh phông nền rừng)")

	# 2. Bảng Gỗ Tiêu Đề 'Chương 1: Sáo Trúc Rừng Xanh'
	# Tọa độ X: 410..966 (w: 556), Y: 28..156 (h: 128)
	var banner_rect := Rect2i(410, 28, 556, 128)
	var banner_img := img.get_region(banner_rect)
	_feather_edges(banner_img, 6, 6, 6, 6)
	banner_img.save_png("res://assets/art/ui_banner_chapter1_wood.png")
	print("[2/9] Đã xuất ui_banner_chapter1_wood.png (Bảng gỗ tiêu đề chương)")

	# 3. Nút Gỗ 'Quay Lại' Góc Trái Trên
	# Tọa độ X: 24..246 (w: 222), Y: 28..108 (h: 80)
	var back_rect := Rect2i(24, 28, 222, 80)
	var back_img := img.get_region(back_rect)
	_feather_edges(back_img, 6, 6, 6, 6)
	back_img.save_png("res://assets/art/ui_btn_back_wood_pill.png")
	print("[3/9] Đã xuất ui_btn_back_wood_pill.png (Nút quay lại viên thuốc bo tròn)")

	# 4. Hũ Thủy Tinh Sao Vàng Góc Phải Trên
	# Tọa độ X: 1248..1340 (w: 92), Y: 14..138 (h: 124)
	var jar_rect := Rect2i(1248, 14, 92, 124)
	var jar_img := img.get_region(jar_rect)
	_feather_edges(jar_img, 4, 4, 4, 4)
	jar_img.save_png("res://assets/art/ui_star_jar_top_right.png")
	print("[4/9] Đã xuất ui_star_jar_top_right.png (Hũ sao thủy tinh nắp bần)")

	# 5. Bạn Thỏ Trắng Nhạc Sĩ Đứng Vẫy Tay (White Bunny Maestro)
	# Tọa độ X: 835..955 (w: 120), Y: 355..560 (h: 205)
	var bunny_rect := Rect2i(835, 355, 120, 205)
	var bunny_img := img.get_region(bunny_rect)
	_feather_edges(bunny_img, 8, 8, 8, 8)
	bunny_img.save_png("res://assets/art/prop_rabbit_maestro_mascot.png")
	print("[5/9] Đã xuất prop_rabbit_maestro_mascot.png (Bạn Thỏ trắng vẫy tay)")

	# 6. Chiếc Rương Báu Thần Mạ Vàng Trên Bục 5
	# Tọa độ X: 1050..1180 (w: 130), Y: 470..600 (h: 130)
	var chest_rect := Rect2i(1050, 470, 130, 130)
	var chest_img := img.get_region(chest_rect)
	_feather_edges(chest_img, 6, 6, 6, 6)
	chest_img.save_png("res://assets/art/prop_chest_level5_gold.png")
	print("[6/9] Đã xuất prop_chest_level5_gold.png (Rương báu thần mạ vàng)")

	# 7. Bục Gỗ Khoanh Cây Tiêu Chuẩn (Thớt Gỗ Cắt Ngang)
	# Lấy vùng bục số 2 làm mẫu sạch (X: 415..565 (w: 150), Y: 500..595 (h: 95))
	var pad_rect := Rect2i(415, 500, 150, 95)
	var pad_img := img.get_region(pad_rect)
	_feather_edges(pad_img, 6, 6, 6, 6)
	pad_img.save_png("res://assets/art/spr_level_pad_wood_slice.png")
	print("[7/9] Đã xuất spr_level_pad_wood_slice.png (Bục gỗ khoanh cây)")

	# 8. Cụm 3 Ngôi Sao Vàng Dập Nổi
	# Lấy từ cụm sao trên bục 2: X: 430..555 (w: 125), Y: 460..510 (h: 50)
	var stars_rect := Rect2i(430, 460, 125, 50)
	var stars_img := img.get_region(stars_rect)
	_feather_edges(stars_img, 4, 4, 4, 4)
	stars_img.save_png("res://assets/art/ui_stars_3_cluster.png")
	print("[8/9] Đã xuất ui_stars_3_cluster.png (Cụm 3 sao vàng)")

	# 9. Bộ 3 Huy Hiệu Bạn Thú Cắm Cọc Đường (Sư tử, Gấu, Mèo)
	# Lion: X: 310..395 (w: 85), Y: 395..480 (h: 85)
	var lion_rect := Rect2i(310, 395, 85, 85)
	var lion_img := img.get_region(lion_rect)
	_feather_edges(lion_img, 4, 4, 4, 4)
	lion_img.save_png("res://assets/art/badge_companion_lion.png")

	# Bear: X: 410..485 (w: 75), Y: 380..455 (h: 75)
	var bear_rect := Rect2i(410, 380, 75, 75)
	var bear_img := img.get_region(bear_rect)
	_feather_edges(bear_img, 4, 4, 4, 4)
	bear_img.save_png("res://assets/art/badge_companion_bear.png")

	# Cat: X: 505..580 (w: 75), Y: 360..435 (h: 75)
	var cat_rect := Rect2i(505, 360, 75, 75)
	var cat_img := img.get_region(cat_rect)
	_feather_edges(cat_img, 4, 4, 4, 4)
	cat_img.save_png("res://assets/art/badge_companion_cat.png")
	print("[9/9] Đã xuất badge_companion_lion.png, bear.png, cat.png (Bộ huy hiệu bạn thú)")

	print("=== HOÀN THÀNH XUẤT TOÀN BỘ ASSET MÀN 05 LEVEL SELECT! ===")
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
