extends Node2D
## Scene gốc.
##
## Tuần 1 dựng bàn phím và audio. Tuần 2 thêm cây thần, vòng gọi–đáp và lọ hạt
## sao — tiêu chí thoát của tuần là "chơi trọn một trang truyện từ đầu đến lúc
## cây trổ quả".
##
## Node này chỉ làm một việc: nối dây. Toàn bộ luật chơi nằm trong CallResponse,
## toàn bộ hiển thị nằm trong MagicTree và StarJar.

@onready var _keyboard: PianoKeyboard = $UI/PianoKeyboard
@onready var _tree: MagicTree = $UI/MagicTree
@onready var _call_response: CallResponse = $CallResponse
@onready var _probe: CanvasLayer = $LatencyProbe
@onready var _page_label: Label = $HUD/PageLabel


func _ready() -> void:
	_probe.bind_keyboard(_keyboard)
	_probe.bind_call_response(_call_response)

	# Node con đã _ready() xong ở thời điểm này, nên trao tham chiếu ở đây là an toàn.
	_call_response.setup(_tree, _keyboard)

	GameState.page_changed.connect(_on_page_changed)
	_on_page_changed(GameState.page_index)


func _on_page_changed(_page_index: int) -> void:
	# Thanh nhạc cụ góc trái của ảnh mock = tiến độ chương: 5 trang một chương.
	_page_label.text = "Chương %d · trang %d/%d" % [
		GameState.chapter_index() + 1,
		GameState.page_in_chapter() + 1,
		Melodies.PAGES_PER_CHAPTER,
	]
