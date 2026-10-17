extends Node
## Máy đo vòng chơi gọi–đáp. CHỈ dùng khi phát triển.
##
## Trả lời đúng tiêu chí thoát của Tuần 2 (docs/production-pipeline.html · Bước 4):
##   "Chơi trọn một trang truyện từ đầu đến lúc cây trổ quả."
##
## Và kiểm cả lời hứa gốc của thiết kế — KHÔNG CÓ TRẠNG THÁI SAI: bấm nhầm phím
## thì không mất gì, chuỗi đứng yên chờ tiếp, cây vẫn cao thêm, tiếng vẫn hay.
##
## Tuần 3 thêm: khoá giữ 2 giây, bản đồ chương, Chơi Tự Do.
##
## Chạy:  Godot --path . res://game/dev/loop_test.tscn
## (phải có cửa sổ — headless không định tuyến InputEventScreenTouch)

var _keyboard: PianoKeyboard
var _tree: MagicTree
var _cr: CallResponse
var _menu: CottageMenuButton
var _map: ChapterMap
var _chapter_end: ChapterEnd
var _points: Array[Vector2] = []
var _fails: int = 0


func _ready() -> void:
	# Bản đồ chương dừng cả cây. Máy đo phải chạy tiếp lúc đó mới đo được rằng
	# ván chơi bên dưới đã thật sự đứng yên.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Ngắt file lưu: phép đo không được phụ thuộc vào những gì máy này đã chơi
	# lần trước, và cũng không được ghi đè tiến độ thật của bé.
	SaveStore.reset_for_test()

	# Bộ đếm lớp phủ là biến static — nó sống qua cả lần dựng lại scene trong
	# cùng một tiến trình, nên phải dọn nếu không phép đo sẽ thấy nó trôi.
	PauseOverlay.reset_pause_state()

	# main.tscn phải treo THẲNG vào root, KHÔNG phải làm con của máy đo.
	# process_mode lan xuống con: máy đo là ALWAYS, nên nếu game nằm dưới nó thì
	# cả game cũng thành ALWAYS và get_tree().paused hoá ra vô nghĩa — phép đo
	# "bàn phím câm khi bản đồ mở" sẽ trượt vì lý do hoàn toàn không có thật.
	var main: Node = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	for i in 6:
		await get_tree().process_frame

	_keyboard = main.get_node("UI/PianoKeyboard")
	_tree = main.get_node("UI/MagicTree")
	_cr = main.get_node("CallResponse")
	_menu = main.get_node("HUD/CottageMenu")
	_map = main.get_node("ChapterMap")
	_chapter_end = main.get_node("ChapterEnd")

	var xf := _keyboard.get_global_transform()
	var w: float = _keyboard.size.x / float(Notes.count())
	for i in Notes.count():
		_points.append(xf * Vector2(i * w + w * 0.5, _keyboard.size.y * 0.5))

	print("=== Tuần 2 · vòng gọi–đáp · Tuần 3 · menu, bản đồ, tự do ===\n")
	await _run()
	await _run_visibility()
	await _run_menu_lock()
	await _run_chapter_map()
	await _run_free_play()
	await _run_backgrounded_mid_press()
	await _run_chapter_end()
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
	_check("chuỗi có 3–8 nốt như thiết kế", seq_len >= 3 and seq_len <= 8, "dài %d" % seq_len)
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

	# --- Bước 3: bé đáp đúng cả chuỗi (tất cả các câu của bài hát) ---
	var total_phrases := maxi(1, Songbook.phrase_count(GameState.page_index))
	print("\n③ Đáp đúng trọn bài (%d câu)" % total_phrases)
	var stars_start := GameState.stars
	var total_notes := 0
	for p_idx in total_phrases:
		if p_idx > 0:
			await _await_state("WAITING", 14.0)
		var guard := 0
		while _cr.state_name() == "WAITING" and guard < 32:
			var n := _cr.expected_note()
			if n < 0:
				break
			await _press(n)
			total_notes += 1
			guard += 1
	_check("mỗi nốt đúng cho một hạt sao", GameState.stars - stars_start == total_notes,
		"được %d / cần %d" % [GameState.stars - stars_start, total_notes])
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


# ============================================================ Tuần 3 · khoá nhẹ --

func _menu_centre() -> Vector2:
	return _menu.get_global_transform() * (_menu.size * 0.5)


