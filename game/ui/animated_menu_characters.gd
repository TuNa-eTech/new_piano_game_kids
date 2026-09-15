class_name AnimatedMenuCharacters
extends Control
## Hệ Thống Sân Khấu Hoạt Họa 2.5D Sống Động Cho Bé Phù Thủy & Chú Sư Tử Con.
##
## Thay vì chỉ đứng một chỗ và đổi texture, hai nhân vật thực sự CHẠY NHẢY, ĐUỔI BẮT,
## BIỂU DIỄN NHẠC KHÍ VÀ RỦ BÉ CHƠI khắp mặt bàn gỗ diorama theo các kịch bản sinh động:
##
## 1. KỊCH BẢN 1 (CHASE): Sư tử chạy trước, Phù thủy đuổi theo, nhảy qua nốt nhạc.
## 2. KỊCH BẢN 2 (INVITE PLAY): Chạy sang nút Khóa Son PLAY bên phải, chỉ tay rủ bé ấn chơi.
## 3. KỊCH BẢN 3 (CONCERT): Ra giữa sân khấu trước cuốn sách, hòa tấu đũa phép & gõ trống rộn ràng.
## 4. KỊCH BẢN 4 (TUMBLE): Sư tử nhào lộn ngã ngửa nũng nịu, phù thủy ngạc nhiên rồi cười đùa.
## 5. KỊCH BẢN 5 (NAP & WAKE): Chợp mắt nghỉ ngơi với "Zzz", chuông reo thức dậy nhảy múa.
##
## Đầy đủ bóng đổ tiếp xúc 2.5D (Contact Shadow) bám theo từng bước chân và độ cao nhảy.

enum AnimState {
	IDLE,
	WALK,
	JUMP,
	ATTACK,
	HIT,
	SLEEP,
	SPECIAL,
}

enum Scenario {
	CHASE,
	INVITE_PLAY,
	CONCERT,
	TUMBLE,
	REST,
}

signal state_changed(new_state: AnimState)

var current_state: AnimState = AnimState.IDLE

# Nút hiển thị
var _wizard_rect: TextureRect
var _lion_rect: TextureRect
var _bubble_label: Label
var _shadow_canvas: Control

# Bộ texture nạp sẵn cho 7 trạng thái
var _wizard_textures: Dictionary = {}
var _lion_textures: Dictionary = {}

# Bộ frame hoạt ảnh tuần tự đa frame (12 animation principles)
var _wizard_jump_frames: Array[Texture2D] = []
var _wizard_walk_frames: Array[Texture2D] = []
var _lion_jump_frames: Array[Texture2D] = []
var _lion_walk_frames: Array[Texture2D] = []
var _wizard_anim_timer: float = 0.0
var _lion_anim_timer: float = 0.0

# Tọa độ sân khấu thực tế trên bàn gỗ (Canvas 1280x720)
const GROUND_Y: float = 545.0
const HOME_WIZARD_X: float = 175.0
const HOME_LION_X: float = 305.0

# Vị trí thực tế động của 2 diễn viên
var _wizard_x: float = HOME_WIZARD_X
var _wizard_y_jump: float = 0.0
var _wizard_state: AnimState = AnimState.IDLE

var _lion_x: float = HOME_LION_X
var _lion_y_jump: float = 0.0
var _lion_state: AnimState = AnimState.IDLE

# Quản lý kịch bản và chu trình diễn
var _current_scenario: Scenario = Scenario.CHASE
var _scenario_index: int = 0
var _scenario_tween: Tween
var _state_timer: float = 0.0
var _total_inactivity_timer: float = 0.0
var _idle_action_timer: float = 0.0
var _is_interacting: bool = false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_load_textures()
	_setup_nodes()
	_reset_to_home()


func _exit_tree() -> void:
	_kill_scenario_tween()


