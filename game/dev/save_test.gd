extends Node
## Máy đo file lưu. CHỈ dùng khi phát triển.
##
## Đo bốn thứ mà mắt thường không thấy được:
##   ① ghi rồi đọc lại có khớp từng trường không;
##   ② file rác thì app còn mở được không (bé nghịch, hoặc ghi dở lúc bị giết);
##   ③ file chính hỏng thì bản .bak có cứu được không;
##   ④ tiến độ giữa trang KHÔNG được lưu — đây là quyết định, không phải thiếu sót.
##
## Chạy được cả headless, phần này không đụng tới chạm màn hình:
##   Godot --headless --path . res://game/dev/save_test.tscn

const TEST_PATH := "user://save_test.cfg"

var _fails: int = 0


## Dọn bộ nhớ mà KHÔNG chạm vào đĩa.
##
## reset_all() phát page_changed, và SaveStore ghi file mỗi lần nghe tín hiệu đó
## ("ghi lại sau mỗi trang"). Nên dọn thẳng tay sẽ ghi đè file bằng số 0 rồi
## phép đo tự đọc lại số 0 của chính nó — mọi khẳng định đều trượt vì lý do sai.
func _reset_memory_only() -> void:
	SaveStore.set_enabled(false)
	GameState.reset_all()
	SaveStore.set_enabled(true)


func _check(label: String, ok: bool, detail: String = "") -> void:
	if not ok:
		_fails += 1
	print("  [%s] %s%s" % ["OK " if ok else "SAI", label, ("  — " + detail) if detail else ""])


func _ready() -> void:
	print("=== Tuần 3 · file lưu ===")
	SaveStore.use_test_path(TEST_PATH)
	SaveStore.set_enabled(true)
	SaveStore.erase()

	_round_trip()
	_corrupt_file()
	_backup_rescue()
	_mid_page()
	_app_backgrounded()

	SaveStore.erase()
	print("")
	print("=== %s ===" % ("ĐẠT" if _fails == 0 else "TRƯỢT (%d lỗi)" % _fails))
	get_tree().quit()


func _round_trip() -> void:
	print("① Ghi rồi đọc lại")
	_reset_memory_only()
	GameState.max_page_reached = 7
	GameState.stars = 42
	GameState.set_page(6)
	_check("ghi được ra đĩa", SaveStore.save())
	_check("file có thật", FileAccess.file_exists(TEST_PATH))

	_reset_memory_only()
	_check("đã xoá sạch trong bộ nhớ", GameState.stars == 0 and GameState.page_index == 0)

	_check("đọc lại được", SaveStore.load_into_game_state())
	_check("trang khớp", GameState.page_index == 6, "trang %d" % GameState.page_index)
	_check("trang xa nhất khớp", GameState.max_page_reached == 7,
		"max %d" % GameState.max_page_reached)
	_check("hạt sao khớp", GameState.stars == 42, "%d sao" % GameState.stars)
	_check("chương mở lại đúng",
		GameState.chapter_unlocked(1) and not GameState.chapter_unlocked(2))


func _corrupt_file() -> void:
	print("")
	print("② File rác thì KHÔNG được sập")
	SaveStore.erase()
	var f := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	f.store_string("  không phải cfg [[[ = = =\nÿþ")
	f.close()

	_reset_memory_only()
	var loaded := SaveStore.load_into_game_state()
	_check("báo là không đọc được", not loaded)
	_check("chạy tiếp với giá trị mặc định",
		GameState.page_index == 0 and GameState.stars == 0)

	# Kiểu sai ở đúng chỗ đáng lẽ phải là số — ConfigFile đọc trót lọt, chỉ có
	# lớp kiểm kiểu trong SaveStore mới chặn được.
	SaveStore.erase()
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "version", SaveStore.VERSION)
	cfg.set_value("progress", "page_index", "chín")
	cfg.set_value("progress", "stars", [1, 2, 3])
	cfg.set_value("progress", "max_page_reached", 999)
	cfg.save(TEST_PATH)

	_reset_memory_only()
	_check("file sai kiểu vẫn nạp được", SaveStore.load_into_game_state())
	_check("trang sai kiểu về mặc định", GameState.page_index == 0,
		"trang %d" % GameState.page_index)
	_check("sao sai kiểu về mặc định", GameState.stars == 0, "%d sao" % GameState.stars)
	_check("số vượt khoảng bị kẹp lại",
		GameState.max_page_reached == Chapters.total_pages() - 1,
		"max %d" % GameState.max_page_reached)


