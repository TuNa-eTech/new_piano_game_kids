extends Node2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	SaveStore.reset_for_test()
	PauseOverlay.reset_pause_state()

	# Giả lập tiến trình: Bé đang ở bài 4 (page_index = 3), các bài 1-3 đã hoàn thành
	GameState.page_index = 3
	GameState.max_page_reached = 3

	var main_scene: PackedScene = load("res://game/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)

	_run_test(main)

func _run_test(main) -> void:
	for i in 20:
		await get_tree().process_frame

	var router = main.router()
	router.open_level_select(0)

	# Chờ hoạt cảnh mở màn 2.5D pop-up hoàn tất (0.8s)
	await get_tree().create_timer(0.8, true).timeout
	for i in 25:
		await get_tree().process_frame

	var img := get_viewport().get_texture().get_image()
	var doc_path := "docs/level_select_rendered.png"
	if img != null:
		img.save_png(doc_path)
		print("LEVEL_SELECT_SCREENSHOT_SAVED_OK: ", doc_path)
	else:
		printerr("IMG_IS_NULL")
	get_tree().quit(0)
