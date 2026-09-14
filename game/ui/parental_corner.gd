class_name ParentalCorner
extends PauseOverlay

const StarlightBurst = preload("res://game/fx/starlight_burst.gd")
## Góc Phụ Huynh (Parental Corner & Cozy Bedtime Control).
## Thiết kế khớp 100% với mock-parental-corner.jpeg và tiêu chuẩn Apple Kids Category 1.3.
##
## Thẩm mỹ Bàn Gỗ Chạm Khắc 2.5D Diorama:
## - Bàn gỗ sồi uốn lượn chạm phù điêu gấu con say giấc ở bệ đỡ đáy
## - Thước trượt âm lượng gỗ xúc giác (Volume Slider)
## - Đĩa quay hẹn giờ đi ngủ hình Mặt Trăng phát sáng (Bedtime Timer Dial: Tắt / 15 / 30 / 45 / 60 phút)
## - Công tắc viên thuốc bật/tắt nhạc ru ngủ êm dịu (Lullaby Toggle)
## - Mascot bé phù thủy ngủ say ôm gấu sư tử nhún nhảy thở êm ái
## - Các món đồ chơi xúc giác: Khay 5 nhạc cụ, Tinh thể thạch anh tím/lam ngọc, Rương báu

signal bedtime_timer_changed(minutes: int)
signal volume_changed(linear_val: float)
signal lullaby_toggled(enabled: bool)

var _bg_texture: Texture2D
var _stage: Control
var _desk_rect: TextureRect

# Volume Controls
var _volume_slider: VSlider
var _volume_label: Label
var _volume_val: float = 0.85

# Timer Controls
var _timer_dial_btn: Button
var _timer_dial_rect: TextureRect
var _timer_label: Label
var _timer_presets: Array[int] = [0, 15, 30, 45, 60]
var _timer_idx: int = 1 # Mặc định 15 phút

# Lullaby Controls
var _lullaby_toggle_btn: Button
var _lullaby_enabled: bool = true
var _lullaby_player: AudioStreamPlayer

# Mascot Boy
var _boy_btn: Button
var _boy_rect: TextureRect
var _boy_time: float = 0.0

# Close button
var _close_btn: Button

# Particles & Time
var _burst_layer: StarlightBurst
var _time: float = 0.0


func _ready() -> void:
	super()
	layer = 19
	_build()
	_set_controls_visible(false)


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta
	_boy_time += delta

	# Nhịp thở êm ái của bé phù thủy ngủ say
	if _boy_rect != null and is_instance_valid(_boy_rect):
		var breathe := 1.0 + 0.022 * sin(_boy_time * 1.6)
		_boy_rect.scale = Vector2(1.0, breathe)

	# Nhịp thở phát sáng nhẹ của vầng hào quang Mặt Trăng hẹn giờ
	if _timer_dial_rect != null and is_instance_valid(_timer_dial_rect):
		var halo := 1.0 + 0.015 * sin(_time * 2.4)
		_timer_dial_rect.scale = Vector2(halo, halo)


