class_name ChapterMap
extends PauseOverlay
## Bản đồ chương — lớp phủ mở bằng nút Menu giữ 2 giây.
##
## LỆCH ẢNH MOCK CÓ CHỦ Ý: ảnh mock có hai nút MENU và LEVELS. Nhưng nếu LEVELS
## chạm phát là mở được thì khoá nhẹ của MENU thành vô nghĩa — bé vẫn rời trang
## tự do, đúng thứ khoá nhẹ sinh ra để chặn. Nên gộp còn một nút Menu (giữ 2
## giây), và bản đồ chứa luôn phần chọn chương.
##
## Quyền sở hữu get_tree().paused nằm ở lớp cha PauseOverlay, không ở đây — xem
## ghi chú trong game/ui/pause_overlay.gd.

signal chapter_selected(chapter: int)

var _cards: Array[ChapterCard] = []
var _root: Control


func _ready() -> void:
	super()
	layer = 10
	_build()


func _build() -> void:
	_add_backdrop(Color(0.04, 0.06, 0.05, 0.92))

	if ResourceLoader.exists("res://assets/art/frame_book.png"):
		var frame := NinePatchRect.new()
		frame.texture = load("res://assets/art/frame_book.png")
		frame.set_anchors_preset(Control.PRESET_FULL_RECT)
		frame.patch_margin_left = 64
		frame.patch_margin_top = 64
		frame.patch_margin_right = 64
		frame.patch_margin_bottom = 64
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(frame)

	_root = MarginContainer.new()

	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		_root.add_theme_constant_override("margin_" + side, 56)
	add_child(_root)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 40)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	_root.add_child(column)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 36)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(row)

	for i in Chapters.count():
		# AspectRatioContainer khoá tỉ lệ thẻ thay vì tự tính kích thước —
		# trong Container thì mọi position/size gán tay đều bị queue_sort() ghi đè.
		var slot := AspectRatioContainer.new()
		slot.ratio = 0.78
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
		row.add_child(slot)

		var card := ChapterCard.new()
		slot.add_child(card)
		card.setup(i)
		card.pressed.connect(_on_card_pressed.bind(i))
		_cards.append(card)

	var footer := CenterContainer.new()
	column.add_child(footer)
	footer.add_child(_make_close_button())


func _make_close_button() -> Button:
	var close := Button.new()
	close.focus_mode = Control.FOCUS_NONE
	# Apple HIG 44 pt ×2. Đây là ĐƯỜNG VỀ DUY NHẤT của bé nên nó phải to.
	close.custom_minimum_size = Vector2(180, 96)

	var box := StyleBoxFlat.new()
	box.bg_color = Color("#3F9455").darkened(0.35)
	box.set_corner_radius_all(48)
	close.add_theme_stylebox_override("normal", box)
	close.add_theme_stylebox_override("hover", box)
	close.add_theme_stylebox_override("focus", box)
	var down := box.duplicate() as StyleBoxFlat
	down.bg_color = Color("#3F9455")
	close.add_theme_stylebox_override("pressed", down)

	var face := Control.new()
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face.set_anchors_preset(Control.PRESET_FULL_RECT)
	close.add_child(face)
	face.draw.connect(_draw_close_arrow.bind(face))

	close.pressed.connect(close_map)
	return close


## Mũi tên quay lui — không chữ, và nó nằm TRONG lớp phủ này chứ không phải trên
## HUD. HUD bị dừng khi bản đồ mở, nên một nút đóng đặt nhầm chỗ sẽ chết cứng và
## bé kẹt trong bản đồ không có đường ra. Với app trẻ em đó là lỗi chí mạng.
var _arrow_back_tex: Texture2D


func _draw_close_arrow(face: Control) -> void:
	if _arrow_back_tex == null and ResourceLoader.exists("res://assets/art/ui_arrow_back.png"):
		_arrow_back_tex = load("res://assets/art/ui_arrow_back.png")

	var c := face.size * 0.5
	var r := minf(face.size.x, face.size.y) * 0.28
	var ink := Color("#E8D9A0")

	if _arrow_back_tex != null:
		var arrow_size := r * 2.4
		var rect := Rect2(c.x - arrow_size * 0.5, c.y - arrow_size * 0.5, arrow_size, arrow_size)
		face.draw_texture_rect(_arrow_back_tex, rect, false, ink)
	else:
		face.draw_line(Vector2(c.x - r, c.y), Vector2(c.x + r, c.y), ink, 8.0, true)
		face.draw_line(
			Vector2(c.x - r, c.y), Vector2(c.x - r * 0.35, c.y - r * 0.6), ink, 8.0, true
		)
		face.draw_line(
			Vector2(c.x - r, c.y), Vector2(c.x - r * 0.35, c.y + r * 0.6), ink, 8.0, true
		)


# ---------------------------------------------------------------- điều khiển --

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
	GameState.select_chapter(chapter)
	chapter_selected.emit(chapter)
	close_map()
