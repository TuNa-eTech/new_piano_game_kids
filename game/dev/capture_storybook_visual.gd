extends Node2D

var _artifact_dir := "/Users/anhtu/.gemini/antigravity/brain/176de66d-0b1d-4aae-8254-01361e4a3c84"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.show_main_menu_on_launch = false # Khởi động thẳng vào màn hình sách tranh chính
	var main_scene: PackedScene = load("res://game/main.tscn")
	var main: Node = main_scene.instantiate()
	add_child(main)
	_run_captures(main)

func _capture(name: String) -> void:
	await get_tree().create_timer(0.30, true).timeout
	for i in 6:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	if img != null:
		var p1 := "%s/%s.png" % [_artifact_dir, name]
		var p2 := "res://docs/screenshots/%s.png" % name
		img.save_png(p1)
		img.save_png(ProjectSettings.globalize_path(p2))
		print("CAPTURED: ", p1)

func _run_captures(main: Node) -> void:
	var diorama: DioramaStage = main.get_node("UI/DioramaStage")

	# 1. Trang 1: Cá Mập Con (Baby Shark)
	diorama.load_page(0)
	for i in 25:
		await get_tree().process_frame
	await _capture("storybook_page_01_shark")

	# 2. Gõ nốt C4: Leo vung đũa phép, bé cá mập reo vui, lá nở hoa
	diorama.on_note_played(0)
	for i in 12:
		await get_tree().process_frame
	await _capture("storybook_page_01_note_struck")

	# 3. Trang 4: Ngôi Sao Nhỏ Lấp Lánh (Twinkle Twinkle - Owl)
	diorama.load_page(3)
	for i in 25:
		await get_tree().process_frame
	await _capture("storybook_page_04_owl")

	# 4. Trang 6: Nông Trại Bác MacDonald (Cow)
	diorama.load_page(5)
	for i in 25:
		await get_tree().process_frame
	await _capture("storybook_page_06_cow")

	# 5. Trang 2: Bánh Xe Buýt Lăn Tròn (Bear)
	diorama.load_page(1)
	for i in 25:
		await get_tree().process_frame
	await _capture("storybook_page_02_bear")

	# 6. Trang 5: Nếu Bạn Đang Thấy Vui (Rabbit)
	diorama.load_page(4)
	for i in 25:
		await get_tree().process_frame
	await _capture("storybook_page_05_rabbit")

	# 7. Trang 7: Bài Ca Bảng Chữ Cái (Lion)
	diorama.load_page(6)
	for i in 25:
		await get_tree().process_frame
	await _capture("storybook_page_07_lion")

	# 8. Trang 9: Năm Chú Khỉ Nhảy Trên Giường (Monkey)
	diorama.load_page(8)
	for i in 25:
		await get_tree().process_frame
	await _capture("storybook_page_09_monkey")

	# 9. Trang 10: Đầu, Vai, Đầu Gối, Ngón Chân (Elephant)
	diorama.load_page(9)
	for i in 25:
		await get_tree().process_frame
	await _capture("storybook_page_10_elephant")

	# 10. Mở Rương Kho Báu Ăn Mừng (Celebrate Completion)
	diorama.celebrate_completion()
	for i in 20:
		await get_tree().process_frame
	await _capture("storybook_chest_celebration")

	print("=== VISUAL CAPTURE COMPLETED ===")
	get_tree().quit(0)
