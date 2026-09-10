extends Node2D

const ScreenRouter = preload("res://game/ui/screen_router.gd")

var _fails: int = 0


func _ready() -> void:
	print("=== Kiểm tra Hệ Thống Điều Phối Luồng Điều Hướng Toàn Diện ===\n")
	SaveStore.reset_for_test()
	PauseOverlay.reset_pause_state()

	var main: Node = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	for i in 6:
		await get_tree().process_frame

	var router: ScreenRouter = main.router()
	_check("ScreenRouter tồn tại trong Main", router != null)

	await _test_main_menu_flow(router)
	await _test_chapter_map_navigation(router)
	await _test_level_select_flow(router)
	await _test_parental_gate_and_corner(router)
	await _test_goodnight_screen_flow(router)
	await _test_chest_reward_flow(router, main)

	print("\n=== %s ===" % ("ĐẠT TOÀN BỘ" if _fails == 0 else "TRƯỢT (%d lỗi)" % _fails))
	main.queue_free()
	get_tree().quit()


func _check(label: String, ok: bool, detail: String = "") -> void:
	if not ok:
		_fails += 1
	print("  [%s] %s%s" % ["OK " if ok else "SAI", label, ("  — " + detail) if detail else ""])


func _test_main_menu_flow(router: ScreenRouter) -> void:
	print("① Kiểm tra luồng Menu Bìa Sách (MainMenu)")
	var menu: MainMenu = router.get_main_menu()
	var map: ChapterMap = router.get_chapter_map()

	router.open_main_menu()
	await get_tree().process_frame
	_check("MainMenu mở thành công", menu.is_open())
	_check("Ván chơi bị tạm dừng khi Menu mở", get_tree().paused)

	# Bấm Chơi Ngay
	menu._on_play_pressed()
	await get_tree().process_frame
	_check("Bấm Chơi Ngay đóng MainMenu", not menu.is_open())
	_check("Ván chơi tiếp tục chạy", not get_tree().paused)

	# Mở lại Menu và bấm Bản Đồ
	router.open_main_menu()
	await get_tree().process_frame
	menu.levels_pressed.emit()
	await get_tree().process_frame
	_check("Bấm Bản Đồ đóng MainMenu", not menu.is_open())
	_check("Bản đồ ChapterMap mở ra", map.is_open())

	map.close_map()
	await get_tree().process_frame
	_check("Đóng Bản đồ trả về game", not map.is_open())


func _test_chapter_map_navigation(router: ScreenRouter) -> void:
	print("\n② Kiểm tra nút điều hướng trên Bản Đồ Chương")
	var map: ChapterMap = router.get_chapter_map()
	var menu: MainMenu = router.get_main_menu()
	var gate: ParentalGate = router.get_parental_gate()

	router.open_chapter_map()
	await get_tree().process_frame
	_check("ChapterMap mở", map.is_open())

	# Bấm nút Bìa Sách trên Bản đồ
	map.main_menu_requested.emit()
	await get_tree().process_frame
	_check("Nút Bìa Sách mở MainMenu", menu.is_open())
	menu.close_overlay()
	await get_tree().process_frame

	# Mở lại Bản đồ và bấm nút Phụ Huynh
	router.open_chapter_map()
	await get_tree().process_frame
	map.parent_gate_requested.emit()
	await get_tree().process_frame
	_check("Nút Phụ Huynh mở Cổng bảo vệ ParentalGate", gate.is_open())
	gate.close_overlay()
	map.close_map()
	await get_tree().process_frame


func _test_level_select_flow(router: ScreenRouter) -> void:
	print("\n③ Kiểm tra luồng Chọn Màn Chơi (LevelSelect)")
	var map: ChapterMap = router.get_chapter_map()
	var level_sel: LevelSelect = router.get_level_select()

	router.open_chapter_map()
	await get_tree().process_frame

	# Chọn Chương 1 trên bản đồ -> LevelSelect mở
	map._on_card_pressed(0)
	await get_tree().process_frame
	_check("Chọn chương 1 mở LevelSelect", level_sel.is_open())

	# Bấm nút Quay lại trên LevelSelect -> Trở về ChapterMap
	level_sel._on_back_pressed()
	await get_tree().process_frame
	_check("Nút Quay lại đóng LevelSelect", not level_sel.is_open())
	_check("Trở lại ChapterMap", map.is_open())

	# Mở lại LevelSelect và chọn Bài 3 (trang 2)
	map._on_card_pressed(0)
	await get_tree().process_frame
	level_sel._on_level_btn_pressed(2)
	await get_tree().process_frame
	_check("Chọn bài 3 chuyển GameState sang trang 2", GameState.page_index == 2)
	_check("LevelSelect đã đóng", not level_sel.is_open())
	_check("ChapterMap đã đóng", not map.is_open())
	_check("Game tiếp tục chạy ở trang mới", not get_tree().paused)


