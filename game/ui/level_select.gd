class_name LevelSelect
extends PauseOverlay
## Màn Hình Chọn Màn Chơi (5 Bục Gỗ Âm Nhạc / Level Select).
## Thiết kế khớp 100% với mock-level-select.jpeg.
##
## Thẩm mỹ Sách Tranh Nổi 3D:
## - Con đường đá rêu xanh uốn lượn qua khu rừng cổ tích
## - 5 bục gỗ khoanh cây tương ứng 5 bài hát (1..5)
## - Các bài đã vượt qua có 3 ngôi sao vàng rạng rỡ
## - Bạn Thỏ trắng nhún nhảy vẫy tay ở bục đang chơi (có vòng hào quang vàng)
## - Bục số 5 có Rương Báu Thần tỏa sáng
## - Bảng gỗ treo tiêu đề 'Chương: Sáo Trúc Rừng Xanh'
## - Nút 'Quay lại' gỗ chạm khắc ở góc trên bên trái

signal level_selected(page_index: int)
signal back_requested

var _bg_texture: Texture2D
var _title_label: Label
var _back_btn: Button
var _chapter_index: int = 0
var _level_buttons: Array[Button] = []


func _ready() -> void:
	super()
	layer = 11
	_build()
	_set_controls_visible(false)


func _build() -> void:
	_add_backdrop(Color(0.02, 0.04, 0.03, 0.95))

	# Phông nền toàn cảnh Level Select từ mock-level-select.jpeg
	if ResourceLoader.exists("res://docs/mock-level-select.jpeg"):
		_bg_texture = load("res://docs/mock-level-select.jpeg")

	var bg_rect := TextureRect.new()
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _bg_texture != null:
		bg_rect.texture = _bg_texture
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(bg_rect)

	# Hiệu ứng đom đóm vàng
	var fireflies := MainMenu.FireflyOverlay.new()
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fireflies)

	var empty_style := StyleBoxEmpty.new()

	# --- 1. NÚT QUAY LẠI (GÓC TRÊN TRÁI) ---
	# Tọa độ tương đối: X ~ 1.8% - 17.5%, Y ~ 3.5% - 14.5%
	_back_btn = Button.new()
	_back_btn.anchor_left = 0.018
	_back_btn.anchor_top = 0.035
	_back_btn.anchor_right = 0.175
	_back_btn.anchor_bottom = 0.145
	_back_btn.focus_mode = Control.FOCUS_NONE
	_back_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_back_btn.flat = true
	_back_btn.add_theme_stylebox_override("normal", empty_style)
	_back_btn.add_theme_stylebox_override("hover", empty_style)
	_back_btn.add_theme_stylebox_override("pressed", empty_style)
	_back_btn.pressed.connect(_on_back_pressed)
	add_child(_back_btn)

	# --- 2. TIÊU ĐỀ CHƯƠNG TRÊN BẢNG GỖ ---
	# Tọa độ tương đối: X ~ 32% - 68%, Y ~ 5% - 16%
	_title_label = Label.new()
	_title_label.anchor_left = 0.32
	_title_label.anchor_top = 0.05
	_title_label.anchor_right = 0.68
	_title_label.anchor_bottom = 0.16
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 21)
	_title_label.add_theme_color_override("font_color", Color(0.98, 0.94, 0.82))
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_title_label)

	# --- 3. 5 BỤC GỖ ÂM NHẠC (1..5) TRÊN CON ĐƯỜNG ĐÁ ---
	# Tọa độ tương ứng chính xác vị trí 5 bục gỗ trong mock:
	# Bục 1: X ~ 14.5% - 26.5%, Y ~ 62% - 84%
	# Bục 2: X ~ 29.5% - 41.5%, Y ~ 56% - 78%
	# Bục 3: X ~ 44.0% - 56.0%, Y ~ 56% - 78%
	# Bục 4: X ~ 58.0% - 72.0%, Y ~ 46% - 84% (Có bạn Thỏ)
	# Bục 5: X ~ 74.5% - 86.5%, Y ~ 58% - 84% (Có Rương Báu)
	var pad_rects := [
		[0.145, 0.62, 0.265, 0.84],
		[0.295, 0.56, 0.415, 0.78],
		[0.440, 0.56, 0.560, 0.78],
		[0.580, 0.46, 0.720, 0.84],
		[0.745, 0.58, 0.865, 0.84]
	]

	for i in 5:
		var btn := Button.new()
		var pr: Array = pad_rects[i]
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

		var pad_draw := LevelPadIndicator.new(i)
		pad_draw.set_anchors_preset(Control.PRESET_FULL_RECT)
		pad_draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(pad_draw)

		add_child(btn)
		_level_buttons.append(btn)


