class_name PianoKeyboard
extends Control
## BỀ MẶT TƯƠNG TÁC DUY NHẤT của game (docs/gameplay-design.html · Quyết định 01).
##
## Khung truyện phía trên chỉ hiển thị, không nhận input. Mọi Control khác phải
## đặt mouse_filter = IGNORE, nếu không chúng nuốt sự kiện trước khi tới đây.
##
## Vì sao tự hit-test thay vì dùng TouchScreenButton: TouchScreenButton là Node2D,
## không tham gia layout của Control — mà tài liệu lại đòi "neo phím đàn theo cạnh
## dưới" và "kiểm ở tỉ lệ 20:9", đúng việc anchor của Control làm sẵn.

signal note_played(index: int)
signal note_released(index: int)

const KEY_GAP := 6.0
const BLACK_KEY_W_RATIO := 0.56
const BLACK_KEY_H_RATIO := 0.58
## Vị trí phím đen: nằm giữa cặp phím trắng (i, i+1). Chỉ để giữ dáng đàn piano
## trong ảnh mock — KHÔNG nhận chạm, và cũng làm vùng chạm phím trắng rộng hơn.
const BLACK_KEY_SLOTS := [0, 1, 3, 4, 5]

## Vùng chạm tối thiểu: Apple HIG 44 pt, trên màn Retina là 88 px.
const MIN_KEY_WIDTH_PX := 88.0

var _key_rects: Array[Rect2] = []
var _keys: Array[AnimalKey] = []
## ngón (event.index) -> chỉ số phím đang giữ. Đa chạm thật: bé sẽ đập cả bàn tay.
var _finger_to_key: Dictionary = {}

@onready var _black_layer: Control = $BlackKeys


func _ready() -> void:
	# Bản thân bàn phím không dùng hệ thống _gui_input của Control —
	# nó bắt sự kiện thô ở _unhandled_input để đường chạm ngắn nhất có thể.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_black_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_black_layer.draw.connect(_draw_black_keys)

	_build_keys()
	resized.connect(_layout_keys)
	_layout_keys()


func _build_keys() -> void:
	var scene := preload("res://game/piano/animal_key.tscn")
	for i in Notes.count():
		var key: AnimalKey = scene.instantiate()
		add_child(key)
		key.setup(i)
		_keys.append(key)
	_key_rects.resize(Notes.count())
	# Phím đen phải vẽ ĐÈ LÊN phím trắng, mà thứ tự vẽ là thứ tự con trong cây —
	# nên đẩy lớp phím đen xuống cuối sau khi đã dựng xong 7 phím trắng.
	move_child(_black_layer, get_child_count() - 1)


## Tính lại ô chữ nhật của từng phím. ĐÂY LÀ NGUỒN DUY NHẤT cho cả hit-test lẫn
## vị trí hiển thị — hai thứ không thể lệch nhau vì chúng đọc cùng một mảng.
##
## Bẫy đã biết: project dùng stretch canvas_items + expand, và ghi chú migration
## của Godot cảnh báo phải kiểm lại ánh xạ toạ độ chạm trên cửa sổ đổi kích thước.
## Vì vậy hit-test chạy trong TOẠ ĐỘ LOCAL của Control này, không dùng thẳng
## event.position của viewport.
func _layout_keys() -> void:
	var n := Notes.count()
	if n == 0:
		return

	var total := size
	var key_w := (total.x - KEY_GAP * (n - 1)) / float(n)
	var key_h := total.y

	if key_w < MIN_KEY_WIDTH_PX:
		push_warning(
			"PianoKeyboard: phím rộng %.1f px, dưới mức 88 px (Apple HIG 44 pt ×2)"
			% key_w
		)

	for i in n:
		var r := Rect2(Vector2(i * (key_w + KEY_GAP), 0.0), Vector2(key_w, key_h))
		_key_rects[i] = r
		_keys[i].position = r.position
		_keys[i].size = r.size
		_keys[i].pivot_offset = r.size * 0.5

	_black_layer.queue_redraw()


func _draw_black_keys() -> void:
	# Phím đen chỉ trang trí — không nằm trong _key_rects nên không thể chạm.
	if _key_rects.is_empty():
		return
	var key_w: float = _key_rects[0].size.x
	var bw := key_w * BLACK_KEY_W_RATIO
	var bh := size.y * BLACK_KEY_H_RATIO
	for slot in BLACK_KEY_SLOTS:
		if slot + 1 >= _key_rects.size():
			continue
		var boundary: float = _key_rects[slot].end.x + KEY_GAP * 0.5
		_black_layer.draw_rect(
			Rect2(Vector2(boundary - bw * 0.5, 0.0), Vector2(bw, bh)),
			Color(0.09, 0.08, 0.12, 0.95)
		)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		var key := _key_at(event.position)
		if key == -1:
			return
		_finger_to_key[event.index] = key
		_strike(key)
		get_viewport().set_input_as_handled()
	else:
		if not _finger_to_key.has(event.index):
			return
		var key: int = _finger_to_key[event.index]
		_finger_to_key.erase(event.index)
		_keys[key].release()
		note_released.emit(key)


## Ngón trượt ngang qua phím khác thì phím mới kêu — trẻ con vuốt cả bàn tay
## dọc bàn phím, và với thang ngũ cung thì kiểu gì cũng thuận tai.
func _handle_drag(event: InputEventScreenDrag) -> void:
	if not _finger_to_key.has(event.index):
		return
	var previous: int = _finger_to_key[event.index]
	var current := _key_at(event.position)
	if current == -1 or current == previous:
		return
	_keys[previous].release()
	note_released.emit(previous)
	_finger_to_key[event.index] = current
	_strike(current)


func _strike(key: int) -> void:
	# Âm thanh TRƯỚC, hình ảnh sau: độ trễ nghe được, còn một khung hình thì không.
	AudioDirector.play_note(key)
	_keys[key].press()
	GameState.note_was_played(key)
	note_played.emit(key)


## Trả về chỉ số phím tại một điểm trong toạ độ viewport, hoặc -1.
func _key_at(viewport_position: Vector2) -> int:
	var local := get_global_transform().affine_inverse() * viewport_position
	for i in _key_rects.size():
		if _key_rects[i].has_point(local):
			return i
	return -1


func fingers_down() -> int:
	return _finger_to_key.size()
