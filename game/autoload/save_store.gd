extends Node
## SaveStore — autoload. Một file user://save.cfg, không có gì khác.
##
## docs/gameplay-design.html · Kỹ thuật · Lưu trữ:
##   "Một file user://save.cfg: chương đã mở, con vật đã mở, tên bé, tổng hạt
##    sao... Ghi lại sau mỗi trang."
## và ranh giới cứng: KHÔNG cloud, KHÔNG phân tích hành vi, không gì rời khỏi máy.
## File này nằm trong user:// của thiết bị và ở nguyên đó.
##
## Thời điểm ghi có HAI mốc, không phải một:
##   ① sau mỗi trang — tài liệu chốt thế, và chuyển trang là sự kiện thưa;
##   ② lúc app xuống nền — trên iOS hệ điều hành giết app nền rất thẳng tay và
##      NOTIFICATION_WM_CLOSE_REQUEST KHÔNG đáng tin. Bé vuốt app đi giữa trang
##      mà chỉ trông vào lúc quit thì trang vừa chơi mất trắng.
##
## KHÔNG có tiến độ giữa trang trong file. Bé đang đánh dở nốt thứ 3 của chuỗi
## mà app bị đóng thì lần sau vào lại ĐẦU trang đó. Chuỗi dài vài giây, khôi
## phục giữa chừng vừa rối vừa khó hiểu với trẻ — nghe cây hát lại từ đầu mới
## là hành vi đúng.

const DEFAULT_PATH := "user://save.cfg"
const BACKUP_SUFFIX := ".bak"

## Tăng số này khi bố cục file đổi, rồi viết nhánh nâng cấp trong _migrate().
const VERSION := 1

const SECTION_META := "meta"
const SECTION_PROGRESS := "progress"

var _path := DEFAULT_PATH
## Tắt được để máy đo không ghi đè file thật của người dùng.
var _enabled := true


func _ready() -> void:
	# Không có dòng này thì autoload sẽ KHÔNG nhận notification khi cây đang bị
	# dừng — mà bản đồ chương thì dừng cây. App xuống nền lúc đang mở bản đồ là
	# đúng kịch bản hay xảy ra nhất, và cũng là kịch bản mất dữ liệu.
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_into_game_state()

	# Nối SAU khi nạp, và đây là thứ tự CÓ Ý NGHĨA, đừng đảo:
	#   ① nối sau khi nạp  -> apply_saved() phát page_changed mà không ghi ngược
	#      lại chính thứ vừa đọc lên;
	#   ② autoload nối trước main scene -> khi trang đổi, SaveStore ghi TRƯỚC khi
	#      CallResponse dựng lại trang. File luôn nói "đầu trang N", đúng bằng
	#      trạng thái mà lần mở app sau sẽ khôi phục.
	GameState.page_changed.connect(_on_page_changed)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED, \
		NOTIFICATION_WM_WINDOW_FOCUS_OUT, \
		NOTIFICATION_WM_CLOSE_REQUEST:
			save()


func _on_page_changed(_page_index: int) -> void:
	save()


# ----------------------------------------------------------------------- ghi --

func save() -> bool:
	if not _enabled:
		return false

	var cfg := ConfigFile.new()
	cfg.set_value(SECTION_META, "version", VERSION)
	cfg.set_value(SECTION_PROGRESS, "page_index", GameState.page_index)
	cfg.set_value(SECTION_PROGRESS, "max_page_reached", GameState.max_page_reached)
	cfg.set_value(SECTION_PROGRESS, "stars", GameState.stars)

	# Tài liệu liệt kê thêm "con vật đã mở" và "tên bé". Hai thứ đó CHƯA CÓ tính
	# năng nào sinh ra dữ liệu: v1 chốt đúng 7 con vật mở sẵn, và chưa có màn
	# nhập tên. Để chỗ trống kèm ghi chú còn hơn bịa dữ liệu rồi tin vào nó.
	cfg.set_value(SECTION_PROGRESS, "animals_unlocked", Notes.count())
	cfg.set_value(SECTION_PROGRESS, "child_name", "")
	cfg.set_value(SECTION_PROGRESS, "bedtime_minutes", GameState.bedtime_minutes)
	cfg.set_value(SECTION_PROGRESS, "instrument_mode", GameState.instrument_mode)

	# Bản sao lưu chụp TRƯỚC khi đè: nếu lần ghi này chết giữa chừng (app bị
	# giết đúng lúc xuống nền) thì .bak vẫn là một file nguyên vẹn của lần trước.
	_backup()

	var err := cfg.save(_path)
	if err != OK:
		push_error("SaveStore: ghi %s thất bại (lỗi %d)" % [_path, err])
		return false
	return true


