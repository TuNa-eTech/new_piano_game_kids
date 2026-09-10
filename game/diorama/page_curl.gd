class_name PageCurl
extends ColorRect
## Component hiển thị hiệu ứng lật trang sách (Page Flip Effect).
##
## Dùng CanvasItem shader uốn cong hình trụ (Cylindrical roll):
## - Chạy 100% trên GPU, không tốn CPU.
## - Phát tín hiệu `page_half_flipped` lúc trang đã gập nửa (để cây thần reset)
## - Đồng bộ mượt mà với âm thanh lật giấy sfx_page_turn.wav.

signal page_half_flipped
signal flip_completed

var _tween: Tween
var _shader_mat: ShaderMaterial


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
		material = _shader_mat


func is_flipping() -> bool:
	return _tween != null and _tween.is_valid()


## Kích hoạt hoạt ảnh lật trang sách với thời lượng duration (mặc định 0.95s)
func flip_page(duration: float = 0.95) -> void:
	if _shader_mat == null:
		_setup_material()

	if _tween != null and _tween.is_valid():
		_tween.kill()

	visible = true
	_set_progress(0.0)

	AudioDirector.play_sfx("page_turn")

	_tween = create_tween().bind_node(self)
	# Nửa đầu: mép phải trang sách cuộn lên đến giữa (gợi mở trang mới)
	_tween.tween_method(_set_progress, 0.0, 0.50, duration * 0.48) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.tween_callback(func(): page_half_flipped.emit())
	# Nửa sau: trang sách lật hẳn sang gáy trái và lặn êm vào trang sách
	_tween.tween_method(_set_progress, 0.50, 1.0, duration * 0.52) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_callback(_on_flip_finished)


func _set_progress(val: float) -> void:
	if _shader_mat != null:
		_shader_mat.set_shader_parameter("progress", val)


func _on_flip_finished() -> void:
	visible = false
	_set_progress(0.0)
	flip_completed.emit()


func _exit_tree() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
