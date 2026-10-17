class_name FreePlayTopBar
extends Control
## Thanh Chọn 4 Nhạc Cụ Gỗ Trung Tâm Màn Hình Chơi Tự Do (docs/mock-free-play.jpeg).
##
## Tái hiện 100% bản vẽ Màn 03: Sân Khấu Chơi Tự Do:
##   0. Đại Cầm (Grand Piano) -> Âm sắc piano ấm áp cổ điển
##   1. Đàn Kalimba Gỗ (Wooden Kalimba) -> Phím gõ kim loại mộc mạc
##   2. Chuông Pha Lê (Crystal Bell) -> Chuông ngân vang trong trẻo
##   3. Giọng Thú Ngộ Nghĩnh (Funny Animal Voices) -> Icon chú Khỉ ngộ nghĩnh
##
## Tương tác:
##   - Trượt êm ái từ mép trên xuống khi bật Chơi Tự Do (Free Play).
##   - Quầng hào quang vàng kim rực rỡ báo hiệu nhạc cụ đang kích hoạt.
##   - Chạm vào slot phát âm thanh thử nốt + hiệu ứng nảy đàn hồi (bounce tween).

signal instrument_selected(index: int)

const BAR_SIZE := Vector2(440.0, 80.0)
const SLOT_COUNT := 4
const INSTRUMENT_NAMES := [
	"Đại Cầm",
	"Đàn Kalimba Gỗ",
	"Chuông Pha Lê",
	"Giọng Thú Ngộ Nghĩnh"
]

## Ánh xạ từ 4 nút Màn 03 sang instrument_mode của GameState:
## 0: Đại Cầm (AUTO / Piano base)
## 1: Kalimba (mode 3)
## 2: Chuông Pha Lê (mode 4)
## 3: Giọng Thú (mode 1)
## P3: giữ nguyên — mock-free-play.jpeg chỉ có 4 slot, FLUTE (mode 2) cố ý
## vắng mặt ở Free Play (vẫn có trong InstrumentSwitcher guided 5 mode).
## Thứ tự không liên tục là đúng, đừng "sửa" thành [0,1,2,3].
const SLOT_TO_MODE := [0, 3, 4, 1]
const SLOT_CENTERS: Array[float] = [76.0, 166.0, 259.0, 353.0]

var _bg_rect: TextureRect
var _selection_aura: Control
var _hit_areas: Array[Control] = []
var _selected_slot: int = 0
var _slide_tween: Tween
var _aura_phase: float = 0.0


func _ready() -> void:
	custom_minimum_size = BAR_SIZE
	size = BAR_SIZE
	mouse_filter = Control.MOUSE_FILTER_PASS
	position = Vector2((1280.0 - BAR_SIZE.x) * 0.5, 4.0)

	_build_ui()

	if is_instance_valid(GameState):
		GameState.free_play_changed.connect(_on_free_play_changed)
		GameState.instrument_mode_changed.connect(_on_game_state_mode_changed)
		visible = GameState.free_play
		_sync_with_game_state()


func _process(delta: float) -> void:
	if visible and _selection_aura != null:
		_aura_phase = fmod(_aura_phase + delta * 2.5, TAU)
		_selection_aura.queue_redraw()


func _build_ui() -> void:
	# 1. Nền gỗ thanh 4 nhạc cụ
	_bg_rect = TextureRect.new()
	_bg_rect.name = "Background"
	_bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg_rect.stretch_mode = TextureRect.STRETCH_SCALE
	_bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if ResourceLoader.exists("res://assets/art/ui_bar_instruments_freeplay.png"):
		_bg_rect.texture = load("res://assets/art/ui_bar_instruments_freeplay.png")
	add_child(_bg_rect)

	# 2. Vùng quầng sáng báo hiệu lựa chọn (Aura Medallion)
	_selection_aura = Control.new()
	_selection_aura.name = "SelectionAura"
	_selection_aura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_selection_aura.draw.connect(_draw_selection_aura)
	add_child(_selection_aura)

	# 3. 4 vùng nhận chạm cảm ứng (Touch Slots chuẩn Apple Kids >= 88 pt)
	for i in SLOT_COUNT:
		var slot := Control.new()
		slot.name = "Slot_%d" % i
		var cx := SLOT_CENTERS[i]
		slot.position = Vector2(cx - 45.0, 0)
		slot.size = Vector2(90.0, size.y)
		slot.pivot_offset = Vector2(45.0, size.y * 0.44)
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		var idx := i
		slot.gui_input.connect(func(event: InputEvent): _on_slot_gui_input(event, idx))
		add_child(slot)
		_hit_areas.append(slot)

	_update_aura_position()


