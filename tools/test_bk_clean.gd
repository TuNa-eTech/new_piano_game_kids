@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/mock-game-play.jpeg")
	img.convert(Image.FORMAT_RGBA8)
	var bk_img := img.get_region(Rect2i(267, 406, 27, 49))
	
	for y in range(bk_img.get_height()):
		for x in range(bk_img.get_width()):
			var c := bk_img.get_pixel(x, y)
			if c.r > 0.60 and c.g > 0.50:
				c.a = 0.0
			elif y > 44:
				c.a = 0.0
			elif x < 7 and y < 15:
				c.a = 0.0
			elif x < 3 and y < 25:
				c.a = 0.0
			bk_img.set_pixel(x, y, c)
			
	bk_img.save_png("res://assets/art/piano_black_key_pure_25d.png")
	print("[OK] Đã xuất: piano_black_key_pure_25d.png")
	quit(0)
