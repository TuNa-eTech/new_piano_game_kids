class_name MagicTree
extends Control
## Cây thần — nơi hiển thị kết quả, KHÔNG nhận input (Quyết định 01).

signal leaf_singing(note_index: int)
signal leaf_bloomed(note_index: int)

const STAGES := 8

## Mỗi nốt đúng đẩy cây lên một đoạn lớn; nốt khác vẫn làm cây cao thêm một
## chút, vì "không có trạng thái sai" — mọi cú chạm đều phải tạo thay đổi
## nhìn thấy được.
const GROWTH_FREE := 0.012
const FREE_GROWTH_CAP := 0.85

## Giai đoạn 0 vẫn phải nhìn thấy được: mầm cây, không phải màn hình trống.
const SPROUT_FRACTION := 0.12

enum LeafState { DORMANT, SINGING, HINT, BLOOMED }

var _growth: float = 0.0
var _leaf_state: Array[LeafState] = []
var _sequence: PackedInt32Array = PackedInt32Array()
var _hint_step: int = -1
var _fruiting: bool = false
var _time: float = 0.0

@onready var _trunk_color := Color("#5a3d2b")
@onready var _ground_color := Color("#243024")

var _tree_textures: Array[Texture2D] = []
var _leaf_texture: Texture2D
var _chest_closed_texture: Texture2D
var _chest_open_texture: Texture2D
var _burst_texture: Texture2D


func _ready() -> void:
	# Khung truyện chỉ hiển thị — không bao giờ nuốt sự kiện chạm.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_leaf_state.resize(Notes.count())

	# Preload 8 tree stage textures
	for i in STAGES:
		var p := "res://assets/art/tree_stage_0%d.png" % (i + 1)
		if ResourceLoader.exists(p):
			_tree_textures.append(load(p))
		else:
			_tree_textures.append(null)

	if ResourceLoader.exists("res://assets/art/leaf_white.png"):
		_leaf_texture = load("res://assets/art/leaf_white.png")
	if ResourceLoader.exists("res://assets/art/chest_closed.png"):
		_chest_closed_texture = load("res://assets/art/chest_closed.png")
	if ResourceLoader.exists("res://assets/art/chest_open.png"):
		_chest_open_texture = load("res://assets/art/chest_open.png")
	if ResourceLoader.exists("res://assets/art/fx_golden_burst.png"):
		_burst_texture = load("res://assets/art/fx_golden_burst.png")

	reset_page()
	resized.connect(queue_redraw)


func _process(delta: float) -> void:
	# Lá gợi ý "nhấp nháy nhẹ theo nhịp thở" (Quyết định 03, bước 2) nên cần
	# vẽ lại mỗi khung hình. Toàn bộ bản vẽ là vài chục hình khối, rất rẻ.
	_time += delta
	if _hint_step >= 0 or _fruiting:
		queue_redraw()


# ------------------------------------------------------------------- điều khiển --

func reset_page() -> void:
	_growth = 0.0
	_hint_step = -1
	_fruiting = false
	for i in _leaf_state.size():
		_leaf_state[i] = LeafState.DORMANT
	queue_redraw()


func set_sequence(sequence: PackedInt32Array) -> void:
	_sequence = sequence
	queue_redraw()


## Cây hát: lá sáng lên khi tới lượt nó trong câu "gọi".
func sing_leaf(note_index: int) -> void:
	if Notes.is_valid(note_index) and _leaf_state[note_index] != LeafState.BLOOMED:
		_leaf_state[note_index] = LeafState.SINGING
		leaf_singing.emit(note_index)
		queue_redraw()


func clear_singing() -> void:
	for i in _leaf_state.size():
		if _leaf_state[i] == LeafState.SINGING:
			_leaf_state[i] = LeafState.DORMANT
	queue_redraw()


## Lá đang được gợi ý — nhấp nháy cho tới khi bé chạm đúng. Không đồng hồ,
## không thanh thời gian: cây chờ vô hạn.
func set_hint(note_index: int) -> void:
	_hint_step = note_index
	if Notes.is_valid(note_index) and _leaf_state[note_index] != LeafState.BLOOMED:
		_leaf_state[note_index] = LeafState.HINT
	queue_redraw()


