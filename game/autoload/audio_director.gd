extends Node
## AudioDirector — autoload. Đường âm thanh của toàn game đi qua đây.
##
## Ràng buộc sống còn (docs/gameplay-design.html · Kỹ thuật):
##   "Tạo sẵn pool AudioStreamPlayer lúc khởi động và tái sử dụng; không bao giờ
##    instantiate() tại thời điểm chạm. Dùng .wav (không .ogg). Attack < 10 ms.
##    Mục tiêu: dưới 60 ms từ ngón tay đến âm thanh."
##
## Có HAI backend sau cùng một hàm play_note(). Tài liệu viết "pool 16
## AudioStreamPlayer"; Godot 4.7 có AudioStreamPolyphonic làm đúng việc đó gọn
## hơn (một player, không bookkeeping voice-stealing). Chưa có số đo trên máy
## thật thì chưa chốt được cái nào — nên giữ cả hai và để Spike B phân xử.

enum Backend {
	POLYPHONIC,  ## Một AudioStreamPlayer + AudioStreamPolyphonic (mặc định).
	POOL,        ## Pool 16 AudioStreamPlayer round-robin, đúng như tài liệu mô tả.
}

const POOL_SIZE := 16
const POLYPHONY := 32
const BUS_NOTES := &"Notes"

## Số ID gần nhất giữ lại để overlay đếm được số nốt đang kêu.
## Mảng cấp phát sẵn — đường nóng không được cấp phát gì.
const RECENT_IDS := 48

var backend: Backend = Backend.POLYPHONIC:
	set(value):
		if backend == value:
			return
		backend = value
		_silence_all()

var _streams: Array[AudioStream] = []
var _bus: StringName = &"Master"

var _poly_player: AudioStreamPlayer
var _poly: AudioStreamPlaybackPolyphonic

var _pool: Array[AudioStreamPlayer] = []
var _pool_next: int = 0

var _recent: PackedInt64Array = PackedInt64Array()
var _recent_i: int = 0

## get_output_latency() đắt — tài liệu 4.7 dặn đừng gọi mỗi frame. Cache lại.
var _cached_latency_ms: float = 0.0


func _ready() -> void:
	# Phải sống qua pause thì mới tắt tiếng được lúc app xuống nền.
	process_mode = Node.PROCESS_MODE_ALWAYS

	_bus = BUS_NOTES if AudioServer.get_bus_index(BUS_NOTES) != -1 else &"Master"

	_recent.resize(RECENT_IDS)
	_recent.fill(AudioStreamPlaybackPolyphonic.INVALID_ID)

	_preload_samples()
	_setup_polyphonic()
	_setup_pool()

	refresh_latency()


func _preload_samples() -> void:
	_streams.resize(Notes.count())
	for i in Notes.count():
		var path: String = Notes.TABLE[i]["sample"]
		var stream: AudioStream = load(path)
		if stream == null:
			push_error("AudioDirector: không nạp được sample %s" % path)
		_streams[i] = stream


func _setup_polyphonic() -> void:
	var poly := AudioStreamPolyphonic.new()
	poly.polyphony = POLYPHONY

	_poly_player = AudioStreamPlayer.new()
	_poly_player.name = "PolyphonicPlayer"
	# Bus của player và bus truyền vào play_stream() phải khớp nhau, nếu không
	# âm thanh lặng lẽ chạy về Master mà không báo lỗi gì.
	_poly_player.bus = _bus
	_poly_player.stream = poly
	add_child(_poly_player)

	# Phải play() thì mới lấy được playback instance.
	_poly_player.play()
	_poly = _poly_player.get_stream_playback() as AudioStreamPlaybackPolyphonic
	if _poly == null:
		push_error("AudioDirector: không lấy được AudioStreamPlaybackPolyphonic")


func _setup_pool() -> void:
	_pool.resize(POOL_SIZE)
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.name = "PoolPlayer%d" % i
		p.bus = _bus
		add_child(p)
		_pool[i] = p


# ---------------------------------------------------------------- đường nóng --
# Từ đây xuống: không load(), không new(), không nối chuỗi, không cấp phát.

func play_note(index: int) -> void:
	if index < 0 or index >= _streams.size():
		return
	var stream := _streams[index]
	if stream == null:
		return

	if backend == Backend.POLYPHONIC:
		var id := _poly.play_stream(
			stream, 0.0, 0.0, 1.0, AudioServer.PLAYBACK_TYPE_DEFAULT, _bus
		)
		_recent[_recent_i] = id
		_recent_i = (_recent_i + 1) % RECENT_IDS
	else:
		var p := _pool[_pool_next]
		_pool_next = (_pool_next + 1) % POOL_SIZE
		p.stream = stream
		p.play()


# ------------------------------------------------------------------ chẩn đoán --

## Số nốt đang thực sự kêu. Chỉ overlay gọi, KHÔNG gọi trong đường chạm.
func active_voice_count() -> int:
	var n := 0
	if backend == Backend.POLYPHONIC:
		if _poly == null:
			return 0
		for id in _recent:
			if id != AudioStreamPlaybackPolyphonic.INVALID_ID and _poly.is_stream_playing(id):
				n += 1
	else:
		for p in _pool:
			if p.playing:
				n += 1
	return n


func refresh_latency() -> void:
	_cached_latency_ms = AudioServer.get_output_latency() * 1000.0


func latency_ms() -> float:
	return _cached_latency_ms


func backend_name() -> String:
	return "POLYPHONIC" if backend == Backend.POLYPHONIC else "POOL x%d" % POOL_SIZE


func toggle_backend() -> void:
	backend = Backend.POOL if backend == Backend.POLYPHONIC else Backend.POLYPHONIC


# ------------------------------------------------------------------ vòng đời --

func _silence_all() -> void:
	for p in _pool:
		p.stop()
	if _poly != null:
		for i in _recent.size():
			var id := _recent[i]
			if id != AudioStreamPlaybackPolyphonic.INVALID_ID:
				_poly.stop_stream(id)
			_recent[i] = AudioStreamPlaybackPolyphonic.INVALID_ID


func _notification(what: int) -> void:
	# Bắt buộc theo mobile port checklist: app xuống nền thì phải câm.
	# Trên iOS đây là chuyện xảy ra thường xuyên, không phải trường hợp hiếm.
	match what:
		NOTIFICATION_APPLICATION_PAUSED:
			_silence_all()
			AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Master"), true)
		NOTIFICATION_APPLICATION_RESUMED:
			AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Master"), false)
			refresh_latency()
