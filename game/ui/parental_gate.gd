class_name ParentalGate
extends PauseOverlay
## Cổng Phụ Huynh — thử thách bảo vệ phụ huynh theo chuẩn Apple Kids Category (Guideline 1.3).
## Thiết kế khớp 100% với mock-parental-gate.jpeg.
##
## Thẩm mỹ Sách Tranh Nổi 3D:
## - Bảng gỗ treo bằng dây thừng/xích sắt cổ kính giữa khu rừng thần tiên
## - Ổ khóa đồng lớn treo lủng lẳng dưới chân bảng
## - Khay gỗ chạm khắc chứa 5 quả trái cây xúc giác 3D (3 dâu tây đỏ, 1 chuối vàng, 1 táo xanh)
## - Câu đố chữ dành cho người lớn: "CỔNG PHỤ HUYNH: Hãy chạm vào 3 quả dâu tây đỏ để mở khóa"
## - Nút đóng ✕ bằng gỗ tròn ở góc trên bên phải

signal gate_unlocked

var _bg_texture: Texture2D
var _fruit_container: HBoxContainer
var _close_btn: Button
var _straw_tex: Texture2D
var _banana_tex: Texture2D
var _apple_tex: Texture2D

var _tapped_strawberries: int = 0
var _fruit_order: Array[String] = []


func _ready() -> void:
	super()
	layer = 20
	_build()
	_set_controls_visible(false)


func _build() -> void:
	_add_backdrop(Color(0.02, 0.04, 0.03, 0.95))

	# Phông nền toàn cảnh Cổng Phụ Huynh từ mock-parental-gate.jpeg
	if ResourceLoader.exists("res://docs/mock-parental-gate.jpeg"):
		_bg_texture = load("res://docs/mock-parental-gate.jpeg")

	var bg_rect := TextureRect.new()
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _bg_texture != null:
		bg_rect.texture = _bg_texture
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(bg_rect)

	# Hiệu ứng đom đóm
	var fireflies := MainMenu.FireflyOverlay.new()
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fireflies)

	# Nạp texture trái cây 3D
	if ResourceLoader.exists("res://assets/art/fruit_strawberry_3d.png"):
		_straw_tex = load("res://assets/art/fruit_strawberry_3d.png")
	if ResourceLoader.exists("res://assets/art/fruit_banana_3d.png"):
		_banana_tex = load("res://assets/art/fruit_banana_3d.png")
	if ResourceLoader.exists("res://assets/art/fruit_apple_3d.png"):
		_apple_tex = load("res://assets/art/fruit_apple_3d.png")

	var empty_style := StyleBoxEmpty.new()

	# --- 1. NÚT ĐÓNG ✕ GỖ TRÒN (GÓC TRÊN PHẢI BẢNG GỖ) ---
	# Tọa độ tương đối: X ~ 72.2% - 80.5%, Y ~ 12.5% - 27.2%
	_close_btn = Button.new()
	_close_btn.anchor_left = 0.722
	_close_btn.anchor_top = 0.125
	_close_btn.anchor_right = 0.805
	_close_btn.anchor_bottom = 0.272
	_close_btn.focus_mode = Control.FOCUS_NONE
	_close_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_close_btn.flat = true
	_close_btn.add_theme_stylebox_override("normal", empty_style)
	_close_btn.add_theme_stylebox_override("hover", empty_style)
	_close_btn.add_theme_stylebox_override("pressed", empty_style)
	_close_btn.pressed.connect(close_overlay)
	add_child(_close_btn)

	# --- 2. KHAY CHỨA 5 TRÁI CÂY TƯƠNG TÁC ---
	# Tọa độ tương đối của khay khoét lõm trên bảng gỗ:
	# X ~ 26.5% - 73.5%, Y ~ 47.5% - 64.5%
	_fruit_container = HBoxContainer.new()
	_fruit_container.anchor_left = 0.265
	_fruit_container.anchor_top = 0.475
	_fruit_container.anchor_right = 0.735
	_fruit_container.anchor_bottom = 0.645
	_fruit_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_fruit_container.add_theme_constant_override("separation", 14)
	_fruit_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fruit_container)

	_reset_fruits()


func open_overlay() -> void:
	_tapped_strawberries = 0
	_reset_fruits()
	super.open_overlay()


func _reset_fruits() -> void:
	_tapped_strawberries = 0

	for child in _fruit_container.get_children():
		child.queue_free()

	_fruit_order = ["banana", "apple", "strawberry", "strawberry", "strawberry"]

	for fruit_type in _fruit_order:
		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.flat = true

		var empty := StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", empty)
		btn.add_theme_stylebox_override("hover", empty)
		btn.add_theme_stylebox_override("pressed", empty)
		btn.add_theme_stylebox_override("disabled", empty)

		var icon := Control.new()
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.draw.connect(_draw_fruit.bind(icon, fruit_type))
		btn.add_child(icon)

		btn.pressed.connect(_on_fruit_pressed.bind(btn, fruit_type))
		_fruit_container.add_child(btn)


func _draw_fruit(node: Control, type: String) -> void:
	var center := node.size * 0.5
	var dim := minf(node.size.x, node.size.y) * 0.88
	var rect := Rect2(center.x - dim * 0.5, center.y - dim * 0.5, dim, dim)
	match type:
		"strawberry":
			if _straw_tex != null:
				node.draw_texture_rect(_straw_tex, rect, false)
				return
			node.draw_circle(center + Vector2(0, 4), 22.0, Color(0.92, 0.18, 0.24))
		"apple":
			if _apple_tex != null:
				node.draw_texture_rect(_apple_tex, rect, false)
				return
			node.draw_circle(center + Vector2(0, 2), 23.0, Color(0.38, 0.78, 0.25))
		"banana":
			if _banana_tex != null:
				node.draw_texture_rect(_banana_tex, rect, false)
				return
			node.draw_arc(center + Vector2(-15, 0), 28.0, -0.4, 1.4, 24, Color(0.96, 0.82, 0.18), 14.0, true)


func _on_fruit_pressed(btn: Button, type: String) -> void:
	if type == "strawberry":
		if btn.disabled:
			return
		btn.disabled = true
		_tapped_strawberries += 1

		# Hiệu ứng nảy và vòng hào quang khi chạm đúng
		var tw := create_tween()
		tw.tween_property(btn, "scale", Vector2(1.15, 1.15), 0.12)
		tw.tween_property(btn, "scale", Vector2.ONE, 0.12)
		AudioDirector.play_sfx("star_ting")

		if _tapped_strawberries >= 3:
			# Mở khóa thành công!
			AudioDirector.play_sfx("chest_open")
			var lock_tw := create_tween()
			lock_tw.tween_interval(0.35)
			lock_tw.tween_callback(func():
				close_overlay()
				gate_unlocked.emit()
			)
	else:
		# Bấm nhầm quả khác -> rung nhẹ
		AudioDirector.play_sfx("wood_tap")
		var tw := create_tween()
		tw.tween_property(btn, "position:x", btn.position.x + 8.0, 0.05)
		tw.tween_property(btn, "position:x", btn.position.x - 8.0, 0.05)
		tw.tween_property(btn, "position:x", btn.position.x, 0.05)