func _load_textures() -> void:
	# 1. Nạp 7 trạng thái cơ bản
	var states := ["idle", "walk", "jump", "attack", "hit", "sleep", "special"]
	for s in states:
		var w_path := "res://assets/characters/wizard/wizard_%s.png" % s
		if ResourceLoader.exists(w_path):
			_wizard_textures[s] = load(w_path)
		elif FileAccess.file_exists(w_path):
			var img := Image.load_from_file(w_path)
			if img != null:
				_wizard_textures[s] = ImageTexture.create_from_image(img)

		var l_path := "res://assets/characters/lion/lion_%s.png" % s
		if ResourceLoader.exists(l_path):
			_lion_textures[s] = load(l_path)
		elif FileAccess.file_exists(l_path):
			var img := Image.load_from_file(l_path)
			if img != null:
				_lion_textures[s] = ImageTexture.create_from_image(img)

	# 2. Nạp chuỗi frame tuần tự (Anticipation -> Action -> Recovery)
	_wizard_jump_frames.clear()
	for i in 7:
		var p := "res://assets/characters/wizard/anims/jump/jump_%d.png" % i
		if ResourceLoader.exists(p):
			_wizard_jump_frames.append(load(p))

	# Ưu tiên dùng frame số 0 từ bộ sprite sheet mới cho IDLE (giày nguyên vẹn, dáng đứng chuẩn)
	if not _wizard_jump_frames.is_empty():
		_wizard_textures["idle"] = _wizard_jump_frames[0]

	_wizard_walk_frames.clear()
	for i in 6:
		var p := "res://assets/characters/wizard/anims/walk/walk_%d.png" % i
		if ResourceLoader.exists(p):
			_wizard_walk_frames.append(load(p))

	_lion_jump_frames.clear()
	for i in 8:
		var p := "res://assets/characters/lion/anims/jump/jump_%d.png" % i
		if ResourceLoader.exists(p):
			_lion_jump_frames.append(load(p))

	if not _lion_jump_frames.is_empty():
		_lion_textures["idle"] = _lion_jump_frames[0]

	# Chuỗi frame đi bộ của sư tử. Thư mục này có thể chưa được dựng; khi đó
	# _lion_walk_frames rỗng và mọi nhánh dùng nó đều tự lui về ảnh tĩnh
	# lion_walk.png, KHÔNG mượn tạm frame nhảy (nhảy và đi khác nhịp hoàn toàn).
	_lion_walk_frames.clear()
	for i in 8:
		var w := "res://assets/characters/lion/anims/walk/walk_%d.png" % i
		if ResourceLoader.exists(w):
			_lion_walk_frames.append(load(w))


func _setup_nodes() -> void:
	# 0. Lớp bóng đổ tiếp xúc 2.5D dưới chân trên mặt bàn
	_shadow_canvas = Control.new()
	_shadow_canvas.name = "ContactShadows"
	_shadow_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shadow_canvas.draw.connect(_on_draw_shadows)
	add_child(_shadow_canvas)

	# 1. Bé Phù Thủy (Kích thước 155x230, chân đặt tại GROUND_Y)
	_wizard_rect = TextureRect.new()
	_wizard_rect.name = "WizardSprite"
	_wizard_rect.size = Vector2(155, 230)
	_wizard_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_wizard_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_wizard_rect.pivot_offset = Vector2(77, 220)
	_wizard_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_wizard_rect.gui_input.connect(_on_wizard_gui_input)
	add_child(_wizard_rect)

	# 2. Chú Sư Tử Con (Kích thước 155x160, chân đặt tại GROUND_Y)
	_lion_rect = TextureRect.new()
	_lion_rect.name = "LionSprite"
	_lion_rect.size = Vector2(155, 160)
	_lion_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_lion_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_lion_rect.pivot_offset = Vector2(77, 150)
	_lion_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_lion_rect.gui_input.connect(_on_lion_gui_input)
	add_child(_lion_rect)

	# 3. Bong bóng biểu cảm / "Zzz" (vị trí thoáng trên đầu, có viền nét rõ ràng)
	_bubble_label = Label.new()
	_bubble_label.name = "ExpressionLabel"
	_bubble_label.position = Vector2(HOME_LION_X - 20, GROUND_Y - 265)
	_bubble_label.text = ""
	_bubble_label.add_theme_font_size_override("font_size", 28)
	_bubble_label.add_theme_color_override("font_color", Color(1.0, 0.98, 0.85, 1.0))
	_bubble_label.add_theme_color_override("font_outline_color", Color(0.20, 0.10, 0.03, 0.95))
	_bubble_label.add_theme_constant_override("outline_size", 6)
	_bubble_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bubble_label)


