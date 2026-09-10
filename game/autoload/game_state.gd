extends Node
## GameState — autoload. Trạng thái ván chơi.
##
## Ranh giới cứng — KHÔNG được vượt (docs/gameplay-design.html · Động cơ lan
## truyền, ranh giới COPPA/GDPR-K): không tài khoản, không đăng nhập, không
## bảng xếp hạng, không thu thập dữ liệu nào rời khỏi máy. Tên bé lưu cục bộ
## trong user://. Đừng để ai ở sprint sau thiết kế nhầm một mạng xã hội vào đây.

signal page_changed(page_index: int)
signal stars_changed(total: int)
signal free_play_changed(enabled: bool)
signal instrument_mode_changed(mode: int)

## Bé vừa đi hết trang cuối của một chương. Phát SAU khi page_index đã nhảy sang
## trang đầu chương mới, để màn kết chương mở ra trên một ván chơi đã dựng xong
## và chỉ đang bị dừng — đóng màn kết là chơi tiếp được ngay.
signal chapter_completed(chapter_index: int)

## Chế độ âm sắc nhạc cụ (Tính Năng 2). 0: AUTO, 1: ANIMALS, 2: FLUTE, 3: KALIMBA, 4: CHIMES
var instrument_mode: int = 0: # Notes.InstrumentMode.AUTO
	set(value):
		if instrument_mode == value:
			return
		instrument_mode = value
		instrument_mode_changed.emit(value)

## Chơi Tự Do: không gợi ý, không chuỗi — chỉ đàn, con vật và cây mọc theo mỗi
## nốt. Tài liệu nói đây là chế độ trẻ ở lại lâu nhất và phụ huynh quay video
## nhiều nhất, nên nó phải có ở v1.
var free_play: bool = false:
	set(value):
		if free_play == value:
			return
		free_play = value
		free_play_changed.emit(value)

## Trang truyện hiện tại, đếm từ 0. Mỗi trang là một giai điệu.
var page_index: int = 0

## Trang xa nhất từng tới. Đây là thứ mở khoá chương trên bản đồ — và nó CHỈ
## tăng, không bao giờ giảm: không có màn thua thì cũng không có đường lùi.
var max_page_reached: int = 0

## Hạt sao — mỗi nốt đúng một hạt. KHÔNG phải điểm số: Quyết định 04 đã bỏ
## SCORE/COMBO vì "trẻ 4 tuổi không đọc được số bốn chữ".
var stars: int = 0

## Tổng số nốt bấm trong phiên. Chỉ để hiện trên overlay chẩn đoán.
var notes_played_this_session: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func note_was_played(_index: int) -> void:
	notes_played_this_session += 1


func award_star() -> void:
	stars += 1
	stars_changed.emit(stars)


## Hết trang cuối của chương cuối thì quay lại trang 1, KHÔNG có màn hình kết.
## Màn kết chương thuộc Tuần 4; ở đây thế giới phải luôn còn chỗ để đi tiếp, vì
## "không có màn hình thua" cũng có nghĩa là không có ngõ cụt. max_page_reached
## đã chạm 14 từ trước nên vòng lại không hề khoá lại chương nào.
func advance_page() -> void:
	var finished := Chapters.of_page(page_index)
	var was_last_page_of_chapter := page_in_chapter() == Melodies.PAGES_PER_CHAPTER - 1
	set_page((page_index + 1) % Chapters.total_pages())
	if was_last_page_of_chapter:
		chapter_completed.emit(finished)


func set_page(index: int) -> void:
	page_index = clampi(index, 0, Chapters.total_pages() - 1)
	max_page_reached = maxi(max_page_reached, page_index)
	page_changed.emit(page_index)


## Bé chọn chương trên bản đồ → nhảy tới trang đầu chương đó.
func select_chapter(chapter: int) -> void:
	set_page(Chapters.first_page_of(chapter))


## Chương 1 luôn mở. Chương N+1 mở khi đã đi hết chương N — tức là lúc
## max_page_reached chạm đúng trang đầu của nó. Khoá ở đây chỉ để bản đồ khỏi
## rối, không phải để thử thách.
func chapter_unlocked(chapter: int) -> bool:
	return max_page_reached >= Chapters.first_page_of(chapter)


## Trang thứ mấy trong chương hiện tại, đếm từ 0. Thanh nhạc cụ góc trái dùng
## số này (5 nhạc cụ = 5 trang của chương).
func page_in_chapter() -> int:
	return page_index % Melodies.PAGES_PER_CHAPTER


func chapter_index() -> int:
	return Chapters.of_page(page_index)


## Nạp từ file lưu. Không phát page_changed nếu không cần — nhưng vẫn phát khi
## trang khác mặc định, để HUD và vòng chơi bắt kịp mà không cần biết ai gọi.
func apply_saved(saved_page: int, saved_max_page: int, saved_stars: int) -> void:
	max_page_reached = clampi(saved_max_page, 0, Chapters.total_pages() - 1)
	stars = maxi(0, saved_stars)
	stars_changed.emit(stars)
	set_page(saved_page)


## Chỉ dùng cho máy đo: đưa mọi thứ về mặc định để phép đo không phụ thuộc vào
## file lưu của lần chạy trước.
func reset_all() -> void:
	free_play = false
	instrument_mode = 0
	page_index = 0
	max_page_reached = 0
	stars = 0
	notes_played_this_session = 0
	stars_changed.emit(stars)
	page_changed.emit(page_index)
