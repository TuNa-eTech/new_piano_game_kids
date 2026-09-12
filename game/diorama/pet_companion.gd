class_name PetCompanion
extends Control
## Thú Cưng Đồng Hành trên trang sách tranh.
##
## Thay đổi diện mạo theo từng bài hát (Cá mập, Gấu, Mèo, Cú, Thỏ, Bò sữa, Sư tử, Cừu, Khỉ, Voi).
## Phản hồi hoạt cảnh sống động theo nhịp nhạc và tương tác của bé.

var _pet_id: String = "shark"
var _bpm: float = 80.0
var _texture_rect: TextureRect
var _bounce_tween: Tween
var _action_tween: Tween
var _idle_tex: Texture2D

const PET_TEXTURES: Dictionary = {
	"shark": "res://assets/art/pet_shark_gen_25d.png",
	"bear": "res://assets/art/pet_bear_cute_25d.png",
	"cat": "res://assets/art/pet_cat_cute_25d.png",
	"owl": "res://assets/art/pet_owl_cute_25d.png",
	"rabbit": "res://assets/art/pet_rabbit_cute_25d.png",
	"cow": "res://assets/art/pet_cow_gen_25d.png",
	"lion": "res://assets/art/pet_lion_cute_25d.png",
	"sheep": "res://assets/art/pet_sheep_gen_25d.png",
	"monkey": "res://assets/art/pet_monkey_cute_25d.png",
	"elephant": "res://assets/art/pet_elephant_cute_25d.png",
}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_texture_rect = TextureRect.new()
	_texture_rect.name = "PetSprite"
	_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(_texture_rect)

	resized.connect(_update_layout)
	_update_layout()
	load_pet(_pet_id, _bpm)


func _update_layout() -> void:
	if _texture_rect != null:
		_texture_rect.position = Vector2.ZERO
		_texture_rect.size = size
		_texture_rect.pivot_offset = size * 0.5


## Tải bạn thú cưng mới theo bài hát
func load_pet(pet_id: String, bpm: float = 80.0) -> void:
	_pet_id = pet_id
	_bpm = maxf(40.0, bpm)

	if _action_tween != null and _action_tween.is_valid():
		_action_tween.kill()
	if _bounce_tween != null and _bounce_tween.is_valid():
		_bounce_tween.kill()

	var tex_path: String = PET_TEXTURES.get(pet_id, "res://assets/art/pet_shark_gen_25d.png")
	if ResourceLoader.exists(tex_path):
		_idle_tex = load(tex_path)
	else:
		_idle_tex = null

	if _texture_rect != null:
		_texture_rect.texture = _idle_tex
		_texture_rect.position = Vector2.ZERO
		_texture_rect.scale = Vector2.ONE

	_start_idle_bounce()


func _start_idle_bounce() -> void:
	if _bounce_tween != null and _bounce_tween.is_valid():
		_bounce_tween.kill()

	var beat_duration := 60.0 / _bpm
	_bounce_tween = create_tween().set_loops().bind_node(self)
	_bounce_tween.tween_property(_texture_rect, "scale", Vector2(1.04, 0.96), beat_duration * 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_bounce_tween.tween_property(_texture_rect, "scale", Vector2(0.97, 1.03), beat_duration * 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Khi bé gõ nốt: Thú cưng nhún nảy nhẹ nhàng, giữ nguyên hình ảnh thú cưng 2.5D cute
func play_react() -> void:
	# Tuyệt đối giữ nguyên texture thú cưng 2.5D (_idle_tex), KHÔNG đổi sang ảnh khác gây chóng mặt!
	if _texture_rect != null and _idle_tex != null and _texture_rect.texture != _idle_tex:
		_texture_rect.texture = _idle_tex

	if _bounce_tween != null and _bounce_tween.is_valid():
		_bounce_tween.kill()
	if _action_tween != null and _action_tween.is_valid():
		_action_tween.kill()

	# Nhún nảy nhẹ nhàng, êm dịu, không giật lắc (squash & stretch 6% vui nhộn cho trẻ nhỏ)
	_action_tween = create_tween().bind_node(self)
	_action_tween.tween_property(_texture_rect, "scale", Vector2(1.06, 0.94), 0.09) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_action_tween.tween_property(_texture_rect, "scale", Vector2(0.97, 1.03), 0.11) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_action_tween.tween_property(_texture_rect, "scale", Vector2(1.0, 1.0), 0.09) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_action_tween.finished.connect(func():
		_start_idle_bounce()
	)


## Khi hoàn thành bài hát: Thú cưng nhảy xoay tròn ăn mừng
func play_celebrate() -> void:
	if _bounce_tween != null and _bounce_tween.is_valid():
		_bounce_tween.kill()
	if _action_tween != null and _action_tween.is_valid():
		_action_tween.kill()

	_action_tween = create_tween().set_loops().bind_node(self)
	_action_tween.tween_property(_texture_rect, "scale", Vector2(1.10, 0.92), 0.25) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_action_tween.tween_property(_texture_rect, "scale", Vector2(0.94, 1.08), 0.25) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
