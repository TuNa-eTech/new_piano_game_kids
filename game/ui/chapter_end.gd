class_name ChapterEnd
extends PauseOverlay
## "Buổi Diễn Rừng Xanh" — màn kết chương (docs/gameplay-design.html · Cơ chế
## lan truyền chính).
##
## Tài liệu tả đúng thế này: "cả 7 con vật hát lại đúng giai điệu bé vừa chơi,
## cây thần mọc theo, rương báu bật mở", trọn 12 giây. Đây là khoảnh khắc được
## thiết kế để ĐẸP KHI BỊ QUAY LẠI, nên nó không có nút bấm nào chen ngang
## trong lúc đang diễn.
##
## Dựng cây RIÊNG chứ không mượn cây của ván chơi: ván chơi bên dưới đã sang
## trang mới rồi (page_changed phát trước chapter_completed), cây của nó đang là
## mầm của trang kế tiếp. Mượn nó thì màn kết chương sẽ tua lại chính trang bé
## chưa chơi.
##
## HAI CHỖ CHƯA LÀM, CÓ LÝ DO:
##  · "dòng chữ bé tự ký — Bản nhạc của Bún, 4 tuổi" cần TÊN BÉ, mà chưa có màn
##    nhập tên nào sinh ra dữ liệu đó. Chỗ ký để trống thay vì bịa một cái tên.
##  · Bước xuất file (A1 clip MP4 / A3 ảnh + nhạc / A4 gợi ý quay màn hình) chưa
##    nối, đang chờ chốt ngã ba Spike A.

signal finished

enum Phase { SPROUT, SINGING, FRUIT, DONE }

const SPROUT_SECONDS := 1.0
const NOTE_INTERVAL := 0.4      ## 23 nốt × 0,4 s ≈ 9,2 s
const FRUIT_SECONDS := 1.6      ## tổng ≈ 11,8 s, đúng "trọn vẹn 12 giây"
const ANIMAL_RADIUS := 26.0
const ANIMAL_POP := 1.55
const CELEBRATION_DB := -6.0

var _chapter: int = 0
var _sequence: PackedInt32Array = PackedInt32Array()
var _phase: Phase = Phase.DONE
var _timer: float = 0.0
var _played: int = 0
var _lit: int = -1
var _lit_age: float = 0.0

var _tree: MagicTree
var _animals: Control
var _continue: Button


func _ready() -> void:
	super()
	layer = 12
	set_process(false)


## Dựng LƯỜI, không dựng lúc khởi động. Màn kết chương chạy 5 trang một lần, mà
## cây + hàng thú + nút bấm của nó là 18 object nằm không suốt phần còn lại của
## phiên chơi. Đo được: dựng sẵn thì object count dao động ±2 lúc rảnh và có lần
## một lượt soak vọt +406 KB; dựng lười thì bốn lượt đứng yên tuyệt đối ở 1,1 KB
## như trước Tuần 4. Đường chạm→âm thanh là ràng buộc cứng của tài liệu, không
## đánh đổi nó lấy chút tiện tay khi viết.
func _ensure_built() -> void:
	if _tree != null:
		return
	_build()


func _build() -> void:
	# ĐỤC HOÀN TOÀN, khác nền mờ của bản đồ chương. Bản đồ là chỗ dừng tạm nên
	# thấy ván chơi bên dưới là đúng; còn đây là một cảnh diễn được thiết kế để
	# QUAY LẠI ĐƯỢC — HUD, nhãn phím và mép khung truyện hiện xuyên qua thì
	# khung hình thành một mớ chồng chéo. Chỉ ảnh chụp mới lộ ra chuyện này.
	_add_backdrop(Color(0.03, 0.05, 0.04, 1.0))

	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_FULL_RECT)
	column.add_theme_constant_override("separation", 12)
	add_child(column)

	_tree = MagicTree.new()
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_tree)

	_animals = Control.new()
	_animals.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_animals.custom_minimum_size = Vector2(0, ANIMAL_RADIUS * 3.4)
	column.add_child(_animals)
	_animals.draw.connect(_draw_animals)

	var footer := CenterContainer.new()
	footer.custom_minimum_size = Vector2(0, 120)
	column.add_child(footer)
	_continue = _make_continue_button()
	footer.add_child(_continue)


func _make_continue_button() -> Button:
	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(180, 96)
	button.visible = false

	var box := StyleBoxFlat.new()
	box.bg_color = Color("#3F9455").darkened(0.35)
	box.set_corner_radius_all(48)
	for state in ["normal", "hover", "focus"]:
		button.add_theme_stylebox_override(state, box)
	var down := box.duplicate() as StyleBoxFlat
	down.bg_color = Color("#3F9455")
	button.add_theme_stylebox_override("pressed", down)

	var face := Control.new()
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.add_child(face)
	face.draw.connect(_draw_continue_arrow.bind(face))

	button.pressed.connect(_on_continue)
	return button


