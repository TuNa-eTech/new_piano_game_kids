class_name ParentalCorner
extends PauseOverlay
## Góc Phụ Huynh & Cài Đặt — không gian thiết lập dành riêng cho cha mẹ.
##
## Cung cấp:
## - Thanh trượt chỉnh âm lượng tổng và nhạc nền
## - Núm chọn hẹn giờ ngủ: Tắt / 15 phút / 30 phút
## - Bật/tắt chế độ nhạc ru ngủ

signal bedtime_timer_changed(minutes: int)

var _volume_slider: HSlider
var _timer_buttons: Array[Button] = []
var _selected_minutes: int = 0


func _ready() -> void:
	super()
	layer = 15
	_build()
	_set_controls_visible(false)


static var _desk_tex: Texture2D = null
static var _dial_tex: Texture2D = null
var _dial_rect: TextureRect

func _build() -> void:
	if _desk_tex == null and ResourceLoader.exists("res://assets/art/parental_wood_desk.png"):
		_desk_tex = load("res://assets/art/parental_wood_desk.png")
	if _dial_tex == null and ResourceLoader.exists("res://assets/art/dial_timer_wood.png"):
		_dial_tex = load("res://assets/art/dial_timer_wood.png")

	_add_backdrop(Color(0.02, 0.04, 0.08, 0.92))

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 480)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.16, 0.10, 0.06, 0.98) # Gỗ sồi nâu ấm
	panel_style.border_color = Color(0.78, 0.62, 0.28, 0.95) # Viền đồng mạ vàng
	panel_style.set_border_width_all(4)
	panel_style.set_corner_radius_all(24)
	panel_style.shadow_color = Color(0, 0, 0, 0.5)
	panel_style.shadow_size = 20
	panel_style.shadow_offset = Vector2(0, 10)
	panel_style.content_margin_left = 36
	panel_style.content_margin_right = 36
	panel_style.content_margin_top = 32
	panel_style.content_margin_bottom = 32
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	if _desk_tex != null:
		var desk_bg := TextureRect.new()
		desk_bg.texture = _desk_tex
		desk_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		desk_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		desk_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		desk_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		desk_bg.modulate = Color(1.0, 1.0, 1.0, 0.40)
		panel.add_child(desk_bg)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 24)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	# Tiêu đề
	var title := Label.new()
	title.text = "GÓC PHỤ HUYNH & CÀI ĐẶT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.96, 0.86, 0.58))
	vbox.add_child(title)

	# --- Khu vực 1: Âm lượng ---
	var vol_row := HBoxContainer.new()
	vol_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vol_row.add_theme_constant_override("separation", 16)
	vbox.add_child(vol_row)

	var vol_label := Label.new()
	vol_label.text = "Âm Lượng:"
	vol_label.custom_minimum_size = Vector2(120, 0)
	vol_label.add_theme_font_size_override("font_size", 16)
	vol_label.add_theme_color_override("font_color", Color(0.90, 0.88, 0.82))
	vol_row.add_child(vol_label)

	_volume_slider = HSlider.new()
	_volume_slider.custom_minimum_size = Vector2(320, 24)
	_volume_slider.min_value = 0.0
	_volume_slider.max_value = 1.0
	_volume_slider.step = 0.05
	_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	_volume_slider.value_changed.connect(_on_volume_changed)
	vol_row.add_child(_volume_slider)

	# --- Khu vực 2: Hẹn giờ đi ngủ ---
	var timer_section := VBoxContainer.new()
	timer_section.add_theme_constant_override("separation", 10)
	vbox.add_child(timer_section)

	var timer_title := Label.new()
	timer_title.text = "Hẹn Giờ Ngủ (Khóa Dịu Dàng Giờ Đi Ngủ 🌙):"
	timer_title.add_theme_font_size_override("font_size", 16)
	timer_title.add_theme_color_override("font_color", Color(0.90, 0.88, 0.82))
	timer_section.add_child(timer_title)

	if _dial_tex != null:
		var dial_center := CenterContainer.new()
		_dial_rect = TextureRect.new()
		_dial_rect.texture = _dial_tex
		_dial_rect.custom_minimum_size = Vector2(120, 90)
		_dial_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_dial_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_dial_rect.pivot_offset = Vector2(60, 45)
		dial_center.add_child(_dial_rect)
		timer_section.add_child(dial_center)

	var timer_btn_row := HBoxContainer.new()
	timer_btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	timer_btn_row.add_theme_constant_override("separation", 16)
	timer_section.add_child(timer_btn_row)

	var options := [
		{"label": "Tắt", "val": 0},
		{"label": "15 Phút", "val": 15},
		{"label": "30 Phút", "val": 30}
	]

	for opt in options:
		var btn := Button.new()
		btn.text = opt["label"]
		btn.custom_minimum_size = Vector2(130, 44)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_timer_selected.bind(opt["val"], btn))
		timer_btn_row.add_child(btn)
		_timer_buttons.append(btn)

	_update_timer_button_styles()

	# Lời nhắn giáo dục cho cha mẹ
	var note := Label.new()
	note.text = "★ Thang âm ngũ cung tự nhiên giúp bé gõ bất kỳ phím nào cũng ngân vang hài hòa."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_font_size_override("font_size", 13)
	note.add_theme_color_override("font_color", Color(0.65, 0.75, 0.68))
	vbox.add_child(note)

	# Nút đóng
	var close_btn := Button.new()
	close_btn.text = "Đóng & Tiếp Tục Chơi"
	close_btn.custom_minimum_size = Vector2(220, 46)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var close_style := StyleBoxFlat.new()
	close_style.bg_color = Color(0.24, 0.52, 0.38, 0.95)
	close_style.set_corner_radius_all(23)
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.add_theme_stylebox_override("hover", close_style)
	close_btn.add_theme_stylebox_override("pressed", close_style)
	close_btn.add_theme_color_override("font_color", Color.WHITE)
	close_btn.pressed.connect(close_overlay)
	vbox.add_child(close_btn)


func _on_volume_changed(val: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(val, 0.0001)))


func _on_timer_selected(minutes: int, _active_btn: Button) -> void:
	_selected_minutes = minutes
	_update_timer_button_styles()
	bedtime_timer_changed.emit(minutes)
	if _dial_rect != null:
		var target_rot := 0.0
		match minutes:
			15: target_rot = 0.52
			30: target_rot = 1.05
			_: target_rot = 0.0
		var tw := create_tween().bind_node(self)
		tw.tween_property(_dial_rect, "rotation", target_rot, 0.22) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _update_timer_button_styles() -> void:
	for btn in _timer_buttons:
		var is_active := (btn.text == "Tắt" and _selected_minutes == 0) or \
						 (btn.text == "15 Phút" and _selected_minutes == 15) or \
						 (btn.text == "30 Phút" and _selected_minutes == 30)

		var style := StyleBoxFlat.new()
		style.set_corner_radius_all(14)
		if is_active:
			style.bg_color = Color(0.78, 0.62, 0.28, 0.95)
			style.border_color = Color(1.0, 0.90, 0.60)
			style.set_border_width_all(2)
			btn.add_theme_color_override("font_color", Color(0.15, 0.10, 0.05))
		else:
			style.bg_color = Color(0.24, 0.15, 0.09, 0.85)
			style.border_color = Color(0.45, 0.35, 0.20)
			style.set_border_width_all(1)
			btn.add_theme_color_override("font_color", Color(0.85, 0.82, 0.75))

		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
