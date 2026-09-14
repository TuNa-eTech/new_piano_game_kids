extends Node2D

func _ready() -> void:
	SaveStore.reset_for_test()
	var gs = get_node_or_null("/root/GameState")
	if gs != null:
		gs.show_main_menu_on_launch = false
		gs.set_page(0)
	var main_scene: PackedScene = load("res://game/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	_wait_and_capture()

func _wait_and_capture() -> void:
	for i in 40:
		await get_tree().process_frame

	var img := get_viewport().get_texture().get_image()
	var path := "/Users/anhtu/.gemini/antigravity/brain/11cd0d6f-5ca3-487b-b85e-a446adcf4811/gameplay_captured.png"
	img.save_png(path)
	img.save_png("res://docs/screenshots/gameplay_revamped.png")
	print("SCREENSHOT_SAVED_OK: ", path)

	var cr: CallResponse = find_child("CallResponse", true, false)
	if cr != null:
		cr.set_process(false)

	var leo: WizardLeo = find_child("WizardLeo", true, false)
	if leo != null:
		# 1. Chụp biểu cảm nháy mắt WINK
		leo.set_expression(WizardLeo.FaceExpr.WINK, 0.0)
		for i in 6:
			await get_tree().process_frame
		var img_wink := get_viewport().get_texture().get_image()
		var path_wink := "/Users/anhtu/.gemini/antigravity/brain/11cd0d6f-5ca3-487b-b85e-a446adcf4811/gameplay_captured_wink.png"
		img_wink.save_png(path_wink)
		print("SCREENSHOT_WINK_SAVED_OK: ", path_wink)

		# 2. Chụp biểu cảm cười tít mắt HAPPY
		leo.set_expression(WizardLeo.FaceExpr.HAPPY, 0.0)
		for i in 6:
			await get_tree().process_frame
		var img_happy := get_viewport().get_texture().get_image()
		var path_happy := "/Users/anhtu/.gemini/antigravity/brain/11cd0d6f-5ca3-487b-b85e-a446adcf4811/gameplay_captured_happy.png"
		img_happy.save_png(path_happy)
		print("SCREENSHOT_HAPPY_SAVED_OK: ", path_happy)

		# 3. Chụp biểu cảm vung tay mắt sao STAR_EYES (Flourish)
		leo.set_expression(WizardLeo.FaceExpr.STAR_EYES, 0.0)
		leo.play_flourish()
		for i in 12:
			await get_tree().process_frame
		var img_star := get_viewport().get_texture().get_image()
		var path_star := "/Users/anhtu/.gemini/antigravity/brain/11cd0d6f-5ca3-487b-b85e-a446adcf4811/gameplay_captured_star_eyes.png"
		img_star.save_png(path_star)
		print("SCREENSHOT_STAR_EYES_SAVED_OK: ", path_star)

	# 4. Chụp kiểm tra chế độ Chơi Tự Do
	GameState.free_play = true
	for i in 15:
		await get_tree().process_frame
	var img_free := get_viewport().get_texture().get_image()
	if img_free != null:
		img_free.save_png("res://docs/screenshots/free_play_revamped.png")
		print("SCREENSHOT_FREE_PLAY_SAVED_OK")

	get_tree().quit()
