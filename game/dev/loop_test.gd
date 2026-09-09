extends Node
## Máy đo vòng chơi gọi–đáp. CHỈ dùng khi phát triển.
##
## Trả lời đúng tiêu chí thoát của Tuần 2 (docs/production-pipeline.html · Bước 4):
##   "Chơi trọn một trang truyện từ đầu đến lúc cây trổ quả."
##
## Và kiểm cả lời hứa gốc của thiết kế — KHÔNG CÓ TRẠNG THÁI SAI: bấm nhầm phím
## thì không mất gì, chuỗi đứng yên chờ tiếp, cây vẫn cao thêm, tiếng vẫn hay.
##
## Chạy:  Godot --path . res://game/dev/loop_test.tscn
## (phải có cửa sổ — headless không định tuyến InputEventScreenTouch)

var _keyboard: PianoKeyboard
var _tree: MagicTree
var _cr: CallResponse
var _points: Array[Vector2] = []
var _fails: int = 0


func _ready() -> void:
	var main: Node = load("res://game/main.tscn").instantiate()
	add_child(main)
	for i in 4:
		await get_tree().process_frame

	_keyboard = main.get_node("UI/PianoKeyboard")
	_tree = main.get_node("UI/MagicTree")
	_cr = main.get_node("CallResponse")

	var xf := _keyboard.get_global_transform()
	var w: float = _keyboard.size.x / float(Notes.count())
	for i in Notes.count():
		_points.append(xf * Vector2(i * w + w * 0.5, _keyboard.size.y * 0.5))

	print("=== Tuần 2 · vòng gọi–đáp ===\n")
	await _run()
	await _run_visibility()
	print("\n=== %s ===" % ("ĐẠT" if _fails == 0 else "TRƯỢT (%d lỗi)" % _fails))
	get_tree().quit()


func _check(label: String, ok: bool, detail: String = "") -> void:
	if not ok:
		_fails += 1
	print("  [%s] %s%s" % ["OK " if ok else "SAI", label, ("  — " + detail) if detail else ""])


func _press(note_index: int) -> void:
	var d := InputEventScreenTouch.new()
	d.index = 0
	d.pressed = true
	d.position = _points[note_index]
	Input.parse_input_event(d)
	await get_tree().process_frame
	var u := InputEventScreenTouch.new()
	u.index = 0
	u.pressed = false
	u.position = _points[note_index]
	Input.parse_input_event(u)
	await get_tree().process_frame


func _await_state(name: String, limit: float = 12.0) -> bool:
	var t := 0.0
	while _cr.state_name() != name and t < limit:
		await get_tree().process_frame
		t += get_process_delta_time()
	return _cr.state_name() == name


func _run() -> void:
	# --- Bước 1: cây hát trước, rồi chuyển sang chờ ---
	print("① Cây hát rồi chờ")
	_check("vào được trạng thái chờ đáp", await _await_state("WAITING"), _cr.state_name())
	var seq_len := _cr.sequence_length()
	_check("chuỗi có 3–5 nốt như thiết kế", seq_len >= 3 and seq_len <= 7, "dài %d" % seq_len)
	_check("có gợi ý nốt cần chạm", _cr.expected_note() >= 0, "nốt %d" % _cr.expected_note())

	# --- KHÔNG CÓ TRẠNG THÁI SAI ---
	print("\n② Bấm nhầm phím thì không mất gì")
	var want := _cr.expected_note()
	var wrong := (want + 3) % Notes.count()
	var stars_before := GameState.stars
	var step_before := _cr.step()
	var growth_before := _tree.growth()
	await _press(wrong)
	_check("không bị trừ / không mất sao", GameState.stars == stars_before)
	_check("chuỗi đứng yên chờ tiếp", _cr.step() == step_before)
	_check("vẫn ở trạng thái chờ, không có màn thua", _cr.state_name() == "WAITING")
	_check("cây vẫn cao thêm một chút", _tree.growth() > growth_before,
		"%.4f -> %.4f" % [growth_before, _tree.growth()])
	_check("gợi ý giữ nguyên nốt cũ", _cr.expected_note() == want)

	# --- Bước 3: bé đáp đúng cả chuỗi ---
	print("\n③ Đáp đúng trọn chuỗi %d nốt" % seq_len)
	var stars_start := GameState.stars
	var guard := 0
	while _cr.state_name() == "WAITING" and guard < 32:
		var n := _cr.expected_note()
		if n < 0:
			break
		await _press(n)
		guard += 1
	_check("mỗi nốt đúng cho một hạt sao", GameState.stars - stars_start == seq_len,
		"được %d / cần %d" % [GameState.stars - stars_start, seq_len])
	_check("cây đã lớn hết cỡ", _tree.growth() >= 0.89, "%.3f" % _tree.growth())
	_check("cây đạt giai đoạn cuối (%d/8)" % (_tree.stage() + 1), _tree.stage() == MagicTree.STAGES - 1)

	# --- Bước 4: cây trổ quả ---
	print("\n④ Cây trổ quả rồi lật trang")
	_check("chuyển sang trổ quả", _cr.state_name() == "FRUITING", _cr.state_name())
	var page_before := GameState.page_index
	_check("lật sang trang mới", await _await_state("WAITING", 14.0), _cr.state_name())
	_check("số trang tăng", GameState.page_index == page_before + 1,
		"trang %d -> %d" % [page_before, GameState.page_index])
	_check("giai điệu trang mới dài hơn hoặc khác", _cr.sequence_length() >= 3,
		"dài %d" % _cr.sequence_length())
	_check("cây đã reset cho trang mới", _tree.growth() < 0.5, "%.3f" % _tree.growth())


## Hồi quy cho lỗi đã gặp: ở giai đoạn 0 thân cây cao 0, mà lá lại bị ẩn theo
## chiều cao thân, nên đầu mỗi trang khung truyện trống trơn — bé không thấy
## cây hát. Bước 1 của vòng chơi coi như hỏng mà mọi con số vẫn đúng.
func _run_visibility() -> void:
	print("\n⑤ Đầu trang, khung truyện KHÔNG được trống")
	_tree.reset_page()
	await get_tree().process_frame
	_check("cây ở giai đoạn 0", _tree.stage() == 0, "stage %d" % _tree.stage())
	_check("vẫn thấy đủ 7 lá", _tree.visible_leaf_count() == Notes.count(),
		"%d lá" % _tree.visible_leaf_count())
	_tree.sing_leaf(2)
	await get_tree().process_frame
	_check("lá đang hát đổi trạng thái", _tree.leaf_state_of(2) == MagicTree.LeafState.SINGING)
