@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/mock-game-play.jpeg")
	img.convert(Image.FORMAT_RGBA8)
	
	# Let's locate the red/coral badge for C:
	# Look around X: 190..230, Y: 490..540
	# Badge C has bright red/coral color: R > 0.85, G < 0.45, B < 0.45
	var min_x := 999
	var max_x := 0
	var min_y := 999
	var max_y := 0
	for y in range(480, 550):
		for x in range(180, 240):
			var c := img.get_pixel(x, y)
			if c.r > 0.85 and c.g < 0.45 and c.b < 0.45:
				min_x = mini(min_x, x)
				max_x = maxi(max_x, x)
				min_y = mini(min_y, y)
				max_y = maxi(max_y, y)
	print("Badge C bounds: X: ", min_x, "..", max_x, " Y: ", min_y, "..", max_y)
	if min_x < max_x:
		print("Badge C center: X=", (min_x + max_x) / 2, " Y=", (min_y + max_y) / 2)
	
	quit(0)
