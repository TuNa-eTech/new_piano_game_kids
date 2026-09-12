@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/mock-game-play.jpeg")
	img.convert(Image.FORMAT_RGBA8)
	print("Image dimensions: ", img.get_width(), "x", img.get_height())
	quit(0)
