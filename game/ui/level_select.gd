class_name LevelSelect
extends PauseOverlay

const StarlightBurst = preload("res://game/fx/starlight_burst.gd")
## Màn Hình Chọn Màn Chơi 2.5D Diorama (5 Bục Gỗ Âm Nhạc / Level Select).
## Thiết kế khớp 100% với mock-level-select.jpeg.
##
## Thẩm mỹ Sách Tranh Nổi 2.5D Diorama & Preschool Zero-Text UX:
## - Con đường đá cuội rêu xanh uốn lượn qua thung lũng rừng cổ tích
## - 5 bục gỗ khoanh cây cắt ngang tương ứng 5 bài hát (1..5)
## - Các bài đã vượt qua có 3 ngôi sao vàng rạng rỡ lơ lửng
## - Bạn Thỏ trắng nhạc sĩ nhún nhảy vẫy tay ở bục đang chơi (kèm dải nốt nhạc bay)
## - Vòng hào quang vàng ma thuật (Golden Aura Ring) xoay động dưới chân bục 4
## - Bục số 5 có Rương Báu Thần mạ vàng tỏa ánh sáng nhiệm màu
## - Bảng gỗ Baroque treo tiêu đề chương (hỗ trợ hiển thị động cho 3 chương)
## - Nút 'Quay lại' gỗ chạm khắc viên thuốc góc trái trên
## - Hũ sao thủy tinh nắp bần góc phải trên tích lũy sao

signal level_selected(page_index: int)
signal back_requested

var _bg_texture: Texture2D
var _stage: Control
var _title_label: Label
var _back_btn: Button
var _star_jar_btn: Button
var _chapter_index: int = 0
var _level_buttons: Array[Button] = []
var _pad_indicators: Array[LevelPadIndicator] = []
var _bunny_node: Control
var _chest_node: Control
var _notes_emitter: MusicalNotesLayer
var _burst_layer: StarlightBurst
var _time: float = 0.0


func _ready() -> void:
	super()
	layer = 11
	_build()
	_set_controls_visible(false)


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta

	# 1. Hoạt ảnh nhịp thở tự nhiên cho Nút Quay lại
	if _back_btn != null and is_instance_valid(_back_btn):
		var breathe := 1.0 + 0.02 * sin(_time * 2.8)
		_back_btn.scale = Vector2(breathe, breathe)

	# 2. Hoạt ảnh lấp lánh nảy nhẹ của Hũ Sao Thủy Tinh
	if _star_jar_btn != null and is_instance_valid(_star_jar_btn):
		_star_jar_btn.rotation = sin(_time * 2.2) * 0.03

	# 3. Hoạt ảnh nhún nhảy vẫy tay của Bạn Thỏ Trắng trên bục đang chơi
	if _bunny_node != null and is_instance_valid(_bunny_node):
		var hop := sin(_time * 3.6) * 5.0
		var tilt := sin(_time * 2.4) * 0.04
		_bunny_node.position.y = hop
		_bunny_node.rotation = tilt

	# 4. Hoạt ảnh lơ lửng của Rương Báu Thần bục số 5
	if _chest_node != null and is_instance_valid(_chest_node):
		_chest_node.position.y = sin(_time * 2.0 + 1.0) * 3.0


