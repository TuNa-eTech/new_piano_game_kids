@tool
extends SceneTree

func _init() -> void:
	print("=== RENDERING 2.5D FREE PLAY SCREEN PREVIEW (MÀN 03) ===")
	var canvas := Image.create(1280, 720, false, Image.FORMAT_RGBA8)
	canvas.fill(Color("#0B2D38")) # Nền rừng chập tối

	# 1. Nền Rừng Thần Tiên (Background Layers)
	var mock_src := Image.load_from_file("res://docs/mock-free-play.jpeg")
	if mock_src != null:
		mock_src.convert(Image.FORMAT_RGBA8)
		mock_src.resize(1280, 720, Image.INTERPOLATE_LANCZOS)
		# Sao chép nền tổng thể làm base canvas
		canvas.blit_rect(mock_src, Rect2i(0, 0, 1280, 720), Vector2i.ZERO)

	# 2. Phủ thêm quầng sáng và độ nét của các thành phần 2.5D đã trích xuất/tối ưu:
	
	# A. Cuốn sách và Bé Phù Thủy Kính Sao
	var wiz_img := Image.load_from_file("res://assets/art/wizard_star_rainbow_piano.png")
	if wiz_img != null:
		wiz_img.convert(Image.FORMAT_RGBA8)
		# Tọa độ tương đối trên canvas 1280x720: X ~ 360, Y ~ 235
		var wiz_dest := Vector2i(365, 235)
		_blend_image(canvas, wiz_img, wiz_dest)

	# B. Cây Đậu Thần Âm Nhạc trên trang phải
	var beanstalk_img := Image.load_from_file("res://assets/art/musical_beanstalk_stage.png")
	if beanstalk_img != null:
		beanstalk_img.convert(Image.FORMAT_RGBA8)
		var bs_dest := Vector2i(630, 120)
		_blend_image(canvas, beanstalk_img, bs_dest)

	# C. Khung Bóng Thoại ("Thỏa thích sáng tác nhạc nào! 🎵")
	var bubble_img := Image.load_from_file("res://assets/art/speech_bubble_freeplay.png")
	if bubble_img != null:
		bubble_img.convert(Image.FORMAT_RGBA8)
		var b_dest := Vector2i(360, 150)
		_blend_image(canvas, bubble_img, b_dest)

	# D. Bong Bóng Xà Phòng Ngũ Sắc Chứa Nốt Nhạc (VFX)
	var vfx_bubbles := Image.load_from_file("res://assets/art/vfx_bubbles_notes.png")
	if vfx_bubbles != null:
		vfx_bubbles.convert(Image.FORMAT_RGBA8)
		# Resize bong bóng cho vừa vặn bay từ cây đậu thần
		var bw: int = int(vfx_bubbles.get_width() * 0.42)
		var bh: int = int(vfx_bubbles.get_height() * 0.42)
		vfx_bubbles.resize(bw, bh, Image.INTERPOLATE_LANCZOS)
		var bub_dest := Vector2i(820, 120)
		_blend_image(canvas, vfx_bubbles, bub_dest)

	# E. Thanh Chọn 4 Nhạc Cụ Gỗ Trung Tâm (FreePlayTopBar)
	var top_bar := Image.load_from_file("res://assets/art/ui_bar_instruments_freeplay.png")
	if top_bar != null:
		top_bar.convert(Image.FORMAT_RGBA8)
		var tb_w: int = 570
		var tb_h: int = int(top_bar.get_height() * (float(tb_w) / float(top_bar.get_width())))
		top_bar.resize(tb_w, tb_h, Image.INTERPOLATE_LANCZOS)
		var tb_x := int((1280 - tb_w) * 0.5)
		var tb_dest := Vector2i(tb_x, 10)
		_blend_image(canvas, top_bar, tb_dest)
		# Vẽ vòng hào quang vàng kim chỉ báo slot 0 ("Đại Cầm")
		var aura_cx: int = tb_x + int(tb_w * 0.185)
		var aura_cy: int = 10 + int(tb_h * 0.44)
		_draw_aura_ring(canvas, aura_cx, aura_cy, 36, Color("#FFE666"), Color("#F2B82E", 0.55))

	# Lưu ảnh kết quả
	var out_docs := "res://docs/free_play_rendered.png"
	canvas.save_png(out_docs)
	print("[OK] Đã lưu render: ", out_docs)

	var brain_dir := "/Users/anhtu/.gemini/antigravity/brain/0373f0d1-4c62-416e-8235-931255c8f2bc/"
	var out_brain := brain_dir + "free_play_rendered.png"
	canvas.save_png(out_brain)
	print("[OK] Đã lưu bản sao vào brain artifact: ", out_brain)

	quit(0)


func _draw_aura_ring(canvas: Image, cx: int, cy: int, radius: int, ring_color: Color, glow_color: Color) -> void:
	for dy in range(-radius - 8, radius + 9):
		for dx in range(-radius - 8, radius + 9):
			var dist := sqrt(float(dx * dx + dy * dy))
			var px: int = cx + dx
			var py: int = cy + dy
			if px >= 0 and px < canvas.get_width() and py >= 0 and py < canvas.get_height():
				if absf(dist - float(radius)) <= 3.0:
					var orig: Color = canvas.get_pixel(px, py)
					canvas.set_pixel(px, py, orig.blend(ring_color))
				elif dist < float(radius + 7):
					var falloff := clampf((float(radius + 7) - dist) / 7.0, 0.0, 1.0)
					var glow := glow_color
					glow.a *= falloff * 0.5
					var orig: Color = canvas.get_pixel(px, py)
					canvas.set_pixel(px, py, orig.blend(glow))


func _blend_image(dst: Image, src: Image, pos: Vector2i) -> void:
	for sy in src.get_height():
		for sx in src.get_width():
			var dx: int = pos.x + sx
			var dy: int = pos.y + sy
			if dx >= 0 and dx < dst.get_width() and dy >= 0 and dy < dst.get_height():
				var sp: Color = src.get_pixel(sx, sy)
				if sp.a > 0.02:
					var dp: Color = dst.get_pixel(dx, dy)
					var final_col := dp.blend(sp)
					dst.set_pixel(dx, dy, final_col)
