class_name ParentalGate
extends PauseOverlay
## Cổng Phụ Huynh — thử thách bảo vệ phụ huynh theo chuẩn Apple Kids Category (Guideline 1.3).
##
## Bé mầm non chưa đọc được chữ nên không thể tự vượt qua câu đố:
## "Hãy chạm vào 3 quả dâu tây đỏ để mở khóa".
## Khi giải đúng 3 quả dâu, phát signal gate_unlocked và đóng cổng.

signal gate_unlocked

var _board: PanelContainer
var _fruit_container: HBoxContainer
var _progress_label: Label
var _tapped_strawberries: int = 0
var _fruit_order: Array[String] = []


func _ready() -> void:
	super()
	layer = 20
	_build()
	_set_controls_visible(false)


func _build() -> void:
	_add_backdrop(Color(0.02, 0.05, 0.04, 0.88))

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	_board = PanelContainer.new()
	_board.custom_minimum_size = Vector2(620, 360)

	var board_style := StyleBoxFlat.new()
	board_style.bg_color = Color(0.18, 0.11, 0.07, 0.96) # Gỗ sồi nâu đậm
	board_style.border_color = Color(0.78, 0.62, 0.28, 0.95) # Viền đồng mạ vàng
	board_style.set_border_width_all(4)
	board_style.set_corner_radius_all(24)
	board_style.shadow_color = Color(0, 0, 0, 0.45)
	board_style.shadow_size = 16
	board_style.shadow_offset = Vector2(0, 8)
	board_style.content_margin_left = 32
	board_style.content_margin_right = 32
	board_style.content_margin_top = 28
	board_style.content_margin_bottom = 28
	_board.add_theme_stylebox_override("panel", board_style)
	center.add_child(_board)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 18)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_board.add_child(vbox)

	# Tiêu đề
	var title := Label.new()
	title.text = "CỔNG PHỤ HUYNH"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.96, 0.86, 0.58))
	vbox.add_child(title)

	# Lời chỉ dẫn bằng chữ (chỉ người lớn biết đọc)
	var prompt := Label.new()
	prompt.text = "Hãy chạm vào 3 quả dâu tây đỏ để mở khóa"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 17)
	prompt.add_theme_color_override("font_color", Color(0.92, 0.90, 0.84))
	vbox.add_child(prompt)

	# Hàng 5 quả trái cây
	_fruit_container = HBoxContainer.new()
	_fruit_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_fruit_container.add_theme_constant_override("separation", 20)
	vbox.add_child(_fruit_container)

	# Nhãn tiến độ (0/3 dâu tây)
	_progress_label = Label.new()
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_progress_label.add_theme_font_size_override("font_size", 15)
	_progress_label.add_theme_color_override("font_color", Color(0.75, 0.70, 0.60))
	vbox.add_child(_progress_label)

	# Nút đóng X góc trên phải
	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(42, 42)
	close_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	close_btn.position = Vector2(_board.custom_minimum_size.x - 52, 10)
	var x_style := StyleBoxFlat.new()
	x_style.bg_color = Color(0.28, 0.16, 0.10, 0.9)
	x_style.border_color = Color(0.72, 0.56, 0.28)
	x_style.set_border_width_all(2)
	x_style.set_corner_radius_all(21)
	close_btn.add_theme_stylebox_override("normal", x_style)
	close_btn.add_theme_stylebox_override("hover", x_style)
	close_btn.add_theme_stylebox_override("pressed", x_style)
	close_btn.add_theme_color_override("font_color", Color.WHITE)
	close_btn.pressed.connect(close_overlay)
	_board.add_child(close_btn)

	_reset_fruits()


func open_overlay() -> void:
	_tapped_strawberries = 0
	_reset_fruits()
	super.open_overlay()


