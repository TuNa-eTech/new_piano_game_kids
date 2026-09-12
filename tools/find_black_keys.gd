@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/mock-game-play.jpeg")
	img.convert(Image.FORMAT_RGBA8)
	var min_y := 999; var max_y := 0
	for y in range(404, 480):
		var c := img.get_pixel(279, y)
		if c.r < 0.35 and c.g < 0.25 and c.b < 0.25:
			min_y = mini(min_y, y)
			max_y = maxi(max_y, y)
	print("Black key 0 at X=279: Y: ", min_y, "..", max_y, " (h=", max_y - min_y, ")")
	quit(0)
