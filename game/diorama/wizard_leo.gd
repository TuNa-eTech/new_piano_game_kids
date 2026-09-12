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
enum FaceExpr { FOCUSED, HAPPY, STAR_EYES, WINK, CELEBRATE }

var _current_state: AnimState = AnimState.PIANO
var _current_expr: FaceExpr = FaceExpr.FOCUSED
var _texture_rect: TextureRect
var _sparkles: CPUParticles2D
var _bounce_tween: Tween
var _action_tween: Tween
var _expr_tween: Tween
var _bpm: float = 80.0

var _tex_focused: Texture2D
var _tex_happy: Texture2D
var _tex_star_eyes: Texture2D
var _tex_wink: Texture2D
var _tex_piano: Texture2D
var _tex_idle: Texture2D
var _tex_cast: Texture2D
var _tex_jump: Texture2D
var _tex_celebrate: Texture2D

var _note_container: Control


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_setup_textures()
	_setup_nodes()
	set_bpm(_bpm)


func _setup_textures() -> void:
	if ResourceLoader.exists("res://assets/art/leo_wizard_piano_gen_25d.png"):
		_tex_focused = load("res://assets/art/leo_wizard_piano_gen_25d.png")
		_tex_piano = _tex_focused
	elif ResourceLoader.exists("res://assets/art/wizard_piano.png"):
		_tex_focused = load("res://assets/art/wizard_piano.png")
		_tex_piano = _tex_focused

	if ResourceLoader.exists("res://assets/art/leo_wizard_piano_happy.png"):
		_tex_happy = load("res://assets/art/leo_wizard_piano_happy.png")
	else:
		_tex_happy = _tex_focused

	if ResourceLoader.exists("res://assets/art/leo_wizard_piano_star_eyes.png"):
		_tex_star_eyes = load("res://assets/art/leo_wizard_piano_star_eyes.png")
	else:
		_tex_star_eyes = _tex_focused

	if ResourceLoader.exists("res://assets/art/leo_wizard_piano_wink.png"):
		_tex_wink = load("res://assets/art/leo_wizard_piano_wink.png")
	else:
		_tex_wink = _tex_focused

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

	# Lớp chứa nốt nhạc bay lượn từ phím đàn
	_note_container = Control.new()
	_note_container.name = "NoteContainer"
	_note_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_note_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_note_container)

	# Hạt bụi tiên lấp lánh khi đánh đàn
	_sparkles = CPUParticles2D.new()
	_sparkles.name = "WandSparkles"
	_sparkles.emitting = false
	_sparkles.one_shot = true
	_sparkles.amount = 16
	_sparkles.lifetime = 0.60
	_sparkles.explosiveness = 0.85
	_sparkles.direction = Vector2(1, -0.7)
	_sparkles.spread = 50.0
	_sparkles.initial_velocity_min = 70.0
	_sparkles.initial_velocity_max = 160.0
	_sparkles.scale_amount_min = 2.5
	_sparkles.scale_amount_max = 5.5
	_sparkles.color = Color("#FFEAA7")
	add_child(_sparkles)

	gui_input.connect(_on_gui_input)
	resized.connect(_update_layout)
	_update_layout()


func _update_layout() -> void:
	if _texture_rect != null:
		_texture_rect.position = Vector2.ZERO
		_texture_rect.size = size
		_texture_rect.pivot_offset = Vector2(size.x * 0.45, size.y * 0.90)

	if _sparkles != null:
		# Điểm phát bụi sao từ bàn phím mini của Leo
		_sparkles.position = Vector2(size.x * 0.55, size.y * 0.62)

	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	# Bóng đổ tiếp xúc 2.5D ấm áp, mềm mại dưới chân ghế và chân đàn
	_draw_soft_ellipse(Vector2(size.x * 0.24, size.y * 0.94), size.x * 0.14, size.y * 0.038, 0.28)
	_draw_soft_ellipse(Vector2(size.x * 0.58, size.y * 0.96), size.x * 0.26, size.y * 0.048, 0.32)


