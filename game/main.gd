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
const ScreenRouter = preload("res://game/ui/screen_router.gd")
const CottageMenuButton = preload("res://game/hud/cottage_menu_button.gd")
const LevelsStarButton = preload("res://game/hud/levels_star_button.gd")
const FreePlayTopBar = preload("res://game/hud/free_play_top_bar.gd")

@onready var _keyboard: PianoKeyboard = $UI/PianoKeyboard
@onready var _tree: MagicTree = $UI/MagicTree
@onready var _call_response: CallResponse = $CallResponse
@onready var _probe: CanvasLayer = $LatencyProbe
@onready var _menu: HoldButton = $HUD/Menu
@onready var _cottage_menu: CottageMenuButton = $HUD/CottageMenu
@onready var _levels_star: LevelsStarButton = $HUD/LevelsStar
@onready var _map: ChapterMap = $ChapterMap
@onready var _chapter_end: ChapterEnd = $ChapterEnd
@onready var _diorama: DioramaStage = $UI/DioramaStage
@onready var _ribbon: MagicRibbon = $UI/MagicRibbon
@onready var _top_inst_bar: Control = $HUD/TopInstrumentBar
@onready var _score_board: Control = $HUD/ScoreBoard

var _router: ScreenRouter
var _free_play_bar: FreePlayTopBar


func _ready() -> void:
	_probe.bind_keyboard(_keyboard)
	_probe.bind_call_response(_call_response)

	_call_response.prompt_updated.connect(_on_prompt_updated)
	_call_response.page_turn_started.connect(_on_page_turn_started)
	_call_response.page_completed.connect(_on_call_response_page_completed)
	_call_response.phrase_completed.connect(_on_phrase_completed)

	# Node con đã _ready() xong ở thời điểm này, nên trao tham chiếu ở đây là an toàn.
	_call_response.setup(_tree, _keyboard)

	_router = ScreenRouter.new()
	_router.name = "ScreenRouter"
	add_child(_router)
	_router.setup(_map, _chapter_end)

	# Thanh 4 Nhạc Cụ Màn 03 Sân Khấu Chơi Tự Do (docs/mock-free-play.jpeg)
	_free_play_bar = FreePlayTopBar.new()
	_free_play_bar.name = "FreePlayTopBar"
	_free_play_bar.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_free_play_bar.position = Vector2((1280.0 - FreePlayTopBar.BAR_SIZE.x) * 0.5, 10.0)
	$HUD.add_child(_free_play_bar)

	GameState.free_play_changed.connect(_on_free_play_mode_changed)
	_on_free_play_mode_changed(GameState.free_play)

	_menu.activated.connect(_on_menu_activated)
	if _cottage_menu != null:
		_cottage_menu.activated.connect(_on_menu_activated)
	if _levels_star != null:
		_levels_star.activated.connect(_on_menu_activated)
	_map.closed.connect(_on_map_closed)
	GameState.chapter_completed.connect(_on_chapter_completed)
	_keyboard.note_played.connect(_on_key_note_played)
	_keyboard.black_note_played.connect(_on_black_note_played)
	if _tree != null:
		_tree.visible = false
		_tree.leaf_singing.connect(func(n):
			if _diorama != null:
				_diorama.sing_leaf(n)
		)
	if _diorama != null:
		_diorama.prop_interacted.connect(_on_diorama_prop_interacted)

	if GameState.show_main_menu_on_launch:
		_router.open_main_menu()


func _on_free_play_mode_changed(enabled: bool) -> void:
	if _top_inst_bar != null:
		_top_inst_bar.visible = not enabled
	if _score_board != null:
		_score_board.visible = false


func _on_page_turn_started() -> void:
	if _diorama != null:
		_diorama.flip_page()


func _on_call_response_page_completed(_page_idx: int) -> void:
	if _diorama != null:
		_diorama.celebrate_completion()


func _on_phrase_completed(_phrase_idx: int) -> void:
	if _diorama != null:
		_diorama.play_flourish()


func _on_prompt_updated(text: String) -> void:
	if _diorama != null:
		_diorama.set_speech_text(text)
	if _ribbon != null and _keyboard != null:
		var exp_note := _call_response.expected_note()
		if exp_note >= 0:
			var from_pos := _diorama.get_leaf_global_position(exp_note) if _diorama != null else (_tree.global_position + _tree.get_leaf_position(exp_note) if _tree != null else Vector2.ZERO)
			var to_pos := _keyboard.get_key_global_position(exp_note)
			_ribbon.set_guiding_stream(from_pos, to_pos, Notes.color_of(exp_note))
		else:
			_ribbon.clear_guiding_stream()


func _on_key_note_played(key: int) -> void:
	if _ribbon != null:
		var from_pos := _keyboard.get_key_global_position(key)
		var to_pos := _diorama.get_leaf_global_position(key) if _diorama != null else (_tree.global_position + _tree.get_leaf_position(key) if _tree != null else Vector2.ZERO)
		_ribbon.emit_ribbon(from_pos, to_pos, Notes.color_of(key))
	if _diorama != null:
		_diorama.on_note_played(key)


func _on_black_note_played(slot: int) -> void:
	if _ribbon != null:
		var from_pos := _keyboard.get_black_key_global_position(slot)
		var target_pos := Vector2(from_pos.x, from_pos.y - 180.0)
		_ribbon.emit_ribbon(from_pos, target_pos, Color("#FFD166"))
	if _diorama != null:
		_diorama.on_note_played(slot)



func _on_menu_activated() -> void:
	# Buông ngón TRƯỚC khi dừng cây: sau khi paused, bàn phím không nhận được sự
	# kiện nhả nữa, ngón đang giữ sẽ kẹt và phím kẹt theo ở trạng thái đang nhấn.
	_keyboard.release_all()
	_map.open_map()




func _on_map_closed() -> void:
	# Lúc bản đồ mở, HUD bị dừng nên nút Menu không thấy ngón nhả ra. Không dọn
	# thì lần sau nó tưởng vẫn còn ngón trên màn hình và từ chối nhận lượt giữ mới.
	_menu.cancel()


func _on_diorama_prop_interacted(prop: String) -> void:
	if prop == "chest" and _router != null:
		_keyboard.release_all()
		_router.open_chest_reward(GameState.chapter_index())


## "Buổi Diễn Rừng Xanh" — hết chương thì cả 7 con vật hát lại giai điệu của
## chương đó. Ván chơi bên dưới đã sang trang đầu chương mới rồi và chỉ đang bị
## dừng, nên đóng màn kết là bé chơi tiếp được ngay.
func _on_chapter_completed(chapter_index: int) -> void:
	# Đi hết một chương CHÍNH LÀ lúc chương sau mở khoá — xem
	# GameState.chapter_unlocked(): nó so max_page_reached với trang đầu chương.
	AudioDirector.play_sfx("chapter_unlock")
	_keyboard.release_all()
	_menu.cancel()
	if _router != null:
		_router.handle_chapter_completed(chapter_index)
	else:
		_chapter_end.play_for_chapter(chapter_index)


func router() -> ScreenRouter:
	return _router
