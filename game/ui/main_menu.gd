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

var _bg_texture: Texture2D
var _bg_rect: TextureRect

var _play_btn: Button
var _play_container: Control
var _play_aura: PlayButtonAura

var _levels_btn: Button
var _levels_box: Control

var _burst_layer: StarlightBurstLayer
var _time: float = 0.0
var _ambient_hint_timer: float = 0.0


func _process(_delta: float) -> void:
	# Fix UI 7 nhóm: hotspot vô hình nên bé không biết chỗ nào chạm được.
	# Thở nhẹ nút Levels + tỏa sparkle mời gọi quanh Play mỗi ~5s.
	if not visible:
		return
	_time += _delta
	if _levels_box != null and is_instance_valid(_levels_box):
		var breathe := 1.0 + 0.03 * sin(_time * 2.4)
		_levels_box.scale = Vector2(breathe, breathe)
	_ambient_hint_timer += _delta
	if _ambient_hint_timer >= 5.0:
		_ambient_hint_timer = 0.0
		if _burst_layer != null and _play_container != null and is_instance_valid(_play_container):
			var center := _play_container.get_global_rect().get_center()
			_burst_layer.emit_burst(center + Vector2(0, -20), Color(1.0, 0.92, 0.50, 0.55), 6)


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

	# 3. LỚP HIỆU ỨNG HẠT ĐOM ĐÓM & BỤI SAO / NỐT NHẠC BAY
	_burst_layer = StarlightBurstLayer.new()
	_burst_layer.name = "StarlightBurstLayer"
	_burst_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_burst_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 4. NHẠC CỤ HOẠT ẢNH TRUNG TÂM (ACCORDION & VIOLIN)
	_build_instrument_props()

	# 5. BỘ ĐIỀU KHIỂN HOẠT ẢNH & SÂN KHẤU CHẠY NHẢY 2.5D (BÉ PHÙ THỦY & SƯ TỬ CON)
	var anim_chars := AnimatedMenuCharacters.new()
	anim_chars.name = "AnimatedCharacters"
	anim_chars.set_anchors_preset(Control.PRESET_FULL_RECT)
	anim_chars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(anim_chars)

	# 6. ĐIỂM CHẠM TƯƠNG TÁC ĐỒ CHƠI (TOY MICRO-INTERACTIONS)
	_build_toy_hotspots()

	# 7. NÚT CHƠI (KHÓA SON MẠ VÀNG KHỔNG LỒ)
	_build_play_button()

	# 8. HUY HIỆU ĐIỀU HƯỚNG GÓC TRÊN (LEVELS)
	_build_header_badges()

	# 9. LỚP ĐOM ĐÓM RỪNG LƠ LỬNG
	var fireflies := FireflyOverlay.new()
	fireflies.name = "FireflyOverlay"
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fireflies)

	# Thêm burst layer ở lớp trên cùng để bụi sao và nốt nhạc bay trên tất cả đối tượng
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

	# --- E. Chạm Đàn Violin Bàn Gỗ Góc Dưới Trái (X: 4% - 17%, Y: 73% - 96%) ---
	var table_vio_btn := Button.new()
	table_vio_btn.name = "TableViolinHotspot"
	table_vio_btn.anchor_left = 0.04
	table_vio_btn.anchor_top = 0.73
	table_vio_btn.anchor_right = 0.17
	table_vio_btn.anchor_bottom = 0.96
	table_vio_btn.flat = true
	table_vio_btn.focus_mode = Control.FOCUS_NONE
	table_vio_btn.add_theme_stylebox_override("normal", empty)
	table_vio_btn.add_theme_stylebox_override("hover", empty)
	table_vio_btn.add_theme_stylebox_override("pressed", empty)
	table_vio_btn.pressed.connect(func():
		var audio := _get_audio()
		if audio != null and audio.has_method("play_sfx"):
			audio.play_sfx("violin_pluck", -3.0)
		if _burst_layer != null:
			var center := table_vio_btn.get_global_rect().get_center()
			_burst_layer.emit_burst(center, Color(1.0, 0.88, 0.45, 0.95), 14)
			_burst_layer.emit_musical_notes(center, 2)
	)
	add_child(table_vio_btn)

	# --- F. Chạm Đàn Hạc Bàn Gỗ Góc Dưới Phải (X: 78% - 94%, Y: 76% - 97%) ---
	var table_harp_btn := Button.new()
	table_harp_btn.name = "TableHarpHotspot"
	table_harp_btn.anchor_left = 0.78
	table_harp_btn.anchor_top = 0.76
	table_harp_btn.anchor_right = 0.94
	table_harp_btn.anchor_bottom = 0.97
	table_harp_btn.flat = true
	table_harp_btn.focus_mode = Control.FOCUS_NONE
	table_harp_btn.add_theme_stylebox_override("normal", empty)
	table_harp_btn.add_theme_stylebox_override("hover", empty)
	table_harp_btn.add_theme_stylebox_override("pressed", empty)
	table_harp_btn.pressed.connect(func():
		var audio := _get_audio()
		if audio != null and audio.has_method("play_sfx"):
			audio.play_sfx("harp_chime", -4.0)
		if _burst_layer != null:
			var center := table_harp_btn.get_global_rect().get_center()
			_burst_layer.emit_burst(center, Color(1.0, 0.95, 0.60, 0.98), 18)
			_burst_layer.emit_musical_notes(center, 3)
	)
	add_child(table_harp_btn)


