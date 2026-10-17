class_name StoryBook
extends Control
## Quyển Sách Tranh Tương Tác 10 Bài Hát (Interactive Living Storybook).
##
## Tích hợp:
## - Khung sách mở 2.5D bìa xanh ngọc mạ vàng.
## - Trang Trái: Banner bài hát, Cậu bé Phù thủy Leo, Thú cưng đồng hành, Khung thoại lời bài hát.
## - Trang Phải: Sân khấu Cây Đậu Thần Âm Nhạc và Rương Kho Báu.
## - Điều hướng lật trang chuyển bài (Prev / Next) và tự động lật khi hoàn thành.

const PageCurl = preload("res://game/diorama/page_curl.gd")
const WizardLeo = preload("res://game/diorama/wizard_leo.gd")
const PetCompanion = preload("res://game/diorama/pet_companion.gd")
const MusicalBeanstalk = preload("res://game/diorama/musical_beanstalk.gd")

signal page_turn_requested(new_page: int)
signal page_covered
signal page_half_flipped
signal flip_completed
signal chest_opened
signal leaf_tapped(note_index: int)

var _current_page: int = 0
var _song_data: Dictionary[String, Variant] = {}

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
var _btn_prev: TextureButton
var _btn_next: TextureButton

# Hiệu ứng lật trang
var _page_curl: PageCurl
var _dip_tween: Tween
var _is_flipping: bool = false
var _freeplay: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	_setup_book_frame()
	_setup_left_page()
	_setup_right_page()
	_setup_page_curl()
	_setup_navigation_buttons()
	resized.connect(_update_layout)
	_update_layout()

	# Khởi động với trang hiện tại của GameState. KHÔNG nối thẳng page_changed
	# vào load_page: DioramaStage là nơi duy nhất quyết định lúc nào thay nội
	# dung, vì nó phải đợi nếp giấy che kín trang mới được đổi.
	load_page(GameState.page_index if GameState != null else 0)


func _setup_book_frame() -> void:
	_book_bg = TextureRect.new()
	_book_bg.name = "BookBackground"
	_book_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_book_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_book_bg.stretch_mode = TextureRect.STRETCH_SCALE
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
	_title_label.text = "Page 1/10: Baby Shark 🦈"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.clip_text = true
	_title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	# Fix UI 7 nhóm: chữ 14px chìm trên điện thoại — nâng lên 18px cho phụ huynh đọc.
	_title_label.add_theme_font_size_override("font_size", 18)
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
	# P0-3: chữ 16px quá nhỏ, đứng xa không đọc được — lên 22px.
	_speech_label.add_theme_font_size_override("font_size", 22)
	_speech_label.add_theme_color_override("font_color", Color("#261405"))
	_speech_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_speech_label.offset_left = 6.0
	_speech_label.offset_top = 2.0
	_speech_label.offset_right = -6.0
	_speech_label.offset_bottom = -2.0
	_speech_bubble.add_child(_speech_label)
	_left_page.add_child(_speech_bubble)

	# 3. Cậu Bé Phù Thủy Leo (Ngồi chơi đàn piano mini trên toàn bộ nửa dưới trang trái)
	_wizard_leo = WizardLeo.new()
	_wizard_leo.name = "WizardLeo"
	_left_page.add_child(_wizard_leo)


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
	_beanstalk.leaf_tapped.connect(func(note_idx: int):
		leaf_tapped.emit(note_idx)
	)
	_right_page.add_child(_beanstalk)

	# 4. Thú Cưng Đồng Hành trên Trang Phải cùng Cây Đậu Thần
	_pet_companion = PetCompanion.new()
	_pet_companion.name = "PetCompanion"
	_right_page.add_child(_pet_companion)


## Tờ giấy cuộn nằm ngay trong quyển sách, phủ đúng một nửa trang. Trước đây nó
## là con của BookSpread — node bị ẩn từ _setup_story_book() — nên hoạt ảnh vẫn
## chạy, âm thanh vẫn kêu, mà không một khung hình nào được vẽ ra.
func _setup_page_curl() -> void:
	_page_curl = PageCurl.new()
	_page_curl.name = "PageCurl"
	_page_curl.sheet_covered.connect(func(): page_covered.emit())
	_page_curl.page_half_flipped.connect(func(): page_half_flipped.emit())
	_page_curl.flip_completed.connect(_on_curl_finished)
	add_child(_page_curl)


