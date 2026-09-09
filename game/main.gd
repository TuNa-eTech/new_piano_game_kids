extends Node2D
## Scene gốc của Tuần 1.
##
## Mới chỉ có bàn phím + overlay chẩn đoán. StoryPanel là ô giữ chỗ để chứng minh
## đúng một điều: nó KHÔNG nuốt sự kiện chạm (Quyết định 01 — khung truyện chỉ
## hiển thị). Cây thần, lá, lọ hạt sao, vòng gọi–đáp thuộc Tuần 2.

@onready var _keyboard: PianoKeyboard = $UI/PianoKeyboard
@onready var _probe: CanvasLayer = $LatencyProbe


func _ready() -> void:
	_probe.bind_keyboard(_keyboard)
	_keyboard.note_played.connect(_on_note_played)


func _on_note_played(_index: int) -> void:
	# Điểm nối cho Tuần 2: chỗ này là nơi lá trên cây thần sẽ bung ra.
	#
	# Giữ TRỐNG có chủ đích. Không đặt print() ở đây: hàm này nằm trong đường
	# nóng của mỗi cú chạm, mà print kèm định dạng chuỗi là một lần cấp phát —
	# đúng thứ tài liệu cấm. Muốn xem nốt nào đang kêu thì bật overlay F3.
	pass
