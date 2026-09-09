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
const BUS_MUSIC := &"Music"

## Pad hoà âm nền — docs/gameplay-design.html · Quyết định 02:
## "biến mọi nốt bé bấm thành một phần của bản nhạc, và lấp khoảng lặng khi bé nghĩ".
const PAD_STREAM := "res://assets/placeholder/music/pad_c_am_f_g.wav"

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

var _pad_player: AudioStreamPlayer


func _ready() -> void:
	# Phải sống qua pause thì mới tắt tiếng được lúc app xuống nền.
	process_mode = Node.PROCESS_MODE_ALWAYS

	_bus = BUS_NOTES if AudioServer.get_bus_index(BUS_NOTES) != -1 else &"Master"

	_recent.resize(RECENT_IDS)
	_recent.fill(AudioStreamPlaybackPolyphonic.INVALID_ID)

	_preload_samples()
	_setup_polyphonic()
	_setup_pool()
	_setup_pad()

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


## Pad chạy trên bus Music riêng (-18 dB trong default_bus_layout.tres), tách
## khỏi bus Notes để sau này chỉnh cân bằng mà không đụng tới tiếng đàn.
func _setup_pad() -> void:
	var stream: AudioStream = load(PAD_STREAM)
	if stream == null:
		push_error("AudioDirector: không nạp được pad %s" % PAD_STREAM)
		return

	_pad_player = AudioStreamPlayer.new()
	_pad_player.name = "PadPlayer"
	_pad_player.bus = BUS_MUSIC if AudioServer.get_bus_index(BUS_MUSIC) != -1 else &"Master"
	_pad_player.stream = stream
	add_child(_pad_player)
	_pad_player.play()


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


## Biến thể có cao độ và âm lượng riêng — dùng cho tiếng "ting" của hạt sao và
## cho tiếng ngân nhắc nhẹ khi bé ngồi im. Vẫn không cấp phát gì.
func play_note_pitched(index: int, pitch: float, volume_db: float = 0.0) -> void:
	if index < 0 or index >= _streams.size():
		return
	var stream := _streams[index]
	if stream == null:
		return

	if backend == Backend.POLYPHONIC:
		var id := _poly.play_stream(
			stream, 0.0, volume_db, pitch, AudioServer.PLAYBACK_TYPE_DEFAULT, _bus
		)
		_recent[_recent_i] = id
		_recent_i = (_recent_i + 1) % RECENT_IDS
	else:
		var p := _pool[_pool_next]
		_pool_next = (_pool_next + 1) % POOL_SIZE
		p.stream = stream
		p.pitch_scale = pitch
		p.volume_db = volume_db
		p.play()
		p.pitch_scale = 1.0
		p.volume_db = 0.0


## Tiếng "ting" khi một hạt sao rơi vào lọ (Quyết định 04). Placeholder: chính
## nốt cao nhất kéo lên một quãng tám, chưa cần file SFX riêng của Bước 3.
func play_ting() -> void:
	play_note_pitched(Notes.count() - 1, 2.0, -8.0)


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

func pad_is_playing() -> bool:
	return _pad_player != null and _pad_player.playing


func _silence_all() -> void:
	for p in _pool:
		p.stop()
	if _poly != null:
		for i in _recent.size():
			var id := _recent[i]
			if id != AudioStreamPlaybackPolyphonic.INVALID_ID:
				_poly.stop_stream(id)
			_recent[i] = AudioStreamPlaybackPolyphonic.INVALID_ID


## Tắt hết tiếng và nhả những tham chiếu do node này giữ, trước khi cây scene
## bị tháo.
##
## ĐÃ ĐO, ĐỪNG KỲ VỌNG QUÁ: hàm này CÓ chạy, nhưng KHÔNG dập tắt được thông báo
## "N ObjectDB instances were leaked / resources still in use at exit" khi thoát
## lúc còn nốt đang ngân. Thread trộn âm của engine vẫn giữ AudioStreamPlayback
## tới sau thời điểm ObjectDB kiểm tra, và GDScript không ép nó nhả sớm hơn được.
## Kể từ khi cây thần tự hát lúc khởi động thì gần như lần thoát nào cũng vướng.
##
## Vô hại: chỉ xảy ra lúc tiến trình kết thúc, không ảnh hưởng bộ nhớ trong lúc
## chơi (soak test đã chứng minh đường nóng phẳng). Giữ hàm này vì dọn tham
## chiếu của chính mình vẫn là việc đúng, không phải vì nó làm sạch log.
func _exit_tree() -> void:
	_silence_all()

	if _pad_player != null:
		_pad_player.stop()
		_pad_player.stream = null

	if _poly_player != null:
		_poly_player.stop()
		_poly_player.stream = null
	_poly = null

	for p in _pool:
		p.stream = null

	_streams.clear()


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
