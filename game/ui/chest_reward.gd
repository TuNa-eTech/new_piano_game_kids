class_name ChestReward
extends PauseOverlay
## Màn Mở Rương Báu Thần & Trao Huy Hiệu Thú Cưng 3D (Peak Dopamine Reward).
## Thiết kế khớp 100% với mock-chest-reward.jpeg và tài liệu art-pipeline-chest-reward-2.5d.md.
##
## Thẩm mỹ Sách Tranh Nổi 2.5D Diorama:
## - Toàn cảnh sân khấu rừng cổ tích với nhà nấm, thạch anh và bảng ma thuật viền vàng mở
## - Rương gỗ mạ vàng bung nắp (spr_chest_open_gold.png) tỏa hào quang rực rỡ
## - Suối sao vàng tuôn trào và pháo hoa giấy ngũ sắc bay lượn
## - Huy hiệu Thú 3D Sư Tử Nhạc Sĩ (spr_badge_lion_maestro_3d.png) bay lơ lửng bồng bềnh
## - Chú Phù Thủy nhỏ (spr_wizard_boy_clapping.png) vỗ tay chúc mừng bé
## - Khung tranh vinh danh tiến trình bộ sưu tập (spr_frame_progress_wood.png)
## - Nút bấm chạm khắc gỗ xúc giác 'NHẬN THƯỞNG 🌿' (ui_btn_claim_wood.png)

signal reward_claimed(badge_index: int)

# --- Nodes & Thành phần 2.5D ---
var _stage: Control
var _bg_texture: Texture2D
var _sunburst_rect: ColorRect
var _chest_sprite: TextureRect
var _badge_container: Control
var _badge_sprite: TextureRect
var _wizard_sprite: TextureRect
var _frame_sprite: TextureRect
var _claim_btn: TextureButton
var _flash_rect: ColorRect
var _fountain_layer: ChestStarlightFountain
var _confetti_layer: ChestConfettiLayer

var _current_badge: int = 0
var _time: float = 0.0
var _entrance_tween: Tween


func _ready() -> void:
	super()
	layer = 12
	_build()
	_set_controls_visible(false)


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta

	# 1. Hoạt ảnh lơ lửng bồng bềnh của Huy hiệu Thú 3D
	if _badge_container != null and is_instance_valid(_badge_container):
		var float_y := sin(_time * 2.8) * 8.0
		var float_tilt := sin(_time * 2.0) * 0.03
		_badge_container.position.y = float_y
		_badge_container.rotation = float_tilt

	# 2. Hoạt ảnh vỗ tay & nhún nhảy hoan hỉ của Chú Phù Thủy nhỏ
	if _wizard_sprite != null and is_instance_valid(_wizard_sprite):
		var hop_y := sin(_time * 5.2) * 5.0
		var hop_tilt := sin(_time * 3.4) * 0.02
		_wizard_sprite.position.y = hop_y
		_wizard_sprite.rotation = hop_tilt

	# 3. Hoạt ảnh nhịp thở tự nhiên của Rương báu mở nắp
	if _chest_sprite != null and is_instance_valid(_chest_sprite):
		var chest_breathe := 1.0 + 0.015 * sin(_time * 2.4)
		_chest_sprite.scale = Vector2(chest_breathe, chest_breathe)

	# 4. Hoạt ảnh nhún nhảy mời gọi của Nút Nhận Thưởng
	if _claim_btn != null and is_instance_valid(_claim_btn):
		var btn_pulse := 1.0 + 0.028 * sin(_time * 3.6)
		_claim_btn.scale = Vector2(btn_pulse, btn_pulse)

	# 5. Khung tranh vinh danh lơ lửng nhẹ
	if _frame_sprite != null and is_instance_valid(_frame_sprite):
		_frame_sprite.position.y = sin(_time * 1.8 + 0.5) * 3.0


