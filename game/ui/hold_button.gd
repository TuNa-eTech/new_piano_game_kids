class_name HoldButton
extends Control
## Nút phải GIỮ mới ăn — khoá nhẹ của nút Menu (Quyết định 03: "giữ 2 giây,
## đủ để bé không thoát nhầm, không cản người lớn").
##
## Viết tách riêng vì Tuần 4 dùng lại: cổng phụ huynh đầy đủ ở luồng lưu clip
## cũng là một cửa có ma sát, chỉ khác độ khó.
##
## PHẢI NHÌN THẤY TIẾN TRÌNH GIỮ. Không có phản hồi thì người lớn tưởng nút hỏng
## và bé học được rằng chạm không có tác dụng — hỏng cả hai vế của câu "chặn bé
## mà không cản người lớn". Vòng tròn ở đây đầy dần trong lúc giữ.
##
## Vì sao _input chứ không _gui_input: cần đếm SỐ NGÓN ĐANG CHẠM TRÊN CẢ MÀN
## HÌNH, mà _gui_input chỉ thấy những ngón rơi trúng nút này. _input nhận mọi
## sự kiện trước hệ GUI nên đếm được đủ.

signal activated
signal hold_progress(ratio: float)

## Quyết định 03 chốt 2 giây.
@export var hold_seconds: float = 2.0

## Nhả sớm thì vòng chạy ngược về 0 chứ không tắt phụt — người lớn cần thấy
## mình đã giữ được bao nhiêu và vì sao chưa đủ.
const RELEASE_SECONDS := 0.3

## Apple HIG 44 pt, trên màn Retina là 88 px.
const MIN_TOUCH_SIZE := 88.0

const RING_WIDTH := 6.0
const BAR_COUNT := 3

var _finger: int = -1
## SỐ ngón đang chạm màn hình, không riêng gì ngón trên nút.
##
## Đếm bằng int chứ không giữ một Dictionary các chỉ số ngón: node này nghe MỌI
## sự kiện chạm của cả game, tức là nó nằm trên đường nóng chạm→âm thanh. Chèn
## và xoá khoá Dictionary ở đó làm mức trôi bộ nhớ nhích từ 0,006 lên 0,008 KB
## mỗi cú chạm — đo được, nên sửa được.
var _touch_count: int = 0
var _held: float = 0.0
var _ratio: float = 0.0

@onready var _base_color := Color("#2a3a2c")
@onready var _ring_color := Color("#E8D9A0")


func _ready() -> void:
	# Nút tự hit-test trong _input, nên không cần hệ GUI của Control.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(MIN_TOUCH_SIZE, MIN_TOUCH_SIZE)
	if size.x < MIN_TOUCH_SIZE or size.y < MIN_TOUCH_SIZE:
		push_warning(
			"HoldButton: %.0f×%.0f px, dưới mức 88 px (Apple HIG 44 pt ×2)"
			% [size.x, size.y]
		)


## App xuống nền giữa lúc đang giữ nút thì sự kiện NHẢ ngón KHÔNG BAO GIỜ tới.
## Bộ đếm kẹt ở 1, và từ đó mọi lượt giữ mới đều bị coi là ngón thứ hai rồi bị
## bỏ — nút Menu chết câm, bé lẫn người lớn đều mất đường vào bản đồ. Bấm nút
## rồi bị phân tâm là việc một đứa 4 tuổi làm suốt, nên đây không phải ca hiếm.
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED, \
		NOTIFICATION_APPLICATION_RESUMED, \
		NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			cancel()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_on_touch(event)
	elif event is InputEventScreenDrag and event.index == _finger:
		# Ngón trượt ra khỏi nút thì bỏ — cử chỉ không còn là "giữ nút này" nữa.
		if not _contains(event.position):
			_abort_hold()


func _on_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touch_count += 1
		if _touch_count > 1:
			# Bàn tay trẻ con úp lên màn hình là nhiều điểm chạm cùng lúc. Một
			# lòng bàn tay đè trúng nút 2 giây KHÔNG được tính là cố ý mở menu —
			# đó đúng là thứ khoá nhẹ sinh ra để chặn.
			#
			# Bỏ lượt giữ nhưng GIỮ NGUYÊN bộ đếm: đặt lại về 0 ở đây thì ngón thứ
			# ba của cùng bàn tay đó lại thành "ngón duy nhất" và mở được menu.
			_abort_hold()
			return
		if _finger == -1 and _contains(event.position):
			_finger = event.index
			_held = 0.0
			get_viewport().set_input_as_handled()
	else:
		_touch_count = maxi(0, _touch_count - 1)
		if event.index == _finger:
			_finger = -1
			_held = 0.0
			get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	var before := _ratio
	if _finger != -1:
		_held += delta
		_ratio = minf(1.0, _held / maxf(0.01, hold_seconds))
		if _ratio >= 1.0:
			_finger = -1
			_held = 0.0
			_ratio = 0.0
			activated.emit()
	elif _ratio > 0.0:
		_ratio = maxf(0.0, _ratio - delta / RELEASE_SECONDS)

	if not is_equal_approx(before, _ratio):
		hold_progress.emit(_ratio)
		queue_redraw()


## Bỏ lượt giữ đang dở, nhưng vẫn nhớ những ngón nào còn trên màn hình.
func _abort_hold() -> void:
	_finger = -1
	_held = 0.0


## Bỏ sạch, kể cả bộ đếm ngón. Gọi khi lớp phủ đóng lại: lúc cây bị dừng, node
## này không nhận được sự kiện NHẢ ngón nào cả, nên bộ đếm sẽ kẹt ở số dương và
## nút từ chối mọi lượt giữ sau đó nếu không dọn.
func cancel() -> void:
	_abort_hold()
	_touch_count = 0
	if _ratio > 0.0:
		queue_redraw()


func progress() -> float:
	return _ratio


func is_holding() -> bool:
	return _finger != -1


func _contains(viewport_position: Vector2) -> bool:
	# Project dùng stretch canvas_items + expand, nên toạ độ viewport KHÔNG bằng
	# toạ độ local. Đổi hệ trước rồi mới so — y hệt PianoKeyboard._key_at().
	var local := get_global_transform().affine_inverse() * viewport_position
	return Rect2(Vector2.ZERO, size).has_point(local)


func _draw() -> void:
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.5 - RING_WIDTH

	draw_circle(c, r, _base_color)
	draw_arc(c, r, 0.0, TAU, 48, _ring_color.darkened(0.55), RING_WIDTH, true)

	# Ba vạch ngang: biểu tượng menu quen thuộc với người lớn, còn bé thì chỉ
	# thấy một hình tròn không có con vật nào trong đó — không mời gọi chạm.
	var bar_w := r * 0.9
	var gap := r * 0.34
	for i in BAR_COUNT:
		var y := c.y + (i - 1) * gap
		draw_line(
			Vector2(c.x - bar_w * 0.5, y),
			Vector2(c.x + bar_w * 0.5, y),
			_ring_color, 4.0, true
		)

	if _ratio > 0.0:
		# Chạy từ 12 giờ theo chiều kim đồng hồ — hướng mà mọi đồng hồ đếm ngược
		# đều chạy, nên không cần ai giải thích.
		draw_arc(
			c, r, -PI * 0.5, -PI * 0.5 + TAU * _ratio,
			48, _ring_color, RING_WIDTH, true
		)
