class_name MusicalBeanstalk
extends Control
## Cây Đậu Thần Âm Nhạc trên Trang Phải của Quyển Sách.
##
## Quản lý:
## - Thân cây đậu thần uốn lượn 2.5D.
## - 7 tán lá nốt nhạc tương ứng với 7 phím đàn (C, D, E, F, G, A, B).
## - Rương báu cổ tích nằm trên ngọn cây (lắc lư theo combo, mở tung phát sáng khi kết bài).
## - Cung cấp toạ độ chính xác cho dải lụa ma thuật (Magic Ribbon) bay tới.

signal chest_clicked

enum LeafState { DORMANT, SINGING, HINT, BLOOMED }

var _leaf_states: Array[LeafState] = []
var _leaf_nodes: Array[Control] = []
var _leaf_glows: Array[TextureRect] = []
var _leaf_labels: Array[Label] = []

var _trunk_rect: TextureRect
var _chest_rect: TextureRect
var _chest_sparkles: CPUParticles2D

var _tex_beanstalk: Texture2D
var _tex_chest_closed: Texture2D
var _tex_chest_open: Texture2D

var _is_fruiting: bool = false
var _chest_tween: Tween

# 7 vị trí tương đối của lá nốt nhạc trên thân cây (tính theo % width và % height của cây)
const LEAF_POSITIONS: Array[Vector2] = [
	Vector2(0.24, 0.74), # C4 (Lá dưới trái)
	Vector2(0.72, 0.65), # D4 (Lá dưới phải)
	Vector2(0.26, 0.52), # E4 (Lá giữa trái)
	Vector2(0.74, 0.48), # F4 (Lá giữa phải)
	Vector2(0.30, 0.35), # G4 (Lá trên trái)
	Vector2(0.68, 0.28), # A4 (Lá trên phải)
	Vector2(0.48, 0.16), # B4 (Lá đọt ngọn gần rương)
]

const LEAF_COLORS: Array[Color] = [
	Color("#E0644F"), # C4 - Sư tử (Đỏ cam)
	Color("#E08A2E"), # D4 - Gấu (Cam mật)
	Color("#D8619A"), # E4 - Thỏ (Hồng phấn)
	Color("#3F9455"), # G4 - Mèo (Xanh lá)
	Color("#3877B5"), # A4 - Khỉ (Xanh dương)
	Color("#7C5CC4"), # C5 - Voi (Tím cà)
	Color("#C7A017"), # D5 - Cú (Vàng hổ phách)
]

const NOTE_LETTERS: Array[String] = ["C", "D", "E", "G", "A", "C", "D"]


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	_leaf_states.resize(7)
	for i in 7:
		_leaf_states[i] = LeafState.DORMANT

	_setup_textures()
	_setup_nodes()
	resized.connect(_update_layout)
	_update_layout()


func _setup_textures() -> void:
	if ResourceLoader.exists("res://assets/art/beanstalk_trunk_fresh_25d.png"):
		_tex_beanstalk = load("res://assets/art/beanstalk_trunk_fresh_25d.png")
	elif ResourceLoader.exists("res://assets/art/beanstalk_vine_clean_25d.png"):
		_tex_beanstalk = load("res://assets/art/beanstalk_vine_clean_25d.png")
	elif ResourceLoader.exists("res://assets/art/magic_beanstalk_clean_25d.png"):
		_tex_beanstalk = load("res://assets/art/magic_beanstalk_clean_25d.png")
	elif ResourceLoader.exists("res://assets/art/musical_beanstalk_stage.png"):
		_tex_beanstalk = load("res://assets/art/musical_beanstalk_stage.png")

	if ResourceLoader.exists("res://assets/art/prop_chest_closed_gold_25d.png"):
		_tex_chest_closed = load("res://assets/art/prop_chest_closed_gold_25d.png")
	elif ResourceLoader.exists("res://assets/art/chest_closed.png"):
		_tex_chest_closed = load("res://assets/art/chest_closed.png")

	if ResourceLoader.exists("res://assets/art/prop_chest_open_gold_25d.png"):
		_tex_chest_open = load("res://assets/art/prop_chest_open_gold_25d.png")
	elif ResourceLoader.exists("res://assets/art/chest_open.png"):
		_tex_chest_open = load("res://assets/art/chest_open.png")