func _build() -> void:
	_add_backdrop(Color(0.02, 0.04, 0.03, 0.94))

	# Khung sân khấu chính để quản lý phối cảnh 2.5D
	_stage = Control.new()
	_stage.name = "DioramaStage"
	_stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	_stage.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_stage)

	# 1. Phông nền toàn cảnh Sân Khấu Rừng & Nhà Nấm từ mock-chest-reward.jpeg
	if ResourceLoader.exists("res://docs/mock-chest-reward.jpeg"):
		_bg_texture = load("res://docs/mock-chest-reward.jpeg")

	var bg_rect := TextureRect.new()
	bg_rect.name = "BackgroundDiorama"
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _bg_texture != null:
		bg_rect.texture = _bg_texture
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	_stage.add_child(bg_rect)

	# 2. Hào quang tia sáng mặt trời xoay chậm sau huy hiệu (Sunburst God Rays)
	_build_sunburst()

	# 3. Rương báu mở nắp tỏa hào quang (spr_chest_open_gold.png)
	_build_chest_actor()

	# 4. Suối hạt sao vàng tuôn trào & Pháo hoa giấy ngũ sắc
	_fountain_layer = ChestStarlightFountain.new()
	_fountain_layer.name = "StarlightFountain"
	_fountain_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fountain_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_fountain_layer)

	_confetti_layer = ChestConfettiLayer.new()
	_confetti_layer.name = "ConfettiLayer"
	_confetti_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_confetti_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_confetti_layer)

	# 5. Huy hiệu Thú 3D Sư Tử Nhạc Sĩ (spr_badge_lion_maestro_3d.png)
	_build_hero_badge()

	# 6. Chú Phù Thủy nhỏ vỗ tay chúc mừng (spr_wizard_boy_clapping.png)
	_build_wizard_actor()

	# 7. Khung tranh gỗ vinh danh tiến trình (spr_frame_progress_wood.png)
	_build_progress_frame()

	# 8. Nút bấm chạm khắc gỗ xúc giác 'NHẬN THƯỞNG 🌿' (ui_btn_claim_wood.png)
	_build_claim_button()

	# 9. Lớp đom đóm lơ lửng rừng đêm
	var fireflies := MainMenu.FireflyOverlay.new()
	fireflies.name = "Fireflies"
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(fireflies)

	# 10. Lớp chớp sáng màn hình khi mở rương (Golden Flash)
	_flash_rect = ColorRect.new()
	_flash_rect.name = "GoldenFlash"
	_flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash_rect.color = Color(1.0, 0.95, 0.6, 0.0)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_flash_rect)


## Xây dựng hào quang tia nắng mặt trời xoay tròn
func _build_sunburst() -> void:
	_sunburst_rect = ColorRect.new()
	_sunburst_rect.name = "SunburstGodRays"
	_sunburst_rect.anchor_left = 0.32
	_sunburst_rect.anchor_top = 0.06
	_sunburst_rect.anchor_right = 0.72
	_sunburst_rect.anchor_bottom = 0.58
	_sunburst_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if ResourceLoader.exists("res://assets/art/sh_godray_sunburst.gdshader"):
		var shader: Shader = load("res://assets/art/sh_godray_sunburst.gdshader")
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("ray_color", Color(1.0, 0.88, 0.45, 0.40))
		mat.set_shader_parameter("ray_count", 18.0)
		mat.set_shader_parameter("rotate_speed", 0.35)
		mat.set_shader_parameter("inner_fade", 0.12)
		_sunburst_rect.material = mat
	_stage.add_child(_sunburst_rect)


## Xây dựng sprite Rương báu mở nắp 2.5D
func _build_chest_actor() -> void:
	_chest_sprite = TextureRect.new()
	_chest_sprite.name = "ChestOpenGold"
	_chest_sprite.anchor_left = 0.390
	_chest_sprite.anchor_top = 0.470
	_chest_sprite.anchor_right = 0.655
	_chest_sprite.anchor_bottom = 0.755
	_chest_sprite.pivot_offset = Vector2(250, 200)

	if ResourceLoader.exists("res://assets/art/spr_chest_open_gold.png"):
		_chest_sprite.texture = load("res://assets/art/spr_chest_open_gold.png")
	_chest_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_chest_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_chest_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_chest_sprite)


## Xây dựng cụm Huy hiệu Thú 3D bay bổng
func _build_hero_badge() -> void:
	_badge_container = Control.new()
	_badge_container.name = "BadgeHeroContainer"
	_badge_container.anchor_left = 0.405
	_badge_container.anchor_top = 0.150
	_badge_container.anchor_right = 0.635
	_badge_container.anchor_bottom = 0.510
	_badge_container.pivot_offset = Vector2(220, 190)
	_badge_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_badge_sprite = TextureRect.new()
	_badge_sprite.name = "BadgeLionSprite"
	_badge_sprite.set_anchors_preset(Control.PRESET_FULL_RECT)

	if ResourceLoader.exists("res://assets/art/spr_badge_lion_maestro_3d.png"):
		_badge_sprite.texture = load("res://assets/art/spr_badge_lion_maestro_3d.png")
	_badge_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_badge_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_badge_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Gắn shader ánh kim lấp lánh chạy qua huy hiệu
	if ResourceLoader.exists("res://assets/art/sh_badge_golden_shine.gdshader"):
		var shader: Shader = load("res://assets/art/sh_badge_golden_shine.gdshader")
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("shine_speed", 1.4)
		mat.set_shader_parameter("shine_width", 0.18)
		mat.set_shader_parameter("shine_color", Color(1.0, 1.0, 0.9, 0.65))
		_badge_sprite.material = mat

	_badge_container.add_child(_badge_sprite)
	_stage.add_child(_badge_container)


