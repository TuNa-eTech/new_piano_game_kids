class_name ScreenRouter
extends Node
## Bộ Điều Phối Luồng Điều Hướng Toàn Diện (Screen Navigation Orchestrator).
##
## Quản lý vòng đời và sự chuyển tiếp liền mạch giữa tất cả các màn hình & lớp phủ.
##
## Số `layer` quyết định lớp nào nằm trên khi hai lớp phủ cùng mở, nên danh sách
## này phải khớp với code — đừng sửa một bên. Từ trên xuống:
##   MainMenu        25  - Bìa sách cổ tích 'Rừng Nhạc'
##   ParentalGate    20  - Cổng phụ huynh (chồng lên Goodnight — Apple Kids 1.3)
##   ParentalCorner  19  - Góc phụ huynh: giờ chơi, âm lượng
##   GoodnightScreen 18  - Màn đêm ru ngủ dịu êm khi hết giờ hẹn
##   ChapterEnd      13  - Buổi diễn rừng xanh đại nhạc hội 12s
##   ChestReward     12  - Mở rương báu trao huy hiệu bạn thú
##   LevelSelect     11  - Chọn 5 bục gỗ âm nhạc trong chương với Thỏ dẫn đường
##   ChapterMap      10  - Bản đồ 3 chương pop-up gỗ
##
## Việc dừng/chạy lại ván chơi KHÔNG do file này quyết định — xem PauseOverlay:
## ván chơi chạy lại khi và chỉ khi ngăn xếp lớp phủ rỗng.

const ParentalGateClass = preload("res://game/ui/parental_gate.gd")
const ParentalCornerClass = preload("res://game/ui/parental_corner.gd")

var _main_menu: MainMenu
var _chapter_map: ChapterMap
var _level_select: LevelSelect
var _goodnight_screen: GoodnightScreen
var _chest_reward: ChestReward
var _chapter_end: ChapterEnd
var _parental_gate: Node
var _parental_corner: Node

var _target_after_gate: String = ""
var _pending_chapter_reward: int = 0
var _reward_from_chapter_end: bool = false
var enable_chest_before_concert: bool = false


func _ready() -> void:
	if _level_select == null:
		setup()


func setup(
	chapter_map: ChapterMap = null,
	chapter_end: ChapterEnd = null
) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if chapter_map != null:
		_chapter_map = chapter_map
	elif _chapter_map == null:
		_chapter_map = ChapterMap.new()
		_chapter_map.name = "ChapterMap"
		add_child(_chapter_map)

	if chapter_end != null:
		_chapter_end = chapter_end
	elif _chapter_end == null:
		_chapter_end = ChapterEnd.new()
		_chapter_end.name = "ChapterEnd"
		add_child(_chapter_end)

	# Khởi tạo các lớp phủ chuyên dụng nếu chưa có trong cây
	_main_menu = MainMenu.new()
	_main_menu.name = "MainMenu"
	add_child(_main_menu)

	_level_select = LevelSelect.new()
	_level_select.name = "LevelSelect"
	add_child(_level_select)

	_goodnight_screen = GoodnightScreen.new()
	_goodnight_screen.name = "GoodnightScreen"
	add_child(_goodnight_screen)

	_chest_reward = ChestReward.new()
	_chest_reward.name = "ChestReward"
	add_child(_chest_reward)

	_parental_gate = ParentalGateClass.new()
	_parental_gate.name = "ParentalGate"
	add_child(_parental_gate)

	_parental_corner = ParentalCornerClass.new()
	_parental_corner.name = "ParentalCorner"
	add_child(_parental_corner)

	_connect_signals()


