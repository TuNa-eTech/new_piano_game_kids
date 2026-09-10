extends Node2D
## Scene gốc.
##
## Tuần 1 dựng bàn phím và audio. Tuần 2 thêm cây thần, vòng gọi–đáp và lọ hạt
## sao. Tuần 3 thêm bản đồ chương, khoá giữ 2 giây ở Menu và Chơi Tự Do — tiêu
## chí thoát của tuần là "một đứa trẻ thật chơi 5 phút không cần người lớn chỉ".
##
## Node này chỉ làm một việc: nối dây. Toàn bộ luật chơi nằm trong CallResponse,
## toàn bộ hiển thị nằm trong MagicTree, StarJar và ChapterProgress.

const DioramaStage = preload("res://game/diorama/diorama_stage.gd")
const MagicRibbon = preload("res://game/diorama/magic_ribbon.gd")
const LevelSelect = preload("res://game/ui/level_select.gd")
const ParentalGate = preload("res://game/ui/parental_gate.gd")
const ParentalCorner = preload("res://game/ui/parental_corner.gd")
const GoodnightScreen = preload("res://game/ui/goodnight_screen.gd")
const ChestReward = preload("res://game/ui/chest_reward.gd")
const MainMenu = preload("res://game/ui/main_menu.gd")

@onready var _keyboard: PianoKeyboard = $UI/PianoKeyboard
@onready var _tree: MagicTree = $UI/MagicTree
@onready var _call_response: CallResponse = $CallResponse
@onready var _probe: CanvasLayer = $LatencyProbe
@onready var _menu: HoldButton = $HUD/Menu
@onready var _map: ChapterMap = $ChapterMap
@onready var _chapter_end: ChapterEnd = $ChapterEnd
@onready var _diorama: DioramaStage = $UI/DioramaStage
@onready var _ribbon: MagicRibbon = $UI/MagicRibbon

var _level_select: LevelSelect
var _parental_gate: ParentalGate
var _parental_corner: ParentalCorner
var _goodnight: GoodnightScreen
var _chest_reward: ChestReward
var _main_menu: MainMenu


func _ready() -> void:
	_probe.bind_keyboard(_keyboard)
	_probe.bind_call_response(_call_response)

	# Node con đã _ready() xong ở thời điểm này, nên trao tham chiếu ở đây là an toàn.
	_call_response.setup(_tree, _keyboard)

	_menu.activated.connect(_on_menu_activated)
	_map.closed.connect(_on_map_closed)
	GameState.chapter_completed.connect(_on_chapter_completed)
	_keyboard.note_played.connect(_on_key_note_played)
	_call_response.prompt_updated.connect(_on_prompt_updated)

	_init_sub_screens()


func _on_prompt_updated(text: String) -> void:
	if _diorama != null:
		_diorama.set_speech_text(text)


func _on_key_note_played(key: int) -> void:

	if _ribbon != null and _tree != null:
		var from_pos := _keyboard.get_key_global_position(key)
		var to_pos := _tree.global_position + _tree.get_leaf_position(key)
		_ribbon.emit_ribbon(from_pos, to_pos, Notes.color_of(key))
	if _diorama != null:
		_diorama.on_note_played(key)



func _on_menu_activated() -> void:
	# Buông ngón TRƯỚC khi dừng cây: sau khi paused, bàn phím không nhận được sự
	# kiện nhả nữa, ngón đang giữ sẽ kẹt và phím kẹt theo ở trạng thái đang nhấn.
	_keyboard.release_all()
	_map.open_map()




func _on_map_closed() -> void:
	# Lúc bản đồ mở, HUD bị dừng nên nút Menu không thấy ngón nhả ra. Không dọn
	# thì lần sau nó tưởng vẫn còn ngón trên màn hình và từ chối nhận lượt giữ mới.
	_menu.cancel()


## "Buổi Diễn Rừng Xanh" — hết chương thì cả 7 con vật hát lại giai điệu của
## chương đó. Ván chơi bên dưới đã sang trang đầu chương mới rồi và chỉ đang bị
## dừng, nên đóng màn kết là bé chơi tiếp được ngay.
func _on_chapter_completed(chapter_index: int) -> void:
	# Đi hết một chương CHÍNH LÀ lúc chương sau mở khoá — xem
	# GameState.chapter_unlocked(): nó so max_page_reached với trang đầu chương.
	AudioDirector.play_sfx("chapter_unlock")
	_keyboard.release_all()
	_menu.cancel()
	_chapter_end.play_for_chapter(chapter_index)


func _init_sub_screens() -> void:
	_level_select = LevelSelect.new()
	add_child(_level_select)
	_level_select.level_selected.connect(_on_level_selected)
	_level_select.back_requested.connect(func(): _map.open_map())

	_parental_gate = ParentalGate.new()
	add_child(_parental_gate)
	_parental_gate.gate_unlocked.connect(_on_parental_gate_unlocked)

	_parental_corner = ParentalCorner.new()
	add_child(_parental_corner)
	_parental_corner.bedtime_timer_changed.connect(func(mins): GameState.set_bedtime_limit(mins))

	_goodnight = GoodnightScreen.new()
	add_child(_goodnight)
	_goodnight.parental_unlock_requested.connect(func(): _parental_gate.open_overlay())

	_chest_reward = ChestReward.new()
	add_child(_chest_reward)

	_main_menu = MainMenu.new()
	add_child(_main_menu)
	_main_menu.play_pressed.connect(_on_ftue_play_pressed)
	_main_menu.levels_pressed.connect(func(): _map.open_map())
	_main_menu.parent_gate_requested.connect(func(): _parental_gate.open_overlay())

	GameState.bedtime_triggered.connect(_on_bedtime_triggered)


func show_main_menu() -> void:
	_main_menu.open_overlay()


func _on_level_selected(page: int) -> void:
	GameState.set_page(page)
	_map.close_map()


func _on_parental_gate_unlocked() -> void:
	if _goodnight.is_open():
		_goodnight.close_overlay()
	else:
		_parental_corner.open_overlay()


func _on_bedtime_triggered() -> void:
	_keyboard.release_all()
	_menu.cancel()
	_goodnight.open_overlay()


func _on_ftue_play_pressed() -> void:
	GameState.has_completed_ftue = true