func _setup_interactive_props(empty_style: StyleBoxEmpty) -> void:
	# Cấu hình các điểm chạm xúc giác đồ chơi mầm non (Secret tactile toys)
	var props := [
		# 1. Huy hiệu Sư tử con ven đường
		{"name": "PropLionBadge", "rect": [0.225, 0.515, 0.285, 0.625], "sfx": "soft_boing", "col": Color("#FCD04B")},
		# 2. Huy hiệu Gấu con ven đường
		{"name": "PropBearBadge", "rect": [0.298, 0.495, 0.352, 0.592], "sfx": "soft_plop", "col": Color("#C48D52")},
		# 3. Huy hiệu Mèo con ven đường
		{"name": "PropCatBadge", "rect": [0.367, 0.468, 0.421, 0.566], "sfx": "cute_purr", "col": Color("#ED7A8E")},
		# 4. Huy hiệu nhỏ nép bụi hoa trước màn hình
		{"name": "PropBushBadges", "rect": [0.435, 0.810, 0.565, 0.910], "sfx": "giggle_cute", "col": Color("#FFE678")},
		# 5. Cụm thạch anh xanh Cyan trên gốc cây mục góc trái
		{"name": "PropCyanCrystal", "rect": [0.005, 0.560, 0.080, 0.720], "sfx": "fairy_dust", "col": Color("#4AE5D8")},
		# 6. Rương báu phụ trên thảm cỏ góc phải
		{"name": "PropGrassChest", "rect": [0.910, 0.580, 0.995, 0.740], "sfx": "chest_open", "col": Color("#FCD04B")}
	]

	for p in props:
		var btn := Button.new()
		btn.name = p["name"]
		var r: Array = p["rect"]
		btn.anchor_left = r[0]
		btn.anchor_top = r[1]
		btn.anchor_right = r[2]
		btn.anchor_bottom = r[3]
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.flat = true
		btn.add_theme_stylebox_override("normal", empty_style)
		btn.add_theme_stylebox_override("hover", empty_style)
		btn.add_theme_stylebox_override("pressed", empty_style)
		btn.item_rect_changed.connect(func(): btn.pivot_offset = btn.size * 0.5)

		var sfx_name: String = p["sfx"]
		var burst_col: Color = p["col"]
		btn.pressed.connect(func():
			_play_sfx(sfx_name)
			var tw := create_tween()
			tw.tween_property(btn, "scale", Vector2(1.22, 1.22), 0.09).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(btn, "scale", Vector2.ONE, 0.14)
			if _burst_layer != null:
				_burst_layer.emit_burst(btn.get_global_rect().get_center(), burst_col, 14)
		)
		_stage.add_child(btn)


