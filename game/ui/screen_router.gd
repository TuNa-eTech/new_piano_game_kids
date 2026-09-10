class_name ScreenRouter
extends Node
## Bộ Điều Phối Luồng Điều Hướng Toàn Diện (Screen Navigation Orchestrator).
##
## Quản lý vòng đời và sự chuyển tiếp liền mạch giữa tất cả các màn hình & lớp phủ:
## 1. MainMenu (layer 25) - Bìa sách cổ tích 'Rừng Nhạc'
## 2. ParentalGate (layer 20) - Cổng giải đố 3 quả dâu bảo vệ trẻ em (Apple Kids Category 1.3)
## 3. GoodnightScreen (layer 18) - Màn đêm ru ngủ dịu êm khi hết giờ hẹn
## 4. ParentalCorner (layer 15) - Góc cài đặt âm lượng & hẹn giờ của cha mẹ
## 5. ChapterEnd (layer 13) - Buổi diễn rừng xanh đại nhạc hội 12s
## 6. ChestReward (layer 12) - Mở rương báu trao huy hiệu bạn thú
## 7. LevelSelect (layer 11) - Chọn 5 bục gỗ âm nhạc trong chương với Thỏ dẫn đường
## 8. ChapterMap (layer 10) - Bản đồ 3 chương pop-up gỗ

enum GateTarget {
	PARENTAL_CORNER,
	WAKE_UP_FOREST
}

var _main_menu: MainMenu
var _chapter_map: ChapterMap
var _level_select: LevelSelect
var _parental_gate: ParentalGate
var _parental_corner: ParentalCorner
var _goodnight_screen: GoodnightScreen
var _chest_reward: ChestReward
var _chapter_end: ChapterEnd

var _gate_target: GateTarget = GateTarget.PARENTAL_CORNER
var _pending_chapter_reward: int = 0
var enable_chest_before_concert: bool = false


func setup(
	chapter_map: ChapterMap,
	chapter_end: ChapterEnd
) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_chapter_map = chapter_map
	_chapter_end = chapter_end

	# Khởi tạo các lớp phủ chuyên dụng nếu chưa có trong cây
	_main_menu = MainMenu.new()
	_main_menu.name = "MainMenu"
	add_child(_main_menu)

	_level_select = LevelSelect.new()
	_level_select.name = "LevelSelect"
	add_child(_level_select)

	_parental_gate = ParentalGate.new()
	_parental_gate.name = "ParentalGate"
	add_child(_parental_gate)

	_parental_corner = ParentalCorner.new()
	_parental_corner.name = "ParentalCorner"
	add_child(_parental_corner)

	_goodnight_screen = GoodnightScreen.new()
	_goodnight_screen.name = "GoodnightScreen"
	add_child(_goodnight_screen)

	_chest_reward = ChestReward.new()
	_chest_reward.name = "ChestReward"
	add_child(_chest_reward)

	_connect_signals()


func _connect_signals() -> void:
	# 1. MainMenu
	_main_menu.play_pressed.connect(_on_main_menu_play)
	_main_menu.levels_pressed.connect(_on_main_menu_levels)
	_main_menu.parent_gate_requested.connect(_on_open_parental_gate_for_corner)

	# 2. ChapterMap
	_chapter_map.chapter_selected.connect(_on_chapter_selected)
	_chapter_map.main_menu_requested.connect(_on_map_main_menu_requested)
	_chapter_map.parent_gate_requested.connect(_on_open_parental_gate_for_corner)

	# 3. LevelSelect
	_level_select.level_selected.connect(_on_level_selected)
	_level_select.back_requested.connect(_on_level_select_back)

	# 4. ParentalGate
	_parental_gate.gate_unlocked.connect(_on_gate_unlocked)

	# 5. ParentalCorner
	_parental_corner.bedtime_timer_changed.connect(_on_bedtime_timer_changed)

	# 6. GoodnightScreen
	_goodnight_screen.parental_unlock_requested.connect(_on_goodnight_unlock_requested)

	# 7. ChestReward
	_chest_reward.reward_claimed.connect(_on_reward_claimed)

	# 8. GameState Bedtime Timer
	GameState.bedtime_expired.connect(_on_bedtime_expired)


# ---------------------------------------------------------------- Điều Hướng --

## Mở màn hình bìa sách chính
func open_main_menu() -> void:
	_main_menu.open_overlay()


## Mở bản đồ chương
func open_chapter_map() -> void:
	_chapter_map.open_map()


## Mở màn hình chọn bài cho chương
func open_level_select(chapter_index: int) -> void:
	if _chapter_map and _chapter_map.is_open():
		_chapter_map.close_map()
	_level_select.open_for_chapter(chapter_index)