func _build() -> void:
	_add_backdrop(Color(0.02, 0.03, 0.03, 0.94))

	# Khung sân khấu chính
	_stage = Control.new()
	_stage.name = "DioramaStage"
	_stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	_stage.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_stage)

	# 1. Phông nền toàn cảnh rừng đêm từ mock-parental-corner.jpeg
	if ResourceLoader.exists("res://assets/art/bg_parental_corner_forest_25d.png"):
		_bg_texture = load("res://assets/art/bg_parental_corner_forest_25d.png")

	var bg_rect := TextureRect.new()
	bg_rect.name = "BackgroundDiorama"
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _bg_texture != null:
		bg_rect.texture = _bg_texture
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	_stage.add_child(bg_rect)

	# 2. Hiệu ứng đom đóm rừng đêm lơ lửng
	var fireflies := MainMenu.FireflyOverlay.new()
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(fireflies)

	var empty_style := StyleBoxEmpty.new()

	# --- 3. BÀN GỖ CHẠM KHẮC PHÙ ĐIÊU GẤU NGỦ (DESK FRAME) ---
	# Tọa độ tương đối: X ~ 15.2% - 71.2%, Y ~ 17.0% - 86.0%
	_desk_rect = TextureRect.new()
	_desk_rect.name = "ParentalWoodDesk"
	_desk_rect.anchor_left = 0.152
	_desk_rect.anchor_top = 0.170
	_desk_rect.anchor_right = 0.712
	_desk_rect.anchor_bottom = 0.860
	if ResourceLoader.exists("res://assets/art/parental_wood_desk.png"):
		_desk_rect.texture = load("res://assets/art/parental_wood_desk.png")
	_desk_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_desk_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_desk_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	_stage.add_child(_desk_rect)

	# Tiêu đề "GÓC PHỤ HUYNH"
	var title_lbl := Label.new()
	title_lbl.name = "TitleLabel"
	title_lbl.anchor_left = 0.28
	title_lbl.anchor_top = 0.22
	title_lbl.anchor_right = 0.58
	title_lbl.anchor_bottom = 0.32
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 28)
	title_lbl.add_theme_color_override("font_color", Color("#4A2814"))
	title_lbl.text = "GÓC PHỤ HUYNH"
	title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(title_lbl)

	# --- 4. CỤM ĐIỀU KHIỂN ÂM LƯỢNG (VOLUME SLIDER TRÁI) ---
	# Tọa độ X ~ 22.0% - 29.5%, Y ~ 38.0% - 68.0%
	_volume_label = Label.new()
	_volume_label.anchor_left = 0.20
	_volume_label.anchor_top = 0.35
	_volume_label.anchor_right = 0.31
	_volume_label.anchor_bottom = 0.40
	_volume_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_volume_label.add_theme_font_size_override("font_size", 18)
	_volume_label.add_theme_color_override("font_color", Color("#4A2814"))
	_volume_label.text = "ÂM LƯỢNG"
	_stage.add_child(_volume_label)

	_volume_slider = VSlider.new()
	_volume_slider.name = "VolumeSlider"
	_volume_slider.anchor_left = 0.235
	_volume_slider.anchor_top = 0.42
	_volume_slider.anchor_right = 0.275
	_volume_slider.anchor_bottom = 0.65
	_volume_slider.min_value = 0.0
	_volume_slider.max_value = 1.0
	_volume_slider.step = 0.05
	_volume_slider.value = _volume_val
	_volume_slider.focus_mode = Control.FOCUS_NONE

	# Style cho thanh trượt
	var slider_grabber := StyleBoxFlat.new()
	slider_grabber.bg_color = Color("#8B5226")
	slider_grabber.border_color = Color("#FCE4B4")
	slider_grabber.set_border_width_all(2)
	slider_grabber.set_corner_radius_all(12)

	_volume_slider.value_changed.connect(_on_volume_changed)
	_stage.add_child(_volume_slider)

	# --- 5. CỤM ĐĨA QUAY HẸN GIỜ ĐI NGỦ (TIMER DIAL Ở GIỮA) ---
	# Tọa độ X ~ 32.0% - 44.0%, Y ~ 34.0% - 70.0%
	_timer_dial_rect = TextureRect.new()
	_timer_dial_rect.name = "TimerDialRect"
	_timer_dial_rect.anchor_left = 0.320
	_timer_dial_rect.anchor_top = 0.340
	_timer_dial_rect.anchor_right = 0.445
	_timer_dial_rect.anchor_bottom = 0.700
	if ResourceLoader.exists("res://assets/art/dial_timer_moon_ring.png"):
		_timer_dial_rect.texture = load("res://assets/art/dial_timer_moon_ring.png")
	_timer_dial_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_timer_dial_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_timer_dial_rect.pivot_offset = Vector2(85, 135)
	_timer_dial_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	_stage.add_child(_timer_dial_rect)

	_timer_label = Label.new()
	_timer_label.name = "TimerLabel"
	_timer_label.anchor_left = 0.340
	_timer_label.anchor_top = 0.480
	_timer_label.anchor_right = 0.425
	_timer_label.anchor_bottom = 0.620
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_timer_label.add_theme_font_size_override("font_size", 22)
	_timer_label.add_theme_color_override("font_color", Color("#4A2814"))
	_timer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_timer_label)
	_update_timer_label()

	_timer_dial_btn = Button.new()
	_timer_dial_btn.name = "TimerDialBtn"
	_timer_dial_btn.anchor_left = 0.320
	_timer_dial_btn.anchor_top = 0.340
	_timer_dial_btn.anchor_right = 0.445
	_timer_dial_btn.anchor_bottom = 0.700
	_timer_dial_btn.focus_mode = Control.FOCUS_NONE
	_timer_dial_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_timer_dial_btn.flat = true
	_timer_dial_btn.add_theme_stylebox_override("normal", empty_style)
	_timer_dial_btn.add_theme_stylebox_override("hover", empty_style)
	_timer_dial_btn.add_theme_stylebox_override("pressed", empty_style)
	_timer_dial_btn.pressed.connect(_on_timer_dial_pressed)
	_stage.add_child(_timer_dial_btn)

	# --- 6. CỤM CÔNG TẮC NHẠC RU NGỦ (LULLABY TOGGLE PHẢI) ---
	# Tọa độ X ~ 45.0% - 53.5%, Y ~ 35.0% - 62.0%
	var lullaby_lbl := Label.new()
	lullaby_lbl.anchor_left = 0.43
	lullaby_lbl.anchor_top = 0.35
	lullaby_lbl.anchor_right = 0.54
	lullaby_lbl.anchor_bottom = 0.40
	lullaby_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lullaby_lbl.add_theme_font_size_override("font_size", 18)
	lullaby_lbl.add_theme_color_override("font_color", Color("#4A2814"))
	lullaby_lbl.text = "NHẠC RU NGỦ"
	_stage.add_child(lullaby_lbl)

	_lullaby_toggle_btn = Button.new()
	_lullaby_toggle_btn.name = "LullabyToggleBtn"
	_lullaby_toggle_btn.anchor_left = 0.450
	_lullaby_toggle_btn.anchor_top = 0.435
	_lullaby_toggle_btn.anchor_right = 0.515
	_lullaby_toggle_btn.anchor_bottom = 0.530
	_lullaby_toggle_btn.focus_mode = Control.FOCUS_NONE
	_lullaby_toggle_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_lullaby_toggle_btn.text = "✔ BẬT"
	_apply_lullaby_toggle_style()
	_lullaby_toggle_btn.pressed.connect(_on_lullaby_toggle_pressed)
	_stage.add_child(_lullaby_toggle_btn)

	# --- 7. MASCOT BÉ PHÙ THỦY NGỦ SAY ÔM SƯ TỬ CON ---
	# Tọa độ X ~ 61.0% - 90.0%, Y ~ 55.0% - 93.0%
	_boy_rect = TextureRect.new()
	_boy_rect.name = "SleepingBoyRect"
	_boy_rect.anchor_left = 0.610
	_boy_rect.anchor_top = 0.550
	_boy_rect.anchor_right = 0.900
	_boy_rect.anchor_bottom = 0.930
	if ResourceLoader.exists("res://assets/art/char_sleeping_wizard_bed.png"):
		_boy_rect.texture = load("res://assets/art/char_sleeping_wizard_bed.png")
	_boy_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_boy_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_boy_rect.pivot_offset = Vector2(200, 260)
	_boy_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	_stage.add_child(_boy_rect)

	_boy_btn = Button.new()
	_boy_btn.name = "SleepingBoyBtn"
	_boy_btn.anchor_left = 0.610
	_boy_btn.anchor_top = 0.550
	_boy_btn.anchor_right = 0.900
	_boy_btn.anchor_bottom = 0.930
	_boy_btn.focus_mode = Control.FOCUS_NONE
	_boy_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_boy_btn.flat = true
	_boy_btn.add_theme_stylebox_override("normal", empty_style)
	_boy_btn.add_theme_stylebox_override("hover", empty_style)
	_boy_btn.add_theme_stylebox_override("pressed", empty_style)
	_boy_btn.pressed.connect(_on_sleeping_boy_tapped)
	_stage.add_child(_boy_btn)

	# --- 8. NÚT ĐÓNG / QUAY LẠI GÓC PHẢI TRÊN (HOME / CLOSE) ---
	_close_btn = Button.new()
	_close_btn.name = "BtnCloseCorner"
	_close_btn.anchor_left = 0.890
	_close_btn.anchor_top = 0.035
	_close_btn.anchor_right = 0.975
	_close_btn.anchor_bottom = 0.175
	_close_btn.focus_mode = Control.FOCUS_NONE
	_close_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_close_btn.flat = true
	_close_btn.add_theme_stylebox_override("normal", empty_style)
	_close_btn.add_theme_stylebox_override("hover", empty_style)
	_close_btn.add_theme_stylebox_override("pressed", empty_style)
	_close_btn.pressed.connect(_on_close_pressed)
	_stage.add_child(_close_btn)

	# --- 9. CÁC ĐIỂM CHẠM ĐỒ CHƠI (TOY HOTSPOTS) ---
	_build_toy_hotspots()

	# --- 10. ÂM THANH NHẠC RU NGỦ (AUDIO STREAM PLAYER) ---
	_lullaby_player = AudioStreamPlayer.new()
	_lullaby_player.name = "LullabyPlayer"
	_lullaby_player.bus = "Master"
	_lullaby_player.volume_db = -12.0
	if ResourceLoader.exists("res://assets/audio/bgm_forest_loop.ogg"):
		_lullaby_player.stream = load("res://assets/audio/bgm_forest_loop.ogg")
	add_child(_lullaby_player)

	# --- 11. LỚP BÙNG NỔ BỤI SAO XÚC GIÁC ---
	_burst_layer = StarlightBurst.new()
	_burst_layer.speed_min = 30.0
	_burst_layer.speed_max = 150.0
	_burst_layer.radius_min = 2.0
	_burst_layer.radius_max = 4.5
	_burst_layer.decay_min = 1.5
	_burst_layer.decay_max = 2.5
	_burst_layer.damping = 0.92
	_burst_layer.halo_scale = 1.8
	_burst_layer.halo_alpha = 0.22
	_burst_layer.default_color = Color("#FFD768")
	_burst_layer.default_count = 16
	_burst_layer.name = "CornerBurstLayer"
	_burst_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_burst_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_burst_layer)