func _on_slot_gui_input(event: InputEvent, index: int) -> void:
	var slot_node: Control = _hit_areas[index]
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(slot_node, "scale", Vector2(0.92, 0.92), 0.05)
		select_slot(index)
		accept_event()
	elif (event is InputEventScreenTouch and not event.pressed) or (event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(slot_node, "scale", Vector2.ONE, 0.22)
		accept_event()


func select_slot(index: int) -> void:
	if index < 0 or index >= SLOT_COUNT:
		return

	_selected_slot = index
	_update_aura_position()

	# Hiệu ứng nảy đàn hồi lò xo
	var slot_node: Control = _hit_areas[index]
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(slot_node, "scale", Vector2(1.18, 1.18), 0.12)
	tw.tween_property(slot_node, "scale", Vector2(1.0, 1.0), 0.20)

	var target_mode: int = SLOT_TO_MODE[index]
	if is_instance_valid(GameState):
		GameState.instrument_mode = target_mode

	# Âm thanh phản hồi xúc giác (cập nhật mode trước để play_note phát đúng nhạc cụ mới)
	if is_instance_valid(AudioDirector):
		AudioDirector.play_sfx("wood_tap")
		match index:
			0: # Đại Cầm
				AudioDirector.play_note(3) # Nốt G4
			1: # Kalimba
				AudioDirector.play_instrument_note(1, 3, 0.0)
			2: # Chuông Pha Lê
				AudioDirector.play_instrument_note(2, 3, 0.0)
			3: # Giọng Thú
				AudioDirector.play_note(3)

	instrument_selected.emit(index)


func _draw_selection_aura() -> void:
	var center_x: float = SLOT_CENTERS[_selected_slot]
	var center_y: float = size.y * 0.44
	var radius := 29.0 + 2.0 * sin(_aura_phase)

	# Quầng sáng ánh kim vàng dịu tự nhiên (Soft Radial Spotlight, không vẽ viền cứng)
	var gold_core := Color(1.0, 0.92, 0.50, 0.40)
	var gold_mid := Color(0.95, 0.75, 0.25, 0.20)
	var gold_outer := Color(0.85, 0.60, 0.15, 0.06)

	_selection_aura.draw_circle(Vector2(center_x, center_y), radius + 10.0, gold_outer)
	_selection_aura.draw_circle(Vector2(center_x, center_y), radius + 4.0, gold_mid)
	_selection_aura.draw_circle(Vector2(center_x, center_y), radius * 0.70, gold_core)



func _update_aura_position() -> void:
	if _selection_aura != null:
		_selection_aura.queue_redraw()


func _sync_with_game_state() -> void:
	var current_mode := GameState.instrument_mode
	for i in SLOT_COUNT:
		if SLOT_TO_MODE[i] == current_mode:
			_selected_slot = i
			break
	_update_aura_position()


func _on_game_state_mode_changed(mode: int) -> void:
	for i in SLOT_COUNT:
		if SLOT_TO_MODE[i] == mode:
			_selected_slot = i
			_update_aura_position()
			break


func _on_free_play_changed(enabled: bool) -> void:
	if _slide_tween != null and _slide_tween.is_valid():
		_slide_tween.kill()

	_slide_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var target_x := (1280.0 - BAR_SIZE.x) * 0.5

	if enabled:
		visible = true
		position = Vector2(target_x, -size.y - 20.0)
		modulate.a = 0.0
		_slide_tween.tween_property(self, "position:y", 4.0, 0.45)
		_slide_tween.parallel().tween_property(self, "modulate:a", 1.0, 0.3)
	else:
		_slide_tween.tween_property(self, "position:y", -size.y - 20.0, 0.35)
		_slide_tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
		_slide_tween.tween_callback(func(): visible = false)