## Khối hiển thị mỹ thuật & hoạt ảnh cho 2 cây đàn (Accordion & Violin)
func _build_instrument_props() -> void:
	var audio := _get_audio()
	var accordion := AccordionProp.new(_burst_layer, audio)
	accordion.name = "AccordionProp"
	add_child(accordion)

	var violin := ViolinProp.new(_burst_layer, audio)
	violin.name = "ViolinProp"
	add_child(violin)


## Nút Khóa Son khổng lồ mạ vàng "PLAY" với hiệu ứng hào quang Aura & phản hồi xúc giác
func _build_play_button() -> void:
	_play_container = Control.new()
	_play_container.name = "PlayButtonContainer"
	# Tọa độ khớp chính xác với Khóa Son PLAY trên tranh concept gốc 1376x768
	_play_container.anchor_left = 0.679
	_play_container.anchor_top = 0.448
	_play_container.anchor_right = 0.847
	_play_container.anchor_bottom = 0.750
	_play_container.pivot_offset = Vector2(115, 115)
	_play_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_play_container)

	# 1. Node giữ chỗ cấu trúc PlayDiscVisual (trong suốt để hiển thị 100% tranh mỹ thuật gốc)
	var disc_rect := TextureRect.new()
	disc_rect.name = "PlayDiscVisual"
	disc_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	disc_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	disc_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	disc_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_play_container.add_child(disc_rect)

	# 2. Hào quang vàng tinh tế nhấp nháy nhịp thở quanh biểu tượng Khóa Son gốc
	_play_aura = PlayButtonAura.new(null)
	_play_aura.name = "PlayButtonAura"
	_play_aura.set_anchors_preset(Control.PRESET_FULL_RECT)
	_play_aura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_play_container.add_child(_play_aura)

	# 3. Bộ điều khiển chuyển động nhịp thở (Breathing Motion Controller)
	var motion := PlayButtonMotion.new(_play_container)
	motion.name = "PlayButtonMotion"
	_play_container.add_child(motion)

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

	# Phản hồi xúc giác vật lý: nhấn nén xuống, hào quang bừng sáng, nốt nhạc bùng nổ
	_play_btn.button_down.connect(func():
		var m: PlayButtonMotion = _play_container.get_node_or_null("PlayButtonMotion") as PlayButtonMotion
		if m != null:
			m._is_pressed = true
		if _play_aura != null:
			_play_aura.set_pressed(true)
		var tw := create_tween()
		tw.tween_property(_play_container, "scale", Vector2(0.94, 0.94), 0.07)
	)
	_play_btn.button_up.connect(func():
		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(_play_container, "scale", Vector2(1.06, 1.06), 0.12)
		tw.tween_property(_play_container, "scale", Vector2.ONE, 0.14)
		tw.tween_callback(func():
			var m: PlayButtonMotion = _play_container.get_node_or_null("PlayButtonMotion") as PlayButtonMotion
			if m != null:
				m._is_pressed = false
			if _play_aura != null:
				_play_aura.set_pressed(false)
		)
	)

	_play_btn.pressed.connect(_on_play_pressed)
	_play_container.add_child(_play_btn)
	_play_aura._target_btn = _play_btn



