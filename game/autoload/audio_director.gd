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
const BUS_SFX := &"SFX"
const BASE_NOTE_DB := -9.0

## Thư mục SFX thật của Bước 3. Thiếu file thì play_sfx() lặng lẽ bỏ qua —
## game vẫn chơi được suốt quãng thay dần từ art tạm sang art thật.
const SFX_DIR := "res://assets/audio/"
static var SFX_NAMES: Array[String] = [
	"star_ting", "chapter_select", "chest_open", "page_turn",
	"menu_open", "hold_complete", "chapter_unlock", "free_play_toggle",
]

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
## Cao độ cố định của từng phím. Với giọng thú Bước 3 (tất cả thu ở G4) đây là
## hệ số dịch; với placeholder Tuần 1 (mỗi file đã đúng cao độ) đây là 1,0.
## Quyết MỘT LẦN lúc khởi động rồi tra bảng — đường nóng không được có nhánh if.
var _pitches: PackedFloat32Array = PackedFloat32Array()
## Nốt đàn nền phát chồng dưới giọng thú cho dày tiếng. Chưa có thì bỏ qua.
var _base_note: AudioStream = null

## Nhạc cụ mộc 3 chương (Hướng 3: Sáo Trúc, Kalimba, Chuông Gió)
## _chapter_instruments[chapter][note_idx] -> AudioStream (nạp sẵn 21 stream)
var _chapter_instruments: Array[Array] = []
## Con trỏ tới bộ stream nhạc cụ mộc của chương đang mở. Đường nóng tra O(1).
var _active_inst_streams: Array[AudioStream] = []
const INST_NOTE_DB := -7.0

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

## tên SFX -> stream đã nạp. Nạp MỘT LẦN lúc khởi động; đường nóng chỉ tra bảng.
var _sfx: Dictionary = {}
var _sfx_player: AudioStreamPlayer
var _sfx_poly: AudioStreamPlaybackPolyphonic


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
	_setup_sfx()

	refresh_latency()
	call_deferred("_connect_game_state")


func _connect_game_state() -> void:
	if is_instance_valid(GameState):
		GameState.page_changed.connect(_on_page_changed)
		set_chapter_instrument(GameState.chapter_index())


func _on_page_changed(_page_idx: int) -> void:
	if is_instance_valid(GameState):
		set_chapter_instrument(GameState.chapter_index())


## Đổi nhạc cụ mộc theo chương. Tra bảng O(1), không cấp phát, không if-else trên đường nóng.
func set_chapter_instrument(chapter_idx: int) -> void:
	var ch := clampi(chapter_idx, 0, _chapter_instruments.size() - 1)
	if ch < _chapter_instruments.size():
		_active_inst_streams = _chapter_instruments[ch]


## Bước 3 thả bảy file voice_<con vật>_g4.wav vào assets/audio/ là tự chuyển
## sang giọng thật. Chưa đủ bảy file thì dùng placeholder Tuần 1 — KHÔNG trộn
## nửa nọ nửa kia, vì bảy phím nửa giọng thật nửa sóng tổng hợp còn khó nghe hơn
## là bảy phím placeholder đồng đều.
func _preload_samples() -> void:
	_streams.resize(Notes.count())
	_pitches.resize(Notes.count())

	var voice_paths: Array[String] = []
	for i in Notes.count():
		voice_paths.append("%svoice_%s_g4.wav" % [SFX_DIR, Notes.voice_of(i)])

	var have_voices := true
	for path in voice_paths:
		if not ResourceLoader.exists(path):
			have_voices = false
			break

	for i in Notes.count():
		var path: String = voice_paths[i] if have_voices else Notes.TABLE[i]["sample"]
		var stream: AudioStream = load(path)
		if stream == null:
			push_error("AudioDirector: không nạp được sample %s" % path)
		_streams[i] = stream
		_pitches[i] = Notes.pitch_of(i) if have_voices else 1.0

	var base_path := "%snote_base_g4.wav" % SFX_DIR
	if ResourceLoader.exists(base_path):
		_base_note = load(base_path)

	# Nạp 21 sample nhạc cụ mộc thật cho 3 chương (Hướng 3)
	_chapter_instruments.resize(3)
	for ch in 3:
		var streams_for_ch: Array[AudioStream] = []
		streams_for_ch.resize(Notes.count())
		for i in Notes.count():
			var p := Notes.instrument_path(ch, i)
			if ResourceLoader.exists(p):
				var stream: AudioStream = load(p)
				streams_for_ch[i] = stream
		_chapter_instruments[ch] = streams_for_ch

	set_chapter_instrument(0)



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
	var ogg_path := "%sbgm_forest_loop.ogg" % SFX_DIR
	var path := ogg_path if ResourceLoader.exists(ogg_path) else PAD_STREAM
	var stream: AudioStream = load(path)
	if stream == null:
		push_error("AudioDirector: không nạp được pad %s" % path)
		return

	_pad_player = AudioStreamPlayer.new()
	_pad_player.name = "PadPlayer"
	_pad_player.bus = BUS_MUSIC if AudioServer.get_bus_index(BUS_MUSIC) != -1 else &"Master"
	_pad_player.stream = stream
	add_child(_pad_player)
	_pad_player.play()


