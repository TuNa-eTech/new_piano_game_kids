class_name GoodnightScreen
extends PauseOverlay
## Màn Chúc Bé Ngủ Ngon — nghi thức kết thúc giờ chơi nhẹ nhàng, êm ái.
## Thiết kế khớp 100% với mock-goodnight-bedtime.jpeg.
##
## Thẩm mỹ Sách Tranh Nổi 3D:
## - Toàn cảnh khu rừng chìm vào màn đêm êm đềm với đèn lồng bí ngô phát sáng dịu
## - Cuốn sách mở ra cảnh bé Phù Thủy say giấc nồng ôm bạn Sư Tử trên thân cây rêu
## - Cây đậu thần trắng phát ra luồng ánh sáng dịu êm
## - Bàn phím bên dưới ngủ say, dải ánh sáng nốt nhạc ru ngủ
## - Bảng gỗ trên cùng: 'Khu rừng đã ngủ say rồi. Chúc bé ngủ ngon! 🌙✨'
## - Nút 'Đánh Thức Khu Rừng' (Mở khóa qua Cổng Phụ Huynh)

signal parental_unlock_requested

var _bg_texture: Texture2D
var _unlock_btn: Button
var _back_btn: Button
var _lullaby_player: AudioStreamPlayer


func _ready() -> void:
	super()
	layer = 18
	_build()
	_set_controls_visible(false)


func _build() -> void:
	_add_backdrop(Color(0.01, 0.02, 0.04, 0.96))

	# Phông nền toàn cảnh Chúc Bé Ngủ Ngon từ mock-goodnight-bedtime.jpeg
	if ResourceLoader.exists("res://docs/mock-goodnight-bedtime.jpeg"):
		_bg_texture = load("res://docs/mock-goodnight-bedtime.jpeg")

	var bg_rect := TextureRect.new()
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _bg_texture != null:
		bg_rect.texture = _bg_texture
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(bg_rect)

	# Hiệu ứng đom đóm bay chậm chạp êm dịu ban đêm
	var fireflies := NightFireflyOverlay.new()
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fireflies)

	var empty_style := StyleBoxEmpty.new()

	# --- 1. NÚT QUAY LẠI / MỞ KHÓA GÓC TRÊN TRÁI ---
	# Tọa độ tương đối: X ~ 1.8% - 9.8%, Y ~ 3.5% - 17.5%
	_back_btn = Button.new()
	_back_btn.anchor_left = 0.018
	_back_btn.anchor_top = 0.035
	_back_btn.anchor_right = 0.098
	_back_btn.anchor_bottom = 0.175
	_back_btn.focus_mode = Control.FOCUS_NONE
	_back_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_back_btn.flat = true
	_back_btn.add_theme_stylebox_override("normal", empty_style)
	_back_btn.add_theme_stylebox_override("hover", empty_style)
	_back_btn.add_theme_stylebox_override("pressed", empty_style)
	_back_btn.pressed.connect(_on_unlock_pressed)
	add_child(_back_btn)

	# --- 2. NÚT ĐÁNH THỨC DÀNH CHO BỐ MẸ (BẢNG GỖ TRÊN CÙNG HOẶC ĐÁY) ---
	_unlock_btn = Button.new()
	_unlock_btn.anchor_left = 0.35
	_unlock_btn.anchor_top = 0.88
	_unlock_btn.anchor_right = 0.65
	_unlock_btn.anchor_bottom = 0.96
	_unlock_btn.text = "🌙 Đánh Thức Khu Rừng (Dành Cho Bố Mẹ)"
	_unlock_btn.focus_mode = Control.FOCUS_NONE
	_unlock_btn.mouse_filter = Control.MOUSE_FILTER_STOP

	var unlock_style := StyleBoxFlat.new()
	unlock_style.bg_color = Color(0.12, 0.18, 0.28, 0.92)
	unlock_style.border_color = Color(0.85, 0.75, 0.42, 0.8)
	unlock_style.set_border_width_all(2)
	unlock_style.set_corner_radius_all(18)
	_unlock_btn.add_theme_stylebox_override("normal", unlock_style)
	_unlock_btn.add_theme_stylebox_override("hover", unlock_style)
	_unlock_btn.add_theme_stylebox_override("pressed", unlock_style)
	_unlock_btn.add_theme_font_size_override("font_size", 14)
	_unlock_btn.add_theme_color_override("font_color", Color(0.95, 0.92, 0.82))
	_unlock_btn.pressed.connect(_on_unlock_pressed)
	add_child(_unlock_btn)

	# Âm thanh nhạc ru ngủ
	_lullaby_player = AudioStreamPlayer.new()
	_lullaby_player.bus = "Master"
	add_child(_lullaby_player)


func open_overlay() -> void:
	super.open_overlay()
	_play_lullaby()


func close_overlay() -> void:
	if _lullaby_player != null and _lullaby_player.playing:
		_lullaby_player.stop()
	super.close_overlay()


func _on_unlock_pressed() -> void:
	AudioDirector.play_sfx("wood_tap")
	parental_unlock_requested.emit()


func _play_lullaby() -> void:
	if ResourceLoader.exists("res://assets/audio/sfx/lullaby_loop.wav"):
		_lullaby_player.stream = load("res://assets/audio/sfx/lullaby_loop.wav")
		_lullaby_player.play()


## Hạt đom đóm đêm bay chậm êm ái
class NightFireflyOverlay extends Control:
	var _fireflies: Array[Dictionary] = []
	var _time: float = 0.0

	func _ready() -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = 99
		for i in 14:
			_fireflies.append({
				"pos": Vector2(rng.randf_range(0.08, 0.92), rng.randf_range(0.12, 0.85)),
				"speed": rng.randf_range(0.3, 0.8),
				"phase": rng.randf_range(0, TAU),
				"radius": rng.randf_range(2.0, 4.0),
			})

	func _process(delta: float) -> void:
		_time += delta
		queue_redraw()

	func _draw() -> void:
		var sz := size
		for ff in _fireflies:
			var sway_x := sin(_time * ff["speed"] + ff["phase"]) * 18.0
			var sway_y := cos(_time * ff["speed"] * 0.7 + ff["phase"]) * 12.0
			var p := Vector2(ff["pos"].x * sz.x + sway_x, ff["pos"].y * sz.y + sway_y)
			var a := 0.25 + 0.25 * sin(_time * ff["speed"] * 1.5 + ff["phase"])
			draw_circle(p, ff["radius"], Color(1.0, 0.95, 0.55, a))
			draw_circle(p, ff["radius"] * 2.5, Color(1.0, 0.85, 0.25, a * 0.3))
