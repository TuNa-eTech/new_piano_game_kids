class_name MainMenu
extends PauseOverlay
## Màn hình Menu Khởi Đầu / Bìa Sách 'Rừng Nhạc' (FTUE).
##
## Lần đầu tiên mở app, xuất hiện bìa sách cổ tích bọc da mạ vàng với:
## - Tên game 'RỪNG NHẠC' và nốt nhạc bay quanh
## - Chú phù thủy nhỏ vẫy tay chào bé
## - Nút 'CHƠI' khóa son khổng lồ kích thích khám phá
## - Nút 'Levels' (Bản đồ chương) và nút 'Phụ Huynh' (Cổng bảo vệ)

signal play_pressed
signal levels_pressed
signal parent_gate_requested


func _ready() -> void:
	super()
	layer = 25
	_build()
	_set_controls_visible(false)


func _build() -> void:
	_add_backdrop(Color(0.04, 0.08, 0.07, 0.96))

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(860, 520)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.14, 0.09, 0.05, 0.98) # Bìa da sồi nâu
	panel_style.border_color = Color(0.85, 0.72, 0.35, 0.98) # Viền mạ vàng
	panel_style.set_border_width_all(5)
	panel_style.set_corner_radius_all(32)
	panel_style.shadow_color = Color(0, 0, 0, 0.6)
	panel_style.shadow_size = 28
	panel_style.content_margin_left = 44
	panel_style.content_margin_right = 44
	panel_style.content_margin_top = 36
	panel_style.content_margin_bottom = 36
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 24)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	# Tiêu đề game mạ vàng
	var title := Label.new()
	title.text = "♫  RỪNG NHẠC  ♫"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(0.98, 0.88, 0.55))
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Cuốn Sách Tranh Nổi Biết Hát Của Bé"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.80, 0.85, 0.78))
	vbox.add_child(subtitle)

	# Nút CHƠI khổng lồ ở giữa
	var play_btn := Button.new()
	play_btn.text = "▶  CHƠI NGAY"
	play_btn.custom_minimum_size = Vector2(280, 72)
	play_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	play_btn.focus_mode = Control.FOCUS_NONE

	var play_style := StyleBoxFlat.new()
	play_style.bg_color = Color(0.85, 0.68, 0.25, 0.98) # Vàng rực rỡ
	play_style.border_color = Color(1.0, 0.95, 0.75)
	play_style.set_border_width_all(3)
	play_style.set_corner_radius_all(36)
	play_style.shadow_color = Color(0.9, 0.7, 0.1, 0.4)
	play_style.shadow_size = 12

	play_btn.add_theme_stylebox_override("normal", play_style)
	play_btn.add_theme_stylebox_override("hover", play_style)
	play_btn.add_theme_stylebox_override("pressed", play_style)
	play_btn.add_theme_font_size_override("font_size", 24)
	play_btn.add_theme_color_override("font_color", Color(0.18, 0.12, 0.04))
	play_btn.pressed.connect(_on_play_pressed)
	vbox.add_child(play_btn)

	# Hàng nút phụ bên dưới
	var bottom_row := HBoxContainer.new()
	bottom_row.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_row.add_theme_constant_override("separation", 32)
	vbox.add_child(bottom_row)

	# Nút Levels
	var levels_btn := Button.new()
	levels_btn.text = "★ Bản Đồ Chương"
	levels_btn.custom_minimum_size = Vector2(180, 44)
	levels_btn.focus_mode = Control.FOCUS_NONE
	var sub_style := StyleBoxFlat.new()
	sub_style.bg_color = Color(0.24, 0.16, 0.10, 0.9)
	sub_style.border_color = Color(0.55, 0.45, 0.28)
	sub_style.set_border_width_all(2)
	sub_style.set_corner_radius_all(22)
	levels_btn.add_theme_stylebox_override("normal", sub_style)
	levels_btn.add_theme_stylebox_override("hover", sub_style)
	levels_btn.add_theme_stylebox_override("pressed", sub_style)
	levels_btn.add_theme_color_override("font_color", Color(0.92, 0.90, 0.85))
	levels_btn.pressed.connect(func(): levels_pressed.emit())
	bottom_row.add_child(levels_btn)

	# Nút Phụ Huynh
	var parent_btn := Button.new()
	parent_btn.text = "🌙 Góc Phụ Huynh"
	parent_btn.custom_minimum_size = Vector2(180, 44)
	parent_btn.focus_mode = Control.FOCUS_NONE
	parent_btn.add_theme_stylebox_override("normal", sub_style)
	parent_btn.add_theme_stylebox_override("hover", sub_style)
	parent_btn.add_theme_stylebox_override("pressed", sub_style)
	parent_btn.add_theme_color_override("font_color", Color(0.92, 0.90, 0.85))
	parent_btn.pressed.connect(func(): parent_gate_requested.emit())
	bottom_row.add_child(parent_btn)


func _on_play_pressed() -> void:
	if AudioDirector != null:
		AudioDirector.play_sfx("page_turn")
	close_overlay()
	play_pressed.emit()