## SFX đi qua một AudioStreamPolyphonic riêng trên bus SFX, tách hẳn khỏi bus
## Notes: tài liệu chốt "Music không bao giờ được lấn tiếng nốt", và SFX cũng vậy.
## Chỉnh cân bằng hạt sao sau này không được đụng tới tiếng đàn.
func _setup_sfx() -> void:
	var bus := BUS_SFX if AudioServer.get_bus_index(BUS_SFX) != -1 else &"Master"

	var poly := AudioStreamPolyphonic.new()
	poly.polyphony = 8
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SfxPlayer"
	_sfx_player.bus = bus
	_sfx_player.stream = poly
	add_child(_sfx_player)
	_sfx_player.play()
	_sfx_poly = _sfx_player.get_stream_playback() as AudioStreamPlaybackPolyphonic

	# Bước 3 chưa xong thì thư mục còn trống. Thiếu file KHÔNG phải lỗi —
	# đừng push_error, nếu không log sẽ đầy tiếng ồn suốt cả giai đoạn chuyển.
	for name in SFX_NAMES:
		var path := "%ssfx_%s.wav" % [SFX_DIR, name]
		if ResourceLoader.exists(path):
			_sfx[name] = load(path)


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

	var pitch := _pitches[index]

	if backend == Backend.POLYPHONIC:
		var id := _poly.play_stream(
			stream, 0.0, 0.0, pitch, AudioServer.PLAYBACK_TYPE_DEFAULT, _bus
		)
		_recent[_recent_i] = id
		_recent_i = (_recent_i + 1) % RECENT_IDS
		# Nhạc cụ mộc của chương (Hướng 3): phát chuẩn cao độ với âm sắc mộc tự nhiên
		if index < _active_inst_streams.size() and _active_inst_streams[index] != null:
			_poly.play_stream(
				_active_inst_streams[index], 0.0, INST_NOTE_DB, 1.0,
				AudioServer.PLAYBACK_TYPE_DEFAULT, _bus
			)
		elif _base_note != null:
			# Nốt đàn nền chồng dưới giọng thú nếu chưa có sample riêng
			_poly.play_stream(
				_base_note, 0.0, BASE_NOTE_DB, pitch,
				AudioServer.PLAYBACK_TYPE_DEFAULT, _bus
			)
	else:
		var p := _pool[_pool_next]
		_pool_next = (_pool_next + 1) % POOL_SIZE
		p.stream = stream
		p.pitch_scale = pitch
		p.play()
		p.pitch_scale = 1.0


## Phát riêng nốt của một nhạc cụ theo chương (dùng cho preview trên bản đồ chương / chọn bài)
func play_instrument_note(chapter: int, index: int, volume_db: float = 0.0) -> void:
	if chapter < 0 or chapter >= _chapter_instruments.size():
		return
	var ch_streams: Array[AudioStream] = _chapter_instruments[chapter]
	if index < 0 or index >= ch_streams.size():
		return
	var stream: AudioStream = ch_streams[index]
	if stream == null or _poly == null:
		return
	_poly.play_stream(
		stream, 0.0, volume_db, 1.0, AudioServer.PLAYBACK_TYPE_DEFAULT, _bus
	)



## Biến thể có cao độ và âm lượng riêng — dùng cho tiếng "ting" của hạt sao và
## cho tiếng ngân nhắc nhẹ khi bé ngồi im. Vẫn không cấp phát gì.
func play_note_pitched(index: int, pitch: float, volume_db: float = 0.0) -> void:
	if index < 0 or index >= _streams.size():
		return
	var stream := _streams[index]
	if stream == null:
		return

	# pitch truyền vào là hệ số TƯƠNG ĐỐI so với cao độ thường của phím, nên phải
	# nhân chứ không thay — nếu không, tiếng ngân nhắc nhẹ sẽ sai nốt khi dùng
	# giọng thú G4 dùng chung.
	var absolute := pitch * _pitches[index]

	if backend == Backend.POLYPHONIC:
		var id := _poly.play_stream(
			stream, 0.0, volume_db, absolute, AudioServer.PLAYBACK_TYPE_DEFAULT, _bus
		)
		_recent[_recent_i] = id
		_recent_i = (_recent_i + 1) % RECENT_IDS
	else:
		var p := _pool[_pool_next]
		_pool_next = (_pool_next + 1) % POOL_SIZE
		p.stream = stream
		p.pitch_scale = absolute
		p.volume_db = volume_db
		p.play()
		p.pitch_scale = 1.0
		p.volume_db = 0.0


## Phát một SFX theo tên. Không có file thì im lặng bỏ qua — Bước 3 thả file
## vào assets/audio/ là tự chạy, không phải sửa một dòng nào ở nơi gọi.
## Đường nóng: chỉ tra Dictionary, không load(), không nối chuỗi.
func play_sfx(sfx_name: String) -> void:
	var stream: AudioStream = _sfx.get(sfx_name)
	if stream == null or _sfx_poly == null:
		return
	_sfx_poly.play_stream(
		stream, 0.0, 0.0, 1.0, AudioServer.PLAYBACK_TYPE_DEFAULT, BUS_SFX
	)


func has_sfx(sfx_name: String) -> bool:
	return _sfx.has(sfx_name)


## Tiếng "ting" khi một hạt sao rơi vào lọ (Quyết định 04).
## Có sfx_star_ting.wav thì dùng nó; chưa có thì lùi về placeholder của Tuần 1 —
## chính nốt cao nhất kéo lên một quãng tám.
func play_ting() -> void:
	if _sfx.has("star_ting"):
		play_sfx("star_ting")
		return
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

	for ch in _chapter_instruments:
		ch.clear()
	_chapter_instruments.clear()
	_active_inst_streams.clear()



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
