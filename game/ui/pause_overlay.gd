class_name PauseOverlay
extends CanvasLayer
## Lớp phủ dừng ván chơi. NƠI DUY NHẤT trong game được ghi vào get_tree().paused.
##
## Vì sao phải có một chủ sở hữu duy nhất: nếu bản đồ chương và màn kết chương
## mỗi bên tự bật/tắt cờ đó, chỉ cần hai lớp phủ chồng nhau một nhịp là lớp đóng
## trước sẽ cho ván chơi chạy lại TRONG KHI lớp kia vẫn phủ kín màn hình — bé
## nghe tiếng đàn phát ra từ một bàn phím không nhìn thấy. Đếm chồng làm cờ chỉ
## tắt khi lớp phủ CUỐI CÙNG đóng.
##
## Ván chơi bên dưới bị chặn bằng hai lớp độc lập, đã đo chứ không đoán:
##   ① get_tree().paused chặn _unhandled_input của node PROCESS_MODE_INHERIT;
##   ② nền mờ là Control MOUSE_FILTER_STOP phủ kín, cũng chặn _unhandled_input.

signal opened
signal closed

const FADE_SECONDS := 0.18

static var _open_count: int = 0

var _backdrop: ColorRect
var _fade_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


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
	_open_count += 1
	get_tree().paused = true
	_fade(0.0, 1.0)
	opened.emit()


func close_overlay() -> void:
	if not visible:
		return
	visible = false
	_open_count = maxi(0, _open_count - 1)
	if _open_count == 0:
		get_tree().paused = false
	closed.emit()


func is_open() -> bool:
	return visible


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


static func open_overlay_count() -> int:
	return _open_count


## Biến static sống qua cả lần dựng lại scene trong cùng một tiến trình, nên máy
## đo dựng main.tscn nhiều lần sẽ thấy bộ đếm trôi nếu không dọn.
static func reset_pause_state() -> void:
	_open_count = 0
