class_name ParentalGate
extends PauseOverlay
## Cổng Phụ Huynh Bảo Vệ (Parental Gate & Tactile Fruit Puzzle).
## Thiết kế khớp 100% với mock-parental-gate.jpeg và chuẩn Apple Kids Category 1.3.
##
## Thẩm mỹ Bảng Gỗ Treo 2.5D Diorama & Câu đố Xúc Giác Trái Cây:
## - Bảng gỗ sồi chạm khắc Baroque treo bằng 2 sợi dây thừng từ tán cây rừng
## - Đung đưa vật lý nhẹ nhàng tự nhiên (Pendulum swing physics)
## - Khay gỗ chìm chứa 5 quả trái cây gỗ bo tròn (Chuối vàng, Táo xanh, Dâu tây đỏ)
## - Yêu cầu bảo vệ: "CỔNG PHỤ HUYNH: Hãy chạm vào 3 quả dâu tây đỏ để mở khóa"
## - Ổ khóa đồng to bản ở đáy bảng rung lắc khi gõ và bung quai khi giải đúng
## - Nút đóng 'X' gỗ tròn ở góc phải trên để quay lại

signal gate_unlocked
signal gate_cancelled

var _bg_texture: Texture2D
var _stage: Control
var _board_anchor: Control
var _prompt_label: Label
var _close_btn: Button
var _padlock_rect: TextureRect
var _fruit_buttons: Array[Button] = []
var _burst_layer: GateStarlightBurstLayer
var _time: float = 0.0

# Dữ liệu câu đố trái cây
const TARGET_FRUIT := "strawberry"
const REQUIRED_COUNT := 3
var _tapped_count: int = 0
var _fruits_layout: Array[Dictionary] = [
	{"type": "banana", "name": "Quả chuối vàng", "tex": "res://assets/art/fruit_banana_3d.png", "rect": [0.275, 0.485, 0.360, 0.655]},
	{"type": "apple", "name": "Quả táo xanh", "tex": "res://assets/art/fruit_apple_3d.png", "rect": [0.375, 0.485, 0.455, 0.655]},
	{"type": "strawberry", "name": "Quả dâu tây đỏ", "tex": "res://assets/art/fruit_strawberry_3d.png", "rect": [0.470, 0.485, 0.545, 0.655]},
	{"type": "strawberry", "name": "Quả dâu tây đỏ", "tex": "res://assets/art/fruit_strawberry_3d.png", "rect": [0.555, 0.485, 0.630, 0.655]},
	{"type": "strawberry", "name": "Quả dâu tây đỏ", "tex": "res://assets/art/fruit_strawberry_3d.png", "rect": [0.640, 0.485, 0.715, 0.655]}
]


func _ready() -> void:
	super()
	layer = 20
	_build()
	_set_controls_visible(false)


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta

	# Đung đưa vật lý nhẹ nhàng của bảng gỗ treo (Pendulum Swing)
	if _board_anchor != null and is_instance_valid(_board_anchor):
		_board_anchor.rotation = sin(_time * 1.6) * 0.012

	# Nhịp thở nhẹ của nút đóng 'X'
	if _close_btn != null and is_instance_valid(_close_btn):
		var breathe := 1.0 + 0.02 * sin(_time * 2.8)
		_close_btn.scale = Vector2(breathe, breathe)