## Xây dựng Chú Phù Thủy nhỏ vỗ tay
func _build_wizard_actor() -> void:
	_wizard_sprite = TextureRect.new()
	_wizard_sprite.name = "WizardBoyActor"
	_wizard_sprite.anchor_left = 0.205
	_wizard_sprite.anchor_top = 0.290
	_wizard_sprite.anchor_right = 0.365
	_wizard_sprite.anchor_bottom = 0.770
	_wizard_sprite.pivot_offset = Vector2(150, 350)

	if ResourceLoader.exists("res://assets/art/spr_wizard_boy_clapping.png"):
		_wizard_sprite.texture = load("res://assets/art/spr_wizard_boy_clapping.png")
	_wizard_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_wizard_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_wizard_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_wizard_sprite)


## Xây dựng Khung tranh vinh danh tiến trình bên trái
func _build_progress_frame() -> void:
	_frame_sprite = TextureRect.new()
	_frame_sprite.name = "ProgressFrame"
	_frame_sprite.anchor_left = 0.080
	_frame_sprite.anchor_top = 0.200
	_frame_sprite.anchor_right = 0.230
	_frame_sprite.anchor_bottom = 0.580
	_frame_sprite.pivot_offset = Vector2(140, 200)

	if ResourceLoader.exists("res://assets/art/spr_frame_progress_wood.png"):
		_frame_sprite.texture = load("res://assets/art/spr_frame_progress_wood.png")
	_frame_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_frame_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_frame_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_frame_sprite)


## Xây dựng Nút Nhận Thưởng to tròn chạm khắc gỗ
func _build_claim_button() -> void:
	_claim_btn = TextureButton.new()
	_claim_btn.name = "BtnClaimWood"
	_claim_btn.anchor_left = 0.365
	_claim_btn.anchor_top = 0.675
	_claim_btn.anchor_right = 0.645
	_claim_btn.anchor_bottom = 0.800
	_claim_btn.pivot_offset = Vector2(270, 70)
	_claim_btn.focus_mode = Control.FOCUS_NONE
	_claim_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_claim_btn.ignore_texture_size = true
	_claim_btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

	if ResourceLoader.exists("res://assets/ui/ui_btn_claim_wood.png"):
		_claim_btn.texture_normal = load("res://assets/ui/ui_btn_claim_wood.png")

	_claim_btn.pressed.connect(_on_claim_pressed)
	_stage.add_child(_claim_btn)

	# Vòng hào quang vàng nhấp nháy trên nút Nhận Thưởng
	var aura := MainMenu.PlayButtonAura.new(_claim_btn)
	aura.name = "ButtonAura"
	aura.set_anchors_preset(Control.PRESET_FULL_RECT)
	aura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(aura)


## Kích hoạt mở màn hình phần thưởng với hoạt cảnh bùng nổ Dopamine
func open_for_chapter(chapter: int) -> void:
	_current_badge = clampi(chapter, 0, 6)

	# Âm thanh mở rương & chuông thần
	_play_sfx("chest_open")
	_play_sfx("star_ting")
	_play_sfx("fairy_dust")
	_play_note(_current_badge, 4, 0.0)

	open_overlay()
	_trigger_entrance_animation()


func show_reward(chapter: int) -> void:
	open_for_chapter(chapter)


