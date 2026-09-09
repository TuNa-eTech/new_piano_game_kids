class_name CallResponse
extends Node
## Vòng lặp chơi gọi–đáp (docs/gameplay-design.html · Quyết định 03).
##
## KHÔNG có cửa sổ thời gian, KHÔNG có note highway, KHÔNG có "Perfect/Good/Miss".
## Game hát trước, rồi chờ bé — chờ vô hạn. Lý do trong tài liệu: chấm điểm theo
## nhịp là hình phạt vô nghĩa với trẻ 4 tuổi, và độ trễ audio khiến mọi cơ chế
## chấm nhịp đều cảm giác hỏng.
##
## Nguyên tắc bất di bất dịch: KHÔNG CÓ TRẠNG THÁI SAI. Phím nào cũng kêu hay,
## phím nào cũng làm cây cao thêm. Bấm sai chỉ đơn giản là chuỗi gợi ý đứng yên
## chờ tiếp — bé thử lại bao nhiêu lần cũng được.

signal page_completed(page_index: int)

enum State { LEAD_IN, SINGING, WAITING, FRUITING, PAGE_TURN }

const SING_LEAD_IN := 0.6
const SING_INTERVAL := 0.55      ## 3 nốt ~1,6 s · 7 nốt ~3,9 s → đúng "2–4 giây"
const SING_TAIL := 0.35
const IDLE_HINT_SECONDS := 8.0   ## Quyết định 03: "sau 8 giây không chạm"
const FRUIT_SECONDS := 3.0       ## "thiết kế nó như một cảnh phim ngắn 3 giây"
const FRUIT_REPLAY_INTERVAL := 0.22
const PAGE_TURN_SECONDS := 1.2

var _tree: MagicTree
var _keyboard: PianoKeyboard

var _state: State = State.LEAD_IN
var _timer: float = 0.0
var _sequence: PackedInt32Array = PackedInt32Array()
var _step: int = 0            ## vị trí trong chuỗi mà bé cần chạm tiếp
var _sing_index: int = 0
var _idle: float = 0.0
var _replay_index: int = 0


func _ready() -> void:
	# Đứng im cho tới khi main.gd nối dây. Node con chạy _ready() TRƯỚC node cha,
	# nên tự đi tìm tham chiếu ở đây sẽ mong manh — để phía sở hữu scene trao
	# tham chiếu vào thì thứ tự luôn đúng và test cũng dễ hơn.
	set_process(false)


func setup(tree: MagicTree, keyboard: PianoKeyboard) -> void:
	_tree = tree
	_keyboard = keyboard
	if _tree == null or _keyboard == null:
		push_error("CallResponse: thiếu MagicTree hoặc PianoKeyboard")
		return
	_keyboard.note_played.connect(_on_note_played)
	_begin_page()
	set_process(true)


# ------------------------------------------------------------------ vòng đời --

func _begin_page() -> void:
	_sequence = Melodies.for_page(GameState.page_index)
	_step = 0
	_sing_index = 0
	_idle = 0.0
	_tree.reset_page()
	_tree.set_sequence(_sequence)
	_enter(State.LEAD_IN)


func _enter(next: State) -> void:
	_state = next
	_timer = 0.0
	match next:
		State.SINGING:
			_sing_index = 0
		State.WAITING:
			_tree.clear_singing()
			_idle = 0.0
			_refresh_hint()
		State.FRUITING:
			_replay_index = 0
			_tree.fruit()
		State.PAGE_TURN:
			pass


func _process(delta: float) -> void:
	_timer += delta
	match _state:
		State.LEAD_IN:
			if _timer >= SING_LEAD_IN:
				_enter(State.SINGING)
		State.SINGING:
			_tick_singing()
		State.WAITING:
			_tick_waiting(delta)
		State.FRUITING:
			_tick_fruiting()
		State.PAGE_TURN:
			if _timer >= PAGE_TURN_SECONDS:
				GameState.advance_page()
				_begin_page()


