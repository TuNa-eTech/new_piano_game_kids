class_name PauseOverlay
extends CanvasLayer
## Lớp phủ dừng ván chơi. NƠI DUY NHẤT trong game được ghi vào get_tree().paused.
##
## Vì sao phải có một chủ sở hữu duy nhất: nếu bản đồ chương và màn kết chương
## mỗi bên tự bật/tắt cờ đó, chỉ cần hai lớp phủ chồng nhau một nhịp là lớp đóng
## trước sẽ cho ván chơi chạy lại TRONG KHI lớp kia vẫn phủ kín màn hình — bé
## nghe tiếng đàn phát ra từ một bàn phím không nhìn thấy.
##
## NGĂN XẾP, KHÔNG PHẢI BỘ ĐẾM (đổi ở Giai Đoạn 1 — xem docs/architecture-refactor.md).
## Trước đây chỗ này là một biến đếm `_open_count`. Bộ đếm chỉ biết "có mấy lớp đang
## mở", không biết LÀ NHỮNG LỚP NÀO, nên nó trôi số trong đúng ba tình huống đã thật
## sự xảy ra và phải vá bằng câu lệnh phòng thủ rải rác trong ScreenRouter:
##   ① mở một lớp đã mở sẵn  -> đếm lên 2, đóng một lần không đủ để ván chơi chạy lại;
##   ② đóng một lớp đã đóng  -> đếm xuống âm (phải maxi(0, ...) che đi);
##   ③ lớp bị queue_free lúc đang mở -> đếm không bao giờ về 0, game kẹt paused vĩnh viễn.
## Ngăn xếp giữ CHÍNH các đối tượng nên cả ba đều biến mất: has()/erase() vốn đã
## bất biến theo phép lặp, và mục chết được dọn trong _prune().
##
## BẤT BIẾN: ván chơi chạy lại khi và CHỈ KHI ngăn xếp rỗng.
##
## Ngăn xếp SÂU ≥ 2 là hợp lệ, không phải lỗi: ParentalGate (layer 20) chồng lên
## GoodnightScreen (layer 18) là luồng đúng thiết kế — Apple Kids 1.3 bắt phải hỏi
## người lớn trước khi đánh thức app. Thứ tự chồng do `layer` của CanvasLayer quyết
## định, và lớp nền mờ MOUSE_FILTER_STOP của lớp trên chặn chạm xuống lớp dưới.
##
## Ván chơi bên dưới bị chặn bằng hai lớp độc lập, đã đo chứ không đoán:
##   ① get_tree().paused chặn _unhandled_input của node PROCESS_MODE_INHERIT;
##   ② nền mờ là Control MOUSE_FILTER_STOP phủ kín, cũng chặn _unhandled_input.

signal opened
signal closed

const FADE_SECONDS := 0.18

## Các lớp phủ đang mở, dưới → trên. Phần tử cuối là lớp đang ở đỉnh.
static var _stack: Array[PauseOverlay] = []

var _backdrop: ColorRect
var _fade_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_set_controls_visible(false)


## Node bị giải phóng lúc còn đang mở thì phải rời ngăn xếp, nếu không ván chơi
## kẹt paused vĩnh viễn — đây chính là lỗi ③ mà bộ đếm cũ không thể tự thoát.
func _exit_tree() -> void:
	if _stack.has(self):
		_stack.erase(self)
		_sync_pause()


func _set_controls_visible(val: bool) -> void:
	for child in get_children():
		if child is Control:
			child.visible = val


## Nền mờ phủ kín. Gọi từ _build() của lớp con, TRƯỚC khi thêm nội dung, để nó
## nằm dưới cùng.
func _add_backdrop(color: Color) -> ColorRect:
	_backdrop = ColorRect.new()
	_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_backdrop.color = color
	# STOP chứ không IGNORE: nền này là lớp chặn chạm thứ hai cho bàn phím.
	_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_backdrop)
	return _backdrop


func open_overlay() -> void:
	if visible:
		return
	visible = true
	_set_controls_visible(true)
	# has() trước khi append: mở lại một lớp đã nằm trong ngăn xếp không được
	# nhân đôi mục. `visible` ở trên đã chặn hầu hết, đây là chốt thứ hai.
	if not _stack.has(self):
		_stack.append(self)
	_sync_pause()
	_fade(0.0, 1.0)
	opened.emit()


func close_overlay() -> void:
	if not visible:
		return
	visible = false
	_set_controls_visible(false)
	_stack.erase(self)
	_sync_pause()
	_fade(1.0, 0.0)
	closed.emit()


func is_open() -> bool:
	return visible


## Lớp phủ này có đang ở đỉnh ngăn xếp không — tức là lớp bé đang thật sự nhìn
## và chạm được.
func is_top() -> bool:
	return not _stack.is_empty() and _stack[_stack.size() - 1] == self


## Dọn các mục đã bị giải phóng. Godot có thể free một node mà không gọi
## _exit_tree theo thứ tự ta mong đợi lúc cây đang bị tháo, nên vẫn phải quét.
static func _prune() -> void:
	var i := _stack.size() - 1
	while i >= 0:
		if not is_instance_valid(_stack[i]):
			_stack.remove_at(i)
		i -= 1


## Nguồn sự thật duy nhất của cờ paused. Mọi đường mở/đóng đều đi qua đây.
func _sync_pause() -> void:
	_prune()
	var tree := get_tree()
	if tree == null:
		return
	tree.paused = not _stack.is_empty()


## Tween mặc định dừng theo node bị pause. Node này ALWAYS nên nó vẫn chạy, còn
## TWEEN_PAUSE_PROCESS là lời khẳng định tường minh — hoạt cảnh kẹt nửa chừng
## đúng lúc cây đang dừng là lỗi rất khó lần ra.
func _fade(from: float, to: float) -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	for child in get_children():
		if child is CanvasItem:
			child.modulate.a = from
	_fade_tween = create_tween().bind_node(self)
	_fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_fade_tween.set_parallel(true)
	for child in get_children():
		if child is CanvasItem:
			_fade_tween.tween_property(child, "modulate:a", to, FADE_SECONDS)


## Lớp phủ đang ở đỉnh, hoặc null nếu ván chơi không bị lớp nào phủ.
static func top_overlay() -> PauseOverlay:
	_prune()
	if _stack.is_empty():
		return null
	return _stack[_stack.size() - 1]


static func open_overlay_count() -> int:
	_prune()
	return _stack.size()


## Biến static sống qua cả lần dựng lại scene trong cùng một tiến trình, nên máy
## đo dựng main.tscn nhiều lần sẽ thấy ngăn xếp trôi nếu không dọn.
static func reset_pause_state() -> void:
	_stack.clear()
