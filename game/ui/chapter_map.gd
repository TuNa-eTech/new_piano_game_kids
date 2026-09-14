class_name ChapterMap
extends PauseOverlay

const StarlightBurst = preload("res://game/fx/starlight_burst.gd")
## Bản đồ chương — lớp phủ mở bằng nút Menu giữ 2 giây hoặc từ Bìa Sách.
## Thiết kế khớp 100% với mock-chapter-map.jpeg.
##
## Thẩm mỹ Sách Tranh Nổi 2.5D Diorama & Animation System:
## - Entry pop-up: Toàn bộ sân khấu sách nổi vươn mở, 3 thẻ chương nhô lên tuần tự đàn hồi
## - Idle animation: Các thẻ chương lơ lửng bồng bềnh, vệt sáng vàng kim quét qua thẻ mở, đom đóm trôi dạt
## - Haptic tactile micro-interactions: Lọ sao nảy bung bụi sao vàng, nút quay lại nén nhả mộc mạc
## - Audio & Particle reaction: Chạm thẻ mở bung suối sao kèm tiếng sáo/kalimba, chạm thẻ khóa rung lắc kim loại

signal chapter_selected(chapter: int)
signal main_menu_requested

var _cards: Array[ChapterCard] = []
var _bg_texture: Texture2D
var _stage: Control
var _back_btn: Button
var _star_jar_btn: Button
var _menu_btn: Button
var _burst_layer: StarlightBurst
var _time: float = 0.0


func _ready() -> void:
	super()
	layer = 10
	_build()
	_set_controls_visible(false)


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta

	# Hoạt ảnh nhịp thở tự nhiên cho Lọ sao góc phải (Toy bottle float)
	if _star_jar_btn != null and is_instance_valid(_star_jar_btn):
		_star_jar_btn.rotation = sin(_time * 2.2) * 0.035

	# Hoạt ảnh nảy nhẹ mời gọi cho Nút quay lại (Back Button breath)
	if _back_btn != null and is_instance_valid(_back_btn):
		var breathe := 1.0 + 0.025 * sin(_time * 2.6)
		_back_btn.scale = Vector2(breathe, breathe)


func _build() -> void:
	_add_backdrop(Color(0.03, 0.05, 0.04, 0.94))

	# Khung sân khấu chính để diễn hoạt ảnh phóng to khi mở sách (Pop-up Book Stage)
	_stage = Control.new()
	_stage.name = "DioramaStage"
	_stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	_stage.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_stage)

	# Phông nền toàn cảnh Bản đồ Chương từ mock-chapter-map.jpeg
	# ⚠️ PHÔNG NỀN TẠM — chưa có asset thật.
	# Asset chính thức mà docs/art-pipeline-chapter-map-2.5d.md đặt tên là
	# `tex_bg_chapter_forest.png` và CHƯA ĐƯỢC DỰNG. Trong lúc chờ, màn này dùng bản
	# tạm trong assets/placeholder/ (chính là tấm concept, nhưng nằm đúng chỗ của
	# một tài nguyên chạy thật — trước đây nó nằm trong docs/, khiến thư mục tài
	# liệu >10 MB bị kéo cả vào gói phát hành).
	# Khi asset thật về: đổi đường dẫn rồi xoá dòng placeholder.
	if ResourceLoader.exists("res://assets/art/tex_bg_chapter_forest.png"):
		_bg_texture = load("res://assets/art/tex_bg_chapter_forest.png")
	elif ResourceLoader.exists("res://assets/placeholder/art/placeholder_bg_chapter_map.jpg"):
		_bg_texture = load("res://assets/placeholder/art/placeholder_bg_chapter_map.jpg")

	var bg_rect := TextureRect.new()
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _bg_texture != null:
		bg_rect.texture = _bg_texture
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	_stage.add_child(bg_rect)

	# Lớp hiệu ứng đom đóm vàng rừng đêm
	var fireflies := MainMenu.FireflyOverlay.new()
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(fireflies)

	var empty_style := StyleBoxEmpty.new()

	# --- 1. NÚT QUAY LẠI (GÓC TRÊN BÊN TRÁI) ---
	# Tọa độ tương đối khớp nút tròn mũi tên gỗ: X ~ 1.8% - 9.8%, Y ~ 3.5% - 17.5%
	_back_btn = Button.new()
	_back_btn.name = "BtnBack"
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
	_back_btn.item_rect_changed.connect(func(): _back_btn.pivot_offset = _back_btn.size * 0.5)
	_back_btn.pressed.connect(_on_back_pressed)
	_stage.add_child(_back_btn)

	# --- 2. NÚT ĐIỀU HƯỚNG BỔ TRỢ (ẨN ĐỂ BẢO TỒN THẨM MỸ BANNER) ---
	_menu_btn = Button.new()
	_menu_btn.visible = false
	_menu_btn.focus_mode = Control.FOCUS_NONE
	_menu_btn.pressed.connect(func(): main_menu_requested.emit())
	add_child(_menu_btn)

	# --- 3. BA THẺ CHƯƠNG NỔI 2.5D (INTERACTIVE POP-UP CARDS) ---
	var card_rects := [
		[0.152, 0.225, 0.370, 0.735],
		[0.388, 0.225, 0.606, 0.735],
		[0.624, 0.225, 0.842, 0.735]
	]

	for i in Chapters.count():
		var card := ChapterCard.new()
		var cr: Array = card_rects[i]
		card.anchor_left = cr[0]
		card.anchor_top = cr[1]
		card.anchor_right = cr[2]
		card.anchor_bottom = cr[3]
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.flat = true
		card.add_theme_stylebox_override("normal", empty_style)
		card.add_theme_stylebox_override("hover", empty_style)
		card.add_theme_stylebox_override("pressed", empty_style)
		card.add_theme_stylebox_override("disabled", empty_style)
		_stage.add_child(card)

		card.setup(i)
		card.pressed.connect(_on_card_pressed.bind(i))
		_cards.append(card)

	# --- 4. LỌ SAO THỦY TINH TƯƠNG TÁC (GÓC TRÊN BÊN PHẢI) ---
	# Tọa độ tương đối: X ~ 90.0% - 98.0%, Y ~ 3.5% - 17.5%
	_star_jar_btn = Button.new()
	_star_jar_btn.name = "StarJarBtn"
	_star_jar_btn.anchor_left = 0.900
	_star_jar_btn.anchor_top = 0.035
	_star_jar_btn.anchor_right = 0.980
	_star_jar_btn.anchor_bottom = 0.175
	_star_jar_btn.focus_mode = Control.FOCUS_NONE
	_star_jar_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_star_jar_btn.flat = true
	_star_jar_btn.add_theme_stylebox_override("normal", empty_style)
	_star_jar_btn.add_theme_stylebox_override("hover", empty_style)
	_star_jar_btn.add_theme_stylebox_override("pressed", empty_style)
	_star_jar_btn.item_rect_changed.connect(func(): _star_jar_btn.pivot_offset = _star_jar_btn.size * 0.5)
	_star_jar_btn.pressed.connect(_on_star_jar_pressed)
	_stage.add_child(_star_jar_btn)

	# --- 5. LỚP BÙNG NỔ BỤI SAO VÀNG (STARLIGHT BURST VFX) ---
	_burst_layer = StarlightBurst.new()
	_burst_layer.name = "StarlightBurstLayer"
	_burst_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_burst_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_burst_layer)