func _draw_soft_ellipse(center: Vector2, rx: float, ry: float, max_alpha: float = 0.30) -> void:
	var steps := 5
	for i in range(steps, 0, -1):
		var t := float(i) / float(steps)
		var layer_alpha := max_alpha * (1.0 - t * 0.7) * (1.0 / float(steps)) * 2.0
		var cur_rx := rx * t
		var cur_ry := ry * t
		draw_set_transform(center, 0.0, Vector2(1.0, cur_ry / maxf(cur_rx, 0.1)))
		draw_circle(Vector2.ZERO, cur_rx, Color(0.10, 0.06, 0.03, layer_alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _on_gui_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		AudioDirector.play_sfx("soft_boing")
		play_jump()


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
	# Nhịp 1: Gật gù nhún nhẹ nghiêng sang phải
	_bounce_tween.tween_property(_texture_rect, "scale", Vector2(1.018, 0.982), beat_duration * 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_bounce_tween.parallel().tween_property(_texture_rect, "rotation", deg_to_rad(0.8), beat_duration * 0.5)
	# Nhịp 2: Nảy người nhẹ nghiêng sang trái
	_bounce_tween.tween_property(_texture_rect, "scale", Vector2(0.985, 1.015), beat_duration * 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_bounce_tween.parallel().tween_property(_texture_rect, "rotation", deg_to_rad(-0.8), beat_duration * 0.5)


## Đổi biểu cảm khuôn mặt và tư thế cho Leo
func set_expression(expr: FaceExpr, duration: float = 1.2) -> void:
	if _current_state == AnimState.CELEBRATE and expr != FaceExpr.CELEBRATE:
		return

	_current_expr = expr
	var target_tex: Texture2D = _tex_focused
	match expr:
		FaceExpr.FOCUSED:
			target_tex = _tex_focused
		FaceExpr.HAPPY:
			target_tex = _tex_happy
		FaceExpr.STAR_EYES:
			target_tex = _tex_star_eyes
		FaceExpr.WINK:
			target_tex = _tex_wink
		FaceExpr.CELEBRATE:
			target_tex = _tex_celebrate

	if _texture_rect != null and target_tex != null:
		_texture_rect.texture = target_tex

	if _expr_tween != null and _expr_tween.is_valid():
		_expr_tween.kill()

	if duration > 0.0 and expr != FaceExpr.FOCUSED and expr != FaceExpr.CELEBRATE:
		_expr_tween = create_tween().bind_node(self)
		_expr_tween.tween_interval(duration)
		_expr_tween.finished.connect(func():
			if _current_state != AnimState.CELEBRATE:
				set_expression(FaceExpr.FOCUSED, 0.0)
		)


## Thao tác Vung Tay Nghệ Sĩ (Maestro Flourish) khi hoàn thành câu hát hoặc combo lớn
func play_flourish() -> void:
	if _current_state == AnimState.CELEBRATE:
		return

	_current_state = AnimState.CAST
	set_expression(FaceExpr.STAR_EYES, 2.2)

	if _bounce_tween != null and _bounce_tween.is_valid():
		_bounce_tween.kill()
	if _action_tween != null and _action_tween.is_valid():
		_action_tween.kill()

	if _sparkles != null:
		_sparkles.restart()

	AudioDirector.play_sfx("fairy_dust")

	_action_tween = create_tween().bind_node(self)
	# 1. Vươn hai tay lên cao, ngửa người lấy đà hùng hồn
	_action_tween.tween_property(_texture_rect, "position:y", -16.0, 0.22) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_action_tween.parallel().tween_property(_texture_rect, "scale", Vector2(0.92, 1.10), 0.22)
	_action_tween.parallel().tween_property(_texture_rect, "rotation", deg_to_rad(3.5), 0.22)

	# 2. Giáng mạnh xuống đàn, phím bừng sáng rực rỡ
	_action_tween.tween_property(_texture_rect, "position:y", 8.0, 0.12) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_action_tween.parallel().tween_property(_texture_rect, "scale", Vector2(1.12, 0.88), 0.12)
	_action_tween.parallel().tween_property(_texture_rect, "rotation", deg_to_rad(-2.0), 0.12)

	# 3. Nẩy người bồng bềnh
	_action_tween.tween_property(_texture_rect, "position:y", -4.0, 0.18) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_action_tween.parallel().tween_property(_texture_rect, "scale", Vector2(0.98, 1.03), 0.18)
	_action_tween.parallel().tween_property(_texture_rect, "rotation", 0.0, 0.18)

	# 4. Trở về trạng thái cân bằng
	_action_tween.tween_property(_texture_rect, "position:y", 0.0, 0.15) \
		.set_trans(Tween.TRANS_SINE)
	_action_tween.parallel().tween_property(_texture_rect, "scale", Vector2.ONE, 0.15)

	_action_tween.finished.connect(func():
		_current_state = AnimState.PIANO
		_start_idle_bounce()
	)

	# Phun chùm nốt nhạc ma thuật rực rỡ sang cây đậu thần
	for i in 4:
		_spawn_floating_note(randi_range(0, 6))
	_spawn_key_sparkle(randi_range(0, 6))


## Khi bé gõ phím hoặc khi biểu diễn gọi mẫu: Leo thực hiện động tác đánh đàn theo nốt
func play_note(note_index: int = 3) -> void:
	if _current_state == AnimState.CELEBRATE:
		return

	_current_state = AnimState.CAST

	# Đổi biểu cảm sinh động theo cao độ:
	if note_index >= 5: # Nốt bổng: Nháy mắt tinh nghịch
		set_expression(FaceExpr.WINK, 0.8)
	elif note_index >= 3: # Nốt giữa: Cười tươi rạng rỡ
		set_expression(FaceExpr.HAPPY, 0.8)
	else: # Nốt trầm: Tập trung chăm chú
		set_expression(FaceExpr.FOCUSED, 0.8)

	if _sparkles != null:
		_sparkles.restart()

	if _bounce_tween != null and _bounce_tween.is_valid():
		_bounce_tween.kill()
	if _action_tween != null and _action_tween.is_valid():
		_action_tween.kill()

	# Nghiêng người và nhún tay theo cao độ nốt nhạc
	var target_rot := 0.0
	var offset_x := 0.0
	if note_index < 3: # Nốt trầm (C4, D4, E4): Nghiêng sang trái, cúi đầu sâu
		target_rot = deg_to_rad(-3.2)
		offset_x = -5.0
	elif note_index > 3: # Nốt bổng (A4, C5, D5): Rướn người về bên phải phím
		target_rot = deg_to_rad(3.5)
		offset_x = 5.0
	else: # Nốt giữa (G4): Gật thẳng dứt khoát
		target_rot = deg_to_rad(0.6)
		offset_x = 0.0

	_action_tween = create_tween().bind_node(self)
	# 1. Nhấn người & bàn tay lướt xuống phím đàn
	_action_tween.tween_property(_texture_rect, "position", Vector2(offset_x, 6.0), 0.07) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_action_tween.parallel().tween_property(_texture_rect, "rotation", target_rot, 0.07)
	_action_tween.parallel().tween_property(_texture_rect, "scale", Vector2(1.06, 0.92), 0.07)

	# 2. Nẩy người bật lên, nón phù thủy lắc nhẹ đàn hồi (overshoot)
	_action_tween.tween_property(_texture_rect, "position", Vector2(offset_x * 0.3, -5.0), 0.10) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_action_tween.parallel().tween_property(_texture_rect, "rotation", -target_rot * 0.4, 0.10)
	_action_tween.parallel().tween_property(_texture_rect, "scale", Vector2(0.96, 1.05), 0.10)

	# 3. Lắc nhẹ đàn hồi hồi phục về vị trí cân bằng
	_action_tween.tween_property(_texture_rect, "position", Vector2.ZERO, 0.09) \
		.set_trans(Tween.TRANS_SINE)
	_action_tween.parallel().tween_property(_texture_rect, "rotation", 0.0, 0.09)
	_action_tween.parallel().tween_property(_texture_rect, "scale", Vector2.ONE, 0.09)

	_action_tween.finished.connect(func():
		_current_state = AnimState.PIANO
		_start_idle_bounce()
	)

	# Hiệu ứng nốt nhạc ma thuật và quầng sáng phím đàn
	_spawn_key_sparkle(note_index)
	_spawn_floating_note(note_index)


## Hiệu ứng quầng sáng phím đàn mini khi Leo đánh
func _spawn_key_sparkle(note_index: int) -> void:
	if _note_container == null:
		return
	var col: Color = Notes.color_of(note_index)
	var key_pos := Vector2(size.x * 0.56, size.y * 0.58)

	var ring := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(col.r, col.g, col.b, 0.70)
	sb.set_corner_radius_all(14)
	ring.add_theme_stylebox_override("panel", sb)
	ring.size = Vector2(20, 20)
	ring.pivot_offset = Vector2(10, 10)
	ring.position = key_pos - Vector2(10, 10)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_note_container.add_child(ring)

	var tw := create_tween().bind_node(ring)
	tw.tween_property(ring, "scale", Vector2(2.0, 2.0), 0.22) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(ring, "modulate:a", 0.0, 0.22)
	tw.finished.connect(ring.queue_free)


## Phun nốt nhạc ma thuật bay bổng từ phím đàn của Leo sang Cây Đậu Thần
func _spawn_floating_note(note_index: int) -> void:
	if _note_container == null:
		return

	var glyphs := ["♪", "♫", "♬", "♩"]
	var note_glyph: String = glyphs[posmod(note_index, glyphs.size())]
	var note_col: Color = Notes.color_of(note_index)

	var lbl := Label.new()
	lbl.text = note_glyph
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", note_col)
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))

	var start_pos := Vector2(size.x * 0.54 + randf_range(-14.0, 14.0), size.y * 0.60)
	lbl.position = start_pos
	lbl.scale = Vector2(0.6, 0.6)
	lbl.pivot_offset = Vector2(11, 11)
	_note_container.add_child(lbl)

	var tw := create_tween().bind_node(lbl)
	var float_x := randf_range(25.0, 55.0)
	var float_y := randf_range(-65.0, -95.0)
	tw.tween_property(lbl, "position", start_pos + Vector2(float_x, float_y), 0.65) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(lbl, "scale", Vector2(1.25, 1.25), 0.30)
	tw.parallel().tween_property(lbl, "rotation", randf_range(-0.3, 0.4), 0.65)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.35).set_delay(0.30)
	tw.finished.connect(lbl.queue_free)


## Giữ tương thích ngược với play_cast
func play_cast() -> void:
	play_note(3)


## Khi bé đạt combo hoặc chạm vào Leo: Leo nhún nhảy vui vẻ bên đàn
func play_jump() -> void:
	if _current_state == AnimState.CELEBRATE:
		return

	_current_state = AnimState.JUMP
	set_expression(FaceExpr.WINK, 1.2)

	if _bounce_tween != null and _bounce_tween.is_valid():
		_bounce_tween.kill()
	if _action_tween != null and _action_tween.is_valid():
		_action_tween.kill()

	if _sparkles != null:
		_sparkles.restart()

	_action_tween = create_tween().bind_node(self)
	# Nhún lấy đà
	_action_tween.tween_property(_texture_rect, "position:y", 6.0, 0.08) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_action_tween.parallel().tween_property(_texture_rect, "scale", Vector2(1.08, 0.92), 0.08)
	# Bật nảy vui vẻ
	_action_tween.tween_property(_texture_rect, "position:y", -12.0, 0.14) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_action_tween.parallel().tween_property(_texture_rect, "scale", Vector2(0.95, 1.06), 0.14)
	_action_tween.parallel().tween_property(_texture_rect, "rotation", deg_to_rad(2.5), 0.14)
	# Tiếp đất êm
	_action_tween.tween_property(_texture_rect, "position:y", 0.0, 0.12) \
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_action_tween.parallel().tween_property(_texture_rect, "scale", Vector2.ONE, 0.12)
	_action_tween.parallel().tween_property(_texture_rect, "rotation", 0.0, 0.12)
	_action_tween.finished.connect(func():
		_current_state = AnimState.PIANO
		_start_idle_bounce()
	)


## Khi hoàn thành cả bài hát: Leo bay bổng ăn mừng (chỉ chuyển ảnh khi kết bài)
func play_celebrate() -> void:
	_current_state = AnimState.CELEBRATE
	set_expression(FaceExpr.CELEBRATE, 0.0)

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
	set_expression(FaceExpr.FOCUSED, 0.0)
	if _action_tween != null and _action_tween.is_valid():
		_action_tween.kill()
	if _bounce_tween != null and _bounce_tween.is_valid():
		_bounce_tween.kill()
	if _texture_rect != null:
		_texture_rect.position = Vector2.ZERO
		_texture_rect.scale = Vector2.ONE
	_start_idle_bounce()
