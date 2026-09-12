class_name TopInstrumentBar
extends Control
## Thanh 5 Nhạc Cụ góc trái trên của màn hình gameplay (docs/mock-game-play.jpeg).

signal instrument_selected(index: int)

const BAR_SIZE := Vector2(360.0, 84.0)

var _bg_rect: TextureRect
var _selection_glow: Control
var _hit_areas: Array[Control] = []
var _selected_index: int = 0
var _glow_tween: Tween

const INSTRUMENT_NAMES := ["Violin", "Flute", "Drum", "Trumpet", "Harp"]


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	resized.connect(_on_resized)
	_build_ui()

	var gs = get_node_or_null("/root/GameState")
	if gs != null and gs.has_signal("instrument_mode_changed"):
		gs.instrument_mode_changed.connect(_on_game_state_instrument_changed)


func _on_resized() -> void:
	if _hit_areas.size() == 5 and size.x > 0:
		var slot_w := size.x / 5.0
		for i in 5:
			_hit_areas[i].position = Vector2(i * slot_w, 0)
			_hit_areas[i].size = Vector2(slot_w, size.y)
		_update_glow_position()


func _build_ui() -> void:
	_bg_rect = TextureRect.new()
	_bg_rect.name = "Background"
	_bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg_rect.stretch_mode = TextureRect.STRETCH_SCALE
	_bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if ResourceLoader.exists("res://assets/art/ui_bar_instruments_gameplay.png"):
		_bg_rect.texture = load("res://assets/art/ui_bar_instruments_gameplay.png")
	add_child(_bg_rect)

	_selection_glow = Control.new()
	_selection_glow.name = "SelectionGlow"
	_selection_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_selection_glow.draw.connect(_draw_selection_glow)
	add_child(_selection_glow)

	var slot_w := size.x / 5.0
	for i in 5:
		var slot := Control.new()
		slot.name = "Slot_%s" % INSTRUMENT_NAMES[i]
		slot.position = Vector2(i * slot_w, 0)
		slot.size = Vector2(slot_w, size.y)
		slot.mouse_filter = Control.MOUSE_FILTER_PASS
		var idx := i
		slot.gui_input.connect(func(event: InputEvent): _on_slot_gui_input(event, idx))
		add_child(slot)
		_hit_areas.append(slot)

	_update_glow_position()


func _on_slot_gui_input(event: InputEvent, index: int) -> void:
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		select_instrument(index)
		accept_event()


func select_instrument(index: int) -> void:
	if index < 0 or index >= 5:
		return

	_selected_index = index
	_update_glow_position()

	var audio = get_node_or_null("/root/AudioDirector")
	if audio != null:
		if audio.has_method("play_instrument_note"):
			audio.play_instrument_note(index, 3, 0.0)
		if audio.has_method("play_sfx"):
			audio.play_sfx("wood_tap")

	var gs = get_node_or_null("/root/GameState")
	if gs != null and gs.has_method("set_instrument_mode"):
		gs.set_instrument_mode(index)

	instrument_selected.emit(index)


func _on_game_state_instrument_changed(mode: int) -> void:
	if mode >= 0 and mode < 5:
		_selected_index = mode
		_update_glow_position()


func _update_glow_position() -> void:
	var slot_w := size.x / 5.0
	var target_x := _selected_index * slot_w + slot_w * 0.5
	var target_y := size.y * 0.5

	if _glow_tween != null and _glow_tween.is_valid():
		_glow_tween.kill()

	_glow_tween = create_tween().bind_node(self)
	_glow_tween.tween_property(_selection_glow, "position", Vector2(target_x, target_y), 0.22) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	_selection_glow.queue_redraw()


func _draw_selection_glow() -> void:
	var pulse := 0.85 + 0.15 * sin(Time.get_ticks_msec() * 0.005)
	var glow_radius := (size.y * 0.42) * pulse
	_selection_glow.draw_circle(Vector2.ZERO, glow_radius + 4.0, Color(0.2, 0.9, 0.85, 0.22))
	_selection_glow.draw_circle(Vector2.ZERO, glow_radius, Color(0.3, 1.0, 0.9, 0.35))
	_selection_glow.draw_arc(Vector2.ZERO, glow_radius, 0.0, TAU, 32, Color(0.6, 1.0, 0.95, 0.75), 2.5, true)