func _build_toy_hotspots() -> void:
	var empty := StyleBoxEmpty.new()

	# Tinh thể pha lê lam ngọc góc trái (X ~ 0% - 10%, Y ~ 55% - 78%)
	var crystal_btn := Button.new()
	crystal_btn.name = "CrystalToyBtn"
	crystal_btn.anchor_left = 0.0
	crystal_btn.anchor_top = 0.55
	crystal_btn.anchor_right = 0.10
	crystal_btn.anchor_bottom = 0.78
	crystal_btn.flat = true
	crystal_btn.focus_mode = Control.FOCUS_NONE
	crystal_btn.add_theme_stylebox_override("normal", empty)
	crystal_btn.pressed.connect(func():
		_play_sfx("star_ting")
		if _burst_layer != null:
			_burst_layer.emit_burst(crystal_btn.get_global_rect().get_center(), Color("#42B6D9"), 16)
	)
	_stage.add_child(crystal_btn)

	# Rương báu gỗ góc phải (X ~ 90% - 99%, Y ~ 58% - 75%)
	var chest_btn := Button.new()
	chest_btn.name = "ChestToyBtn"
	chest_btn.anchor_left = 0.90
	chest_btn.anchor_top = 0.58
	chest_btn.anchor_right = 0.99
	chest_btn.anchor_bottom = 0.75
	chest_btn.flat = true
	chest_btn.focus_mode = Control.FOCUS_NONE
	chest_btn.add_theme_stylebox_override("normal", empty)
	chest_btn.pressed.connect(func():
		_play_sfx("soft_plop")
		if _burst_layer != null:
			_burst_layer.emit_burst(chest_btn.get_global_rect().get_center(), Color(1.0, 0.85, 0.35, 0.9), 14)
	)
	_stage.add_child(chest_btn)