func _backup() -> void:
	if not FileAccess.file_exists(_path):
		return
	var err := DirAccess.copy_absolute(_path, _path + BACKUP_SUFFIX)
	if err != OK:
		push_warning("SaveStore: không chép được bản .bak (lỗi %d)" % err)


# ----------------------------------------------------------------------- đọc --

## Trả về true nếu đã nạp được từ file (chính hoặc .bak). File mới tinh hoặc
## hỏng cả hai thì về mặc định — và đó là một kết cục HỢP LỆ, không phải lỗi:
## mất tiến độ vẫn hơn là app không mở được.
func load_into_game_state() -> bool:
	var data := _read(_path)
	if data.is_empty():
		data = _read(_path + BACKUP_SUFFIX)
		if not data.is_empty():
			push_warning("SaveStore: file chính hỏng, đã dùng bản .bak")
	if data.is_empty():
		return false

	GameState.apply_saved(
		data["page_index"], data["max_page_reached"], data["stars"]
	)
	if data.has("bedtime_minutes"):
		GameState.set_bedtime_timer(data["bedtime_minutes"])
	if data.has("instrument_mode"):
		GameState.instrument_mode = data["instrument_mode"]
	return true


## Đọc một file thành dictionary đã kiểm, hoặc {} nếu không dùng được.
## KHÔNG BAO GIỜ tin nội dung file: get_value luôn có giá trị mặc định, kiểu
## luôn được kiểm, số luôn được kẹp về khoảng hợp lệ. File nằm trong user:// —
## một lần ghi dở dang hay một lần nghịch tay là đủ để nó thành rác.
func _read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return {}

	var version := _int_at(cfg, SECTION_META, "version", 0)
	if version <= 0 or version > VERSION:
		push_warning("SaveStore: version %d không đọc được, bỏ qua file" % version)
		return {}

	var last_page := Chapters.total_pages() - 1
	var max_page := clampi(
		_int_at(cfg, SECTION_PROGRESS, "max_page_reached", 0), 0, last_page
	)
	return {
		"page_index": clampi(
			_int_at(cfg, SECTION_PROGRESS, "page_index", 0), 0, last_page
		),
		"max_page_reached": max_page,
		"stars": maxi(0, _int_at(cfg, SECTION_PROGRESS, "stars", 0)),
		"bedtime_minutes": clampi(_int_at(cfg, SECTION_PROGRESS, "bedtime_minutes", 0), 0, 120),
		"instrument_mode": clampi(_int_at(cfg, SECTION_PROGRESS, "instrument_mode", 0), 0, 4),
	}


## get_value trả về đúng Variant đang nằm trong file — kể cả khi đó là chuỗi
## "abc" ở chỗ đáng lẽ phải là số. Kiểm kiểu ở đây, đừng để nó chui vào GameState.
func _int_at(cfg: ConfigFile, section: String, key: String, fallback: int) -> int:
	var value: Variant = cfg.get_value(section, key, fallback)
	var kind := typeof(value)
	if kind == TYPE_INT or kind == TYPE_FLOAT:
		return int(value)
	return fallback


# ------------------------------------------------------------------ máy đo --

## Máy đo phải đo được chính nó, không đo lẫn file lưu của lần chạy trước.
func use_test_path(path: String) -> void:
	_path = path


func enabled() -> bool:
	return _enabled


func set_enabled(value: bool) -> void:
	_enabled = value


func path() -> String:
	return _path


func erase() -> void:
	DirAccess.remove_absolute(_path)
	DirAccess.remove_absolute(_path + BACKUP_SUFFIX)


## Ngắt SaveStore khỏi ván chơi rồi đưa GameState về mặc định, để phép đo không
## phụ thuộc vào những gì máy này đã chơi hôm qua.
func reset_for_test() -> void:
	_enabled = false
	GameState.reset_all()
