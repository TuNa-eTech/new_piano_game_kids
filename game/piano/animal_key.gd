class_name AnimalKey
extends Control
## Một phím đàn có mặt con vật. NODE THUẦN HIỂN THỊ — không nhận input.
##
## Toàn bộ việc bắt chạm do PianoKeyboard làm (một chỗ duy nhất, hit-test 7 ô
## chữ nhật). Tách như vậy để Tuần 2 nối lá trên cây thần vào cùng tín hiệu mà
## không phải đụng lại đường input.
##
## Ở Tuần 1 thân phím là ColorRect + Label. Bước 2 thay bằng AnimatedSprite2D
## với 3 khung hình mỗi con vật.

const SQUASH := Vector2(1.06, 0.88)
const SQUASH_TIME := 0.055
const RECOVER_TIME := 0.42
const HELD_BRIGHTNESS := 1.22

var index: int = -1

var _tween: Tween

@onready var _body: ColorRect = $Body
@onready var _label: Label = $Label


func setup(key_index: int) -> void:
	index = key_index
	_body.color = Notes.color_of(key_index)
	_label.text = "%s\n%s" % [Notes.animal_of(key_index), Notes.note_of(key_index)]
	# Không có node con nào được nuốt sự kiện chạm — xem Quyết định 01:
	# khung truyện và phím chỉ có MỘT bề mặt tương tác, do PianoKeyboard giữ.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE


## Phản hồi hình ảnh phải nổ ra ở khung hình NGAY SAU sự kiện chạm — tài liệu
## cho phép nó đi trước cả âm thanh nếu cần.
func press() -> void:
	pivot_offset = size * 0.5

	# Tween riêng cho từng phím, KHÔNG dùng một _active_tween dùng chung:
	# dùng chung thì bấm phím 7 sẽ giết mất cú nảy của phím 3.
	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween().bind_node(self)
	_tween.tween_property(self, "scale", SQUASH, SQUASH_TIME) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2.ONE, RECOVER_TIME) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	_body.color = Notes.color_of(index) * HELD_BRIGHTNESS


func release() -> void:
	# Không có trạng thái "sai", nên nhả phím cũng không phạt gì —
	# chỉ trả lại màu. Cú nảy tự chạy nốt phần còn lại.
	_body.color = Notes.color_of(index)
