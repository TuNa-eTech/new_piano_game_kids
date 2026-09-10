class_name DioramaStage
extends Control
## Sân khấu Pop-up Book Diorama 3D của Rừng Nhạc.
##
## Tái hiện 100% không gian sống động của mock-game-play.jpeg:
## - Hậu cảnh rừng cổ tích với nhà nấm và đom đóm bay lượn
## - Cuốn sách tranh mở 2 trang với gáy sách uốn cong và viền mạ vàng
## - Trang trái: Chú Phù Thủy Nhỏ chơi đàn mini + bong bóng thoại hướng dẫn
## - Bục đàn gỗ và hai cụm tinh thể thạch anh xanh ngọc / hồng tím phát sáng
## - Rương gỗ cổ điển trên thảm cỏ

const PageCurl = preload("res://game/diorama/page_curl.gd")

@onready var _bg_far: TextureRect = $BGFar
@onready var _bg_mid: TextureRect = $BGMid
@onready var _bg_near: TextureRect = $BGNear

@onready var _book_spread: TextureRect = $BookSpread
@onready var _wizard: TextureRect = $BookSpread/Wizard
@onready var _speech_bubble: Panel = $BookSpread/SpeechBubble
@onready var _speech_label: Label = $BookSpread/SpeechBubble/Label

@onready var _crystal_cyan: TextureRect = $CrystalCyan
@onready var _crystal_magenta: TextureRect = $CrystalMagenta
@onready var _chest_ground: TextureRect = $ChestGround

var _wizard_tween: Tween
var _crystal_tween: Tween
var _sparkle_tex: Texture2D
var _wiz_normal_tex: Texture2D
var _wiz_party_tex: Texture2D

var _page_curl: PageCurl
var _fireflies: CPUParticles2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_setup_textures()
	_setup_page_curl()
	_setup_fireflies()
	_start_wizard_animation()
	_start_crystal_glow()
	resized.connect(_update_layout)
	_update_layout()
	if GameState != null:
		GameState.free_play_changed.connect(_on_free_play_changed)



func _on_free_play_changed(enabled: bool) -> void:
	if enabled and _wiz_party_tex != null:
		_wizard.texture = _wiz_party_tex
	elif _wiz_normal_tex != null:
		_wizard.texture = _wiz_normal_tex


func _setup_textures() -> void:
	if ResourceLoader.exists("res://assets/art/bg_far.png"):
		_bg_far.texture = load("res://assets/art/bg_far.png")
	if ResourceLoader.exists("res://assets/art/bg_mid.png"):
		_bg_mid.texture = load("res://assets/art/bg_mid.png")
	if ResourceLoader.exists("res://assets/art/bg_near.png"):
		_bg_near.texture = load("res://assets/art/bg_near.png")

	if ResourceLoader.exists("res://assets/art/open_book_spread.png"):
		_book_spread.texture = load("res://assets/art/open_book_spread.png")
	if ResourceLoader.exists("res://assets/art/wizard_piano.png"):
		_wiz_normal_tex = load("res://assets/art/wizard_piano.png")
		_wizard.texture = _wiz_normal_tex
	if ResourceLoader.exists("res://assets/art/wizard_star_party.png"):
		_wiz_party_tex = load("res://assets/art/wizard_star_party.png")

	if ResourceLoader.exists("res://assets/art/crystal_cyan_stump.png"):
		_crystal_cyan.texture = load("res://assets/art/crystal_cyan_stump.png")
	if ResourceLoader.exists("res://assets/art/crystal_magenta_stump.png"):
		_crystal_magenta.texture = load("res://assets/art/crystal_magenta_stump.png")
	if ResourceLoader.exists("res://assets/art/chest_ground.png"):
		_chest_ground.texture = load("res://assets/art/chest_ground.png")
	if ResourceLoader.exists("res://assets/art/fx_sparkle.png"):
		_sparkle_tex = load("res://assets/art/fx_sparkle.png")


