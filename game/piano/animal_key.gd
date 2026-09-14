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

## Bảng màu pastel cầu vồng chuẩn Màn 03 Sân Khấu Chơi Tự Do (docs/mock-free-play.jpeg)
const RAINBOW_COLORS: Array[Color] = [
	Color("#F7B5D5"), # 0: C4 - Hồng pastel
	Color("#FAC8A8"), # 1: D4 - Cam đào
	Color("#FDF0A6"), # 2: E4 - Vàng kem
	Color("#C4E8A3"), # 3: F4 - Xanh lá non
	Color("#A5E6CE"), # 4: G4 - Bạc hà ngọc
	Color("#A0DCF7"), # 5: A4 - Xanh lơ nhạt
	Color("#9BB8F5"), # 6: B4 - Xanh lavender
]

var index: int = -1
var _has_sprite: bool = false
var _has_token: bool = false
var _is_hint_active: bool = false
var _is_rainbow: bool = false
var _key_tex: TextureRect
var _base_token_y: float = 0.0

var _badge_tex: TextureRect
var _badge_color: Color
var _badge_color_held: Color
var _badge_style: StyleBoxFlat
var _body_style: StyleBoxFlat
var _chamfer_style: StyleBoxFlat

var _tween: Tween
var _hint_tween: Tween

@onready var _key_top: Control = $KeyTop
@onready var _body: Panel = $KeyTop/Body
@onready var _chamfer: Panel = $KeyTop/Chamfer
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

	_badge_color = Notes.color_of(key_index)
	_badge_color_held = _badge_color * HELD_BRIGHTNESS

	# Mặt phím ngà 2.5D sắc nét
	_body_style = StyleBoxFlat.new()
	_body_style.bg_color = COLOR_CREAM
	_body_style.corner_radius_top_left = 3
	_body_style.corner_radius_top_right = 3
	_body_style.corner_radius_bottom_left = 10
	_body_style.corner_radius_bottom_right = 10
	_body_style.border_width_left = 1
	_body_style.border_width_top = 1
	_body_style.border_width_right = 1
	_body_style.border_width_bottom = 0
	_body_style.border_color = Color("#DEC088", 0.45)
	_body_style.shadow_color = Color(0, 0, 0, 0.25)
	_body_style.shadow_size = 3
	_body_style.shadow_offset = Vector2(0, 3)
	_body.add_theme_stylebox_override("panel", _body_style)
	_body.visible = true

	# Nút nốt nhạc tròn màu sắc theo mock (dự phòng)
	_badge_style = StyleBoxFlat.new()
	_badge_style.bg_color = _badge_color
	_badge_style.set_corner_radius_all(20)
	_badge_style.border_width_left = 2
	_badge_style.border_width_top = 2
	_badge_style.border_width_right = 2
	_badge_style.border_width_bottom = 2
	_badge_style.border_color = Color(1, 1, 1, 0.65)
	_badge_style.shadow_color = Color(0, 0, 0, 0.25)
	_badge_style.shadow_size = 2
	_badge_style.shadow_offset = Vector2(0, 2)
	_badge.add_theme_stylebox_override("panel", _badge_style)

	# Mặt vát trước (chamfer) 3D
	_chamfer_style = StyleBoxFlat.new()
	_chamfer_style.bg_color = COLOR_CHAMFER
	_chamfer_style.corner_radius_bottom_left = 10
	_chamfer_style.corner_radius_bottom_right = 10
	_chamfer_style.border_width_top = 2
	_chamfer_style.border_color = Color(1, 1, 1, 0.65)
	_chamfer.add_theme_stylebox_override("panel", _chamfer_style)
	_chamfer.visible = true

	# Chữ nốt trên nút tròn chuẩn ngũ cung Notes.TABLE: C, D, E, G, A, C, D
	var note_name := Notes.note_of(key_index)
	var letter := note_name.substr(0, 1)
	_label.text = letter

	_glow_overlay.color = _badge_color
	_glow_overlay.color.a = 0.0

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chamfer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_key_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_token.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var voice := Notes.voice_of(key_index)

	# 2. Avatar Thú 2.5D độc lập chuẩn sạch (không dính phím đen hay viền lân cận)
	var token_path := "res://assets/art/animal_%s_gen_25d.png" % voice
	if not ResourceLoader.exists(token_path):
		token_path = "res://assets/art/animal_token_25d_%s.png" % voice
	if not ResourceLoader.exists(token_path):
		token_path = "res://assets/art/avatar_%s_clean_25d.png" % voice
	if not ResourceLoader.exists(token_path):
		token_path = "res://assets/art/avatar_%s_25d.png" % voice
	if not ResourceLoader.exists(token_path):
		token_path = "res://assets/art/badge_%s.png" % voice

	if ResourceLoader.exists(token_path):
		_token.texture = load(token_path)
		_token.visible = true
		_has_token = true
	else:
		_token.visible = false
		_has_token = false

	# 3. Huy hiệu Nốt tròn 3D Glossy (Badge Note 2.5D)
	var badge_path := "res://assets/art/badge_note_25d_%s.png" % letter
	if ResourceLoader.exists(badge_path):
		if _badge_tex == null:
			_badge_tex = TextureRect.new()
			_badge_tex.name = "BadgeNote3D"
			_badge_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_badge_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			_badge_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			_key_top.add_child(_badge_tex)
		_badge_tex.texture = load(badge_path)
		_badge_tex.visible = true
		_badge.visible = false
		_label.visible = false
	else:
		_badge.visible = true
		_label.visible = true

	# 4. AnimatedSprite2D làm tư thế hát dự phòng
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
		_sprite.visible = not _has_token
		_has_sprite = true
	else:
		_sprite.visible = false
		_has_sprite = false

	_chamfer.visible = true
	_update_layout()