## Nút Menu mở bản đồ ngay khi chạm — không còn khoá giữ 2 giây.
func _run_menu_lock() -> void:
	print("\n⑥ Nút Menu mở ngay khi chạm")
	GameState.free_play = false

	var d := InputEventScreenTouch.new()
	d.index = 0
	d.pressed = true
	d.position = _menu_centre()
	Input.parse_input_event(d)
	await get_tree().process_frame
	_check("chỉ mới chạm xuống thì CHƯA mở bản đồ", not _map.is_open())

	var u := InputEventScreenTouch.new()
	u.index = 0
	u.pressed = false
	u.position = _menu_centre()
	Input.parse_input_event(u)
	await get_tree().process_frame
	_check("chạm rồi nhả thì mở bản đồ ngay", _map.is_open())
	_check("ván chơi bên dưới đã dừng", get_tree().paused)
	_map.close_map()
	await get_tree().process_frame
	_menu.cancel()

	# P0-1: phụ huynh bấm menu trong lúc bé đàn 2 ngón vẫn mở được map bình
	# thường — ngón trên đàn không bao giờ tới gui_input của nút nên không ảnh hưởng.
	print("⑥b Menu mở được khi bé đang đàn")
	var mp := _menu_centre()
	var md := InputEventScreenTouch.new()
	md.index = 0
	md.pressed = true
	md.position = mp
	Input.parse_input_event(md)
	for i in 3:
		await _press(i % Notes.count())
	var mu := InputEventScreenTouch.new()
	mu.index = 0
	mu.pressed = false
	mu.position = mp
	Input.parse_input_event(mu)
	await get_tree().process_frame
	_check("nhả menu sau khi bé đàn vẫn mở bản đồ", _map.is_open())


func _run_chapter_map() -> void:
	print("\n⑦ Bản đồ chương")
	if not _map.is_open():
		_map.open_map()
		await get_tree().process_frame

	# Ván chơi phải ĐỨNG YÊN, và bàn phím phải câm.
	#
	# Điểm chạm của phím đàn nằm ở cạnh dưới màn hình — mà nút đóng của bản đồ
	# cũng ở giữa cạnh dưới. Chạm trúng nó thì bản đồ ĐÓNG, đúng như thiết kế,
	# và những lượt chạm sau đó rơi vào lúc đã hết dừng. Nên phải dừng vòng lặp
	# ngay khi bản đồ đóng, rồi đòi có đủ số lượt chạm THẬT SỰ diễn ra lúc bản đồ
	# còn mở — không thì một phép đo rỗng sẽ đội lốt một lần đạt.
	var page_before := GameState.page_index
	var state_before := _cr.state_name()
	var notes_before := GameState.notes_played_this_session
	var keyboard_blocked := not _keyboard.can_process()
	var pressed_under_map := 0

	for i in Notes.count():
		if not _map.is_open():
			break
		var t := InputEventScreenTouch.new()
		t.index = 0
		t.pressed = true
		t.position = _points[i]
		Input.parse_input_event(t)
		await get_tree().process_frame
		var r := InputEventScreenTouch.new()
		r.index = 0
		r.pressed = false
		r.position = _points[i]
		Input.parse_input_event(r)
		await get_tree().process_frame
		pressed_under_map += 1

	_check("có đo thật — đủ lượt chạm lúc bản đồ mở (chốt chặn phép đo)",
		pressed_under_map >= 3, "%d lượt" % pressed_under_map)
	_check("bàn phím bị chặn ngay ở tầng process", keyboard_blocked)
	_check("bàn phím câm khi bản đồ mở",
		GameState.notes_played_this_session == notes_before,
		"thêm %d nốt" % (GameState.notes_played_this_session - notes_before))
	_check("trang không đổi", GameState.page_index == page_before)
	_check("vòng chơi đứng yên", _cr.state_name() == state_before, _cr.state_name())

	# Nhạc nền KHÔNG được tắt: im bặt khi mở menu là khoảng lặng khó chịu với trẻ.
	await get_tree().process_frame
	var music := AudioServer.get_bus_index("Music")
	var peak := AudioServer.get_bus_peak_volume_left_db(music, 0)
	_check("pad nền vẫn kêu lúc dừng", peak > -60.0, "%.1f dB" % peak)

	# Save mới tinh: mới đi hết 1 trang nên chương 2, 3 còn khoá.
	_check("chương 1 luôn mở", GameState.chapter_unlocked(0))
	_check("chương 2 còn khoá", not GameState.chapter_unlocked(1),
		"max_page = %d" % GameState.max_page_reached)
	_check("chương 3 còn khoá", not GameState.chapter_unlocked(2))

	# Mở khoá rồi chọn chương 2 → nhảy đúng trang đầu chương đó.
	GameState.max_page_reached = Chapters.first_page_of(1)
	_check("đi hết chương 1 thì chương 2 mở", GameState.chapter_unlocked(1))
	GameState.select_chapter(1)
	await get_tree().process_frame
	_check("chọn chương 2 nhảy đúng trang", GameState.page_index == 5,
		"trang %d" % GameState.page_index)
	_check("vòng chơi dựng lại trang mới", _cr.step() == 0)

	if not _map.is_open():
		_map.open_map()
		await get_tree().process_frame
	_map.close_map()
	await get_tree().process_frame
	_check("đóng bản đồ thì ván chơi chạy lại", not get_tree().paused)
	_check("bản đồ đã ẩn", not _map.is_open())