## Bỏ mọi gợi ý. Chơi Tự Do chốt rõ "không gợi ý" — mà set_hint(-1) chỉ xoá con
## trỏ chứ để nguyên chiếc lá đang ở trạng thái HINT, nên nó vẫn nhấp nháy tiếp.
func clear_hint() -> void:
	_hint_step = -1
	for i in _leaf_state.size():
		if _leaf_state[i] == LeafState.HINT:
			_leaf_state[i] = LeafState.DORMANT
	queue_redraw()


## Nốt đúng: lá nở thành nốt vàng và thân cây vươn lên một đoạn lớn.
func bloom(note_index: int, sequence_length: int) -> void:
	if not Notes.is_valid(note_index):
		return
	_leaf_state[note_index] = LeafState.BLOOMED
	_growth = minf(1.0, _growth + 0.9 / maxf(1.0, float(sequence_length)))
	leaf_bloomed.emit(note_index)
	queue_redraw()


## Nốt không nằm trong gợi ý: vẫn kêu hay, lá thường vẫn mọc thêm, chuỗi gợi ý
## giữ nguyên vị trí. Bé thử lại bao nhiêu lần cũng được.
func grow_free() -> void:
	if _growth < FREE_GROWTH_CAP:
		_growth = minf(FREE_GROWTH_CAP, _growth + GROWTH_FREE)
		queue_redraw()


## Cây trổ quả: hoa nở, rương báu hiện ra. Khoảnh khắc đáng quay màn hình.
func fruit() -> void:
	_fruiting = true
	_growth = 1.0
	queue_redraw()


func stage() -> int:
	return clampi(int(_growth * (STAGES - 1) + 0.001), 0, STAGES - 1)


func growth() -> float:
	return _growth


## Số lá đang được vẽ. Dùng cho máy đo — từng có lỗi ẩn hết lá ở giai đoạn 0.
func visible_leaf_count() -> int:
	return Notes.count()


func leaf_state_of(note_index: int) -> int:
	return _leaf_state[note_index] if Notes.is_valid(note_index) else -1


# ------------------------------------------------------------------------- vẽ --

@export var center_ratio_x: float = 0.72

const LEAF_COORDS: Array[Vector2] = [
	Vector2(0.29, 0.71), # 0 (C4): low-left branch
	Vector2(0.69, 0.72), # 1 (D4): low-right branch
	Vector2(0.28, 0.54), # 2 (E4): mid-left branch
	Vector2(0.76, 0.53), # 3 (G4): mid-right branch
	Vector2(0.30, 0.38), # 4 (A4): upper-left branch
	Vector2(0.75, 0.39), # 5 (C5): upper-right branch
	Vector2(0.35, 0.23), # 6 (D5): top-left branch
]

const CONCEPT_LEAF_COORDS: Array[Vector2] = [
	Vector2(681.0, 384.0), # 0 (C4): cành thấp bên trái
	Vector2(837.0, 428.0), # 1 (D4): cành thấp bên phải
	Vector2(681.0, 271.0), # 2 (E4): cành giữa bên trái
	Vector2(819.0, 333.0), # 3 (G4): cành giữa bên phải
	Vector2(744.0, 176.0), # 4 (A4): cành cao bên trái
	Vector2(844.0, 214.0), # 5 (C5): cành cao bên phải
	Vector2(794.0, 113.0), # 6 (D5): ngọn cây sát rương vàng
]

func get_leaf_position(i: int) -> Vector2:
	return _leaf_anchor(i)

func _leaf_anchor(i: int) -> Vector2:
	if i >= 0 and i < CONCEPT_LEAF_COORDS.size():
		return CONCEPT_LEAF_COORDS[i]
	return Vector2(size.x * 0.61, size.y * 0.35)


func _draw() -> void:
	# Cây Đậu Thần hiển thị nguyên vẹn từ tranh Diorama (không vẽ mô đất đè lên)
	# Chỉ vẽ hào quang phát sáng và ký hiệu nốt nhạc khi lá hát, gợi ý hoặc nở hoa
	for i in Notes.count():
		if _leaf_state[i] != LeafState.DORMANT:
			_draw_leaf(i, _leaf_anchor(i))

	# Khi hoàn thành chuỗi (fruiting): vẽ vầng hào quang rương báu nở rộ
	if _fruiting:
		var chest_pos := Vector2(765.0, 80.0)
		_draw_chest(chest_pos)


