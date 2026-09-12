class_name WizardLeo
extends Control
## Cậu Bé Phù Thủy Leo - Nhân vật chính đồng hành cùng bé trên trang sách.
##
## Quản lý các trạng thái hoạt cảnh:
## - PIANO: Ngồi đàn piano mini, nhún nhảy theo nhịp BPM bài hát.
## - CAST: Vung đũa phép bắn đốm sao cổ tích khi bé gõ phím đúng.
## - JUMP: Nhảy cẫng reo vui khi bé đạt chuỗi nốt hoặc hoàn thành câu hát.
## - CELEBRATE: Bay bổng giữa dải nốt nhạc vàng khi hoàn thành bài hát.

enum AnimState { PIANO, IDLE, CAST, JUMP, CELEBRATE }

var _current_state: AnimState = AnimState.PIANO
var _texture_rect: TextureRect
var _sparkles: CPUParticles2D
var _bounce_tween: Tween
var _action_tween: Tween
var _bpm: float = 80.0

var _tex_piano: Texture2D
var _tex_idle: Texture2D
var _tex_cast: Texture2D
var _tex_jump: Texture2D
var _tex_celebrate: Texture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_setup_textures()
	_setup_nodes()
	set_bpm(_bpm)


func _setup_textures() -> void:
	if ResourceLoader.exists("res://assets/art/leo_wizard_piano_gen_25d.png"):
		_tex_piano = load("res://assets/art/leo_wizard_piano_gen_25d.png")
	elif ResourceLoader.exists("res://assets/art/wizard_piano.png"):
		_tex_piano = load("res://assets/art/wizard_piano.png")

	if ResourceLoader.exists("res://assets/art/leo_wizard_cast_gen_25d.png"):
		_tex_cast = load("res://assets/art/leo_wizard_cast_gen_25d.png")
		_tex_idle = _tex_cast
	elif ResourceLoader.exists("res://assets/characters/wizard/wizard_attack.png"):
		_tex_cast = load("res://assets/characters/wizard/wizard_attack.png")
		_tex_idle = load("res://assets/characters/wizard/wizard_idle.png")

	if ResourceLoader.exists("res://assets/art/leo_wizard_celebrate_gen_25d.png"):
		_tex_celebrate = load("res://assets/art/leo_wizard_celebrate_gen_25d.png")
		_tex_jump = _tex_celebrate
	elif ResourceLoader.exists("res://assets/characters/wizard/wizard_special.png"):
		_tex_celebrate = load("res://assets/characters/wizard/wizard_special.png")
		_tex_jump = load("res://assets/characters/wizard/wizard_jump.png")


func _setup_nodes() -> void:
	_texture_rect = TextureRect.new()
	_texture_rect.name = "SpriteLeo"
	_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_texture_rect.texture = _tex_piano
	add_child(_texture_rect)

	# Hạt bụi tiên lấp lánh khi vung đũa thần
	_sparkles = CPUParticles2D.new()
	_sparkles.name = "WandSparkles"
	_sparkles.emitting = false
	_sparkles.one_shot = true
	_sparkles.amount = 14
	_sparkles.lifetime = 0.65
	_sparkles.explosiveness = 0.85
	_sparkles.direction = Vector2(1, -0.6)
	_sparkles.spread = 45.0
	_sparkles.initial_velocity_min = 60.0
	_sparkles.initial_velocity_max = 140.0
	_sparkles.scale_amount_min = 2.5
	_sparkles.scale_amount_max = 5.5
	_sparkles.color = Color("#FFEAA7")
	add_child(_sparkles)

	resized.connect(_update_layout)
	_update_layout()


func _update_layout() -> void:
	if _texture_rect != null:
		_texture_rect.position = Vector2.ZERO
		_texture_rect.size = size
		_texture_rect.pivot_offset = Vector2(size.x * 0.5, size.y * 0.85)

	if _sparkles != null:
		# Điểm phát bụi sao từ đầu đũa phép (khoảng 78% X, 22% Y theo sprite Leo mới)
		_sparkles.position = Vector2(size.x * 0.78, size.y * 0.22)


## Cập nhật nhịp BPM để nhún nhảy chuẩn nhịp bài hát
func set_bpm(bpm: float) -> void:
	_bpm = maxf(40.0, bpm)
	_start_idle_bounce()