func _build() -> void:
	_add_backdrop(Color(0.02, 0.04, 0.03, 0.95))

	# Khung sân khấu chính để diễn hoạt ảnh phóng to sách nổi (Pop-up Stage)
	_stage = Control.new()
	_stage.name = "DioramaStage"
	_stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	_stage.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_stage)

	# 1. Phông nền sạch Level Select (không dính chữ, không dính đạo cụ)
	if ResourceLoader.exists("res://assets/art/tex_bg_level_select_clean.png"):
		_bg_texture = load("res://assets/art/tex_bg_level_select_clean.png")

	var bg_rect := TextureRect.new()
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _bg_texture != null:
		bg_rect.texture = _bg_texture
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	_stage.add_child(bg_rect)

	# 2. Hiệu ứng đom đóm vàng lơ lửng rừng đêm
	var fireflies := MainMenu.FireflyOverlay.new()
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(fireflies)

	var empty_style := StyleBoxEmpty.new()

	# --- 3. NÚT QUAY LẠI GỖ 2.5D ZERO-TEXT (GÓC TRÊN TRÁI) ---
	_back_btn = Button.new()
	_back_btn.name = "BtnBack"
	_back_btn.flat = true
	_back_btn.focus_mode = Control.FOCUS_NONE
	_back_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_back_btn.anchor_left = 0.022
	_back_btn.anchor_top = 0.035
	_back_btn.anchor_right = 0.098
	_back_btn.anchor_bottom = 0.170
	_back_btn.offset_left = 0.0
	_back_btn.offset_top = 0.0
	_back_btn.offset_right = 0.0
	_back_btn.offset_bottom = 0.0
	_back_btn.pivot_offset = Vector2(49.0, 49.0)
	_back_btn.resized.connect(func(): _back_btn.pivot_offset = _back_btn.size * 0.5)

	for state in ["normal", "hover", "focus", "pressed", "disabled"]:
		_back_btn.add_theme_stylebox_override(state, empty_style)

	var back_icon := TextureRect.new()
	back_icon.name = "BackIcon"
	back_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	back_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	back_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	back_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/ui_btn_wood_back.png"):
		back_icon.texture = load("res://assets/art/ui_btn_wood_back.png")
	_back_btn.add_child(back_icon)

	_back_btn.button_down.connect(func():
		var tw := create_tween()
		tw.tween_property(_back_btn, "scale", Vector2(0.88, 0.88), 0.06)
	)
	_back_btn.button_up.connect(func():
		var tw := create_tween()
		tw.tween_property(_back_btn, "scale", Vector2(1.06, 1.06), 0.08)
		tw.tween_property(_back_btn, "scale", Vector2.ONE, 0.06)
	)
	_back_btn.pressed.connect(_on_back_pressed)
	_stage.add_child(_back_btn)

	# --- 4. HŨ SAO THỦY TINH (GÓC TRÊN PHẢI) ---
	_star_jar_btn = Button.new()
	_star_jar_btn.name = "BtnStarJar"
	_star_jar_btn.flat = true
	_star_jar_btn.focus_mode = Control.FOCUS_NONE
	_star_jar_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_star_jar_btn.anchor_left = 0.905
	_star_jar_btn.anchor_top = 0.020
	_star_jar_btn.anchor_right = 0.980
	_star_jar_btn.anchor_bottom = 0.170
	_star_jar_btn.offset_left = 0.0
	_star_jar_btn.offset_top = 0.0
	_star_jar_btn.offset_right = 0.0
	_star_jar_btn.offset_bottom = 0.0
	_star_jar_btn.pivot_offset = Vector2(48.0, 54.0)
	_star_jar_btn.resized.connect(func(): _star_jar_btn.pivot_offset = _star_jar_btn.size * 0.5)

	for state in ["normal", "hover", "focus", "pressed", "disabled"]:
		_star_jar_btn.add_theme_stylebox_override(state, empty_style)

	var jar_icon := TextureRect.new()
	jar_icon.name = "StarJarIcon"
	jar_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	jar_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	jar_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	jar_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/ui_star_jar.png"):
		jar_icon.texture = load("res://assets/art/ui_star_jar.png")
	_star_jar_btn.add_child(jar_icon)

	_star_jar_btn.pressed.connect(_on_star_jar_pressed)
	_stage.add_child(_star_jar_btn)

	# --- 5. TIÊU ĐỀ CHƯƠNG TRÊN BẢNG RUY BĂNG GỖ (TRUNG TÂM PHÍA TRÊN) ---
	_title_label = Label.new()
	_title_label.name = "ChapterTitleLabel"
	_title_label.anchor_left = 0.28
	_title_label.anchor_top = 0.038
	_title_label.anchor_right = 0.72
	_title_label.anchor_bottom = 0.175
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 26)
	_title_label.add_theme_color_override("font_color", Color("#FFF5D0"))
	_title_label.add_theme_color_override("font_shadow_color", Color(0.18, 0.08, 0.02, 0.9))
	_title_label.add_theme_constant_override("shadow_offset_x", 2)
	_title_label.add_theme_constant_override("shadow_offset_y", 2)
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_title_label)

	# --- 6. 5 BỤC GỖ ÂM NHẠC (1..5) TRÊN CON ĐƯỜNG ĐÁ ---
	var pad_rects := [
		[0.145, 0.62, 0.265, 0.84],
		[0.295, 0.56, 0.415, 0.78],
		[0.440, 0.56, 0.560, 0.78],
		[0.580, 0.56, 0.720, 0.84],
		[0.745, 0.58, 0.865, 0.84]
	]

	for i in 5:
		var btn := Button.new()
		var pr: Array = pad_rects[i]
		btn.name = "PadBtn_%d" % (i + 1)
		btn.anchor_left = pr[0]
		btn.anchor_top = pr[1]
		btn.anchor_right = pr[2]
		btn.anchor_bottom = pr[3]
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.flat = true
		btn.add_theme_stylebox_override("normal", empty_style)
		btn.add_theme_stylebox_override("hover", empty_style)
		btn.add_theme_stylebox_override("pressed", empty_style)
		btn.add_theme_stylebox_override("disabled", empty_style)
		btn.item_rect_changed.connect(func(): btn.pivot_offset = btn.size * 0.5)

		# 1. Bục gỗ cắt lát 2.5D
		var pad_img := TextureRect.new()
		pad_img.name = "PadWoodTexture"
		pad_img.set_anchors_preset(Control.PRESET_FULL_RECT)
		pad_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pad_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pad_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if ResourceLoader.exists("res://assets/art/spr_level_pad_wood.png"):
			pad_img.texture = load("res://assets/art/spr_level_pad_wood.png")
		btn.add_child(pad_img)

		# 2. Số nổi 3D trên thớt gỗ
		var num_lbl := Label.new()
		num_lbl.name = "PadNumberLabel"
		num_lbl.text = str(i + 1)
		num_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		num_lbl.add_theme_font_size_override("font_size", 28)
		num_lbl.add_theme_color_override("font_color", Color("#FFFDF7"))
		num_lbl.add_theme_color_override("font_shadow_color", Color("#4E2A14"))
		num_lbl.add_theme_constant_override("shadow_offset_x", 2)
		num_lbl.add_theme_constant_override("shadow_offset_y", 2)
		num_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		num_lbl.offset_top = -14.0
		num_lbl.offset_bottom = -14.0
		btn.add_child(num_lbl)

		# 3. Cụm 3 sao vàng lơ lửng phía trên bục (hiện khi đã hoàn thành)
		var stars_img := TextureRect.new()
		stars_img.name = "PadStarsCluster"
		stars_img.anchor_left = 0.02
		stars_img.anchor_top = -0.52
		stars_img.anchor_right = 0.98
		stars_img.anchor_bottom = 0.05
		stars_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		stars_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		stars_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stars_img.visible = false
		if ResourceLoader.exists("res://assets/art/ui_stars_3_cluster.png"):
			stars_img.texture = load("res://assets/art/ui_stars_3_cluster.png")
		btn.add_child(stars_img)

		# 4. Rương báu thần trên bục 5
		if i == 4:
			_chest_node = TextureRect.new()
			_chest_node.name = "TreasureChestPad5"
			_chest_node.anchor_left = 0.08
			_chest_node.anchor_top = -0.62
			_chest_node.anchor_right = 0.92
			_chest_node.anchor_bottom = 0.28
			_chest_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			_chest_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			_chest_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if ResourceLoader.exists("res://assets/art/spr_level_chest_gold.png"):
				_chest_node.texture = load("res://assets/art/spr_level_chest_gold.png")
			btn.add_child(_chest_node)

		# 5. Vòng hào quang vàng và hiệu ứng khóa (LevelPadIndicator)
		var pad_draw := LevelPadIndicator.new(i)
		pad_draw.set_anchors_preset(Control.PRESET_FULL_RECT)
		pad_draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(pad_draw)
		_pad_indicators.append(pad_draw)

		_stage.add_child(btn)
		_level_buttons.append(btn)

	# Tạo sẵn Bạn Thỏ Trắng Mascot (sẽ tự nhảy đến bục hiện tại khi mở màn)
	_bunny_node = TextureRect.new()
	_bunny_node.name = "BunnyMascot"
	_bunny_node.anchor_left = 0.08
	_bunny_node.anchor_top = -0.78
	_bunny_node.anchor_right = 0.92
	_bunny_node.anchor_bottom = 0.28
	_bunny_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bunny_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_bunny_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/spr_bunny_mascot_stand.png"):
		_bunny_node.texture = load("res://assets/art/spr_bunny_mascot_stand.png")

	# --- 7. CÁC ĐIỂM TƯƠNG TÁC XÚC GIÁC BÍ MẬT (INTERACTIVE PROPS & EASTER EGGS) ---
	_setup_interactive_props(empty_style)

	# --- 8. DẢI NỐT NHẠC MA THUẬT BAY QUANH THỎ ---
	_notes_emitter = MusicalNotesLayer.new()
	_notes_emitter.name = "MusicalNotesLayer"
	_notes_emitter.set_anchors_preset(Control.PRESET_FULL_RECT)
	_notes_emitter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_notes_emitter)

	# --- 9. LỚP BÙNG NỔ BỤI SAO VÀNG CHÀO ĐÓN ---
	_burst_layer = StarlightBurst.new()
	_burst_layer.name = "LevelStarlightBurstLayer"
	_burst_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_burst_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_burst_layer)