func _update_layout() -> void:
	if size.x <= 0 or size.y <= 0:
		return

	# Cuốn sách mở ở vị trí trung tâm màn hình, phía trên bàn phím đàn
	var book_w := minf(size.x * 0.88, 1140.0)
	var book_h := book_w * (1080.0 / 1920.0)
	var book_y := (size.y - book_h) * 0.38 # nằm gọn trong nửa trên
	_book_spread.size = Vector2(book_w, book_h)
	_book_spread.position = Vector2((size.x - book_w) * 0.5, book_y)

	# Phù thủy nhỏ ở trang sách bên trái
	var wiz_w := book_w * 0.30
	var wiz_h := wiz_w * (600.0 / 560.0)
	_wizard.size = Vector2(wiz_w, wiz_h)
	_wizard.position = Vector2(book_w * 0.14, book_h * 0.40)
	_wizard.pivot_offset = Vector2(wiz_w * 0.5, wiz_h)

	# Bong bóng thoại phía trên phù thủy nhỏ
	var bubble_w := book_w * 0.32
	var bubble_h := 62.0
	_speech_bubble.size = Vector2(bubble_w, bubble_h)
	_speech_bubble.position = Vector2(book_w * 0.13, book_h * 0.27)

	# Cụm thạch anh xanh ngọc ở góc trái dưới bệ đàn
	var cry_w := minf(size.x * 0.18, 160.0)
	var cry_h := cry_w * (480.0 / 440.0)
	_crystal_cyan.size = Vector2(cry_w, cry_h)
	_crystal_cyan.position = Vector2(10.0, size.y - cry_h - 18.0)

	# Cụm thạch anh hồng tím ở góc phải dưới
	_crystal_magenta.size = Vector2(cry_w, cry_h)
	_crystal_magenta.position = Vector2(size.x - cry_w - 10.0, size.y - cry_h - 18.0)

	# Rương báu nhỏ trên cỏ ở góc phải ngoài cuốn sách
	var chest_dim := minf(size.x * 0.10, 85.0)
	_chest_ground.size = Vector2(chest_dim, chest_dim)
	_chest_ground.position = Vector2(size.x - chest_dim - 8.0, size.y - chest_dim - 18.0)

	# Trang sách phải uốn cong (PageCurl)
	if _page_curl != null:
		var page_w := book_w * 0.46
		var page_h := book_h * 0.88
		_page_curl.size = Vector2(page_w, page_h)
		_page_curl.position = Vector2(book_w * 0.50, book_h * 0.06)

	# Vùng phát đom đóm bao quanh cuốn sách
	if _fireflies != null:
		_fireflies.position = Vector2(size.x * 0.5, size.y * 0.38)
		_fireflies.emission_rect_extents = Vector2(size.x * 0.45, size.y * 0.28)


func _setup_page_curl() -> void:
	_page_curl = PageCurl.new()
	_page_curl.name = "PageCurl"
	_book_spread.add_child(_page_curl)


## CPUParticles2D tạo đàn đom đóm và bụi sao thần tiên bay lơ lửng quanh sách
func _setup_fireflies() -> void:
	_fireflies = CPUParticles2D.new()
	_fireflies.name = "AmbientFireflies"
	_fireflies.amount = 22
	_fireflies.lifetime = 4.2
	_fireflies.preprocess = 2.0
	if _sparkle_tex != null:
		_fireflies.texture = _sparkle_tex

	_fireflies.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_fireflies.emission_rect_extents = Vector2(500.0, 180.0)
	_fireflies.direction = Vector2(0, -1)
	_fireflies.spread = 55.0
	_fireflies.initial_velocity_min = 6.0
	_fireflies.initial_velocity_max = 20.0
	_fireflies.gravity = Vector2(0, -3.5)
	_fireflies.scale_amount_min = 0.35
	_fireflies.scale_amount_max = 0.80

	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.95, 0.70, 0.0))
	grad.add_point(0.2, Color(1.0, 0.92, 0.55, 0.85))
	grad.add_point(0.75, Color(0.75, 1.0, 0.75, 0.70))
	grad.set_color(1, Color(1.0, 0.95, 0.70, 0.0))
	_fireflies.color_ramp = grad

	add_child(_fireflies)



## Gọi từ CallResponse khi kết thúc giai điệu để lật sang trang mới
func flip_page(duration: float = 0.95) -> void:
	if _page_curl != null:
		_page_curl.flip_page(duration)


func set_speech_text(text: String) -> void:
	if _speech_label != null:
		_speech_label.text = text


func on_note_played(_note_idx: int) -> void:
	if _wizard != null:
		var tw := create_tween().bind_node(self)
		tw.tween_property(_wizard, "scale", Vector2(1.15, 0.85), 0.06) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(_wizard, "scale", Vector2(1.0, 1.0), 0.14) \
			.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


## Chú phù thủy nhỏ nhún nhảy chơi đàn mini theo nhịp
func _start_wizard_animation() -> void:
	if _wizard_tween != null and _wizard_tween.is_valid():
		_wizard_tween.kill()

	_wizard_tween = create_tween().bind_node(self).set_loops()
	_wizard_tween.tween_property(_wizard, "rotation", 0.04, 0.42) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_wizard_tween.tween_property(_wizard, "scale", Vector2(1.03, 0.97), 0.42) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_wizard_tween.tween_property(_wizard, "rotation", -0.04, 0.42) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_wizard_tween.tween_property(_wizard, "scale", Vector2(0.98, 1.02), 0.42) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Ánh sáng tinh thể thạch anh thở nhịp chậm (Breathing glow)
func _start_crystal_glow() -> void:
	if _crystal_tween != null and _crystal_tween.is_valid():
		_crystal_tween.kill()

	_crystal_tween = create_tween().bind_node(self).set_loops()
	_crystal_tween.parallel().tween_property(_crystal_cyan, "modulate:a", 0.75, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_crystal_tween.parallel().tween_property(_crystal_magenta, "modulate:a", 1.0, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_crystal_tween.parallel().tween_property(_crystal_cyan, "modulate:a", 1.0, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_crystal_tween.parallel().tween_property(_crystal_magenta, "modulate:a", 0.75, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _exit_tree() -> void:
	if _wizard_tween != null and _wizard_tween.is_valid():
		_wizard_tween.kill()
	if _crystal_tween != null and _crystal_tween.is_valid():
		_crystal_tween.kill()


