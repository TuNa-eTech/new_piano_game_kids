extends Node
## Automated test for the 10-page Interactive Living Storybook.
##
## Run: /Applications/Godot.app/Contents/MacOS/Godot --headless --path . res://game/dev/test_storybook_10_pages.tscn

const StoryBook = preload("res://game/diorama/story_book.gd")
const WizardLeo = preload("res://game/diorama/wizard_leo.gd")
const PetCompanion = preload("res://game/diorama/pet_companion.gd")
const MusicalBeanstalk = preload("res://game/diorama/musical_beanstalk.gd")
const DioramaStage = preload("res://game/diorama/diorama_stage.gd")

var _fails: int = 0


func _check(label: String, ok: bool, detail: String = "") -> void:
	if not ok:
		_fails += 1
	print("  [%s] %s%s" % ["OK " if ok else "SAI", label, ("  — " + detail) if detail else ""])


func _ready() -> void:
	print("=== KIỂM THỬ QUYỂN SÁCH TRANH SỐNG ĐỘNG 10 BÀI HÁT (STORYBOOK) ===\n")

	await _test_storybook_initialization()
	await _test_all_10_song_pages()
	await _test_interactive_notes_and_celebration()
	await _test_page_navigation()
	await _test_diorama_integration()

	print("\n=== %s ===" % ("ĐẠT TOÀN BỘ (STORYBOOK 10 BÀI HÁT)" if _fails == 0 else "TRƯỢT (%d lỗi)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _test_storybook_initialization() -> void:
	print("① Kiểm tra khởi tạo StoryBook")
	var book := StoryBook.new()
	add_child(book)
	book.size = Vector2(880, 416)
	await get_tree().process_frame

	_check("StoryBook khởi tạo thành công", book != null)
	_check("Có Background bìa sách mở", book._book_bg != null and book._book_bg.texture != null)
	_check("Có Trang Trái (LeftPage)", book._left_page != null)
	_check("Có Trang Phải (RightPage)", book._right_page != null)
	_check("Có Bé Phù Thủy Leo", book._wizard_leo != null)
	_check("Có Bạn Thú Cưng đồng hành", book._pet_companion != null)
	_check("Có Cây Đậu Thần Âm Nhạc", book._beanstalk != null)
	_check("Có Nút lật trang Prev/Next", book._btn_prev != null and book._btn_next != null)

	book.queue_free()


func _test_all_10_song_pages() -> void:
	print("\n② Kiểm tra 10 bài hát và thú cưng từng trang")
	var book := StoryBook.new()
	add_child(book)
	book.size = Vector2(880, 416)
	await get_tree().process_frame

	var total_songs := Songbook.count()
	_check("Songbook có đủ 10 bài hát", total_songs == 10, "Hiện có %d bài" % total_songs)

	for i in total_songs:
		book.load_page(i)
		var song := Songbook.get_song(i)
		var title: String = song.get("vietnamese_title", song.get("title", ""))
		var pet_id: String = song.get("pet_id", "")
		var emoji: String = song.get("pet_emoji", "")

		var title_has_name: bool = title in book._title_label.text
		var bubble_has_intro: bool = not book._speech_label.text.is_empty()
		var pet_loaded: bool = book._pet_companion._texture_rect.texture != null

		_check("Trang %d (%s %s): Banner đúng tiêu đề" % [i + 1, title, emoji], title_has_name)
		_check("Trang %d: Khung thoại có lời dẫn truyện" % [i + 1], bubble_has_intro)
		_check("Trang %d: Thú cưng '%s' có sprite texture" % [i + 1, pet_id], pet_loaded)

	book.queue_free()


func _test_interactive_notes_and_celebration() -> void:
	print("\n③ Kiểm tra hoạt cảnh gõ nốt, cây hát và rương báu")
	var book := StoryBook.new()
	add_child(book)
	book.size = Vector2(880, 416)
	await get_tree().process_frame

	# 1. Gõ nốt C4 (0)
	book.on_note_struck(0)
	_check("Leo chuyển trạng thái CAST khi gõ nốt", book._wizard_leo._current_state == WizardLeo.AnimState.CAST)
	_check("Lá C4 nở hoa (BLOOMED)", book._beanstalk._leaf_states[0] == MusicalBeanstalk.LeafState.BLOOMED)

	# 2. Cây hát nốt E4 (2)
	book.sing_leaf(2)
	_check("Lá E4 chuyển sang trạng thái SINGING", book._beanstalk._leaf_states[2] == MusicalBeanstalk.LeafState.SINGING)

	# 3. Hoàn thành bài hát: Mở rương và ăn mừng
	book.celebrate_completion()
	_check("Leo chuyển trạng thái CELEBRATE", book._wizard_leo._current_state == WizardLeo.AnimState.CELEBRATE)
	_check("Rương báu mở tung phát sáng", book._beanstalk._is_fruiting)
	_check("Khung thoại hiển thị lời chúc mừng", "HOAN HÔ" in book._speech_label.text)

	book.queue_free()


func _test_page_navigation() -> void:
	print("\n④ Kiểm tra điều hướng lật trang")
	var book := StoryBook.new()
	add_child(book)
	book.size = Vector2(880, 416)
	await get_tree().process_frame

	book.load_page(0)
	_check("Trang 1: Nút Prev ẩn", not book._btn_prev.visible)
	_check("Trang 1: Nút Next hiện", book._btn_next.visible)

	book.load_page(9)
	_check("Trang 10: Nút Prev hiện", book._btn_prev.visible)
	_check("Trang 10: Nút Next ẩn", not book._btn_next.visible)

	# Test lật trang
	var pages_received: Array[int] = []
	book.page_turn_requested.connect(func(p): pages_received.append(p))

	# Quyển sách KHÔNG tự đổi trang nữa: hai nút chỉ nêu yêu cầu, còn thứ tự
	# "cuộn giấy trước, đổi dữ liệu sau" do DioramaStage cầm trịch (xem ⑥).
	book.load_page(0)
	book.next_page()
	await get_tree().process_frame
	_check("next_page() xin lật sang trang 1 (bài 2)",
		pages_received.size() == 1 and pages_received[0] == 1,
		"nhận %s" % str(pages_received))
	_check("next_page() KHÔNG tự đổi trang", book._current_page == 0)

	pages_received.clear()
	book.load_page(1)
	book.prev_page()
	await get_tree().process_frame
	_check("prev_page() xin lật về trang 0 (bài 1)",
		pages_received.size() == 1 and pages_received[0] == 0,
		"nhận %s" % str(pages_received))

	pages_received.clear()
	book.load_page(9)
	book.next_page()
	book.load_page(0)
	book.prev_page()
	await get_tree().process_frame
	_check("hết biên thì không xin lật nữa", pages_received.is_empty(),
		"nhận %s" % str(pages_received))

	book.queue_free()


func _test_diorama_integration() -> void:
	print("\n⑤ Kiểm tra tích hợp trong DioramaStage")
	var scene := preload("res://game/diorama/diorama_stage.tscn")
	var diorama: DioramaStage = scene.instantiate()
	add_child(diorama)
	diorama.size = Vector2(1280, 460)
	await get_tree().process_frame

	_check("DioramaStage có StoryBook", diorama._story_book != null)

	# Kiểm tra toạ độ lá nốt nhạc toàn cục
	for i in 7:
		var pos := diorama.get_leaf_global_position(i)
		_check("Lá %d có toạ độ toàn cục hợp lệ (X: 600..1200, Y: 20..440)" % i,
			pos.x > 600.0 and pos.x < 1200.0 and pos.y > 20.0 and pos.y < 440.0,
			"pos = %s" % str(pos))

	# Kiểm tra lật trang từ diorama
	diorama.load_page(3) # Twinkle Twinkle (Owl)
	_check("Diorama load_page(3) thành công", diorama._story_book._current_page == 3)

	await _test_page_curl(diorama)

	diorama.queue_free()


## Hồi quy cho lỗi đã gặp: PageCurl từng là con của BookSpread — node bị ẩn ngay
## trong _setup_story_book() — nên suốt nhiều tháng hoạt ảnh vẫn chạy, tiếng giấy
## vẫn kêu, mà không một khung hình nào được vẽ. Test này canh đúng ba điều mà
## mắt người nhìn thấy: tờ giấy CÓ hiện ra, nó phủ đúng nửa trang đang lật, và
## nội dung chỉ đổi SAU khi giấy đã che kín.
func _test_page_curl(diorama: DioramaStage) -> void:
	print("\n⑥ Kiểm tra hoạt ảnh cuộn trang (PageCurl)")
	var book: StoryBook = diorama._story_book
	var curl: PageCurl = diorama.get_page_curl()
	_check("DioramaStage có PageCurl", curl != null)
	if curl == null:
		return
	_check("PageCurl nằm trong StoryBook, không phải node bị ẩn",
		curl.get_parent() == book and book.is_visible_in_tree())

	diorama.load_page(3)
	GameState.set_page(3)
	await get_tree().process_frame

	# --- Lật tới: cuộn trang PHẢI ---
	diorama.request_page_turn(4, 0.6)
	await get_tree().process_frame
	_check("lật tới: tờ giấy hiện ra", curl.visible)
	_check("lật tới: giấy phủ đúng trang phải",
		is_equal_approx(curl.position.x, book._right_page.position.x)
		and is_equal_approx(curl.size.x, book._right_page.size.x),
		"curl x=%.1f w=%.1f" % [curl.position.x, curl.size.x])
	_check("lật tới: nội dung CHƯA đổi lúc giấy còn phẳng", book._current_page == 3,
		"đang ở trang %d" % book._current_page)

	await curl.sheet_covered
	_check("giấy che kín rồi mới đổi nội dung", book._current_page == 4,
		"đang ở trang %d" % book._current_page)
	_check("đang lật thì khoá hai nút, bé bấm dồn không xếp hàng được",
		book._btn_prev.disabled and book._btn_next.disabled)

	await curl.flip_completed
	await get_tree().process_frame
	_check("lật xong thì giấy biến mất", not curl.visible)
	_check("lật xong thì mở khoá nút", not book._btn_prev.disabled)
	_check("lật xong đứng đúng trang 5", GameState.page_index == 4 and book._current_page == 4,
		"GameState %d · sách %d" % [GameState.page_index, book._current_page])

	# --- Lật lui: cuộn trang TRÁI ---
	diorama.request_page_turn(3, 0.6)
	await get_tree().process_frame
	_check("lật lui: giấy phủ đúng trang trái",
		is_equal_approx(curl.position.x, book._left_page.position.x)
		and is_equal_approx(curl.size.x, book._left_page.size.x),
		"curl x=%.1f w=%.1f" % [curl.position.x, curl.size.x])
	await curl.flip_completed
	await get_tree().process_frame
	_check("lật lui xong đứng đúng trang 4", book._current_page == 3,
		"đang ở trang %d" % book._current_page)

	# --- Đúng thứ bé chạm: HAI NÚT MŨI TÊN ---
	# Hai đoạn test trên gọi thẳng request_page_turn(), nên nếu sợi dây
	# page_turn_requested -> DioramaStage đứt thì chúng vẫn xanh trong khi hai nút
	# trên màn hình bấm không ăn gì. Đây là đúng hình dạng của con bug vừa sửa:
	# hoạt ảnh chạy ngon, chỉ là chẳng ai gọi tới.
	diorama.load_page(3)
	GameState.set_page(3)
	await get_tree().process_frame

	book._btn_next.pressed.emit()
	await get_tree().process_frame
	_check("bấm nút ▶ thì giấy cuộn trang phải thật",
		curl.visible and is_equal_approx(curl.position.x, book._right_page.position.x))
	await curl.flip_completed
	await get_tree().process_frame
	_check("bấm nút ▶ sang đúng bài kế", book._current_page == 4,
		"đang ở trang %d" % book._current_page)

	book._btn_prev.pressed.emit()
	await get_tree().process_frame
	_check("bấm nút ◀ thì giấy cuộn trang trái thật",
		curl.visible and is_equal_approx(curl.position.x, book._left_page.position.x))
	await curl.flip_completed
	await get_tree().process_frame
	_check("bấm nút ◀ về đúng bài trước", book._current_page == 3,
		"đang ở trang %d" % book._current_page)

	# --- Trang cuối KHÔNG đi qua đường này: để CallResponse phát chapter_completed ---
	GameState.set_page(Songbook.count() - 1)
	await get_tree().process_frame
	var page_before: int = GameState.page_index
	diorama.flip_page(0.6)
	await get_tree().process_frame
	_check("trang cuối thì không tự lật, nhường advance_page() lo vòng chương",
		not curl.visible and GameState.page_index == page_before,
		"trang %d" % GameState.page_index)