func open_for_chapter(chapter: int) -> void:
	if _stage == null:
		_build()
	_chapter_index = chapter
	var chapter_names := [
		"Sáo Trúc Rừng Xanh",
		"Hồ Nước Kalimba",
		"Lâu Đài Chuông Gió"
	]
	var ch_name: String = chapter_names[clampi(chapter, 0, 2)]
	_title_label.text = "Chương %d: %s" % [chapter + 1, ch_name]

	var base_page := chapter * Chapters.pages_per_chapter()
	var current_page: int = GameState.page_index
	var max_page: int = GameState.max_page_reached

	# Xác định bục bài học hiện tại của bé trong chương này (0..4)
	var active_idx := clampi(current_page - base_page, 0, 4)
	if current_page < base_page:
		active_idx = 0
	elif current_page >= base_page + 5:
		active_idx = 4

	# Gắn Bạn Thỏ Trắng vào đúng bục hiện tại của bé!
	if _bunny_node != null:
		if _bunny_node.get_parent() != null:
			_bunny_node.get_parent().remove_child(_bunny_node)
		_level_buttons[active_idx].add_child(_bunny_node)

	for i in 5:
		var page := base_page + i
		var btn := _level_buttons[i]
		var is_unlocked := page <= max_page
		var is_completed := page < current_page
		var is_current := (i == active_idx)
		btn.disabled = not is_unlocked

		# Cụm 3 sao vàng cho bài đã hoàn thành
		var stars: Control = btn.get_node_or_null("PadStarsCluster")
		if stars != null:
			stars.visible = is_completed and not is_current

		# Tinh chỉnh vị trí số để không bị che
		var num_lbl: Label = btn.get_node_or_null("PadNumberLabel")
		if num_lbl != null:
			if i == 4 and _chest_node != null:
				num_lbl.offset_top = 18.0
				num_lbl.offset_bottom = 18.0
			else:
				num_lbl.offset_top = -14.0
				num_lbl.offset_bottom = -14.0

		for conn in btn.pressed.get_connections():
			btn.pressed.disconnect(conn.callable)
		btn.pressed.connect(_on_level_btn_pressed.bind(page, i))

		if i < _pad_indicators.size():
			_pad_indicators[i].update_state(page, current_page, is_unlocked, is_current)

	# Cập nhật tọa độ dải nốt nhạc bay quanh bạn Thỏ
	if _notes_emitter != null and active_idx < _level_buttons.size():
		var btn_center := _level_buttons[active_idx].get_global_rect().get_center()
		if btn_center != Vector2.ZERO:
			_notes_emitter.set_target_center(btn_center)

	_play_sfx("menu_open")
	open_overlay()
	_play_entry_animation(active_idx)


