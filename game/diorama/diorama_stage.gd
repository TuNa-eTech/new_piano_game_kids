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

signal prop_interacted(prop_name: String)

const WIZARD_CHEERS: Array[String] = [
	"Bé đàn hay quá! ✨",
	"Giai điệu diệu kỳ! 🎶",
	"Cùng chơi tiếp nào! 🌟",
	"Khu rừng bừng sáng! 🍃",
	"Hoan hô bé giỏi! 🎉",
]

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

# Hệ thống hạt particle burst tương tác cho các đạo cụ
var _wizard_sparkles: CPUParticles2D
var _cyan_sparkles: CPUParticles2D
var _magenta_sparkles: CPUParticles2D
var _chest_sparkles: CPUParticles2D
var _book_sparkles: CPUParticles2D

var _cheer_index: int = 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	_setup_textures()
	_setup_page_curl()
	_setup_fireflies()
	_setup_interactive_particles()
	_setup_interactions()
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
	_crystal_magenta.pivot_offset = Vector2(cry_w * 0.5, cry_h * 0.5)
	_crystal_cyan.pivot_offset = Vector2(cry_w * 0.5, cry_h * 0.5)

	# Rương báu nhỏ trên cỏ ở góc phải ngoài cuốn sách (đặt cạnh thạch anh hồng)
	var chest_dim := minf(size.x * 0.10, 85.0)
	_chest_ground.size = Vector2(chest_dim, chest_dim)
	_chest_ground.position = Vector2(size.x - cry_w - chest_dim - 24.0, size.y - chest_dim - 18.0)
	_chest_ground.pivot_offset = Vector2(chest_dim * 0.5, chest_dim * 0.5)

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


