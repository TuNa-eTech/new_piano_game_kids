class_name GoodnightScreen
extends PauseOverlay
## Màn Chúc Bé Ngủ Ngon (Goodnight Bedtime & Sleeping Piano Diorama).
## Thiết kế khớp 100% với mock-goodnight-bedtime.jpeg và tiêu chuẩn Apple Kids Category 1.3.
##
## Thẩm mỹ Sách Tranh Nổi 2.5D Diorama Giờ Đi Ngủ:
## - Toàn cảnh khu rừng chìm vào màn đêm êm đềm với đèn lồng bí ngô phát sáng dịu
## - Bảng gỗ trên cùng: 'Khu rừng đã ngủ say rồi. Chúc bé ngủ ngon! 🌙✨'
## - Cuốn sách nổi mở ra cảnh bé Phù Thủy say giấc nồng ôm bạn Sư Tử dưới chăn lá cây
## - Cây đậu thần phát sáng trắng bạc kèm dải nốt nhạc ru ngủ pastel uốn lượn
## - Bàn phím đàn gỗ bên dưới: 7 bạn thú nhắm mắt ngủ say với chữ nốt C-D-E-F-G-A-B
## - Nút tròn gỗ BACK (kích hoạt Cổng Phụ Huynh) & Nút tròn gỗ SOUND (bật/tắt nhạc ru)

signal wake_up_requested
signal sound_toggled(enabled: bool)

var _bg_texture: Texture2D
var _stage: Control
var _book_rect: TextureRect
var _plaque_rect: TextureRect
var _piano_rect: TextureRect

var _back_btn: Button
var _sound_btn: Button
var _piano_keys: Array[Button] = []

var _lullaby_player: AudioStreamPlayer
var _sound_enabled: bool = true
var _burst_layer: GoodnightZzzBurstLayer
var _time: float = 0.0


func _ready() -> void:
	super()
	layer = 18
	_build()
	_set_controls_visible(false)


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta

	# Nhịp thở phập phồng nhẹ nhàng của cuốn sách nổi bé phù thủy say giấc
	if _book_rect != null and is_instance_valid(_book_rect):
		var breathe := 1.0 + 0.018 * sin(_time * 1.5)
		_book_rect.scale = Vector2(1.0, breathe)

	# Nhịp thở êm đềm của bảng gỗ chúc ngủ ngon
	if _plaque_rect != null and is_instance_valid(_plaque_rect):
		var sway := 1.0 + 0.012 * sin(_time * 2.1)
		_plaque_rect.scale = Vector2(sway, sway)


