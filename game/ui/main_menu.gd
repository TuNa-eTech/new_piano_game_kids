class_name MainMenu
extends PauseOverlay

const AnimatedMenuCharacters = preload("res://game/ui/animated_menu_characters.gd")

## Màn hình Menu Khởi Đầu / Bìa Sách 'Rừng Nhạc' (FTUE) chuẩn 2.5D Diorama.
##
## Thiết kế trung thực tuyệt đối với concept mock-main-menu.jpeg:
## - Sử dụng tranh nền concept gốc thống nhất hoàn hảo về màu sắc, ánh sáng và bố cục
## - Khắc phục triệt để lỗi phân tầng: Không dùng các lát cắt hình chữ nhật thô gây nhân đôi nhân vật, cắt cụt chân hay rách nền
## - Hiệu ứng 2.5D sống động:
##   + Hào quang nhịp thở và vệt sáng quét kim hoàn trên Khóa Son nút PLAY
##   + Dải nốt nhạc vàng ngũ cung xoay vòng quanh bìa sách ma thuật "MUSIC FOREST"
##   + Đom đóm rừng đêm lơ lửng trôi dạt theo làn gió
##   + Các điểm chạm tương tác đồ chơi: Chạm Phù Thủy/Sư Tử, Chạm Pha Lê Cyan, Chạm Rương Báu
##   + Phản hồi xúc giác vật lý khi bấm nút: Nén nhả đàn hồi, bùng nổ bụi sao vàng (StarlightBurst)

signal play_pressed
signal levels_pressed
signal parent_gate_requested

var _bg_texture: Texture2D
var _bg_rect: TextureRect

var _play_btn: Button
var _play_container: Control
var _play_aura: PlayButtonAura

var _levels_btn: Button
var _parent_btn: Button

var _burst_layer: StarlightBurstLayer
var _time: float = 0.0


func _ready() -> void:
	super()
	layer = 25
	_build()
	_set_controls_visible(false)


func open_overlay() -> void:
	super.open_overlay()
	var audio := _get_audio()
	if audio != null and audio.has_method("play_main_menu_music"):
		audio.play_main_menu_music(0.1)

	# Hiệu ứng bùng nổ chào đón sôi động ngay khi vừa vào màn hình chính
	if _play_container != null:
		_play_container.scale = Vector2(0.72, 0.72)
		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(_play_container, "scale", Vector2.ONE, 0.45)

	if _burst_layer != null and _play_container != null:
		get_tree().create_timer(0.06).timeout.connect(func():
			if _burst_layer != null and is_instance_valid(_play_container):
				var center := _play_container.get_global_rect().get_center()
				_burst_layer.emit_burst(center, Color(1.0, 0.90, 0.40, 0.95), 24)
				_burst_layer.emit_burst(center + Vector2(-15, -10), Color(1.0, 0.80, 0.25, 0.85), 14)
		)



func _get_audio() -> Node:
	if Engine.has_singleton("AudioDirector"):
		return Engine.get_singleton("AudioDirector")
	var root_node: Node = get_tree().root if get_tree() else null
	if root_node != null and root_node.has_node("AudioDirector"):
		return root_node.get_node("AudioDirector")
	return null


