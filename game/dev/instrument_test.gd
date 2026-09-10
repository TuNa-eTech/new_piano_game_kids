extends Node
## Máy đo kiểm tra Tính Năng 2: Nút Chuyển Đổi Nhạc Cụ Trực Tiếp (Instrument Mode Switcher).
##
## Chạy:  Godot --headless --path . res://game/dev/instrument_test.tscn

var _fails: int = 0


func _check(label: String, ok: bool, detail: String = "") -> void:
	if not ok:
		_fails += 1
	print("  [%s] %s%s" % ["OK " if ok else "SAI", label, ("  — " + detail) if detail else ""])


func _ready() -> void:
	print("=== Kiểm tra Tính Năng 2: Instrument Mode Switcher ===\n")

	await _test_notes_metadata()
	await _test_game_state_modes()
	await _test_audio_director_routing()
	await _test_instrument_switcher_ui()

	print("\n=== %s ===" % ("ĐẠT TOÀN BỘ" if _fails == 0 else "TRƯỢT (%d lỗi)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _test_notes_metadata() -> void:
	print("① Kiểm tra Notes metadata")
	_check("Notes có đúng 5 chế độ", Notes.mode_count() == 5, "mode_count = %d" % Notes.mode_count())

	for m in Notes.mode_count():
		var info := Notes.mode_info(m)
		_check("Mode %d có tên hợp lệ" % m, not info.get("name", "").is_empty(), info.get("name", ""))
		_check("Mode %d có icon hợp lệ" % m, ResourceLoader.exists(info.get("icon", "")), info.get("icon", ""))
		_check("Mode %d có màu sắc" % m, info.get("color") is Color)


func _test_game_state_modes() -> void:
	print("\n② Kiểm tra GameState & Signal")
	GameState.instrument_mode = Notes.InstrumentMode.AUTO
	_check("Mặc định là AUTO (0)", GameState.instrument_mode == 0)

	var signal_received: Array[int] = []
	var cb := func(mode: int): signal_received.append(mode)
	GameState.instrument_mode_changed.connect(cb)

	GameState.instrument_mode = Notes.InstrumentMode.FLUTE
	_check("Đổi sang FLUTE (2)", GameState.instrument_mode == 2)
	_check("Phát signal instrument_mode_changed", signal_received.has(2))

	GameState.instrument_mode = Notes.InstrumentMode.KALIMBA
	_check("Đổi sang KALIMBA (3)", GameState.instrument_mode == 3)

	GameState.reset_all()
	_check("reset_all() đưa instrument_mode về 0 (AUTO)", GameState.instrument_mode == 0)
	GameState.instrument_mode_changed.disconnect(cb)


func _test_audio_director_routing() -> void:
	print("\n③ Kiểm tra AudioDirector định tuyến âm thanh")
	for mode in [Notes.InstrumentMode.AUTO, Notes.InstrumentMode.ANIMALS, Notes.InstrumentMode.FLUTE, Notes.InstrumentMode.KALIMBA, Notes.InstrumentMode.CHIMES]:
		GameState.instrument_mode = mode
		await get_tree().process_frame

		# Phát preview không crash
		AudioDirector.play_mode_preview(mode)

		# Phát tất cả 7 nốt không crash
		for k in Notes.count():
			AudioDirector.play_note(k)

		_check("Mode %d phát âm thanh 7 phím trôi chảy" % mode, true)


func _test_instrument_switcher_ui() -> void:
	print("\n④ Kiểm tra UI InstrumentSwitcher")
	var scene := preload("res://game/ui/instrument_switcher.tscn")
	var switcher: InstrumentSwitcher = scene.instantiate()
	add_child(switcher)
	await get_tree().process_frame

	_check("Khay mở rộng ban đầu đóng", not switcher._dock_open)
	
	# Mở khay
	switcher.open_dock()
	_check("open_dock() mở khay thành công", switcher._dock_open)
	_check("Node dock hiển thị", switcher._dock.visible)

	# Chọn trực tiếp từ khay
	switcher._on_dock_btn_pressed(Notes.InstrumentMode.CHIMES)
	_check("Chọn CHIMES từ dock", GameState.instrument_mode == Notes.InstrumentMode.CHIMES)

	# Đóng khay
	switcher.close_dock()
	_check("close_dock() đóng khay", not switcher._dock_open)

	# Nhấn nút chính xoay vòng sang chế độ kế tiếp
	var prev_mode: int = GameState.instrument_mode
	switcher._on_main_button_pressed()
	var expected_mode: int = (prev_mode + 1) % Notes.mode_count()
	_check("Nhấn nút chính chuyển sang mode kế tiếp (%d -> %d)" % [prev_mode, expected_mode],
		GameState.instrument_mode == expected_mode)

	switcher.queue_free()