func _build() -> void:
	_add_backdrop(Color(0.01, 0.02, 0.04, 0.96))

	# Khung sân khấu chính
	_stage = Control.new()
	_stage.name = "DioramaStage"
	_stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	_stage.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_stage)

	# 1. Phông nền toàn cảnh rừng đêm từ mock-goodnight-bedtime.jpeg
	if ResourceLoader.exists("res://assets/art/bg_goodnight_forest_25d.png"):
		_bg_texture = load("res://assets/art/bg_goodnight_forest_25d.png")
	elif ResourceLoader.exists("res://docs/mock-goodnight-bedtime.jpeg"):
		_bg_texture = load("res://docs/mock-goodnight-bedtime.jpeg")

	var bg_rect := TextureRect.new()
	bg_rect.name = "BackgroundDiorama"
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _bg_texture != null:
		bg_rect.texture = _bg_texture
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	_stage.add_child(bg_rect)

	# 2. Hiệu ứng đom đóm bay chậm chạp êm dịu ban đêm
	var fireflies := NightFireflyOverlay.new()
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(fireflies)

	var empty_style := StyleBoxEmpty.new()

	# --- 3. BẢNG GỖ LỜI CHÚC NGỦ NGON Ở ĐỈNH ---
	# Tọa độ tương đối: X ~ 31.2% - 67.6%, Y ~ 2.6% - 18.9%
	_plaque_rect = TextureRect.new()
	_plaque_rect.name = "GoodnightPlaque"
	_plaque_rect.anchor_left = 0.312
	_plaque_rect.anchor_top = 0.026
	_plaque_rect.anchor_right = 0.676
	_plaque_rect.anchor_bottom = 0.189
	if ResourceLoader.exists("res://assets/art/plaque_goodnight_wood_banner.png"):
		_plaque_rect.texture = load("res://assets/art/plaque_goodnight_wood_banner.png")
	_plaque_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_plaque_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_plaque_rect.pivot_offset = Vector2(250, 62)
	_plaque_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	_stage.add_child(_plaque_rect)

	var plaque_lbl := Label.new()
	plaque_lbl.name = "PlaqueLabel"
	plaque_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	plaque_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	plaque_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	plaque_lbl.add_theme_font_size_override("font_size", 20)
	plaque_lbl.add_theme_color_override("font_color", Color("#FFF5D0"))
	plaque_lbl.add_theme_color_override("font_shadow_color", Color(0.12, 0.08, 0.03, 0.9))
	plaque_lbl.add_theme_constant_override("shadow_offset_x", 2)
	plaque_lbl.add_theme_constant_override("shadow_offset_y", 2)
	plaque_lbl.text = "Khu rừng đã ngủ say rồi.\nChúc bé ngủ ngon! 🌙✨"
	plaque_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plaque_rect.add_child(plaque_lbl)

	# --- 4. CUỐN SÁCH NỔI BÉ PHÙ THỦY SAY GIẤC & CÂY ĐẬU THẦN ---
	# Tọa độ tương đối: X ~ 24.0% - 76.3%, Y ~ 16.3% - 67.0%
	_book_rect = TextureRect.new()
	_book_rect.name = "SleepingBookRect"
	_book_rect.anchor_left = 0.240
	_book_rect.anchor_top = 0.163
	_book_rect.anchor_right = 0.763
	_book_rect.anchor_bottom = 0.670
	if ResourceLoader.exists("res://assets/art/book_sleeping_boy_beanstalk.png"):
		_book_rect.texture = load("res://assets/art/book_sleeping_boy_beanstalk.png")
	_book_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_book_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_book_rect.pivot_offset = Vector2(360, 195)
	_book_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	_stage.add_child(_book_rect)

	# Nút chạm tương tác vào sách
	var book_btn := Button.new()
	book_btn.name = "BookInteractiveBtn"
	book_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	book_btn.focus_mode = Control.FOCUS_NONE
	book_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	book_btn.flat = true
	book_btn.add_theme_stylebox_override("normal", empty_style)
	book_btn.add_theme_stylebox_override("hover", empty_style)
	book_btn.add_theme_stylebox_override("pressed", empty_style)
	book_btn.pressed.connect(_on_sleeping_book_tapped)
	_book_rect.add_child(book_btn)

	# --- 5. BÀN PHÍM ĐÀN 7 BẠN THÚ NGỦ SAY ---
	# Tọa độ tương đối: X ~ 10.2% - 90.1%, Y ~ 65.1% - 100.0%
	_piano_rect = TextureRect.new()
	_piano_rect.name = "SleepingPianoRect"
	_piano_rect.anchor_left = 0.102
	_piano_rect.anchor_top = 0.651
	_piano_rect.anchor_right = 0.901
	_piano_rect.anchor_bottom = 1.000
	if ResourceLoader.exists("res://assets/art/keys_piano_sleeping_animals.png"):
		_piano_rect.texture = load("res://assets/art/keys_piano_sleeping_animals.png")
	_piano_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_piano_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_piano_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	_stage.add_child(_piano_rect)

	# 7 vùng chạm xúc giác cho 7 phím thú
	_build_sleeping_keys()

	# --- 6. NÚT TRÒN GỖ QUAY LẠI (BACK BUTTON GÓC TRÊN TRÁI) ---
	# Tọa độ X ~ 1.8% - 8.4%, Y ~ 3.3% - 15.0%
	_back_btn = Button.new()
	_back_btn.name = "BtnBack"
	_back_btn.anchor_left = 0.018
	_back_btn.anchor_top = 0.033
	_back_btn.anchor_right = 0.084
	_back_btn.anchor_bottom = 0.150
	_back_btn.focus_mode = Control.FOCUS_NONE
	_back_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_back_btn.flat = true
	_back_btn.add_theme_stylebox_override("normal", empty_style)
	_back_btn.add_theme_stylebox_override("hover", empty_style)
	_back_btn.add_theme_stylebox_override("pressed", empty_style)
	_back_btn.item_rect_changed.connect(func(): _back_btn.pivot_offset = _back_btn.size * 0.5)

	var back_tex_rect := TextureRect.new()
	back_tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if ResourceLoader.exists("res://assets/art/ui_btn_wood_circle_back.png"):
		back_tex_rect.texture = load("res://assets/art/ui_btn_wood_circle_back.png")
	back_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	back_tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	back_tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_back_btn.add_child(back_tex_rect)
	_back_btn.pressed.connect(_on_unlock_pressed)
	_stage.add_child(_back_btn)

	# --- 7. NÚT TRÒN GỖ LOA ÂM THANH (SOUND BUTTON GÓC TRÊN PHẢI) ---
	# Tọa độ X ~ 91.6% - 98.1%, Y ~ 3.3% - 15.0%
	_sound_btn = Button.new()
	_sound_btn.name = "BtnSound"
	_sound_btn.anchor_left = 0.916
	_sound_btn.anchor_top = 0.033
	_sound_btn.anchor_right = 0.981
	_sound_btn.anchor_bottom = 0.150
	_sound_btn.focus_mode = Control.FOCUS_NONE
	_sound_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_sound_btn.flat = true
	_sound_btn.add_theme_stylebox_override("normal", empty_style)
	_sound_btn.add_theme_stylebox_override("hover", empty_style)
	_sound_btn.add_theme_stylebox_override("pressed", empty_style)
	_sound_btn.item_rect_changed.connect(func(): _sound_btn.pivot_offset = _sound_btn.size * 0.5)

	var sound_tex_rect := TextureRect.new()
	sound_tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if ResourceLoader.exists("res://assets/art/ui_btn_wood_circle_sound.png"):
		sound_tex_rect.texture = load("res://assets/art/ui_btn_wood_circle_sound.png")
	sound_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sound_tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sound_tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sound_btn.add_child(sound_tex_rect)
	_sound_btn.pressed.connect(_on_sound_toggle_pressed)
	_stage.add_child(_sound_btn)

	# --- 8. ÂM THANH NHẠC RU NGỦ ---
	_lullaby_player = AudioStreamPlayer.new()
	_lullaby_player.name = "GoodnightLullabyPlayer"
	_lullaby_player.bus = "Master"
	_lullaby_player.volume_db = -14.0
	if ResourceLoader.exists("res://assets/audio/bgm_forest_loop.ogg"):
		_lullaby_player.stream = load("res://assets/audio/bgm_forest_loop.ogg")
	add_child(_lullaby_player)

	# --- 9. LỚP BỤI SAO & BONG BÓNG ZZZ RU NGỦ ---
	_burst_layer = GoodnightZzzBurstLayer.new()
	_burst_layer.name = "GoodnightZzzBurstLayer"
	_burst_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_burst_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_burst_layer)


