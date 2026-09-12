@tool
extends SceneTree
## Script trích xuất và tách nền trong suốt cho 7 thế hoạt ảnh của Phù Thủy và Sư Tử

func _init() -> void:
	print("--- Bắt đầu trích xuất sprite sheet nhân vật ---")
	var dir := DirAccess.open("res://")
	if not dir.dir_exists("assets/characters/wizard"):
		dir.make_dir_recursive("assets/characters/wizard")
	if not dir.dir_exists("assets/characters/lion"):
		dir.make_dir_recursive("assets/characters/lion")

	# Sao chép hình nền sạch mới vào assets/menu/
	var bg_src := "/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/menu_stage_no_chars_1789139846517.jpg"
	if FileAccess.file_exists(bg_src):
		var bg_bytes := FileAccess.get_file_as_bytes(bg_src)
		var f := FileAccess.open("res://assets/menu/tex_menu_stage_clean.jpg", FileAccess.WRITE)
		if f != null:
			f.store_buffer(bg_bytes)
			f.close()
			print("[OK] Đã lưu res://assets/menu/tex_menu_stage_clean.jpg")

	# 1. Trích xuất Phù Thủy
	var wiz_src := "/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/wizard_anim_sheet_1789139787221.jpg"
	if FileAccess.file_exists(wiz_src):
		var wiz_img := Image.load_from_file(wiz_src)
		wiz_img.convert(Image.FORMAT_RGBA8)
		_process_wizard(wiz_img)

	# 2. Trích xuất Sư Tử
	var lion_src := "/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/lion_anim_sheet_1789139816330.jpg"
	if FileAccess.file_exists(lion_src):
		var lion_img := Image.load_from_file(lion_src)
		lion_img.convert(Image.FORMAT_RGBA8)
		_process_lion(lion_img)

	print("--- Hoàn tất trích xuất toàn bộ sprite nhân vật ---")
	quit(0)


func _process_wizard(img: Image) -> void:
	# Toạ độ các box cho Phù Thủy (1376 x 768) có vùng đệm an toàn
	var boxes := {
		"idle": Rect2i(40, 75, 185, 292),
		"walk": Rect2i(265, 75, 205, 292),
		"jump": Rect2i(500, 55, 215, 310),
		"attack": Rect2i(770, 75, 270, 292),
		"hit": Rect2i(245, 415, 210, 280),
		"sleep": Rect2i(530, 505, 260, 195),
		"special": Rect2i(1100, 335, 255, 350),
	}

	for anim_name in boxes:
		var rect: Rect2i = boxes[anim_name]
		var sub := img.get_region(rect)
		_make_transparent(sub)
		var out_path := "res://assets/characters/wizard/wizard_%s.png" % anim_name
		sub.save_png(out_path)
		print("[OK] Đã xuất ", out_path)


func _process_lion(img: Image) -> void:
	# Toạ độ các box cho Sư Tử (1376 x 768) có vùng đệm an toàn giữ trọn vẹn bờm và trống
	var boxes := {
		"idle": Rect2i(35, 150, 210, 196),
		"walk": Rect2i(290, 150, 225, 196),
		"jump": Rect2i(540, 95, 250, 245),
		"attack": Rect2i(815, 115, 245, 233),
		"hit": Rect2i(410, 465, 260, 225),
		"sleep": Rect2i(720, 510, 270, 190),
		"special": Rect2i(1070, 465, 270, 255),
	}

	for anim_name in boxes:
		var rect: Rect2i = boxes[anim_name]
		var sub := img.get_region(rect)
		_make_transparent(sub)
		var out_path := "res://assets/characters/lion/lion_%s.png" % anim_name
		sub.save_png(out_path)
		print("[OK] Đã xuất ", out_path)


## Chuyển nền trắng và bóng đổ xám sang trong suốt hoàn toàn
static func _make_transparent(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()

	var visited := PackedByteArray()
	visited.resize(w * h)
	visited.fill(0)

	var queue: Array[Vector2i] = []
	# Thêm các pixel viền ngoài
	for x in w:
		queue.append(Vector2i(x, 0))
		queue.append(Vector2i(x, h - 1))
	for y in range(1, h - 1):
		queue.append(Vector2i(0, y))
		queue.append(Vector2i(w - 1, y))

	var head := 0
	while head < queue.size():
		var p := queue[head]
		head += 1
		var idx := p.y * w + p.x
		if visited[idx] == 1:
			continue
		visited[idx] = 1

		var col := img.get_pixel(p.x, p.y)
		var max_c := maxf(col.r, maxf(col.g, col.b))
		var min_c := minf(col.r, minf(col.g, col.b))
		var diff := max_c - min_c
		var bright := (col.r + col.g + col.b) / 3.0

		# Pixel được tính là nền hoặc bóng xám/xanh trên nền trắng nếu:
		# 1. Rất sáng (> 0.75)
		# 2. Hoặc có màu trung tính/xám nhạt (diff < 0.18) và sáng (> 0.40)
		# 3. Hoặc có bóng mờ nhạt (diff < 0.25) và sáng (> 0.62)
		var is_bg: bool = (bright > 0.75) or (diff < 0.18 and bright > 0.40) or (diff < 0.25 and bright > 0.62)

		if is_bg:
			col.a = 0.0
			img.set_pixel(p.x, p.y, col)

			# Tiếp tục lan truyền flood fill
			if p.x > 0 and visited[idx - 1] == 0:
				queue.append(Vector2i(p.x - 1, p.y))
			if p.x < w - 1 and visited[idx + 1] == 0:
				queue.append(Vector2i(p.x + 1, p.y))
			if p.y > 0 and visited[idx - w] == 0:
				queue.append(Vector2i(p.x, p.y - 1))
			if p.y < h - 1 and visited[idx + w] == 0:
				queue.append(Vector2i(p.x, p.y + 1))
		elif bright > 0.65 and diff < 0.30:
			# Rìa mờ chống răng cưa
			var a := clampf((0.75 - bright) / 0.10, 0.0, 1.0)
			col.a = a
			img.set_pixel(p.x, p.y, col)