func _on_draw_shadows() -> void:
	# Vẽ 2 bóng đổ tiếp xúc 2.5D độc lập bám theo từng bước chân và độ cao nhảy
	var shadow_base := Color(0.04, 0.12, 0.03, 0.38)

	# Bóng Phù Thủy
	var w_fade := clampf(1.0 - _wizard_y_jump * 0.008, 0.3, 1.0)
	var w_scale_x: float = _wizard_rect.scale.x * w_fade
	var w_scale_y: float = 0.30 * _wizard_rect.scale.y * w_fade
	var w_col := Color(shadow_base.r, shadow_base.g, shadow_base.b, shadow_base.a * w_fade)
	_shadow_canvas.draw_set_transform(Vector2(_wizard_x, GROUND_Y + 2.0), 0.0, Vector2(w_scale_x, w_scale_y))
	_shadow_canvas.draw_circle(Vector2.ZERO, 38.0, w_col)

	# Bóng Sư Tử
	var l_fade := clampf(1.0 - _lion_y_jump * 0.008, 0.3, 1.0)
	var l_scale_x: float = _lion_rect.scale.x * l_fade
	var l_scale_y: float = 0.30 * _lion_rect.scale.y * l_fade
	var l_col := Color(shadow_base.r, shadow_base.g, shadow_base.b, shadow_base.a * l_fade)
	_shadow_canvas.draw_set_transform(Vector2(_lion_x, GROUND_Y + 2.0), 0.0, Vector2(l_scale_x, l_scale_y))
	_shadow_canvas.draw_circle(Vector2.ZERO, 40.0, l_col)


func _process(delta: float) -> void:
	_state_timer += delta
	_total_inactivity_timer += delta

	# Cập nhật vị trí hiển thị của 2 Sprite dựa trên toạ độ X và độ cao nhảy
	_wizard_rect.position = Vector2(_wizard_x - 77.0, GROUND_Y - 225.0 - _wizard_y_jump)
	_lion_rect.position = Vector2(_lion_x - 77.0, GROUND_Y - 155.0 - _lion_y_jump)

	# Bong bóng biểu cảm bám theo đỉnh đầu nhân vật
	if _bubble_label.text != "":
		var target_bubble_x: float = (_wizard_x + _lion_x) * 0.5 - 20.0
		_bubble_label.position.x = target_bubble_x
		_bubble_label.position.y = GROUND_Y - 265.0 - maxf(_wizard_y_jump, _lion_y_jump) * 0.5

	# Vi-hoạt ảnh khi đang ở thế IDLE (thở nhịp nhàng + mũ lắc lư + vẫy đuôi)
	if _wizard_state == AnimState.IDLE and not _is_interacting:
		var breath := sin(_state_timer * 2.5) * 0.025
		_wizard_rect.scale = Vector2(1.0 + breath, 1.0 - breath)
		_wizard_rect.rotation = sin(_state_timer * 2.0) * 0.025

	if _lion_state == AnimState.IDLE and not _is_interacting:
		var breath_l := sin(_state_timer * 2.8) * 0.025
		_lion_rect.scale = Vector2(1.0 - breath_l, 1.0 + breath_l)
		_lion_rect.rotation = -sin(_state_timer * 3.0) * 0.035

	# Cập nhật chuỗi frame tuần tự (12 Animation Principles)
	_wizard_anim_timer += delta
	_lion_anim_timer += delta

	if _wizard_state == AnimState.WALK and not _wizard_walk_frames.is_empty():
		var idx: int = int(_wizard_anim_timer * 7.5) % _wizard_walk_frames.size()
		_wizard_rect.texture = _wizard_walk_frames[idx]
	elif _wizard_state == AnimState.JUMP and not _wizard_jump_frames.is_empty():
		var idx: int = clamp(int(_wizard_anim_timer * 9.0), 0, _wizard_jump_frames.size() - 1)
		_wizard_rect.texture = _wizard_jump_frames[idx]

	if _lion_state == AnimState.WALK and not _lion_walk_frames.is_empty():
		var idx: int = int(_lion_anim_timer * 7.0) % _lion_walk_frames.size()
		_lion_rect.texture = _lion_walk_frames[idx]
	elif _lion_state == AnimState.JUMP and not _lion_jump_frames.is_empty():
		var idx: int = clamp(int(_lion_anim_timer * 9.5), 0, _lion_jump_frames.size() - 1)
		_lion_rect.texture = _lion_jump_frames[idx]

	# Cập nhật vẽ bóng đổ
	if _shadow_canvas != null:
		_shadow_canvas.queue_redraw()

	# Quản lý tự động chuyển kịch bản từ _process
	if not _is_interacting and (_scenario_tween == null or not _scenario_tween.is_valid()):
		_idle_action_timer += delta
		if _idle_action_timer >= 1.2:
			_idle_action_timer = 0.0
			_start_next_scenario()