func _reset_fruits() -> void:
	_tapped_strawberries = 0
	_update_progress()

	for child in _fruit_container.get_children():
		child.queue_free()

	_fruit_order = ["strawberry", "strawberry", "strawberry", "banana", "apple"]
	_fruit_order.shuffle()

	for fruit_type in _fruit_order:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(80, 80)
		btn.focus_mode = Control.FOCUS_NONE

		var btn_style := StyleBoxFlat.new()
		btn_style.bg_color = Color(0.24, 0.15, 0.09, 0.92)
		btn_style.border_color = Color(0.55, 0.42, 0.22, 0.85)
		btn_style.set_border_width_all(2)
		btn_style.set_corner_radius_all(16)
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_stylebox_override("hover", btn_style)
		btn.add_theme_stylebox_override("pressed", btn_style)

		# Vẽ biểu tượng trái cây xúc giác
		var icon := Control.new()
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.set_meta("fruit_type", fruit_type)
		icon.draw.connect(_draw_fruit.bind(icon, fruit_type))
		btn.add_child(icon)

		btn.pressed.connect(_on_fruit_pressed.bind(btn, fruit_type))
		_fruit_container.add_child(btn)


func _draw_fruit(node: Control, type: String) -> void:
	var center := node.size * 0.5
	match type:
		"strawberry":
			# Quả dâu đỏ hình tim tròn
			node.draw_circle(center + Vector2(0, 4), 22.0, Color(0.92, 0.18, 0.24))
			# Đốm hạt dâu vàng
			node.draw_circle(center + Vector2(-6, 2), 2.0, Color(0.98, 0.85, 0.45))
			node.draw_circle(center + Vector2(6, 2), 2.0, Color(0.98, 0.85, 0.45))
			node.draw_circle(center + Vector2(0, 10), 2.0, Color(0.98, 0.85, 0.45))
			# Cuống lá xanh
			node.draw_circle(center + Vector2(-8, -14), 7.0, Color(0.25, 0.75, 0.35))
			node.draw_circle(center + Vector2(8, -14), 7.0, Color(0.25, 0.75, 0.35))
			node.draw_circle(center + Vector2(0, -16), 5.0, Color(0.20, 0.65, 0.30))
		"apple":
			# Quả táo xanh tròn
			node.draw_circle(center + Vector2(0, 2), 23.0, Color(0.38, 0.78, 0.25))
			# Cuống nâu
			node.draw_rect(Rect2(center.x - 2, center.y - 22, 4, 10), Color(0.45, 0.28, 0.15))
			# Chiếc lá xanh
			node.draw_circle(center + Vector2(7, -18), 6.0, Color(0.25, 0.85, 0.35))
		"banana":
			# Quả chuối vàng cong
			node.draw_arc(center + Vector2(-15, 0), 28.0, -0.4, 1.4, 24, Color(0.96, 0.82, 0.18), 14.0, true)
			# Đầu cuống chuối
			node.draw_circle(center + Vector2(-12, -20), 4.0, Color(0.42, 0.30, 0.12))


func _on_fruit_pressed(btn: Button, type: String) -> void:
	if type == "strawberry":
		if btn.disabled:
			return
		btn.disabled = true
		btn.modulate = Color(1.2, 1.2, 1.2, 0.45) # Mờ đi vì đã chọn
		_tapped_strawberries += 1
		_update_progress()
		if AudioDirector != null:
			AudioDirector.play_sfx("star_ting")

		if _tapped_strawberries >= 3:
			# Đã chạm đủ 3 quả dâu đỏ -> Mở khóa thành công!
			if AudioDirector != null:
				AudioDirector.play_sfx("hold_complete")
			close_overlay()
			gate_unlocked.emit()
	else:
		# Bấm nhầm quả khác -> Rung nhẹ và reset lại
		_shake_board()
		_reset_fruits()


func _update_progress() -> void:
	if _progress_label != null:
		_progress_label.text = "Đã chạm: %d / 3 quả dâu đỏ" % _tapped_strawberries


func _shake_board() -> void:
	var tw := create_tween().bind_node(self)
	var origin_x := _board.position.x
	tw.tween_property(_board, "position:x", origin_x - 12.0, 0.05)
	tw.tween_property(_board, "position:x", origin_x + 12.0, 0.05)
	tw.tween_property(_board, "position:x", origin_x - 8.0, 0.05)
	tw.tween_property(_board, "position:x", origin_x, 0.05)