func _play_entry_animation(active_idx: int = 3) -> void:
	# 1. Toàn bộ sân khấu sách nổi nhún mở nhẹ nhàng
	if _stage != null:
		_stage.pivot_offset = _stage.size * 0.5
		_stage.scale = Vector2(0.95, 0.95)
		var stage_tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		stage_tw.tween_property(_stage, "scale", Vector2.ONE, 0.35)

	# 2. Hoạt cảnh 5 bục gỗ nảy tuần tự (Staggered Pop-up)
	for i in _level_buttons.size():
		var btn := _level_buttons[i]
		btn.scale = Vector2(0.2, 0.2)
		var delay := 0.05 + i * 0.06
		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_interval(delay)
		tw.tween_property(btn, "scale", Vector2.ONE, 0.32)

	# 3. Nút quay lại và hũ sao bung nảy đàn hồi
	if _back_btn != null:
		_back_btn.scale = Vector2(0.3, 0.3)
		var back_tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		back_tw.tween_property(_back_btn, "scale", Vector2.ONE, 0.36)

	if _star_jar_btn != null:
		_star_jar_btn.scale = Vector2(0.3, 0.3)
		var jar_tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		jar_tw.tween_property(_star_jar_btn, "scale", Vector2.ONE, 0.38)

	# 4. Bụi sao vàng bùng nổ chúc mừng ngay trên bục hiện tại của bé
	if _burst_layer != null and active_idx < _level_buttons.size():
		get_tree().create_timer(0.28).timeout.connect(func():
			if _burst_layer != null and active_idx < _level_buttons.size() and is_instance_valid(_level_buttons[active_idx]):
				var center := _level_buttons[active_idx].get_global_rect().get_center()
				_burst_layer.emit_burst(center, Color(1.0, 0.92, 0.45, 0.95), 24)
		)


