@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/mock-game-play.jpeg")
	img.convert(Image.FORMAT_RGBA8)
	
	# Let's search each key for the animal's black nose/eyes around Y: 450..495
	var key_ranges := [
		[180, 260], # Lion
		[270, 350], # Bear
		[370, 450], # Rabbit
		[470, 550], # Cat
		[570, 650], # Monkey
		[660, 740], # Elephant
		[760, 840], # Owl
	]
	var names := ["Lion", "Bear", "Rabbit", "Cat", "Monkey", "Elephant", "Owl"]
	
	for i in range(7):
		var k_min: int = key_ranges[i][0]
		var k_max: int = key_ranges[i][1]
		var min_x := 999; var max_x := 0
		var min_y := 999; var max_y := 0
		for y in range(450, 495):
			for x in range(k_min, k_max):
				var c := img.get_pixel(x, y)
				# Animal features (dark nose/eyes/mouth lines):
				if c.r < 0.22 and c.g < 0.22 and c.b < 0.22:
					min_x = mini(min_x, x)
					max_x = maxi(max_x, x)
					min_y = mini(min_y, y)
					max_y = maxi(max_y, y)
		print("%s feature bounds: X: %d..%d (cx=%d), Y: %d..%d (cy=%d)" % [
			names[i], min_x, max_x, (min_x + max_x) / 2,
			min_y, max_y, (min_y + max_y) / 2
		])
	quit(0)