func _build_sleeping_keys() -> void:
	var empty := StyleBoxEmpty.new()
	var animal_names := ["Sư tử", "Gấu", "Thỏ", "Mèo", "Khỉ", "Voi", "Cú"]
	var colors := [
		Color("#F57C73"), Color("#F7B05B"), Color("#F5DE6A"),
		Color("#8BC34A"), Color("#4DD0E1"), Color("#7986CB"), Color("#BA68C8")
	]

	# 7 phím đàn chia đều theo chiều ngang từ ~ 17% đến ~ 83% trên thanh đàn
	var start_x := 0.170
	var key_w := 0.094

	for i in range(7):
		var btn := Button.new()
		btn.name = "SleepingKey_%d" % i
		btn.anchor_left = start_x + i * key_w
		btn.anchor_top = 0.700
		btn.anchor_right = start_x + (i + 1) * key_w
		btn.anchor_bottom = 0.980
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.flat = true
		btn.add_theme_stylebox_override("normal", empty)
		btn.add_theme_stylebox_override("hover", empty)
		btn.add_theme_stylebox_override("pressed", empty)
		btn.item_rect_changed.connect(func(): btn.pivot_offset = btn.size * 0.5)

		var col: Color = colors[i]
		var a_name: String = animal_names[i]
		btn.pressed.connect(_on_key_pressed.bind(btn, i, col, a_name))
		_stage.add_child(btn)
		_piano_keys.append(btn)


func open_overlay() -> void:
	super.open_overlay()
	_play_lullaby()
	_play_entrance_animation()


func close_overlay() -> void:
	if _lullaby_player != null and _lullaby_player.playing:
		_lullaby_player.stop()
	super.close_overlay()