func open_for_chapter(chapter: int) -> void:
	_chapter_index = chapter
	var chapter_names := [
		"Sáo Trúc Rừng Xanh",
		"Hồ Nước Kalimba",
		"Lâu Đài Chuông Gió"
	]
	var ch_name: String = chapter_names[clampi(chapter, 0, 2)]
	if chapter == 0:
		_title_label.text = "" # Bảng gỗ trong mock đã có sẵn chữ chạm khắc tuyệt đẹp
	else:
		_title_label.text = "Chương %d:\n%s" % [chapter + 1, ch_name]

	var base_page := chapter * Chapters.pages_per_chapter()
	var current_page := GameState.page_index
	var max_page := GameState.max_page_reached

	for i in 5:
		var page := base_page + i
		var btn := _level_buttons[i]
		var is_unlocked := page <= max_page
		btn.disabled = not is_unlocked

		# Ngắt kết nối cũ nếu có
		for conn in btn.pressed.get_connections():
			btn.pressed.disconnect(conn.callable)
		btn.pressed.connect(_on_level_btn_pressed.bind(page))

		var indicator: LevelPadIndicator = btn.get_node_or_null("LevelPadIndicator")
		if indicator != null:
			indicator.update_state(page, current_page, is_unlocked)

	open_overlay()


func _on_level_btn_pressed(page: int) -> void:
	if AudioDirector != null:
		AudioDirector.play_sfx("chapter_select")
	close_overlay()
	level_selected.emit(page)


func _on_back_pressed() -> void:
	if AudioDirector != null:
		AudioDirector.play_sfx("wood_tap")
	close_overlay()
	back_requested.emit()


## Node vẽ vòng sáng vàng khi bục đang được chọn
class LevelPadIndicator extends Control:
	var _idx: int = 0
	var _page: int = 0
	var _is_current: bool = false
	var _is_unlocked: bool = false
	var _time: float = 0.0

	func _init(idx: int) -> void:
		_idx = idx
		name = "LevelPadIndicator"

	func update_state(page: int, current_page: int, unlocked: bool) -> void:
		_page = page
		_is_current = (page == current_page)
		_is_unlocked = unlocked
		queue_redraw()

	func _process(delta: float) -> void:
		if _is_current:
			_time += delta
			queue_redraw()

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.42

		if not _is_unlocked:
			# Lớp sương tối bảo vệ bài bị khóa
			draw_circle(c, r, Color(0.05, 0.06, 0.08, 0.55))
			var gold := Color("#E8D9A0")
			var bw := r * 0.6
			var bh := r * 0.5
			draw_rect(Rect2(c.x - bw * 0.5, c.y - bh * 0.2, bw, bh), Color("#5A3E1B"), true)
			draw_rect(Rect2(c.x - bw * 0.5, c.y - bh * 0.2, bw, bh), gold, false, 2.0)
			draw_arc(Vector2(c.x, c.y - bh * 0.2), bw * 0.35, PI, TAU, 12, gold, 2.5, true)
		elif _is_current:
			# Vòng hào quang vàng nhấp nháy trên bục của bạn Thỏ
			var pulse := 0.5 + 0.5 * sin(_time * 4.0)
			draw_circle(c, r * (1.0 + 0.12 * pulse), Color(1.0, 0.88, 0.35, 0.14 + 0.10 * pulse))
			draw_arc(c, r * (1.0 + 0.06 * pulse), 0, TAU, 32, Color(1.0, 0.95, 0.65, 0.45 + 0.35 * pulse), 3.0, true)