## Các huy hiệu điều hướng góc trên (Levels)
func _build_header_badges() -> void:
	var empty := StyleBoxEmpty.new()

	# --- NÚT LEVELS (NGÔI SAO GỖ GÓC TRÁI TRÊN) ---
	var levels_box := Control.new()
	levels_box.name = "LevelsBox"
	levels_box.anchor_left = 0.022
	levels_box.anchor_top = 0.042
	levels_box.anchor_right = 0.105
	levels_box.anchor_bottom = 0.195
	levels_box.pivot_offset = Vector2(50, 50)
	levels_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(levels_box)
	_levels_box = levels_box

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


func _on_play_pressed() -> void:
	if _burst_layer != null and _play_btn != null:
		var center := _play_btn.get_global_rect().get_center()
		_burst_layer.emit_burst(center, Color(1.0, 0.95, 0.55, 0.98), 32)
		_burst_layer.emit_musical_notes(center, 4)
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


## Lớp vẽ hiệu ứng hào quang xoay (Rotating Sunburst Rays & Fairy Sparkles) quanh nút Khóa Son
class PlayButtonAura extends Control:
	var _target_btn: Control
	var _time: float = 0.0
	var _is_pressed: bool = false

	func _init(target: Control = null) -> void:
		_target_btn = target

	func set_pressed(p: bool) -> void:
		_is_pressed = p
		queue_redraw()

	func _process(delta: float) -> void:
		_time += delta
		queue_redraw()

	func _draw() -> void:
		if _target_btn != null and not _target_btn.is_visible_in_tree():
			return
		var center := size * 0.5
		var radius := minf(size.x, size.y) * 0.50
		var pulse := 0.5 + 0.5 * sin(_time * 2.5)

		# 1. Tia sáng vàng quay xoay nhẹ nhàng (Rotating God Rays / Sunburst Beams)
		# Tỏa ra từ tâm và tan biến êm dịu ra không gian (Alpha -> 0), tuyệt đối không tạo viền bao tròn
		var num_rays := 10
		var rot_speed := 0.42 if not _is_pressed else 1.2
		var base_rot := _time * rot_speed
		var ray_len := radius * (1.18 + 0.08 * pulse if not _is_pressed else 1.35)
		var ray_half_w := (TAU / float(num_rays)) * 0.28
		var ray_intensity := 1.8 if _is_pressed else (0.85 + 0.25 * pulse)

		for i in num_rays:
			var angle := base_rot + (float(i) * TAU / float(num_rays))
			var p1 := center + Vector2(cos(angle - ray_half_w), sin(angle - ray_half_w)) * ray_len
			var p2 := center + Vector2(cos(angle + ray_half_w), sin(angle + ray_half_w)) * ray_len
			var c_center := Color(1.0, 0.90, 0.45, 0.11 * ray_intensity)
			var c_tip := Color(1.0, 0.85, 0.35, 0.0) # tan biến hoàn toàn
			draw_primitive(
				PackedVector2Array([center, p1, p2]),
				PackedColorArray([c_center, c_tip, c_tip]),
				PackedVector2Array()
			)

		# Lớp tia xoay ngược chiều mềm mại (Counter-rotating soft rays)
		var num_rays2 := 6
		var base_rot2 := -_time * (rot_speed * 0.6)
		var ray_len2 := radius * 1.05
		var ray_half_w2 := (TAU / float(num_rays2)) * 0.35
		for i in num_rays2:
			var angle := base_rot2 + (float(i) * TAU / float(num_rays2))
			var p1 := center + Vector2(cos(angle - ray_half_w2), sin(angle - ray_half_w2)) * ray_len2
			var p2 := center + Vector2(cos(angle + ray_half_w2), sin(angle + ray_half_w2)) * ray_len2
			var c_center := Color(1.0, 0.95, 0.60, 0.07 * ray_intensity)
			var c_tip := Color(1.0, 0.90, 0.40, 0.0)
			draw_primitive(
				PackedVector2Array([center, p1, p2]),
				PackedColorArray([c_center, c_tip, c_tip]),
				PackedVector2Array()
			)

		# 2. Đốm sao tiên nữ 4 cánh xoay lượn và lấp lánh (Twinkling Fairy Star Sparkles)
		var num_stars := 6
		for i in num_stars:
			var star_speed := 0.65 if not _is_pressed else 1.8
			var star_angle := _time * star_speed + (float(i) * TAU / float(num_stars))
			var dist := radius * (0.85 + 0.18 * sin(_time * 1.6 + i * 1.4))
			var sp := center + Vector2(cos(star_angle) * 1.02, sin(star_angle) * 0.94) * dist
			var sa := clampf(0.35 + 0.50 * sin(_time * 3.4 + i * 2.1), 0.0, 1.0)
			if _is_pressed:
				sa = 1.0

			var col_star := Color(1.0, 0.98, 0.75, sa)
			var arm := 3.2 if not _is_pressed else 5.0
			draw_line(sp - Vector2(arm, 0), sp + Vector2(arm, 0), col_star, 1.2)
			draw_line(sp - Vector2(0, arm), sp + Vector2(0, arm), col_star, 1.2)
			draw_circle(sp, 1.6, Color(1.0, 1.0, 0.90, sa))




