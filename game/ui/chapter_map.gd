class_name ChapterMap
extends PauseOverlay
## Bản đồ chương — lớp phủ mở bằng nút Menu giữ 2 giây hoặc từ Bìa Sách.
## Thiết kế khớp 100% với mock-chapter-map.jpeg.
##
## Thẩm mỹ Sách Tranh Nổi 3D:
## - Cuốn sách mở rộng trên bàn gỗ rừng ma thuật
## - 3 thẻ chương 3D nổi bật:
##     • Chương 1: Sáo Trúc Rừng Xanh (đang mở)
##     • Chương 2: Hồ Nước Kalimba (nước biếc, hoa sen)
##     • Chương 3: Lâu Đài Chuông Gió (đai da khóa đồng cổ)
## - Bảng gỗ uốn lượn 'Chapter Selection Map' ở trên cùng
## - Nút Quay Lại (Mũi tên gỗ tròn) góc trên bên trái
## - Nút Bìa Sách & Góc Phụ Huynh tích hợp tinh tế
## - Lọ sao thủy tinh phát sáng góc trên bên phải

signal chapter_selected(chapter: int)
signal main_menu_requested
signal parent_gate_requested

var _cards: Array[ChapterCard] = []
var _bg_texture: Texture2D
var _back_btn: Button
var _menu_btn: Button
var _parent_btn: Button


func _ready() -> void:
	super()
	layer = 10
	_build()
	_set_controls_visible(false)


func _build() -> void:
	_add_backdrop(Color(0.03, 0.05, 0.04, 0.94))

	# Phông nền toàn cảnh Bản đồ Chương từ mock-chapter-map.jpeg
	if ResourceLoader.exists("res://docs/mock-chapter-map.jpeg"):
		_bg_texture = load("res://docs/mock-chapter-map.jpeg")

	var bg_rect := TextureRect.new()
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _bg_texture != null:
		bg_rect.texture = _bg_texture
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(bg_rect)

	# Lớp hiệu ứng đom đóm vàng
	var fireflies := MainMenu.FireflyOverlay.new()
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fireflies)

	var empty_style := StyleBoxEmpty.new()

	# --- 1. NÚT QUAY LẠI (GÓC TRÊN BÊN TRÁI) ---
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
	_back_btn.pressed.connect(close_map)
	add_child(_back_btn)

	# --- 2. NÚT ĐIỀU HƯỚNG BỔ SỢ (BÌA SÁCH & PHỤ HUYNH) ---
	# Đặt gọn gàng ở 2 góc phụ để bé và phụ huynh dễ dàng chuyển màn
	var nav_bar := HBoxContainer.new()
	nav_bar.anchor_left = 0.12
	nav_bar.anchor_top = 0.04
	nav_bar.anchor_right = 0.88
	nav_bar.anchor_bottom = 0.14
	nav_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(nav_bar)

	_menu_btn = Button.new()
	_menu_btn.text = "📖 Bìa Sách"
	_menu_btn.focus_mode = Control.FOCUS_NONE
	_menu_btn.custom_minimum_size = Vector2(130, 44)
	var wood_btn_style := StyleBoxFlat.new()
	wood_btn_style.bg_color = Color(0.22, 0.14, 0.08, 0.90)
	wood_btn_style.border_color = Color(0.65, 0.52, 0.32)
	wood_btn_style.set_border_width_all(2)
	wood_btn_style.set_corner_radius_all(20)
	wood_btn_style.content_margin_left = 14
	wood_btn_style.content_margin_right = 14
	_menu_btn.add_theme_stylebox_override("normal", wood_btn_style)
	_menu_btn.add_theme_stylebox_override("hover", wood_btn_style)
	_menu_btn.add_theme_stylebox_override("pressed", wood_btn_style)
	_menu_btn.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78))
	_menu_btn.add_theme_font_size_override("font_size", 14)
	_menu_btn.pressed.connect(func(): main_menu_requested.emit())
	nav_bar.add_child(_menu_btn)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nav_bar.add_child(spacer)

	_parent_btn = Button.new()
	_parent_btn.text = "🌙 Phụ Huynh"
	_parent_btn.focus_mode = Control.FOCUS_NONE
	_parent_btn.custom_minimum_size = Vector2(130, 44)
	_parent_btn.add_theme_stylebox_override("normal", wood_btn_style)
	_parent_btn.add_theme_stylebox_override("hover", wood_btn_style)
	_parent_btn.add_theme_stylebox_override("pressed", wood_btn_style)
	_parent_btn.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78))
	_parent_btn.add_theme_font_size_override("font_size", 14)
	_parent_btn.pressed.connect(func(): parent_gate_requested.emit())
	nav_bar.add_child(_parent_btn)

	# --- 3. BA THẺ CHƯƠNG (INTERACTIVE CARDS) ---
	# Tọa độ khớp hoàn hảo viền thẻ gỗ nổi 3D trên trang sách:
	# Thẻ 1: X ~ 15.2% - 37.0%, Y ~ 22.5% - 73.5%
	# Thẻ 2: X ~ 38.8% - 60.6%, Y ~ 22.5% - 73.5%
	# Thẻ 3: X ~ 62.4% - 84.2%, Y ~ 22.5% - 73.5%
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
		add_child(card)

		card.setup(i)
		card.pressed.connect(_on_card_pressed.bind(i))
		_cards.append(card)


func open_map() -> void:
	for card in _cards:
		card.refresh()
	AudioDirector.play_sfx("menu_open")
	open_overlay()


func close_map() -> void:
	close_overlay()


func _on_card_pressed(chapter: int) -> void:
	if not GameState.chapter_unlocked(chapter):
		return
	AudioDirector.play_sfx("chapter_select")
	AudioDirector.play_instrument_note(chapter, 3, 0.0)
	GameState.select_chapter(chapter)
	chapter_selected.emit(chapter)
	close_map()
