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

	book.load_page(0)
	book.next_page()
	# Đợi tween hoàn thành
	await get_tree().create_timer(0.45).timeout
	_check("next_page() lật sang trang 1 (bài 2)", book._current_page == 1)

	book.prev_page()
	await get_tree().create_timer(0.45).timeout
	_check("prev_page() lật về trang 0 (bài 1)", book._current_page == 0)

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

	diorama.queue_free()