## Quyết định 03: "không gợi ý, không chuỗi — chỉ đàn, con vật và cây mọc theo mỗi nốt".
func _run_free_play() -> void:
	print("\n⑧ Chơi Tự Do")
	_check("vào lại được trạng thái chờ đáp", await _await_state("WAITING"), _cr.state_name())

	GameState.free_play = true
	await get_tree().process_frame
	_check("vòng chơi chuyển sang FREE", _cr.state_name() == "FREE", _cr.state_name())
	_check("không còn gợi ý nốt nào", _cr.expected_note() == -1)

	_tree.reset_page()
	await get_tree().process_frame
	var stars_before := GameState.stars
	var growth_before := _tree.growth()
	for i in 20:
		await _press(i % Notes.count())
	_check("bấm 20 phím không được hạt sao nào", GameState.stars == stars_before,
		"thêm %d sao" % (GameState.stars - stars_before))
	_check("vẫn không có gợi ý", _cr.expected_note() == -1)
	_check("cây vẫn cao thêm mỗi nốt", _tree.growth() > growth_before,
		"%.3f -> %.3f" % [growth_before, _tree.growth()])
	_check("không có lá nào nhấp nháy gợi ý", _tree.leaf_state_of(_tree_hint_leaf()) != MagicTree.LeafState.HINT)

	# Bé 4 tuổi sẽ bấm nút đó hai lần liên tiếp. Đường quay về phải dẫn tới một
	# trạng thái sạch chứ không phải chỗ dở dang mà không ai giải thích.
	GameState.free_play = false
	_check("tắt tự do thì hát lại trang từ đầu", await _await_state("WAITING"), _cr.state_name())
	_check("chuỗi về lại vạch xuất phát", _cr.step() == 0, "bước %d" % _cr.step())
	_check("gợi ý trở lại hợp lệ", _cr.expected_note() >= 0, "nốt %d" % _cr.expected_note())


## Lá đầu tiên của chuỗi — nơi gợi ý sẽ xuất hiện nếu nó bị rò vào chế độ tự do.
func _tree_hint_leaf() -> int:
	return Melodies.for_page(GameState.page_index)[0]


## Hồi quy cho một lỗi khoá cứng: app xuống nền GIỮA LÚC ngón đang nhấn nút Menu
## (chưa kịp nhả) thì sự kiện nhả ngón không bao giờ tới. Nếu nút không tự dọn,
## bộ đếm ngón kẹt lại và lượt chạm hợp lệ tiếp theo bị coi là "ngón khác" rồi bỏ
## qua — nút Menu chết câm. Bấm nút rồi bị phân tâm là việc một đứa 4 tuổi làm suốt.
func _run_backgrounded_mid_press() -> void:
	print("")
	print("⑨ App xuống nền giữa lúc ngón đang nhấn nút Menu")
	if _map.is_open():
		_map.close_map()
		await get_tree().process_frame
	_menu.cancel()

	var p := _menu_centre()
	var d := InputEventScreenTouch.new()
	d.index = 0
	d.pressed = true
	d.position = p
	Input.parse_input_event(d)
	await get_tree().process_frame

	# Ngón này KHÔNG bao giờ được nhả — app nuốt mất sự kiện đó.
	_menu.notification(NOTIFICATION_APPLICATION_PAUSED)
	_menu.notification(NOTIFICATION_APPLICATION_RESUMED)
	await get_tree().process_frame

	var u := InputEventScreenTouch.new()
	u.index = 0
	u.pressed = true
	u.position = p
	Input.parse_input_event(u)
	await get_tree().process_frame
	var r := InputEventScreenTouch.new()
	r.index = 0
	r.pressed = false
	r.position = p
	Input.parse_input_event(r)
	await get_tree().process_frame
	_check("chạm lại sau khi app xuống nền vẫn mở được bản đồ", _map.is_open())
	_map.close_map()
	await get_tree().process_frame
	_menu.cancel()


