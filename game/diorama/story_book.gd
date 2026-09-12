class_name StoryBook
extends Control
## Quyển Sách Tranh Tương Tác 10 Bài Hát (Interactive Living Storybook).
##
## Tích hợp:
## - Khung sách mở 2.5D bìa xanh ngọc mạ vàng.
## - Trang Trái: Banner bài hát, Cậu bé Phù thủy Leo, Thú cưng đồng hành, Khung thoại lời bài hát.
## - Trang Phải: Sân khấu Cây Đậu Thần Âm Nhạc và Rương Kho Báu.
## - Điều hướng lật trang chuyển bài (Prev / Next) và tự động lật khi hoàn thành.

const WizardLeo = preload("res://game/diorama/wizard_leo.gd")
const PetCompanion = preload("res://game/diorama/pet_companion.gd")
const MusicalBeanstalk = preload("res://game/diorama/musical_beanstalk.gd")

signal page_turn_requested(new_page: int)
signal chest_opened

var _current_page: int = 0
var _song_data: Dictionary = {}

# Node trang trái
var _book_bg: TextureRect
var _left_page: Control
var _title_banner: PanelContainer
var _title_label: Label
var _wizard_leo: WizardLeo
var _pet_companion: PetCompanion
var _speech_bubble: Panel
var _speech_label: Label

# Node trang phải
var _right_page: Control
var _beanstalk: MusicalBeanstalk

# Nút chuyển trang
var _btn_prev: Button
var _btn_next: Button

# Hiệu ứng lật trang
var _flip_layer: ColorRect
var _is_flipping: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	_setup_book_frame()
	_setup_left_page()
	_setup_right_page()
	_setup_navigation_buttons()
	resized.connect(_update_layout)
	_update_layout()

	# Khởi động với trang hiện tại của GameState
	var init_page := 0
	if GameState != null:
		init_page = GameState.page_index
	load_page(init_page)


func _setup_book_frame() -> void:
	_book_bg = TextureRect.new()
	_book_bg.name = "BookBackground"
	_book_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_book_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_book_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists("res://assets/art/storybook_open_frame_clean.png"):
		_book_bg.texture = load("res://assets/art/storybook_open_frame_clean.png")
	add_child(_book_bg)


func _setup_left_page() -> void:
	_left_page = Control.new()
	_left_page.name = "LeftPage"
	_left_page.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_left_page)

	# 1. Banner Tiêu Đề Bài Hát
	_title_banner = PanelContainer.new()
	_title_banner.name = "TitleBanner"
	_title_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var sb_banner := StyleBoxFlat.new()
	sb_banner.bg_color = Color("#4A2E1B", 0.88)
	sb_banner.border_width_left = 2
	sb_banner.border_width_top = 2
	sb_banner.border_width_right = 2
	sb_banner.border_width_bottom = 2
	sb_banner.border_color = Color("#F3C969", 0.95)
	sb_banner.set_corner_radius_all(12)
	sb_banner.shadow_color = Color(0, 0, 0, 0.3)
	sb_banner.shadow_size = 4
	sb_banner.shadow_offset = Vector2(0, 2)
	_title_banner.add_theme_stylebox_override("panel", sb_banner)

	_title_label = Label.new()
	_title_label.name = "TitleLabel"
	_title_label.text = "Trang 1/10: Cá Mập Con 🦈"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 14)
	_title_label.add_theme_color_override("font_color", Color("#FFF7E6"))
	_title_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_title_banner.add_child(_title_label)
	_left_page.add_child(_title_banner)

	# 2. Khung thoại dẫn truyện / lời bài hát
	_speech_bubble = Panel.new()
	_speech_bubble.name = "SpeechBubble"
	_speech_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var sb_bubble := StyleBoxFlat.new()
	sb_bubble.bg_color = Color(1.0, 0.98, 0.94, 0.94)
	sb_bubble.border_width_left = 2
	sb_bubble.border_width_top = 2
	sb_bubble.border_width_right = 2
	sb_bubble.border_width_bottom = 2
	sb_bubble.border_color = Color(0.32, 0.22, 0.15, 0.80)
	sb_bubble.set_corner_radius_all(12)
	sb_bubble.shadow_color = Color(0, 0, 0, 0.2)
	sb_bubble.shadow_size = 3
	sb_bubble.shadow_offset = Vector2(0, 2)
	_speech_bubble.add_theme_stylebox_override("panel", sb_bubble)

	_speech_label = Label.new()
	_speech_label.name = "SpeechLabel"
	_speech_label.text = "Cùng Leo đánh thức mầm cây thần nhé!"
	_speech_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_speech_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_speech_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_speech_label.add_theme_font_size_override("font_size", 13)
	_speech_label.add_theme_color_override("font_color", Color("#261405"))
	_speech_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_speech_label.offset_left = 6.0
	_speech_label.offset_top = 2.0
	_speech_label.offset_right = -6.0
	_speech_label.offset_bottom = -2.0
	_speech_bubble.add_child(_speech_label)
	_left_page.add_child(_speech_bubble)

	# 3. Cậu Bé Phù Thủy Leo
	_wizard_leo = WizardLeo.new()
	_wizard_leo.name = "WizardLeo"
	_left_page.add_child(_wizard_leo)

	# 4. Thú Cưng Đồng Hành
	_pet_companion = PetCompanion.new()
	_pet_companion.name = "PetCompanion"
	_left_page.add_child(_pet_companion)


