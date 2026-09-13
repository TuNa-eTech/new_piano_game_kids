extends Node
## Automated test for the Continuous Autoplay (Jukebox) system.
##
## Run: /Applications/Godot.app/Contents/MacOS/Godot --headless --path . res://game/dev/test_autoplay.tscn

const AutoPlayButton = preload("res://game/ui/auto_play_button.gd")
const PianoKeyboard = preload("res://game/piano/piano_keyboard.gd")
const MagicTree = preload("res://game/story/magic_tree.gd")
const CallResponse = preload("res://game/call_response.gd")

var _fails: int = 0


func _check(label: String, ok: bool, detail: String = "") -> void:
	if not ok:
		_fails += 1
	print("  [%s] %s%s" % ["OK " if ok else "SAI", label, ("  — " + detail) if detail else ""])


func _ready() -> void:
	print("=== KIỂM THỬ TỰ ĐỘNG PHÁT HẾT BÀI HÁT (AUTOPLAY / JUKEBOX) ===\n")

	await _test_gamestate_flags()
	await _test_keyboard_play_auto_key()
	await _test_autoplay_button_ui()
	await _test_call_response_autoplay_flow()

	print("\n=== %s ===" % ("ĐẠT TOÀN BỘ (AUTOPLAY TEST)" if _fails == 0 else "TRƯỢT (%d lỗi)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _test_gamestate_flags() -> void:
	print("① Kiểm tra cờ trạng thái GameState.auto_play")
	GameState.reset_all()

	_check("Mặc định auto_play là false", GameState.auto_play == false)

	var signal_box := [false, false]
	GameState.auto_play_changed.connect(func(v):
		signal_box[0] = true
		signal_box[1] = v
	)

	GameState.auto_play = true
	_check("Bật auto_play thành true", GameState.auto_play == true)
	_check("Signal auto_play_changed phát đúng", signal_box[0] and signal_box[1] == true)

	# Kiểm tra tính loại trừ với free_play
	GameState.free_play = true
	_check("Khi bật free_play, auto_play tự động tắt", GameState.auto_play == false and GameState.free_play == true)

	GameState.auto_play = true
	_check("Khi bật auto_play, free_play tự động tắt", GameState.auto_play == true and GameState.free_play == false)

	GameState.auto_play = false


func _test_keyboard_play_auto_key() -> void:
	print("\n② Kiểm tra PianoKeyboard.play_auto_key()")
	var kb_scene := preload("res://game/piano/piano_keyboard.tscn")
	var kb: PianoKeyboard = kb_scene.instantiate()
	add_child(kb)
	kb.size = Vector2(1280, 256)
	await get_tree().process_frame

	var played := [-1]
	var released := [-1]
	kb.note_played.connect(func(k): played[0] = k)
	kb.note_released.connect(func(k): released[0] = k)

	kb.play_auto_key(2, 0.12) # Nốt E4 (Thỏ)
	_check("Phím E4 (2) phát tín hiệu note_played ngay lập tức", played[0] == 2)

	await get_tree().create_timer(0.20).timeout
	_check("Sau 0.12s, phím E4 phát tín hiệu note_released", released[0] == 2)

	kb.queue_free()


func _test_autoplay_button_ui() -> void:
	print("\n③ Kiểm tra AutoPlayButton UI")
	GameState.reset_all()

	var btn := AutoPlayButton.new()
	add_child(btn)
	btn.size = Vector2(96, 96)
	await get_tree().process_frame

	_check("AutoPlayButton có toggle_mode", btn.toggle_mode == true)
	_check("Mặc định button_pressed = false", btn.button_pressed == false)

	# Bấm nút
	btn.button_pressed = true
	btn.toggled.emit(true)
	_check("Kích hoạt nút -> GameState.auto_play chuyển true", GameState.auto_play == true)

	# Tắt qua GameState -> nút tự đồng bộ
	GameState.auto_play = false
	_check("Tắt qua GameState -> nút tự chuyển false", btn.button_pressed == false)

	btn.queue_free()


func _test_call_response_autoplay_flow() -> void:
	print("\n④ Kiểm tra luồng biểu diễn tự động trong CallResponse")
	GameState.reset_all()
	GameState.set_page(0) # Baby Shark

	var tree := MagicTree.new()
	add_child(tree)
	var kb_scene := preload("res://game/piano/piano_keyboard.tscn")
	var kb: PianoKeyboard = kb_scene.instantiate()
	add_child(kb)
	kb.size = Vector2(1280, 256)

	var cr := CallResponse.new()
	add_child(cr)
	cr.setup(tree, kb)
	await get_tree().process_frame

	_check("CallResponse khởi tạo ở trang 0 (Baby Shark)", cr._page == 0)

	var phrases := [0]
	cr.phrase_completed.connect(func(_idx): phrases[0] += 1)

	# Bật auto_play
	GameState.auto_play = true

	# Kiểm tra tự động chuyển sang WAITING và bắt đầu gõ nốt
	_check("Khi bật auto_play, trạng thái chuyển sang WAITING ngay", cr._state == CallResponse.State.WAITING)

	var initial_step := cr._step
	# Chờ đến khi auto-play gõ nốt đầu tiên
	var timeout := 0.0
	while cr._step == initial_step and timeout < 2.0:
		await get_tree().process_frame
		timeout += get_process_delta_time()

	_check("Auto-play tự động tiến bước nốt (_step tăng)", cr._step > initial_step, "_step hiện tại: %d" % cr._step)

	# Đợi hoàn thành câu 1 (8 nốt Baby Shark)
	var max_wait := 5.5
	var elapsed := 0.0
	while phrases[0] == 0 and elapsed < max_wait:
		await get_tree().process_frame
		elapsed += get_process_delta_time()

	_check("Câu 1 hoàn thành tự động mà không cần bé chạm tay", phrases[0] >= 1, "Số câu xong: %d" % phrases[0])
	_check("Chuyển sang câu 2 của bài hát", cr._phrase_index >= 1, "Câu hiện tại: %d" % cr._phrase_index)

	GameState.auto_play = false
	cr.queue_free()
	tree.queue_free()
	kb.queue_free()
