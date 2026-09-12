@tool
extends SceneTree
## Script trích xuất và bóc tách các layer 2.5D độc lập:
## 1. Nền rừng sạch không chứa sách/đàn/HUD (bg_fairytale_village_clean_25d.jpg)
## 2. Cuốn sách và cây đậu thần tách nền độc lập (storybook_isolated.png)
## 3. Bệ đàn console gỗ 2.5D tách nền độc lập (piano_console_isolated.png)

func _init() -> void:
	print("=== BẮT ĐẦU BÓC TÁCH CÁC LỚP LAYER 2.5D ĐỘC LẬP ===")
	var src_path := "res://docs/mock-game-play.jpeg"
	if not FileAccess.file_exists(src_path):
		printerr("Không tìm thấy: ", src_path)
		quit(1)
		return

	var img := Image.load_from_file(src_path)
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()

	# 1. Bóc tách Cuốn Sách Tranh + Cây Đậu Thần thành Layer độc lập (X: 242..778, Y: 30..364)
	# Tuyệt đối kết thúc tại Y=364 trước khi chạm bệ đàn piano (Y=366) để không bị dính nốt đàn
	var book_rect := Rect2i(242, 30, 536, 334)
	var book_img := img.get_region(book_rect)
	_mask_storybook_alpha(book_img)
	book_img.save_png("res://assets/art/storybook_isolated_25d.png")
	print("[OK] Đã xuất storybook_isolated_25d.png (Cuốn sách + Cây Đậu Thần tách nền chuẩn 100%)")

	# 2. Bóc tách Bệ Đàn Piano Gỗ 2.5D thành Layer độc lập (X: 90..900, Y: 360..572)
	# 4. Trích xuất toàn bộ bộ asset Piano 2.5D sạch 100% từ piano_console_source_clean_25d.jpg
	_extract_clean_piano_suite()

	quit(0)


func _mask_storybook_alpha(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	# Book cover top edge starts around y = 68 (since book_rect.position.y = 30 and book cover top is y ~ 98)
	# For y < 68:
	#   The beanstalk & chest span roughly x in [260, 480]
	#   Outside this beanstalk corridor, everything is background sky/trees and MUST be transparent (a = 0)
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			var a := 1.0
			
			# Area above the book (y < 68): only beanstalk and chest exist!
			if y < 68:
				if x < 260:
					# Left of beanstalk above book: completely transparent
					a = 0.0
				elif x > 490:
					# Right of beanstalk above book: completely transparent
					a = 0.0
				else:
					# Within beanstalk corridor: feather gently at outer boundaries
					if x < 275:
						a = float(x - 260) / 15.0
					elif x > 475:
						a = float(490 - x) / 15.0
					if y < 8:
						a = minf(a, float(y) / 8.0)
			else:
				# Below book top edge:
				# Feather outer borders of the book cover
				if x < 10:
					a = minf(a, float(x) / 10.0)
				if x > w - 10:
					a = minf(a, float(w - 1 - x) / 10.0)
				if y > h - 10:
					a = minf(a, float(h - 1 - y) / 10.0)
					
			c.a = c.a * a
			img.set_pixel(x, y, c)


func _mask_piano_console_alpha(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			var a := 1.0
			# Mép trái ngoài tai cuộn gỗ
			if x < 12:
				a = minf(a, float(x) / 12.0)
			# Mép phải ngoài tai cuộn gỗ
			if x > w - 12:
				a = minf(a, float(w - 1 - x) / 12.0)
			# Mép trên ngoài thanh nẹp gỗ (trừ vùng dải lụa bay lên ở X: 240..600)
			if y < 10:
				if x < 230 or x > 610:
					a = minf(a, float(y) / 10.0)
			# Mép dưới
			if y > h - 8:
				a = minf(a, float(h - 1 - y) / 8.0)
			c.a = c.a * a
			img.set_pixel(x, y, c)


func _extract_clean_piano_suite() -> void:
	var src_path := "res://assets/art/piano_console_source_clean_25d.jpg"
	if not FileAccess.file_exists(src_path):
		printerr("Không tìm thấy: ", src_path)
		return

	var img := Image.load_from_file(src_path)
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	print("Đang xử lý piano_console_source: ", w, "x", h)

	# 1. Đo bounding box của cây đàn (loại bỏ màu xanh lá nền)
	# Màu xanh lá nền: G > 0.45 và G > R * 1.3 và G > B * 1.3
	var min_x := w
	var max_x := 0
	var min_y := h
	var max_y := 0

	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			var is_green: bool = c.g > 0.42 and c.g > c.r * 1.25 and c.g > c.b * 1.25
			if is_green:
				# Chroma key ra trong suốt với khử viền xanh
				c.a = 0.0
				img.set_pixel(x, y, c)
			else:
				# Chỉ xét nửa trên của ảnh (cây đàn) - nửa dưới là hàng icon phụ
				if y < 600:
					min_x = mini(min_x, x)
					max_x = maxi(max_x, x)
					min_y = mini(min_y, y)
					max_y = maxi(max_y, y)

	print("Bounding box bệ đàn: X: ", min_x, "..", max_x, " Y: ", min_y, "..", max_y)

	# Cắt vùng cây đàn chính
	var pad := 6
	var p_x: int = maxi(0, min_x - pad)
	var p_y: int = maxi(0, min_y - pad)
	var p_w: int = mini(w - p_x, (max_x - min_x) + pad * 2)
	var p_h: int = mini(h - p_y, (max_y - min_y) + pad * 2)
	var piano_main := img.get_region(Rect2i(p_x, p_y, p_w, p_h))
	
	piano_main.save_png("res://assets/art/piano_console_master_clean_25d.png")
	print("[OK] Đã xuất piano_console_master_clean_25d.png: ", p_w, "x", p_h)