## Bộ điều khiển chuyển động nhịp thở bồng bềnh của Nút PLAY
class PlayButtonMotion extends Node:
	var _container: Control
	var _time: float = 0.0
	var _is_pressed: bool = false

	func _init(container: Control) -> void:
		_container = container

	func _ready() -> void:
		if is_instance_valid(_container):
			_container.resized.connect(func():
				_container.pivot_offset = _container.size * 0.5
			)
			_container.pivot_offset = _container.size * 0.5

	func _process(delta: float) -> void:
		_time += delta
		if not _is_pressed and is_instance_valid(_container):
			# Nhịp thở hữu cơ nhẹ nhàng (Lullaby breath)
			var pulse := sin(_time * 2.4) * 0.032
			_container.scale = Vector2.ONE * (1.0 + pulse)


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


## Lớp phát hiệu ứng bùng nổ bụi sao vàng và nốt nhạc bay khi chạm (Starlight & Music Notes Burst)
class StarlightBurstLayer extends Control:
	var _particles: Array[Dictionary] = []
	var _musical_notes: Array[Dictionary] = []

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

	func emit_musical_notes(origin: Vector2, count: int = 3) -> void:
		var rng := RandomNumberGenerator.new()
		var colors := [
			Color(1.0, 0.88, 0.38, 0.95), # Golden amber
			Color(0.42, 0.96, 0.86, 0.95), # Cyan emerald
			Color(1.0, 0.68, 0.88, 0.95), # Fairy pink
			Color(1.0, 0.98, 0.68, 0.95), # Warm yellow
		]
		for i in count:
			var vx := rng.randf_range(-35.0, 35.0)
			var vy := rng.randf_range(-80.0, -140.0)
			_musical_notes.append({
				"pos": origin + Vector2(rng.randf_range(-18, 18), rng.randf_range(-12, 12)),
				"vel": Vector2(vx, vy),
				"rot": rng.randf_range(-0.35, 0.35),
				"rot_spd": rng.randf_range(-1.2, 1.2),
				"scale": rng.randf_range(0.85, 1.25),
				"color": colors[i % colors.size()],
				"alpha": 1.0,
				"decay": rng.randf_range(0.8, 1.3),
				"phase": rng.randf_range(0, TAU),
			})

	func _process(delta: float) -> void:
		var redraw_needed := false
		if not _particles.is_empty():
			redraw_needed = true
			var i := _particles.size() - 1
			while i >= 0:
				var p: Dictionary = _particles[i]
				p["pos"] += p["vel"] * delta
				p["vel"] *= 0.92
				p["alpha"] -= p["decay"] * delta
				if p["alpha"] <= 0.0:
					_particles.remove_at(i)
				i -= 1

		if not _musical_notes.is_empty():
			redraw_needed = true
			var j := _musical_notes.size() - 1
			while j >= 0:
				var n: Dictionary = _musical_notes[j]
				n["pos"] += n["vel"] * delta
				n["pos"].x += sin(n["phase"] + n["alpha"] * 5.0) * 0.8
				n["vel"].y *= 0.96
				n["rot"] += n["rot_spd"] * delta
				n["alpha"] -= n["decay"] * delta
				if n["alpha"] <= 0.0:
					_musical_notes.remove_at(j)
				j -= 1

		if redraw_needed:
			queue_redraw()

	func _draw() -> void:
		for p in _particles:
			var col: Color = p["color"]
			col.a *= p["alpha"]
			draw_circle(p["pos"], p["radius"] * p["alpha"], col)
			draw_circle(p["pos"], p["radius"] * 1.8 * p["alpha"], Color(col.r, col.g, col.b, col.a * 0.25))

		for n in _musical_notes:
			var col: Color = n["color"]
			col.a *= n["alpha"]
			_draw_musical_note(n["pos"], col, n["scale"], n["rot"])

	func _draw_musical_note(p: Vector2, col: Color, sc: float, rot: float) -> void:
		var head_radius := 4.2 * sc
		var stem_h := 13.0 * sc
		var xform := Transform2D(rot, p)
		draw_set_transform_matrix(xform)
		draw_circle(Vector2.ZERO, head_radius * 1.5, Color(col.r, col.g, col.b, col.a * 0.3))
		draw_circle(Vector2.ZERO, head_radius, col)
		var stem_x := head_radius * 0.72
		draw_line(Vector2(stem_x, 0), Vector2(stem_x, -stem_h), col, 1.8 * sc)
		draw_arc(Vector2(stem_x + 2.8 * sc, -stem_h + 3.2 * sc), 3.2 * sc, 0.0, PI * 0.7, 6, col, 1.8 * sc)
		draw_set_transform_matrix(Transform2D.IDENTITY)


