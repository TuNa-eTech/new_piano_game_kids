extends Node2D

func _ready() -> void:
	var menu := MainMenu.new()
	add_child(menu)
	menu.open_overlay()
	_wait_and_capture(menu)

func _wait_and_capture(menu: MainMenu) -> void:
	var anim_chars: AnimatedMenuCharacters = menu.get_node_or_null("AnimatedCharacters")
	if anim_chars != null:
		anim_chars._run_scenario_chase()

	for i in 40:
		await get_tree().process_frame

	var img := get_viewport().get_texture().get_image()
	var path := "/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/current_menu_render.png"
	if img != null:
		img.save_png(path)
		print("SCREENSHOT_SAVED_OK: ", path)
	else:
		printerr("IMG_IS_NULL")
	get_tree().quit(0)