# ------------------------------------------------------------------ vòng đời --

## Diễn lại TOÀN BỘ giai điệu của chương vừa xong, đúng thứ tự bé đã chơi.
func play_for_chapter(chapter: int) -> void:
	_chapter = chapter
	_sequence = PackedInt32Array()
	var first := Chapters.first_page_of(chapter)
	for i in Chapters.pages_per_chapter():
		_sequence.append_array(Melodies.for_page(first + i))

	_ensure_built()
	_played = 0
	_lit = -1
	_lit_age = 0.0
	_timer = 0.0
	_phase = Phase.SPROUT
	_tree.reset_page()
	_tree.set_sequence(_sequence)
	_continue.visible = false
	_animals.queue_redraw()

	open_overlay()
	set_process(true)


func _process(delta: float) -> void:
	_timer += delta
	_lit_age += delta

	match _phase:
		Phase.SPROUT:
			if _timer >= SPROUT_SECONDS:
				_enter(Phase.SINGING)
		Phase.SINGING:
			_tick_singing()
		Phase.FRUIT:
			if _timer >= FRUIT_SECONDS:
				_enter(Phase.DONE)
		Phase.DONE:
			set_process(false)

	if _lit >= 0:
		_animals.queue_redraw()


func _enter(next: Phase) -> void:
	_phase = next
	_timer = 0.0
	match next:
		Phase.FRUIT:
			_tree.fruit()
		Phase.DONE:
			_lit = -1
			_animals.queue_redraw()
			# Nút hiện SAU khi diễn xong: trong lúc diễn không có gì mời bấm,
			# để 12 giây đó quay lại được trọn vẹn.
			_continue.visible = true
			finished.emit()


func _tick_singing() -> void:
	var due := int(_timer / NOTE_INTERVAL)
	while _played < _sequence.size() and due > _played:
		var note: int = _sequence[_played]
		# Chừa headroom: 23 nốt cách nhau 0,4 s thì đuôi nốt chồng lên nhau và
		# tổng lại chạm sát trần (đo được −0,6 dB ở mức mặc định). HardLimiter
		# trên Master giữ cho không vỡ tiếng, nhưng màn kết vẫn sẽ TO HƠN HẲN
		# lúc chơi — trong app cho trẻ nhỏ thì đột ngột to lên là một lỗi.
		AudioDirector.play_note_pitched(note, 1.0, CELEBRATION_DB)
		_tree.clear_singing()
		_tree.sing_leaf(note)
		# Cây mọc đều theo cả chương, chạm đỉnh đúng lúc nốt cuối vang lên.
		_tree.bloom(note, _sequence.size())
		_lit = note
		_lit_age = 0.0
		_played += 1
		_animals.queue_redraw()

	if _played >= _sequence.size() and _timer >= _sequence.size() * NOTE_INTERVAL:
		_enter(Phase.FRUIT)


func _on_continue() -> void:
	close_overlay()
	set_process(false)


func note_count() -> int:
	return _sequence.size()


func phase_name() -> String:
	return ["SPROUT", "SINGING", "FRUIT", "DONE"][_phase]


func is_done() -> bool:
	return _phase == Phase.DONE


# -------------------------------------------------------------------- vẽ --

## Cả 7 con vật xếp thành hàng dưới cây; con đang hát thì nảy lên. Đây là "cả 7
## con vật hát lại" của tài liệu, dựng bằng art tạm đúng luật Bước 4.
func _draw_animals() -> void:
	var n := Notes.count()
	if n == 0:
		return
	var gap: float = minf(_animals.size.x / float(n + 1), ANIMAL_RADIUS * 3.0)
	var start := _animals.size.x * 0.5 - gap * (n - 1) * 0.5
	var y := _animals.size.y * 0.5

	for i in n:
		var colour: Color = Notes.TABLE[i]["color"]
		var r := ANIMAL_RADIUS
		if i == _lit:
			# Nảy rồi lắng xuống — cùng ngôn ngữ chuyển động với phím đàn.
			r *= lerpf(ANIMAL_POP, 1.0, minf(1.0, _lit_age / NOTE_INTERVAL))
		else:
			colour = colour.darkened(0.35)
		_animals.draw_circle(Vector2(start + i * gap, y), r, colour)


func _draw_continue_arrow(face: Control) -> void:
	var c := face.size * 0.5
	var r := minf(face.size.x, face.size.y) * 0.28
	var ink := Color("#E8D9A0")
	face.draw_line(Vector2(c.x - r, c.y), Vector2(c.x + r, c.y), ink, 8.0, true)
	face.draw_line(
		Vector2(c.x + r, c.y), Vector2(c.x + r * 0.35, c.y - r * 0.6), ink, 8.0, true
	)
	face.draw_line(
		Vector2(c.x + r, c.y), Vector2(c.x + r * 0.35, c.y + r * 0.6), ink, 8.0, true
	)
