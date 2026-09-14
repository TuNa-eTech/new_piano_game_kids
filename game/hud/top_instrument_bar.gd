class_name TopInstrumentBar
extends Control
## Khay 5 Nhạc Cụ Chạm Khắc Gỗ Cổ Tích Tương Tác 2.5D (Docs/mock-game-play.jpeg).
##
## Thiết kế theo chuẩn thẩm mỹ Storybook 2.5D:
##   - Khay gỗ sồi chạm khắc 5 hốc tròn có chiều sâu (ui_bar_instruments_rack.png).
##   - 5 nhạc cụ độc lập (Violin, Sáo, Trống, Kèn, Đàn Hạc) đặt trong từng hốc gỗ.
##   - Nhạc cụ được chọn: Tự nổi lên (Scale 1.2x, nhấc bổng -3px), quầng sáng ngọc bích
##     dạ quang lan tỏa nhẹ nhàng PHÍA DƯỚI/SAU LƯNG nhạc cụ.
##   - Các nhạc cụ còn lại: Nằm êm trong hốc gỗ với độ mờ dịu mắt (alpha 0.65, scale 0.92).
##   - Tuyệt đối KHÔNG vẽ ô vuông/tròn thô đè lên texture, mang lại cảm giác xúc giác chân thực.

signal instrument_selected(index: int)

const BAR_SIZE := Vector2(260.0, 76.0)
const SLOT_COUNT := 5
const SLOT_CENTERS: Array[Vector2] = [
	Vector2(33.4, 37.0),
	Vector2(81.4, 37.0),
	Vector2(129.1, 37.0),
	Vector2(176.4, 36.9),
	Vector2(223.9, 36.6)
]
const ICON_BASE_SIZE := Vector2(36.0, 36.0)
const INSTRUMENT_NAMES := ["Violin", "Flute", "Drum", "Trumpet", "Harp"]
const ICON_PATHS := [
	"res://assets/art/progress_violin.png",
	"res://assets/art/progress_flute.png",
	"res://assets/art/progress_drum.png",
	"res://assets/art/progress_trumpet.png",
	"res://assets/art/progress_harp.png"
]

var _glow_aura: Control
var _rack_texture: TextureRect
var _icons: Array[TextureRect] = []
var _slot_controls: Array[Control] = []
var _selected_index: int = 0
var _glow_pos: Vector2
var _glow_tween: Tween
var _icon_tweens: Array[Tween] = [null, null, null, null, null]
var _time_passed: float = 0.0


func _ready() -> void:
	custom_minimum_size = BAR_SIZE
	size = BAR_SIZE
	mouse_filter = Control.MOUSE_FILTER_PASS
	_glow_pos = SLOT_CENTERS[0]
	_build_ui()

	var gs = get_node_or_null("/root/GameState")
	if gs != null:
		if gs.has_signal("instrument_mode_changed"):
			gs.instrument_mode_changed.connect(_on_game_state_instrument_changed)
		if "instrument_mode" in gs:
			_selected_index = clampi(gs.instrument_mode, 0, 4)
	_apply_visual_states(true)


func _process(delta: float) -> void:
	_time_passed += delta
	if _glow_aura != null and visible:
		_glow_aura.queue_redraw()


func _build_ui() -> void:
	# 1. Lớp quầng sáng ngọc bích dạ quang (Nằm sau khay hoặc lọt vào trong hốc)
	_glow_aura = Control.new()
	_glow_aura.name = "SoftBacklight"
	_glow_aura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow_aura.draw.connect(_draw_glow_aura)
	add_child(_glow_aura)

	# 2. Khay gỗ sồi 5 hốc tròn 2.5D
	_rack_texture = TextureRect.new()
	_rack_texture.name = "WoodRack"
	_rack_texture.size = BAR_SIZE
	_rack_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_rack_texture.stretch_mode = TextureRect.STRETCH_SCALE
	_rack_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/ui_bar_instruments_rack.png"):
		_rack_texture.texture = load("res://assets/art/ui_bar_instruments_rack.png")
	add_child(_rack_texture)

	# 3. 5 Icon nhạc cụ độc lập & Vùng chạm
	for i in SLOT_COUNT:
		var center := SLOT_CENTERS[i]

		var slot := Control.new()
		slot.name = "Slot_%s" % INSTRUMENT_NAMES[i]
		slot.size = Vector2(46.0, 46.0)
		slot.position = center - slot.size * 0.5
		slot.pivot_offset = slot.size * 0.5
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		var idx := i
		slot.gui_input.connect(func(event: InputEvent): _on_slot_gui_input(event, idx))

		var icon := TextureRect.new()
		icon.name = "Icon"
		icon.size = ICON_BASE_SIZE
		icon.position = (slot.size - ICON_BASE_SIZE) * 0.5
		icon.pivot_offset = ICON_BASE_SIZE * 0.5
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE

		if ResourceLoader.exists(ICON_PATHS[i]):
			icon.texture = load(ICON_PATHS[i])

		slot.add_child(icon)
		add_child(slot)

		_slot_controls.append(slot)
		_icons.append(icon)