## Bước 1 — Cây hát: cây tự sáng các lá theo thứ tự, mỗi lá phát nốt của nó.
func _tick_singing() -> void:
	var due := int(_timer / SING_INTERVAL)
	while _sing_index < _sequence.size() and due > _sing_index:
		var note: int = _sequence[_sing_index]
		_tree.clear_singing()
		_tree.sing_leaf(note)
		AudioDirector.play_note(note)
		_sing_index += 1
	if _sing_index >= _sequence.size() and _timer >= _sequence.size() * SING_INTERVAL + SING_TAIL:
		_enter(State.WAITING)


## Bước 2 — Cây chờ: không đồng hồ, không thanh thời gian. Sau 8 giây im lặng,
## con vật tương ứng ngân nhẹ nốt của mình để nhắc.
func _tick_waiting(delta: float) -> void:
	_idle += delta
	if _idle >= IDLE_HINT_SECONDS:
		_idle = 0.0
		if _step < _sequence.size():
			AudioDirector.play_note_pitched(_sequence[_step], 1.0, -10.0)


## Bước 4 — Cây trổ quả: cả 7 con vật cùng hát lại giai điệu vừa xong.
func _tick_fruiting() -> void:
	var due := int(_timer / FRUIT_REPLAY_INTERVAL)
	while _replay_index < _sequence.size() and due > _replay_index:
		AudioDirector.play_note_pitched(_sequence[_replay_index], 1.0, -3.0)
		_replay_index += 1
	if _timer >= FRUIT_SECONDS:
		_enter(State.PAGE_TURN)


# --------------------------------------------------------------------- input --

## Bé chạm phím. Hàm này KHÔNG bao giờ chặn hay phạt — bàn phím đã phát tiếng
## trước khi tín hiệu này tới đây.
func _on_note_played(note_index: int) -> void:
	_idle = 0.0

	if _state != State.WAITING or _step >= _sequence.size():
		# Ngoài lúc chờ đáp thì vẫn là chơi tự do: cây vẫn cao thêm một chút.
		_tree.grow_free()
		return

	if note_index != _sequence[_step]:
		# Phím khác: vẫn kêu hay, lá thường mọc thêm, chuỗi giữ nguyên vị trí.
		_tree.grow_free()
		return

	# Nốt đúng: lá nở thành nốt vàng, thân cây vươn lên, hạt sao rơi vào lọ.
	_tree.bloom(note_index, _sequence.size())
	GameState.award_star()
	AudioDirector.play_ting()
	_step += 1

	if _step >= _sequence.size():
		_enter(State.FRUITING)
		page_completed.emit(GameState.page_index)
	else:
		_refresh_hint()


func _refresh_hint() -> void:
	if _step < _sequence.size():
		_tree.set_hint(_sequence[_step])


# ----------------------------------------------------------------- chẩn đoán --

## Nốt mà chuỗi đang chờ, hoặc -1 nếu không ở lúc chờ đáp.
## Dùng cho overlay chẩn đoán và cho máy đo vòng chơi.
func expected_note() -> int:
	if _state == State.WAITING and _step < _sequence.size():
		return _sequence[_step]
	return -1


func sequence_length() -> int:
	return _sequence.size()


func step() -> int:
	return _step


## State.keys() cấp phát một mảng mới MỖI LẦN GỌI. Overlay chẩn đoán gọi hàm này
## mỗi khung hình, nên dùng bảng hằng thay vì tra ngược enum.
## Chỉ literal mới là biểu thức hằng — bọc PackedStringArray(...) vào là lời gọi
## constructor và const sẽ không biên dịch. Đúng cái bẫy đã ghi ở notes.gd.
const STATE_NAMES := ["LEAD_IN", "SINGING", "WAITING", "FRUITING", "PAGE_TURN"]


func state_name() -> String:
	return STATE_NAMES[_state]


func progress() -> String:
	return "%d/%d" % [_step, _sequence.size()]
