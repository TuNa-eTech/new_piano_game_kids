class_name AnimalKey
extends Control
## Một phím đàn có mặt con vật và cơ chế lún phím 3D cơ học.
##
## Toàn bộ việc bắt chạm do PianoKeyboard làm (một chỗ duy nhất, hit-test 7 ô
## chữ nhật). Tách như vậy để Tuần 2 nối lá trên cây thần vào cùng tín hiệu mà
## không phải đụng lại đường input.
##
## Thiết kế 3D cơ học:
## - Mặt trên ngà kem (KeyTop) có gắn huy hiệu nổi 3D (Token) và nút nốt tròn (Badge).
## - Mặt trước vát cạnh (Chamfer) và bóng đổ (Shadow) tạo chiều sâu 3D cơ học.
## - Khi chạm: mặt phím lún xuống 8px theo trục Z/Y, nảy đàn hồi SQUASH.

const SQUASH := Vector2(1.04, 0.92)
const SQUASH_TIME := 0.055
const RECOVER_TIME := 0.38
const HELD_BRIGHTNESS := 1.18
const DEPRESS_PX := 8.0

const COLOR_CREAM := Color("#FDF3DA")
const COLOR_CREAM_HELD := Color("#FFFBEF")
const COLOR_CHAMFER := Color("#DEC088")
const COLOR_CHAMFER_HELD := Color("#EBD09C")

var index: int = -1
var _has_sprite: bool = false
var _has_token: bool = false
var _is_hint_active: bool = false

var _badge_color: Color
var _badge_color_held: Color
var _badge_style: StyleBoxFlat
var _chamfer_style: StyleBoxFlat

var _tween: Tween
var _hint_tween: Tween

@onready var _shadow: ColorRect = $Shadow
@onready var _chamfer: Panel = $Chamfer
@onready var _key_top: Control = $KeyTop
@onready var _body: ColorRect = $KeyTop/Body
@onready var _glow_overlay: ColorRect = $KeyTop/GlowOverlay
@onready var _sprite: AnimatedSprite2D = $KeyTop/Sprite
@onready var _token: TextureRect = $KeyTop/Token
@onready var _badge: Panel = $KeyTop/Badge
@onready var _label: Label = $KeyTop/Label


func _ready() -> void:
	resized.connect(_update_layout)


func _exit_tree() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if _hint_tween != null and _hint_tween.is_valid():
		_hint_tween.kill()


func setup(key_index: int) -> void:
	index = key_index
	_body.color = COLOR_CREAM

	_badge_color = Notes.color_of(key_index)
	_badge_color_held = _badge_color * HELD_BRIGHTNESS

	# Nút nốt nhạc tròn màu sắc theo mock
	_badge_style = StyleBoxFlat.new()
	_badge_style.bg_color = _badge_color
	_badge_style.set_corner_radius_all(22)
	_badge_style.border_width_left = 2
	_badge_style.border_width_top = 2
	_badge_style.border_width_right = 2
	_badge_style.border_width_bottom = 2
	_badge_style.border_color = Color(1, 1, 1, 0.45)
	_badge.add_theme_stylebox_override("panel", _badge_style)

	# Mặt vát trước (chamfer) 3D
	_chamfer_style = StyleBoxFlat.new()
	_chamfer_style.bg_color = COLOR_CHAMFER
	_chamfer_style.corner_radius_bottom_left = 10
	_chamfer_style.corner_radius_bottom_right = 10
	_chamfer.add_theme_stylebox_override("panel", _chamfer_style)

	# Chữ nốt trên nút tròn: C, D, E, G, A...
	var note_name := Notes.note_of(key_index)
	var letter := note_name.substr(0, 1) # lấy chữ C, D, E...
	_label.text = letter

	_glow_overlay.color = _badge_color
	_glow_overlay.color.a = 0.0

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chamfer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_key_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_token.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var voice := Notes.voice_of(key_index)

	# 1. Huy hiệu 3D con vật tròn (Token) theo ảnh mock
	var token_path := "res://assets/art/badge_%s.png" % voice
	if ResourceLoader.exists(token_path):
		_token.texture = load(token_path)
		_token.visible = true
		_has_token = true
	else:
		_token.visible = false
		_has_token = false

	# 2. AnimatedSprite2D làm tư thế hát dự phòng
	var idle_path := "res://assets/art/animal_%s_idle.png" % voice
	var sing_path := "res://assets/art/animal_%s_sing.png" % voice
	if ResourceLoader.exists(idle_path) and ResourceLoader.exists(sing_path):
		var frames := SpriteFrames.new()
		frames.add_animation(&"idle")
		frames.add_frame(&"idle", load(idle_path))
		frames.add_animation(&"sing")
		frames.add_frame(&"sing", load(sing_path))
		_sprite.sprite_frames = frames
		_sprite.play(&"idle")
		# Nếu đã có token tròn 3D như mock thì ưu tiên token
		_sprite.visible = not _has_token
		_has_sprite = true
	else:
		_sprite.visible = false
		_has_sprite = false

	_update_layout()