func open_map() -> void:
	for card in _cards:
		card.refresh()
	AudioDirector.play_sfx("menu_open")
	open_overlay()
	_play_entry_animation()


func _play_entry_animation() -> void:
	# 1. Toàn bộ sân khấu sách nổi nhún mở nhẹ nhàng
	if _stage != null:
		_stage.pivot_offset = _stage.size * 0.5
		_stage.scale = Vector2(0.95, 0.95)
		var stage_tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		stage_tw.tween_property(_stage, "scale", Vector2.ONE, 0.35)

	# 2. Hoạt cảnh 3 thẻ chương nhô lên tuần tự từ trang sách (Staggered Pop-up)
	for i in _cards.size():
		_cards[i].pop_up_intro(0.06 + i * 0.08)

	# 3. Nút quay lại và Lọ sao bung nảy đàn hồi
	if _back_btn != null:
		_back_btn.scale = Vector2(0.3, 0.3)
		var back_tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		back_tw.tween_property(_back_btn, "scale", Vector2.ONE, 0.38)

	if _star_jar_btn != null:
		_star_jar_btn.scale = Vector2(0.3, 0.3)
		var jar_tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		jar_tw.tween_property(_star_jar_btn, "scale", Vector2.ONE, 0.40)

	# 4. Hiệu ứng bùng nổ bụi sao chào đón ngay trên Thẻ Chương 1 (Thẻ đang mở)
	if _burst_layer != null and _cards.size() > 0:
		get_tree().create_timer(0.20).timeout.connect(func():
			if _burst_layer != null and _cards.size() > 0 and is_instance_valid(_cards[0]):
				var center := _cards[0].get_global_rect().get_center()
				_burst_layer.emit_burst(center, Color(1.0, 0.92, 0.50, 0.95), 22)
		)


func close_map() -> void:
	close_overlay()


func _on_back_pressed() -> void:
	AudioDirector.play_sfx("menu_open")
	if _back_btn != null:
		var tw := create_tween()
		tw.tween_property(_back_btn, "scale", Vector2(0.85, 0.85), 0.08).set_trans(Tween.TRANS_QUAD)
		tw.tween_property(_back_btn, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK)
	close_map()


func _on_star_jar_pressed() -> void:
	AudioDirector.play_sfx("star_ting")
	if _star_jar_btn != null:
		var tw := create_tween()
		tw.tween_property(_star_jar_btn, "scale", Vector2(1.22, 1.22), 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(_star_jar_btn, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_SINE)

	if _burst_layer != null and _star_jar_btn != null:
		var center := _star_jar_btn.get_global_rect().get_center()
		_burst_layer.emit_burst(center, Color(1.0, 0.95, 0.55, 0.98), 18)
		_burst_layer.emit_burst(center + Vector2(-8, 6), Color(1.0, 0.80, 0.30, 0.85), 10)


func _on_card_pressed(chapter: int) -> void:
	if chapter >= 0 and chapter < _cards.size():
		_cards[chapter].play_tap_feedback()

	var is_unlocked := GameState.chapter_unlocked(chapter)

	if not is_unlocked:
		AudioDirector.play_sfx("padlock_rattle")
		if _burst_layer != null and chapter < _cards.size():
			var center := _cards[chapter].get_global_rect().get_center()
			_burst_layer.emit_burst(center, Color(0.85, 0.45, 0.20, 0.8), 8)
		return

	AudioDirector.play_sfx("chapter_select")
	AudioDirector.play_instrument_note(chapter, 3, 0.0)

	if _burst_layer != null and chapter < _cards.size():
		var center := _cards[chapter].get_global_rect().get_center()
		_burst_layer.emit_burst(center, Color(1.0, 0.92, 0.45, 0.95), 26)
		_burst_layer.emit_burst(center, Color(1.0, 0.78, 0.25, 0.85), 16)

	GameState.select_chapter(chapter)
	chapter_selected.emit(chapter)
	close_map()


## Lớp phát hiệu ứng bùng nổ bụi sao vàng khi tương tác (Starlight Burst)
