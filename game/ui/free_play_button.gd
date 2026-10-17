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

const MIN_TOUCH_SIZE := 96.0

var _face: Control
var _anim_tween: Tween
var _aura_phase: float = 0.0

@onready var _accent := Color("#FFE566")
var _free_play_texture: Texture2D


func _ready() -> void:
	toggle_mode = true
	focus_mode = Control.FOCUS_NONE
	flat = true
	if ResourceLoader.exists("res://assets/art/ui_btn_freeplay_wood.png"):
		_free_play_texture = load("res://assets/art/ui_btn_freeplay_wood.png")
	elif ResourceLoader.exists("res://assets/art/ui_free_play.png"):
		_free_play_texture = load("res://assets/art/ui_free_play.png")
	custom_minimum_size = Vector2(MIN_TOUCH_SIZE, MIN_TOUCH_SIZE)
	pivot_offset = Vector2(MIN_TOUCH_SIZE * 0.5, MIN_TOUCH_SIZE * 0.5)

	var empty := StyleBoxEmpty.new()
	for state in ["normal", "hover", "focus", "pressed", "disabled"]:
		add_theme_stylebox_override(state, empty)

	_face = Control.new()
	_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_face.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_face)
	_face.draw.connect(_draw_face)

	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	toggled.connect(_on_toggled)
	GameState.free_play_changed.connect(_on_free_play_changed)
	button_pressed = GameState.free_play


func _process(delta: float) -> void:
	if GameState.free_play and _face != null:
		_aura_phase = fmod(_aura_phase + delta * 3.0, TAU)
		_face.queue_redraw()


func _on_button_down() -> void:
	if _anim_tween != null and _anim_tween.is_valid():
		_anim_tween.kill()
	_anim_tween = create_tween()
	_anim_tween.tween_property(self, "scale", Vector2(0.90, 0.90), 0.06).set_trans(Tween.TRANS_QUAD)


func _on_button_up() -> void:
	if _anim_tween != null and _anim_tween.is_valid():
		_anim_tween.kill()
	_anim_tween = create_tween()
	_anim_tween.tween_property(self, "scale", Vector2.ONE, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_toggled(pressed_state: bool) -> void:
	# P1 radio: bật Tự do mà Jukebox đang chạy thì Jukebox tự tắt trong
	# GameState — phát thêm fairy_dust để phụ huynh/bé nghe ra "đã chuyển mode",
	# thay vì nhạc dừng đột ngột không báo.
	var killed_auto := pressed_state and GameState.auto_play
	AudioDirector.play_sfx("free_play_toggle")
	GameState.free_play = pressed_state
	if killed_auto:
		AudioDirector.play_sfx("fairy_dust")
	_face.queue_redraw()


func _on_free_play_changed(enabled: bool) -> void:
	if button_pressed != enabled:
		button_pressed = enabled
	_face.queue_redraw()


func _draw_face() -> void:
	var c := _face.size * 0.5
	var r := minf(_face.size.x, _face.size.y) * 0.5
	var on := GameState.free_play
	var ink := _accent if on else Color(1, 1, 1, 0.85)

	if _free_play_texture != null:
		if on:
			_face.draw_circle(c, r * 0.50, Color(0.25, 0.95, 0.85, 0.30))
		var tex_size := r * 1.92
		var tex_rect := Rect2(c.x - tex_size * 0.5, c.y - tex_size * 0.5, tex_size, tex_size)
		var mod := Color(1.15, 1.15, 1.05, 1.0) if on else Color(0.95, 0.95, 0.95, 0.96)
		_face.draw_texture_rect(_free_play_texture, tex_rect, false, mod)
	else:
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
	for i in 8:
		var a := TAU * i / 8.0 + _aura_phase * 0.35
		var d := Vector2(cos(a), sin(a))
		_face.draw_line(c + d * (r * 0.82), c + d * (r * 0.96), ink, 3.0, true)