func _build() -> void:
	_add_backdrop(Color(0.02, 0.04, 0.03, 0.98))

	# 1. TRANH NỀN SÂN KHẤU CHUẨN (Bàn gỗ + Sách + Nút Play, không dính nhân vật để nhường chỗ cho Animation)
	var stage_clean_path := "res://assets/menu/tex_menu_stage_clean.jpg"
	if ResourceLoader.exists(stage_clean_path):
		_bg_texture = load(stage_clean_path)
	elif ResourceLoader.exists("res://docs/mock-main-menu.jpeg"):
		_bg_texture = load("res://docs/mock-main-menu.jpeg")

	_bg_rect = TextureRect.new()
	_bg_rect.name = "BackgroundEnvironment"
	_bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _bg_texture != null:
		_bg_rect.texture = _bg_texture
	_bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_bg_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_bg_rect)

	# 2. DẢI NỐT NHẠC VÀNG XOAY QUANH TÊN SÁCH "MUSIC FOREST"
	var notes_orbit := SwirlingNotesOrbit.new()
	notes_orbit.name = "SwirlingNotesOrbit"
	notes_orbit.anchor_left = 0.34
	notes_orbit.anchor_top = 0.16
	notes_orbit.anchor_right = 0.67
	notes_orbit.anchor_bottom = 0.70
	notes_orbit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(notes_orbit)

	# 3. BỘ ĐIỀU KHIỂN HOẠT ẢNH & SÂN KHẤU CHẠY NHẢY 2.5D (BÉ PHÙ THỦY & SƯ TỬ CON)
	var anim_chars := AnimatedMenuCharacters.new()
	anim_chars.name = "AnimatedCharacters"
	anim_chars.set_anchors_preset(Control.PRESET_FULL_RECT)
	anim_chars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(anim_chars)

	# 4. ĐIỂM CHẠM TƯƠNG TÁC ĐỒ CHƠI (TOY MICRO-INTERACTIONS)
	_build_toy_hotspots()

	# 4. NÚT CHƠI (KHÓA SON MẠ VÀNG KHỔNG LỒ)
	_build_play_button()

	# 5. HUY HIỆU ĐIỀU HƯỚNG GÓC TRÊN (LEVELS & PARENTS)
	_build_header_badges()

	# 6. LỚP HIỆU ỨNG HẠT ĐOM ĐÓM & BỤI SAO
	var fireflies := FireflyOverlay.new()
	fireflies.name = "FireflyOverlay"
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fireflies)

	_burst_layer = StarlightBurstLayer.new()
	_burst_layer.name = "StarlightBurstLayer"
	_burst_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_burst_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_burst_layer)


## Các điểm chạm tương tác xúc giác trên tranh diorama
func _build_toy_hotspots() -> void:
	var empty := StyleBoxEmpty.new()

	# --- A. Chạm Bé Phù Thủy & Chú Sư Tử Con (X: 10% - 30%, Y: 40% - 84%) ---
	var char_btn := Button.new()
	char_btn.name = "CharacterHotspot"
	char_btn.anchor_left = 0.10
	char_btn.anchor_top = 0.40
	char_btn.anchor_right = 0.30
	char_btn.anchor_bottom = 0.84
	char_btn.flat = true
	char_btn.focus_mode = Control.FOCUS_NONE
	char_btn.add_theme_stylebox_override("normal", empty)
	char_btn.add_theme_stylebox_override("hover", empty)
	char_btn.add_theme_stylebox_override("pressed", empty)
	char_btn.pressed.connect(func():
		var ac: AnimatedMenuCharacters = get_node_or_null("AnimatedCharacters") as AnimatedMenuCharacters
		if ac != null:
			ac._on_tapped()
		if _burst_layer != null:
			_burst_layer.emit_burst(char_btn.get_global_rect().get_center(), Color(1.0, 0.85, 0.45, 0.95), 18)
	)
	add_child(char_btn)

	# --- B. Chạm Cuốn Sách Ma Thuật (X: 37% - 64%, Y: 18% - 75%) ---
	var book_btn := Button.new()
	book_btn.name = "BookHotspot"
	book_btn.anchor_left = 0.37
	book_btn.anchor_top = 0.18
	book_btn.anchor_right = 0.64
	book_btn.anchor_bottom = 0.75
	book_btn.flat = true
	book_btn.focus_mode = Control.FOCUS_NONE
	book_btn.add_theme_stylebox_override("normal", empty)
	book_btn.add_theme_stylebox_override("hover", empty)
	book_btn.add_theme_stylebox_override("pressed", empty)
	book_btn.pressed.connect(func():
		var audio := _get_audio()
		if audio != null and audio.has_method("play_sfx"):
			audio.play_sfx("page_turn")
		if _burst_layer != null:
			_burst_layer.emit_burst(book_btn.get_global_rect().get_center(), Color(1.0, 0.95, 0.65, 0.9), 20)
	)
	add_child(book_btn)

	# --- C. Chạm Tinh Thể Cyan Góc Trái (X: 0% - 12%, Y: 55% - 78%) ---
	var crystal_btn := Button.new()
	crystal_btn.name = "CrystalHotspot"
	crystal_btn.anchor_left = 0.0
	crystal_btn.anchor_top = 0.55
	crystal_btn.anchor_right = 0.12
	crystal_btn.anchor_bottom = 0.78
	crystal_btn.flat = true
	crystal_btn.focus_mode = Control.FOCUS_NONE
	crystal_btn.add_theme_stylebox_override("normal", empty)
	crystal_btn.add_theme_stylebox_override("hover", empty)
	crystal_btn.add_theme_stylebox_override("pressed", empty)
	crystal_btn.pressed.connect(func():
		var audio := _get_audio()
		if audio != null and audio.has_method("play_ting"):
			audio.play_ting()
		if _burst_layer != null:
			_burst_layer.emit_burst(crystal_btn.get_global_rect().get_center(), Color(0.3, 0.95, 0.95, 0.9), 16)
	)
	add_child(crystal_btn)

	# --- D. Chạm Rương Báu Góc Phải (X: 89% - 100%, Y: 58% - 78%) ---
	var chest_btn := Button.new()
	chest_btn.name = "ChestHotspot"
	chest_btn.anchor_left = 0.89
	chest_btn.anchor_top = 0.58
	chest_btn.anchor_right = 1.0
	chest_btn.anchor_bottom = 0.78
	chest_btn.flat = true
	chest_btn.focus_mode = Control.FOCUS_NONE
	chest_btn.add_theme_stylebox_override("normal", empty)
	chest_btn.add_theme_stylebox_override("hover", empty)
	chest_btn.add_theme_stylebox_override("pressed", empty)
	chest_btn.pressed.connect(func():
		var audio := _get_audio()
		if audio != null and audio.has_method("play_sfx"):
			audio.play_sfx("star_ting")
		if _burst_layer != null:
			_burst_layer.emit_burst(chest_btn.get_global_rect().get_center(), Color(1.0, 0.85, 0.35, 0.95), 18)
	)
	add_child(chest_btn)