func _build() -> void:
	_add_backdrop(Color(0.02, 0.03, 0.02, 0.90))

	# Khung sân khấu chính
	_stage = Control.new()
	_stage.name = "DioramaStage"
	_stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	_stage.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_stage)

	# 1. Phông nền toàn cảnh từ mock-parental-gate.jpeg
	if ResourceLoader.exists("res://assets/art/bg_parental_gate_forest_25d.png"):
		_bg_texture = load("res://assets/art/bg_parental_gate_forest_25d.png")
	elif ResourceLoader.exists("res://docs/mock-parental-gate.jpeg"):
		_bg_texture = load("res://docs/mock-parental-gate.jpeg")

	var bg_rect := TextureRect.new()
	bg_rect.name = "BackgroundDiorama"
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _bg_texture != null:
		bg_rect.texture = _bg_texture
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	_stage.add_child(bg_rect)

	# 2. Hiệu ứng đom đóm rừng đêm
	var fireflies := MainMenu.FireflyOverlay.new()
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(fireflies)

	# 3. Neo trục xoay bảng gỗ treo (Treo từ trên đỉnh màn hình)
	_board_anchor = Control.new()
	_board_anchor.name = "BoardAnchor"
	_board_anchor.set_anchors_preset(Control.PRESET_FULL_RECT)
	_board_anchor.pivot_offset = Vector2(688, 0) # Trục quay giữa 2 sợi dây thừng
	_board_anchor.mouse_filter = Control.MOUSE_FILTER_PASS
	_stage.add_child(_board_anchor)

	var empty_style := StyleBoxEmpty.new()

	# --- 4. BẢNG GỖ TREO & DÂY THỪNG (HANGING BOARD) ---
	# Tọa độ tương đối: X ~ 21.8% - 78.1%, Y ~ 0.0% - 76.8%
	var board_rect := TextureRect.new()
	board_rect.name = "HangingBoard"
	board_rect.anchor_left = 0.218
	board_rect.anchor_top = 0.0
	board_rect.anchor_right = 0.781
	board_rect.anchor_bottom = 0.768
	if ResourceLoader.exists("res://assets/art/gate_hanging_board_chain.png"):
		board_rect.texture = load("res://assets/art/gate_hanging_board_chain.png")
	board_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	board_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	board_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	_board_anchor.add_child(board_rect)

	# --- 5. NÚT ĐÓNG 'X' GỖ TRÒN (GÓC PHẢI TRÊN BẢNG GỖ) ---
	# Tọa độ tương đối: X ~ 71.9% - 80.6%, Y ~ 12.3% - 28.0%
	_close_btn = Button.new()
	_close_btn.name = "BtnCloseGate"
	_close_btn.anchor_left = 0.719
	_close_btn.anchor_top = 0.123
	_close_btn.anchor_right = 0.806
	_close_btn.anchor_bottom = 0.280
	_close_btn.focus_mode = Control.FOCUS_NONE
	_close_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_close_btn.flat = true
	_close_btn.add_theme_stylebox_override("normal", empty_style)
	_close_btn.add_theme_stylebox_override("hover", empty_style)
	_close_btn.add_theme_stylebox_override("pressed", empty_style)
	_close_btn.item_rect_changed.connect(func(): _close_btn.pivot_offset = _close_btn.size * 0.5)
	_close_btn.pressed.connect(_on_close_pressed)
	_board_anchor.add_child(_close_btn)

	# --- 6. DÒNG CHỮ HƯỚNG DẪN CÂU ĐỐ (PROMPT LABEL) ---
	# Tọa độ tương đối: X ~ 26.0% - 74.0%, Y ~ 22.0% - 46.0%
	_prompt_label = Label.new()
	_prompt_label.name = "PromptLabel"
	_prompt_label.anchor_left = 0.260
	_prompt_label.anchor_top = 0.220
	_prompt_label.anchor_right = 0.740
	_prompt_label.anchor_bottom = 0.460
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_prompt_label.add_theme_font_size_override("font_size", 24)
	_prompt_label.add_theme_color_override("font_color", Color("#FFF5D0"))
	_prompt_label.add_theme_color_override("font_shadow_color", Color(0.15, 0.08, 0.02, 0.9))
	_prompt_label.add_theme_constant_override("shadow_offset_x", 2)
	_prompt_label.add_theme_constant_override("shadow_offset_y", 2)
	_prompt_label.text = "CỔNG PHỤ HUYNH:\nHãy chạm vào 3 quả dâu tây\nđỏ để mở khóa"
	_prompt_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_board_anchor.add_child(_prompt_label)

	# --- 7. NĂM NÚT TRÁI CÂY TRONG KHAY GỖ CHÌM ---
	for i in _fruits_layout.size():
		var f_data: Dictionary = _fruits_layout[i]
		var btn := Button.new()
		btn.name = "FruitBtn_%d" % i
		var r: Array = f_data["rect"]
		btn.anchor_left = r[0]
		btn.anchor_top = r[1]
		btn.anchor_right = r[2]
		btn.anchor_bottom = r[3]
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.flat = true
		btn.add_theme_stylebox_override("normal", empty_style)
		btn.add_theme_stylebox_override("hover", empty_style)
		btn.add_theme_stylebox_override("pressed", empty_style)
		btn.item_rect_changed.connect(func(): btn.pivot_offset = btn.size * 0.5)

		var f_type: String = f_data["type"]
		btn.pressed.connect(_on_fruit_pressed.bind(btn, f_type, i))
		_board_anchor.add_child(btn)
		_fruit_buttons.append(btn)

	# --- 8. Ổ KHÓA ĐỒNG TO BẢN Ở ĐÁY BẢNG GỖ ---
	# Tọa độ tương đối: X ~ 44.7% - 55.2%, Y ~ 69.6% - 97.0%
	_padlock_rect = TextureRect.new()
	_padlock_rect.name = "PadlockBrass"
	_padlock_rect.anchor_left = 0.447
	_padlock_rect.anchor_top = 0.696
	_padlock_rect.anchor_right = 0.552
	_padlock_rect.anchor_bottom = 0.970
	_padlock_rect.pivot_offset = Vector2(72, 105)
	if ResourceLoader.exists("res://assets/art/padlock_brass_gate_closed.png"):
		_padlock_rect.texture = load("res://assets/art/padlock_brass_gate_closed.png")
	_padlock_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_padlock_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_padlock_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_padlock_rect.gui_input.connect(_on_padlock_gui_input)
	_board_anchor.add_child(_padlock_rect)

	# --- 9. LỚP BÙNG NỔ BỤI SAO VÀNG ---
	_burst_layer = GateStarlightBurstLayer.new()
	_burst_layer.name = "GateStarlightBurstLayer"
	_burst_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_burst_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_burst_layer)


