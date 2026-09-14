class_name InstrumentSwitcher
extends Control
## Nút Chuyển Đổi Nhạc Cụ Trực Tiếp (Tính Năng 2).
##
## Cho phép bé chuyển đổi tức thì giữa 5 âm sắc nhạc cụ:
##   0. Theo Chương (Auto): Giọng thú + Nhạc cụ mộc của chương đang mở
##   1. Giọng Thú (Animals): 7 muông thú rừng xanh
##   2. Sáo Trúc (Flute): Thuần sáo trúc mộc Chương 1
##   3. Kalimba: Thuần phím gõ kim loại mộc Chương 2
##   4. Chuông Gió (Chimes): Thuần chuông pha lê Chương 3
##
## Tương tác:
##   - Chạm đơn: Xoay vòng đổi sang nhạc cụ tiếp theo + phát nốt preview + nhún nảy đàn hồi.
##   - Chạm nút khay / giữ: Bung mở khay 5 nhạc cụ sang bên trái để chọn trực tiếp.
##   - Tự động đóng khay sau 4 giây không chạm để không che khuất cuốn sách 3D.

signal mode_selected(mode: int)

const MAIN_SIZE := Vector2(96.0, 96.0)
## Apple Kids: mỗi nút dock >= 88pt để bé chạm trúng.
const DOCK_BTN_SIZE := Vector2(88.0, 88.0)
const DOCK_GAP := 10.0
## P1: 4s che sách quá lâu — 2s đủ chọn, tự gập nhanh.
const AUTO_CLOSE_DELAY := 2.0
## P1: giữ 0.5s mới bung khay; tap thường chỉ xoay mode, hết che sách oan.
const LONG_PRESS_SECONDS := 0.5

const ICONS := [
	preload("res://assets/art/ui_inst_auto.png"),
	preload("res://assets/art/ui_inst_animals.png"),
	preload("res://assets/art/ui_inst_flute.png"),
	preload("res://assets/art/ui_inst_kalimba.png"),
	preload("res://assets/art/ui_inst_chimes.png"),
]

var _current_mode: int = 0
var _dock_open: bool = false
var _auto_close_timer: float = 0.0

var _main_btn: Button
var _main_face: Control
var _dock: Control
var _dock_buttons: Array[Button] = []
var _floating_label: PanelContainer
var _label_text: Label
var _label_tween: Tween
var _bounce_tween: Tween

var _aura_angle: float = 0.0
var _press_held: float = -1.0
var _long_press_fired: bool = false


func _ready() -> void:
	custom_minimum_size = MAIN_SIZE
	size = MAIN_SIZE
	mouse_filter = Control.MOUSE_FILTER_PASS

	_build_ui()

	if is_instance_valid(GameState):
		GameState.instrument_mode_changed.connect(_on_game_state_mode_changed)
		GameState.free_play_changed.connect(_on_free_play_changed)
		_current_mode = GameState.instrument_mode
		visible = not GameState.free_play
	_update_visuals()


func _process(delta: float) -> void:
	# Xoay nhẹ vòng hào quang phát sáng
	_aura_angle = fmod(_aura_angle + delta * 1.8, TAU)
	if _main_face != null:
		_main_face.queue_redraw()

	# P1: đo giữ nút chính để phân biệt tap / long-press.
	if _press_held >= 0.0:
		_press_held += delta
		if not _long_press_fired and _press_held >= LONG_PRESS_SECONDS:
			_long_press_fired = true
			open_dock()

	# Đếm thời gian tự động gập khay
	if _dock_open:
		_auto_close_timer -= delta
		if _auto_close_timer <= 0.0:
			close_dock()


