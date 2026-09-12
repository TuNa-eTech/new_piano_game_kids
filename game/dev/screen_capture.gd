extends Node2D

func _ready() -> void:
	var gs = get_node_or_null("/root/GameState")
	if gs != null:
		gs.show_main_menu_on_launch = false
	var main_scene: PackedScene = load("res://game/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	_wait_and_capture()

func _wait_and_capture() -> void:
	for i in 40:
		await get_tree().process_frame

	var img := get_viewport().get_texture().get_image()
	var path := "/Users/anhtu/.gemini/antigravity/brain/176de66d-0b1d-4aae-8254-01361e4a3c84/gameplay_captured.png"
	img.save_png(path)
	print("SCREENSHOT_SAVED_OK: ", path)

	# Nhấn thử phím đen slot 1 (D#) để chụp ảnh trạng thái phát sáng ma thuật
	var kb: PianoKeyboard = find_child("PianoKeyboard", true, false)
	if kb != null:
		var pos := kb.get_black_key_global_position(1)
		var touch := InputEventScreenTouch.new()
		touch.index = 99
		touch.position = pos
		touch.pressed = true
		kb._unhandled_input(touch)

		for i in 10:
			await get_tree().process_frame

		var img_pressed := get_viewport().get_texture().get_image()
		var path_pressed := "/Users/anhtu/.gemini/antigravity/brain/176de66d-0b1d-4aae-8254-01361e4a3c84/gameplay_captured_pressed.png"
		img_pressed.save_png(path_pressed)
		print("SCREENSHOT_PRESSED_SAVED_OK: ", path_pressed)

	get_tree().quit()
