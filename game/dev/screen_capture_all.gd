extends Node2D

var _brain_dir := "/Users/anhtu/.gemini/antigravity-ide/brain/cc7e5692-27fc-4258-ac78-4bed5663171a"

func _ready() -> void:
	var main_scene: PackedScene = load("res://game/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	_run_captures(main)

func _capture(name: String) -> void:
	for i in 6:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var p := "%s/%s.png" % [_brain_dir, name]
	img.save_png(p)
	print("CAPTURED: ", p)

func _run_captures(main) -> void:
	# 1. Gameplay screen
	for i in 30:
		await get_tree().process_frame
	await _capture("screen_gameplay")

	# 2. Main menu
	var menu: MainMenu = MainMenu.new()
	add_child(menu)
	menu.open_overlay()
	await _capture("screen_main_menu")
	menu.close_overlay()
	menu.queue_free()

	# 3. Chapter map
	var map: ChapterMap = main.get_node("ChapterMap")
	map.open_map()
	await _capture("screen_chapter_map")

	# 4. Level select
	var level_sel: LevelSelect = LevelSelect.new()
	add_child(level_sel)
	level_sel.open_for_chapter(0)
	await _capture("screen_level_select")
	level_sel.close_overlay()
	level_sel.queue_free()
	map.close_map()

	# 5. Parental Gate
	var gate: ParentalGate = ParentalGate.new()
	add_child(gate)
	gate.open_overlay()
	await _capture("screen_parental_gate")
	gate.close_overlay()
	gate.queue_free()

	# 6. Parental Corner
	var corner: ParentalCorner = ParentalCorner.new()
	add_child(corner)
	corner.open_overlay()
	await _capture("screen_parental_corner")
	corner.close_overlay()
	corner.queue_free()

	# 7. Goodnight Screen
	var goodnight: GoodnightScreen = GoodnightScreen.new()
	add_child(goodnight)
	goodnight.open_overlay()
	await _capture("screen_goodnight")
	goodnight.close_overlay()
	goodnight.queue_free()

	# 8. Chest Reward
	var chest: ChestReward = ChestReward.new()
	add_child(chest)
	chest.show_reward(0)
	await _capture("screen_chest_reward")
	chest.close_overlay()
	chest.queue_free()

	# 9. Grand Finale
	var finale: ChapterEnd = main.get_node("ChapterEnd")
	finale.play_for_chapter(0)
	for i in 20:
		await get_tree().process_frame
	await _capture("screen_grand_finale")
	finale.close_overlay()

	print("ALL_SCREENS_CAPTURED_SUCCESSFULLY")
	get_tree().quit()