func _build_ui() -> void:
	# 1. Khay mở rộng 5 nhạc cụ (bung sang bên trái nút chính)
	_dock = Control.new()
	_dock.name = "Dock"
	_dock.mouse_filter = Control.MOUSE_FILTER_PASS
	_dock.visible = false
	_dock.modulate = Color(1, 1, 1, 0)
	_dock.position = Vector2.ZERO
	add_child(_dock)

	var total_dock_w := 5 * DOCK_BTN_SIZE.x + 4 * DOCK_GAP + 24.0
	var dock_h := DOCK_BTN_SIZE.y + 16.0
	_dock.size = Vector2(total_dock_w, dock_h)
	# Đặt khay nằm về phía bên trái của nút chính
	_dock.position = Vector2(-total_dock_w - 12.0, (MAIN_SIZE.y - dock_h) * 0.5)

	# Nền khay gỗ sồi chạm khắc 3D
	var dock_bg := Control.new()
	dock_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	dock_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dock.add_child(dock_bg)
	dock_bg.draw.connect(func(): _draw_dock_bg(dock_bg))

	# 5 nút chọn trực tiếp trong khay
	for i in 5:
		var btn := Button.new()
		btn.name = "DockBtn%d" % i
		btn.custom_minimum_size = DOCK_BTN_SIZE
		btn.size = DOCK_BTN_SIZE
		btn.position = Vector2(12.0 + i * (DOCK_BTN_SIZE.x + DOCK_GAP), 8.0)
		btn.focus_mode = Control.FOCUS_NONE
		btn.flat = true

		var face := Control.new()
		face.set_anchors_preset(Control.PRESET_FULL_RECT)
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(face)
		var mode_idx := i
		face.draw.connect(func(): _draw_dock_btn_face(face, mode_idx))

		btn.pressed.connect(func(): _on_dock_btn_pressed(mode_idx))
		_dock.add_child(btn)
		_dock_buttons.append(btn)

	# 2. Nút chính
	_main_btn = Button.new()
	_main_btn.name = "MainButton"
	_main_btn.custom_minimum_size = MAIN_SIZE
	_main_btn.size = MAIN_SIZE
	_main_btn.position = Vector2.ZERO
	_main_btn.pivot_offset = MAIN_SIZE * 0.5
	_main_btn.focus_mode = Control.FOCUS_NONE
	_main_btn.flat = true
	add_child(_main_btn)

	_main_face = Control.new()
	_main_face.set_anchors_preset(Control.PRESET_FULL_RECT)
	_main_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_main_btn.add_child(_main_face)
	_main_face.draw.connect(_draw_main_face)

	# P1: tap = xoay mode, long-press 0.5s = bung khay. Dùng button_down/up
	# để đo thời gian giữ thay vì pressed (pressed bung khay ngay cả khi
	# bé chỉ muốn đổi 1 nấc).
	_main_btn.button_down.connect(_on_main_button_down)
	_main_btn.button_up.connect(_on_main_button_up)

	# 3. Nhãn nổi hiển thị tên nhạc cụ bằng tiếng Việt (floating popup pill)
	_floating_label = PanelContainer.new()
	_floating_label.name = "FloatingLabel"
	_floating_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_floating_label.visible = false
	_floating_label.modulate = Color(1, 1, 1, 0)
	
	var pill_box := StyleBoxFlat.new()
	pill_box.bg_color = Color(0.12, 0.08, 0.05, 0.92)
	pill_box.set_corner_radius_all(14)
	pill_box.set_border_width_all(2)
	pill_box.border_color = Color("#E8D9A0")
	pill_box.content_margin_left = 14.0
	pill_box.content_margin_right = 14.0
	pill_box.content_margin_top = 6.0
	pill_box.content_margin_bottom = 6.0
	_floating_label.add_theme_stylebox_override("panel", pill_box)

	_label_text = Label.new()
	_label_text.add_theme_color_override("font_color", Color("#FFF8E7"))
	_label_text.add_theme_font_size_override("font_size", 16)
	_floating_label.add_child(_label_text)
	add_child(_floating_label)


func _draw_dock_bg(target: Control) -> void:
	var rect := Rect2(Vector2.ZERO, target.size)
	# Drop shadow
	target.draw_rect(Rect2(rect.position.x, rect.position.y + 4.0, rect.size.x, rect.size.y), Color(0, 0, 0, 0.40), true, -1, false)
	# Nền gỗ sồi sẫm bo tròn
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.10, 0.07, 0.95)
	style.set_corner_radius_all(24)
	style.set_border_width_all(2)
	style.border_color = Color(0.85, 0.72, 0.38, 0.85)
	style.draw(target.get_canvas_item(), rect)


