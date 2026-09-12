extends Node2D

var _brain_dir := "/Users/anhtu/.gemini/antigravity-ide/brain/49773952-7526-4797-9d56-cef7847b9ac1"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	SaveStore.reset_for_test()
	PauseOverlay.reset_pause_state()
	var main_scene: PackedScene = load("res://game/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	_run_captures(main)

func _capture(name: String) -> void:
	await get_tree().create_timer(0.35, true).timeout
	for i in 6:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var p := "%s/%s.png" % [_brain_dir, name]
	img.save_png(p)
	print("CAPTURED: ", p)

func _run_captures(main) -> void:
	# 1. Gameplay screen (Stage 0 Sprout)
	for i in 30:
		await get_tree().process_frame
	await _capture("screen_gameplay")

	# 1b. Gameplay screen (Stage 7 Full Magic Tree with bloomed leaves)
	var tree: MagicTree = main.get_node("UI/MagicTree")
	if tree != null:
		for n in Notes.count():
			tree.bloom(n, Notes.count())
		for i in 10:
			await get_tree().process_frame
		await _capture("screen_gameplay_mature")
		tree.reset_page()

	# 1c. Page flip transition in progress (mid-curl)
	var diorama: DioramaStage = main.get_node("UI/DioramaStage")
	if diorama != null:
		diorama.flip_page(1.2)
		for i in 25:
			await get_tree().process_frame
		await _capture("screen_page_flip_mid")
		for i in 50:
			await get_tree().process_frame

	# 1d. Instrument Switcher dock expanded
	var switcher: InstrumentSwitcher = main.get_node_or_null("HUD/InstrumentSwitcher")
	if switcher != null:
		switcher.open_dock()
		for i in 20:
			await get_tree().process_frame
		await _capture("screen_inst_dock_expanded")
		switcher.select_mode(Notes.InstrumentMode.KALIMBA)
		switcher.close_dock()
		for i in 15:
			await get_tree().process_frame
		await _capture("screen_gameplay_kalimba")
		switcher.select_mode(Notes.InstrumentMode.AUTO)

	# 1e. Interactive Diorama: Wizard Tap & Magic Sparkles
	if diorama != null:
		diorama.interact_wizard()
		for i in 6:
			await get_tree().process_frame
		await _capture("screen_diorama_wizard_tap")
		for i in 15:
			await get_tree().process_frame

	# 1f. Interactive Diorama: Crystal & Chest Glow
	if diorama != null:
		diorama.interact_crystal_cyan()
		diorama.interact_crystal_magenta()
		diorama.interact_chest()
		for i in 6:
			await get_tree().process_frame
		await _capture("screen_diorama_crystals_glow")
		for i in 15:
			await get_tree().process_frame

	# 1g. Interactive Star Jar Wiggle & Flash
	var star_jar = main.get_node_or_null("HUD/StarJar")
	if star_jar != null:
		star_jar.wiggle()
		for i in 6:
			await get_tree().process_frame
		await _capture("screen_diorama_star_jar_shake")
		for i in 15:
			await get_tree().process_frame

	# 2. Main menu via ScreenRouter
	var router = main.router()
	router.open_main_menu()
	await _capture("screen_main_menu")
	router.close_active_overlay()

	# 3. Chapter map via ScreenRouter (with Header Bar: Bìa Sách + Phụ Huynh)
	router.open_chapter_map()
	await _capture("screen_chapter_map")

	# 4. Level select via ScreenRouter
	router.open_level_select(0)
	await _capture("screen_level_select")
	router.close_active_overlay()

	# 5. Parental Gate via ScreenRouter
	router.open_parental_gate()
	await _capture("screen_parental_gate")
	router.close_active_overlay()

	# 6. Parental Corner via ScreenRouter
	router.open_parental_corner()
	await _capture("screen_parental_corner")
	router.close_active_overlay()

	# 7. Goodnight Screen via ScreenRouter
	router.open_goodnight()
	await _capture("screen_goodnight")
	router.close_active_overlay()

	# 8. Chest Reward via ScreenRouter
	router.open_chest_reward(0)
	await _capture("screen_chest_reward")
	router.close_active_overlay()

	# 9. Grand Finale via ScreenRouter
	router.open_chapter_end(0)
	for i in 20:
		await get_tree().process_frame
	await _capture("screen_grand_finale")
	router.close_active_overlay()

	print("ALL_SCREENS_CAPTURED_SUCCESSFULLY")
	get_tree().quit()