func _setup_navigation_buttons() -> void:
	var tex_back: Texture2D = null
	if ResourceLoader.exists("res://assets/art/ui_arrow_back.png"):
		tex_back = load("res://assets/art/ui_arrow_back.png")

	var tex_next: Texture2D = null
	if ResourceLoader.exists("res://assets/art/ui_arrow_next.png"):
		tex_next = load("res://assets/art/ui_arrow_next.png")

	_btn_prev = TextureButton.new()
	_btn_prev.name = "BtnPrevPage"
	_btn_prev.texture_normal = tex_back
	_btn_prev.ignore_texture_size = true
	_btn_prev.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	_btn_prev.custom_minimum_size = Vector2(88, 88)
	_btn_prev.pivot_offset = Vector2(44, 44)
	_btn_prev.button_down.connect(func():
		_btn_prev.scale = Vector2(0.90, 0.90)
		AudioDirector.play_sfx("wood_tap")
	)
	_btn_prev.button_up.connect(func(): _btn_prev.scale = Vector2.ONE)
	_btn_prev.pressed.connect(prev_page)
	add_child(_btn_prev)

	_btn_next = TextureButton.new()
	_btn_next.name = "BtnNextPage"
	_btn_next.texture_normal = tex_next
	_btn_next.ignore_texture_size = true
	_btn_next.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	_btn_next.custom_minimum_size = Vector2(88, 88)
	_btn_next.pivot_offset = Vector2(44, 44)
	_btn_next.button_down.connect(func():
		_btn_next.scale = Vector2(0.90, 0.90)
		AudioDirector.play_sfx("wood_tap")
	)
	_btn_next.button_up.connect(func(): _btn_next.scale = Vector2.ONE)
	_btn_next.pressed.connect(next_page)
	add_child(_btn_next)


func _update_layout() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	if _book_bg != null:
		_book_bg.position = Vector2.ZERO
		_book_bg.size = size

	# Chia đôi quyển sách: Trang Trái và Trang Phải khớp với tranh minh họa trong khung sách
	var margin_x := size.x * 0.08
	var margin_y := size.y * 0.06
	var page_w := size.x * 0.405
	var page_h := size.y * 0.88

	if _left_page != null:
		_left_page.position = Vector2(margin_x, margin_y)
		_left_page.size = Vector2(page_w, page_h)

		# Bố cục Trang Trái
		var banner_h := 26.0
		_title_banner.position = Vector2(16.0, 8.0)
		_title_banner.size = Vector2(page_w - 32.0, banner_h)

		# P0-3: bubble 30px + font 16 không đọc được từ xa — lên 62px để
		# chứa 2 dòng lời Việt 18-21px, Leo lùi xuống tương ứng.
		var bubble_h := 62.0
		_speech_bubble.position = Vector2(16.0, 8.0 + banner_h + 4.0)
		_speech_bubble.size = Vector2(page_w - 32.0, bubble_h)

		# Leo ở nửa dưới trang trái: Đứng/ngồi oai vệ, thoải mái bên cây đàn mini
		# Kích thước to hơn và đặt sát mép đáy trang sách gần bàn phím đàn piano lớn
		var leo_s := 285.0
		_wizard_leo.size = Vector2(leo_s, leo_s)
		_wizard_leo.position = Vector2((page_w - leo_s) * 0.5 + 20.0, page_h - leo_s + 18.0)

	if _right_page != null:
		var right_x := size.x * 0.515
		_right_page.position = Vector2(right_x, margin_y)
		_right_page.size = Vector2(page_w, page_h)

		if _beanstalk != null:
			_beanstalk.position = Vector2.ZERO
			_beanstalk.size = Vector2(page_w, page_h)

		# Thú cưng đồng hành trên trang phải: Cùng cao độ mặt đất với Leo, hướng mặt về phía Cây Đậu Thần và Leo
		if _pet_companion != null:
			var pet_size := clampf(page_w * 0.24, 72.0, 84.0)
			_pet_companion.size = Vector2(pet_size, pet_size)
			_pet_companion.position = Vector2(page_w - pet_size - 28.0, page_h - pet_size + 14.0)
			_pet_companion.set_facing_left(true)

	# Nút lật trang gỗ 2.5D cỡ 88x88 chuẩn ngón tay trẻ em nằm gọn ở rìa bìa sách
	if _btn_prev != null and _btn_next != null:
		var btn_s := 88.0
		var btn_y := (size.y - btn_s) * 0.5
		_btn_prev.size = Vector2(btn_s, btn_s)
		_btn_prev.position = Vector2(4.0, btn_y)
		_btn_next.size = Vector2(btn_s, btn_s)
		_btn_next.position = Vector2(size.x - btn_s - 4.0, btn_y)


