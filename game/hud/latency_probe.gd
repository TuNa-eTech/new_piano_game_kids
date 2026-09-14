extends CanvasLayer
## Overlay chẩn đoán cho Spike B. Không có nó thì "không trễ" chỉ là cảm giác.
##
## CẢNH BÁO ĐỌC SỐ: con số độ trễ ở đây CHỈ có nghĩa trên máy iOS thật.
## Trên Simulator, Godot chạy bằng CoreAudio của chính con Mac và sẽ cho một
## con số đẹp không có thật — xem docs/production-pipeline.html:
##   "Cả Spike B lẫn Spike C đều vô nghĩa trên máy ảo hoặc máy cao cấp —
##    độ trễ âm thanh chính là thứ cần đo, và máy tốt sẽ nói dối bạn."

const TOGGLE_KEY := KEY_F3
const BACKEND_KEY := KEY_F4
const REBASE_KEY := KEY_F5
const LATENCY_REFRESH_SEC := 1.0

var _keyboard: PianoKeyboard
var _call_response: CallResponse
var _latency_timer: float = 0.0
## Mốc bộ nhớ lúc bắt đầu. Đường nóng không cấp phát thì con số này phải phẳng.
## Performance.get_monitor() trả về float — khai báo int ở đây sẽ ăn cảnh báo
## NARROWING_CONVERSION và cắt mất phần lẻ.
var _memory_baseline: float = 0.0

@onready var _label: Label = $Panel/Label
@onready var _panel: PanelContainer = $Panel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_memory_baseline = Performance.get_monitor(Performance.MEMORY_STATIC)


func bind_keyboard(keyboard: PianoKeyboard) -> void:
	_keyboard = keyboard


func bind_call_response(call_response: CallResponse) -> void:
	_call_response = call_response


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		TOGGLE_KEY:
			_panel.visible = not _panel.visible
		BACKEND_KEY:
			AudioDirector.toggle_backend()
		REBASE_KEY:
			# Lượt đập ĐẦU TIÊN luôn kéo theo vài trăm KB hâm nóng allocator —
			# đó là bình thường, không phải rò. Đặt lại mốc rồi đập tiếp: từ lượt
			# thứ hai trở đi con số phải gần như đứng yên.
			_memory_baseline = Performance.get_monitor(Performance.MEMORY_STATIC)


func _process(delta: float) -> void:
	if not _panel.visible:
		return

	# get_output_latency() đắt — tài liệu 4.7 dặn đừng gọi mỗi frame.
	_latency_timer += delta
	if _latency_timer >= LATENCY_REFRESH_SEC:
		_latency_timer = 0.0
		AudioDirector.refresh_latency()

	var mem_now := Performance.get_monitor(Performance.MEMORY_STATIC)
	var mem_drift := (mem_now - _memory_baseline) / 1024.0

	# macOS/CoreAudio trả về đúng 0 cho get_output_latency() — đã kiểm chứng.
	# Đừng đọc số 0 đó thành "không có độ trễ".
	var lat := AudioDirector.latency_ms()
	var lat_line := (
		"độ trễ ra  driver không báo (0.0)"
		if lat <= 0.0
		else "độ trễ ra  %.1f ms   (mục tiêu < 60 ms tổng)" % lat
	)

	_label.text = "\n".join([
		"F3 ẩn/hiện · F4 đổi backend · F5 đặt lại mốc bộ nhớ",
		"backend    %s" % AudioDirector.backend_name(),
		lat_line,
		"nốt đang kêu %d" % AudioDirector.active_voice_count(),
		"ngón đang chạm %d" % (_keyboard.fingers_down() if _keyboard else 0),
		"tổng nốt   %d" % GameState.notes_played_this_session,
		"vòng chơi  %s  %s" % [
			_call_response.state_name() if _call_response else "-",
			_call_response.progress() if _call_response else "",
		],
		"sao / trang %d / %d" % [GameState.stars, GameState.page_index + 1],
		"bộ nhớ trôi %+.1f KB" % mem_drift,
		"fps        %d" % Engine.get_frames_per_second(),
		"",
		"Bộ nhớ: lượt đập đầu tiên trôi vài trăm KB là allocator",
		"hâm nóng, KHÔNG phải rò. Bấm F5 rồi đập tiếp — từ đó",
		"con số phải gần như đứng yên.",
		"",
		"Số độ trễ chỉ có nghĩa trên máy iOS thật.",
		"Simulator dùng CoreAudio của Mac — nó nói dối.",
	])
