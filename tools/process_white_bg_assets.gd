@tool
extends SceneTree

func remove_white_bg(src_path: String, dst_path: String, white_thresh: float = 0.90, edge_thresh: float = 0.80) -> void:
	var img := Image.new()
	var err := img.load(src_path)
	if err != OK:
		printerr("Failed to load: ", src_path)
		return
	
	img.convert(Image.FORMAT_RGBA8)
	var w: int = img.get_width()
	var h: int = img.get_height()
	
	var is_bg: Array[bool] = []
	is_bg.resize(w * h)
	is_bg.fill(false)
	
	var visited: Array[bool] = []
	visited.resize(w * h)
	visited.fill(false)
	
	var q: Array[Vector2i] = []
	
	var is_white := func(c: Color) -> bool:
		var min_c := minf(c.r, minf(c.g, c.b))
		var max_diff := maxf(absf(c.r - c.g), maxf(absf(c.g - c.b), absf(c.r - c.b)))
		return min_c >= white_thresh and max_diff < 0.12
	
	# Seed border pixels
	for x in range(w):
		for y in [0, h - 1]:
			var idx: int = y * w + x
			if not visited[idx]:
				visited[idx] = true
				var c := img.get_pixel(x, y)
				if is_white.call(c):
					is_bg[idx] = true
					q.append(Vector2i(x, y))
	for y in range(h):
		for x in [0, w - 1]:
			var idx: int = y * w + x
			if not visited[idx]:
				visited[idx] = true
				var c := img.get_pixel(x, y)
				if is_white.call(c):
					is_bg[idx] = true
					q.append(Vector2i(x, y))
					
	# Flood fill BFS
	var head: int = 0
	while head < q.size():
		var p: Vector2i = q[head]
		head += 1
		for offset: Vector2i in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var nx: int = p.x + offset.x
			var ny: int = p.y + offset.y
			if nx >= 0 and nx < w and ny >= 0 and ny < h:
				var nidx: int = ny * w + nx
				if not visited[nidx]:
					visited[nidx] = true
					var c := img.get_pixel(nx, ny)
					if is_white.call(c):
						is_bg[nidx] = true
						q.append(Vector2i(nx, ny))
						
	print("Asset: ", src_path.get_file(), " -> bg pixels found: ", head, " (", snappedf(float(head)/(w*h)*100.0, 0.1), "%)")
	
	# Mark bg transparent, and feather boundary pixels
	var min_x: int = w
	var max_x: int = 0
	var min_y: int = h
	var max_y: int = 0
	
	for y in range(h):
		for x in range(w):
			var idx: int = y * w + x
			if is_bg[idx]:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
			else:
				# Check if neighbor is bg
				var touches_bg := false
				for offset: Vector2i in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1), Vector2i(1,1), Vector2i(-1,-1), Vector2i(1,-1), Vector2i(-1,1)]:
					var nx: int = x + offset.x
					var ny: int = y + offset.y
					if nx < 0 or nx >= w or ny < 0 or ny >= h or is_bg[ny * w + nx]:
						touches_bg = true
						break
				var c := img.get_pixel(x, y)
				if touches_bg:
					var min_c := minf(c.r, minf(c.g, c.b))
					if min_c > edge_thresh:
						var bg_fraction := clampf((min_c - edge_thresh) / (1.0 - edge_thresh), 0.0, 1.0)
						var alpha := 1.0 - bg_fraction
						if alpha < 0.02:
							img.set_pixel(x, y, Color(0,0,0,0))
							continue
						var inv_a := 1.0 / alpha
						c.r = clampf((c.r - bg_fraction) * inv_a, 0.0, 1.0)
						c.g = clampf((c.g - bg_fraction) * inv_a, 0.0, 1.0)
						c.b = clampf((c.b - bg_fraction) * inv_a, 0.0, 1.0)
						c.a = alpha
						img.set_pixel(x, y, c)
				
				# Track bounds
				if c.a > 0.05:
					min_x = mini(min_x, x)
					max_x = maxi(max_x, x)
					min_y = mini(min_y, y)
					max_y = maxi(max_y, y)
					
	# Add margin
	var pad := 4
	min_x = maxi(0, min_x - pad)
	max_x = mini(w - 1, max_x + pad)
	min_y = maxi(0, min_y - pad)
	max_y = mini(h - 1, max_y + pad)
	
	var crop_rect := Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
	var cropped := img.get_region(crop_rect)
	print("Cropped bounds: ", crop_rect, " final size: ", cropped.get_size())
	
	var save_err := cropped.save_png(dst_path)
	if save_err == OK:
		print("Successfully saved: ", dst_path)
	else:
		printerr("Failed to save: ", dst_path, " error: ", save_err)

func _init() -> void:
	remove_white_bg(
		"/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/menu_accordion_toy_1789202499245.jpg",
		"assets/menu/tex_accordion.png",
		0.92, 0.82
	)
	remove_white_bg(
		"/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/menu_violin_toy_1789202539557.jpg",
		"assets/menu/tex_violin.png",
		0.92, 0.82
	)
	remove_white_bg(
		"/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/menu_play_button_1789202559124.jpg",
		"assets/menu/tex_play_disc.png",
		0.92, 0.82
	)
	quit()