## Prop Đàn Accordion (Phong Cầm) 2.5D với nhịp thở nếp gấp và phản hồi nén nhả xúc giác
class AccordionProp extends Control:
	var _tex_rect: TextureRect
	var _time: float = 0.0
	var _is_reacting: bool = false
	var _burst_layer: StarlightBurstLayer
	var _audio_node: Node

	func _init(burst: StarlightBurstLayer, audio: Node) -> void:
		_burst_layer = burst
		_audio_node = audio

	func _ready() -> void:
		# Tọa độ khớp chính xác với đàn Phong Cầm trên concept gốc
		anchor_left = 0.4288
		anchor_top = 0.6562
		anchor_right = 0.6046
		anchor_bottom = 0.8490
		mouse_filter = Control.MOUSE_FILTER_PASS
		resized.connect(func():
			pivot_offset = Vector2(size.x * 0.50, size.y * 0.75)
		)
		pivot_offset = Vector2(size.x * 0.50, size.y * 0.75)

		_tex_rect = TextureRect.new()
		_tex_rect.name = "AccordionVisual"
		_tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_tex_rect)

		var btn := Button.new()
		btn.name = "AccordionButton"
		btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.flat = true
		var empty := StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", empty)
		btn.add_theme_stylebox_override("hover", empty)
		btn.add_theme_stylebox_override("pressed", empty)
		btn.pressed.connect(_on_tapped)
		add_child(btn)

	var _ambient_timer: float = 0.0

	func _process(delta: float) -> void:
		_time += delta
		_ambient_timer += delta
		# Tự động tỏa nốt nhạc nhẹ nhàng định kỳ như nhạc cụ đang ngân nga
		if _ambient_timer > 3.8:
			_ambient_timer = 0.0
			if _burst_layer != null and not _is_reacting:
				var center := get_global_rect().get_center()
				_burst_layer.emit_musical_notes(center + Vector2(randf_range(-15, 15), -10), 1)

	func _on_tapped() -> void:
		if _is_reacting:
			return
		_is_reacting = true
		if _audio_node != null and _audio_node.has_method("play_sfx"):
			_audio_node.play_sfx("accordion_breath", -3.0)
		if _burst_layer != null:
			var center := get_global_rect().get_center()
			_burst_layer.emit_burst(center, Color(1.0, 0.85, 0.4, 0.95), 18)
			_burst_layer.emit_musical_notes(center, 3)

		# Nhịp nén nhả nhẹ tại chỗ khi chạm vào
		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "scale", Vector2(0.95, 1.05), 0.08)
		tw.tween_property(self, "scale", Vector2(1.04, 0.96), 0.12)
		tw.tween_property(self, "scale", Vector2.ONE, 0.16)
		tw.tween_callback(func(): _is_reacting = false)


