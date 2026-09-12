@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/mock-free-play.jpeg")
	if img == null:
		print("Failed to load mock-free-play.jpeg")
		quit(1)
		return
	print("Size of mock-free-play: ", img.get_width(), "x", img.get_height())
	quit(0)
