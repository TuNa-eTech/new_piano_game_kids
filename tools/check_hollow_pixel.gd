@tool
extends SceneTree

func _init() -> void:
	var path := "res://assets/art/piano_chassis_frame_hollow_25d.png"
	var img := Image.load_from_file(path)
	img.convert(Image.FORMAT_RGBA8)
	var c := img.get_pixel(img.get_width() / 2, img.get_height() / 2)
	print("Center pixel of piano_chassis_frame_hollow_25d: ", c, " alpha=", c.a)
	quit(0)