## Hoạt cảnh xuất hiện hoành tráng (Entrance Dopamine Burst)
func _trigger_entrance_animation() -> void:
	if _entrance_tween != null and _entrance_tween.is_valid():
		_entrance_tween.kill()

	_entrance_tween = create_tween().set_parallel(true)

	# 1. Chớp sáng vàng rực rỡ từ miệng rương
	if _flash_rect != null:
		_flash_rect.color.a = 0.38
		_entrance_tween.tween_property(_flash_rect, "color:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# 2. Rương báu nảy mở đàn hồi
	if _chest_sprite != null:
		_chest_sprite.scale = Vector2(0.6, 0.6)
		_entrance_tween.tween_property(_chest_sprite, "scale", Vector2.ONE, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# 3. Huy hiệu 3D phóng từ trong rương vút lên cao rồi bung nở
	if _badge_container != null:
		_badge_container.scale = Vector2(0.1, 0.1)
		_badge_container.position.y = 80.0
		_entrance_tween.tween_property(_badge_container, "scale", Vector2.ONE, 0.70).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		_entrance_tween.tween_property(_badge_container, "position:y", 0.0, 0.60).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# 4. Phù thủy nhỏ nhảy cẫng lên reo mừng
	if _wizard_sprite != null:
		_wizard_sprite.scale = Vector2(0.8, 0.8)
		_entrance_tween.tween_property(_wizard_sprite, "scale", Vector2.ONE, 0.48).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# 5. Kích hoạt bùng nổ suối sao & pháo giấy
	if _fountain_layer != null:
		_fountain_layer.burst()
	if _confetti_layer != null:
		_confetti_layer.burst()


## Xử lý khi bé chạm nút Nhận Thưởng
func _on_claim_pressed() -> void:
	_play_sfx("star_ting")

	# Hoạt ảnh co giãn đàn hồi (Squash & Stretch)
	if _claim_btn != null:
		var btn_tween := create_tween()
		btn_tween.tween_property(_claim_btn, "scale", Vector2(0.88, 0.88), 0.08)
		btn_tween.tween_property(_claim_btn, "scale", Vector2(1.08, 1.08), 0.10)
		btn_tween.tween_property(_claim_btn, "scale", Vector2.ONE, 0.08)
		await btn_tween.finished

	close_overlay()
	reward_claimed.emit(_current_badge)


func _play_sfx(sfx_name: String) -> void:
	if not is_inside_tree():
		return
	var ad := get_node_or_null("/root/AudioDirector")
	if ad != null and ad.has_method("play_sfx"):
		ad.play_sfx(sfx_name)


func _play_note(instrument_idx: int, note_idx: int, time: float = 0.0) -> void:
	if not is_inside_tree():
		return
	var ad := get_node_or_null("/root/AudioDirector")
	if ad != null and ad.has_method("play_instrument_note"):
		ad.play_instrument_note(instrument_idx, note_idx, time)




# ==============================================================================
# LỚP HIỆU ỨNG HẠT: SUỐI SAO VÀNG TUÔN TRÀO (ChestStarlightFountain)
# ==============================================================================
class ChestStarlightFountain extends Control:
	class StarParticle:
		var pos: Vector2
		var vel: Vector2
		var size: float
		var alpha: float
		var life: float
		var max_life: float
		var color: Color
		var rot: float
		var rot_speed: float

	var _particles: Array[StarParticle] = []
	var _rng := RandomNumberGenerator.new()

	func _ready() -> void:
		_rng.randomize()

	func _process(delta: float) -> void:
		var center_x := size.x * 0.52
		var emitter_y := size.y * 0.58

		# Sinh hạt liên tục nhẹ nhàng
		if _particles.size() < 40 and _rng.randf() < 0.45:
			_spawn_particle(center_x, emitter_y)

		var surviving: Array[StarParticle] = []
		for p in _particles:
			p.life -= delta
			if p.life > 0.0:
				p.pos += p.vel * delta
				p.vel.y += 90.0 * delta # Trọng lực nhẹ
				p.vel.x += sin(p.life * 4.0) * 15.0 * delta # Lắc lư hình sin
				p.rot += p.rot_speed * delta
				p.alpha = clampf(p.life / p.max_life, 0.0, 1.0)
				surviving.append(p)
		_particles = surviving
		queue_redraw()

	func burst() -> void:
		var center_x := size.x * 0.52
		var emitter_y := size.y * 0.58
		for i in range(25):
			_spawn_particle(center_x, emitter_y, true)

	func _spawn_particle(x: float, y: float, is_burst: bool = false) -> void:
		var p := StarParticle.new()
		p.pos = Vector2(x + _rng.randf_range(-70.0, 70.0), y + _rng.randf_range(-15.0, 15.0))
		var speed := _rng.randf_range(160.0, 320.0) if is_burst else _rng.randf_range(100.0, 220.0)
		var angle := _rng.randf_range(-PI * 0.75, -PI * 0.25)
		p.vel = Vector2(cos(angle), sin(angle)) * speed
		p.size = _rng.randf_range(5.0, 13.0)
		p.max_life = _rng.randf_range(1.4, 2.5)
		p.life = p.max_life
		p.alpha = 1.0
		p.rot = _rng.randf_range(0.0, TAU)
		p.rot_speed = _rng.randf_range(-4.0, 4.0)

		var colors := [
			Color(1.0, 0.95, 0.65), # Vàng kem sáng
			Color(1.0, 0.85, 0.30), # Vàng kim rực rỡ
			Color(0.6, 0.95, 0.90), # Cyan thạch anh
			Color(1.0, 0.70, 0.85)  # Hồng sen
		]
		p.color = colors[_rng.randi() % colors.size()]
		_particles.append(p)

	func _draw() -> void:
		for p in _particles:
			var draw_col := Color(p.color.r, p.color.g, p.color.b, p.alpha * 0.9)
			# Vẽ ngôi sao 4 cánh bo góc lấp lánh
			var s := p.size
			var pts: PackedVector2Array = [
				p.pos + Vector2(0, -s).rotated(p.rot),
				p.pos + Vector2(s * 0.25, -s * 0.25).rotated(p.rot),
				p.pos + Vector2(s, 0).rotated(p.rot),
				p.pos + Vector2(s * 0.25, s * 0.25).rotated(p.rot),
				p.pos + Vector2(0, s).rotated(p.rot),
				p.pos + Vector2(-s * 0.25, s * 0.25).rotated(p.rot),
				p.pos + Vector2(-s, 0).rotated(p.rot),
				p.pos + Vector2(-s * 0.25, -s * 0.25).rotated(p.rot)
			]
			draw_colored_polygon(pts, draw_col)
			# Tâm sáng trắng
			draw_circle(p.pos, s * 0.28, Color(1.0, 1.0, 1.0, p.alpha))


# ==============================================================================
# LỚP HIỆU ỨNG HẠT: PHÁO HOA GIẤY NGŨ SẮC (ChestConfettiLayer)
# ==============================================================================
class ChestConfettiLayer extends Control:
	class ConfettiPiece:
		var pos: Vector2
		var vel: Vector2
		var size: Vector2
		var rot: float
		var rot_speed: float
		var color: Color
		var life: float
		var max_life: float

	var _pieces: Array[ConfettiPiece] = []
	var _rng := RandomNumberGenerator.new()

	func _ready() -> void:
		_rng.randomize()

	func _process(delta: float) -> void:
		var surviving: Array[ConfettiPiece] = []
		for c in _pieces:
			c.life -= delta
			if c.life > 0.0:
				c.pos += c.vel * delta
				c.vel.y += 120.0 * delta # Trọng lực rơi
				c.vel.x += sin(c.life * 3.0) * 20.0 * delta
				c.rot += c.rot_speed * delta
				surviving.append(c)
		_pieces = surviving
		queue_redraw()

	func burst() -> void:
		var center_x := size.x * 0.52
		var emitter_y := size.y * 0.45
		var palette := [
			Color(0.95, 0.35, 0.45), # Hồng sen
			Color(0.30, 0.85, 0.80), # Cyan
			Color(1.00, 0.85, 0.25), # Vàng kim
			Color(0.70, 0.40, 0.90), # Tím thạch anh
			Color(0.40, 0.85, 0.45)  # Xanh rêu
		]
		for i in range(35):
			var c := ConfettiPiece.new()
			c.pos = Vector2(center_x + _rng.randf_range(-120.0, 120.0), emitter_y + _rng.randf_range(-50.0, 20.0))
			var speed := _rng.randf_range(120.0, 280.0)
			var angle := _rng.randf_range(-PI * 0.85, -PI * 0.15)
			c.vel = Vector2(cos(angle), sin(angle)) * speed
			c.size = Vector2(_rng.randf_range(6.0, 14.0), _rng.randf_range(4.0, 8.0))
			c.rot = _rng.randf_range(0.0, TAU)
			c.rot_speed = _rng.randf_range(-5.0, 5.0)
			c.color = palette[_rng.randi() % palette.size()]
			c.max_life = _rng.randf_range(2.0, 3.5)
			c.life = c.max_life
			_pieces.append(c)

	func _draw() -> void:
		for c in _pieces:
			var alpha := clampf(c.life / c.max_life, 0.0, 1.0)
			var draw_col := Color(c.color.r, c.color.g, c.color.b, alpha)
			var half_size := c.size * 0.5
			var pts: PackedVector2Array = [
				c.pos + Vector2(-half_size.x, -half_size.y).rotated(c.rot),
				c.pos + Vector2(half_size.x, -half_size.y).rotated(c.rot),
				c.pos + Vector2(half_size.x, half_size.y).rotated(c.rot),
				c.pos + Vector2(-half_size.x, half_size.y).rotated(c.rot)
			]
			draw_colored_polygon(pts, draw_col)
