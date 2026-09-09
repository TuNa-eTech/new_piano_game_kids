class_name StarJar
extends Control
## Lọ hạt sao — thay cho SCORE/COMBO của ảnh mock (Quyết định 04).
##
## "Giữ đúng vị trí góc phải trên của mock, nhưng thay bằng một chiếc lọ thủy
## tinh đầy dần. Mỗi nốt đúng = một hạt sao bay vào lọ, có tiếng ting."
## Con số vẫn hiện nhỏ và mờ bên dưới lọ — dành cho phụ huynh nhìn qua vai,
## không dành cho bé. Trẻ 4 tuổi đọc mực nước, không đọc chữ số.

## Số hạt để đầy một lọ. Lọ đầy = mở một con vật mới (tính năng của Tuần 3).
const JAR_CAPACITY := 12

var _fill: float = 0.0        ## mức hiển thị, chạy đuổi theo _target
var _target: float = 0.0
var _flash: float = 0.0

@onready var _label: Label = $Count


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _label:
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameState.stars_changed.connect(_on_stars_changed)
	_on_stars_changed(GameState.stars)


func _process(delta: float) -> void:
	var moved := absf(_target - _fill) > 0.001
	if moved:
		_fill = move_toward(_fill, _target, delta * 0.9)
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta * 2.2)
	if moved or _flash > 0.0:
		queue_redraw()


func _on_stars_changed(total: int) -> void:
	_target = float(total % JAR_CAPACITY) / float(JAR_CAPACITY)
	if total > 0 and total % JAR_CAPACITY == 0:
		_target = 1.0
	_flash = 1.0
	if _label:
		_label.text = str(total)
	queue_redraw()


func _draw() -> void:
	var glass := Color(1, 1, 1, 0.16 + 0.20 * _flash)
	var body := Rect2(Vector2.ZERO, Vector2(size.x, size.y * 0.82))

	# Mực sao dâng từ đáy lọ lên.
	var fh := body.size.y * _fill
	if fh > 1.0:
		draw_rect(
			Rect2(body.position.x, body.position.y + body.size.y - fh, body.size.x, fh),
			Color("#F2C64B").lerp(Color.WHITE, 0.25 * _flash)
		)

	# Thành lọ vẽ sau cùng để viền nằm trên mực sao.
	draw_rect(body, glass, false, 2.0)
	draw_rect(
		Rect2(body.position.x + body.size.x * 0.22, -size.y * 0.06,
			body.size.x * 0.56, size.y * 0.06),
		glass, false, 2.0
	)
