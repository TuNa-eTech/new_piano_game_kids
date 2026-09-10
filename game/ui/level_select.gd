class_name LevelSelect
extends PauseOverlay
## Màn Hình Chọn Màn Chơi (5 Bục Gỗ Âm Nhạc / Level Select).
##
## Hiển thị 5 bài hát của chương được chọn dọc theo con đường đá rêu xanh:
## - Màn 1..5 tương ứng 5 trang của chương
## - Màn đã hoàn thành có các hạt sao vàng
## - Màn hiện tại phát sáng và có bạn thú vẫy tay
## - Nút 'Quay lại' để trở về Bản Đồ Chương

signal level_selected(page_index: int)
signal back_requested

var _title_label: Label
var _pad_container: HBoxContainer
var _chapter_index: int = 0


func _ready() -> void:
	super()
	layer = 11
	_build()
	_set_controls_visible(false)


func _build() -> void:
	_add_backdrop(Color(0.03, 0.06, 0.05, 0.94))

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(940, 480)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.09, 0.06, 0.98) # Gỗ sồi mộc mạc
	panel_style.border_color = Color(0.78, 0.62, 0.28, 0.95) # Viền mạ vàng
	panel_style.set_border_width_all(4)
	panel_style.set_corner_radius_all(28)
	panel_style.shadow_color = Color(0, 0, 0, 0.5)
	panel_style.shadow_size = 20
	panel_style.content_margin_left = 28
	panel_style.content_margin_right = 28
	panel_style.content_margin_top = 24
	panel_style.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 24)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(hbox)

	# Cột trái: Bạn Thỏ dẫn đường vẫy tay
	if ResourceLoader.exists("res://assets/art/rabbit_guide.png"):
		var rabbit_rect := TextureRect.new()
		rabbit_rect.texture = load("res://assets/art/rabbit_guide.png")
		rabbit_rect.custom_minimum_size = Vector2(170, 380)
		rabbit_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rabbit_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(rabbit_rect)

	# Cột phải: Hàng tiêu đề + 5 bục gỗ âm nhạc
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 24)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	# Hàng tiêu đề + nút Quay lại
	var top_row := HBoxContainer.new()
	top_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(top_row)

	var back_btn := Button.new()
	back_btn.text = "◀  Quay lại"
	back_btn.custom_minimum_size = Vector2(130, 42)
	back_btn.focus_mode = Control.FOCUS_NONE
	var back_style := StyleBoxFlat.new()
	back_style.bg_color = Color(0.25, 0.16, 0.10, 0.9)
	back_style.border_color = Color(0.55, 0.42, 0.22)
	back_style.set_border_width_all(2)
	back_style.set_corner_radius_all(18)
	back_btn.add_theme_stylebox_override("normal", back_style)
	back_btn.add_theme_stylebox_override("hover", back_style)
	back_btn.add_theme_stylebox_override("pressed", back_style)
	back_btn.add_theme_color_override("font_color", Color(0.95, 0.92, 0.85))
	back_btn.pressed.connect(_on_back_pressed)
	top_row.add_child(back_btn)

	_title_label = Label.new()
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 22)
	_title_label.add_theme_color_override("font_color", Color(0.96, 0.86, 0.58))
	top_row.add_child(_title_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(130, 0)
	top_row.add_child(spacer)

	# 5 bục gỗ âm nhạc (Level 1 -> 5)
	_pad_container = HBoxContainer.new()
	_pad_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_pad_container.add_theme_constant_override("separation", 18)
	vbox.add_child(_pad_container)


func open_for_chapter(chapter: int) -> void:
	_chapter_index = chapter
	var chapter_names := [
		"Sáo Trúc Rừng Xanh",
		"Hồ Nước Kalimba",
		"Lâu Đài Chuông Gió"
	]
	var ch_name: String = chapter_names[clampi(chapter, 0, 2)]
	_title_label.text = "Chương %d: %s" % [chapter + 1, ch_name]

	for child in _pad_container.get_children():
		child.queue_free()

	var base_page := chapter * Chapters.pages_per_chapter()
	var current_page := GameState.page_index
	var max_page := GameState.max_page_reached

	var pad_tex: Texture2D = null
	if ResourceLoader.exists("res://assets/art/stepping_stone_pad.png"):
		pad_tex = load("res://assets/art/stepping_stone_pad.png")

	for i in Chapters.pages_per_chapter():
		var page := base_page + i
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(120, 160)
		btn.focus_mode = Control.FOCUS_NONE

		var is_unlocked := page <= max_page
		var is_current := page == current_page

		var style := StyleBoxFlat.new()
		style.set_corner_radius_all(20)
		style.set_border_width_all(3)

		if is_current:
			style.bg_color = Color(0.78, 0.62, 0.28, 0.95)
			style.border_color = Color(1.0, 0.92, 0.65)
			style.shadow_color = Color(0.9, 0.7, 0.1, 0.4)
			style.shadow_size = 12
			btn.add_theme_color_override("font_color", Color(0.15, 0.10, 0.05))
		elif is_unlocked:
			style.bg_color = Color(0.28, 0.18, 0.11, 0.92)
			style.border_color = Color(0.55, 0.45, 0.25)
			btn.add_theme_color_override("font_color", Color(0.95, 0.92, 0.85))
		else:
			style.bg_color = Color(0.15, 0.14, 0.13, 0.8)
			style.border_color = Color(0.3, 0.3, 0.3)
			btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)

		if pad_tex != null:
			btn.icon = pad_tex
			btn.expand_icon = true
			btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

		var lvl_title := Melodies.level_name(page)
		btn.text = "%s\nBài %d\n%s" % [
			lvl_title,
			i + 1,
			"★★★" if (page < current_page) else ("★ Đang chơi" if is_current else ("Rương 🎁" if i == 4 else "🔒"))
		]
		btn.add_theme_font_size_override("font_size", 13)
		btn.disabled = not is_unlocked

		btn.pressed.connect(_on_level_btn_pressed.bind(page))
		_pad_container.add_child(btn)

	open_overlay()


func _on_level_btn_pressed(page: int) -> void:
	if AudioDirector != null:
		AudioDirector.play_sfx("chapter_select")
	close_overlay()
	level_selected.emit(page)


func _on_back_pressed() -> void:
	close_overlay()
	back_requested.emit()