func _setup_right_page() -> void:
	_right_page = Control.new()
	_right_page.name = "RightPage"
	_right_page.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_right_page)

	_beanstalk = MusicalBeanstalk.new()
	_beanstalk.name = "MusicalBeanstalk"
	_beanstalk.chest_clicked.connect(func():
		chest_opened.emit()
	)
	_right_page.add_child(_beanstalk)


func _setup_navigation_buttons() -> void:
	var sb_btn := StyleBoxFlat.new()
	sb_btn.bg_color = Color("#F3C969", 0.90)
	sb_btn.border_width_left = 2
	sb_btn.border_width_top = 2
	sb_btn.border_width_right = 2
	sb_btn.border_width_bottom = 2
	sb_btn.border_color = Color("#5B371E")
	sb_btn.set_corner_radius_all(20)
	sb_btn.shadow_color = Color(0, 0, 0, 0.3)
	sb_btn.shadow_size = 3
	sb_btn.shadow_offset = Vector2(0, 2)

	_btn_prev = Button.new()
	_btn_prev.name = "BtnPrevPage"
	_btn_prev.text = "◀"
	_btn_prev.custom_minimum_size = Vector2(44, 44)
	_btn_prev.add_theme_stylebox_override("normal", sb_btn)
	_btn_prev.add_theme_color_override("font_color", Color("#3D2211"))
	_btn_prev.add_theme_font_size_override("font_size", 18)
	_btn_prev.pressed.connect(prev_page)
	add_child(_btn_prev)

	_btn_next = Button.new()
	_btn_next.name = "BtnNextPage"
	_btn_next.text = "▶"
	_btn_next.custom_minimum_size = Vector2(44, 44)
	_btn_next.add_theme_stylebox_override("normal", sb_btn)
	_btn_next.add_theme_color_override("font_color", Color("#3D2211"))
	_btn_next.add_theme_font_size_override("font_size", 18)
	_btn_next.pressed.connect(next_page)
	add_child(_btn_next)


func _update_layout() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	if _book_bg != null:
		_book_bg.position = Vector2.ZERO
		_book_bg.size = size

	# Chia đôi quyển sách: Trang Trái và Trang Phải
	# Mỗi trang chiếm khoảng 43% chiều rộng, lùi vào mép bìa và tránh gáy sách giữa
	var margin_x := size.x * 0.065
	var margin_y := size.y * 0.075
	var page_w := size.x * 0.42
	var page_h := size.y * 0.85

	if _left_page != null:
		_left_page.position = Vector2(margin_x, margin_y)
		_left_page.size = Vector2(page_w, page_h)

		# Bố cục Trang Trái
		var banner_h := 30.0
		_title_banner.position = Vector2(10.0, 6.0)
		_title_banner.size = Vector2(page_w - 20.0, banner_h)

		var bubble_h := 44.0
		_speech_bubble.position = Vector2(10.0, banner_h + 8.0)
		_speech_bubble.size = Vector2(page_w - 20.0, bubble_h)

		# Leo ở nửa dưới bên trái
		var leo_w := page_w * 0.65
		var leo_h := page_h * 0.60
		_wizard_leo.size = Vector2(leo_w, leo_h)
		_wizard_leo.position = Vector2(6.0, page_h - leo_h - 6.0)

		# Thú cưng ở góc dưới bên phải trang trái
		var pet_size := minf(page_w * 0.38, 92.0)
		_pet_companion.size = Vector2(pet_size, pet_size)
		_pet_companion.position = Vector2(page_w - pet_size - 12.0, page_h - pet_size - 18.0)

	if _right_page != null:
		var right_x := size.x * 0.515
		_right_page.position = Vector2(right_x, margin_y)
		_right_page.size = Vector2(page_w, page_h)

		if _beanstalk != null:
			_beanstalk.position = Vector2.ZERO
			_beanstalk.size = Vector2(page_w, page_h)

	# Nút lật trang ở hai bên bìa sách
	if _btn_prev != null and _btn_next != null:
		var btn_y := (size.y - 44.0) * 0.5
		_btn_prev.position = Vector2(6.0, btn_y)
		_btn_next.position = Vector2(size.x - 50.0, btn_y)


