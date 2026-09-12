@tool
extends SceneTree
## Script trích xuất toàn bộ các layer và props từ docs/mock-game-play.jpeg
## để tái hiện 100% Visual Fidelity cho màn hình Gameplay 2.5D.

func _init() -> void:
	print("=== BẮT ĐẦU TRÍCH XUẤT LAYER TỪ docs/mock-game-play.jpeg ===")
	var src_path := "res://docs/mock-game-play.jpeg"
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

	# 1. Background Làng Cổ Tích Toàn Cảnh (1024 x 572)
	# Lưu ảnh nền đầy đủ gồm 2 ngôi nhà cổ tích 2 bên, vòm cây hoàng hôn và thảm cỏ hoa
	var bg_img := img.duplicate()
	bg_img.save_png("res://assets/art/bg_fairytale_village_25d.png")
	print("[1/8] Đã xuất bg_fairytale_village_25d.png (Toàn cảnh rừng & 2 ngôi nhà)")

	# 2. Cuốn Sách Tranh Diorama Đầy Đủ (Book Diorama Stage)
	# Vùng sách: X: 240..776 (w: 536), Y: 40..376 (h: 336)
	# Bao gồm: Phù thủy nhỏ bên trái, Cây Đậu Thần xoắn ốc vươn cao với lá nốt nhạc và rương vàng bên phải
	var book_rect := Rect2i(240, 40, 536, 336)
	var book_img := img.get_region(book_rect)
	_feather_edges(book_img, 12, 12, 12, 12)
	book_img.save_png("res://assets/art/storybook_beanstalk_diorama_25d.png")
	print("[2/8] Đã xuất storybook_beanstalk_diorama_25d.png (Sách tranh + Cây Đậu Thần + Phù Thủy)")

	# 3. Bệ Đàn Piano Gỗ Console 2.5D (Chassis & Keys)
	# Vùng bệ đàn: X: 95..895 (w: 800), Y: 362..570 (h: 208)
	# Điêu khắc hoa văn cuộn 2 bên, thanh nẹp trên và 7 phím C-B
	var piano_rect := Rect2i(95, 362, 800, 208)
	var piano_img := img.get_region(piano_rect)
	_feather_edges(piano_img, 6, 6, 6, 6)
	piano_img.save_png("res://assets/art/piano_console_wood_chassis_25d.png")
	print("[3/8] Đã xuất piano_console_wood_chassis_25d.png (Bệ gỗ 2.5D + Phím đàn Diatonic)")

	# 4. Trích xuất 7 Phím Đàn Riêng Biệt (Key C -> B) để tạo Animation Nhấn Phím 2.5D
	# Trong piano_rect (w: 800, h: 208), các phím trắng bắt đầu từ local X ~ 58..744 (tổng rộng ~686 px)
	# Mỗi phím rộng ~ 98 px, cao ~ 152 px (local Y: 42..194)
	var key_start_x := 154 # Tọa độ tuyệt đối trên ảnh gốc
	var key_y := 404
	var key_w := 98
	var key_h := 150
	for i in range(7):
		var k_rect := Rect2i(key_start_x + i * key_w, key_y, key_w, key_h)
		var k_img := img.get_region(k_rect)
		_feather_edges(k_img, 4, 4, 4, 4)
		var k_path := "res://assets/art/piano_key_25d_slice_%d.png" % i
		k_img.save_png(k_path)
	print("[4/8] Đã xuất 7 phím piano_key_25d_slice_0..6.png (C, D, E, F, G, A, B)")

	# 5. Dải Lụa Ma Thuật Khóa Sol (Magic Musical Ribbon Trail)
	# Vùng dải lụa ngũ sắc uốn từ phím đàn lên cây đậu thần: X: 340..710 (w: 370), Y: 180..450 (h: 270)
	var ribbon_rect := Rect2i(340, 180, 370, 270)
	var ribbon_img := img.get_region(ribbon_rect)
	_feather_edges(ribbon_img, 16, 16, 16, 16)
	ribbon_img.save_png("res://assets/art/magic_musical_ribbon_trail.png")
	print("[5/8] Đã xuất magic_musical_ribbon_trail.png (Dải lụa ngũ sắc Khóa Sol)")

	# 6. Cụm Thạch Anh Xanh Ngọc (Cyan Crystal on Stump) - Khử viền trắng triệt để
	# Tọa độ X: 0..86 (w: 86), Y: 370..465 (h: 95)
	var cyan_rect := Rect2i(0, 370, 86, 95)
	var cyan_img := img.get_region(cyan_rect)
	_feather_edges(cyan_img, 6, 6, 6, 6)
	cyan_img.save_png("res://assets/art/crystal_cyan_mock_clean.png")
	print("[6/8] Đã xuất crystal_cyan_mock_clean.png")

	# 7. Cụm Thạch Anh Hồng Tím (Magenta Crystal on Stump)
	# Tọa độ X: 782..834 (w: 52), Y: 378..458 (h: 80)
	var mag_rect := Rect2i(782, 378, 52, 80)
	var mag_img := img.get_region(mag_rect)
	_feather_edges(mag_img, 6, 6, 6, 6)
	mag_img.save_png("res://assets/art/crystal_magenta_mock_clean.png")
	print("[7/8] Đã xuất crystal_magenta_mock_clean.png")

	# 8. Bong Bóng Thoại Hoạt Hình (Speech Bubble Cartoon)
	# Tọa độ X: 278..502 (w: 224), Y: 110..182 (h: 72)
	var bubble_rect := Rect2i(278, 110, 224, 72)
	var bubble_img := img.get_region(bubble_rect)
	_feather_edges(bubble_img, 6, 6, 6, 6)
	bubble_img.save_png("res://assets/art/speech_bubble_cartoon_clean.png")
	print("[8/8] Đã xuất speech_bubble_cartoon_clean.png")

	print("=== HOÀN THÀNH XUẤT TOÀN BỘ ASSET LAYER 2.5D! ===")
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
			# Smoothstep easing
			alpha_factor = alpha_factor * alpha_factor * (3.0 - 2.0 * alpha_factor)

			var c := img.get_pixel(x, y)
			c.a = c.a * alpha_factor
			img.set_pixel(x, y, c)