func _test_parental_gate_and_corner(router: ScreenRouter) -> void:
	print("\n④ Kiểm tra Cổng Phụ Huynh & Góc Cài Đặt (ParentalGate -> Corner)")
	var gate: ParentalGate = router.get_parental_gate()
	var corner: ParentalCorner = router.get_parental_corner()

	router.open_parental_settings()
	await get_tree().process_frame
	_check("ParentalGate mở", gate.is_open())

	# Mô phỏng giải câu đố 3 quả dâu đỏ
	gate._tapped_strawberries = 3
	gate.close_overlay()
	gate.gate_unlocked.emit()
	await get_tree().process_frame

	_check("Giải đúng câu đố đóng ParentalGate", not gate.is_open())
	_check("Mở Góc Phụ Huynh ParentalCorner", corner.is_open())

	# Thử đặt hẹn giờ ngủ 15 phút
	corner._on_timer_selected(15, Button.new())
	_check("GameState nhận hẹn giờ 15 phút", GameState.bedtime_minutes == 15)
	_check("Bộ đếm hẹn giờ kích hoạt", GameState.bedtime_active)
	_check("Thời gian còn lại > 0", GameState.bedtime_remaining > 800.0)

	corner.close_overlay()
	await get_tree().process_frame
	_check("Đóng ParentalCorner", not corner.is_open())


func _test_goodnight_screen_flow(router: ScreenRouter) -> void:
	print("\n⑤ Kiểm tra Màn Chúc Bé Ngủ Ngon (GoodnightScreen)")
	var goodnight: GoodnightScreen = router.get_goodnight_screen()
	var gate: ParentalGate = router.get_parental_gate()

	# Kích hoạt sự kiện hết giờ
	GameState.bedtime_expired.emit()
	await get_tree().process_frame
	_check("GoodnightScreen tự động mở khi hết giờ", goodnight.is_open())
	_check("Ván chơi bên dưới bị tạm dừng", get_tree().paused)

	# Bấm nút Đánh Thức Khu Rừng -> Mở ParentalGate
	goodnight._on_unlock_pressed()
	await get_tree().process_frame
	_check("Mở ParentalGate để người lớn mở khóa", gate.is_open())

	# Người lớn giải đúng câu đố dâu tây
	gate._tapped_strawberries = 3
	gate.close_overlay()
	gate.gate_unlocked.emit()
	await get_tree().process_frame

	_check("Mở khóa thành công đóng GoodnightScreen", not goodnight.is_open())
	_check("Reset hẹn giờ ngủ về 0", GameState.bedtime_minutes == 0)
	_check("Game tiếp tục chơi bình thường", not get_tree().paused)


func _test_chest_reward_flow(router: ScreenRouter, main: Node) -> void:
	print("\n⑥ Kiểm tra Mở Rương Báu Nhận Huy Hiệu (ChestReward)")
	var chest: ChestReward = router.get_chest_reward()

	router.open_chest_reward(0)
	await get_tree().process_frame
	_check("ChestReward mở ra", chest.is_open())

	chest._on_claim_pressed()
	await get_tree().process_frame
	_check("Bấm Nhận Thưởng đóng ChestReward", not chest.is_open())

	# Kiểm tra chạm rương báu trong Diorama
	var diorama: DioramaStage = main.get_node("UI/DioramaStage")
	diorama.interact_chest()
	await get_tree().process_frame
	_check("Chạm rương báu Diorama kích hoạt ChestReward", chest.is_open())
	chest.close_overlay()
	await get_tree().process_frame
