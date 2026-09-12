@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/mock-game-play.jpeg")
	img.convert(Image.FORMAT_RGBA8)
	
	# Key positions roughly:
	# C: 160..257, D: 257..354, E: 354..451, F: 451..548, G: 548..645, A: 645..742, B: 742..839
	var key_ranges := [
		[160, 256], [257, 353], [354, 450], [451, 547], [548, 644], [645, 741], [742, 838]
	]
	var notes := ["C", "D", "E", "F", "G", "A", "B"]
	
	# In each key, let's find the badge by finding the most saturated/colored blob around Y: 495..530
	for i in range(7):
		var k_min: int = key_ranges[i][0]
		var k_max: int = key_ranges[i][1]
		
		# Badge search
		var b_min_x := 999; var b_max_x := 0
		var b_min_y := 999; var b_max_y := 0
		for y in range(495, 532):
			for x in range(k_min, k_max):
				var c := img.get_pixel(x, y)
				var max_c := maxf(c.r, maxf(c.g, c.b))
				var min_c := minf(c.r, minf(c.g, c.b))
				var sat := max_c - min_c
				# The badge has high saturation, unlike the ivory key (sat < 0.20)
				# and unlike the letter 'white' inside it (which is in the middle of the badge)
				if sat > 0.35:
					b_min_x = mini(b_min_x, x)
					b_max_x = maxi(b_max_x, x)
					b_min_y = mini(b_min_y, y)
					b_max_y = maxi(b_max_y, y)
		print("Badge %s: X: %d..%d (cx=%d), Y: %d..%d (cy=%d)" % [
			notes[i], b_min_x, b_max_x, (b_min_x + b_max_x) / 2,
			b_min_y, b_max_y, (b_min_y + b_max_y) / 2
		])
	
	quit(0)