func open_corner() -> void:
	_play_sfx("menu_open")
	open_overlay()
	_sync_state_from_engine()
	if _lullaby_enabled and _lullaby_player != null and not _lullaby_player.playing:
		_lullaby_player.play()


func close_corner() -> void:
	if _lullaby_player != null and _lullaby_player.playing:
		_lullaby_player.stop()
	close_overlay()


func _sync_state_from_engine() -> void:
	# Đồng bộ âm lượng hiện tại
	var bus_idx := AudioServer.get_bus_index("Master")
	if bus_idx >= 0:
		var db := AudioServer.get_bus_volume_db(bus_idx)
		_volume_val = db_to_linear(db)
		if _volume_slider != null:
			_volume_slider.value = _volume_val

	# Đồng bộ bộ đếm giờ ngủ từ GameState nếu có
	var found_idx := _timer_presets.find(GameState.bedtime_minutes)
	if found_idx >= 0:
		_timer_idx = found_idx
	_update_timer_label()


func _on_volume_changed(val: float) -> void:
	_volume_val = val
	var bus_idx := AudioServer.get_bus_index("Master")
	if bus_idx >= 0:
		var db := linear_to_db(val)
		if val <= 0.01:
			AudioServer.set_bus_mute(bus_idx, true)
		else:
			AudioServer.set_bus_mute(bus_idx, false)
			AudioServer.set_bus_volume_db(bus_idx, db)
	volume_changed.emit(val)