func open_gate() -> void:
	_tapped_count = 0
	_play_sfx("menu_open")
	open_overlay()
	_play_entrance_animation()


func _play_entrance_animation() -> void:
	# Bảng gỗ hạ từ trên vòm cây xuống với độ nảy lò xo dây thừng
	if _board_anchor != null:
		_board_anchor.position.y = -600.0
		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(_board_anchor, "position:y", 0.0, 0.45)


func _on_fruit_pressed(btn: Button, fruit_type: String, _idx: int) -> void:
	# Hoạt cảnh nảy đàn hồi (Squash & Stretch)
	var tw := create_tween()
	tw.tween_property(btn, "scale", Vector2(1.25, 1.25), 0.08).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(btn, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK)

	if fruit_type == TARGET_FRUIT:
		# Chạm đúng quả dâu tây đỏ
		_tapped_count += 1
		_play_sfx("star_ting")
		if _burst_layer != null:
			_burst_layer.emit_burst(btn.get_global_rect().get_center(), Color("#ED7A8E"), 15)

		if _tapped_count >= REQUIRED_COUNT:
			_unlock_success()
	else:
		# Chạm sai quả (chuối hoặc táo): reset đếm và rung lắc cảnh báo nhẹ
		_tapped_count = 0
		_play_sfx("soft_plop")
		_shake_node(btn)
		_shake_node(_padlock_rect)


