@tool
extends SceneTree

func _init() -> void:
	var paths := [
		"/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/menu_accordion_toy_1789202499245.jpg",
		"/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/menu_violin_toy_1789202539557.jpg",
		"/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/menu_play_button_1789202559124.jpg"
	]
	for p in paths:
		var img := Image.new()
		var err := img.load(p)
		if err != OK:
			print("Error loading: ", p)
			continue
		print("--- Asset: ", p.get_file(), " size: ", img.get_size(), " format: ", img.get_format())
		print("  (0,0): ", img.get_pixel(0, 0))
		print("  (10,10): ", img.get_pixel(10, 10))
		print("  (w-1,0): ", img.get_pixel(img.get_width() - 1, 0))
		print("  (0,h-1): ", img.get_pixel(0, img.get_height() - 1))
		print("  (w-1,h-1): ", img.get_pixel(img.get_width() - 1, img.get_height() - 1))
	quit()
