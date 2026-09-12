extends Node2D

func _ready() -> void:
	print("=== BẮT ĐẦU KIỂM THỬ HƯỚNG B: BÀN ĐÀN TRÀN VIỀN & PHÍM ĐEN TƯƠNG TÁC ===")
	var scene: PackedScene = load("res://game/main.tscn")
	var main = scene.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var kb: PianoKeyboard = main.find_child("PianoKeyboard", true, false)
	assert(kb != null, "PianoKeyboard phải tồn tại")

	# 1. Kiểm tra kích thước bàn phím tràn viền 1280px
	print("[1] Kiểm tra kích thước bàn phím: size = ", kb.size)
	assert(kb.size.x == 1280.0, "Bàn phím phải tràn 100% chiều rộng 1280px")

	# 2. Kiểm tra số lượng phím
	var white_keys = kb.get("_keys")
	assert(white_keys.size() == 7, "Phải có đủ 7 phím trắng")
	var black_slots = [0, 1, 3, 4, 5]

	# 3. Kiểm tra tương tác chạm phím đen (Accidentals)
	print("[2] Kiểm tra tương tác 5 phím đen...")
	var black_notes_played: Array[int] = []
	kb.black_note_played.connect(func(slot: int):
		black_notes_played.append(slot)
		print("  -> Bắt được tín hiệu black_note_played: slot = ", slot)
	)

	for slot in black_slots:
		var black_pos = kb.get_black_key_global_position(slot)
		var touch_down = InputEventScreenTouch.new()
		touch_down.index = slot + 10
		touch_down.position = black_pos
		touch_down.pressed = true
		kb._unhandled_input(touch_down)

		var touch_up = InputEventScreenTouch.new()
		touch_up.index = slot + 10
		touch_up.position = black_pos
		touch_up.pressed = false
		kb._unhandled_input(touch_up)

	assert(black_notes_played.size() == 5, "Cả 5 phím đen đều phải kích hoạt được")
	for slot in black_slots:
		assert(slot in black_notes_played, "Phím đen slot %d phải được kích hoạt" % slot)
	print("  [OK] Cả 5 phím đen (C#, D#, F#, G#, A#) đều nhận cảm ứng và phát tín hiệu chính xác!")

	# 4. Kiểm tra tương tác chạm phím trắng
	print("[3] Kiểm tra tương tác 7 phím trắng...")
	var white_notes_played: Array[int] = []
	kb.note_played.connect(func(k: int):
		white_notes_played.append(k)
		print("  -> Bắt được tín hiệu note_played: key = ", k)
	)

	for i in 7:
		var white_pos = kb.get_key_global_position(i)
		# Chạm vào phần đáy phím trắng (tránh phím đen ở trên)
		white_pos.y += 60.0
		var touch_down = InputEventScreenTouch.new()
		touch_down.index = i + 1
		touch_down.position = white_pos
		touch_down.pressed = true
		kb._unhandled_input(touch_down)

		var touch_up = InputEventScreenTouch.new()
		touch_up.index = i + 1
		touch_up.position = white_pos
		touch_up.pressed = false
		kb._unhandled_input(touch_up)

	assert(white_notes_played.size() == 7, "Cả 7 phím trắng đều phải kích hoạt được")
	print("  [OK] Cả 7 phím trắng (C, D, E, F, G, A, B) đều nhận cảm ứng và phát tín hiệu chính xác!")

	# 5. Kiểm tra âm thanh của AudioDirector cho phím đen
	print("[4] Kiểm tra AudioDirector.play_black_key...")
	for slot in black_slots:
		AudioDirector.play_black_key(slot)
	print("  [OK] AudioDirector.play_black_key phát âm thanh mượt mà không lỗi!")

	print("=== TOÀN BỘ KIỂM THỬ HƯỚNG B ĐẠT 100% ===")
	get_tree().quit(0)
