class_name ParentalCorner
extends PauseOverlay
## Góc Phụ Huynh & Cài Đặt — không gian thiết lập dành riêng cho cha mẹ.
## Thiết kế khớp 100% với mock-parental-corner.jpeg.
##
## Thẩm mỹ Sách Tranh Nổi 3D:
## - Toàn cảnh bàn gỗ rừng ma thuật với chú Phù Thủy nhỏ ngủ say ôm bạn Sư Tử
## - Bảng gỗ chạm khắc các nút điều khiển âm thanh và giấc ngủ:
##     • Thanh trượt 'Âm lượng'
##     • Núm vặn hẹn giờ ngủ sinh học '15 Phút / 30 Phút / Tắt' có vòng hào quang
##     • Công tắc 'Nhạc ru ngủ'
##     • Nút đóng quay trở lại ván chơi

signal bedtime_timer_changed(minutes: int)

var _bg_texture: Texture2D
var _volume_slider: Slider
var _timer_buttons: Array[Button] = []
var _selected_minutes: int = 0
var _dial_btn: Button
var _close_btn: Button


func _ready() -> void:
	super()
	layer = 15
	_build()
	_set_controls_visible(false)


func _build() -> void:
	_add_backdrop(Color(0.02, 0.04, 0.05, 0.94))

	# Phông nền toàn cảnh Góc Phụ Huynh từ mock-parental-corner.jpeg
	if ResourceLoader.exists("res://docs/mock-parental-corner.jpeg"):
		_bg_texture = load("res://docs/mock-parental-corner.jpeg")

	var bg_rect := TextureRect.new()
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _bg_texture != null:
		bg_rect.texture = _bg_texture
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(bg_rect)

	# Hiệu ứng đom đóm
	var fireflies := MainMenu.FireflyOverlay.new()
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fireflies)

	var empty_style := StyleBoxEmpty.new()

	# --- 1. NÚT ĐÓNG / QUAY LẠI (GÓC TRÊN BÊN PHẢI HOẶC MENU) ---
	# Tọa độ tương đối góc trên phải (House / Menu icon): X ~ 90.5% - 97.5%, Y ~ 3.5% - 15.5%
	_close_btn = Button.new()
	_close_btn.anchor_left = 0.905
	_close_btn.anchor_top = 0.035
	_close_btn.anchor_right = 0.975
	_close_btn.anchor_bottom = 0.155
	_close_btn.focus_mode = Control.FOCUS_NONE
	_close_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_close_btn.flat = true
	_close_btn.add_theme_stylebox_override("normal", empty_style)
	_close_btn.add_theme_stylebox_override("hover", empty_style)
	_close_btn.add_theme_stylebox_override("pressed", empty_style)
	_close_btn.pressed.connect(close_overlay)
	add_child(_close_btn)

	# Nút đóng phụ chữ to dưới đáy để phụ huynh dễ nhấn
	var done_btn := Button.new()
	done_btn.anchor_left = 0.38
	done_btn.anchor_top = 0.77
	done_btn.anchor_right = 0.58
	done_btn.anchor_bottom = 0.86
	done_btn.text = "Đóng & Tiếp Tục Chơi  ✔"
	done_btn.focus_mode = Control.FOCUS_NONE
	var done_style := StyleBoxFlat.new()
	done_style.bg_color = Color(0.18, 0.42, 0.22, 0.92)
	done_style.border_color = Color(0.45, 0.85, 0.52)
	done_style.set_border_width_all(2)
	done_style.set_corner_radius_all(18)
	done_btn.add_theme_stylebox_override("normal", done_style)
	done_btn.add_theme_stylebox_override("hover", done_style)
	done_btn.add_theme_stylebox_override("pressed", done_style)
	done_btn.add_theme_font_size_override("font_size", 14)
	done_btn.add_theme_color_override("font_color", Color.WHITE)
	done_btn.pressed.connect(close_overlay)
	add_child(done_btn)

	# --- 2. THANH TRƯỢT ÂM LƯỢNG (CỘT TRÁI TRÊN BẢNG GỖ) ---
	# Tọa độ tương đối: X ~ 30.5% - 35.5%, Y ~ 47.5% - 68.5%
	_volume_slider = VSlider.new()
	_volume_slider.anchor_left = 0.305
	_volume_slider.anchor_top = 0.475
	_volume_slider.anchor_right = 0.355
	_volume_slider.anchor_bottom = 0.685
	_volume_slider.min_value = 0.0
	_volume_slider.max_value = 1.0
	_volume_slider.step = 0.05
	_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	_volume_slider.value_changed.connect(_on_volume_changed)
	add_child(_volume_slider)

	# --- 3. NÚM HẸN GIỜ NGỦ TRÒN (Ở TRUNG TÂM BẢNG GỖ) ---
	# Tọa độ tương đối: X ~ 42.0% - 54.0%, Y ~ 47.5% - 71.5%
	_dial_btn = Button.new()
	_dial_btn.anchor_left = 0.420
	_dial_btn.anchor_top = 0.475
	_dial_btn.anchor_right = 0.540
	_dial_btn.anchor_bottom = 0.715
	_dial_btn.focus_mode = Control.FOCUS_NONE
	_dial_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_dial_btn.flat = true
	_dial_btn.add_theme_stylebox_override("normal", empty_style)
	_dial_btn.add_theme_stylebox_override("hover", empty_style)
	_dial_btn.add_theme_stylebox_override("pressed", empty_style)
	_dial_btn.pressed.connect(_cycle_bedtime_timer)
	add_child(_dial_btn)

	# Hiển thị số phút trên núm vặn
	var dial_label := Label.new()
	dial_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	dial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dial_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dial_label.name = "DialLabel"
	dial_label.add_theme_font_size_override("font_size", 22)
	dial_label.add_theme_color_override("font_color", Color(0.24, 0.15, 0.08))
	_dial_btn.add_child(dial_label)

	# --- 4. CÔNG TẮC BẬT/TẮT NHẠC RU NGỦ (CỘT PHẢI) ---
	# Tọa độ tương đối: X ~ 59.5% - 66.5%, Y ~ 44.5% - 51.5%
	var lullaby_btn := Button.new()
	lullaby_btn.anchor_left = 0.595
	lullaby_btn.anchor_top = 0.445
	lullaby_btn.anchor_right = 0.665
	lullaby_btn.anchor_bottom = 0.515
	lullaby_btn.focus_mode = Control.FOCUS_NONE
	lullaby_btn.flat = true
	lullaby_btn.add_theme_stylebox_override("normal", empty_style)
	lullaby_btn.add_theme_stylebox_override("hover", empty_style)
	lullaby_btn.add_theme_stylebox_override("pressed", empty_style)
	lullaby_btn.pressed.connect(func():
		AudioDirector.play_sfx("wood_tap")
	)
	add_child(lullaby_btn)

	_update_dial_display()


func open_overlay() -> void:
	_selected_minutes = GameState.bedtime_minutes
	_update_dial_display()
	super.open_overlay()


func _cycle_bedtime_timer() -> void:
	AudioDirector.play_sfx("wood_tap")
	var options := [0, 15, 30]
	var cur_idx := options.find(_selected_minutes)
	if cur_idx == -1:
		cur_idx = 0
	var next_idx := (cur_idx + 1) % options.size()
	_on_timer_selected(options[next_idx], _dial_btn)


func _on_timer_selected(minutes: int, btn: Button) -> void:
	_selected_minutes = minutes
	GameState.set_bedtime_timer(minutes)
	bedtime_timer_changed.emit(minutes)
	_update_dial_display()


func _update_dial_display() -> void:
	if _dial_btn == null:
		return
	var lbl: Label = _dial_btn.get_node_or_null("DialLabel")
	if lbl != null:
		if _selected_minutes == 0:
			lbl.text = "Tắt\nOff"
		else:
			lbl.text = "%d\nPhút" % _selected_minutes


func _on_volume_changed(val: float) -> void:
	var db := linear_to_db(maxf(val, 0.0001))
	AudioServer.set_bus_volume_db(0, db)