func _draw_dock_btn_face(face: Control, mode_idx: int) -> void:
	var c := face.size * 0.5
	var r := minf(face.size.x, face.size.y) * 0.5 - 2.0
	var is_active := (mode_idx == _current_mode)
	var info: Dictionary = Notes.mode_info(mode_idx)
	var col: Color = info.get("color", Color.WHITE)

	# Vòng highlight nếu đang chọn
	if is_active:
		face.draw_circle(c, r + 2.0, Color(col.r, col.g, col.b, 0.35))
		face.draw_arc(c, r + 1.0, 0.0, TAU, 32, col, 3.0, true)

	# Nền nút tròn
	face.draw_circle(c, r, Color(0.20, 0.14, 0.10, 0.92))
	face.draw_arc(c, r, 0.0, TAU, 32, Color(0.70, 0.58, 0.32, 0.65), 1.5, true)

	# Vẽ icon nhạc cụ
	if mode_idx < ICONS.size() and ICONS[mode_idx] != null:
		var tex_size := r * 1.4
		var tex_rect := Rect2(c.x - tex_size * 0.5, c.y - tex_size * 0.5, tex_size, tex_size)
		face.draw_texture_rect(ICONS[mode_idx], tex_rect, false)


func _draw_main_face() -> void:
	var c := _main_face.size * 0.5
	var r := minf(_main_face.size.x, _main_face.size.y) * 0.5 - 4.0
	var info: Dictionary = Notes.mode_info(_current_mode)
	var col: Color = info.get("color", Color("#E8D9A0"))

	# 1. Hào quang phát sáng huyền ảo xoay quanh nút
	var aura_points := 6
	for i in aura_points:
		var a := _aura_angle + TAU * float(i) / float(aura_points)
		var offset := Vector2(cos(a), sin(a)) * (r + 4.0)
		_main_face.draw_circle(c + offset, 3.5, Color(col.r, col.g, col.b, 0.40))

	_main_face.draw_arc(c, r + 3.0, 0.0, TAU, 36, Color(col.r, col.g, col.b, 0.35), 2.5, true)

	# 2. Drop shadow
	_main_face.draw_circle(c + Vector2(0, 4.0), r, Color(0, 0, 0, 0.45))

	# 3. Huy hiệu gỗ sồi chính
	_main_face.draw_circle(c, r, Color(0.18, 0.12, 0.08, 0.96))
	_main_face.draw_arc(c, r, 0.0, TAU, 36, Color(0.88, 0.76, 0.42, 0.95), 2.5, true)
	_main_face.draw_arc(c, r - 4.0, 0.0, TAU, 36, Color(col.r, col.g, col.b, 0.50), 1.5, true)

	# 4. Icon nhạc cụ active
	if _current_mode < ICONS.size() and ICONS[_current_mode] != null:
		var tex_size := r * 1.35
		var tex_rect := Rect2(c.x - tex_size * 0.5, c.y - tex_size * 0.5, tex_size, tex_size)
		_main_face.draw_texture_rect(ICONS[_current_mode], tex_rect, false)

	# 5. Dấu mũi tên nhỏ báo hiệu có thể bung khay
	var arrow_pos := c + Vector2(-r * 0.65, 0)
	var arrow_col := Color(1, 1, 1, 0.75 if _dock_open else 0.40)
	var flip := -1.0 if _dock_open else 1.0
	_main_face.draw_polygon([
		arrow_pos + Vector2(2.0 * flip, -5.0),
		arrow_pos + Vector2(-4.0 * flip, 0.0),
		arrow_pos + Vector2(2.0 * flip, 5.0)
	], [arrow_col])


func _on_main_button_down() -> void:
	_press_held = 0.0
	_long_press_fired = false