## Nút Khóa Son khổng lồ mạ vàng "PLAY" với hiệu ứng hào quang Aura & nén nhả vật lý
func _build_play_button() -> void:
	_play_container = Control.new()
	_play_container.name = "PlayButtonContainer"
	# Tọa độ tương đối trên màn hình 16:9: X ~ 67.2% - 84.6%, Y ~ 47.5% - 79.5%
	_play_container.anchor_left = 0.672
	_play_container.anchor_top = 0.475
	_play_container.anchor_right = 0.846
	_play_container.anchor_bottom = 0.795
	_play_container.pivot_offset = Vector2(110, 110)
	_play_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_play_container)

	_play_btn = Button.new()
	_play_btn.name = "PlayButtonHitbox"
	_play_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	_play_btn.focus_mode = Control.FOCUS_NONE
	_play_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_play_btn.flat = true

	var play_empty := StyleBoxEmpty.new()
	_play_btn.add_theme_stylebox_override("normal", play_empty)
	_play_btn.add_theme_stylebox_override("hover", play_empty)
	_play_btn.add_theme_stylebox_override("pressed", play_empty)
	_play_btn.add_theme_stylebox_override("focus", play_empty)

	# Phản hồi xúc giác vật lý: nhấn nén xuống, nhả bật nảy lên
	_play_btn.button_down.connect(func():
		var tw := create_tween()
		tw.tween_property(_play_container, "scale", Vector2(0.92, 0.92), 0.08)
	)
	_play_btn.button_up.connect(func():
		var tw := create_tween()
		tw.tween_property(_play_container, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK)
	)

	_play_btn.pressed.connect(_on_play_pressed)
	_play_container.add_child(_play_btn)

	# Hào quang vàng tinh tế nhấp nháy nhịp thở quanh biểu tượng Khóa Son
	_play_aura = PlayButtonAura.new(_play_btn)
	_play_aura.name = "PlayButtonAura"
	_play_aura.set_anchors_preset(Control.PRESET_FULL_RECT)
	_play_aura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_play_container.add_child(_play_aura)


