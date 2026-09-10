class_name MainMenu
extends PauseOverlay
## Màn hình Menu Khởi Đầu / Bìa Sách 'Rừng Nhạc' (FTUE) khớp 100% mock-main-menu.jpeg.
##
## Thiết kế theo chuẩn thẩm mỹ Sách Tranh Nổi 3D:
## - Toàn cảnh bàn gỗ rừng ma thuật với cuốn sách da dập chữ 'RỪNG NHẠC' mạ vàng ở trung tâm
## - Chú Phù Thủy và Bạn Sư Tử nhỏ đứng vẫy tay trên bàn gỗ rêu phong
## - Nút Khóa Son 'CHƠI' khổng lồ bằng gỗ mạ vàng với hào quang tỏa sáng nhịp nhàng
## - Nút 'Levels' (ngôi sao gỗ) ở góc trên bên trái
## - Nút 'Phụ Huynh' (mặt trăng gỗ) ở góc trên bên phải
## - Đom đóm và nốt nhạc vàng bay bổng lơ lửng quanh cuốn sách

signal play_pressed
signal levels_pressed
signal parent_gate_requested

var _bg_texture: Texture2D
var _play_btn: Button
var _play_glow: Control
var _levels_btn: Button
var _parent_btn: Button
var _time: float = 0.0


func _ready() -> void:
	super()
	layer = 25
	_build()
	_set_controls_visible(false)


func _build() -> void:
	_add_backdrop(Color(0.02, 0.04, 0.03, 0.98))

	# Phông nền toàn cảnh diorama Bìa Sách từ mock-main-menu.jpeg
	if ResourceLoader.exists("res://docs/mock-main-menu.jpeg"):
		_bg_texture = load("res://docs/mock-main-menu.jpeg")

	var bg_rect := TextureRect.new()
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _bg_texture != null:
		bg_rect.texture = _bg_texture
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(bg_rect)

	# Lớp hiệu ứng hạt đom đóm bay lơ lửng
	var fireflies := FireflyOverlay.new()
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fireflies)

	# --- 1. NÚT CHƠI (KHÓA SON KHỔNG LỒ) ---
	# Tọa độ tương đối trên màn hình 16:9: X ~ 67.5% - 84.5%, Y ~ 48% - 79%
	var play_container := Control.new()
	play_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	play_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(play_container)

	_play_glow = Control.new()
	_play_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	_play_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	play_container.add_child(_play_glow)

	_play_btn = Button.new()
	_play_btn.anchor_left = 0.672
	_play_btn.anchor_top = 0.475
	_play_btn.anchor_right = 0.846
	_play_btn.anchor_bottom = 0.795
	_play_btn.focus_mode = Control.FOCUS_NONE
	_play_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_play_btn.flat = true

	# Style viền phát sáng nhẹ khi hover/press
	var play_empty := StyleBoxEmpty.new()
	_play_btn.add_theme_stylebox_override("normal", play_empty)
	_play_btn.add_theme_stylebox_override("hover", play_empty)
	_play_btn.add_theme_stylebox_override("pressed", play_empty)
	_play_btn.add_theme_stylebox_override("focus", play_empty)

	_play_btn.pressed.connect(_on_play_pressed)
	play_container.add_child(_play_btn)

	# Hiệu ứng nhún nhảy & hào quang phát sáng mời gọi bé bấm nút CHƠI
	var play_glow_draw := PlayButtonAura.new(_play_btn)
	play_glow_draw.set_anchors_preset(Control.PRESET_FULL_RECT)
	play_glow_draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	play_container.add_child(play_glow_draw)

	# --- 2. NÚT LEVELS (NGÔI SAO GỖ GÓC TRÁI TRÊN) ---
	# Tọa độ tương đối: X ~ 2.2% - 10.5%, Y ~ 4.2% - 19.5%
	_levels_btn = Button.new()
	_levels_btn.anchor_left = 0.022
	_levels_btn.anchor_top = 0.042
	_levels_btn.anchor_right = 0.105
	_levels_btn.anchor_bottom = 0.195
	_levels_btn.focus_mode = Control.FOCUS_NONE
	_levels_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_levels_btn.flat = true
	_levels_btn.add_theme_stylebox_override("normal", play_empty)
	_levels_btn.add_theme_stylebox_override("hover", play_empty)
	_levels_btn.add_theme_stylebox_override("pressed", play_empty)
	_levels_btn.pressed.connect(_on_levels_pressed)
	add_child(_levels_btn)

	# --- 3. NÚT PHỤ HUYNH (MẶT TRĂNG GỖ GÓC PHẢI TRÊN) ---
	# Tọa độ tương đối: X ~ 89.5% - 97.8%, Y ~ 4.2% - 19.5%
	_parent_btn = Button.new()
	_parent_btn.anchor_left = 0.895
	_parent_btn.anchor_top = 0.042
	_parent_btn.anchor_right = 0.978
	_parent_btn.anchor_bottom = 0.195
	_parent_btn.focus_mode = Control.FOCUS_NONE
	_parent_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_parent_btn.flat = true
	_parent_btn.add_theme_stylebox_override("normal", play_empty)
	_parent_btn.add_theme_stylebox_override("hover", play_empty)
	_parent_btn.add_theme_stylebox_override("pressed", play_empty)
	_parent_btn.pressed.connect(_on_parent_pressed)
	add_child(_parent_btn)


