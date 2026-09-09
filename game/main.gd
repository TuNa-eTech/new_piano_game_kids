extends Node2D
## Scene gốc.
##
## Tuần 1 dựng bàn phím và audio. Tuần 2 thêm cây thần, vòng gọi–đáp và lọ hạt
## sao. Tuần 3 thêm bản đồ chương, khoá giữ 2 giây ở Menu và Chơi Tự Do — tiêu
## chí thoát của tuần là "một đứa trẻ thật chơi 5 phút không cần người lớn chỉ".
##
## Node này chỉ làm một việc: nối dây. Toàn bộ luật chơi nằm trong CallResponse,
## toàn bộ hiển thị nằm trong MagicTree, StarJar và ChapterProgress.

@onready var _keyboard: PianoKeyboard = $UI/PianoKeyboard
@onready var _tree: MagicTree = $UI/MagicTree
@onready var _call_response: CallResponse = $CallResponse
@onready var _probe: CanvasLayer = $LatencyProbe
@onready var _menu: HoldButton = $HUD/Menu
@onready var _map: ChapterMap = $ChapterMap


func _ready() -> void:
	_probe.bind_keyboard(_keyboard)
	_probe.bind_call_response(_call_response)

	# Node con đã _ready() xong ở thời điểm này, nên trao tham chiếu ở đây là an toàn.
	_call_response.setup(_tree, _keyboard)

	_menu.activated.connect(_on_menu_activated)
	_map.closed.connect(_on_map_closed)


func _on_menu_activated() -> void:
	# Buông ngón TRƯỚC khi dừng cây: sau khi paused, bàn phím không nhận được sự
	# kiện nhả nữa, ngón đang giữ sẽ kẹt và phím kẹt theo ở trạng thái đang nhấn.
	_keyboard.release_all()
	_map.open_map()


func _on_map_closed() -> void:
	# Lúc bản đồ mở, HUD bị dừng nên nút Menu không thấy ngón nhả ra. Không dọn
	# thì lần sau nó tưởng vẫn còn ngón trên màn hình và từ chối nhận lượt giữ mới.
	_menu.cancel()
