@tool
extends SceneTree
func _init() -> void:
	var img := Image.load_from_file("/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/menu_stage_no_chars_1789139846517.jpg")
	if img == null:
		print("Failed to load")
		quit()
		return
	print("Size: ", img.get_size())
	# Bounding box of original Play button:
	# In 1376x768:
	var play_rect := Rect2i(930, 350, 245, 255)
	var play_crop := img.get_region(play_rect)
	play_crop.save_png("scratch/orig_play_crop.png")
	
	# Bounding box of original Accordion & Violin:
	var inst_rect := Rect2i(580, 500, 320, 160)
	var inst_crop := img.get_region(inst_rect)
	inst_crop.save_png("scratch/orig_inst_crop.png")
	print("Saved crops to scratch/")
	quit()