func _setup_interactive_particles() -> void:
	# 1. Chùm sao phù thủy
	_wizard_sparkles = CPUParticles2D.new()
	_wizard_sparkles.name = "WizardSparkles"
	_wizard_sparkles.emitting = false
	_wizard_sparkles.one_shot = true
	_wizard_sparkles.explosiveness = 0.85
	_wizard_sparkles.amount = 18
	_wizard_sparkles.lifetime = 0.9
	if _sparkle_tex != null:
		_wizard_sparkles.texture = _sparkle_tex
	_wizard_sparkles.direction = Vector2(1.0, -0.6)
	_wizard_sparkles.spread = 45.0
	_wizard_sparkles.initial_velocity_min = 120.0
	_wizard_sparkles.initial_velocity_max = 240.0
	_wizard_sparkles.gravity = Vector2(0, 110.0)
	_wizard_sparkles.scale_amount_min = 0.4
	_wizard_sparkles.scale_amount_max = 0.95
	var wiz_grad := Gradient.new()
	wiz_grad.set_color(0, Color(1.0, 0.9, 0.4, 1.0))
	wiz_grad.add_point(0.3, Color(0.4, 0.9, 1.0, 0.9))
	wiz_grad.add_point(0.7, Color(1.0, 0.5, 0.8, 0.8))
	wiz_grad.set_color(1, Color(1.0, 1.0, 0.5, 0.0))
	_wizard_sparkles.color_ramp = wiz_grad
	_wizard.add_child(_wizard_sparkles)

	# 2. Bụi ngọc thạch anh xanh
	_cyan_sparkles = CPUParticles2D.new()
	_cyan_sparkles.name = "CyanSparkles"
	_cyan_sparkles.emitting = false
	_cyan_sparkles.one_shot = true
	_cyan_sparkles.explosiveness = 0.8
	_cyan_sparkles.amount = 14
	_cyan_sparkles.lifetime = 0.75
	if _sparkle_tex != null:
		_cyan_sparkles.texture = _sparkle_tex
	_cyan_sparkles.direction = Vector2(0, -1)
	_cyan_sparkles.spread = 60.0
	_cyan_sparkles.initial_velocity_min = 60.0
	_cyan_sparkles.initial_velocity_max = 140.0
	_cyan_sparkles.gravity = Vector2(0, -20.0)
	_cyan_sparkles.scale_amount_min = 0.35
	_cyan_sparkles.scale_amount_max = 0.8
	var cyan_grad := Gradient.new()
	cyan_grad.set_color(0, Color(0.5, 1.0, 1.0, 1.0))
	cyan_grad.set_color(1, Color(0.2, 0.8, 0.9, 0.0))
	_cyan_sparkles.color_ramp = cyan_grad
	_crystal_cyan.add_child(_cyan_sparkles)

	# 3. Bụi ngọc thạch anh hồng tím
	_magenta_sparkles = CPUParticles2D.new()
	_magenta_sparkles.name = "MagentaSparkles"
	_magenta_sparkles.emitting = false
	_magenta_sparkles.one_shot = true
	_magenta_sparkles.explosiveness = 0.8
	_magenta_sparkles.amount = 14
	_magenta_sparkles.lifetime = 0.75
	if _sparkle_tex != null:
		_magenta_sparkles.texture = _sparkle_tex
	_magenta_sparkles.direction = Vector2(0, -1)
	_magenta_sparkles.spread = 60.0
	_magenta_sparkles.initial_velocity_min = 60.0
	_magenta_sparkles.initial_velocity_max = 140.0
	_magenta_sparkles.gravity = Vector2(0, -20.0)
	_magenta_sparkles.scale_amount_min = 0.35
	_magenta_sparkles.scale_amount_max = 0.8
	var mag_grad := Gradient.new()
	mag_grad.set_color(0, Color(1.0, 0.6, 0.9, 1.0))
	mag_grad.set_color(1, Color(0.8, 0.3, 0.7, 0.0))
	_magenta_sparkles.color_ramp = mag_grad
	_crystal_magenta.add_child(_magenta_sparkles)

	# 4. Sao vàng từ rương báu
	_chest_sparkles = CPUParticles2D.new()
	_chest_sparkles.name = "ChestSparkles"
	_chest_sparkles.emitting = false
	_chest_sparkles.one_shot = true
	_chest_sparkles.explosiveness = 0.75
	_chest_sparkles.amount = 12
	_chest_sparkles.lifetime = 0.7
	if _sparkle_tex != null:
		_chest_sparkles.texture = _sparkle_tex
	_chest_sparkles.direction = Vector2(0, -1)
	_chest_sparkles.spread = 50.0
	_chest_sparkles.initial_velocity_min = 70.0
	_chest_sparkles.initial_velocity_max = 130.0
	_chest_sparkles.gravity = Vector2(0, 30.0)
	_chest_sparkles.scale_amount_min = 0.4
	_chest_sparkles.scale_amount_max = 0.85
	var gold_grad := Gradient.new()
	gold_grad.set_color(0, Color(1.0, 0.92, 0.45, 1.0))
	gold_grad.set_color(1, Color(1.0, 0.75, 0.2, 0.0))
	_chest_sparkles.color_ramp = gold_grad
	_chest_ground.add_child(_chest_sparkles)


func _setup_interactions() -> void:
	_book_spread.mouse_filter = Control.MOUSE_FILTER_PASS
	_wizard.mouse_filter = Control.MOUSE_FILTER_STOP
	_crystal_cyan.mouse_filter = Control.MOUSE_FILTER_STOP
	_crystal_magenta.mouse_filter = Control.MOUSE_FILTER_STOP
	_chest_ground.mouse_filter = Control.MOUSE_FILTER_STOP

	_wizard.gui_input.connect(_on_wizard_gui_input)
	_crystal_cyan.gui_input.connect(_on_crystal_cyan_gui_input)
	_crystal_magenta.gui_input.connect(_on_crystal_magenta_gui_input)
	_chest_ground.gui_input.connect(_on_chest_gui_input)
	_book_spread.gui_input.connect(_on_book_gui_input)


func _on_wizard_gui_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		interact_wizard()
		accept_event()


func _on_crystal_cyan_gui_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		interact_crystal_cyan()
		accept_event()


func _on_crystal_magenta_gui_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		interact_crystal_magenta()
		accept_event()


func _on_chest_gui_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		interact_chest()
		accept_event()


