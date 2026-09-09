extends Node
## Soak test cho đường nóng chạm→âm thanh. CHỈ dùng khi phát triển.
##
## Trả lời đúng một câu hỏi mà tài liệu bắt phải trả lời trước khi làm nội dung:
## đường chạm có cấp phát bộ nhớ mỗi lần bấm hay không.
##
## Chạy nhiều lượt giống hệt nhau rồi so mức trôi bộ nhớ giữa các lượt:
##   - lượt sau trôi ít hẳn lượt đầu  -> chỉ là allocator hâm nóng, KHÔNG rò
##   - các lượt trôi đều nhau         -> rò thật, mỗi cú chạm tốn thêm bộ nhớ
##
## Chạy:
##   Godot --headless --path . res://game/dev/soak_test.tscn
##
## Lưu ý: headless dùng driver âm thanh Dummy trừ khi ép --audio-driver.
## Con số ĐỘ TRỄ ở đây vô nghĩa — độ trễ chỉ đo được trên máy iOS thật.

const PASSES := 5
const ROUNDS_PER_PASS := 60
const FINGERS := 3

var _keyboard: PianoKeyboard
var _points: Array[Vector2] = []


func _ready() -> void:
	# Ngắt file lưu: mỗi lần chuyển trang SaveStore sẽ ghi ra đĩa, và chi phí đó
	# là của DỤNG CỤ ĐO chứ không phải của đường chạm. Nó cũng sẽ ghi đè tiến độ
	# thật của bé nếu để nguyên.
	SaveStore.reset_for_test()

	var main: Node = load("res://game/main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	# Tắt overlay chẩn đoán khi đo: nó định dạng cả một khối chuỗi mỗi khung
	# hình, đó là chi phí của DỤNG CỤ ĐO chứ không phải của game.
	var probe := main.get_node_or_null("LatencyProbe/Panel")
	if probe:
		probe.visible = false

	# --nologic: tắt vòng gọi–đáp và HUD để đo RIÊNG đường chạm→âm thanh,
	# đúng điều kiện của phép đo Tuần 1. Chênh lệch giữa hai chế độ chính là
	# chi phí của lớp giao diện Tuần 2.
	if "--nologic" in OS.get_cmdline_user_args():
		var cr := main.get_node_or_null("CallResponse")
		if cr:
			cr.set_process(false)
		var hud := main.get_node_or_null("HUD")
		if hud:
			hud.visible = false
		print("[chế độ] chỉ đo đường chạm→âm thanh (không logic, không HUD)")

	_keyboard = main.get_node("UI/PianoKeyboard")

	# Chờ layout ổn định — Control chưa có size thì hit-test chắc chắn trượt.
	for i in 10:
		if _keyboard.size.x > 1.0:
			break
		await get_tree().process_frame
	print("viewport=%s  keyboard.size=%s  global_pos=%s" % [
		get_viewport().get_visible_rect().size,
		_keyboard.size,
		_keyboard.global_position,
	])

	var xf := _keyboard.get_global_transform()
	var w: float = _keyboard.size.x / float(Notes.count())
	for i in Notes.count():
		_points.append(xf * Vector2(i * w + w * 0.5, _keyboard.size.y * 0.5))

	# Chọn backend từ dòng lệnh để Spike B đo được cả hai trên cùng một phép thử:
	#   Godot --path . res://game/dev/soak_test.tscn -- --pool
	if "--pool" in OS.get_cmdline_user_args():
		AudioDirector.backend = AudioDirector.Backend.POOL

	print("backend=%s" % AudioDirector.backend_name())
	print("driver=%s  mix_rate=%d  bus Notes=%d  strikes/lượt=%d" % [
		AudioServer.get_driver_name(),
		AudioServer.get_mix_rate(),
		AudioServer.get_bus_index(&"Notes"),
		ROUNDS_PER_PASS * FINGERS,
	])
	print("output_latency báo về: %.3f s" % AudioServer.get_output_latency())

	# Kiểm tra tỉnh táo: một cú chạm phải làm tăng bộ đếm. Nếu không, phép đo
	# bên dưới đo cái rỗng và mọi con số đều vô nghĩa.
	var probe_before := GameState.notes_played_this_session
	_touch(0, 0, true)
	await get_tree().process_frame
	_touch(0, 0, false)
	await get_tree().process_frame
	var routed := GameState.notes_played_this_session > probe_before
	print("input tới được bàn phím: %s" % ("CÓ" if routed else "KHÔNG — số liệu dưới đây vô nghĩa"))

	# Đếm giọng chỉ đọc sổ sách của chính AudioDirector — nó KHÔNG chứng minh
	# có tiếng thật đi ra. Đo đỉnh tín hiệu trên bus mới là bằng chứng.
	print("pad nền đang chạy: %s  (bus Music idx=%d)" % [
		"CÓ" if AudioDirector.pad_is_playing() else "KHÔNG",
		AudioServer.get_bus_index(&"Music"),
	])
	var bus_music := AudioServer.get_bus_index(&"Music")
	var peak_music := -200.0
	for i in 30:
		await get_tree().process_frame
		peak_music = maxf(peak_music, AudioServer.get_bus_peak_volume_left_db(bus_music, 0))
	print("đỉnh bus Music: %.1f dB => %s" % [
		peak_music, "pad CÓ ra tiếng" if peak_music > -60.0 else "IM LẶNG",
	])

	var bus_notes := AudioServer.get_bus_index(&"Notes")
	var bus_master := AudioServer.get_bus_index(&"Master")
	var peak_notes := -200.0
	var peak_master := -200.0
	for i in 40:
		await get_tree().process_frame
		peak_notes = maxf(peak_notes, AudioServer.get_bus_peak_volume_left_db(bus_notes, 0))
		peak_master = maxf(peak_master, AudioServer.get_bus_peak_volume_left_db(bus_master, 0))
	print("đỉnh tín hiệu — Notes %.1f dB · Master %.1f dB  => %s" % [
		peak_notes, peak_master,
		"CÓ tiếng thật đi ra" if peak_notes > -60.0 else "IM LẶNG — audio không mix",
	])
	print("")

	var drifts: Array[float] = []
	for p in PASSES:
		drifts.append(await _one_pass())
		print("lượt %d: trôi %+8.1f KB   object=%d   tổng nốt=%d" % [
			p + 1, drifts[p],
			Performance.get_monitor(Performance.OBJECT_COUNT),
			GameState.notes_played_this_session,
		])

	print("")
	var first := drifts[0]
	var tail := 0.0
	for i in range(1, drifts.size()):
		tail += drifts[i]
	tail /= float(drifts.size() - 1)
	print("lượt đầu %.1f KB · trung bình các lượt sau %.1f KB" % [first, tail])
	var per_strike := tail / float(ROUNDS_PER_PASS * FINGERS)
	print("=> %.3f KB mỗi cú chạm ở trạng thái ổn định" % per_strike)
	print("ngón còn kẹt: %d   giọng còn kêu: %d" % [
		_keyboard.fingers_down(), AudioDirector.active_voice_count(),
	])

	# Ghi chú: Godot sẽ báo vài "resources still in use at exit" ở đây — đó là
	# autoload giữ stream cho tới lúc engine tắt, và chỉ xảy ra với riêng máy đo
	# này vì nó dựng main.tscn làm con. Bản game chạy bình thường thoát sạch.
	get_tree().quit()


func _one_pass() -> float:
	# Để tween và đuôi nốt tắt hẳn trước khi lấy mốc.
	await get_tree().create_timer(2.0).timeout
	var before := Performance.get_monitor(Performance.MEMORY_STATIC)

	for r in ROUNDS_PER_PASS:
		for f in FINGERS:
			_touch(f, (r * FINGERS + f) % Notes.count(), true)
		await get_tree().process_frame
		for f in FINGERS:
			_touch(f, (r * FINGERS + f) % Notes.count(), false)
		await get_tree().process_frame

	await get_tree().create_timer(2.5).timeout
	return (Performance.get_monitor(Performance.MEMORY_STATIC) - before) / 1024.0


func _touch(finger: int, key: int, pressed: bool) -> void:
	var e := InputEventScreenTouch.new()
	e.index = finger
	e.pressed = pressed
	e.position = _points[key]
	Input.parse_input_event(e)
