extends Node

# Automated Test cho Màn 05: Chọn Màn Chơi 2.5D Diorama (Level Select)
const LevelSelectClass = preload("res://game/ui/level_select.gd")

var _passed: int = 0
var _failed: int = 0

func _ready() -> void:
	print("=== BẮT ĐẦU KIỂM THỬ MÀN 05: LEVEL SELECT 2.5D DIORAMA ===")
	_run_tests()

func _check(desc: String, condition: bool) -> void:
	if condition:
		_passed += 1
		print("  [OK ] %s" % desc)
	else:
		_failed += 1
		print("  [FAIL] %s" % desc)

func _run_tests() -> void:
	SaveStore.reset_for_test()
	PauseOverlay.reset_pause_state()

	var ls: LevelSelect = LevelSelectClass.new()
	add_child(ls)

	# 1. Kiểm tra texture nền sạch và các asset 2.5D
	_check("Có tex_bg_level_select_clean.png", ResourceLoader.exists("res://assets/art/tex_bg_level_select_clean.png"))
	_check("Có spr_level_pad_wood.png", ResourceLoader.exists("res://assets/art/spr_level_pad_wood.png"))
	_check("Có spr_bunny_mascot_stand.png", ResourceLoader.exists("res://assets/art/spr_bunny_mascot_stand.png"))
	_check("Có spr_level_chest_gold.png", ResourceLoader.exists("res://assets/art/spr_level_chest_gold.png"))
	_check("Có ui_stars_3_cluster.png", ResourceLoader.exists("res://assets/art/ui_stars_3_cluster.png"))
	_check("Có ui_btn_wood_back.png", ResourceLoader.exists("res://assets/art/ui_btn_wood_back.png"))

	# 2. Test mở cho Chương 1 với bé đang ở bài 4 (page_index = 3)
	GameState.page_index = 3
	GameState.max_page_reached = 3
	ls.open_for_chapter(0)
	await get_tree().process_frame

	var title_lbl: Label = ls.find_child("ChapterTitleLabel", true, false)
	_check("ChapterTitleLabel tồn tại", title_lbl != null)
	_check("Tiêu đề Chương 1 khớp 'Chương 1: Sáo Trúc Rừng Xanh'", title_lbl != null and title_lbl.text == "Chương 1: Sáo Trúc Rừng Xanh")

	# Kiểm tra 5 bục nút bấm
	var pad_btns: Array[Button] = []
	for i in 5:
		var pad_btn: Button = ls.find_child("PadBtn_%d" % (i + 1), true, false)
		if pad_btn != null:
			pad_btns.append(pad_btn)
	_check("Đủ 5 bục gỗ độc lập 2.5D", pad_btns.size() == 5)

	# Kiểm tra vị trí bạn Thỏ: phải nằm ở PadBtn_4 (index 3)
	var bunny: Control = ls.find_child("BunnyMascot", true, false)
	_check("BunnyMascot tồn tại", bunny != null)
	_check("Thỏ gắn đúng vào bục hiện tại của bé (PadBtn_4)", bunny != null and pad_btns.size() == 5 and bunny.get_parent() == pad_btns[3])

	# Kiểm tra trạng thái sao: bài 1..3 phải hiện cụm 3 sao vàng
	var all_stars_ok := true
	for i in 3:
		if i < pad_btns.size():
			var stars: Control = pad_btns[i].find_child("PadStarsCluster", true, false)
			if stars == null or not stars.visible:
				all_stars_ok = false
	_check("Bài 1, 2, 3 hiển thị cụm 3 sao vàng rực rỡ", all_stars_ok)

	# Kiểm tra rương vàng bục 5
	var chest: Control = null
	if pad_btns.size() == 5:
		chest = pad_btns[4].find_child("TreasureChestPad5", true, false)
	_check("Rương Báu Thần mạ vàng ngự trên bục 5", chest != null)

	# 3. Test mở cho Chương 2 (Chương 2: Hồ Nước Kalimba)
	GameState.page_index = 5
	GameState.max_page_reached = 7
	ls.open_for_chapter(1)
	await get_tree().process_frame
	_check("Tiêu đề Chương 2 khớp 'Chương 2: Hồ Nước Kalimba'", title_lbl.text == "Chương 2: Hồ Nước Kalimba")
	_check("Thỏ ở Chương 2 bài đầu tự động chuyển sang PadBtn_1", bunny.get_parent() == pad_btns[0])

	# 4. Test mở cho Chương 3 (Chương 3: Lâu Đài Chuông Gió)
	GameState.page_index = 14
	GameState.max_page_reached = 14
	ls.open_for_chapter(2)
	await get_tree().process_frame
	_check("Tiêu đề Chương 3 khớp 'Chương 3: Lâu Đài Chuông Gió'", title_lbl.text == "Chương 3: Lâu Đài Chuông Gió")
	_check("Thỏ ở Chương 3 bài cuối tự động chuyển sang PadBtn_5", bunny.get_parent() == pad_btns[4])

	# 5. Test Tương tác Nút Quay lại
	var back_btn: Button = ls.find_child("BtnBack", true, false)
	_check("Nút Quay lại BtnBack tồn tại", back_btn != null)
	var back_called := [false]
	ls.back_requested.connect(func(): back_called[0] = true)
	if back_btn != null:
		back_btn.pressed.emit()
		await get_tree().process_frame
	_check("Nút Quay lại phát tín hiệu back_requested", back_called[0])

	# 6. Test Chọn Màn Chơi (Tín hiệu level_selected)
	var selected_page := [-1]
	ls.level_selected.connect(func(p: int): selected_page[0] = p)
	if pad_btns.size() > 2:
		pad_btns[2].pressed.emit()
		# Chờ timer 0.18s trong level_select
		await get_tree().create_timer(0.25).timeout
	_check("Chọn bục 3 phát tín hiệu level_selected với đúng page", selected_page[0] == 12)

	print("\n=== KẾT QUẢ: %d ĐẠT, %d THẤT BẠI ===" % [_passed, _failed])
	if _failed == 0:
		print("=== ĐẠT TOÀN BỘ TIÊU CHÍ MÀN 05 2.5D DIORAMA ===")
	get_tree().quit(0 if _failed == 0 else 1)