## Các huy hiệu điều hướng góc trên (Levels & Parents)
func _build_header_badges() -> void:
	var empty := StyleBoxEmpty.new()

	# --- NÚT LEVELS (NGÔI SAO GỖ GÓC TRÁI TRÊN) ---
	var levels_box := Control.new()
	levels_box.anchor_left = 0.022
	levels_box.anchor_top = 0.042
	levels_box.anchor_right = 0.105
	levels_box.anchor_bottom = 0.195
	levels_box.pivot_offset = Vector2(50, 50)
	levels_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(levels_box)

	_levels_btn = Button.new()
	_levels_btn.name = "LevelsButton"
	_levels_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	_levels_btn.focus_mode = Control.FOCUS_NONE
	_levels_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_levels_btn.flat = true
	_levels_btn.add_theme_stylebox_override("normal", empty)
	_levels_btn.add_theme_stylebox_override("hover", empty)
	_levels_btn.add_theme_stylebox_override("pressed", empty)
	_levels_btn.button_down.connect(func():
		var tw := create_tween()
		tw.tween_property(levels_box, "scale", Vector2(0.9, 0.9), 0.08)
	)
	_levels_btn.button_up.connect(func():
		var tw := create_tween()
		tw.tween_property(levels_box, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK)
	)
	_levels_btn.pressed.connect(_on_levels_pressed)
	levels_box.add_child(_levels_btn)

	# --- NÚT PHỤ HUYNH (MẶT TRĂNG GỖ GÓC PHẢI TRÊN) ---
	var parents_box := Control.new()
	parents_box.anchor_left = 0.895
	parents_box.anchor_top = 0.042
	parents_box.anchor_right = 0.978
	parents_box.anchor_bottom = 0.195
	parents_box.pivot_offset = Vector2(50, 50)
	parents_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(parents_box)

	_parent_btn = Button.new()
	_parent_btn.name = "ParentsButton"
	_parent_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	_parent_btn.focus_mode = Control.FOCUS_NONE
	_parent_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_parent_btn.flat = true
	_parent_btn.add_theme_stylebox_override("normal", empty)
	_parent_btn.add_theme_stylebox_override("hover", empty)
	_parent_btn.add_theme_stylebox_override("pressed", empty)
	_parent_btn.button_down.connect(func():
		var tw := create_tween()
		tw.tween_property(parents_box, "scale", Vector2(0.9, 0.9), 0.08)
	)
	_parent_btn.button_up.connect(func():
		var tw := create_tween()
		tw.tween_property(parents_box, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK)
	)
	_parent_btn.pressed.connect(_on_parent_pressed)
	parents_box.add_child(_parent_btn)


func _on_play_pressed() -> void:
	if _burst_layer != null and _play_btn != null:
		_burst_layer.emit_burst(_play_btn.get_global_rect().get_center(), Color(1.0, 0.95, 0.55, 0.98), 28)
	var audio := _get_audio()
	if audio != null:
		if audio.has_method("play_sfx"):
			audio.play_sfx("page_turn")
		if audio.has_method("play_gameplay_music"):
			audio.play_gameplay_music(1.0)
	close_overlay()
	play_pressed.emit()


func _on_levels_pressed() -> void:
	var audio := _get_audio()
	if audio != null and audio.has_method("play_sfx"):
		audio.play_sfx("star_ting")
	levels_pressed.emit()


func _on_parent_pressed() -> void:
	var audio := _get_audio()
	if audio != null and audio.has_method("play_sfx"):
		audio.play_sfx("wood_tap")
	parent_gate_requested.emit()


# -----------------------------------------------------------------------------
# CÁC CLASS HIỆU ỨNG THỊ GIÁC NATIVE (VFX & PARTICLES)
# -----------------------------------------------------------------------------

## Dải nốt nhạc vàng xoay vòng quanh bìa cuốn sách theo đường cong elip
class SwirlingNotesOrbit extends Control:
	var _time: float = 0.0
	const NOTE_COUNT := 6

	func _process(delta: float) -> void:
		_time += delta
		queue_redraw()

	func _draw() -> void:
		var center := size * 0.5
		var rx := size.x * 0.44
		var ry := size.y * 0.35

		for i in NOTE_COUNT:
			var angle := _time * 0.75 + (i * TAU / NOTE_COUNT)
			var nx := center.x + cos(angle) * rx
			var ny := center.y + sin(angle) * ry * 0.85
			var p := Vector2(nx, ny)

			var depth := sin(angle)
			var a := clampf(0.40 + 0.40 * depth, 0.20, 0.85)
			var r := 3.5 + 1.2 * depth

			# Hào quang nốt nhạc
			draw_circle(p, r * 2.0, Color(1.0, 0.85, 0.35, a * 0.25))
			draw_circle(p, r, Color(1.0, 0.96, 0.65, a))


