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
signal phrase_completed(phrase_index: int)
signal prompt_updated(prompt_text: String)
signal page_turn_started

## FREE là Chơi Tự Do: không hát gọi, không gợi ý, không chuỗi — chỉ đàn, con
## vật và cây mọc theo mỗi nốt (Quyết định 03). Nó là một TRẠNG THÁI chứ không
## phải một lá cờ rải rác, để chỉ có đúng một chỗ quyết định vòng chơi đang làm gì.
enum State { LEAD_IN, SINGING, WAITING, FRUITING, PAGE_TURN, FREE }

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
var _phrase_index: int = 0    ## câu hát hiện tại trong bài hát
var _sing_index: int = 0
var _idle: float = 0.0
var _replay_index: int = 0
## Trang mà vòng chơi ĐANG chơi. Khác GameState.page_index thì phải dựng lại
## trang — bản đồ chương đổi trang từ bên ngoài, không đi qua đây.
var _page: int = -1


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
	GameState.free_play_changed.connect(_on_free_play_changed)
	# Bé chọn chương trên bản đồ thì trang đổi mà không ai báo cho vòng chơi.
	GameState.page_changed.connect(_on_page_changed)
	_begin_page(true)
	set_process(true)


# ------------------------------------------------------------------ vòng đời --

func _begin_page(first: bool = false) -> void:
	_page = clampi(GameState.page_index, 0, Songbook.count() - 1) if Songbook.count() > 0 else GameState.page_index
	_phrase_index = 0
	_load_phrase()
	_step = 0
	_sing_index = 0
	_idle = 0.0
	_tree.reset_page()
	_tree.set_sequence(_sequence)

	# Phát nhạc nền backing track chuẩn 10 bài hát của Songbook
	if Songbook.is_valid(_page):
		var song := Songbook.get_song(_page)
		var bgm_path: String = song.get("bgm_path", "")
		AudioDirector.play_songbook_bgm(bgm_path)
	else:
		AudioDirector.play_gameplay_music()

	# Trang đầu tiên của phiên không có gì để "lật" — chỉ kêu khi thật sự sang trang.
	if not first:
		AudioDirector.play_sfx("page_turn")
	_enter(State.FREE if GameState.free_play else State.LEAD_IN)


func _load_phrase() -> void:
	if Songbook.is_valid(_page):
		_sequence = Songbook.get_phrase_sequence(_page, _phrase_index)
		if _sequence.is_empty():
			_sequence = Melodies.for_page(_page)
	else:
		_sequence = Melodies.for_page(_page)


func _get_phrase_prompt() -> String:
	if Songbook.is_valid(_page):
		var phrase := Songbook.get_phrase(_page, _phrase_index)
		var lyrics: String = phrase.get("lyrics", "")
		if not lyrics.is_empty():
			return "♫ %s ♫" % lyrics
	return ""


func _on_page_changed(page_index: int) -> void:
	var target := clampi(page_index, 0, Songbook.count() - 1) if Songbook.count() > 0 else page_index
	if target != _page:
		_begin_page()


## Bật tự do: giữ nguyên cây bé đang trồng, chỉ tắt phần gợi ý và chuỗi.
## Tắt tự do: dựng lại trang từ đầu — cây hát lại câu gọi. Bé 4 tuổi sẽ bấm nút
## đó hai lần liên tiếp, nên đường quay về phải luôn dẫn tới một trạng thái sạch
## chứ không phải chỗ dở dang mà không ai giải thích.
func _on_free_play_changed(enabled: bool) -> void:
	if enabled:
		_enter(State.FREE)
	else:
		_begin_page()


func _enter(next: State) -> void:
	_state = next
	_timer = 0.0
	match next:
		State.LEAD_IN:
			_tree.clear_singing()
			_tree.clear_hint()
			if _keyboard != null:
				_keyboard.clear_hint_key()
			var p := _get_phrase_prompt()
			prompt_updated.emit(p if not p.is_empty() else "Lắng nghe khu rừng nào... ♫")
		State.SINGING:
			_sing_index = 0
			_tree.clear_hint()
			if _keyboard != null:
				_keyboard.clear_hint_key()
			var p := _get_phrase_prompt()
			prompt_updated.emit(p if not p.is_empty() else "Giai điệu đang ngân vang! ♫")
		State.WAITING:
			_tree.clear_singing()
			_idle = 0.0
			_refresh_hint()
		State.FRUITING:
			_replay_index = 0
			_tree.fruit()
			_tree.clear_hint()
			if _keyboard != null:
				_keyboard.clear_hint_key()
			AudioDirector.play_sfx("chest_open")
			prompt_updated.emit("Cây thần nở hoa rực rỡ! ★")
		State.PAGE_TURN:
			_tree.clear_hint()
			if _keyboard != null:
				_keyboard.clear_hint_key()
			prompt_updated.emit("Lật sang trang mới...")
			page_turn_started.emit()
		State.FREE:
			_tree.clear_singing()
			_tree.clear_hint()
			if _keyboard != null:
				_keyboard.clear_hint_key()
			_step = 0
			prompt_updated.emit("Bé thỏa thích chơi đàn! ♬")



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
				# advance_page() phát page_changed, và _on_page_changed dựng lại
				# trang. Một đường duy nhất, dùng chung với bản đồ chương.
				GameState.advance_page()
		State.FREE:
			pass


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
		phrase_completed.emit(_phrase_index)
		var total_phrases := Songbook.phrase_count(_page)
		if Songbook.is_valid(_page) and (_phrase_index + 1) < total_phrases:
			# Chuyển tiếp sang câu tiếp theo của bài hát
			_phrase_index += 1
			_load_phrase()
			_step = 0
			_tree.set_sequence(_sequence)
			AudioDirector.play_sfx("fairy_dust")
			_enter(State.LEAD_IN)
		else:
			# Hoàn thành trọn vẹn bài hát!
			_enter(State.FRUITING)
			page_completed.emit(GameState.page_index)
	else:
		_refresh_hint()


func _refresh_hint() -> void:
	if _step < _sequence.size():
		var n: int = _sequence[_step]
		_tree.set_hint(n)
		if _keyboard != null:
			_keyboard.set_hint_key(n)
		var lyrics := _get_phrase_prompt()
		if not lyrics.is_empty():
			prompt_updated.emit(lyrics)
		else:
			prompt_updated.emit("♪ %s ♪" % Notes.animal_of(n))
	else:
		_tree.clear_hint()
		if _keyboard != null:
			_keyboard.clear_hint_key()




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
const STATE_NAMES := ["LEAD_IN", "SINGING", "WAITING", "FRUITING", "PAGE_TURN", "FREE"]


func state_name() -> String:
	return STATE_NAMES[_state]


func progress() -> String:
	var total_p := Songbook.phrase_count(_page)
	if total_p > 1:
		return "Câu %d/%d (%d/%d)" % [_phrase_index + 1, total_p, _step, _sequence.size()]
	return "%d/%d" % [_step, _sequence.size()]