func _connect_signals() -> void:
	# 1. MainMenu
	_main_menu.play_pressed.connect(_on_main_menu_play)
	_main_menu.levels_pressed.connect(_on_main_menu_levels)

	# 2. ChapterMap
	_chapter_map.chapter_selected.connect(_on_chapter_selected)
	_chapter_map.main_menu_requested.connect(_on_map_main_menu_requested)

	# 3. LevelSelect
	_level_select.level_selected.connect(_on_level_selected)
	_level_select.back_requested.connect(_on_level_select_back)

	# 4. GoodnightScreen
	_goodnight_screen.wake_up_requested.connect(_on_goodnight_wake_up)

	# 5. ChestReward
	_chest_reward.reward_claimed.connect(_on_reward_claimed)

	# 6. GameState Bedtime Timer
	if not GameState.bedtime_expired.is_connected(_on_bedtime_expired):
		GameState.bedtime_expired.connect(_on_bedtime_expired)

	# 7. ParentalGate
	_parental_gate.gate_unlocked.connect(_on_parental_gate_unlocked)
	_parental_gate.gate_cancelled.connect(_on_parental_gate_cancelled)

	# 8. ParentalCorner
	_parental_corner.closed.connect(_on_parental_corner_closed)


# ---------------------------------------------------------------- Điều Hướng --

## Mở màn hình bìa sách chính
func open_main_menu() -> void:
	_main_menu.open_overlay()


## Mở bản đồ chương
func open_chapter_map() -> void:
	_chapter_map.open_map()


## Mở màn hình chọn bài cho chương
func open_level_select(chapter_index: int) -> void:
	_level_select.open_for_chapter(chapter_index)
	if _chapter_map and _chapter_map.is_open():
		_chapter_map.close_map()


## Mở màn hình chúc bé ngủ ngon
func open_goodnight_screen() -> void:
	_goodnight_screen.open_overlay()


## Alias ngắn gọn cho open_goodnight_screen
func open_goodnight() -> void:
	open_goodnight_screen()


## Mở màn hình nhận thưởng rương báu
func open_chest_reward(badge_index: int) -> void:
	_reward_from_chapter_end = false
	_pending_chapter_reward = badge_index
	_chest_reward.show_reward(badge_index)


## Mở màn hình kết thúc chương (Forest Concert)
func open_chapter_end(chapter_index: int = 0) -> void:
	_chapter_end.play_for_chapter(chapter_index)


## Mở Cổng Phụ Huynh Bảo Vệ (Parental Gate)
func open_parental_gate(target_after_gate: String = "parental_corner") -> void:
	_target_after_gate = target_after_gate
	if _parental_gate != null and _parental_gate.has_method("open_gate"):
		_parental_gate.open_gate()


## Mở Góc Phụ Huynh (Cài đặt giờ chơi, âm lượng, thông tin)
func open_parental_corner() -> void:
	if _parental_corner != null and _parental_corner.has_method("open_corner"):
		_parental_corner.open_corner()


## Đóng tất cả các màn hình/lớp phủ đang mở
func close_all() -> void:
	close_active_overlay()


## Đóng mọi lớp phủ đang mở, từ ĐỈNH ngăn xếp xuống.
##
## Trước Giai Đoạn 1 đây là 8 khối `if` liệt kê tay từng lớp. Hai vấn đề: thêm màn
## hình mới mà quên thêm vào đây thì nó không bao giờ được dọn (đã xảy ra —
## xem _on_main_menu_play), và thứ tự đóng là thứ tự viết trong danh sách chứ
## không phải thứ tự chồng thật.
##
## Đóng từ đỉnh xuống mới đúng: lớp trên cùng là lớp bé đang nhìn. PauseOverlay
## chỉ cho ván chơi chạy lại khi ngăn xếp rỗng, nên không có nhịp nào đàn kêu
## trong lúc màn hình vẫn bị phủ kín.
func close_active_overlay() -> void:
	# Chốt chặn vòng lặp vô hạn: nếu một lớp con ghi đè close_overlay() mà quên
	# gọi super() thì nó sẽ không rời ngăn xếp, và vòng while sẽ quay mãi.
	var guard := 16
	while guard > 0:
		var top := PauseOverlay.top_overlay()
		if top == null:
			return
		top.close_overlay()
		guard -= 1
	push_error("ScreenRouter: không dọn hết ngăn xếp lớp phủ — có lớp con nào đó không gọi super() trong close_overlay()?")


