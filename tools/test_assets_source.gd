@tool
extends SceneTree

func _init() -> void:
	print("=== KIỂM TRA NGUỒN ASSET PIANO ===")
	
	# 1. Kiểm tra piano_console_source_clean_25d.jpg
	var src_clean := "res://assets/art/piano_console_source_clean_25d.jpg"
	if FileAccess.file_exists(src_clean):
		var img_clean := Image.load_from_file(src_clean)
		print("Clean source size: ", img_clean.get_width(), "x", img_clean.get_height())
		
	# 2. Kiểm tra docs/mock-game-play.jpeg
	var src_mock := "res://docs/mock-game-play.jpeg"
	if FileAccess.file_exists(src_mock):
		var img_mock := Image.load_from_file(src_mock)
		print("Mock source size: ", img_mock.get_width(), "x", img_mock.get_height())

	quit(0)
