extends Control
## Thanh nhạc cụ góc trái của ảnh mock = tiến độ chương: 5 chấm cho 5 trang.
##
## Thay cho nhãn chữ "Chương 1 · trang 2/5". Trẻ 4 tuổi đọc được 5 chấm chứ
## không đọc được câu đó — đúng luật "Show, Don't Tell" của tài liệu game
## giáo dục, và đúng ranh giới "v1 không lời" của Phạm vi v1.
##
## Vẽ lại CHỈ KHI trạng thái đổi, không đụng gì trong _process: cập nhật nhãn
## tĩnh mỗi khung hình là hao pin trên máy di động mà không đổi lấy gì.

const ICON_SIZE := 28.0
const ICON_GAP := 38.0

@onready var _done_color := Color("#E8D9A0")
var _instrument_textures: Array[Texture2D] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_instrument_textures = [
		load("res://assets/art/progress_violin.png"),
		load("res://assets/art/progress_flute.png"),
		load("res://assets/art/progress_drum.png"),
		load("res://assets/art/progress_trumpet.png"),
		load("res://assets/art/progress_harp.png")
	]
	custom_minimum_size = Vector2(
		ICON_GAP * Chapters.pages_per_chapter(), ICON_SIZE + 12.0
	)
	GameState.page_changed.connect(_on_page_changed)


func _on_page_changed(_page_index: int) -> void:
	queue_redraw()


func _draw() -> void:
	var chapter := GameState.chapter_index()
	var accent := Chapters.color_of(chapter)
	var current := GameState.page_in_chapter()
	var y := (size.y - ICON_SIZE) * 0.5
	var total_w := Chapters.pages_per_chapter() * ICON_GAP

	var pill_rect := Rect2(-10, y - 6, total_w + 14, ICON_SIZE + 12)
	# Drop shadow
	draw_rect(Rect2(-10, y - 3, total_w + 14, ICON_SIZE + 12), Color(0.0, 0.0, 0.0, 0.35), true)
	# Carved dark oak wood plaque
	draw_rect(pill_rect, Color(0.16, 0.10, 0.06, 0.92), true)
	# Gilded brass border
	draw_rect(pill_rect, Color(0.78, 0.62, 0.28, 0.85), false, 2.0)
	# Inner golden bead line
	draw_rect(pill_rect.grow(-3.0), Color(0.95, 0.82, 0.45, 0.30), false, 1.0)

	for i in Chapters.pages_per_chapter():
		var x := i * ICON_GAP
		var rect := Rect2(x, y, ICON_SIZE, ICON_SIZE)
		var tex := _instrument_textures[i] if i < _instrument_textures.size() else null

		if tex != null:
			if i < current:
				draw_texture_rect(tex, rect, false, _done_color)
			elif i == current:
				# Highlight active page with glowing circle behind and accent color
				draw_circle(rect.get_center(), ICON_SIZE * 0.65, Color(accent.r, accent.g, accent.b, 0.35))
				draw_arc(rect.get_center(), ICON_SIZE * 0.65, 0.0, TAU, 24, accent, 2.5, true)
				draw_texture_rect(tex, rect, false, Color.WHITE)
			else:
				draw_texture_rect(tex, rect, false, Color(1, 1, 1, 0.45))
		else:
			# Fallback if texture missing
			var centre := rect.get_center()
			if i < current:
				draw_circle(centre, 9.0, _done_color)
			elif i == current:
				draw_circle(centre, 9.0, accent)
			else:
				draw_arc(centre, 9.0, 0.0, TAU, 24, Color(1, 1, 1, 0.45), 2.5, true)

