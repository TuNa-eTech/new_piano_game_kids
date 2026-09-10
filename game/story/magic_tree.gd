class_name MagicTree
extends Control
## Cây thần — nơi hiển thị kết quả, KHÔNG nhận input (Quyết định 01).
##
## Art tạm theo đúng luật Bước 4: "hình chữ nhật màu và vòng tròn màu là đủ —
## cây thần là 8 hình khối cao dần, lá là 7 chấm nhỏ. Không vẽ gì thật trong
## bốn tuần này." Bước 2 thay bằng AnimatedSprite2D 8 giai đoạn mà không phải
## đụng tới logic ở đây.

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
var _chest_open_texture: Texture2D


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
	if ResourceLoader.exists("res://assets/art/chest_open.png"):
		_chest_open_texture = load("res://assets/art/chest_open.png")

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

func get_leaf_position(i: int) -> Vector2:
	return _leaf_anchor(i)

func _leaf_anchor(i: int) -> Vector2:
	## Lá gắn chính xác vào các cành của cây thần ma thuật uốn lượn trên trang phải
	var tree_cx := size.x * center_ratio_x
	var ground_y := size.y * 0.94
	var tree_display_h := ground_y * 0.92
	var tree_display_w := tree_display_h * 0.625
	var tree_top_left := Vector2(tree_cx - tree_display_w * 0.5, ground_y - tree_display_h + 8.0)

	if i >= 0 and i < LEAF_COORDS.size():
		var norm := LEAF_COORDS[i]
		return tree_top_left + Vector2(norm.x * tree_display_w, norm.y * tree_display_h)

	return Vector2(tree_cx, ground_y - tree_display_h * 0.5)


func _draw() -> void:
	var ground_y := size.y * 0.94
	var tree_cx := size.x * center_ratio_x
	var tree_display_h := ground_y * 0.92
	var tree_display_w := tree_display_h * 0.625
	var tree_rect := Rect2(tree_cx - tree_display_w * 0.5, ground_y - tree_display_h + 8.0, tree_display_w, tree_display_h)

	var has_art := _tree_textures.size() > 0 and _tree_textures[0] != null
	if not has_art:
		draw_rect(Rect2(0, ground_y, size.x, size.y - ground_y), _ground_color)

	# Thân cây: 8 giai đoạn rời rạc
	var st := stage()

	if st < _tree_textures.size() and _tree_textures[st] != null:
		draw_texture_rect(_tree_textures[st], tree_rect, false)
	else:
		var full_h := size.y * 0.78
		var frac := SPROUT_FRACTION + (1.0 - SPROUT_FRACTION) * (float(st) / float(STAGES - 1))
		var h := full_h * frac
		var w := size.x * 0.035
		if h > 1.0:
			draw_rect(Rect2(tree_cx - w * 0.5, ground_y - h, w, h), _trunk_color)

	# Cả 7 lá LUÔN hiển thị
	for i in Notes.count():
		_draw_leaf(i, _leaf_anchor(i))

	if _fruiting:
		var fruit_top := Vector2(tree_cx, tree_rect.position.y + 0.16 * tree_display_h)
		_draw_fruit(fruit_top)


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
			draw_circle(p, r * 0.85, Color(base, 0.25))
			if _leaf_texture != null:
				draw_texture_rect(_leaf_texture, Rect2(p.x - leaf_size * 0.5, p.y - leaf_size * 0.5, leaf_size, leaf_size), false, Color(base, 0.70))
			else:
				draw_circle(p, r, Color(base, 0.40))
			draw_string(font, p + Vector2(-5, 5), sym, HORIZONTAL_ALIGNMENT_CENTER, -1, 13, Color(1, 1, 1, 0.85))
		LeafState.SINGING:
			draw_circle(p, r * 1.35, Color(base, 0.45))
			if _leaf_texture != null:
				var s := leaf_size * 1.25
				draw_texture_rect(_leaf_texture, Rect2(p.x - s * 0.5, p.y - s * 0.5, s, s), false, Color.WHITE)
			else:
				draw_circle(p, r * 1.25, Color(base, 0.95))
			draw_string(font, p + Vector2(-6, 6), sym, HORIZONTAL_ALIGNMENT_CENTER, -1, 15, Color.WHITE)
		LeafState.HINT:
			var pulse := 0.5 + 0.5 * sin(_time * 2.8)
			draw_circle(p, r * (1.1 + 0.3 * pulse), Color(1, 1, 1, 0.2 + 0.25 * pulse))
			if _leaf_texture != null:
				var s := leaf_size * (1.05 + 0.2 * pulse)
				var c := Color(base.lerp(Color.WHITE, 0.45 * pulse), 0.8 + 0.2 * pulse)
				draw_texture_rect(_leaf_texture, Rect2(p.x - s * 0.5, p.y - s * 0.5, s, s), false, c)
			else:
				draw_circle(p, r * (1.0 + 0.22 * pulse), Color(base, 0.5 + 0.5 * pulse))
			draw_string(font, p + Vector2(-6, 6), sym, HORIZONTAL_ALIGNMENT_CENTER, -1, 15, Color(1, 1, 1, 0.95))
		LeafState.BLOOMED:
			draw_circle(p, r * 1.25, Color("#F2C64B", 0.45))
			if _leaf_texture != null:
				var s := leaf_size * 1.15
				draw_texture_rect(_leaf_texture, Rect2(p.x - s * 0.5, p.y - s * 0.5, s, s), false, Color("#F2C64B"))
			else:
				draw_circle(p, r * 1.35, Color("#F2C64B"))
				draw_circle(p, r * 1.05, base)
			draw_string(font, p + Vector2(-6, 6), "★", HORIZONTAL_ALIGNMENT_CENTER, -1, 15, Color.WHITE)



func _draw_fruit(top: Vector2) -> void:
	var t := _time * 3.0
	var gold := Color("#F2C64B")
	for k in 6:
		var a := TAU * k / 6.0 + t * 0.35
		var rr := size.y * 0.10 * (1.0 + 0.12 * sin(t + k))
		draw_circle(top + Vector2(cos(a), sin(a)) * rr, size.y * 0.022, gold)

	# Rương báu mở
	if _chest_open_texture != null:
		var cs := size.y * 0.22
		var rect := Rect2(top.x - cs * 0.5, top.y - cs * 0.85, cs, cs)
		draw_texture_rect(_chest_open_texture, rect, false)
	else:
		var cw := size.x * 0.07
		var ch := size.y * 0.06
		draw_rect(Rect2(top.x - cw * 0.5, top.y - ch * 1.6, cw, ch), Color("#8a5a2b"))
		draw_rect(Rect2(top.x - cw * 0.5, top.y - ch * 1.6, cw, ch * 0.28), gold)
