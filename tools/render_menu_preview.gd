@tool
extends SceneTree

func _init() -> void:
	print("=== RENDERING MENU PREVIEW WITH CHARACTERS ON MOSSY STAGE ===")
	var bg_path := "res://assets/menu/tex_menu_stage_clean.jpg"
	if not FileAccess.file_exists(bg_path):
		printerr("BG NOT FOUND")
		quit(1)
		return

	var bg := Image.load_from_file(bg_path)
	bg.resize(1280, 720, Image.INTERPOLATE_LANCZOS)
	bg.convert(Image.FORMAT_RGBA8)

	# 1. Vẽ bóng đổ 2.5D cho Phù thủy và Sư tử
	var wiz_x: int = 195
	var lion_x: int = 305
	var ground_y: int = 545

	_draw_shadow(bg, wiz_x, ground_y, 45, 14, 0.45)
	_draw_shadow(bg, lion_x, ground_y, 38, 12, 0.45)

	# 2. Blit Wizard Sprite
	var wiz_img := Image.load_from_file("res://assets/characters/wizard/anims/walk/walk_2.png")
	if wiz_img != null:
		wiz_img.convert(Image.FORMAT_RGBA8)
		var dest := Vector2i(wiz_x - int(wiz_img.get_width() * 0.5), ground_y - wiz_img.get_height() + 10)
		_blend_image(bg, wiz_img, dest)

	# 3. Blit Lion Sprite
	var lion_img := Image.load_from_file("res://assets/characters/lion/anims/jump/jump_2.png")
	if lion_img != null:
		lion_img.convert(Image.FORMAT_RGBA8)
		# Lion hopping slightly
		var lion_jump_y: int = 35
		var dest_l := Vector2i(lion_x - int(lion_img.get_width() * 0.5), ground_y - lion_img.get_height() - lion_jump_y + 10)
		_blend_image(bg, lion_img, dest_l)

	var out_path := "/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/current_menu_render.png"
	bg.save_png(out_path)
	print("RENDER_SAVED_OK: ", out_path)
	quit(0)


func _draw_shadow(canvas: Image, cx: int, cy: int, rx: int, ry: int, alpha: float) -> void:
	for dy in range(-ry, ry + 1):
		for dx in range(-rx, rx + 1):
			var nx: float = float(dx) / float(rx)
			var ny: float = float(dy) / float(ry)
			var dist_sq: float = nx * nx + ny * ny
			if dist_sq <= 1.0:
				var falloff: float = (1.0 - dist_sq) * alpha
				var px: int = cx + dx
				var py: int = cy + dy
				if px >= 0 and px < canvas.get_width() and py >= 0 and py < canvas.get_height():
					var orig: Color = canvas.get_pixel(px, py)
					var blended := orig.lerp(Color(0.05, 0.03, 0.01, 1.0), falloff)
					canvas.set_pixel(px, py, blended)


func _blend_image(dst: Image, src: Image, pos: Vector2i) -> void:
	for sy in src.get_height():
		for sx in src.get_width():
			var dx: int = pos.x + sx
			var dy: int = pos.y + sy
			if dx >= 0 and dx < dst.get_width() and dy >= 0 and dy < dst.get_height():
				var sp: Color = src.get_pixel(sx, sy)
				if sp.a > 0.01:
					var dp: Color = dst.get_pixel(dx, dy)
					var final_color := dp.blend(sp)
					dst.set_pixel(dx, dy, final_color)