func _on_play_pressed() -> void:
	if AudioDirector != null:
		AudioDirector.play_sfx("page_turn")
	close_overlay()
	play_pressed.emit()


func _on_levels_pressed() -> void:
	if AudioDirector != null:
		AudioDirector.play_sfx("star_ting")
	levels_pressed.emit()


func _on_parent_pressed() -> void:
	if AudioDirector != null:
		AudioDirector.play_sfx("wood_tap")
	parent_gate_requested.emit()


## Node vẽ hiệu ứng hào quang vàng tỏa sáng xung quanh nút Khóa Son
class PlayButtonAura extends Control:
	var _target_btn: Button
	var _time: float = 0.0

	func _init(target: Button) -> void:
		_target_btn = target

	func _process(delta: float) -> void:
		_time += delta
		queue_redraw()

	func _draw() -> void:
		if _target_btn == null or not _target_btn.is_visible_in_tree():
			return
		var rect := _target_btn.get_global_rect()
		var center := rect.get_center()
		var radius := minf(rect.size.x, rect.size.y) * 0.52
		var pulse := 0.5 + 0.5 * sin(_time * 3.5)

		# Hào quang vàng mềm mại nhấp nháy thu hút sự chú ý của bé
		draw_circle(center, radius * (1.0 + 0.08 * pulse), Color(1.0, 0.88, 0.45, 0.16 + 0.12 * pulse))
		draw_arc(center, radius * (1.0 + 0.05 * pulse), 0, TAU, 36, Color(1.0, 0.95, 0.65, 0.35 + 0.25 * pulse), 3.0, true)


## Lớp vẽ hạt đom đóm thần tiên lơ lửng trong không gian rừng
class FireflyOverlay extends Control:
	var _fireflies: Array[Dictionary] = []
	var _time: float = 0.0

	func _ready() -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = 42
		for i in 18:
			_fireflies.append({
				"pos": Vector2(rng.randf_range(0.05, 0.95), rng.randf_range(0.08, 0.88)),
				"speed": rng.randf_range(0.6, 1.8),
				"phase": rng.randf_range(0, TAU),
				"radius": rng.randf_range(2.0, 4.5),
			})

	func _process(delta: float) -> void:
		_time += delta
		queue_redraw()

	func _draw() -> void:
		var sz := size
		for ff in _fireflies:
			var sway_x := sin(_time * ff["speed"] + ff["phase"]) * 14.0
			var sway_y := cos(_time * ff["speed"] * 0.8 + ff["phase"]) * 10.0
			var p := Vector2(ff["pos"].x * sz.x + sway_x, ff["pos"].y * sz.y + sway_y)
			var a := 0.35 + 0.35 * sin(_time * ff["speed"] * 2.2 + ff["phase"])
			draw_circle(p, ff["radius"], Color(1.0, 0.95, 0.6, a))
			draw_circle(p, ff["radius"] * 2.2, Color(1.0, 0.85, 0.3, a * 0.35))
