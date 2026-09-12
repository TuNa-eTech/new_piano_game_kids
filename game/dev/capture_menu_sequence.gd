extends Node2D

func _ready() -> void:
	var menu := MainMenu.new()
	add_child(menu)
	menu.open_overlay()
	_record_sequence(menu)

func _record_sequence(menu: MainMenu) -> void:
	var anim_chars: AnimatedMenuCharacters = menu.get_node_or_null("AnimatedCharacters")
	var base_path := "/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/"

	# 1. Chụp Frame 1: Vị trí xuất phát trên thảm rêu
	for i in 10:
		await get_tree().process_frame
	var img1 := get_viewport().get_texture().get_image()
	if img1 != null:
		img1.save_png(base_path + "menu_real_01_home.png")
		print("SAVED_01_OK")

	# 2. Bắt đầu Kịch bản Đuổi bắt trên thảm rêu
	if anim_chars != null:
		anim_chars._run_scenario_chase()

	# Chờ 0.5s để sư tử chạy đến mép rêu và phù thủy bật nhảy
	for i in 30:
		await get_tree().process_frame
	var img2 := get_viewport().get_texture().get_image()
	if img2 != null:
		img2.save_png(base_path + "menu_real_02_chase.png")
		print("SAVED_02_OK")

	# Chờ tiếp đến pha tung nốt nhạc và biểu cảm
	for i in 45:
		await get_tree().process_frame
	var img3 := get_viewport().get_texture().get_image()
	if img3 != null:
		img3.save_png(base_path + "menu_real_03_notes.png")
		print("SAVED_03_OK")

	get_tree().quit(0)
