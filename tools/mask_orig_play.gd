@tool
extends SceneTree
func _init() -> void:
	var img := Image.load_from_file("scratch/orig_play_crop.png")
	if img == null:
		quit()
		return
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	print("Play crop size: ", w, "x", h)
	
	# The disc center is roughly (w/2, h/2 - 5)
	# Let's inspect the gold rim
	# The gold rim is roughly an ellipse: center (122, 122), rx: 104, ry: 108
	# Wait! The treble clef extends slightly above and below the disc!
	# Top loop of clef: y reaches ~12!
	# Bottom curl: y reaches ~230!
	# Outer gold ring: x from ~18 to ~226, y from ~25 to ~220