func _draw_glow_aura() -> void:
	if _glow_pos == Vector2.ZERO:
		return
	var breath := sin(_time_passed * 3.5) * 1.5
	var base_r := 21.0 + breath

	# Quầng sáng ngọc bích mịn nhiều lớp (Radial Glow, không có viền cứng)
	var color_center := Color(0.20, 0.95, 0.88, 0.55)
	var color_mid := Color(0.12, 0.80, 0.75, 0.30)
	var color_outer := Color(0.08, 0.65, 0.70, 0.10)

	_glow_aura.draw_circle(_glow_pos, base_r + 5.0, color_outer)
	_glow_aura.draw_circle(_glow_pos, base_r, color_mid)
	_glow_aura.draw_circle(_glow_pos, base_r * 0.65, color_center)


func _on_slot_gui_input(event: InputEvent, index: int) -> void:
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		select_instrument(index)
		accept_event()


func select_instrument(index: int) -> void:
	if index < 0 or index >= SLOT_COUNT:
		return

	_selected_index = index
	_apply_visual_states(false)

	# Hiệu ứng nảy đàn hồi (bounce) khi chạm vào nhạc cụ được chọn
	if index < _icons.size():
		var icon := _icons[index]
		var tw := create_tween().bind_node(self).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(icon, "scale", Vector2(1.38, 1.38), 0.10)
		tw.tween_property(icon, "scale", Vector2(1.20, 1.20), 0.15)

	# Phát âm thanh phản hồi xúc giác + nốt mẫu của nhạc cụ
	var audio = get_node_or_null("/root/AudioDirector")
	if audio != null:
		if audio.has_method("play_sfx"):
			audio.play_sfx("wood_tap")
		match index:
			0: # Violin
				audio.play_sfx("violin_pluck")
			1: # Flute
				if audio.has_method("play_instrument_note"):
					audio.play_instrument_note(0, 0, 0.0)
			2: # Drum
				audio.play_sfx("soft_boing")
			3: # Trumpet
				audio.play_sfx("accordion_breath")
			4: # Harp
				audio.play_sfx("harp_chime")

	var gs = get_node_or_null("/root/GameState")
	if gs != null and "instrument_mode" in gs:
		gs.instrument_mode = index

	instrument_selected.emit(index)


func _on_game_state_instrument_changed(mode: int) -> void:
	if mode >= 0 and mode < SLOT_COUNT and mode != _selected_index:
		_selected_index = mode
		_apply_visual_states(false)


func _apply_visual_states(immediate: bool) -> void:
	var target_center := SLOT_CENTERS[_selected_index]

	# Di chuyển quầng sáng ngọc bích mượt mà đến hốc được chọn
	if immediate:
		_glow_pos = target_center
		if _glow_aura != null:
			_glow_aura.queue_redraw()
	else:
		if _glow_tween != null and _glow_tween.is_valid():
			_glow_tween.kill()
		_glow_tween = create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_glow_tween.tween_property(self, "_glow_pos", target_center, 0.28)

	# Chuyển đổi trạng thái vật lý của 5 nhạc cụ
	for i in SLOT_COUNT:
		if i >= _icons.size():
			continue
		var icon := _icons[i]
		var is_active := (i == _selected_index)
		var target_scale := Vector2(1.20, 1.20) if is_active else Vector2(0.92, 0.92)
		var target_y := -3.0 if is_active else 0.0
		var target_mod := Color(1.15, 1.15, 1.15, 1.0) if is_active else Color(0.88, 0.88, 0.88, 0.65)

		if immediate:
			icon.scale = target_scale
			icon.position.y = (ICON_BASE_SIZE.y * (1.0 - target_scale.y) * 0.5) + target_y
			icon.modulate = target_mod
		else:
			if _icon_tweens[i] != null and _icon_tweens[i].is_valid():
				_icon_tweens[i].kill()
			var tw := create_tween().bind_node(self).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.parallel().tween_property(icon, "scale", target_scale, 0.22)
			tw.parallel().tween_property(icon, "position:y", target_y, 0.22)
			tw.parallel().tween_property(icon, "modulate", target_mod, 0.22)
			_icon_tweens[i] = tw