## Lớp vẽ hiệu ứng hào quang vàng tỏa sáng xung quanh nút Khóa Son (nhẹ nhàng, không cháy sáng)
class PlayButtonAura extends Control:
	var _target_btn: Button
	var _time: float = 0.0

	func _init(target: Button) -> void:
		_target_btn = target

	func _process(delta: float) -> void:
		_time += delta
		queue_redraw()

	func _draw() -> void:
		if _target_btn == null or not _target_btn.is_visible_in_tree():
			return
		var center := size * 0.5
		var radius := minf(size.x, size.y) * 0.48
		var pulse := 0.5 + 0.5 * sin(_time * 2.8)

		# Hào quang vàng mềm mại, tinh tế, không gắt mắt
		draw_circle(center, radius * (1.0 + 0.06 * pulse), Color(1.0, 0.88, 0.45, 0.12 + 0.08 * pulse))
		draw_arc(center, radius * (1.0 + 0.04 * pulse), 0, TAU, 36, Color(1.0, 0.95, 0.65, 0.25 + 0.15 * pulse), 2.5, true)


## Lớp vẽ hạt đom đóm thần tiên lơ lửng trong không gian rừng
class FireflyOverlay extends Control:
	var _fireflies: Array[Dictionary] = []
	var _time: float = 0.0

	func _ready() -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = 42
		for i in 22:
			_fireflies.append({
				"pos": Vector2(rng.randf_range(0.05, 0.95), rng.randf_range(0.08, 0.88)),
				"speed": rng.randf_range(0.6, 1.8),
				"phase": rng.randf_range(0, TAU),
				"radius": rng.randf_range(2.0, 4.0),
			})

	func _process(delta: float) -> void:
		_time += delta
		queue_redraw()

	func _draw() -> void:
		var sz := size
		for ff in _fireflies:
			var sway_x := sin(_time * ff["speed"] + ff["phase"]) * 14.0
			var sway_y := cos(_time * ff["speed"] * 0.8 + ff["phase"]) * 10.0
			var p := Vector2(ff["pos"].x * sz.x + sway_x, ff["pos"].y * sz.y + sway_y)
			var a := 0.30 + 0.30 * sin(_time * ff["speed"] * 2.2 + ff["phase"])
			draw_circle(p, ff["radius"], Color(1.0, 0.95, 0.6, a))
			draw_circle(p, ff["radius"] * 2.0, Color(1.0, 0.85, 0.3, a * 0.3))


## Lớp phát hiệu ứng bùng nổ bụi sao vàng khi bấm (Starlight Burst)
class StarlightBurstLayer extends Control:
	var _particles: Array[Dictionary] = []

	func emit_burst(origin: Vector2, color: Color, count: int = 20) -> void:
		var rng := RandomNumberGenerator.new()
		for i in count:
			var angle := rng.randf_range(0, TAU)
			var spd := rng.randf_range(60.0, 220.0)
			_particles.append({
				"pos": origin,
				"vel": Vector2(cos(angle), sin(angle)) * spd,
				"color": color,
				"alpha": 1.0,
				"radius": rng.randf_range(2.5, 5.0),
				"decay": rng.randf_range(1.5, 2.5),
			})

	func _process(delta: float) -> void:
		if _particles.is_empty():
			return
		var i := _particles.size() - 1
		while i >= 0:
			var p: Dictionary = _particles[i]
			p["pos"] += p["vel"] * delta
			p["vel"] *= 0.92
			p["alpha"] -= p["decay"] * delta
			if p["alpha"] <= 0.0:
				_particles.remove_at(i)
			i -= 1
		queue_redraw()

	func _draw() -> void:
		for p in _particles:
			var col: Color = p["color"]
			col.a *= p["alpha"]
			draw_circle(p["pos"], p["radius"] * p["alpha"], col)
			draw_circle(p["pos"], p["radius"] * 1.8 * p["alpha"], Color(col.r, col.g, col.b, col.a * 0.25))