func _setup_nodes() -> void:
	# 1. Thân cây đậu thần
	_trunk_rect = TextureRect.new()
	_trunk_rect.name = "BeanstalkTrunk"
	_trunk_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_trunk_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_trunk_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_trunk_rect.texture = _tex_beanstalk
	add_child(_trunk_rect)

	# 2. 7 Tán lá nốt nhạc tương tác
	var leaf_tex: Texture2D = null
	if ResourceLoader.exists("res://assets/art/leaf_white.png"):
		leaf_tex = load("res://assets/art/leaf_white.png")
	elif ResourceLoader.exists("res://assets/art/fx_glow.png"):
		leaf_tex = load("res://assets/art/fx_glow.png")

	for i in 7:
		var leaf := Control.new()
		leaf.name = "Leaf_%s" % NOTE_LETTERS[i]
		leaf.mouse_filter = Control.MOUSE_FILTER_STOP
		leaf.custom_minimum_size = Vector2(42, 42)

		var glow := TextureRect.new()
		glow.name = "Glow"
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		glow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		glow.modulate = LEAF_COLORS[i]
		glow.texture = leaf_tex
		leaf.add_child(glow)
		_leaf_glows.append(glow)

		var lbl := Label.new()
		lbl.name = "NoteLabel"
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.text = "♪\n%s" % NOTE_LETTERS[i]
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		lbl.add_theme_constant_override("shadow_offset_x", 1)
		lbl.add_theme_constant_override("shadow_offset_y", 1)
		leaf.add_child(lbl)

		# Bắt sự kiện chạm trực tiếp vào lá nốt nhạc
		var leaf_idx := i
		leaf.gui_input.connect(func(event: InputEvent):
			if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
				AudioDirector.play_note(leaf_idx)
				bloom_leaf(leaf_idx)
		)

		add_child(leaf)
		_leaf_nodes.append(leaf)
		_leaf_labels.append(lbl)

	# 3. Rương báu cổ tích trên ngọn cây
	_chest_rect = TextureRect.new()
	_chest_rect.name = "TreasureChest"
	_chest_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_chest_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_chest_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_chest_rect.texture = _tex_chest_closed
	_chest_rect.gui_input.connect(func(event: InputEvent):
		if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
			AudioDirector.play_sfx("soft_boing")
			wobble_chest()
			chest_clicked.emit()
	)
	add_child(_chest_rect)

	# 4. Hạt bụi vàng tỏa ra từ rương
	_chest_sparkles = CPUParticles2D.new()
	_chest_sparkles.name = "ChestSparkles"
	_chest_sparkles.emitting = false
	_chest_sparkles.one_shot = true
	_chest_sparkles.amount = 24
	_chest_sparkles.lifetime = 1.0
	_chest_sparkles.explosiveness = 0.9
	_chest_sparkles.direction = Vector2(0, -1)
	_chest_sparkles.spread = 70.0
	_chest_sparkles.initial_velocity_min = 80.0
	_chest_sparkles.initial_velocity_max = 180.0
	_chest_sparkles.scale_amount_min = 3.0
	_chest_sparkles.scale_amount_max = 7.0
	_chest_sparkles.color = Color("#FFD700")
	add_child(_chest_sparkles)