## Cập nhật giao diện khi vào/thoát chế độ Chơi Tự Do
func set_freeplay_mode(enabled: bool) -> void:
	if _title_banner != null:
		_title_banner.visible = not enabled
	if _speech_bubble != null:
		_speech_bubble.visible = not enabled
	_freeplay = enabled
	_update_nav_buttons()


## Nạp dữ liệu trang bài hát
func load_page(page_idx: int) -> void:
	var total_songs: int = Songbook.count()
	if total_songs == 0:
		return
	_current_page = clampi(page_idx, 0, total_songs - 1)
	_song_data.assign(Songbook.get_song(_current_page))

	# Cập nhật banner tiêu đề tiếng Việt đồng nhất với các màn hình khác
	var en_title: String = _song_data.get("title", "")
	var vi_title: String = _song_data.get("vietnamese_title", en_title)
	var emoji: String = _song_data.get("pet_emoji", "✨")
	_title_label.text = "%s Bài %d/%d: %s" % [emoji, _current_page + 1, total_songs, vi_title]

	# Cập nhật lời bài hát mở đầu
	var phrases: Array = _song_data.get("phrases", [])
	if not phrases.is_empty():
		var first_phrase: Dictionary = phrases[0]
		var lyrics: String = first_phrase.get("lyrics", "")
		if not lyrics.is_empty():
			set_speech_text("♫ %s ♫" % lyrics)
		else:
			set_speech_text("♪ %s ♪" % vi_title)
	else:
		set_speech_text("♪ %s · %s ♪" % [vi_title, en_title])

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

	_update_nav_buttons()


## Một chỗ duy nhất quyết định hai nút lật có hiện hay không: Chơi Tự Do thì giấu
## hẳn, hết biên trang thì giấu nút tương ứng, đang lật dở thì khoá để bé bấm dồn
## không xếp hàng được hai ba lượt lật chồng lên nhau.
func _update_nav_buttons() -> void:
	if _btn_prev == null or _btn_next == null:
		return
	var total: int = Songbook.count()
	_btn_prev.visible = not _freeplay and _current_page > 0
	_btn_next.visible = not _freeplay and _current_page < total - 1
	_btn_prev.disabled = _is_flipping
	_btn_next.disabled = _is_flipping


## Đặt nội dung khung thoại (lời bài hát / gợi ý) kèm co giãn cỡ chữ để không cắt chữ
func set_speech_text(text: String) -> void:
	if _speech_label != null:
		var fs := 18 if text.length() > 34 else 21
		_speech_label.add_theme_font_size_override("font_size", fs)
		_speech_label.text = text


## Khi bé gõ đúng nốt đàn (hoặc Chơi Tự Do): Đồng bộ hoạt cảnh Leo, Thú cưng và Cây đậu thần
func on_note_struck(note_index: int) -> void:
	if _wizard_leo != null:
		_wizard_leo.play_note(note_index)
	if _pet_companion != null:
		_pet_companion.play_react()
	if _beanstalk != null:
		_beanstalk.bloom_leaf(note_index)


## Khi bé gõ nhầm nốt trong lúc chờ (WAITING): Leo và thú cưng vẫn hưởng ứng vui vẻ,
## nhưng KHÔNG nở lá sai để cây chỉ nở đúng chuỗi nốt của câu nhạc.
func on_wrong_note_struck(note_index: int) -> void:
	if _wizard_leo != null:
		_wizard_leo.play_note(note_index)
	if _pet_companion != null:
		_pet_companion.play_react()


## Khép lại các lá đã nở để chuẩn bị cho câu nhạc tiếp theo trong bài hát nhiều câu.
func reset_leaves() -> void:
	if _beanstalk != null:
		_beanstalk.reset_leaves()


## Cây hát: Lá nốt nhạc phát sáng và Leo gõ đàn mẫu
func sing_leaf(note_index: int) -> void:
	if _beanstalk != null:
		_beanstalk.sing_leaf(note_index)
	if _wizard_leo != null:
		_wizard_leo.play_note(note_index)


## Hoàn thành bài hát: Leo nhảy múa, thú cưng reo hò, rương báu mở bung
func celebrate_completion() -> void:
	if _wizard_leo != null:
		_wizard_leo.play_celebrate()
	if _pet_companion != null:
		_pet_companion.play_celebrate()
	if _beanstalk != null:
		_beanstalk.open_chest_celebration()
	set_speech_text("HOAN HÔ BÉ GIỎI QUÁ! ✨\nRƯƠNG BÁU ĐÃ MỞ RỒI! 🎉")


