@tool
extends SceneTree

func _init() -> void:
	print("--- KIỂM TRA TOÀN BỘ AVATAR VÀ BADGE ---")
	var voices := ["lion", "bear", "rabbit", "cat", "monkey", "elephant", "owl"]
	for v in voices:
		var p1 := "res://assets/art/avatar_%s_25d.png" % v
		var p2 := "res://assets/art/badge_%s.png" % v
		if FileAccess.file_exists(p1):
			var im := Image.load_from_file(p1)
			print("Avatar %s: %dx%d" % [v, im.get_width(), im.get_height()])
		if FileAccess.file_exists(p2):
			var im := Image.load_from_file(p2)
			print("Badge %s: %dx%d" % [v, im.get_width(), im.get_height()])
	quit(0)