## Mở cổng phụ huynh trực tiếp
func open_parental_gate(target_type: String = "corner") -> void:
	if target_type == "goodnight" or target_type == "wake_up":
		_gate_target = GateTarget.WAKE_UP_FOREST
	else:
		_gate_target = GateTarget.PARENTAL_CORNER
	_parental_gate.open_overlay()


## Mở góc phụ huynh trực tiếp
func open_parental_corner() -> void:
	_parental_corner.open_overlay()


## Mở cổng phụ huynh để vào cài đặt
func open_parental_settings() -> void:
	_on_open_parental_gate_for_corner()


## Mở màn hình chúc bé ngủ ngon
func open_goodnight_screen() -> void:
	_goodnight_screen.open_overlay()


## Alias ngắn gọn cho open_goodnight_screen
func open_goodnight() -> void:
	open_goodnight_screen()


## Mở màn hình nhận thưởng rương báu
func open_chest_reward(badge_index: int) -> void:
	_pending_chapter_reward = badge_index
	_chest_reward.show_reward(badge_index)


## Mở màn hình kết thúc chương (Forest Concert)
func open_chapter_end(chapter_index: int = 0) -> void:
	_chapter_end.play_for_chapter(chapter_index)


## Đóng tất cả các màn hình/lớp phủ đang mở
func close_all() -> void:
	close_active_overlay()


## Đóng lớp phủ đang mở nếu có
func close_active_overlay() -> void:
	if _main_menu and _main_menu.is_open():
		_main_menu.close_overlay()
	if _chapter_map and _chapter_map.is_open():
		_chapter_map.close_map()
	if _level_select and _level_select.is_open():
		_level_select.close_overlay()
	if _parental_gate and _parental_gate.is_open():
		_parental_gate.close_overlay()
	if _parental_corner and _parental_corner.is_open():
		_parental_corner.close_overlay()
	if _goodnight_screen and _goodnight_screen.is_open():
		_goodnight_screen.close_overlay()
	if _chest_reward and _chest_reward.is_open():
		_chest_reward.close_overlay()
	if _chapter_end and _chapter_end.is_open():
		_chapter_end.close_overlay()


# ---------------------------------------------------------------- Xử Lý Sự Kiện --

func _on_main_menu_play() -> void:
	# Đóng menu và bắt đầu chơi
	pass


func _on_main_menu_levels() -> void:
	_main_menu.close_overlay()
	_chapter_map.open_map()


func _on_open_parental_gate_for_corner() -> void:
	_gate_target = GateTarget.PARENTAL_CORNER
	_parental_gate.open_overlay()


func _on_map_main_menu_requested() -> void:
	_chapter_map.close_map()
	_main_menu.open_overlay()


func _on_chapter_selected(chapter: int) -> void:
	# Khi bé chọn chương trên bản đồ, mở con đường chọn bài (LevelSelect)
	_chapter_map.close_map()
	_level_select.open_for_chapter(chapter)


func _on_level_selected(page: int) -> void:
	GameState.set_page(page)
	_level_select.close_overlay()
	_chapter_map.close_map()


func _on_level_select_back() -> void:
	_level_select.close_overlay()
	_chapter_map.open_map()


func _on_gate_unlocked() -> void:
	match _gate_target:
		GateTarget.PARENTAL_CORNER:
			_parental_corner.open_overlay()
		GateTarget.WAKE_UP_FOREST:
			_goodnight_screen.close_overlay()
			GameState.set_bedtime_timer(0)


func _on_bedtime_timer_changed(minutes: int) -> void:
	GameState.set_bedtime_timer(minutes)


func _on_goodnight_unlock_requested() -> void:
	_gate_target = GateTarget.WAKE_UP_FOREST
	_parental_gate.open_overlay()


func _on_bedtime_expired() -> void:
	_goodnight_screen.open_overlay()


func _on_reward_claimed(_badge_index: int) -> void:
	if _chapter_end != null:
		_chapter_end.play_for_chapter(_pending_chapter_reward)


## Xử lý hoàn thành chương (gọi từ main.gd khi trang cuối kết thúc)
func handle_chapter_completed(chapter_index: int) -> void:
	_pending_chapter_reward = chapter_index
	if enable_chest_before_concert:
		_chest_reward.show_reward(chapter_index)
	else:
		_chapter_end.play_for_chapter(chapter_index)


# ---------------------------------------------------------------- Getters --

func get_main_menu() -> MainMenu:
	return _main_menu

func get_chapter_map() -> ChapterMap:
	return _chapter_map

func get_level_select() -> LevelSelect:
	return _level_select

func get_parental_gate() -> ParentalGate:
	return _parental_gate

func get_parental_corner() -> ParentalCorner:
	return _parental_corner

func get_goodnight_screen() -> GoodnightScreen:
	return _goodnight_screen

func get_chest_reward() -> ChestReward:
	return _chest_reward

func get_chapter_end() -> ChapterEnd:
	return _chapter_end
