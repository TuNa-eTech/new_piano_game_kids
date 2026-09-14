class_name StarJar
extends Control
## Lọ hạt sao — thay cho SCORE/COMBO của ảnh mock (Quyết định 04).
##
## "Giữ đúng vị trí góc phải trên của mock, nhưng thay bằng một chiếc lọ thủy
## tinh đầy dần. Mỗi nốt đúng = một hạt sao bay vào lọ, có tiếng ting."
## Con số vẫn hiện nhỏ và mờ bên dưới lọ — dành cho phụ huynh nhìn qua vai,
## không dành cho bé. Trẻ 4 tuổi đọc mực nước, không đọc chữ số.

signal jar_interacted

## Số hạt để đầy một lọ. Lọ đầy = mở một con vật mới (tính năng của Tuần 3).
const JAR_CAPACITY := 12

var _fill: float = 0.0        ## mức hiển thị, chạy đuổi theo _target
var _target: float = 0.0
var _flash: float = 0.0
var _wiggle_tween: Tween

var _last_accel: Vector3 = Vector3.ZERO
var _shake_cooldown: float = 0.0

@onready var _label: Label = get_node_or_null("Count")


var _jar_tex: Texture2D
var _star_tex: Texture2D


func _ready() -> void:
	# P2: STOP nuốt chạm + spam ting khi bé tưởng lọ là nút. IGNORE để chạm
	# xuyên qua; wiggle chỉ còn qua lắc máy (accelerometer) và phím S test.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	pivot_offset = Vector2(size.x * 0.5, size.y * 0.85)

	if ResourceLoader.exists("res://assets/art/ui_star_jar.png"):
		_jar_tex = load("res://assets/art/ui_star_jar.png")
	if ResourceLoader.exists("res://assets/art/ui_star.png"):
		_star_tex = load("res://assets/art/ui_star.png")

	if _label:
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Fix UI 7 nhóm: số sao cho phụ huynh nhìn qua vai — trước đây alpha 0.45
		# chìm vào nền rừng. Tăng tương phản nhưng vẫn nhỏ, không tranh vai trò
		# "đọc mực nước" của bé.
		_label.add_theme_font_size_override("font_size", 20)
		_label.add_theme_color_override("font_color", Color("#FFF8E7"))
		_label.add_theme_color_override("font_outline_color", Color("#3D2211"))
		_label.add_theme_constant_override("outline_size", 6)
	GameState.stars_changed.connect(_on_stars_changed)
	_on_stars_changed(GameState.stars)


func _gui_input(event: InputEvent) -> void:
	# P2: lọ IGNORE nên không còn nhận gui_input; giữ hàm rỗng để không
	# vô tình nối lại. Wiggle qua _unhandled_input (phím S) và accelerometer.
	pass


func _unhandled_input(event: InputEvent) -> void:
	# Phím S thử nghiệm rung lắc lọ sao trên máy tính Desktop
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_S:
			wiggle()


func _process(delta: float) -> void:
	var moved := absf(_target - _fill) > 0.001
	if moved:
		_fill = move_toward(_fill, _target, delta * 0.9)
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta * 2.2)
	if moved or _flash > 0.0:
		queue_redraw()

	# Cảm ứng gia tốc rung lắc thiết bị (Device Shake / Accelerometer)
	var accel := Input.get_accelerometer()
	if _last_accel != Vector3.ZERO:
		var diff := (accel - _last_accel).length()
		if diff > 12.0 and _shake_cooldown <= 0.0:
			wiggle()
			_shake_cooldown = 0.45
	_last_accel = accel
	if _shake_cooldown > 0.0:
		_shake_cooldown -= delta


## Lọ hạt sao lắc lư vui tai khi bé chạm hoặc lắc máy
func wiggle() -> void:
	if _wiggle_tween != null and _wiggle_tween.is_valid():
		_wiggle_tween.kill()

	_wiggle_tween = create_tween().bind_node(self)
	_wiggle_tween.tween_property(self, "rotation", 0.16, 0.07).set_trans(Tween.TRANS_SINE)
	_wiggle_tween.parallel().tween_property(self, "scale", Vector2(1.14, 0.88), 0.07).set_trans(Tween.TRANS_QUAD)
	_wiggle_tween.tween_property(self, "rotation", -0.14, 0.09).set_trans(Tween.TRANS_SINE)
	_wiggle_tween.parallel().tween_property(self, "scale", Vector2(0.94, 1.10), 0.09).set_trans(Tween.TRANS_QUAD)
	_wiggle_tween.tween_property(self, "rotation", 0.08, 0.08).set_trans(Tween.TRANS_SINE)
	_wiggle_tween.tween_property(self, "rotation", 0.0, 0.10).set_trans(Tween.TRANS_BOUNCE)
	_wiggle_tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.10)

	_flash = 1.0
	AudioDirector.play_ting()
	jar_interacted.emit()


func _on_stars_changed(total: int) -> void:
	var was_full := total > 0 and total % JAR_CAPACITY == 0
	_target = float(total % JAR_CAPACITY) / float(JAR_CAPACITY)
	if was_full:
		_target = 1.0
	_flash = 1.0
	if _label:
		_label.text = str(total)
	# P2: đầy lọ ăn mừng tại chỗ (nảy + fanfare) rồi mới rót về 0 ở sao
	# tiếp theo — bé không còn tưởng "mất sao".
	if was_full:
		wiggle()
		var audio := get_node_or_null("/root/AudioDirector")
		if audio != null and audio.has_method("play_sfx"):
			audio.play_sfx("fairy_dust")
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

	# P2: 12 vạch chia để bé/phụ huynh thấy "sắp đầy" — 1 vạch = 1 hạt.
	var tick_top := body.position.y + body.size.y * 0.13
	var tick_bottom := body.position.y + body.size.y * 0.85
	for i in range(1, JAR_CAPACITY):
		var tx := body.position.x + body.size.x * (0.14 + 0.72 * float(i) / float(JAR_CAPACITY))
		draw_line(Vector2(tx, tick_top), Vector2(tx, tick_bottom), Color(1, 1, 1, 0.30), 1.0)

	# Khi có sao mới (flash > 0), vẽ hạt sao nhỏ phát sáng
	if _flash > 0.0 and _star_tex != null:
		var star_s := 24.0 * (1.0 + 0.3 * _flash)
		var star_r := Rect2(body.size.x * 0.72, -star_s * 0.4, star_s, star_s)
		draw_texture_rect(_star_tex, star_r, false, Color(1, 1, 1, _flash))

