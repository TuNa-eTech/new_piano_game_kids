extends Node2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	SaveStore.reset_for_test()
	PauseOverlay.reset_pause_state()

	var main_scene: PackedScene = load("res://game/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)

	_run_test(main)

func _run_test(main) -> void:
	for i in 20:
		await get_tree().process_frame

	var router = main.router()
	router.open_chapter_end(0)

	# Chờ vào sâu trong buổi diễn hòa tấu (1.5s)
	await get_tree().create_timer(1.5, true).timeout
	for i in 20:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw

	var img := get_viewport().get_texture().get_image()
	var path := "/Users/anhtu/.gemini/antigravity/brain/48246db2-f5ca-47db-a8a9-79f414bcedf5/screen_grand_finale_rendered.png"
	var doc_path := "docs/grand_finale_rendered.png"
	if img != null:
		img.save_png(path)
		img.save_png(doc_path)
		print("GRAND_FINALE_SCREENSHOT_SAVED_OK: ", path)
	else:
		printerr("IMG_IS_NULL")
	get_tree().quit(0)
