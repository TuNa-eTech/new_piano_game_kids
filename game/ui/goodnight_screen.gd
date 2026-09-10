class_name GoodnightScreen
extends PauseOverlay
## Màn Chúc Bé Ngủ Ngon — nghi thức kết thúc giờ chơi nhẹ nhàng, êm ái.
##
## Khi hết giờ hẹn giờ (15 hay 30 phút), màn hình này xuất hiện:
## - Khu rừng chìm vào màn đêm êm dịu
## - Chú phù thủy nhỏ ngủ say dưới chăn lá
## - Bàn phím bên dưới tắt sáng, nhạc chuyển sang âm sắc ru ngủ
## - Nút 'Đánh Thức Khu Rừng' BẮT BUỘC phải qua Cổng Phụ Huynh (ParentalGate)

signal parental_unlock_requested

var _lullaby_player: AudioStreamPlayer


func _ready() -> void:
	super()
	layer = 18
	_build()
	_set_controls_visible(false)


func _build() -> void:
	_add_backdrop(Color(0.01, 0.03, 0.07, 0.96))

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 440)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.12, 0.20, 0.98) # Xanh đêm huyền ảo
	panel_style.border_color = Color(0.85, 0.75, 0.42, 0.85) # Viền trăng vàng
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(28)
	panel_style.shadow_color = Color(0, 0, 0, 0.6)
	panel_style.shadow_size = 24
	panel_style.content_margin_left = 40
	panel_style.content_margin_right = 40
	panel_style.content_margin_top = 36
	panel_style.content_margin_bottom = 36
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 24)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	# Biểu tượng mặt trăng & sao
	var moon_icon := Label.new()
	moon_icon.text = "🌙 ✨ 💤"
	moon_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	moon_icon.add_theme_font_size_override("font_size", 42)
	vbox.add_child(moon_icon)

	# Lời chúc ngủ ngon
	var message := Label.new()
	message.text = "Khu rừng đã ngủ say rồi.\nChúc bé ngủ ngon và mơ những giấc mơ đẹp!"
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 22)
	message.add_theme_color_override("font_color", Color(0.95, 0.92, 0.84))
	vbox.add_child(message)

	# Gợi ý nhẹ nhàng
	var hint := Label.new()
	hint.text = "Các bạn thú và chú Phù Thủy Nhỏ đang say giấc nồng.\nHẹn gặp lại bé vào ngày mai nhé!"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 15)
	hint.add_theme_color_override("font_color", Color(0.65, 0.72, 0.85))
	vbox.add_child(hint)

	# Nút dành cho phụ huynh (muốn đánh thức để chơi tiếp)
	var unlock_btn := Button.new()
	unlock_btn.text = "Đánh Thức Khu Rừng (Dành Cho Bố Mẹ)"
	unlock_btn.custom_minimum_size = Vector2(300, 46)
	unlock_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.18, 0.26, 0.38, 0.9)
	btn_style.border_color = Color(0.50, 0.62, 0.78)
	btn_style.set_border_width_all(2)
	btn_style.set_corner_radius_all(23)
	unlock_btn.add_theme_stylebox_override("normal", btn_style)
	unlock_btn.add_theme_stylebox_override("hover", btn_style)
	unlock_btn.add_theme_stylebox_override("pressed", btn_style)
	unlock_btn.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0))
	unlock_btn.pressed.connect(_on_unlock_pressed)
	vbox.add_child(unlock_btn)


func _on_unlock_pressed() -> void:
	# Yêu cầu vượt qua Cổng Phụ Huynh mới được mở!
	parental_unlock_requested.emit()