func _backup_rescue() -> void:
	print("")
	print("③ Bản .bak cứu được file chính hỏng")
	SaveStore.erase()
	_reset_memory_only()
	GameState.max_page_reached = 9
	GameState.stars = 11
	GameState.set_page(9)
	SaveStore.save()
	# Lần ghi thứ hai mới chụp .bak từ nội dung của lần thứ nhất.
	SaveStore.save()
	_check("có bản .bak", FileAccess.file_exists(TEST_PATH + SaveStore.BACKUP_SUFFIX))

	var f := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	f.store_string("[[[ hỏng giữa chừng")
	f.close()

	_reset_memory_only()
	_check("vẫn nạp được từ .bak", SaveStore.load_into_game_state())
	_check("tiến độ còn nguyên", GameState.page_index == 9 and GameState.stars == 11,
		"trang %d, %d sao" % [GameState.page_index, GameState.stars])


func _mid_page() -> void:
	print("")
	print("④ KHÔNG lưu tiến độ giữa trang (quyết định có chủ ý)")
	SaveStore.erase()
	_reset_memory_only()
	GameState.set_page(3)
	# Bé đang đánh dở nốt thứ 3 của chuỗi: sao đã cộng, trang thì chưa xong.
	GameState.award_star()
	GameState.award_star()
	GameState.award_star()
	SaveStore.save()

	_reset_memory_only()
	SaveStore.load_into_game_state()
	_check("mở lại vào ĐẦU trang đang chơi", GameState.page_index == 3,
		"trang %d" % GameState.page_index)
	_check("hạt sao đã ăn thì vẫn giữ", GameState.stars == 3, "%d sao" % GameState.stars)
	_check("không có trường nào ghi bước giữa chuỗi", not _has_key("step"))


func _has_key(key: String) -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(TEST_PATH) != OK:
		return false
	for section in cfg.get_sections():
		if cfg.has_section_key(section, key):
			return true
	return false


## Đường sống còn trên iOS. Hệ điều hành giết app nền rất thẳng tay và
## NOTIFICATION_WM_CLOSE_REQUEST không đáng tin — nếu nhánh này hỏng thì bé vuốt
## app đi là mất trang vừa chơi, mà không có gì báo cho ai biết.
func _app_backgrounded() -> void:
	print("")
	print("⑤ App xuống nền thì phải ghi NGAY")

	# Dựng trạng thái mà không để page_changed ghi hộ, rồi xoá sạch dấu vết:
	# có thế mới biết file sinh ra là do notification chứ không do gì khác.
	SaveStore.set_enabled(false)
	GameState.reset_all()
	GameState.max_page_reached = 4
	GameState.stars = 6
	GameState.set_page(4)
	SaveStore.set_enabled(true)
	SaveStore.erase()
	_check("chưa có file trước khi xuống nền", not FileAccess.file_exists(TEST_PATH))

	SaveStore.notification(NOTIFICATION_APPLICATION_PAUSED)
	_check("xuống nền là ghi ngay", FileAccess.file_exists(TEST_PATH))

	_reset_memory_only()
	SaveStore.load_into_game_state()
	_check("ghi đúng thứ đang chơi dở", GameState.page_index == 4 and GameState.stars == 6,
		"trang %d, %d sao" % [GameState.page_index, GameState.stars])