## Thao tác vung tay nghệ sĩ biểu diễn của Leo
func play_leo_flourish() -> void:
	if _wizard_leo != null:
		_wizard_leo.play_flourish()
	if _pet_companion != null:
		_pet_companion.play_react()


## Đổi biểu cảm cho Leo
func set_leo_expression(expr: int, duration: float = 1.2) -> void:
	if _wizard_leo != null:
		_wizard_leo.set_expression(expr, duration)


func current_page() -> int:
	return _current_page


## Dành cho công cụ chụp hình và test soi tiến độ hoạt ảnh.
func get_page_curl() -> PageCurl:
	return _page_curl


func is_flipping() -> bool:
	return _is_flipping


## Lật sang trang tiếp theo — chỉ NÊU YÊU CẦU.
## Quyển sách không tự đổi trang: DioramaStage cầm trịch thứ tự "cuộn giấy trước,
## đổi dữ liệu sau", còn GameState mới là nơi giữ số trang thật.
func next_page() -> void:
	if _is_flipping or _current_page >= Songbook.count() - 1:
		return
	page_turn_requested.emit(_current_page + 1)


## Lật về trang trước
func prev_page() -> void:
	if _is_flipping or _current_page <= 0:
		return
	page_turn_requested.emit(_current_page - 1)


## Chạy hoạt ảnh cuộn giấy trên đúng nửa trang sẽ bị lật.
## forward = true lật tới (cuộn trang phải), false lật lui (cuộn trang trái).
func play_flip(forward: bool, duration: float = 0.95) -> void:
	if _page_curl == null:
		return
	_is_flipping = true
	_update_nav_buttons()
	_place_curl(forward)
	_dip_opposite_page(forward, duration)
	_page_curl.flip_page(duration, forward)


## Đặt tờ giấy cuộn trùng khít nửa trang đang lật. Lấy thẳng hình chữ nhật của
## node trang, không chép lại con số bố cục — bố cục đổi thì nếp cuộn đổi theo.
func _place_curl(forward: bool) -> void:
	var page: Control = _right_page if forward else _left_page
	if page == null or _page_curl == null:
		return
	_page_curl.position = page.position
	_page_curl.size = page.size


## Nếp giấy chỉ che được nửa trang đang lật, nhưng đổi bài thì NỬA KIA cũng đổi
## theo (tên bài, lời hát, Leo, thú cưng). Kéo nửa kia chìm vào bóng tối đúng lúc
## nội dung bị tráo rồi thả sáng lại, để không có cú nháy "chữ đổi trước, giấy
## cuộn sau".
##
## Tối màu chứ KHÔNG hạ alpha: hạ alpha thì trang thủng ra, thấy cả hình in trên
## bìa sách nằm dưới — nhìn như trang giấy biến mất. Tối màu đọc ra đúng thứ mà
## mắt chờ đợi: bóng của tờ giấy đang dựng lên hắt sang nửa trang bên kia.
const DIP_SHADOW := Color(0.34, 0.30, 0.27, 1.0)


func _dip_opposite_page(forward: bool, duration: float) -> void:
	var page: Control = _left_page if forward else _right_page
	if page == null:
		return
	if _dip_tween != null and _dip_tween.is_valid():
		_dip_tween.kill()
	page.modulate = Color.WHITE
	# Chạm đáy đúng lúc PageCurl báo sheet_covered (~21% thời lượng, đã tính cả
	# đường cong gia tốc), rồi mới thả sáng lại.
	_dip_tween = create_tween().bind_node(self)
	_dip_tween.tween_property(page, "modulate", DIP_SHADOW, duration * 0.21) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_dip_tween.tween_property(page, "modulate", Color.WHITE, duration * 0.36) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(duration * 0.06)


func _on_curl_finished() -> void:
	_is_flipping = false
	if _left_page != null:
		_left_page.modulate = Color.WHITE
	if _right_page != null:
		_right_page.modulate = Color.WHITE
	_update_nav_buttons()
	flip_completed.emit()


## Lấy toạ độ lá nốt nhạc trên trang phải để hướng dải lụa ma thuật
func get_leaf_global_position(note_index: int) -> Vector2:
	if _beanstalk != null:
		return _beanstalk.global_position + _beanstalk.get_leaf_position(note_index)
	return global_position + size * 0.5
