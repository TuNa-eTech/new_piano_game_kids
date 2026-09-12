@tool
extends SceneTree
## Script trích xuất toàn bộ các layer và props từ docs/mock-parental-gate.jpeg
## để phục vụ tái hiện màn hình ParentalGate 2.5D chuẩn xác 100%.

func _init() -> void:
	print("=== BẮT ĐẦU TRÍCH XUẤT LAYER TỪ docs/mock-parental-gate.jpeg ===")
	var src_path := "res://docs/mock-parental-gate.jpeg"
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

	# 1. Background Toàn Cảnh Rừng & 2 Ngôi Nhà (1376 x 768)
	var bg_img := img.duplicate()
	bg_img.save_png("res://assets/art/bg_parental_gate_forest_25d.png")
	print("[1/6] Đã xuất bg_parental_gate_forest_25d.png")

	# 2. Bảng Gỗ Treo Dây Thừng (Hanging Board)
	# Tọa độ X: 300..1075 (w: 775), Y: 0..590 (h: 590)
	var board_rect := Rect2i(300, 0, 775, 590)
	var board_img := img.get_region(board_rect)
	_feather_edges(board_img, 6, 6, 6, 6)
	board_img.save_png("res://assets/art/gate_hanging_board_chain.png")
	print("[2/6] Đã xuất gate_hanging_board_chain.png")

	# 3. Nút Đóng 'X' Gỗ Tròn
	# Tọa độ X: 990..1110 (w: 120), Y: 95..215 (h: 120)
	var close_rect := Rect2i(990, 95, 120, 120)
	var close_img := img.get_region(close_rect)
	_feather_edges(close_img, 4, 4, 4, 4)
	close_img.save_png("res://assets/art/ui_btn_close_wood_x.png")
	print("[3/6] Đã xuất ui_btn_close_wood_x.png")

	# 4. Ổ Khóa Đồng To Bản Ở Đáy Bảng
	# Tọa độ X: 615..760 (w: 145), Y: 535..745 (h: 210)
	var lock_rect := Rect2i(615, 535, 145, 210)
	var lock_img := img.get_region(lock_rect)
	_feather_edges(lock_img, 4, 4, 4, 4)
	lock_img.save_png("res://assets/art/padlock_brass_gate_closed.png")
	print("[4/6] Đã xuất padlock_brass_gate_closed.png")

	# 5. Bộ 3 Quả Trái Cây Gỗ (Chuối, Táo, Dâu)
	# Chuối: X: 380..495 (w: 115), Y: 375..495 (h: 120)
	var banana_rect := Rect2i(380, 375, 115, 120)
	var banana_img := img.get_region(banana_rect)
	_feather_edges(banana_img, 4, 4, 4, 4)
	banana_img.save_png("res://assets/art/fruit_banana_3d.png")

	# Táo: X: 515..625 (w: 110), Y: 375..495 (h: 120)
	var apple_rect := Rect2i(515, 375, 110, 120)
	var apple_img := img.get_region(apple_rect)
	_feather_edges(apple_img, 4, 4, 4, 4)
	apple_img.save_png("res://assets/art/fruit_apple_3d.png")

	# Dâu tây: X: 645..745 (w: 100), Y: 375..495 (h: 120)
	var straw_rect := Rect2i(645, 375, 100, 120)
	var straw_img := img.get_region(straw_rect)
	_feather_edges(straw_img, 4, 4, 4, 4)
	straw_img.save_png("res://assets/art/fruit_strawberry_3d.png")
	print("[5/6] Đã xuất fruit_banana_3d.png, fruit_apple_3d.png, fruit_strawberry_3d.png")

	print("=== HOÀN THÀNH XUẤT ASSET MÀN 08 PARENTAL GATE! ===")
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
