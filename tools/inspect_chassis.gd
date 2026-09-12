@tool
extends SceneTree

func _init() -> void:
	var path := "res://assets/art/piano_console_wood_chassis_25d.png"
	var img := Image.load_from_file(path)
	img.convert(Image.FORMAT_RGBA8)
	print("Chassis size: ", img.get_width(), "x", img.get_height())
	
	# Let's inspect where the keys start and end inside this image:
	# Local coordinates of the 7 keys:
	# Key 0..6
	# Check at Y = 120 (middle of the keys)
	var min_key_x := 999
	var max_key_x := 0
	for x in range(img.get_width()):
		var c := img.get_pixel(x, 120)
		# Ivory key: R > 0.85, G > 0.80, B > 0.70
		if c.r > 0.85 and c.g > 0.80 and c.b > 0.68:
			min_key_x = mini(min_key_x, x)
			max_key_x = maxi(max_key_x, x)
	print("Keys horizontal span at Y=120: X: ", min_key_x, "..", max_key_x, " (width: ", max_key_x - min_key_x, ")")
	
	# Check vertical span of the keys:
	var min_key_y := 999
	var max_key_y := 0
	for y in range(img.get_height()):
		var c := img.get_pixel(250, y) # middle of key D
		if c.r > 0.85 and c.g > 0.80 and c.b > 0.68:
			min_key_y = mini(min_key_y, y)
			max_key_y = maxi(max_key_y, y)
	print("Key vertical span at X=250: Y: ", min_key_y, "..", max_key_y, " (height: ", max_key_y - min_key_y, ")")

	quit(0)