## Nạp dữ liệu trang bài hát
func load_page(page_idx: int) -> void:
	var total_songs: int = Songbook.count()
	if total_songs == 0:
		return
	_current_page = clampi(page_idx, 0, total_songs - 1)
	_song_data = Songbook.get_song(_current_page)

	# Cập nhật banner tiêu đề
	var title: String = _song_data.get("vietnamese_title", _song_data.get("title", ""))
	var emoji: String = _song_data.get("pet_emoji", "✨")
	_title_label.text = "Trang %d/%d: %s %s" % [_current_page + 1, total_songs, title, emoji]

	# Cập nhật lời dẫn truyện ban đầu
	var intro: String = _song_data.get("story_intro", "Cùng Leo và thú cưng đánh thức cây đậu thần nhé!")
	set_speech_text(intro)

	# Cập nhật BPM và trạng thái cho Cậu bé Leo
	var bpm: float = _song_data.get("bpm", 80.0)
	if _wizard_leo != null:
		_wizard_leo.reset_to_piano()
		_wizard_leo.set_bpm(bpm)

	# Cập nhật Bạn Thú Cưng đồng hành
	var pet_id: String = _song_data.get("pet_id", "shark")
	if _pet_companion != null:
		_pet_companion.load_pet(pet_id, bpm)

	# Reset cây đậu thần
	if _beanstalk != null:
		_beanstalk.reset_page()

	# Cập nhật hiển thị nút lật trang
	_btn_prev.visible = (_current_page > 0)
	_btn_next.visible = (_current_page < total_songs - 1)


## Đặt nội dung khung thoại (lời bài hát / gợi ý)
func set_speech_text(text: String) -> void:
	if _speech_label != null:
		_speech_label.text = text


## Khi bé gõ nốt đàn: Đồng bộ hoạt cảnh Leo, Thú cưng và Cây đậu thần
func on_note_struck(note_index: int) -> void:
	if _wizard_leo != null:
		_wizard_leo.play_cast()
	if _pet_companion != null:
		_pet_companion.play_react()
	if _beanstalk != null:
		_beanstalk.bloom_leaf(note_index)


## Cây hát: Lá nốt nhạc phát sáng
func sing_leaf(note_index: int) -> void:
	if _beanstalk != null:
		_beanstalk.sing_leaf(note_index)


## Hoàn thành bài hát: Leo nhảy múa, thú cưng reo hò, rương báu mở bung
func celebrate_completion() -> void:
	if _wizard_leo != null:
		_wizard_leo.play_celebrate()
	if _pet_companion != null:
		_pet_companion.play_celebrate()
	if _beanstalk != null:
		_beanstalk.open_chest_celebration()
	set_speech_text("HOAN HÔ BÉ GIỎI QUÁ! ✨\nRƯƠNG BÁU ĐÃ MỞ RỒI! 🎉")


## Lật sang trang tiếp theo
func next_page() -> void:
	if _is_flipping or _current_page >= Songbook.count() - 1:
		return
	_flip_to_page(_current_page + 1)


## Lật về trang trước
func prev_page() -> void:
	if _is_flipping or _current_page <= 0:
		return
	_flip_to_page(_current_page - 1)


func _flip_to_page(target_page: int) -> void:
	_is_flipping = true
	AudioDirector.play_sfx("soft_boing")

	# Hiệu ứng thu phóng lật trang mượt mà
	var tw := create_tween().bind_node(self)
	tw.tween_property(_left_page, "modulate:a", 0.0, 0.18)
	tw.parallel().tween_property(_right_page, "modulate:a", 0.0, 0.18)
	tw.finished.connect(func():
		load_page(target_page)
		if GameState != null:
			GameState.set_page(target_page)
		page_turn_requested.emit(target_page)

		var tw_in := create_tween().bind_node(self)
		tw_in.tween_property(_left_page, "modulate:a", 1.0, 0.22)
		tw_in.parallel().tween_property(_right_page, "modulate:a", 1.0, 0.22)
		tw_in.finished.connect(func():
			_is_flipping = false
		)
	)


## Lấy toạ độ lá nốt nhạc trên trang phải để hướng dải lụa ma thuật
func get_leaf_global_position(note_index: int) -> Vector2:
	if _beanstalk != null:
		return _beanstalk.global_position + _beanstalk.get_leaf_position(note_index)
	return global_position + size * 0.5