## Prop Đàn Violin (Vĩ Cầm) 2.5D tương tác âm nhạc và tỏa nốt nhạc thần tiên
class ViolinProp extends Control:
	var _tex_rect: TextureRect
	var _time: float = 0.0
	var _ambient_timer: float = 0.0
	var _is_reacting: bool = false
	var _burst_layer: StarlightBurstLayer
	var _audio_node: Node

	func _init(burst: StarlightBurstLayer, audio: Node) -> void:
		_burst_layer = burst
		_audio_node = audio

	func _ready() -> void:
		# Tọa độ khớp chính xác với đàn Vĩ Cầm trên concept gốc
		anchor_left = 0.5814
		anchor_top = 0.6406
		anchor_right = 0.6541
		anchor_bottom = 0.8568
		mouse_filter = Control.MOUSE_FILTER_PASS
		resized.connect(func():
			pivot_offset = Vector2(size.x * 0.48, size.y * 0.95)
		)
		pivot_offset = Vector2(size.x * 0.48, size.y * 0.95)

		_tex_rect = TextureRect.new()
		_tex_rect.name = "ViolinVisual"
		_tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_tex_rect)

		var btn := Button.new()
		btn.name = "ViolinButton"
		btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.flat = true
		var empty := StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", empty)
		btn.add_theme_stylebox_override("hover", empty)
		btn.add_theme_stylebox_override("pressed", empty)
		btn.pressed.connect(_on_tapped)
		add_child(btn)

	func _process(delta: float) -> void:
		_time += delta
		_ambient_timer += delta
		# Tự động tỏa nốt nhạc định kỳ
		if _ambient_timer > 4.6:
			_ambient_timer = 0.0
			if _burst_layer != null and not _is_reacting:
				var center := get_global_rect().get_center()
				_burst_layer.emit_musical_notes(center + Vector2(randf_range(-10, 10), -12), 1)

	func _on_tapped() -> void:
		if _is_reacting:
			return
		_is_reacting = true
		if _audio_node != null and _audio_node.has_method("play_sfx"):
			_audio_node.play_sfx("violin_pluck", -3.0)
		if _burst_layer != null:
			var center := get_global_rect().get_center()
			_burst_layer.emit_burst(center, Color(1.0, 0.90, 0.5, 0.95), 16)
			_burst_layer.emit_musical_notes(center, 2)

		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(0.96, 1.06), 0.07)
		tw.tween_property(self, "scale", Vector2(1.03, 0.97), 0.10)
		tw.tween_property(self, "scale", Vector2.ONE, 0.14)
		tw.tween_callback(func(): _is_reacting = false)

