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


var _jar_tex: Texture2D
var _star_tex: Texture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/ui_star_jar.png"):
		_jar_tex = load("res://assets/art/ui_star_jar.png")
	if ResourceLoader.exists("res://assets/art/ui_star.png"):
		_star_tex = load("res://assets/art/ui_star.png")

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
	var body := Rect2(Vector2.ZERO, Vector2(size.x, size.y * 0.85))

	# Drop shadow beneath glass jar
	draw_circle(Vector2(body.size.x * 0.5, body.size.y * 0.92), body.size.x * 0.38, Color(0, 0, 0, 0.28))

	# Mực sao dâng từ đáy lọ lên
	var fh := body.size.y * 0.72 * _fill
	if fh > 1.0:
		var fill_rect := Rect2(body.position.x + body.size.x * 0.14, body.position.y + body.size.y * 0.85 - fh, body.size.x * 0.72, fh)
		draw_rect(
			fill_rect,
			Color("#F2C64B").lerp(Color.WHITE, 0.35 * _flash)
		)

	if _jar_tex != null:
		draw_texture_rect(_jar_tex, body, false, Color(1, 1, 1, 0.95))
	else:
		var glass := Color(1, 1, 1, 0.22 + 0.20 * _flash)
		draw_rect(body, glass, false, 2.0)
		draw_rect(
			Rect2(body.position.x + body.size.x * 0.22, -size.y * 0.08,
				body.size.x * 0.56, size.y * 0.08),
			Color("#A67C52"), true
		)

	# Khi có sao mới (flash > 0), vẽ hạt sao nhỏ phát sáng
	if _flash > 0.0 and _star_tex != null:
		var star_s := 24.0 * (1.0 + 0.3 * _flash)
		var star_r := Rect2(body.size.x * 0.72, -star_s * 0.4, star_s, star_s)
		draw_texture_rect(_star_tex, star_r, false, Color(1, 1, 1, _flash))

