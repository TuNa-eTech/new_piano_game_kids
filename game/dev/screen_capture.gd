extends Node2D

func _ready() -> void:
	var main_scene: PackedScene = load("res://game/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	_wait_and_capture()

func _wait_and_capture() -> void:
	for i in 60:
		await get_tree().process_frame

	var img := get_viewport().get_texture().get_image()
	var path := "/Users/anhtu/.gemini/antigravity-ide/brain/cc7e5692-27fc-4258-ac78-4bed5663171a/game_final_art_screen.png"
	img.save_png(path)
	print("SCREENSHOT_SAVED_OK: ", path)
	get_tree().quit()