func _on_level_btn_pressed(page: int, pad_index: int = 0) -> void:
	# Xúc giác nảy bục đàn hồi
	if pad_index < _level_buttons.size():
		var btn := _level_buttons[pad_index]
		var tw := create_tween()
		tw.tween_property(btn, "scale", Vector2(0.90, 0.90), 0.08).set_trans(Tween.TRANS_QUAD)
		tw.tween_property(btn, "scale", Vector2(1.08, 1.08), 0.12).set_trans(Tween.TRANS_BACK)
		tw.tween_property(btn, "scale", Vector2.ONE, 0.10)

	# Âm thanh phản hồi trực quan
	if pad_index == 3:
		_play_sfx("star_ting")
	elif pad_index == 4:
		_play_sfx("chapter_select")
	else:
		_play_sfx("wood_tap")

	# Hiệu ứng bụi sao khi chọn
	if _burst_layer != null and pad_index < _level_buttons.size():
		var center := _level_buttons[pad_index].get_global_rect().get_center()
		_burst_layer.emit_burst(center, Color(1.0, 0.96, 0.60, 0.95), 18)

	get_tree().create_timer(0.18).timeout.connect(func():
		close_overlay()
		level_selected.emit(page)
	)


func _on_back_pressed() -> void:
	_play_sfx("wood_tap")
	if _back_btn != null:
		var tw := create_tween()
		tw.tween_property(_back_btn, "scale", Vector2(0.85, 0.85), 0.08).set_trans(Tween.TRANS_QUAD)
		tw.tween_property(_back_btn, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK)
	close_overlay()
	back_requested.emit()