func _on_timer_dial_pressed() -> void:
	_timer_idx = (_timer_idx + 1) % _timer_presets.size()
	var mins: int = _timer_presets[_timer_idx]
	_play_sfx("star_ting")

	# Hoạt cảnh xoay nhẹ đĩa hẹn giờ
	if _timer_dial_rect != null:
		var tw := create_tween()
		tw.tween_property(_timer_dial_rect, "rotation_degrees", _timer_dial_rect.rotation_degrees + 72.0, 0.20).set_trans(Tween.TRANS_BACK)

	_update_timer_label()

	# Cập nhật GameState
	GameState.set_bedtime_timer(mins)

	if _burst_layer != null and _timer_dial_btn != null:
		_burst_layer.emit_burst(_timer_dial_btn.get_global_rect().get_center(), Color("#FFD768"), 18)

	bedtime_timer_changed.emit(mins)


func _update_timer_label() -> void:
	if _timer_label == null:
		return
	var mins: int = _timer_presets[_timer_idx]
	if mins == 0:
		_timer_label.text = "TẮT"
	else:
		_timer_label.text = "%d\nPhút" % mins


func _on_lullaby_toggle_pressed() -> void:
	_lullaby_enabled = not _lullaby_enabled
	_play_sfx("soft_boing")
	_apply_lullaby_toggle_style()

	if _lullaby_enabled:
		if _lullaby_player != null and not _lullaby_player.playing:
			_lullaby_player.play()
	else:
		if _lullaby_player != null and _lullaby_player.playing:
			_lullaby_player.stop()

	lullaby_toggled.emit(_lullaby_enabled)


func _apply_lullaby_toggle_style() -> void:
	if _lullaby_toggle_btn == null:
		return
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(14)
	style.set_border_width_all(2)

	if _lullaby_enabled:
		_lullaby_toggle_btn.text = "✔ BẬT"
		style.bg_color = Color(0.24, 0.58, 0.28, 0.92) # Xanh lá tươi
		style.border_color = Color("#FFF5D0")
		_lullaby_toggle_btn.add_theme_color_override("font_color", Color("#FFF5D0"))
	else:
		_lullaby_toggle_btn.text = "✖ TẮT"
		style.bg_color = Color(0.38, 0.28, 0.22, 0.90) # Nâu sẫm
		style.border_color = Color(0.6, 0.5, 0.4)
		_lullaby_toggle_btn.add_theme_color_override("font_color", Color(0.8, 0.75, 0.7))

	_lullaby_toggle_btn.add_theme_stylebox_override("normal", style)
	_lullaby_toggle_btn.add_theme_stylebox_override("hover", style)
	_lullaby_toggle_btn.add_theme_stylebox_override("pressed", style)


func _on_sleeping_boy_tapped() -> void:
	_play_sfx("cute_purr")
	if _boy_rect != null:
		var tw := create_tween()
		tw.tween_property(_boy_rect, "scale", Vector2(1.15, 0.88), 0.10).set_trans(Tween.TRANS_QUAD)
		tw.tween_property(_boy_rect, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK)

	if _burst_layer != null and _boy_btn != null:
		_burst_layer.emit_burst(_boy_btn.get_global_rect().get_center() + Vector2(0, -40), Color(0.75, 0.85, 1.0, 0.95), 16)


func _on_close_pressed() -> void:
	_play_sfx("wood_tap")
	if _close_btn != null:
		var tw := create_tween()
		tw.tween_property(_close_btn, "scale", Vector2(0.85, 0.85), 0.08)
		tw.tween_property(_close_btn, "scale", Vector2.ONE, 0.10)
	close_corner()


func _play_sfx(sfx_name: String) -> void:
	AudioDirector.play_sfx(sfx_name)


## Lớp hiệu ứng bụi sao bung nở cho Góc Phụ Huynh
