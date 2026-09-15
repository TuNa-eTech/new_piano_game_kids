class_name PageCurl
extends ColorRect
## Component hiển thị hiệu ứng lật trang sách (Page Flip Effect).
##
## Dùng CanvasItem shader uốn cong hình trụ (Cylindrical roll):
## - Chạy 100% trên GPU, không tốn CPU.
## - Phát tín hiệu `page_half_flipped` lúc trang đã gập nửa (để cây thần reset)
## - Đồng bộ mượt mà với âm thanh lật giấy sfx_page_turn.wav.
##
## KHÔNG tự biết mình che trang nào: bên sở hữu (StoryBook) đặt vị trí và kích
## thước trước mỗi lần lật, vì chỉ nó biết nửa trái hay nửa phải đang bị lật.

## Tờ giấy vừa che kín trang — ĐÂY mới là lúc tráo nội dung.
## Chờ tới lúc gập nửa thì quá muộn: nếp gấp đã đi được nửa trang, phần trang
## lộ ra phía sau nó chiếm nửa màn hình, và cú tráo nội dung nháy rõ mồn một.
signal sheet_covered
signal page_half_flipped
signal flip_completed

## Mốc progress mà tờ giấy đã phủ kín ~95% bề mặt trang. Phần còn hở nằm gọn
## trong dải bóng đổ dưới chân nếp gấp nên mắt không bắt được cú tráo.
const COVER_PROGRESS := 0.12

var _tween: Tween
var _shader_mat: ShaderMaterial
var _progress: float = 0.0
var _covered: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_setup_material()


func _setup_material() -> void:
	var shader: Shader = load("res://game/diorama/shaders/page_curl.gdshader")
	if shader != null:
		_shader_mat = ShaderMaterial.new()
		_shader_mat.shader = shader
		_shader_mat.set_shader_parameter("progress", 0.0)
		_shader_mat.set_shader_parameter("direction", 1.0)
		material = _shader_mat


func is_flipping() -> bool:
	return _tween != null and _tween.is_valid()


## Mức hoàn thành 0..1 của lần lật đang chạy — dành cho test và công cụ chụp hình.
func progress() -> float:
	return _progress


## Kích hoạt hoạt ảnh lật trang sách với thời lượng duration (mặc định 0.95s).
## forward = false thì nếp cuộn chạy ngược lại, dùng khi bé bấm nút lùi.
func flip_page(duration: float = 0.95, forward: bool = true) -> void:
	if _shader_mat == null:
		_setup_material()

	if _tween != null and _tween.is_valid():
		_tween.kill()

	_shader_mat.set_shader_parameter("direction", 1.0 if forward else -1.0)
	visible = true
	_covered = false
	_set_progress(0.0)

	AudioDirector.play_sfx("page_turn")

	_tween = create_tween().bind_node(self)
	# Nửa đầu: mép trang sách cuộn lên đến giữa (gợi mở trang mới)
	_tween.tween_method(_set_progress, 0.0, 0.50, duration * 0.48) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.tween_callback(func(): page_half_flipped.emit())
	# Nửa sau: trang sách lật hẳn sang gáy và lặn êm vào trang sách
	_tween.tween_method(_set_progress, 0.50, 1.0, duration * 0.52) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_callback(_on_flip_finished)


func _set_progress(val: float) -> void:
	_progress = val
	# Bắn tín hiệu từ trong hàm nội suy thay vì cắt tween làm ba đoạn: cắt đoạn
	# là cắt luôn đường cong gia tốc, giấy sẽ khựng đúng chỗ nối.
	if not _covered and val >= COVER_PROGRESS:
		_covered = true
		sheet_covered.emit()
	if _shader_mat != null:
		_shader_mat.set_shader_parameter("progress", val)


func _on_flip_finished() -> void:
	visible = false
	_set_progress(0.0)
	flip_completed.emit()


func _exit_tree() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