func _unlock_success() -> void:
	_play_sfx("padlock_unlock")
	_play_sfx("star_ting")

	# Rung mở ổ khóa đồng & bùng nổ bụi sao vàng
	if _padlock_rect != null:
		var tw := create_tween()
		tw.tween_property(_padlock_rect, "scale", Vector2(1.35, 1.35), 0.12).set_trans(Tween.TRANS_BACK)
		tw.tween_property(_padlock_rect, "rotation", 0.15, 0.08)
		tw.tween_property(_padlock_rect, "rotation", -0.15, 0.08)
		tw.tween_property(_padlock_rect, "rotation", 0.0, 0.08)
		if _burst_layer != null:
			_burst_layer.emit_burst(_padlock_rect.get_global_rect().get_center(), Color(1.0, 0.92, 0.45, 0.95), 30)

	# Bảng gỗ kéo vút lên trên
	get_tree().create_timer(0.35).timeout.connect(func():
		if _board_anchor != null:
			var tw_up := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tw_up.tween_property(_board_anchor, "position:y", -700.0, 0.35)
			tw_up.finished.connect(func():
				close_overlay()
				gate_unlocked.emit()
			)
		else:
			close_overlay()
			gate_unlocked.emit()
	)


func _on_close_pressed() -> void:
	_play_sfx("wood_tap")
	if _close_btn != null:
		var tw := create_tween()
		tw.tween_property(_close_btn, "scale", Vector2(0.85, 0.85), 0.08)
		tw.tween_property(_close_btn, "scale", Vector2.ONE, 0.10)
	close_overlay()
	gate_cancelled.emit()


func _on_padlock_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Gõ vào ổ khóa khi chưa giải câu đố: phát tiếng lách cách kim loại
		_play_sfx("padlock_rattle")
		_shake_node(_padlock_rect)


func _shake_node(node: Control) -> void:
	if node == null:
		return
	var orig_pos := node.position
	var tw := create_tween()
	tw.tween_property(node, "position:x", orig_pos.x - 8.0, 0.04)
	tw.tween_property(node, "position:x", orig_pos.x + 8.0, 0.04)
	tw.tween_property(node, "position:x", orig_pos.x - 4.0, 0.04)
	tw.tween_property(node, "position:x", orig_pos.x, 0.04)


func _play_sfx(sfx_name: String) -> void:
	var ad := get_node_or_null("/root/AudioDirector")
	if ad != null and ad.has_method("play_sfx"):
		ad.play_sfx(sfx_name)


## Lớp hiệu ứng bụi sao bung nở cho Cổng Phụ Huynh
class GateStarlightBurstLayer extends Control:
	var _particles: Array[Dictionary] = []

	func emit_burst(origin: Vector2, color: Color = Color(1.0, 0.92, 0.45, 0.95), count: int = 18) -> void:
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		for j in range(count):
			var angle := rng.randf_range(0, TAU)
			var spd := rng.randf_range(40.0, 180.0)
			_particles.append({
				"pos": origin,
				"vel": Vector2(cos(angle), sin(angle)) * spd,
				"color": color,
				"alpha": 1.0,
				"radius": rng.randf_range(2.5, 4.8),
				"decay": rng.randf_range(1.6, 2.8),
			})

	func _process(delta: float) -> void:
		if _particles.is_empty():
			return
		var i := _particles.size() - 1
		while i >= 0:
			var p: Dictionary = _particles[i]
			p["pos"] += p["vel"] * delta
			p["vel"] *= 0.91
			p["alpha"] -= p["decay"] * delta
			if p["alpha"] <= 0.0:
				_particles.remove_at(i)
			i -= 1
		queue_redraw()

	func _draw() -> void:
		for p in _particles:
			var col: Color = p["color"]
			col.a *= p["alpha"]
			draw_circle(p["pos"], p["radius"] * p["alpha"], col)
			draw_circle(p["pos"], p["radius"] * 1.8 * p["alpha"], Color(col.r, col.g, col.b, col.a * 0.25))