# ====================================================== Tuần 4 · màn kết chương --

## "Buổi Diễn Rừng Xanh" — docs/gameplay-design.html tả: "cả 7 con vật hát lại
## đúng giai điệu bé vừa chơi, cây thần mọc theo, rương báu bật mở", trọn 12 giây.
func _run_chapter_end() -> void:
	print("")
	print("⑩ Màn kết chương")
	GameState.free_play = false
	GameState.set_page(Chapters.pages_per_chapter() - 1)
	await get_tree().process_frame

	var page_before := GameState.page_index
	GameState.advance_page()
	await get_tree().process_frame
	_check("hết trang cuối chương thì màn kết mở", _chapter_end.is_open())
	_check("ván chơi bên dưới đã dừng", get_tree().paused)
	_check("ván chơi đã sẵn ở trang đầu chương sau",
		GameState.page_index == page_before + 1, "trang %d" % GameState.page_index)

	# Diễn lại TOÀN BỘ giai điệu của chương, không phải mỗi trang cuối.
	var expected := 0
	for i in Chapters.pages_per_chapter():
		expected += Melodies.for_page(i).size()
	_check("diễn lại đủ giai điệu cả chương", _chapter_end.note_count() == expected,
		"%d / %d nốt" % [_chapter_end.note_count(), expected])

	# Gợi ý quay màn hình KHÔNG được nằm trong khung lúc đang diễn — nếu không
	# nó lọt thẳng vào đoạn phim phụ huynh vừa bật máy quay.
	_check("lúc đang diễn thì không có chữ nào trong khung",
		not _chapter_end.hint_visible())

	# Có tiếng thật đi ra chứ không phải chỉ đổi con số.
	var bus := AudioServer.get_bus_index("Notes")
	var peak := -200.0
	var t := 0.0
	while not _chapter_end.is_done() and t < 20.0:
		await get_tree().process_frame
		t += get_process_delta_time()
		peak = maxf(peak, AudioServer.get_bus_peak_volume_left_db(bus, 0))
	_check("diễn xong trong khoảng 12 giây", _chapter_end.is_done(),
		"%.1f s, pha %s" % [t, _chapter_end.phase_name()])
	_check("thời lượng nằm trong 9–15 giây", t > 9.0 and t < 15.0, "%.1f s" % t)
	# Vừa phải nghe rõ, vừa phải còn headroom — màn kết KHÔNG được to hơn hẳn
	# lúc chơi. HardLimiter trên Master che được tiếng vỡ, nên chỉ có phép đo
	# mới bắt được chuyện này.
	_check("7 con vật CÓ hát ra tiếng thật", peak > -60.0, "%.1f dB" % peak)
	_check("còn headroom, không dội tai", peak < -2.0, "%.1f dB" % peak)

	_check("diễn xong mới hiện gợi ý quay màn hình", _chapter_end.hint_visible())

	# Buổi diễn TỰ LẶP LẠI: phụ huynh có bao nhiêu lượt bật quay màn hình cũng
	# được, mà màn hình chỉ có một nút cho bé.
	var t2 := 0.0
	while _chapter_end.is_done() and t2 < 8.0:
		await get_tree().process_frame
		t2 += get_process_delta_time()
	_check("tự diễn lại sau khoảng nghỉ", not _chapter_end.is_done(),
		"%.1f s, pha %s" % [t2, _chapter_end.phase_name()])
	_check("diễn lại thì chữ lại biến mất", not _chapter_end.hint_visible())

	_chapter_end.close_overlay()
	await get_tree().process_frame
	_check("đóng màn kết thì ván chơi chạy lại", not get_tree().paused)
	_check("bộ đếm lớp phủ về 0", PauseOverlay.open_overlay_count() == 0,
		"%d" % PauseOverlay.open_overlay_count())
	_check("chơi tiếp được ngay trang mới", await _await_state("WAITING"), _cr.state_name())