func _start_idle_bounce() -> void:
	if _bounce_tween != null and _bounce_tween.is_valid():
		_bounce_tween.kill()

	if _current_state != AnimState.PIANO and _current_state != AnimState.IDLE:
		return

	var beat_duration := 60.0 / _bpm
	_bounce_tween = create_tween().set_loops().bind_node(self)
	_bounce_tween.tween_property(_texture_rect, "scale", Vector2(1.03, 0.96), beat_duration * 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_bounce_tween.tween_property(_texture_rect, "scale", Vector2(0.98, 1.02), beat_duration * 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Khi bé gõ nốt đàn: Leo gật đầu và nhấn đàn theo nhịp, giữ nguyên tư thế ngồi đàn
func play_cast() -> void:
	if _current_state == AnimState.CELEBRATE:
		return

	_current_state = AnimState.CAST

	# Tuyệt đối giữ nguyên texture ngồi đàn (_tex_piano), KHÔNG đổi ảnh gây chóng mặt!
	if _texture_rect != null and _tex_piano != null and _texture_rect.texture != _tex_piano:
		_texture_rect.texture = _tex_piano

	if _sparkles != null:
		_sparkles.restart()

	if _bounce_tween != null and _bounce_tween.is_valid():
		_bounce_tween.kill()
	if _action_tween != null and _action_tween.is_valid():
		_action_tween.kill()

	# Nhún nảy nhẹ nhàng, êm dịu, không giật lắc (squash & stretch 4% vui nhộn cho trẻ nhỏ)
	_action_tween = create_tween().bind_node(self)
	_action_tween.tween_property(_texture_rect, "scale", Vector2(1.04, 0.96), 0.08) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_action_tween.tween_property(_texture_rect, "scale", Vector2(0.98, 1.02), 0.10) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_action_tween.tween_property(_texture_rect, "scale", Vector2(1.0, 1.0), 0.08) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_action_tween.finished.connect(func():
		_current_state = AnimState.PIANO
		_start_idle_bounce()
	)


## Khi bé đạt combo hoặc hoàn thành 1 câu hát: Leo nhún nhảy vui vẻ bên đàn
func play_jump() -> void:
	if _current_state == AnimState.CELEBRATE:
		return

	_current_state = AnimState.JUMP
	# Giữ nguyên texture ngồi đàn
	if _texture_rect != null and _tex_piano != null and _texture_rect.texture != _tex_piano:
		_texture_rect.texture = _tex_piano

	if _bounce_tween != null and _bounce_tween.is_valid():
		_bounce_tween.kill()
	if _action_tween != null and _action_tween.is_valid():
		_action_tween.kill()

	_action_tween = create_tween().bind_node(self)
	_action_tween.tween_property(_texture_rect, "scale", Vector2(1.07, 0.93), 0.10) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_action_tween.tween_property(_texture_rect, "scale", Vector2(0.96, 1.04), 0.12) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_action_tween.tween_property(_texture_rect, "scale", Vector2(1.0, 1.0), 0.10) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_action_tween.finished.connect(func():
		_current_state = AnimState.PIANO
		_start_idle_bounce()
	)


## Khi hoàn thành cả bài hát: Leo bay bổng ăn mừng (chỉ chuyển ảnh khi kết bài)
func play_celebrate() -> void:
	_current_state = AnimState.CELEBRATE
	if _tex_celebrate != null and _texture_rect != null:
		_texture_rect.texture = _tex_celebrate

	if _bounce_tween != null and _bounce_tween.is_valid():
		_bounce_tween.kill()
	if _action_tween != null and _action_tween.is_valid():
		_action_tween.kill()

	_action_tween = create_tween().set_loops().bind_node(self)
	_action_tween.tween_property(_texture_rect, "position:y", -12.0, 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_action_tween.tween_property(_texture_rect, "position:y", 4.0, 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Đặt lại trạng thái về ban đầu khi sang bài hát mới
func reset_to_piano() -> void:
	_current_state = AnimState.PIANO
	if _action_tween != null and _action_tween.is_valid():
		_action_tween.kill()
	if _bounce_tween != null and _bounce_tween.is_valid():
		_bounce_tween.kill()
	if _texture_rect != null and _tex_piano != null:
		_texture_rect.texture = _tex_piano
		_texture_rect.position = Vector2.ZERO
		_texture_rect.scale = Vector2.ONE
	_start_idle_bounce()
