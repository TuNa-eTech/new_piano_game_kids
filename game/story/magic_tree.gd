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


func _ready() -> void:
	# Khung truyện chỉ hiển thị — không bao giờ nuốt sự kiện chạm.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_leaf_state.resize(Notes.count())
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

func _leaf_anchor(i: int) -> Vector2:
	## Lá xếp so le hai bên thân, cao dần theo chỉ số nốt.
	var base := size.y * 0.92
	var top := size.y * 0.16
	var t := (i + 1.0) / (Notes.count() + 1.0)
	var y := lerpf(base, top, t)
	var dx := size.x * 0.085 * (1.0 if i % 2 == 0 else -1.0)
	return Vector2(size.x * 0.5 + dx, y)


func _draw() -> void:
	var ground_y := size.y * 0.94
	draw_rect(Rect2(0, ground_y, size.x, size.y - ground_y), _ground_color)

	# Thân cây: 8 giai đoạn rời rạc, không nội suy — để nhìn rõ từng nấc lớn lên.
	var st := stage()
	var full_h := size.y * 0.78
	# Chừa sẵn một mầm ở giai đoạn 0 — trước đây thân cao 0 nên đầu mỗi trang
	# khung truyện trống trơn, mà "cây hát" lại là bước ĐẦU TIÊN của vòng chơi.
	var frac := SPROUT_FRACTION + (1.0 - SPROUT_FRACTION) * (float(st) / float(STAGES - 1))
	var h := full_h * frac
	var w := size.x * 0.035
	if h > 1.0:
		draw_rect(Rect2(size.x * 0.5 - w * 0.5, ground_y - h, w, h), _trunk_color)

	var trunk_top := ground_y - h
	# Cả 7 lá LUÔN hiển thị. Lá là chỗ đứng cố định (LeafSlots trong thiết kế),
	# và câu "gọi" của cây là làm lá sáng lên — nếu ẩn lá theo chiều cao thân thì
	# bé không nhìn thấy cây hát gì cả. Thân cây lớn lên mới là phần thưởng.
	for i in Notes.count():
		_draw_leaf(i, _leaf_anchor(i))

	if _fruiting:
		_draw_fruit(Vector2(size.x * 0.5, trunk_top))


## Vòng nhẫn vẽ bằng HAI draw_circle lồng nhau chứ không dùng draw_arc.
## draw_arc dựng một mảng điểm mới mỗi lần gọi, mà lá gợi ý nhấp nháy nên hàm
## này chạy mỗi khung hình — đã đo thấy nó làm bộ nhớ trôi lên rõ rệt.
func _draw_leaf(i: int, p: Vector2) -> void:
	var base := Notes.color_of(i)
	var r := size.y * 0.045
	match _leaf_state[i]:
		LeafState.DORMANT:
			draw_circle(p, r, Color(base, 0.30))
		LeafState.SINGING:
			draw_circle(p, r * 1.25, Color(base, 0.95))
		LeafState.HINT:
			# "nhấp nháy nhẹ theo nhịp thở" — chậm, không giật.
			var pulse := 0.5 + 0.5 * sin(_time * 2.6)
			draw_circle(p, r * 1.52, Color(1, 1, 1, 0.16 + 0.22 * pulse))
			draw_circle(p, r * (1.0 + 0.22 * pulse), Color(base, 0.45 + 0.5 * pulse))
		LeafState.BLOOMED:
			draw_circle(p, r * 1.42, Color("#F2C64B"))
			draw_circle(p, r * 1.1, base)


func _draw_fruit(top: Vector2) -> void:
	var t := _time * 3.0
	var gold := Color("#F2C64B")
	for k in 6:
		var a := TAU * k / 6.0 + t * 0.35
		var rr := size.y * 0.10 * (1.0 + 0.12 * sin(t + k))
		draw_circle(top + Vector2(cos(a), sin(a)) * rr, size.y * 0.022, gold)
	# Rương báu
	var cw := size.x * 0.07
	var ch := size.y * 0.06
	draw_rect(Rect2(top.x - cw * 0.5, top.y - ch * 1.6, cw, ch), Color("#8a5a2b"))
	draw_rect(Rect2(top.x - cw * 0.5, top.y - ch * 1.6, cw, ch * 0.28), gold)