# ==============================================================================
# HỆ THỐNG KỊCH BẢN SÂN KHẤU (STAGE CHOREOGRAPHY)
# ==============================================================================

func _start_next_scenario() -> void:
	if _is_interacting:
		return

	var scenarios := [
		Scenario.CHASE,
		Scenario.INVITE_PLAY,
		Scenario.CONCERT,
		Scenario.TUMBLE,
	]

	# Nếu không tương tác quá 40s -> chợp mắt ngủ ngắn
	if _total_inactivity_timer >= 40.0:
		_total_inactivity_timer = 0.0
		_run_scenario_rest()
		return

	_current_scenario = scenarios[_scenario_index % scenarios.size()]
	_scenario_index += 1

	match _current_scenario:
		Scenario.CHASE:
			_run_scenario_chase()
		Scenario.INVITE_PLAY:
			_run_scenario_invite_play()
		Scenario.CONCERT:
			_run_scenario_concert()
		Scenario.TUMBLE:
			_run_scenario_tumble()


## KỊCH BẢN 1: Đuổi bắt vui nhộn trên thảm rêu bên trái (không lấn sang sách)
func _run_scenario_chase() -> void:
	_kill_scenario_tween()
	_scenario_tween = create_tween()

	# 1. Sư tử vui vẻ chạy trước về mép thảm rêu bên phải (dừng trước sách tại X = 330)
	_scenario_tween.tween_callback(func():
		_set_lion_state(AnimState.WALK)
		_lion_rect.flip_h = false
		_bubble_label.text = "🐾"
	)
	_scenario_tween.tween_property(self, "_lion_x", 330.0, 0.9).set_trans(Tween.TRANS_SINE)

	# 2. Phù thủy bật nhảy lon ton đuổi theo
	_scenario_tween.parallel().tween_callback(func():
		_set_wizard_state(AnimState.JUMP)
	)
	_scenario_tween.parallel().tween_property(self, "_wizard_y_jump", 35.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_scenario_tween.tween_property(self, "_wizard_y_jump", 0.0, 0.18).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.WALK)
		_wizard_rect.flip_h = false
	)
	_scenario_tween.tween_property(self, "_wizard_x", 240.0, 0.8).set_trans(Tween.TRANS_SINE)

	# 3. Sư tử nhảy cẫng lên mừng rỡ và quay đầu lại nhìn phù thủy
	_scenario_tween.tween_callback(func():
		_set_lion_state(AnimState.JUMP)
		_lion_rect.flip_h = true
		_play_organic_sfx("soft_boing", -12.0)
	)
	_scenario_tween.tween_property(self, "_lion_y_jump", 45.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_scenario_tween.tween_property(self, "_lion_y_jump", 0.0, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	# 4. Cả hai đối diện nhau: Phù thủy vẫy trượng, Sư tử gõ nhịp
	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.ATTACK)
		_set_lion_state(AnimState.ATTACK)
		_bubble_label.text = "✨♬"
		_play_organic_sfx("giggle_cute", -11.0)
		_spawn_magic_notes_at(Vector2((_wizard_x + _lion_x) * 0.5, GROUND_Y - 130))
	)
	_scenario_tween.tween_interval(1.0)

	# 5. Cả hai cùng quay đầu chạy lon ton về lại vị trí gốc
	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.WALK)
		_set_lion_state(AnimState.WALK)
		_wizard_rect.flip_h = true
		_lion_rect.flip_h = true
		_bubble_label.text = ""
	)
	_scenario_tween.tween_property(self, "_wizard_x", HOME_WIZARD_X, 0.9).set_trans(Tween.TRANS_SINE)
	_scenario_tween.parallel().tween_property(self, "_lion_x", HOME_LION_X, 0.9).set_trans(Tween.TRANS_SINE)

	# 6. Về đến nhà, quay mặt lại tươi cười nghỉ ngơi
	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.IDLE)
		_set_lion_state(AnimState.IDLE)
		_wizard_rect.flip_h = false
		_lion_rect.flip_h = false
	)
	_scenario_tween.tween_interval(2.2)
	_scenario_tween.finished.connect(_on_scenario_finished)