func _update_layout() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	_key_top.position = Vector2.ZERO
	_key_top.size = size

	# Thân phím ngà bao phủ toàn bộ chiều dài phím
	_body.position = Vector2.ZERO
	_body.size = size

	# Mặt vát trước (chamfer) ở 20px chân phím
	var chamfer_h := 20.0
	_chamfer.position = Vector2(0, size.y - chamfer_h)
	_chamfer.size = Vector2(size.x, chamfer_h)

	# Canh giữa Avatar Thú 2.5D ở giữa phím, tách biệt hoàn toàn không bị huy hiệu chữ cái che
	var token_size := clampf(size.x * 0.42, 64.0, 76.0)
	_base_token_y = size.y * 0.38
	_token.size = Vector2(token_size, token_size)
	_token.position = Vector2((size.x - token_size) * 0.5, _base_token_y)
	_token.pivot_offset = Vector2(token_size * 0.5, token_size * 0.5)

	# Vị trí Sprite thay thế nếu không có token
	_sprite.position = Vector2(size.x * 0.5, size.y * 0.52)

	# Nút nốt tròn 3D ở chân phím (tách rời dưới cằm thú khoảng 8-12px, chuẩn concept)
	var badge_size := clampf(size.x * 0.20, 32.0, 36.0)
	var badge_y := size.y - badge_size - 8.0
	if _badge_tex != null:
		_badge_tex.size = Vector2(badge_size, badge_size)
		_badge_tex.position = Vector2((size.x - badge_size) * 0.5, badge_y)
		_badge_tex.pivot_offset = Vector2(badge_size * 0.5, badge_size * 0.5)

	_badge.size = Vector2(badge_size, badge_size)
	_badge.position = Vector2((size.x - badge_size) * 0.5, badge_y)
	_badge.pivot_offset = Vector2(badge_size * 0.5, badge_size * 0.5)

	_label.size = _badge.size
	_label.position = _badge.position


## Cơ chế lún phím 3D cơ học và nảy đàn hồi
func press() -> void:
	pivot_offset = size * 0.5

	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween().bind_node(self)
	_tween.set_parallel(true)
	# Lún phím 3D: mặt phím trượt xuống theo trục Y
	_tween.tween_property(_key_top, "position:y", DEPRESS_PX, SQUASH_TIME) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", SQUASH, SQUASH_TIME) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_glow_overlay, "color:a", 0.35, SQUASH_TIME)
	if _badge_style != null:
		_badge_style.bg_color = _badge_color_held
	if _badge_tex != null and _badge_tex.visible:
		_tween.tween_property(_badge_tex, "scale", Vector2(1.12, 1.12), SQUASH_TIME)
	if _token != null and _token.visible:
		_tween.tween_property(_token, "scale", Vector2(1.08, 0.92), SQUASH_TIME)
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
	_tween.parallel().tween_property(_glow_overlay, "color:a", 0.0, RECOVER_TIME)
	if _badge_style != null:
		_badge_style.bg_color = _badge_color
	if _badge_tex != null and _badge_tex.visible:
		_tween.parallel().tween_property(_badge_tex, "scale", Vector2.ONE, RECOVER_TIME) \
			.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if _token != null and _token.visible:
		_tween.parallel().tween_property(_token, "scale", Vector2.ONE, RECOVER_TIME) \
			.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if _has_sprite and _sprite.visible:
		_sprite.play(&"idle")
	_apply_base_colors()


func set_rainbow_mode(enabled: bool) -> void:
	_is_rainbow = enabled
	_apply_base_colors()


func _apply_base_colors() -> void:
	if _body_style == null or _chamfer_style == null:
		return
	if _is_rainbow and index >= 0 and index < RAINBOW_COLORS.size():
		var col := RAINBOW_COLORS[index]
		_body_style.bg_color = col
		_chamfer_style.bg_color = col.darkened(0.18)
	else:
		_body_style.bg_color = COLOR_CREAM
		_chamfer_style.bg_color = COLOR_CHAMFER


func set_hint_active(active: bool) -> void:
	if _is_hint_active == active:
		return
	_is_hint_active = active

	if _hint_tween != null and _hint_tween.is_valid():
		_hint_tween.kill()

	var base_y := _base_token_y if _base_token_y > 0.0 else size.y * 0.40

	if not active:
		_glow_overlay.color.a = 0.0
		if _token != null and _has_token:
			_token.position.y = base_y
			_token.scale = Vector2.ONE
		return

	_glow_overlay.color = _badge_color
	_glow_overlay.color.a = 0.18
	_hint_tween = create_tween().bind_node(self).set_loops()

	# 1. Hào quang phát sáng nhịp nhàng — P0-3: tăng từ 0.52 lên 0.65 để
	# đứng xa 2m vẫn thấy phím cần bấm.
	_hint_tween.tween_property(_glow_overlay, "color:a", 0.65, 0.35) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if _token != null and _has_token:
		_hint_tween.parallel().tween_property(_token, "position:y", base_y - 16.0, 0.35) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_hint_tween.parallel().tween_property(_token, "scale", Vector2(1.14, 0.90), 0.35) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	_hint_tween.tween_property(_glow_overlay, "color:a", 0.18, 0.35) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if _token != null and _has_token:
		_hint_tween.parallel().tween_property(_token, "position:y", base_y, 0.35) \
			.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		_hint_tween.parallel().tween_property(_token, "scale", Vector2.ONE, 0.35) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