# ---------------------------------------------------------------- Xử Lý Sự Kiện --

func _on_main_menu_play() -> void:
	# Trước đây là `pass` — menu tự đóng nhưng router không dọn các lớp phủ khác
	# (map/level/goodnight) nên ván chơi kẹt paused. Dọn sạch ngăn xếp để bé bấm
	# CHƠI là chơi được ngay, bất kể trước đó đang mở những gì.
	close_active_overlay()


func _on_main_menu_levels() -> void:
	_chapter_map.open_map()
	_main_menu.close_overlay()


func _on_map_main_menu_requested() -> void:
	_main_menu.open_overlay()
	_chapter_map.close_map()


func _on_chapter_selected(chapter: int) -> void:
	# Khi bé chọn chương trên bản đồ, mở con đường chọn bài (LevelSelect) trước khi đóng bản đồ
	_level_select.open_for_chapter(chapter)
	_chapter_map.close_map()


func _on_level_selected(page: int) -> void:
	GameState.auto_play = false
	GameState.free_play = false
	GameState.set_page(page)
	_level_select.close_overlay()
	_chapter_map.close_map()


func _on_level_select_back() -> void:
	_chapter_map.open_map()
	_level_select.close_overlay()


func _on_goodnight_wake_up() -> void:
	# Tuân thủ Apple Kids Category 1.3: Khi đánh thức app từ màn hình ngủ, mở Cổng Phụ Huynh
	open_parental_gate("wake_up")


func _on_parental_gate_unlocked() -> void:
	if _target_after_gate == "wake_up":
		_goodnight_screen.close_overlay()
		GameState.set_bedtime_timer(0)
	elif _target_after_gate == "parental_corner":
		open_parental_corner()
	_target_after_gate = ""


func _on_parental_gate_cancelled() -> void:
	_target_after_gate = ""


func _on_bedtime_expired() -> void:
	_goodnight_screen.open_overlay()


func _on_reward_claimed(_badge_index: int) -> void:
	# Chỉ mở Buổi Diễn Rừng Xanh nếu rương được mở từ sự kiện hoàn thành chương.
	# Nếu bé bấm vào đạo cụ rương trên sân khấu thì đóng rương và quay về bài đang chơi.
	var should_open_concert := _reward_from_chapter_end
	_reward_from_chapter_end = false
	if should_open_concert and _chapter_end != null and not _chapter_end.is_open():
		_chapter_end.play_for_chapter(_pending_chapter_reward)
	if _chest_reward != null and _chest_reward.is_open():
		_chest_reward.close_overlay()


## Xử lý hoàn thành chương (gọi từ main.gd khi trang cuối kết thúc)
func handle_chapter_completed(chapter_index: int) -> void:
	_pending_chapter_reward = chapter_index
	# chapter_completed có thể tới hai lần trong một nhịp. Màn thưởng cuối chương
	# đã mở rồi thì lần thứ hai không được mở đè — bỏ qua, đừng chồng lớp.
	if _chapter_end != null and _chapter_end.is_open():
		return
	if _chest_reward != null and _chest_reward.is_open():
		return
	if enable_chest_before_concert:
		_reward_from_chapter_end = true
		_chest_reward.show_reward(chapter_index)
	else:
		_reward_from_chapter_end = false
		_chapter_end.play_for_chapter(chapter_index)


func _on_parental_corner_closed() -> void:
	pass


# ---------------------------------------------------------------- Getters --

func get_main_menu() -> MainMenu:
	return _main_menu

func get_chapter_map() -> ChapterMap:
	return _chapter_map

func get_level_select() -> LevelSelect:
	return _level_select

func get_goodnight_screen() -> GoodnightScreen:
	return _goodnight_screen

func get_chest_reward() -> ChestReward:
	return _chest_reward

func get_chapter_end() -> ChapterEnd:
	return _chapter_end

func get_parental_gate() -> Node:
	return _parental_gate

func get_parental_corner() -> Node:
	return _parental_corner