func _on_star_jar_pressed() -> void:
	_play_sfx("star_ting")
	if _star_jar_btn != null:
		var tw := create_tween()
		tw.tween_property(_star_jar_btn, "scale", Vector2(1.22, 1.22), 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(_star_jar_btn, "scale", Vector2.ONE, 0.14)
	if _burst_layer != null and _star_jar_btn != null:
		_burst_layer.emit_burst(_star_jar_btn.get_global_rect().get_center(), Color(1.0, 0.95, 0.5, 0.9), 16)


func _play_sfx(sfx_name: String) -> void:
	AudioDirector.play_sfx(sfx_name)


## Node hiển thị trạng thái và vẽ vòng sáng vàng trên bục gỗ
class LevelPadIndicator extends Control:
	var _idx: int = 0
	var _page: int = 0
	var _is_current: bool = false
	var _is_unlocked: bool = false
	var _time: float = 0.0

	func _init(idx: int) -> void:
		_idx = idx
		name = "LevelPadIndicator"

	func update_state(page: int, current_page: int, unlocked: bool, current: bool = false) -> void:
		_page = page
		_is_current = current
		_is_unlocked = unlocked
		queue_redraw()

	func _process(delta: float) -> void:
		if _is_current or _idx == 4:
			_time += delta
			queue_redraw()

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.42

		if not _is_unlocked:
			# Màn bị khóa: Lớp sương tối bảo vệ & ổ khóa nhỏ
			draw_circle(c, r, Color(0.05, 0.06, 0.08, 0.52))
			var gold := Color("#E8D9A0")
			var bw := r * 0.50
			var bh := r * 0.42
			draw_rect(Rect2(c.x - bw * 0.5, c.y - bh * 0.15, bw, bh), Color("#4A2E1B"), true)
			draw_rect(Rect2(c.x - bw * 0.5, c.y - bh * 0.15, bw, bh), gold, false, 2.0)
			draw_arc(Vector2(c.x, c.y - bh * 0.15), bw * 0.35, PI, TAU, 12, gold, 2.5, true)
		elif _is_current:
			# Vòng hào quang vàng ma thuật 2.5D xoay quanh bục có bạn Thỏ
			var pulse := 0.5 + 0.5 * sin(_time * 4.0)
			var outer_rx := r * (1.25 + 0.10 * pulse)
			var outer_ry := outer_rx * 0.60
			# Hào quang mờ
			draw_colored_polygon(_make_ellipse_points(c + Vector2(0, 10), outer_rx, outer_ry, 32), Color(1.0, 0.88, 0.35, 0.18 + 0.12 * pulse))
			# Vành sáng rực rỡ
			var inner_rx := r * (1.08 + 0.05 * pulse)
			var inner_ry := inner_rx * 0.60
			var ring_pts := _make_ellipse_points(c + Vector2(0, 10), inner_rx, inner_ry, 32)
			for p_idx in range(ring_pts.size() - 1):
				var p1: Vector2 = ring_pts[p_idx]
				var p2: Vector2 = ring_pts[p_idx + 1]
				var shimmer := 0.5 + 0.5 * sin(_time * 6.0 + float(p_idx) * 0.4)
				var ring_col := Color(1.0, 0.95, 0.65, 0.55 + 0.45 * shimmer)
				draw_line(p1, p2, ring_col, 3.5, true)
		elif _idx == 4:
			# Bục 5: Ánh sáng lấp lánh nhẹ quanh rương báu
			var pulse := 0.5 + 0.5 * sin(_time * 3.2)
			draw_arc(c + Vector2(0, 8), r * 1.05, 0, TAU, 24, Color(1.0, 0.92, 0.5, 0.20 + 0.15 * pulse), 2.0, true)

	func _make_ellipse_points(center: Vector2, rx: float, ry: float, segments: int) -> PackedVector2Array:
		var pts := PackedVector2Array()
		for i in range(segments + 1):
			var theta := float(i) / float(segments) * TAU
			pts.append(center + Vector2(cos(theta) * rx, sin(theta) * ry))
		return pts


## Lớp phát các nốt nhạc ngũ sắc bay lơ lửng quanh bạn Thỏ
class MusicalNotesLayer extends Control:
	var _notes: Array[Dictionary] = []
	var _timer: float = 0.0
	var _target_center: Vector2 = Vector2.ZERO

	func set_target_center(pos: Vector2) -> void:
		_target_center = pos

	func _process(delta: float) -> void:
		_timer += delta
		# Sinh nốt nhạc mới mỗi 0.35s
		if _timer >= 0.35 and _notes.size() < 12:
			_timer = 0.0
			_spawn_note()

		# Cập nhật vị trí nốt nhạc
		var alive: Array[Dictionary] = []
		for n in _notes:
			n.life += delta
			n.pos.y -= delta * n.speed
			n.pos.x += sin(n.life * 4.0 + n.seed_val) * (delta * 25.0)
			if n.life < n.max_life:
				alive.append(n)
		_notes = alive
		queue_redraw()

	func _spawn_note() -> void:
		var center_x := _target_center.x if _target_center != Vector2.ZERO else size.x * 0.65
		var center_y := _target_center.y if _target_center != Vector2.ZERO else size.y * 0.58
		var colors := [
			Color("#ED7A8E"), # Hồng sen
			Color("#4AE5D8"), # Cyan ma thuật
			Color("#FFE678"), # Vàng kim
			Color("#A472E8")  # Tím thần tiên
		]
		var glyphs := ["♪", "♫", "♬", "♩"]
		_notes.append({
			"pos": Vector2(center_x + randf_range(-40, 40), center_y + randf_range(-10, 10)),
			"speed": randf_range(35, 65),
			"life": 0.0,
			"max_life": randf_range(1.6, 2.4),
			"seed_val": randf() * TAU,
			"color": colors[randi() % colors.size()],
			"glyph": glyphs[randi() % glyphs.size()],
			"size": randf_range(18, 26)
		})

	func _draw() -> void:
		var font := ThemeDB.fallback_font
		for n in _notes:
			var alpha: float
			var progress: float = n.life / n.max_life
			if progress < 0.2:
				alpha = progress / 0.2
			elif progress > 0.7:
				alpha = (1.0 - progress) / 0.3
			else:
				alpha = 1.0
			var col: Color = n.color
			col.a = alpha * 0.85
			draw_string(font, n.pos, n.glyph, HORIZONTAL_ALIGNMENT_CENTER, -1, int(n.size), col)


## Lớp hiệu ứng bùng nổ bụi sao vàng khi chọn màn chơi
