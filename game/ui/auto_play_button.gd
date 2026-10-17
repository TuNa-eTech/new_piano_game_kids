class_name AutoPlayButton
extends Button
## Nút "Tự Động" (Auto-Play / Jukebox Mode).
##
## Khi bật:
## - Máy tự động gõ đàn theo đúng tiết tấu BPM của bài hát.
## - Cây thần nở hoa, dải lụa phát sáng, lời bài hát hiện trên bong bóng thoại.
## - Hết câu tự sang câu tiếp, hết bài tự mở rương ăn mừng và lật sang bài tiếp theo.
##
## Phong cách 2.5D xúc giác mộc mạc:
## - Nút tròn gỗ 96x96pt chuẩn Apple Kids.
## - Biểu tượng nút Play kết hợp Nốt Nhạc (▶♫).
## - Khi bật: Hào quang vàng kim lấp lánh (Breathing Starlight Aura).

const MIN_TOUCH_SIZE := 96.0

var _face: Control
var _anim_tween: Tween
var _aura_phase: float = 0.0
var _autoplay_tex: Texture2D

@onready var _accent := Color("#FFE566")


func _ready() -> void:
	toggle_mode = true
	focus_mode = Control.FOCUS_NONE
	flat = true
	if ResourceLoader.exists("res://assets/art/ui_btn_autoplay_wood.png"):
		_autoplay_tex = load("res://assets/art/ui_btn_autoplay_wood.png")
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
	GameState.auto_play_changed.connect(_on_auto_play_changed)
	button_pressed = GameState.auto_play


func _process(delta: float) -> void:
	if GameState.auto_play and _face != null:
		_aura_phase = fmod(_aura_phase + delta * 3.2, TAU)
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
	# P1 radio: bật Jukebox mà đang Chơi tự do thì Free tự tắt trong
	# GameState — thêm fairy_dust đã có + wood_tap để nghe ra chuyển mode.
	var killed_free := pressed_state and GameState.free_play
	AudioDirector.play_sfx("fairy_dust")
	GameState.auto_play = pressed_state
	if killed_free:
		AudioDirector.play_sfx("wood_tap")
	_face.queue_redraw()


func _on_auto_play_changed(enabled: bool) -> void:
	if button_pressed != enabled:
		button_pressed = enabled
	_face.queue_redraw()


func _draw_face() -> void:
	var c := _face.size * 0.5
	var r := minf(_face.size.x, _face.size.y) * 0.5
	var on := GameState.auto_play

	if _autoplay_tex != null:
		if on:
			_face.draw_circle(c, r * 0.50, Color(1.0, 0.90, 0.35, 0.32))
		var tex_s := r * 1.92
		var tex_rect := Rect2(c.x - tex_s * 0.5, c.y - tex_s * 0.5, tex_s, tex_s)
		var mod := Color(1.15, 1.12, 1.0, 1.0) if on else Color(0.95, 0.95, 0.95, 0.96)
		_face.draw_texture_rect(_autoplay_tex, tex_rect, false, mod)
	else:
		var ink := _accent if on else Color(1, 1, 1, 0.85)
		var play_offset := Vector2(-r * 0.22, 0.0)
		var p1 := c + play_offset + Vector2(-r * 0.24, -r * 0.30)
		var p2 := c + play_offset + Vector2(-r * 0.24, r * 0.30)
		var p3 := c + play_offset + Vector2(r * 0.26, 0.0)
		var poly := PackedVector2Array([p1, p2, p3])
		if on:
			_face.draw_colored_polygon(poly, ink)
		else:
			_face.draw_polyline(PackedVector2Array([p1, p2, p3, p1]), ink, 3.5, true)

	if not on:
		return

	# Hào quang đom đóm vàng xoay lấp lánh (Starlight breathing aura)
	var pulse := 1.0 + 0.08 * sin(_aura_phase)
	for i in 8:
		var a := TAU * i / 8.0 + _aura_phase * 0.4
		var d := Vector2(cos(a), sin(a))
		var star_pos := c + d * (r * 0.86 * pulse)
		var star_color := Color(1.0, 0.95, 0.5, 0.65 + 0.35 * sin(_aura_phase + i))
		_face.draw_circle(star_pos, 2.8, star_color)
