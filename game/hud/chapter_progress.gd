extends Control
## Thanh nhạc cụ góc trái của ảnh mock = tiến độ chương: 5 chấm cho 5 trang.
##
## Thay cho nhãn chữ "Chương 1 · trang 2/5". Trẻ 4 tuổi đọc được 5 chấm chứ
## không đọc được câu đó — đúng luật "Show, Don't Tell" của tài liệu game
## giáo dục, và đúng ranh giới "v1 không lời" của Phạm vi v1.
##
## Vẽ lại CHỈ KHI trạng thái đổi, không đụng gì trong _process: cập nhật nhãn
## tĩnh mỗi khung hình là hao pin trên máy di động mà không đổi lấy gì.

const DOT_RADIUS := 9.0
const DOT_GAP := 30.0

@onready var _done_color := Color("#E8D9A0")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(
		DOT_GAP * Chapters.pages_per_chapter(), DOT_RADIUS * 4.0
	)
	GameState.page_changed.connect(_on_page_changed)


func _on_page_changed(_page_index: int) -> void:
	queue_redraw()


func _draw() -> void:
	var chapter := GameState.chapter_index()
	var accent := Chapters.color_of(chapter)
	var current := GameState.page_in_chapter()
	var y := size.y * 0.5

	for i in Chapters.pages_per_chapter():
		var centre := Vector2(DOT_RADIUS + i * DOT_GAP, y)
		if i < current:
			draw_circle(centre, DOT_RADIUS, _done_color)
		elif i == current:
			draw_circle(centre, DOT_RADIUS, accent)
			draw_arc(centre, DOT_RADIUS + 5.0, 0.0, TAU, 24, accent, 3.0, true)
		else:
			draw_arc(centre, DOT_RADIUS, 0.0, TAU, 24, Color(1, 1, 1, 0.28), 2.5, true)