func _play_entrance_animation() -> void:
	# Bảng gỗ và cuốn sách nổi mở ra nhún nhảy nhẹ nhàng
	if _plaque_rect != null:
		_plaque_rect.scale = Vector2(0.6, 0.6)
		var tw_p := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw_p.tween_property(_plaque_rect, "scale", Vector2.ONE, 0.38)

	if _book_rect != null:
		_book_rect.scale = Vector2(0.85, 0.85)
		var tw_b := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw_b.tween_property(_book_rect, "scale", Vector2.ONE, 0.42)


func _on_unlock_pressed() -> void:
	_play_sfx("wood_tap")
	if _back_btn != null:
		var tw := create_tween()
		tw.tween_property(_back_btn, "scale", Vector2(0.85, 0.85), 0.08)
		tw.tween_property(_back_btn, "scale", Vector2.ONE, 0.10)
	wake_up_requested.emit()


func _on_sound_toggle_pressed() -> void:
	_sound_enabled = not _sound_enabled
	_play_sfx("soft_boing")
	if _sound_btn != null:
		var tw := create_tween()
		tw.tween_property(_sound_btn, "scale", Vector2(1.2, 1.2), 0.08)
		tw.tween_property(_sound_btn, "scale", Vector2.ONE, 0.12)

	if _sound_enabled:
		_sound_btn.modulate = Color.WHITE
		if _lullaby_player != null and not _lullaby_player.playing:
			_lullaby_player.play()
	else:
		_sound_btn.modulate = Color(0.6, 0.6, 0.6, 0.7)
		if _lullaby_player != null and _lullaby_player.playing:
			_lullaby_player.stop()

	sound_toggled.emit(_sound_enabled)


func _on_sleeping_book_tapped() -> void:
	_play_sfx("cute_purr")
	if _book_rect != null:
		var tw := create_tween()
		tw.tween_property(_book_rect, "scale", Vector2(1.05, 0.95), 0.10).set_trans(Tween.TRANS_QUAD)
		tw.tween_property(_book_rect, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK)

	if _burst_layer != null and _book_rect != null:
		var c := _book_rect.get_global_rect().get_center() + Vector2(-60, -20)
		_burst_layer.emit_burst(c, Color("#FFF5D0"), 18)


func _on_key_pressed(btn: Button, key_idx: int, col: Color, _animal: String) -> void:
	# Nhấn phím thú ngủ say: phát nốt ru dịu êm và nhún nhẹ
	_play_sfx("star_ting")
	var tw := create_tween()
	tw.tween_property(btn, "scale", Vector2(1.15, 0.90), 0.08).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(btn, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK)

	if _burst_layer != null:
		var c := btn.get_global_rect().get_center()
		_burst_layer.emit_burst(c, col, 12)


func _play_lullaby() -> void:
	if _sound_enabled and _lullaby_player != null and not _lullaby_player.playing:
		_lullaby_player.play()


func _play_sfx(sfx_name: String) -> void:
	var ad := get_node_or_null("/root/AudioDirector")
	if ad != null and ad.has_method("play_sfx"):
		ad.play_sfx(sfx_name)


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


## Lớp phát hiệu ứng bụi sao và chữ Zzz ru ngủ khi chạm
class GoodnightZzzBurstLayer extends Control:
	var _particles: Array[Dictionary] = []

	func emit_burst(origin: Vector2, color: Color = Color(1.0, 0.95, 0.55, 0.95), count: int = 14) -> void:
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		for j in range(count):
			var angle := rng.randf_range(0, TAU)
			var spd := rng.randf_range(20.0, 110.0)
			_particles.append({
				"pos": origin,
				"vel": Vector2(cos(angle), sin(angle) - 0.4) * spd,
				"color": color,
				"alpha": 1.0,
				"radius": rng.randf_range(2.5, 4.8),
				"decay": rng.randf_range(1.2, 2.2),
			})

	func _process(delta: float) -> void:
		if _particles.is_empty():
			return
		var i := _particles.size() - 1
		while i >= 0:
			var p: Dictionary = _particles[i]
			p["pos"] += p["vel"] * delta
			p["vel"] *= 0.94
			p["alpha"] -= p["decay"] * delta
			if p["alpha"] <= 0.0:
				_particles.remove_at(i)
			i -= 1
		queue_redraw()

	func _draw() -> void:
		for p in _particles:
			var col: Color = p["color"]
			col.a *= p["alpha"]
			draw_circle(p["pos"], p["radius"] * p["alpha"], col)
			draw_circle(p["pos"], p["radius"] * 2.0 * p["alpha"], Color(col.r, col.g, col.b, col.a * 0.25))