func _on_book_gui_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		interact_book(event.position)


func interact_wizard() -> void:
	# Nảy nảy và lắc nón vui nhộn
	var tw := create_tween().bind_node(self).set_parallel(false)
	tw.tween_property(_wizard, "scale", Vector2(1.22, 0.80), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(_wizard, "scale", Vector2(0.92, 1.15), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(_wizard, "scale", Vector2(1.0, 1.0), 0.20).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	var rot_tw := create_tween().bind_node(self)
	rot_tw.tween_property(_wizard, "rotation", 0.20, 0.08)
	rot_tw.tween_property(_wizard, "rotation", -0.16, 0.12)
	rot_tw.tween_property(_wizard, "rotation", 0.0, 0.16)

	# Bắn hạt sao ma thuật
	if _wizard_sparkles != null:
		_wizard_sparkles.position = _wizard.size * Vector2(0.65, 0.25)
		_wizard_sparkles.restart()

	# Đổi câu cổ vũ trên bong bóng thoại
	_cheer_index = (_cheer_index + 1) % WIZARD_CHEERS.size()
	set_speech_text(WIZARD_CHEERS[_cheer_index])

	# Âm thanh vui nhộn
	AudioDirector.play_note_pitched(3, 1.25, -2.0)
	prop_interacted.emit("wizard")


func interact_crystal_cyan() -> void:
	# Tinh thể bừng sáng
	var tw := create_tween().bind_node(self).set_parallel(true)
	tw.tween_property(_crystal_cyan, "modulate", Color(2.5, 2.8, 3.0), 0.08)
	tw.tween_property(_crystal_cyan, "scale", Vector2(1.18, 0.88), 0.08)
	tw.chain().tween_property(_crystal_cyan, "modulate", Color(1.0, 1.0, 1.0), 0.45)
	tw.chain().tween_property(_crystal_cyan, "scale", Vector2(1.0, 1.0), 0.22).set_trans(Tween.TRANS_BOUNCE)

	if _cyan_sparkles != null:
		_cyan_sparkles.position = _crystal_cyan.size * Vector2(0.5, 0.3)
		_cyan_sparkles.restart()

	AudioDirector.play_instrument_note(2, 5, 0.0) # Chuông gió C5 thanh khiết
	prop_interacted.emit("crystal_cyan")


func interact_crystal_magenta() -> void:
	# Tinh thể bừng sáng hồng tím
	var tw := create_tween().bind_node(self).set_parallel(true)
	tw.tween_property(_crystal_magenta, "modulate", Color(3.0, 1.8, 2.8), 0.08)
	tw.tween_property(_crystal_magenta, "scale", Vector2(1.18, 0.88), 0.08)
	tw.chain().tween_property(_crystal_magenta, "modulate", Color(1.0, 1.0, 1.0), 0.45)
	tw.chain().tween_property(_crystal_magenta, "scale", Vector2(1.0, 1.0), 0.22).set_trans(Tween.TRANS_BOUNCE)

	if _magenta_sparkles != null:
		_magenta_sparkles.position = _crystal_magenta.size * Vector2(0.5, 0.3)
		_magenta_sparkles.restart()

	AudioDirector.play_instrument_note(1, 2, 0.0) # Kalimba E4 mộc ấm
	prop_interacted.emit("crystal_magenta")


func interact_chest() -> void:
	var tw := create_tween().bind_node(self)
	var orig_y := _chest_ground.position.y
	tw.tween_property(_chest_ground, "position:y", orig_y - 14.0, 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_chest_ground, "rotation", 0.14, 0.09)
	tw.tween_property(_chest_ground, "position:y", orig_y, 0.16).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_chest_ground, "rotation", 0.0, 0.16)

	if _chest_sparkles != null:
		_chest_sparkles.position = _chest_ground.size * Vector2(0.5, 0.3)
		_chest_sparkles.restart()

	AudioDirector.play_sfx("chest_open")
	prop_interacted.emit("chest")


func interact_book(pos: Vector2) -> void:
	AudioDirector.play_ting()
	prop_interacted.emit("book")


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