func _update_layout() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	if _trunk_rect != null:
		_trunk_rect.position = Vector2.ZERO
		_trunk_rect.size = size

	# Căn vị trí 7 lá nốt nhạc theo tỷ lệ
	for i in _leaf_nodes.size():
		var l_node := _leaf_nodes[i]
		var rel := LEAF_POSITIONS[i]
		var l_size := Vector2(40.0, 40.0)
		l_node.size = l_size
		l_node.position = Vector2(size.x * rel.x - l_size.x * 0.5, size.y * rel.y - l_size.y * 0.5)
		l_node.pivot_offset = l_size * 0.5

		var lbl := _leaf_labels[i]
		lbl.position = Vector2.ZERO
		lbl.size = l_size

		if i < _leaf_glows.size():
			var gl := _leaf_glows[i]
			gl.position = Vector2.ZERO
			gl.size = l_size

	# Rương báu nằm ở đỉnh ngọn cây
	if _chest_rect != null:
		var c_size := Vector2(minf(size.x * 0.35, 104.0), minf(size.x * 0.32, 94.0))
		_chest_rect.size = c_size
		_chest_rect.position = Vector2((size.x - c_size.x) * 0.5, size.y * 0.055)
		_chest_rect.pivot_offset = c_size * 0.5

		if _chest_sparkles != null:
			_chest_sparkles.position = _chest_rect.position + c_size * 0.5


## Trả về toạ độ tương đối của lá nốt nhạc để nối dải lụa ma thuật
func get_leaf_position(note_index: int) -> Vector2:
	if note_index >= 0 and note_index < _leaf_nodes.size():
		return _leaf_nodes[note_index].position + _leaf_nodes[note_index].size * 0.5
	return size * 0.5


## Cây hát: Chiếc lá nốt nhạc phát sáng nhấp nháy
func sing_leaf(note_index: int) -> void:
	if note_index < 0 or note_index >= _leaf_nodes.size():
		return
	_leaf_states[note_index] = LeafState.SINGING
	var node := _leaf_nodes[note_index]
	var tw := create_tween().bind_node(self)
	tw.tween_property(node, "scale", Vector2(1.35, 1.35), 0.15) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(node, "scale", Vector2(1.15, 1.15), 0.2) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)


## Bé đàn đúng nốt: Lá nở hoa nốt nhạc rực rỡ
func bloom_leaf(note_index: int) -> void:
	if note_index < 0 or note_index >= _leaf_nodes.size():
		return
	_leaf_states[note_index] = LeafState.BLOOMED
	var node := _leaf_nodes[note_index]
	var tw := create_tween().bind_node(self)
	tw.tween_property(node, "scale", Vector2(1.45, 1.45), 0.12) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(node, "scale", Vector2(1.0, 1.0), 0.28) \
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	wobble_chest()


## Rương báu rung rinh khi có nốt đúng
func wobble_chest() -> void:
	if _chest_rect == null or _is_fruiting:
		return
	if _chest_tween != null and _chest_tween.is_valid():
		_chest_tween.kill()

	_chest_tween = create_tween().bind_node(self)
	_chest_tween.tween_property(_chest_rect, "rotation_degrees", 7.0, 0.06)
	_chest_tween.tween_property(_chest_rect, "rotation_degrees", -7.0, 0.08)
	_chest_tween.tween_property(_chest_rect, "rotation_degrees", 0.0, 0.06)


## Hoàn thành bài: Rương báu mở bung, phát sáng rực rỡ và pháo hoa nốt nhạc
func open_chest_celebration() -> void:
	_is_fruiting = true
	if _chest_rect != null and _tex_chest_open != null:
		_chest_rect.texture = _tex_chest_open
		_chest_rect.rotation_degrees = 0.0

	if _chest_sparkles != null:
		_chest_sparkles.restart()

	AudioDirector.play_sfx("chest_open")

	var tw := create_tween().bind_node(self)
	tw.tween_property(_chest_rect, "scale", Vector2(1.3, 1.3), 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_chest_rect, "scale", Vector2(1.1, 1.1), 0.3)


## Reset lại trạng thái cây khi sang bài hát mới
func reset_page() -> void:
	_is_fruiting = false
	if _chest_rect != null and _tex_chest_closed != null:
		_chest_rect.texture = _tex_chest_closed
		_chest_rect.scale = Vector2.ONE
		_chest_rect.rotation_degrees = 0.0

	for i in 7:
		_leaf_states[i] = LeafState.DORMANT
		if i < _leaf_nodes.size():
			_leaf_nodes[i].scale = Vector2.ONE