## KỊCH BẢN 2: Đứng từ mép thảm rêu rủ bé chơi & chỉ về phía sách / nút PLAY
func _run_scenario_invite_play() -> void:
	_kill_scenario_tween()
	_scenario_tween = create_tween()

	# 1. Sư tử bước ra mép thảm rêu (X = 335, không bước lên sách)
	_scenario_tween.tween_callback(func():
		_set_lion_state(AnimState.WALK)
		_lion_rect.flip_h = false
		_bubble_label.text = "👉🎵"
	)
	_scenario_tween.tween_property(self, "_lion_x", 335.0, 0.8).set_trans(Tween.TRANS_SINE)

	# 2. Phù thủy bước theo tới bên cạnh
	_scenario_tween.parallel().tween_callback(func():
		_set_wizard_state(AnimState.WALK)
		_wizard_rect.flip_h = false
	)
	_scenario_tween.parallel().tween_property(self, "_wizard_x", 245.0, 0.8).set_trans(Tween.TRANS_SINE)

	# 3. Sư tử hào hứng nhảy nhót chỉ tay hướng về nút PLAY bên phải
	_scenario_tween.tween_callback(func():
		_set_lion_state(AnimState.JUMP)
		_play_organic_sfx("soft_boing", -12.0)
	)
	_scenario_tween.tween_property(self, "_lion_y_jump", 45.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_scenario_tween.tween_property(self, "_lion_y_jump", 0.0, 0.18).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	# 4. Phù thủy vung đũa phép bắn chòm sao bay bổng về hướng cuốn sách
	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.ATTACK)
		_set_lion_state(AnimState.ATTACK)
		_bubble_label.text = "★PLAY!★"
		_play_organic_sfx("fairy_dust", -10.0)
		_spawn_magic_notes_at(Vector2(350, GROUND_Y - 150))
	)
	_scenario_tween.tween_interval(1.2)

	# 5. Cả hai cùng quay đầu trở về vị trí ấm cúng
	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.WALK)
		_set_lion_state(AnimState.WALK)
		_wizard_rect.flip_h = true
		_lion_rect.flip_h = true
		_bubble_label.text = ""
	)
	_scenario_tween.tween_property(self, "_wizard_x", HOME_WIZARD_X, 0.9).set_trans(Tween.TRANS_SINE)
	_scenario_tween.parallel().tween_property(self, "_lion_x", HOME_LION_X, 0.9).set_trans(Tween.TRANS_SINE)

	# 6. Nghỉ ngơi
	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.IDLE)
		_set_lion_state(AnimState.IDLE)
		_wizard_rect.flip_h = false
		_lion_rect.flip_h = false
	)
	_scenario_tween.tween_interval(2.2)
	_scenario_tween.finished.connect(_on_scenario_finished)


