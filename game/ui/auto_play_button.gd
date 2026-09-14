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

@onready var _accent := Color("#FFE566")


func _ready() -> void:
	toggle_mode = true
	focus_mode = Control.FOCUS_NONE
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
	on.bg_color = Color("#8C4E1E") # Gỗ sồi ấm áp sáng rực
	on.border_color = _accent
	on.shadow_color = Color(1.0, 0.85, 0.25, 0.5)
	on.shadow_size = 12

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
	GameState.auto_play_changed.connect(_on_auto_play_changed)
	button_pressed = GameState.auto_play


func _process(delta: float) -> void:
	if GameState.auto_play and _face != null:
		_aura_phase = fmod(_aura_phase + delta * 3.2, TAU)
		_face.queue_redraw()


func _on_button_down() -> void:
	if _anim_tween != null and _anim_tween.is_valid():
		_anim_tween.kill()
	_anim_tween = create_tween().set_parallel(true)
	_anim_tween.tween_property(self, "position:y", position.y + 6.0, 0.06).set_trans(Tween.TRANS_QUAD)
	_anim_tween.tween_property(self, "scale", Vector2(1.08, 0.90), 0.06).set_trans(Tween.TRANS_QUAD)


func _on_button_up() -> void:
	if _anim_tween != null and _anim_tween.is_valid():
		_anim_tween.kill()
	_anim_tween = create_tween().set_parallel(true)
	_anim_tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


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
	# Fix UI 7 nhóm: ink tắt 0.60 chìm trên nền gỗ tối — nâng lên 0.85.
	var ink := _accent if on else Color(1, 1, 1, 0.85)

	# 1. Vẽ biểu tượng Tam Giác Phát Nhạc (Play Symbol ▶) bên trái tâm
	var play_offset := Vector2(-r * 0.22, 0.0)
	var p1 := c + play_offset + Vector2(-r * 0.24, -r * 0.30)
	var p2 := c + play_offset + Vector2(-r * 0.24, r * 0.30)
	var p3 := c + play_offset + Vector2(r * 0.26, 0.0)

	var poly := PackedVector2Array([p1, p2, p3])
	if on:
		_face.draw_colored_polygon(poly, ink)
	else:
		_face.draw_polyline(PackedVector2Array([p1, p2, p3, p1]), ink, 3.5, true)

	# 2. Vẽ Nốt Nhạc (Musical Note ♪) nhỏ bên phải
	var note_c := c + Vector2(r * 0.28, r * 0.12)
	var head_r := r * 0.16
	if on:
		_face.draw_circle(note_c, head_r, ink)
	else:
		_face.draw_arc(note_c, head_r, 0.0, TAU, 16, ink, 3.0, true)

	# Thân nốt nhạc
	var stem_top := note_c + Vector2(head_r * 0.8, -r * 0.48)
	_face.draw_line(note_c + Vector2(head_r * 0.8, 0), stem_top, ink, 3.5, true)
	# Móc nốt nhạc
	_face.draw_line(stem_top, stem_top + Vector2(r * 0.20, r * 0.14), ink, 3.5, true)

	if not on:
		return

	# 3. Hào quang đom đóm vàng xoay lấp lánh (Starlight breathing aura)
	var pulse := 1.0 + 0.08 * sin(_aura_phase)
	for i in 8:
		var a := TAU * i / 8.0 + _aura_phase * 0.4
		var d := Vector2(cos(a), sin(a))
		var star_pos := c + d * (r * 0.82 * pulse)
		var star_color := Color(1.0, 0.95, 0.5, 0.65 + 0.35 * sin(_aura_phase + i))
		_face.draw_circle(star_pos, 2.5, star_color)
