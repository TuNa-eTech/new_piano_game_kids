class_name ChapterCard
extends Button
## Một thẻ chương trên bản đồ (khớp với vị trí thẻ 3D trên mock-chapter-map.jpeg).
##
## Khi mở khóa: có viền hào quang vàng nhấp nháy tinh tế khi chọn.
## Khi bị khóa: phủ lớp sương mờ bảo vệ và ổ khóa gỗ cổ kính.

var chapter: int = 0
var _face: Control


func setup(index: int) -> void:
	chapter = index
	focus_mode = Control.FOCUS_NONE

	_face = Control.new()
	_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_face.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_face)
	_face.draw.connect(_draw_face)

	refresh()


func refresh() -> void:
	disabled = not GameState.chapter_unlocked(chapter)
	if _face != null:
		_face.queue_redraw()


func _draw_face() -> void:
	var w := _face.size.x
	var h := _face.size.y
	var dim := disabled

	var r := Rect2(0, 0, w, h)
	if dim:
		# Lớp phủ sương mờ êm dịu có bo tròn góc khớp thẻ gỗ nổi 3D
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.06, 0.08, 0.10, 0.58)
		style.set_corner_radius_all(24)
		_face.draw_style_box(style, r)
		_draw_lock(Vector2(w * 0.5, h * 0.48), minf(w, h) * 0.16)
		return

	# Khi chương mở: vẽ viền hào quang vàng nhấp nháy bo tròn báo hiệu có thể chơi
	var active_style := StyleBoxFlat.new()
	active_style.bg_color = Color.TRANSPARENT
	active_style.border_color = Color(1.0, 0.88, 0.45, 0.65)
	active_style.set_border_width_all(3)
	active_style.set_corner_radius_all(24)
	_face.draw_style_box(active_style, r)

	# 5 chấm tiến độ nhỏ tinh tế ở cạnh dưới thẻ
	var pages := Chapters.pages_per_chapter()
	var first := Chapters.first_page_of(chapter)
	var dot_r := minf(w, h) * 0.038
	var dot_gap := dot_r * 3.2
	var dot_x := w * 0.5 - dot_gap * (pages - 1) * 0.5
	var dot_y := h * 0.88

	for i in pages:
		var page := first + i
		var centre := Vector2(dot_x + i * dot_gap, dot_y)
		if GameState.max_page_reached > page:
			_face.draw_circle(centre, dot_r, Color("#F5D77F"))
		elif GameState.page_index == page:
			_face.draw_circle(centre, dot_r * 1.25, Color("#FFFFFF"))
			_face.draw_circle(centre, dot_r * 0.7, Color("#F5D77F"))
		else:
			_face.draw_circle(centre, dot_r, Color(0.3, 0.35, 0.38, 0.6))


func _draw_lock(c: Vector2, r: float) -> void:
	var gold := Color("#E8D9A0")
	var dark_brass := Color("#6B4F2A")

	# Thân ổ khóa
	var bw := r * 1.5
	var bh := r * 1.3
	var body_rect := Rect2(c.x - bw * 0.5, c.y - bh * 0.25, bw, bh)
	_face.draw_rect(body_rect, dark_brass, true)
	_face.draw_rect(body_rect, gold, false, 3.0)

	# Quai khóa vòng cung
	var shackle_r := bw * 0.38
	var shackle_c := Vector2(c.x, c.y - bh * 0.25)
	_face.draw_arc(shackle_c, shackle_r, PI, TAU, 18, gold, 3.5, true)

	# Lỗ khóa tròn nhỏ
	_face.draw_circle(Vector2(c.x, c.y + bh * 0.22), r * 0.22, Color(0.1, 0.08, 0.05))