## KỊCH BẢN 3: Tiểu hòa tấu ấm áp ngay trên thảm rêu
func _run_scenario_concert() -> void:
	_kill_scenario_tween()
	_scenario_tween = create_tween()

	# 1. Cùng bước nhẹ vào giữa thảm rêu
	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.WALK)
		_set_lion_state(AnimState.WALK)
		_wizard_rect.flip_h = false
		_lion_rect.flip_h = true
		_bubble_label.text = "🎶"
	)
	_scenario_tween.tween_property(self, "_wizard_x", 205.0, 0.7).set_trans(Tween.TRANS_SINE)
	_scenario_tween.parallel().tween_property(self, "_lion_x", 275.0, 0.7).set_trans(Tween.TRANS_SINE)

	# 2. Phù thủy vung đũa tỏa nốt nhạc
	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.ATTACK)
		_play_organic_sfx("fairy_dust", -12.0)
		_spawn_magic_notes_at(Vector2(215, GROUND_Y - 140))
	)
	_scenario_tween.tween_interval(0.4)

	# 3. Sư tử gõ nhịp nhún chân
	_scenario_tween.tween_callback(func():
		_set_lion_state(AnimState.ATTACK)
		_spawn_magic_notes_at(Vector2(265, GROUND_Y - 110))
	)
	_scenario_tween.tween_interval(0.4)

	# 4. Phù thủy bay bổng nhẹ nhàng, Sư tử nhảy cẫng lên ăn mừng
	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.SPECIAL)
		_bubble_label.text = "🌟🎶✨"
		_spawn_magic_notes_at(Vector2(240, GROUND_Y - 160))
	)
	_scenario_tween.tween_property(self, "_wizard_y_jump", 30.0, 0.35).set_trans(Tween.TRANS_SINE)
	_scenario_tween.tween_property(self, "_wizard_y_jump", 0.0, 0.35).set_trans(Tween.TRANS_SINE)

	_scenario_tween.tween_callback(func():
		_set_lion_state(AnimState.JUMP)
		_play_organic_sfx("soft_boing", -12.0)
	)
	_scenario_tween.tween_property(self, "_lion_y_jump", 40.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_scenario_tween.tween_property(self, "_lion_y_jump", 0.0, 0.18).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_scenario_tween.tween_interval(0.6)

	# 5. Cúi chào và trở về vị trí
	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.WALK)
		_set_lion_state(AnimState.WALK)
		_wizard_rect.flip_h = true
		_lion_rect.flip_h = false
		_bubble_label.text = ""
	)
	_scenario_tween.tween_property(self, "_wizard_x", HOME_WIZARD_X, 0.7).set_trans(Tween.TRANS_SINE)
	_scenario_tween.parallel().tween_property(self, "_lion_x", HOME_LION_X, 0.7).set_trans(Tween.TRANS_SINE)

	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.IDLE)
		_set_lion_state(AnimState.IDLE)
		_wizard_rect.flip_h = false
		_lion_rect.flip_h = false
	)
	_scenario_tween.tween_interval(2.0)
	_scenario_tween.finished.connect(_on_scenario_finished)


## KỊCH BẢN 4: Sư tử nhào lộn tinh nghịch trên thảm rêu, phù thủy đỡ bạn
func _run_scenario_tumble() -> void:
	_kill_scenario_tween()
	_scenario_tween = create_tween()

	# 1. Sư tử lon ton bước lại gần phù thủy
	_scenario_tween.tween_callback(func():
		_set_lion_state(AnimState.WALK)
		_lion_rect.flip_h = true
	)
	_scenario_tween.tween_property(self, "_lion_x", 250.0, 0.7).set_trans(Tween.TRANS_SINE)

	# 2. Sư tử tinh nghịch ngã lăn nhào lộn trên thảm rêu
	_scenario_tween.tween_callback(func():
		_set_lion_state(AnimState.HIT)
		_bubble_label.text = "(>o<)!"
		_play_organic_sfx("soft_plop", -10.0)
	)
	_scenario_tween.tween_property(_lion_rect, "rotation_degrees", 15.0, 0.15)
	_scenario_tween.tween_property(_lion_rect, "rotation_degrees", -15.0, 0.15)
	_scenario_tween.tween_property(_lion_rect, "rotation_degrees", 0.0, 0.15)

	# 3. Phù thủy quay sang ngơ ngác giật mình
	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.HIT)
		_bubble_label.text = "O_O?!"
	)
	_scenario_tween.tween_interval(0.6)

	# 4. Sư tử bật dậy nhảy cẫng, cả hai vui vẻ thả tim sao
	_scenario_tween.tween_callback(func():
		_set_lion_state(AnimState.JUMP)
		_set_wizard_state(AnimState.SPECIAL)
		_bubble_label.text = "💖✨"
		_play_organic_sfx("giggle_cute", -10.0)
		_spawn_magic_notes_at(Vector2(210, GROUND_Y - 130))
	)
	_scenario_tween.tween_property(self, "_lion_y_jump", 35.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_scenario_tween.tween_property(self, "_lion_y_jump", 0.0, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_scenario_tween.tween_interval(0.8)

	# 5. Về chỗ nghỉ ngơi
	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.WALK)
		_set_lion_state(AnimState.WALK)
		_wizard_rect.flip_h = false
		_lion_rect.flip_h = false
		_bubble_label.text = ""
	)
	_scenario_tween.tween_property(self, "_wizard_x", HOME_WIZARD_X, 0.7).set_trans(Tween.TRANS_SINE)
	_scenario_tween.parallel().tween_property(self, "_lion_x", HOME_LION_X, 0.7).set_trans(Tween.TRANS_SINE)

	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.IDLE)
		_set_lion_state(AnimState.IDLE)
		_wizard_rect.flip_h = false
		_lion_rect.flip_h = false
	)
	_scenario_tween.tween_interval(2.0)
	_scenario_tween.finished.connect(_on_scenario_finished)


