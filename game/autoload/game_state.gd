extends Node
## GameState — autoload. Trạng thái ván chơi.
##
## Ranh giới cứng — KHÔNG được vượt (docs/gameplay-design.html · Động cơ lan
## truyền, ranh giới COPPA/GDPR-K): không tài khoản, không đăng nhập, không
## bảng xếp hạng, không thu thập dữ liệu nào rời khỏi máy. Tên bé lưu cục bộ
## trong user://. Đừng để ai ở sprint sau thiết kế nhầm một mạng xã hội vào đây.

signal page_changed(page_index: int)
signal stars_changed(total: int)

## Chơi Tự Do: không gợi ý, không chuỗi — chỉ đàn, con vật và cây mọc theo mỗi
## nốt. Tài liệu nói đây là chế độ trẻ ở lại lâu nhất và phụ huynh quay video
## nhiều nhất, nên nó phải có ở v1.
var free_play: bool = false:
	set(value):
		if free_play == value:
			return
		free_play = value
		free_play_changed.emit(value)

signal free_play_changed(enabled: bool)

## Trang truyện hiện tại, đếm từ 0. Mỗi trang là một giai điệu.
var page_index: int = 0

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


func advance_page() -> void:
	page_index += 1
	page_changed.emit(page_index)


## Trang thứ mấy trong chương hiện tại, đếm từ 0. Thanh nhạc cụ góc trái dùng
## số này (5 nhạc cụ = 5 trang của chương).
func page_in_chapter() -> int:
	return page_index % Melodies.PAGES_PER_CHAPTER


func chapter_index() -> int:
	return page_index / Melodies.PAGES_PER_CHAPTER
