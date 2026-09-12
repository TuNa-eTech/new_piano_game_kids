@tool
extends SceneTree

func _init() -> void:
	print("=== RENDERING 2.5D CHEST REWARD SCREEN PREVIEW (MÀN 06) ===")
	var canvas := Image.create(1280, 720, false, Image.FORMAT_RGBA8)
	canvas.fill(Color("#081C14"))

	# 1. Nền Sân Khấu Sách Nổi & Rừng Cổ Tích
	var mock_src := Image.load_from_file("res://docs/mock-chest-reward.jpeg")
	if mock_src != null:
		mock_src.convert(Image.FORMAT_RGBA8)
		mock_src.resize(1280, 720, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect(mock_src, Rect2i(0, 0, 1280, 720), Vector2i.ZERO)

	# 2. Rương Báu Thần Bung Nắp (spr_chest_open_gold.png)
	# Tọa độ tương đối trên canvas 1280x720: X ~ 490, Y ~ 335, kích thước ~ 340x320
	var chest_img := Image.load_from_file("res://assets/art/spr_chest_open_gold.png")
	if chest_img != null:
		chest_img.convert(Image.FORMAT_RGBA8)
		var cw: int = 345
		var ch: int = int(chest_img.get_height() * (float(cw) / float(chest_img.get_width())))
		chest_img.resize(cw, ch, Image.INTERPOLATE_LANCZOS)
		_blend_image(canvas, chest_img, Vector2i(495, 335))

	# 3. Chùm Tia Sáng Mặt Trời (Sunburst God Rays) phía sau Huy Hiệu
	_draw_sunburst_rays(canvas, 640, 240, 170, Color(1.0, 0.88, 0.40, 0.35))

	# 4. Huy Hiệu Thú 3D Sư Tử Nhạc Sĩ (spr_badge_lion_maestro_3d.png)
	# Tọa độ tương đối trên canvas 1280x720: X ~ 525, Y ~ 110, kích thước ~ 230x230
	var badge_img := Image.load_from_file("res://assets/art/spr_badge_lion_maestro_3d.png")
	if badge_img != null:
		badge_img.convert(Image.FORMAT_RGBA8)
		var bw: int = 240
		var bh: int = int(badge_img.get_height() * (float(bw) / float(badge_img.get_width())))
		badge_img.resize(bw, bh, Image.INTERPOLATE_LANCZOS)
		_blend_image(canvas, badge_img, Vector2i(520, 110))

	# 5. Bé Phù Thủy Nhỏ Vỗ Tay (spr_wizard_boy_clapping.png)
	# Tọa độ tương đối: X ~ 265, Y ~ 205, kích thước ~ 205x335
	var wiz_img := Image.load_from_file("res://assets/art/spr_wizard_boy_clapping.png")
	if wiz_img != null:
		wiz_img.convert(Image.FORMAT_RGBA8)
		var ww: int = 205
		var wh: int = int(wiz_img.get_height() * (float(ww) / float(wiz_img.get_width())))
		wiz_img.resize(ww, wh, Image.INTERPOLATE_LANCZOS)
		_blend_image(canvas, wiz_img, Vector2i(265, 205))

	# 6. Khung Tranh Gỗ Vinh Danh Tiến Trình (spr_frame_progress_wood.png)
	# Tọa độ tương đối: X ~ 100, Y ~ 140, kích thước ~ 195x255
	var frame_img := Image.load_from_file("res://assets/art/spr_frame_progress_wood.png")
	if frame_img != null:
		frame_img.convert(Image.FORMAT_RGBA8)
		var fw: int = 195
		var fh: int = int(frame_img.get_height() * (float(fw) / float(frame_img.get_width())))
		frame_img.resize(fw, fh, Image.INTERPOLATE_LANCZOS)
		_blend_image(canvas, frame_img, Vector2i(100, 140))

	# 7. Nút Gỗ 'NHẬN THƯỞNG 🌿' (ui_btn_claim_wood.png)
	# Tọa độ tương đối: X ~ 468, Y ~ 485, kích thước ~ 355x128
	var btn_img := Image.load_from_file("res://assets/ui/ui_btn_claim_wood.png")
	if btn_img != null:
		btn_img.convert(Image.FORMAT_RGBA8)
		var bw: int = 355
		var bh: int = int(btn_img.get_height() * (float(bw) / float(btn_img.get_width())))
		btn_img.resize(bw, bh, Image.INTERPOLATE_LANCZOS)
		_blend_image(canvas, btn_img, Vector2i(468, 485))

	# 8. Suối Hạt Sao Vàng & Pháo Hoa Giấy Confetti
	_draw_starlight_sparks(canvas)

	# Lưu ảnh kết quả
	var out_docs := "res://docs/chest_reward_rendered.png"
	canvas.save_png(out_docs)
	print("[OK] Đã lưu preview kết quả vào: ", out_docs)

	var brain_dir := "/Users/anhtu/.gemini/antigravity/brain/1171fe0b-ebf8-489d-bfa3-fb9dbef92b31/"
	var out_brain := brain_dir + "chest_reward_rendered.png"
	canvas.save_png(out_brain)
	print("[OK] Đã lưu bản sao vào brain artifact: ", out_brain)

	quit(0)


func _draw_sunburst_rays(canvas: Image, cx: int, cy: int, radius: int, ray_color: Color) -> void:
	var ray_count := 18
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			var dist := sqrt(float(dx * dx + dy * dy))
			if dist > float(radius):
				continue
			var px := cx + dx
			var py := cy + dy
			if px < 0 or px >= canvas.get_width() or py < 0 or py >= canvas.get_height():
				continue
			var angle := atan2(float(dy), float(dx))
			var rays := sin(angle * float(ray_count)) * 0.5 + 0.5
			var fade := clampf(1.0 - (dist / float(radius)), 0.0, 1.0)
			var col := ray_color
			col.a *= rays * fade * 0.45
			var orig := canvas.get_pixel(px, py)
			canvas.set_pixel(px, py, orig.blend(col))


func _draw_starlight_sparks(canvas: Image, seed_val: int = 42) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	var colors := [
		Color(1.0, 0.95, 0.65), # Kem
		Color(1.0, 0.85, 0.25), # Vàng
		Color(0.5, 0.95, 0.90), # Cyan
		Color(1.0, 0.60, 0.80)  # Hồng
	]
	# Vẽ 45 ngôi sao lấp lánh xung quanh miệng rương và huy hiệu
	for i in range(45):
		var sx := rng.randi_range(470, 810)
		var sy := rng.randi_range(160, 480)
		var size := rng.randi_range(3, 7)
		var col: Color = colors[rng.randi() % colors.size()]
		_draw_star_cross(canvas, sx, sy, size, col)


func _draw_star_cross(canvas: Image, cx: int, cy: int, size: int, col: Color) -> void:
	for d in range(-size, size + 1):
		var px := cx + d
		var py := cy
		if px >= 0 and px < canvas.get_width() and py >= 0 and py < canvas.get_height():
			var a := 1.0 - absf(float(d)) / float(size + 1)
			var c := col
			c.a *= a
			canvas.set_pixel(px, py, canvas.get_pixel(px, py).blend(c))
		px = cx
		py = cy + d
		if px >= 0 and px < canvas.get_width() and py >= 0 and py < canvas.get_height():
			var a := 1.0 - absf(float(d)) / float(size + 1)
			var c := col
			c.a *= a
			canvas.set_pixel(px, py, canvas.get_pixel(px, py).blend(c))


func _blend_image(dst: Image, src: Image, pos: Vector2i) -> void:
	for sy in src.get_height():
		for sx in src.get_width():
			var dx := pos.x + sx
			var dy := pos.y + sy
			if dx >= 0 and dx < dst.get_width() and dy >= 0 and dy < dst.get_height():
				var src_col := src.get_pixel(sx, sy)
				if src_col.a > 0.001:
					var dst_col := dst.get_pixel(dx, dy)
					dst.set_pixel(dx, dy, dst_col.blend(src_col))