## KỊCH BẢN 5: Chợp mắt nghỉ ngơi (khi lâu không có tương tác > 40s)
func _run_scenario_rest() -> void:
	_kill_scenario_tween()
	_scenario_tween = create_tween()

	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.SLEEP)
		_set_lion_state(AnimState.SLEEP)
		_bubble_label.text = "Zzz..."
		_play_organic_sfx("cute_purr", -13.0)
	)
	_scenario_tween.tween_interval(5.0)

	# Thức dậy tươi tỉnh bằng cú nhảy đón bé
	_scenario_tween.tween_callback(func():
		_bubble_label.text = "★"
		_set_wizard_state(AnimState.JUMP)
		_set_lion_state(AnimState.JUMP)
		_play_organic_sfx("soft_boing", -11.0)
		_spawn_magic_notes_at(Vector2(240, GROUND_Y - 140))
	)
	_scenario_tween.tween_property(self, "_wizard_y_jump", 40.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_scenario_tween.parallel().tween_property(self, "_lion_y_jump", 40.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_scenario_tween.tween_property(self, "_wizard_y_jump", 0.0, 0.18).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_scenario_tween.parallel().tween_property(self, "_lion_y_jump", 0.0, 0.18).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	_scenario_tween.tween_callback(func():
		_set_wizard_state(AnimState.IDLE)
		_set_lion_state(AnimState.IDLE)
		_bubble_label.text = ""
	)
	_scenario_tween.tween_interval(1.5)
	_scenario_tween.finished.connect(_on_scenario_finished)


func _on_scenario_finished() -> void:
	if not _is_interacting:
		_start_next_scenario()


# ==============================================================================
# TƯƠNG TÁC CẢM ỨNG (TOUCH / TAP INTERACTIVITY)
# ==============================================================================

func _on_wizard_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_interacted("wizard")


func _on_lion_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_interacted("lion")


## Được gọi từ MainMenu khi bé chạm vào vùng CharacterHotspot
func _on_tapped() -> void:
	_on_interacted("both")


func _on_interacted(target: String) -> void:
	_total_inactivity_timer = 0.0
	_is_interacting = true
	_kill_scenario_tween()

	_spawn_magic_notes_at(Vector2(_wizard_x, GROUND_Y - 130))
	_spawn_magic_notes_at(Vector2(_lion_x, GROUND_Y - 110))

	var tw := create_tween()
	if target == "wizard":
		_set_wizard_state(AnimState.SPECIAL)
		_play_organic_sfx("fairy_dust", -6.0)
		_bubble_label.text = "✨(^v^)!"
		tw.tween_property(self, "_wizard_y_jump", 50.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "_wizard_y_jump", 0.0, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	elif target == "lion":
		_set_lion_state(AnimState.ATTACK)
		_play_organic_sfx("giggle_cute", -6.0)
		_bubble_label.text = "🥁(>o<)!"
		tw.tween_property(self, "_lion_y_jump", 50.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "_lion_y_jump", 0.0, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	else:
		_set_wizard_state(AnimState.JUMP)
		_set_lion_state(AnimState.JUMP)
		_play_organic_sfx("soft_boing", -6.0)
		_play_organic_sfx("fairy_dust", -8.0)
		_bubble_label.text = "🌟💖🌟"
		tw.tween_property(self, "_wizard_y_jump", 50.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(self, "_lion_y_jump", 50.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "_wizard_y_jump", 0.0, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(self, "_lion_y_jump", 0.0, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	tw.tween_interval(1.0)
	tw.tween_callback(func():
		_is_interacting = false
		_bubble_label.text = ""
		_set_wizard_state(AnimState.IDLE)
		_set_lion_state(AnimState.IDLE)
		_start_next_scenario()
	)


# ==============================================================================
# HÀM BỔ TRỢ (HELPERS)
# ==============================================================================

func _set_wizard_state(s: AnimState) -> void:
	_wizard_state = s
	current_state = s
	_wizard_anim_timer = 0.0
	if s == AnimState.WALK and not _wizard_walk_frames.is_empty():
		_wizard_rect.texture = _wizard_walk_frames[0]
	elif s == AnimState.JUMP and not _wizard_jump_frames.is_empty():
		_wizard_rect.texture = _wizard_jump_frames[0]
	else:
		var s_name := _state_to_name(s)
		if _wizard_textures.has(s_name):
			_wizard_rect.texture = _wizard_textures[s_name]
	state_changed.emit(s)


func _set_lion_state(s: AnimState) -> void:
	_lion_state = s
	_lion_anim_timer = 0.0
	if s == AnimState.WALK and not _lion_walk_frames.is_empty():
		_lion_rect.texture = _lion_walk_frames[0]
	elif s == AnimState.JUMP and not _lion_jump_frames.is_empty():
		_lion_rect.texture = _lion_jump_frames[0]
	else:
		var s_name := _state_to_name(s)
		if _lion_textures.has(s_name):
			_lion_rect.texture = _lion_textures[s_name]


func _state_to_name(s: AnimState) -> String:
	match s:
		AnimState.IDLE: return "idle"
		AnimState.WALK: return "walk"
		AnimState.JUMP: return "jump"
		AnimState.ATTACK: return "attack"
		AnimState.HIT: return "hit"
		AnimState.SLEEP: return "sleep"
		AnimState.SPECIAL: return "special"
		_: return "idle"


func _reset_to_home() -> void:
	_wizard_x = HOME_WIZARD_X
	_wizard_y_jump = 0.0
	_wizard_rect.flip_h = false
	_set_wizard_state(AnimState.IDLE)

	_lion_x = HOME_LION_X
	_lion_y_jump = 0.0
	_lion_rect.flip_h = false
	_set_lion_state(AnimState.IDLE)


func _kill_scenario_tween() -> void:
	if _scenario_tween != null and _scenario_tween.is_valid():
		_scenario_tween.kill()


func _spawn_magic_notes_at(spawn_pos: Vector2) -> void:
	var symbols := ["♪", "♫", "✨", "★", "♬"]
	for i in 3:
		var note := Label.new()
		note.text = symbols[randi() % symbols.size()]
		note.add_theme_font_size_override("font_size", randi_range(20, 28))
		note.add_theme_color_override("font_color", Color(1.0, randf_range(0.75, 0.95), randf_range(0.2, 0.6), 0.95))
		note.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var p := spawn_pos + Vector2(randf_range(-25, 25), randf_range(-15, 15))
		note.position = p
		add_child(note)

		var tw := create_tween()
		var target_pos := p + Vector2(randf_range(-35, 35), -randf_range(50, 95))
		tw.tween_property(note, "position", target_pos, randf_range(0.8, 1.3)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(note, "modulate:a", 0.0, randf_range(0.8, 1.3)).set_delay(0.3)
		tw.finished.connect(note.queue_free)


func _play_organic_sfx(sfx_name: String, volume_db: float = -12.0) -> void:
	var ad: Node = null
	if Engine.has_singleton("AudioDirector"):
		ad = Engine.get_singleton("AudioDirector")
	elif get_tree() and get_tree().root and get_tree().root.has_node("AudioDirector"):
		ad = get_tree().root.get_node("AudioDirector")

	if ad != null and ad.has_method("play_sfx"):
		ad.play_sfx(sfx_name, volume_db)


func _play_audio_chime(_pitch: float = 1.0) -> void:
	var ad: Node = null
	if Engine.has_singleton("AudioDirector"):
		ad = Engine.get_singleton("AudioDirector")
	elif get_tree() and get_tree().root and get_tree().root.has_node("AudioDirector"):
		ad = get_tree().root.get_node("AudioDirector")

	# Không bao giờ phát nốt đàn piano khi di chuyển hoặc hoạt cảnh tự động
	# Chỉ phát hiệu ứng sao lấp lánh khi bé chủ động chạm vào nhân vật
	if ad != null and ad.has_method("play_sfx"):
		ad.play_sfx("fairy_dust", -6.0)


func _play_audio_step() -> void:
	# Giữ yên tĩnh để trẻ lắng nghe trọn vẹn giai điệu êm dịu của nhạc nền BGM
	pass
