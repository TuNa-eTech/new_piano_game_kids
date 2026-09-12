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
	if ResourceLoader.exists("res://assets/art/ui_free_play.png"):
		_free_play_texture = load("res://assets/art/ui_free_play.png")
	custom_minimum_size = Vector2(MIN_TOUCH_SIZE, MIN_TOUCH_SIZE)
	pivot_offset = Vector2(MIN_TOUCH_SIZE * 0.5, MIN_TOUCH_SIZE * 0.5)

	var box := StyleBoxFlat.new()
	box.bg_color = Color("#2D1E16")
	box.set_corner_radius_all(48)
	box.set_border_width_all(4)
	box.border_color = Color("#8C5838")
	box.shadow_color = Color(0, 0, 0, 0.35)
	box.shadow_size = 6
	box.shadow_offset = Vector2(0, 5)

	var on := box.duplicate() as StyleBoxFlat
	on.bg_color = Color("#3A8848")
	on.border_color = _accent
	on.shadow_color = Color(0.95, 0.8, 0.2, 0.45)
	on.shadow_size = 10

	for state in ["normal", "hover", "focus"]:
		add_theme_stylebox_override(state, box)
	for state in ["pressed"]:
		add_theme_stylebox_override(state, on)

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
	_anim_tween = create_tween().set_parallel(true)
	# Lún 3D cơ học và nén hình học (Squash)
	_anim_tween.tween_property(self, "position:y", position.y + 6.0, 0.06).set_trans(Tween.TRANS_QUAD)
	_anim_tween.tween_property(self, "scale", Vector2(1.08, 0.90), 0.06).set_trans(Tween.TRANS_QUAD)


func _on_button_up() -> void:
	if _anim_tween != null and _anim_tween.is_valid():
		_anim_tween.kill()
	_anim_tween = create_tween().set_parallel(true)
	# Nảy lò xo đàn hồi (Elastic Recovery)
	_anim_tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_toggled(pressed_state: bool) -> void:
	AudioDirector.play_sfx("free_play_toggle")
	GameState.free_play = pressed_state
	_face.queue_redraw()


func _on_free_play_changed(enabled: bool) -> void:
	if button_pressed != enabled:
		button_pressed = enabled
	_face.queue_redraw()


func _draw_face() -> void:
	var c := _face.size * 0.5
	var r := minf(_face.size.x, _face.size.y) * 0.5
	var on := GameState.free_play
	var ink := _accent if on else Color(1, 1, 1, 0.55)

	if _free_play_texture != null:
		var tex_size := r * 1.15
		var tex_rect := Rect2(c.x - tex_size * 0.5, c.y - tex_size * 0.5, tex_size, tex_size)
		_face.draw_texture_rect(_free_play_texture, tex_rect, false, ink)
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
	for i in 6:
		var a := TAU * i / 6.0 - PI * 0.5
		var d := Vector2(cos(a), sin(a))
		_face.draw_line(c + d * (r * 0.76), c + d * (r * 0.92), ink, 3.0, true)