## Vẽ lá: dùng _leaf_texture nếu có, kết hợp vẽ quầng sáng và ký tự nốt nhạc
func _draw_leaf(i: int, p: Vector2) -> void:
	var base := Notes.color_of(i)
	var r := size.y * 0.032
	var leaf_size := r * 2.1
	var note_symbols := ["♪", "♫", "♬", "♩", "♪", "♫", "♬"]
	var sym: String = note_symbols[i % note_symbols.size()]
	var font := ThemeDB.fallback_font

	match _leaf_state[i]:
		LeafState.DORMANT:
			# Không vẽ đè lên hình minh họa cây đậu thần khi lá đang ngủ
			pass
		LeafState.SINGING:
			# Vầng hào quang sáng rực khi lá đang phát ra giai điệu
			draw_circle(p, r * 1.5, Color(base.r, base.g, base.b, 0.35))
			draw_circle(p, r * 1.1, Color(base.r, base.g, base.b, 0.85))
			draw_circle(p, r * 0.65, Color.WHITE)
			draw_string(font, p + Vector2(-6, 6), sym, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(base.r * 0.4, base.g * 0.4, base.b * 0.4, 1.0))
		LeafState.HINT:
			# Quầng sáng nhấp nháy theo nhịp thở mời gọi bé bấm đúng nốt
			var pulse := 0.5 + 0.5 * sin(_time * 3.2)
			draw_circle(p, r * (1.3 + 0.4 * pulse), Color(base.r, base.g, base.b, 0.35 * pulse))
			draw_circle(p, r * (0.95 + 0.2 * pulse), Color(base.r, base.g, base.b, 0.75 + 0.25 * pulse))
			draw_circle(p, r * 0.55, Color(1, 1, 1, 0.9))
			draw_string(font, p + Vector2(-6, 6), sym, HORIZONTAL_ALIGNMENT_CENTER, -1, 15, Color(base.r * 0.3, base.g * 0.3, base.b * 0.3, 1.0))
		LeafState.BLOOMED:
			# Lá nở hoa vàng kim rực rỡ khi bé bấm trúng
			draw_circle(p, r * 1.6, Color(1.0, 0.85, 0.3, 0.4))
			draw_circle(p, r * 1.15, Color("#F2C64B"))
			draw_circle(p, r * 0.7, Color.WHITE)
			draw_string(font, p + Vector2(-6, 6), "★", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color("#8A5800"))



func get_chest_position() -> Vector2:
	var ground_y := size.y * 0.94
	var tree_cx := size.x * center_ratio_x
	var tree_display_h := ground_y * 0.92
	var st := stage()
	var peak_frac := lerpf(0.18, 0.94, float(st) / float(STAGES - 1))
	var bob := sin(_time * 2.5) * 3.5
	return Vector2(tree_cx, ground_y - tree_display_h * peak_frac + bob)


func get_chest_global_position() -> Vector2:
	return global_position + get_chest_position()


func _draw_chest(pos: Vector2) -> void:
	var cs := size.y * 0.16
	var rect := Rect2(pos.x - cs * 0.5, pos.y - cs * 0.75, cs, cs)

	if _fruiting:
		# Hiệu ứng bùng nổ tia sáng vàng
		if _burst_texture != null:
			var burst_size := cs * 2.6
			var burst_rect := Rect2(pos.x - burst_size * 0.5, pos.y - burst_size * 0.6, burst_size, burst_size)
			draw_texture_rect(_burst_texture, burst_rect, false, Color(1.0, 1.0, 1.0, 0.75 + 0.25 * sin(_time * 4.0)))
		# Các hạt sao vàng bay quanh rương
		var t := _time * 3.0
		var gold := Color("#F2C64B")
		for k in 8:
			var a := TAU * k / 8.0 + t * 0.4
			var rr := cs * 0.85 * (1.0 + 0.15 * sin(t + k))
			draw_circle(pos + Vector2(cos(a), sin(a)) * rr, size.y * 0.016, gold)

		# Rương mở bung nắp
		if _chest_open_texture != null:
			draw_texture_rect(_chest_open_texture, rect, false)
	else:
		# Hào quang vàng nhẹ quanh rương đóng
		var glow_pulse := 0.5 + 0.5 * sin(_time * 2.2)
		draw_circle(pos - Vector2(0, cs * 0.25), cs * 0.55, Color(1.0, 0.88, 0.45, 0.18 + 0.14 * glow_pulse))

		# Rương đóng cưỡi trên đỉnh cành đậu thần
		if _chest_closed_texture != null:
			draw_texture_rect(_chest_closed_texture, rect, false)
		elif _chest_open_texture != null:
			draw_texture_rect(_chest_open_texture, rect, false)
