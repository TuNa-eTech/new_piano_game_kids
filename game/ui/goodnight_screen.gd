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


static var _bg_night_tex: Texture2D = null
static var _wizard_sleep_tex: Texture2D = null

var _wizard_rect: TextureRect
var _sleep_tween: Tween


func _build() -> void:
	if _bg_night_tex == null and ResourceLoader.exists("res://assets/art/bg_night_twilight_forest.png"):
		_bg_night_tex = load("res://assets/art/bg_night_twilight_forest.png")
	if _wizard_sleep_tex == null and ResourceLoader.exists("res://assets/art/wizard_sleeping_leaves.png"):
		_wizard_sleep_tex = load("res://assets/art/wizard_sleeping_leaves.png")

	_add_backdrop(Color(0.01, 0.02, 0.05, 0.96))

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 480)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.09, 0.16, 0.98) # Xanh đêm sâu thẳm
	panel_style.border_color = Color(0.85, 0.75, 0.42, 0.85) # Viền trăng vàng
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(28)
	panel_style.shadow_color = Color(0, 0, 0, 0.65)
	panel_style.shadow_size = 24
	panel_style.content_margin_left = 36
	panel_style.content_margin_right = 36
	panel_style.content_margin_top = 28
	panel_style.content_margin_bottom = 28
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	# Nền rừng đêm pop-up 3D
	if _bg_night_tex != null:
		var bg_night_rect := TextureRect.new()
		bg_night_rect.texture = _bg_night_tex
		bg_night_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_night_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg_night_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg_night_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg_night_rect.modulate = Color(1.0, 1.0, 1.0, 0.45)
		panel.add_child(bg_night_rect)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	# Chú phù thủy nhỏ đắp chăn lá ngủ say
	if _wizard_sleep_tex != null:
		var wiz_center := CenterContainer.new()
		_wizard_rect = TextureRect.new()
		_wizard_rect.texture = _wizard_sleep_tex
		_wizard_rect.custom_minimum_size = Vector2(280, 195)
		_wizard_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_wizard_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_wizard_rect.pivot_offset = Vector2(140, 97)
		wiz_center.add_child(_wizard_rect)
		vbox.add_child(wiz_center)
		_start_breathing()
	else:
		var moon_icon := Label.new()
		moon_icon.text = "🌙 ✨ 💤"
		moon_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		moon_icon.add_theme_font_size_override("font_size", 42)
		vbox.add_child(moon_icon)

	# Lời chúc ngủ ngon
	var message := Label.new()
	message.text = "Khu rừng đã ngủ say rồi.\nChúc bé ngủ ngon và mơ những giấc mơ thật đẹp!"
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 20)
	message.add_theme_color_override("font_color", Color(0.95, 0.92, 0.84))
	vbox.add_child(message)

	# Gợi ý nhẹ nhàng
	var hint := Label.new()
	hint.text = "Các bạn thú và bé Phù Thủy Nhỏ đang say giấc nồng.\nHẹn gặp lại bé vào ngày mai nhé!"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.70, 0.78, 0.90))
	vbox.add_child(hint)

	# Nút dành cho phụ huynh
	var unlock_btn := Button.new()
	unlock_btn.text = "Đánh Thức Khu Rừng (Dành Cho Bố Mẹ)"
	unlock_btn.custom_minimum_size = Vector2(300, 44)
	unlock_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.18, 0.26, 0.38, 0.9)
	btn_style.border_color = Color(0.50, 0.62, 0.78)
	btn_style.set_border_width_all(2)
	btn_style.set_corner_radius_all(22)
	unlock_btn.add_theme_stylebox_override("normal", btn_style)
	unlock_btn.add_theme_stylebox_override("hover", btn_style)
	unlock_btn.add_theme_stylebox_override("pressed", btn_style)
	unlock_btn.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0))
	unlock_btn.pressed.connect(_on_unlock_pressed)
	vbox.add_child(unlock_btn)


func _start_breathing() -> void:
	if _wizard_rect == null:
		return
	if _sleep_tween != null and _sleep_tween.is_valid():
		_sleep_tween.kill()
	_sleep_tween = create_tween().bind_node(self).set_loops()
	_sleep_tween.tween_property(_wizard_rect, "scale", Vector2(1.03, 0.97), 1.8) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_sleep_tween.tween_property(_wizard_rect, "scale", Vector2(0.98, 1.02), 1.8) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_unlock_pressed() -> void:
	parental_unlock_requested.emit()
