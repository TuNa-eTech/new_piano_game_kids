class_name ChapterCard
extends Button
## Một thẻ chương trên bản đồ (Quyết định 04: "nơi bé tự chọn lại chương yêu thích").
##
## KHÔNG CÓ CHỮ trên thẻ. Người chơi 3–5 tuổi chưa đọc được, nên danh tính chương
## là MÀU và SỐ CHẤM TO đếm được (1, 2, 3 chấm), còn tiến độ là 5 chấm nhỏ =
## 5 trang. Đúng luật "Show, Don't Tell" của tài liệu game giáo dục.
##
## Vẽ bằng một Control con nối vào tín hiệu draw, không ghi đè _draw() của Button:
## Button tự vẽ stylebox trong notification vẽ của nó, chồng thêm _draw() lên là
## trông cậy vào thứ tự không được bảo đảm. Cùng cách piano_keyboard.gd vẽ phím đen.

var chapter: int = 0

var _face: Control


func setup(index: int) -> void:
	chapter = index
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(160, 200)

	_face = Control.new()
	_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_face.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_face)
	_face.draw.connect(_draw_face)

	_apply_style()
	refresh()


func _apply_style() -> void:
	var accent := Chapters.color_of(chapter)

	var normal := StyleBoxFlat.new()
	normal.bg_color = accent.darkened(0.45)
	normal.set_corner_radius_all(28)
	normal.set_border_width_all(4)
	normal.border_color = accent

	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = accent.darkened(0.2)

	var locked := normal.duplicate() as StyleBoxFlat
	locked.bg_color = Color(0.13, 0.14, 0.15)
	locked.border_color = Color(0.28, 0.29, 0.3)

	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", normal)
	add_theme_stylebox_override("focus", normal)
	add_theme_stylebox_override("pressed", pressed)
	add_theme_stylebox_override("disabled", locked)


## Gọi lại mỗi lần bản đồ mở. Chỉ đọc trạng thái, không giữ bản sao nào.
func refresh() -> void:
	disabled = not GameState.chapter_unlocked(chapter)
	modulate.a = 0.45 if disabled else 1.0
	if _face != null:
		_face.queue_redraw()


static var _card_tex: Texture2D


func _draw_face() -> void:
	if _card_tex == null and ResourceLoader.exists("res://assets/art/card_chapter.png"):
		_card_tex = load("res://assets/art/card_chapter.png")

	var w := _face.size.x
	var h := _face.size.y
	var accent := Chapters.color_of(chapter)
	var dim := disabled

	if _card_tex != null:
		var card_color := Color(0.45, 0.45, 0.45) if dim else accent.lerp(Color.WHITE, 0.25)
		_face.draw_texture_rect(_card_tex, Rect2(Vector2.ZERO, _face.size), false, card_color)

	# Danh tính chương: 1, 2 hoặc 3 chấm to — đếm được, không cần đọc.
	var marks := chapter + 1
	var mark_r := minf(w, h) * 0.085
	var spacing := mark_r * 2.6
	var start_x := w * 0.5 - spacing * (marks - 1) * 0.5
	var mark_y := h * 0.38
	for i in marks:
		_face.draw_circle(
			Vector2(start_x + i * spacing, mark_y), mark_r,
			Color(0.42, 0.43, 0.45) if dim else accent
		)

	if dim:
		_draw_lock(Vector2(w * 0.5, h * 0.68), minf(w, h) * 0.11)
		return

	# Tiến độ chương: 5 chấm nhỏ = 5 trang, chấm đã qua thì đầy.
	var pages := Chapters.pages_per_chapter()
	var first := Chapters.first_page_of(chapter)
	var dot_r := minf(w, h) * 0.035
	var dot_gap := dot_r * 3.0
	var dot_x := w * 0.5 - dot_gap * (pages - 1) * 0.5
	var dot_y := h * 0.72
	for i in pages:
		var page := first + i
		var centre := Vector2(dot_x + i * dot_gap, dot_y)
		if GameState.max_page_reached > page:
			_face.draw_circle(centre, dot_r, Color("#E8D9A0"))
		elif GameState.page_index == page:
			_face.draw_circle(centre, dot_r, accent.lightened(0.3))
		else:
			_face.draw_arc(centre, dot_r, 0.0, TAU, 20, Color(1, 1, 1, 0.3), 2.0, true)


static var _lock_tex: Texture2D


func _draw_lock(centre: Vector2, r: float) -> void:
	if _lock_tex == null and ResourceLoader.exists("res://assets/art/ui_lock.png"):
		_lock_tex = load("res://assets/art/ui_lock.png")

	if _lock_tex != null:
		var lock_size := r * 3.0
		var rect := Rect2(centre.x - lock_size * 0.5, centre.y - lock_size * 0.5, lock_size, lock_size)
		_face.draw_texture_rect(_lock_tex, rect, false, Color(1, 1, 1, 0.75))
	else:
		var body := Color(0.55, 0.56, 0.58)
		_face.draw_rect(
			Rect2(centre - Vector2(r, r * 0.1), Vector2(r * 2.0, r * 1.5)), body
		)
		_face.draw_arc(
			centre - Vector2(0.0, r * 0.1), r * 0.66, PI, TAU, 20, body, r * 0.42, true
		)
