@tool
extends SceneTree
## Script trích xuất và tách nền trong suốt cho các bộ Sprite Sheet Animation chuẩn 12 nguyên lý

func _init() -> void:
	print("=== BẮT ĐẦU TRÍCH XUẤT CÁC BỘ MULTI-FRAME ANIMATION SPRITE SHEETS ===")
	var dir := DirAccess.open("res://")
	dir.make_dir_recursive("assets/characters/wizard/anims/jump")
	dir.make_dir_recursive("assets/characters/wizard/anims/walk")
	dir.make_dir_recursive("assets/characters/lion/anims/jump")

	# 1. Trích xuất Wizard Jump (7 frames theo nguyên lý Anticipation -> Apex -> Recovery)
	var wiz_jump_src := "/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/wizard_jump_frames_1789141798823.jpg"
	if FileAccess.file_exists(wiz_jump_src):
		print("[1/3] Đang xử lý Wizard Jump Frames...")
		var img := Image.load_from_file(wiz_jump_src)
		img.convert(Image.FORMAT_RGBA8)
		_slice_wizard_jump(img)

	# 2. Trích xuất Lion Jump (8 frames: Anticipation -> Spring -> Apex -> Landing -> Recovery)
	var lion_jump_src := "/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/lion_jump_frames_1789141972723.jpg"
	if FileAccess.file_exists(lion_jump_src):
		print("[2/3] Đang xử lý Lion Jump Frames...")
		var img := Image.load_from_file(lion_jump_src)
		img.convert(Image.FORMAT_RGBA8)
		_slice_lion_jump(img)

	# 3. Trích xuất Wizard Walk Cycle (6 frames: Contact -> Down -> Pass -> Up)
	var wiz_walk_src := "/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/wizard_walk_frames_1789141999053.jpg"
	if FileAccess.file_exists(wiz_walk_src):
		print("[3/3] Đang xử lý Wizard Walk Cycle Frames...")
		var img := Image.load_from_file(wiz_walk_src)
		img.convert(Image.FORMAT_RGBA8)
		_slice_wizard_walk(img)

	print("=== HOÀN TẤT TRÍCH XUẤT CÁC BỘ ANIMATION FRAMES ===")
	quit(0)


func _slice_wizard_jump(img: Image) -> void:
	# Cắt 7 frames từ dải ảnh 1376x768 (Ground line ở Y ~ 720)
	var boxes: Array[Rect2i] = [
		Rect2i(20, 390, 185, 325),   # Frame 0: Idle Ready
		Rect2i(210, 420, 185, 295),  # Frame 1: Anticipation Crouch (Squash)
		Rect2i(400, 220, 185, 380),  # Frame 2: Takeoff Launch (Stretch)
		Rect2i(590, 70, 210, 390),   # Frame 3: Apex Float with Wand
		Rect2i(800, 200, 210, 370),  # Frame 4: Descent (Cape follow-through)
		Rect2i(960, 420, 210, 295),  # Frame 5: Landing Impact (Squash)
		Rect2i(1170, 390, 190, 325), # Frame 6: Recovery (Standing)
	]

	for i in boxes.size():
		var sub := img.get_region(boxes[i])
		_make_transparent(sub)
		var out_path := "res://assets/characters/wizard/anims/jump/jump_%d.png" % i
		sub.save_png(out_path)
		print("  -> Đã lưu ", out_path)


func _slice_lion_jump(img: Image) -> void:
	# Cắt 8 frames từ dải 2 hàng 4 cột
	var boxes: Array[Rect2i] = [
		# Hàng 1
		Rect2i(20, 95, 280, 255),    # Frame 0: Ready
		Rect2i(320, 150, 300, 200),  # Frame 1: Anticipation Crouch
		Rect2i(650, 75, 330, 260),   # Frame 2: Spring Launch
		Rect2i(990, 95, 330, 240),   # Frame 3: Apex Flying Leap
		# Hàng 2
		Rect2i(20, 430, 280, 255),   # Frame 4: Descending
		Rect2i(320, 420, 320, 265),  # Frame 5: Reaching ground
		Rect2i(680, 480, 310, 210),  # Frame 6: Landing Impact Squash
		Rect2i(1040, 430, 280, 260), # Frame 7: Recovery & Tail wag
	]

	for i in boxes.size():
		var sub := img.get_region(boxes[i])
		_make_transparent(sub)
		var out_path := "res://assets/characters/lion/anims/jump/jump_%d.png" % i
		sub.save_png(out_path)
		print("  -> Đã lưu ", out_path)


func _slice_wizard_walk(img: Image) -> void:
	# Cắt 6 frames walk cycle (Y: 150 -> 545)
	var boxes: Array[Rect2i] = [
		Rect2i(30, 150, 215, 385),   # Frame 0: Contact Right
		Rect2i(250, 150, 215, 385),  # Frame 1: Down / Squash
		Rect2i(470, 150, 215, 385),  # Frame 2: Passing
		Rect2i(690, 150, 215, 385),  # Frame 3: Contact Left
		Rect2i(910, 150, 215, 385),  # Frame 4: Down / Squash
		Rect2i(1130, 150, 215, 385), # Frame 5: Passing / Up
	]

	for i in boxes.size():
		var sub := img.get_region(boxes[i])
		_make_transparent(sub)
		var out_path := "res://assets/characters/wizard/anims/walk/walk_%d.png" % i
		sub.save_png(out_path)
		print("  -> Đã lưu ", out_path)


## Khử nền trắng và bóng xám, giữ đường nét nhân vật
static func _make_transparent(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()

	var visited := PackedByteArray()
	visited.resize(w * h)
	visited.fill(0)

	var queue: Array[Vector2i] = []
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

		var is_bg: bool = (bright > 0.75) or (diff < 0.18 and bright > 0.40) or (diff < 0.25 and bright > 0.62)

		if is_bg:
			col.a = 0.0
			img.set_pixel(p.x, p.y, col)

			if p.x > 0 and visited[idx - 1] == 0:
				queue.append(Vector2i(p.x - 1, p.y))
			if p.x < w - 1 and visited[idx + 1] == 0:
				queue.append(Vector2i(p.x + 1, p.y))
			if p.y > 0 and visited[idx - w] == 0:
				queue.append(Vector2i(p.x, p.y - 1))
			if p.y < h - 1 and visited[idx + w] == 0:
				queue.append(Vector2i(p.x, p.y + 1))
		elif bright > 0.65 and diff < 0.30:
			var a := clampf((0.75 - bright) / 0.10, 0.0, 1.0)
			col.a = a
			img.set_pixel(p.x, p.y, col)
