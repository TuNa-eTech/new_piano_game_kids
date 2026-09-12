@tool
extends SceneTree

func _init() -> void:
	print("--- TÁCH BIỆT DẢI LỤA MA THUẬT SẠCH 100% ---")
	var src_path := "res://docs/mock-game-play.jpeg"
	var img := Image.load_from_file(src_path)
	img.convert(Image.FORMAT_RGBA8)
	
	# Vùng chứa dải lụa ma thuật uốn từ phím đàn lên ngọn cây đậu thần
	# X: 340..710 (w: 370), Y: 140..450 (h: 310)
	var ribbon_rect := Rect2i(340, 140, 370, 310)
	var ribbon_img := img.get_region(ribbon_rect)
	
	var rw := ribbon_img.get_width()
	var rh := ribbon_img.get_height()
	
	# Tạo ảnh ribbon trong suốt hoàn toàn, chỉ giữ lại vệt sáng của dải lụa và nốt nhạc
	for y in range(rh):
		var orig_y := ribbon_rect.position.y + y
		for x in range(rw):
			var orig_x := ribbon_rect.position.x + x
			var c := ribbon_img.get_pixel(x, y)
			
			# Độ sáng và độ bão hòa
			var max_c := maxf(c.r, maxf(c.g, c.b))
			var min_c := minf(c.r, minf(c.g, c.b))
			var lum := 0.299 * c.r + 0.587 * c.g + 0.114 * c.b
			
			# Điểm ảnh thuộc dải lụa ma thuật:
			# 1. Khóa Sol trắng phát sáng (lum rất cao > 0.88)
			# 2. Dải sóng phát sáng (cyan, pink, yellow, white)
			# 3. Các hạt sao lấp lánh
			var is_luminous := false
			var alpha := 0.0
			
			# Khóa Sol trắng và tia sáng chói
			if lum > 0.86 and (max_c - min_c) < 0.20:
				is_luminous = true
				alpha = clampf((lum - 0.82) / 0.15, 0.0, 1.0)
			# Dải sóng neon hồng/tím
			elif c.r > 0.70 and c.b > 0.75 and c.g < 0.70:
				is_luminous = true
				alpha = clampf((c.b - 0.60) / 0.35, 0.0, 1.0)
			# Dải sóng neon xanh lơ/cyan
			elif c.b > 0.75 and c.g > 0.70 and c.r < 0.65:
				is_luminous = true
				alpha = clampf((c.b - 0.55) / 0.35, 0.0, 1.0)
			# Dải sóng vàng chanh/xanh non phát sáng
			elif c.r > 0.80 and c.g > 0.80 and c.b < 0.60 and lum > 0.78:
				is_luminous = true
				alpha = clampf((lum - 0.72) / 0.20, 0.0, 1.0)
			# Nốt nhạc dạ quang nhiều màu
			elif lum > 0.75 and (c.b > 0.75 or (c.r > 0.80 and c.g > 0.70)):
				is_luminous = true
				alpha = clampf((lum - 0.70) / 0.25, 0.0, 1.0)
				
			# Nếu điểm ảnh ở vùng phím đàn (orig_y >= 390), loại bỏ triệt để màu phím đàn (màu gỗ nâu, màu ngà phẳng)
			if orig_y >= 390:
				var is_wood := c.r < 0.35 and c.g < 0.25 and c.b < 0.25 # phím đen / gỗ
				var is_ivory := c.r > 0.85 and c.g > 0.80 and c.b > 0.70 and (max_c - min_c) < 0.18 and lum < 0.88 # mặt phím ngà
				if is_wood or is_ivory:
					is_luminous = false
					alpha = 0.0
					
			if is_luminous:
				c.a = alpha
			else:
				c.a = 0.0
				
			ribbon_img.set_pixel(x, y, c)
			
	ribbon_img.save_png("res://assets/art/magic_musical_ribbon_trail_clean.png")
	print("[OK] Đã xuất magic_musical_ribbon_trail_clean.png")
	quit(0)