func _on_main_button_up() -> void:
	# Nhả trước 0.5s = tap: xoay 1 nấc, KHÔNG bung khay. Giữ đủ lâu đã
	# bung khay ở _process thì nhả chỉ reset timer, không xoay thêm.
	var was_long := _long_press_fired
	_press_held = -1.0
	_long_press_fired = false
	if _dock_open:
		_auto_close_timer = AUTO_CLOSE_DELAY
		return
	if not was_long:
		var next_mode := (_current_mode + 1) % Notes.mode_count()
		select_mode(next_mode)


func _on_main_button_pressed() -> void:
	# Giữ tương thích ngược nếu còn nối ở scene cũ: hành vi = tap.
	if _dock_open:
		close_dock()
	else:
		var next_mode := (_current_mode + 1) % Notes.mode_count()
		select_mode(next_mode)


func _on_dock_btn_pressed(mode_idx: int) -> void:
	select_mode(mode_idx)
	_auto_close_timer = 2.0 # Đóng nhanh sau khi đã chọn xong


func select_mode(new_mode: int) -> void:
	_current_mode = new_mode
	if is_instance_valid(GameState):
		GameState.instrument_mode = new_mode

	# Phản hồi âm thanh nốt đặc trưng của nhạc cụ
	AudioDirector.play_mode_preview(new_mode)

	_animate_squash_and_stretch()
	_show_floating_label()
	_update_visuals()
	mode_selected.emit(new_mode)


func _on_game_state_mode_changed(mode: int) -> void:
	if _current_mode != mode:
		_current_mode = mode
		_update_visuals()


func _on_free_play_changed(enabled: bool) -> void:
	# Free Play đã có FreePlayTopBar (4 slot lớn) ở giữa trên.
	# Ẩn switcher nhỏ góc phải để còn đúng 1 bộ đổi nhạc cụ trên màn hình.
	visible = not enabled


func _update_visuals() -> void:
	if _main_face != null:
		_main_face.queue_redraw()
	for btn in _dock_buttons:
		var face: Control = btn.get_child(0) as Control
		if face != null:
			face.queue_redraw()


func _animate_squash_and_stretch() -> void:
	if _bounce_tween != null and _bounce_tween.is_running():
		_bounce_tween.kill()

	_bounce_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_main_btn.scale = Vector2(0.82, 1.18)
	_bounce_tween.tween_property(_main_btn, "scale", Vector2(1.12, 0.90), 0.12)
	_bounce_tween.tween_property(_main_btn, "scale", Vector2(1.0, 1.0), 0.18)


func _show_floating_label() -> void:
	var info: Dictionary = Notes.mode_info(_current_mode)
	var mode_name: String = info.get("name", "")
	_label_text.text = mode_name

	# Căn chỉnh vị trí nhãn nổi phía trên nút
	_floating_label.reset_size()
	var label_w := _floating_label.get_minimum_size().x
	_floating_label.position = Vector2(
		(MAIN_SIZE.x - label_w) * 0.5,
		-42.0
	)
	_floating_label.visible = true

	if _label_tween != null and _label_tween.is_running():
		_label_tween.kill()

	_label_tween = create_tween()
	_label_tween.tween_property(_floating_label, "modulate:a", 1.0, 0.15)
	_label_tween.tween_interval(1.2)
	_label_tween.tween_property(_floating_label, "modulate:a", 0.0, 0.35)
	_label_tween.tween_callback(func(): _floating_label.visible = false)


func open_dock() -> void:
	if _dock_open:
		_auto_close_timer = AUTO_CLOSE_DELAY
		return

	_dock_open = true
	_auto_close_timer = AUTO_CLOSE_DELAY
	_dock.visible = true

	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var target_x := -_dock.size.x - 12.0
	_dock.position.x = -MAIN_SIZE.x
	_dock.modulate.a = 0.0
	tween.tween_property(_dock, "position:x", target_x, 0.28)
	tween.tween_property(_dock, "modulate:a", 1.0, 0.22)
	_main_face.queue_redraw()


func close_dock() -> void:
	if not _dock_open:
		return

	_dock_open = false
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(_dock, "position:x", -MAIN_SIZE.x, 0.18)
	tween.tween_property(_dock, "modulate:a", 0.0, 0.18)
	tween.chain().tween_callback(func(): _dock.visible = false)
	_main_face.queue_redraw()
