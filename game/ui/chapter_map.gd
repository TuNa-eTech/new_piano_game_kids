class_name ChapterMap
extends CanvasLayer
## Bản đồ chương — lớp phủ mở bằng nút Menu giữ 2 giây.
##
## LỆCH ẢNH MOCK CÓ CHỦ Ý: ảnh mock có hai nút MENU và LEVELS. Nhưng nếu LEVELS
## chạm phát là mở được thì khoá nhẹ của MENU thành vô nghĩa — bé vẫn rời trang
## tự do, đúng thứ khoá nhẹ sinh ra để chặn. Nên gộp còn một nút Menu (giữ 2
## giây), và bản đồ chứa luôn phần chọn chương.
##
## NƠI DUY NHẤT ĐƯỢC SỞ HỮU get_tree().paused. Không module nào khác chạm vào cờ
## đó. Có nhiều chủ sở hữu là có kịch bản này: bé mở bản đồ → app xuống nền →
## mở lại → đàn ở dưới tự chạy tiếp trong khi bản đồ vẫn phủ trên.
##
## Ván chơi bên dưới bị chặn bằng HAI lớp độc lập, đã đo chứ không đoán:
##   ① get_tree().paused chặn _unhandled_input của node PROCESS_MODE_INHERIT;
##   ② nền mờ là Control MOUSE_FILTER_STOP phủ kín, cũng chặn _unhandled_input.
## Lớp phủ này process_mode = ALWAYS nên nút của chính nó vẫn ăn.

signal opened
signal closed
signal chapter_selected(chapter: int)

const FADE_SECONDS := 0.18

var _cards: Array[ChapterCard] = []
var _root: Control
var _backdrop: ColorRect
var _tween: Tween


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	visible = false


func _build() -> void:
	_backdrop = ColorRect.new()
	_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_backdrop.color = Color(0.04, 0.06, 0.05, 0.88)
	# STOP chứ không IGNORE: nền này là lớp chặn chạm thứ hai cho bàn phím.
	_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_backdrop)

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
func _draw_close_arrow(face: Control) -> void:
	var c := face.size * 0.5
	var r := minf(face.size.x, face.size.y) * 0.28
	var ink := Color("#E8D9A0")
	face.draw_line(Vector2(c.x - r, c.y), Vector2(c.x + r, c.y), ink, 8.0, true)
	face.draw_line(
		Vector2(c.x - r, c.y), Vector2(c.x - r * 0.35, c.y - r * 0.6), ink, 8.0, true
	)
	face.draw_line(
		Vector2(c.x - r, c.y), Vector2(c.x - r * 0.35, c.y + r * 0.6), ink, 8.0, true
	)


# ---------------------------------------------------------------- điều khiển --

func open_map() -> void:
	if visible:
		return
	for card in _cards:
		card.refresh()
	visible = true
	get_tree().paused = true
	_fade(0.0, 1.0)
	opened.emit()


func close_map() -> void:
	if not visible:
		return
	get_tree().paused = false
	visible = false
	closed.emit()


func is_open() -> bool:
	return visible


func _on_card_pressed(chapter: int) -> void:
	if not GameState.chapter_unlocked(chapter):
		return
	GameState.select_chapter(chapter)
	chapter_selected.emit(chapter)
	close_map()


## Tween mặc định dừng theo node bị pause. Node này ALWAYS nên nó vẫn chạy, còn
## TWEEN_PAUSE_PROCESS là lời khẳng định tường minh — hoạt cảnh kẹt nửa chừng
## đúng lúc cây đang dừng là một lỗi rất khó lần ra.
func _fade(from: float, to: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_root.modulate.a = from
	_backdrop.modulate.a = from
	_tween = create_tween().bind_node(self)
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_parallel(true)
	_tween.tween_property(_root, "modulate:a", to, FADE_SECONDS)
	_tween.tween_property(_backdrop, "modulate:a", to, FADE_SECONDS)
