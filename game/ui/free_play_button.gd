class_name FreePlayButton
extends Button
## Nút "Tự do" — Quyết định 03 chốt nó LUÔN HIỆN trên phím đàn.
##
## Bật lên thì không gợi ý, không chuỗi: chỉ đàn, con vật và cây mọc theo mỗi
## nốt. Tài liệu gọi đây là chế độ trẻ ở lại lâu nhất và phụ huynh quay video
## nhiều nhất, nên nó không phải thứ giấu trong menu.
##
## Không chữ. Biểu tượng là một nốt nhạc: tắt thì viền rỗng, bật thì đầy và có
## tia — thay đổi phải thấy được từ xa vì bé sẽ bấm nó rất nhiều lần.

const MIN_TOUCH_SIZE := 88.0

var _face: Control

@onready var _accent := Color("#E8D9A0")


func _ready() -> void:
	toggle_mode = true
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(MIN_TOUCH_SIZE, MIN_TOUCH_SIZE)

	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.09, 0.13, 0.10, 0.85)
	box.set_corner_radius_all(44)
	box.set_border_width_all(3)
	box.border_color = Color(1, 1, 1, 0.18)
	var on := box.duplicate() as StyleBoxFlat
	on.bg_color = Color("#3F9455").darkened(0.15)
	on.border_color = _accent
	for state in ["normal", "hover", "focus"]:
		add_theme_stylebox_override(state, box)
	for state in ["pressed"]:
		add_theme_stylebox_override(state, on)

	_face = Control.new()
	_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_face.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_face)
	_face.draw.connect(_draw_face)

	toggled.connect(_on_toggled)
	GameState.free_play_changed.connect(_on_free_play_changed)
	button_pressed = GameState.free_play


func _on_toggled(pressed_state: bool) -> void:
	GameState.free_play = pressed_state
	_face.queue_redraw()


## Trạng thái có thể bị đổi từ nơi khác (máy đo, hoặc một luồng sau này). Nút chỉ
## HIỂN THỊ trạng thái chứ không sở hữu nó, nên phải bám theo nguồn thật.
func _on_free_play_changed(enabled: bool) -> void:
	if button_pressed != enabled:
		button_pressed = enabled
	_face.queue_redraw()


func _draw_face() -> void:
	var c := _face.size * 0.5
	var r := minf(_face.size.x, _face.size.y) * 0.5
	var on := GameState.free_play
	var ink := _accent if on else Color(1, 1, 1, 0.55)

	var head := c + Vector2(-r * 0.16, r * 0.24)
	var head_r := r * 0.2
	if on:
		_face.draw_circle(head, head_r, ink)
	else:
		_face.draw_arc(head, head_r, 0.0, TAU, 24, ink, 4.0, true)
	_face.draw_line(
		head + Vector2(head_r, 0.0),
		head + Vector2(head_r, -r * 0.78),
		ink, 4.0, true
	)
	_face.draw_line(
		head + Vector2(head_r, -r * 0.78),
		head + Vector2(head_r + r * 0.36, -r * 0.62),
		ink, 4.0, true
	)

	if not on:
		return
	# Tia sáng: bật rồi thì nhìn từ xa cũng biết đang ở chế độ tự do.
	for i in 6:
		var a := TAU * i / 6.0 - PI * 0.5
		var d := Vector2(cos(a), sin(a))
		_face.draw_line(c + d * (r * 0.76), c + d * (r * 0.92), ink, 3.0, true)
