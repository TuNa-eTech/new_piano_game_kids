@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/mock-game-play.jpeg")
	img.convert(Image.FORMAT_RGBA8)
	var bk_img := img.get_region(Rect2i(264, 404, 30, 54))
	bk_img.save_png("res://assets/art/test_black_key.png")
	quit(0)
