extends Node
## GameState — autoload. Ở Tuần 1 đây mới chỉ là cái vỏ.
##
## Tài liệu đặt lúc ghi save là "sau mỗi trang" (docs/gameplay-design.html ·
## Lưu trữ), mà trang truyện thuộc Tuần 2. Nên lần này chỉ giữ đúng thứ bàn
## phím cần và để sẵn chỗ cho phần còn lại.
##
## Ranh giới cứng — KHÔNG được vượt (Động cơ lan truyền · ranh giới COPPA/GDPR-K):
## không tài khoản, không đăng nhập, không bảng xếp hạng, không thu thập dữ liệu
## nào rời khỏi máy. Tên bé lưu cục bộ trong user://.

signal free_play_changed(enabled: bool)

## Tuần 1 chỉ có Chơi Tự Do — không gợi ý, không chuỗi, chỉ đàn.
## Đây là chế độ tài liệu nói trẻ ở lại lâu nhất và phụ huynh quay video nhiều nhất.
var free_play: bool = true:
	set(value):
		if free_play == value:
			return
		free_play = value
		free_play_changed.emit(value)

## Tổng số nốt bé đã bấm trong phiên này. Chỉ để hiện trên overlay chẩn đoán,
## KHÔNG phải điểm số — tài liệu đã bỏ SCORE/COMBO ở Quyết định 04.
var notes_played_this_session: int = 0


func _ready() -> void:
	# Đứng ngoài pause để còn phản ứng khi app xuống nền.
	process_mode = Node.PROCESS_MODE_ALWAYS


func note_was_played(_index: int) -> void:
	notes_played_this_session += 1