func _update_layout() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	# Canh giữa token 3D trên mặt phím
	if _token != null and _has_token:
		var token_dim := minf(size.x - 16.0, size.y * 0.44)
		_token.custom_minimum_size = Vector2(token_dim, token_dim)
		_token.size = Vector2(token_dim, token_dim)
		_token.position = Vector2(
			(size.x - token_dim) * 0.5,
			size.y * 0.28
		)

	# Canh giữa sprite nếu dùng sprite
	if _sprite != null and _has_sprite and not _has_token:
		var usable_h := maxf(10.0, size.y - 48.0)
		_sprite.position = Vector2(size.x * 0.5, usable_h * 0.52)
		var target_dim := minf(size.x - 12.0, usable_h - 10.0)
		var s := target_dim / 360.0
		_sprite.scale = Vector2(s, s)


## Cơ chế lún phím 3D cơ học và nảy đàn hồi
func press() -> void:
	pivot_offset = size * 0.5

	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween().bind_node(self)
	# Lún mặt phím xuống 8px tạo cảm giác cơ học
	_tween.parallel().tween_property(_key_top, "position:y", DEPRESS_PX, SQUASH_TIME) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "scale", SQUASH, SQUASH_TIME) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	_body.color = COLOR_CREAM_HELD
	if _chamfer_style != null:
		_chamfer_style.bg_color = COLOR_CHAMFER_HELD
	if _badge_style != null:
		_badge_style.bg_color = _badge_color_held
	if _has_sprite and _sprite.visible:
		_sprite.play(&"sing")


func release() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween().bind_node(self)
	# Nhả phím: lò xo nảy lại vị trí cũ
	_tween.parallel().tween_property(_key_top, "position:y", 0.0, RECOVER_TIME) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "scale", Vector2.ONE, RECOVER_TIME) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	_body.color = COLOR_CREAM
	if _chamfer_style != null:
		_chamfer_style.bg_color = COLOR_CHAMFER
	if _badge_style != null:
		_badge_style.bg_color = _badge_color
	if _has_sprite and _sprite.visible:
		_sprite.play(&"idle")


func set_hint_active(active: bool) -> void:
	if _is_hint_active == active:
		return
	_is_hint_active = active

	if _hint_tween != null and _hint_tween.is_valid():
		_hint_tween.kill()

	if not active:
		_glow_overlay.color.a = 0.0
		return

	_glow_overlay.color = _badge_color
	_glow_overlay.color.a = 0.12
	_hint_tween = create_tween().bind_node(self).set_loops()
	_hint_tween.tween_property(_glow_overlay, "color:a", 0.45, 0.35) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_hint_tween.tween_property(_glow_overlay, "color:a", 0.12, 0.35) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
