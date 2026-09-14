class_name ChapterEnd
extends PauseOverlay
## "Buổi Diễn Rừng Xanh" — Màn 07 Đại Hoan Ca Kết Chương (docs/mock-grand-finale.jpeg)
##
## Kiến trúc Sân khấu Múa Rối Gỗ 2.5D Diorama Độc Bản:
##  · Tầng 1 (Z: -30): Hậu cảnh rừng già hoàng hôn, nhà nấm cổ tích, đom đóm lập lòe
##  · Tầng 2 (Z: -20): Màn hình tranh ma thuật dát vàng: Cây Đậu Thần vươn cao & Rương Báu Mở Bung
##  · Tầng 3 (Z: -18): Hào quang kim quang (Sunburst Rays) xoay chuyển từ rương báu trên ngọn cây
##  · Tầng 4 (Z: -15): Bục sàn gỗ ván dăm 2.5D (Wooden Stage Deck Platform)
##  · Tầng 5 (Z: -10): 6 Nghệ sĩ tí hon biểu diễn độc lập:
##                     1. Sư tử gõ 3 trống liên hoàn với dùi trống luân phiên
##                     2. Gấu nâu ôm đàn harp gảy dây phát sáng vàng kim
##                     3. Cậu bé phù thủy lướt tay phím piano gỗ upright, sao trên chóp nón lấp lánh
##                     4. Mèo sọc vàng đứng 2 chân thổi sáo gỗ, tỏa luồng gió nốt nhạc
##                     5. Voi con lam tai hồng khiêu vũ nhấc chân, vung vòi đập tai
##                     6. Cú mèo xòe cánh ca hát, phát các vòng tròn sóng âm ngân vang
##  · Tầng 6 (Z: -5):  Lớp hiệu ứng đặc thù (VFX): sóng âm, bọt nốt nhạc, tia sao, sóng rung mặt trống
##  · Tầng 7 (Z: 0):   Bàn phím piano gỗ 2.5D với 7 phím C-D-E-F-G-A-B phát sáng neon theo nhịp nốt
##  · Tầng 8 (Z: +10): Hai cụm tinh thể thạch anh Cyan & Magenta trên trụ cánh gỗ, rương báu nhỏ góc phải
##  · Tầng 9 (Z: +20): Bảng hiệu gỗ ruy băng "BUỔI DIỄN RỪNG XANH" có 2 sao vàng
##  · Tầng 10 (Z: +30): Nút Mũi tên tiếp tục (Continue Arrow) to tròn, hiện mượt mà sau 12 giây diễn
##
## Chuẩn Apple Kids Category 1.3:
##  · Không gián đoạn 12 giây diễn để bé và phụ huynh thưởng thức trọn vẹn
##  · Tự động lặp lại buổi diễn nếu chưa bấm chuyển màn

signal finished

enum Phase { SPROUT, SINGING, FRUIT, REST }

const SPROUT_SECONDS := 1.0
const NOTE_INTERVAL := 0.4      ## 23 nốt × 0,4 s ≈ 9,2 s
const FRUIT_SECONDS := 1.6      ## tổng ≈ 11,8 s, đúng "trọn vẹn 12 giây"
const REST_SECONDS := 4.0       ## thời gian nghỉ giữa các lượt diễn
const ANIMAL_RADIUS := 26.0
const ANIMAL_POP := 1.55
const CELEBRATION_DB := -6.0

var _chapter: int = 0
var _sequence: PackedInt32Array = PackedInt32Array()
var _phase: Phase = Phase.REST
var _timer: float = 0.0
var _played: int = 0
var _lit: int = -1
var _lit_age: float = 0.0
var _anim_time: float = 0.0

var _diorama: Control
var _bg_forest: TextureRect
var _magic_screen: TextureRect
var _screen_rays: Control
var _stage_deck: TextureRect

# 6 Nhân vật nghệ sĩ độc lập
var _musicians_container: Control
var _lion: TextureRect
var _bear: TextureRect
var _wizard: TextureRect
var _cat: TextureRect
var _elephant: TextureRect
var _owl: TextureRect
var _musicians_vfx: Control

# Bàn phím tiền cảnh & phụ kiện
var _keyboard: TextureRect
var _key_highlights: Control
var _crystal_cyan: TextureRect
var _crystal_purple: TextureRect
var _small_chest: TextureRect
var _banner: TextureRect

var _tree: MagicTree
var _animals: Control
var _footer: Control
var _hint: Label
var _continue: Button
var _bgm_player: AudioStreamPlayer
var _arrow_next_tex: Texture2D


func _ready() -> void:
	super()
	# 13 chứ không phải 12: ChestReward cũng ở 12, và hai lớp CanvasLayer cùng số
	# thì thứ tự vẽ rơi về thứ tự trong cây — tức là không xác định theo ý ta.
	# Buổi diễn luôn mở NGAY SAU rương (_on_reward_claimed), nên nó phải nằm trên.
	# Số 13 cũng đúng bằng cái mà comment đầu screen_router.gd vẫn ghi từ trước.
	layer = 13
	set_process(false)


func _ensure_built() -> void:
	if _tree != null:
		return
	_build()


func _build() -> void:
	# 0. Nền đen sâu để che khuất màn chơi phía dưới
	_add_backdrop(Color(0.03, 0.05, 0.04, 1.0))

	# Khung sân khấu Diorama chính (1280x720)
	_diorama = Control.new()
	_diorama.name = "DioramaStage"
	_diorama.set_anchors_preset(Control.PRESET_FULL_RECT)
	_diorama.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_diorama)

	# 1. Hậu cảnh rừng già hoàng hôn cổ tích
	_bg_forest = TextureRect.new()
	_bg_forest.name = "ForestBackdrop"
	_bg_forest.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg_forest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg_forest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_bg_forest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/tex_bg_twilight_forest.png"):
		_bg_forest.texture = load("res://assets/art/tex_bg_twilight_forest.png")
	elif ResourceLoader.exists("res://docs/mock-grand-finale.jpeg"):
		_bg_forest.texture = load("res://docs/mock-grand-finale.jpeg")
	_diorama.add_child(_bg_forest)

	# Đom đóm vàng lập lòe trong rừng
	var fireflies := MainMenu.FireflyOverlay.new()
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_diorama.add_child(fireflies)

	# 2. Màn hình tranh ma thuật dát vàng: Cây Đậu Thần & Rương Vàng
	_magic_screen = TextureRect.new()
	_magic_screen.name = "MagicScreen"
	_magic_screen.anchor_left = 0.19
	_magic_screen.anchor_top = 0.10
	_magic_screen.anchor_right = 0.81
	_magic_screen.anchor_bottom = 0.58
	_magic_screen.clip_contents = true
	_magic_screen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_magic_screen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_magic_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/spr_stage_magic_tree_chest.png"):
		_magic_screen.texture = load("res://assets/art/spr_stage_magic_tree_chest.png")
	_diorama.add_child(_magic_screen)

	# 3. Lớp vẽ hào quang kim quang (Sunburst Rays) từ rương báu mở bung
	_screen_rays = Control.new()
	_screen_rays.name = "ChestSunburstRays"
	_screen_rays.set_anchors_preset(Control.PRESET_FULL_RECT)
	_screen_rays.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_screen_rays.draw.connect(_draw_chest_rays)
	_magic_screen.add_child(_screen_rays)

	# 4. Bục Sàn Gỗ 2.5D (Wooden Stage Deck Platform) nối giữa tranh ma thuật và phím đàn
	_stage_deck = TextureRect.new()
	_stage_deck.name = "StageWoodenDeck"
	_stage_deck.anchor_left = 0.16
	_stage_deck.anchor_top = 0.46
	_stage_deck.anchor_right = 0.84
	_stage_deck.anchor_bottom = 0.63
	_stage_deck.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_stage_deck.stretch_mode = TextureRect.STRETCH_SCALE
	_stage_deck.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/spr_stage_wooden_deck.png"):
		_stage_deck.texture = load("res://assets/art/spr_stage_wooden_deck.png")
	_diorama.add_child(_stage_deck)

	# 5. Dàn 6 nghệ sĩ tí hon đứng vững chãi trên sàn gỗ
	_musicians_container = Control.new()
	_musicians_container.name = "MusiciansContainer"
	_musicians_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_musicians_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_diorama.add_child(_musicians_container)

	# Từng nhân vật đứng độc lập với nhạc cụ riêng biệt (được nâng lên mặt sàn gỗ):
	_lion = _create_musician("MusicianLion", "res://assets/art/spr_musician_lion.png", 0.18, 0.35, 0.32, 0.61)
	_bear = _create_musician("MusicianBear", "res://assets/art/spr_musician_bear.png", 0.29, 0.33, 0.42, 0.61)
	_wizard = _create_musician("MusicianWizard", "res://assets/art/spr_musician_wizard.png", 0.39, 0.28, 0.57, 0.61)
	_cat = _create_musician("MusicianCat", "res://assets/art/spr_musician_cat.png", 0.55, 0.40, 0.65, 0.61)
	_elephant = _create_musician("MusicianElephant", "res://assets/art/spr_musician_elephant.png", 0.62, 0.38, 0.72, 0.61)
	_owl = _create_musician("MusicianOwl", "res://assets/art/spr_musician_owl.png", 0.70, 0.45, 0.77, 0.61)

	# 6. Lớp vẽ hiệu ứng biểu diễn đặc thù (VFX)
	_musicians_vfx = Control.new()
	_musicians_vfx.name = "MusiciansVFX"
	_musicians_vfx.set_anchors_preset(Control.PRESET_FULL_RECT)
	_musicians_vfx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_musicians_vfx.draw.connect(_draw_musicians_vfx)
	_diorama.add_child(_musicians_vfx)

	# 7. Bàn phím piano 2.5D ở tiền cảnh
	_keyboard = TextureRect.new()
	_keyboard.name = "PianoKeyboardStage"
	_keyboard.anchor_left = 0.11
	_keyboard.anchor_top = 0.58
	_keyboard.anchor_right = 0.89
	_keyboard.anchor_bottom = 0.98
	_keyboard.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_keyboard.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_keyboard.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/spr_keyboard_stage_base.png"):
		_keyboard.texture = load("res://assets/art/spr_keyboard_stage_base.png")
	_diorama.add_child(_keyboard)

	# Lớp vẽ phát quang từng phím khi nốt vang lên
	_key_highlights = Control.new()
	_key_highlights.set_anchors_preset(Control.PRESET_FULL_RECT)
	_key_highlights.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_keyboard.add_child(_key_highlights)
	_key_highlights.draw.connect(_draw_key_glow)

	# 8. Cụm tinh thể thạch anh Cyan (góc trái trụ sân khấu)
	_crystal_cyan = TextureRect.new()
	_crystal_cyan.name = "CrystalCyan"
	_crystal_cyan.anchor_left = 0.00
	_crystal_cyan.anchor_top = 0.58
	_crystal_cyan.anchor_right = 0.15
	_crystal_cyan.anchor_bottom = 0.94
	_crystal_cyan.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_crystal_cyan.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_crystal_cyan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/spr_prop_crystal_cyan.png"):
		_crystal_cyan.texture = load("res://assets/art/spr_prop_crystal_cyan.png")
	_diorama.add_child(_crystal_cyan)

	# Cụm tinh thể thạch anh Magenta (góc phải trụ sân khấu)
	_crystal_purple = TextureRect.new()
	_crystal_purple.name = "CrystalPurple"
	_crystal_purple.anchor_left = 0.85
	_crystal_purple.anchor_top = 0.58
	_crystal_purple.anchor_right = 0.99
	_crystal_purple.anchor_bottom = 0.94
	_crystal_purple.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_crystal_purple.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_crystal_purple.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/spr_prop_crystal_purple.png"):
		_crystal_purple.texture = load("res://assets/art/spr_prop_crystal_purple.png")
	_diorama.add_child(_crystal_purple)

	# Chiếc rương báu nhỏ bằng gỗ (góc phải dưới bãi cỏ)
	_small_chest = TextureRect.new()
	_small_chest.name = "SmallChest"
	_small_chest.anchor_left = 0.89
	_small_chest.anchor_top = 0.72
	_small_chest.anchor_right = 0.99
	_small_chest.anchor_bottom = 0.97
	_small_chest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_small_chest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_small_chest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/spr_prop_small_closed_chest.png"):
		_small_chest.texture = load("res://assets/art/spr_prop_small_closed_chest.png")
	_diorama.add_child(_small_chest)

	# 9. Bảng hiệu gỗ ruy băng "BUỔI DIỄN RỪNG XANH" có 2 sao vàng
	_banner = TextureRect.new()
	_banner.name = "TitleBanner"
	_banner.anchor_left = 0.24
	_banner.anchor_top = 0.01
	_banner.anchor_right = 0.76
	_banner.anchor_bottom = 0.18
	_banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/ui_banner_grand_finale.png"):
		_banner.texture = load("res://assets/art/ui_banner_grand_finale.png")
	_diorama.add_child(_banner)

	# Cây thần logic giữ nguyên phục vụ tính toán nốt và tiến trình bài học
	_tree = MagicTree.new()
	_tree.visible = false
	_diorama.add_child(_tree)

	_animals = Control.new()
	_animals.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_animals.visible = false
	_diorama.add_child(_animals)

	# 10. Khay điều hướng xuất hiện sau khi diễn xong (Phase.REST)
	_footer = VBoxContainer.new()
	_footer.anchor_left = 0.15
	_footer.anchor_top = 0.75
	_footer.anchor_right = 0.85
	_footer.anchor_bottom = 0.98
	_footer.alignment = BoxContainer.ALIGNMENT_CENTER
	_footer.add_theme_constant_override("separation", 10)
	_footer.visible = false
	_diorama.add_child(_footer)

	if ResourceLoader.exists("res://assets/art/ui_arrow_next.png"):
		_arrow_next_tex = load("res://assets/art/ui_arrow_next.png")

	_hint = Label.new()
	_hint.text = "Muốn giữ lại buổi diễn? Bật quay màn hình của máy — buổi diễn sẽ tự chạy lại."
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.modulate = Color(1, 1, 1, 0.75)
	_hint.add_theme_font_size_override("font_size", 16)
	_footer.add_child(_hint)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 28)
	_footer.add_child(row)

	_continue = _make_button(Color("#3F9455"), _draw_continue_arrow, _on_continue)
	row.add_child(_continue)


func _create_musician(node_name: String, path: String, al: float, at: float, ar: float, ab: float) -> TextureRect:
	var rect := TextureRect.new()
	rect.name = node_name
	rect.anchor_left = al
	rect.anchor_top = at
	rect.anchor_right = ar
	rect.anchor_bottom = ab
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(path):
		rect.texture = load(path)
	_musicians_container.add_child(rect)
	return rect


func _make_button(accent: Color, painter: Callable, action: Callable) -> Button:
	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(180, 84)

	var box := StyleBoxFlat.new()
	box.bg_color = accent.darkened(0.35)
	box.set_corner_radius_all(42)
	for state in ["normal", "hover", "focus"]:
		button.add_theme_stylebox_override(state, box)
	var down := box.duplicate() as StyleBoxFlat
	down.bg_color = accent
	button.add_theme_stylebox_override("pressed", down)

	var face := Control.new()
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.add_child(face)
	face.draw.connect(painter.bind(face))

	button.pressed.connect(action)
	return button


# ------------------------------------------------------------------ vòng đời --

func play_for_chapter(chapter: int) -> void:
	_chapter = chapter
	_sequence = PackedInt32Array()
	var first := Chapters.first_page_of(chapter)
	for i in Chapters.pages_per_chapter():
		_sequence.append_array(Melodies.for_page(first + i))

	_ensure_built()
	_start_show()
	open_overlay()


func _start_show() -> void:
	_footer.visible = false
	_played = 0
	_lit = -1
	_lit_age = 0.0
	_timer = 0.0
	_anim_time = 0.0
	_phase = Phase.SPROUT
	_tree.reset_page()
	_tree.set_sequence(_sequence)
	_play_bgm()
	set_process(true)


func _process(delta: float) -> void:
	_timer += delta
	_lit_age += delta
	_anim_time += delta

	# 1. Nhịp thở tự nhiên của bảng hiệu gỗ
	if _banner != null:
		var banner_bob := sin(_anim_time * 2.2) * 3.5
		_banner.offset_top = banner_bob
		_banner.offset_bottom = banner_bob

	# 2. Xung phát quang của thạch anh
	if _crystal_cyan != null:
		var pulse := 0.90 + 0.18 * (0.5 + 0.5 * sin(_anim_time * 3.0))
		_crystal_cyan.modulate = Color(pulse, 1.0, 1.0, 1.0)

	if _crystal_purple != null:
		var pulse := 0.90 + 0.18 * (0.5 + 0.5 * sin(_anim_time * 3.0 + 1.2))
		_crystal_purple.modulate = Color(1.0, pulse, 1.0, 1.0)

	# 3. Hoạt ảnh độc bản cho từng nhân vật biểu diễn
	_animate_individual_musicians()

	# 4. Màn hình tranh ma thuật
	if _magic_screen != null:
		if _phase == Phase.FRUIT:
			var glow := 1.0 + 0.20 * sin(_timer * 10.0)
			_magic_screen.modulate = Color(glow, glow, glow * 0.95, 1.0)
		elif _phase == Phase.SINGING:
			_magic_screen.modulate = Color(1.05, 1.05, 1.02, 1.0)
		else:
			_magic_screen.modulate = Color.WHITE

	# 5. Cập nhật tiến trình biểu diễn
	match _phase:
		Phase.SPROUT:
			if _timer >= SPROUT_SECONDS:
				_enter(Phase.SINGING)
		Phase.SINGING:
			_tick_singing()
		Phase.FRUIT:
			if _timer >= FRUIT_SECONDS:
				_enter(Phase.REST)
		Phase.REST:
			if _timer >= REST_SECONDS:
				_start_show()

	if _screen_rays != null:
		_screen_rays.queue_redraw()

	if _musicians_vfx != null:
		_musicians_vfx.queue_redraw()

	if _key_highlights != null:
		_key_highlights.queue_redraw()


## Lập trình hoạt ảnh cử động độc bản cho từng nhân vật nghệ sĩ
func _animate_individual_musicians() -> void:
	var is_singing := (_phase == Phase.SINGING)

	# 1. SƯ TỬ (Trống)
	if _lion != null:
		_lion.pivot_offset = Vector2(_lion.size.x * 0.5, _lion.size.y * 0.95)
		if is_singing:
			# Nhịp gõ trống nhanh liên tục 2 dùi luân phiên
			var drum_swing := sin(_anim_time * 16.0)
			_lion.rotation_degrees = drum_swing * 2.8
			_lion.offset_top = abs(drum_swing) * 3.2
		else:
			_lion.rotation_degrees = sin(_anim_time * 2.2) * 1.2
			_lion.offset_top = sin(_anim_time * 2.2) * 2.0

		if _lit == 0: # Nốt C - Phím Sư Tử
			var pop := clampf(1.0 - (_lit_age / 0.35), 0.0, 1.0)
			_lion.scale = Vector2(1.0 - pop * 0.06, 1.0 + pop * 0.16)
		else:
			_lion.scale = Vector2.ONE

	# 2. GẤU (Đàn Harp)
	if _bear != null:
		_bear.pivot_offset = Vector2(_bear.size.x * 0.5, _bear.size.y * 0.95)
		if is_singing:
			# Tay gảy dây, người nghiêng dịu dàng theo thế đàn harp
			var harp_sway := sin(_anim_time * 3.5)
			_bear.rotation_degrees = harp_sway * 2.2
			_bear.offset_top = sin(_anim_time * 3.5 + 0.5) * 2.5
		else:
			_bear.rotation_degrees = sin(_anim_time * 1.8 + 1.0) * 1.5
			_bear.offset_top = sin(_anim_time * 1.8) * 1.5

		if _lit == 1: # Nốt D - Phím Gấu
			var pop := clampf(1.0 - (_lit_age / 0.35), 0.0, 1.0)
			_bear.scale = Vector2.ONE * (1.0 + pop * 0.12)
		else:
			_bear.scale = Vector2.ONE

	# 3. PHÙ THỦY (Đàn Piano upright)
	if _wizard != null:
		_wizard.pivot_offset = Vector2(_wizard.size.x * 0.5, _wizard.size.y * 0.95)
		if is_singing:
			# Đôi tay lướt phím piano, nón nhấp nhô nhịp nhàng
			var play_rock := sin(_anim_time * 11.0)
			_wizard.rotation_degrees = play_rock * 2.0
			_wizard.offset_top = -abs(play_rock) * 3.5
		else:
			_wizard.rotation_degrees = sin(_anim_time * 2.2 + 2.0) * 1.4
			_wizard.offset_top = sin(_anim_time * 2.2) * 1.8

		if _lit >= 0: # Phù thủy hưởng ứng mọi nốt nhạc
			var pop := clampf(1.0 - (_lit_age / 0.30), 0.0, 1.0)
			_wizard.scale = Vector2.ONE * (1.0 + pop * 0.08)
		else:
			_wizard.scale = Vector2.ONE

	# 4. MÈO (Thổi Sáo)
	if _cat != null:
		_cat.pivot_offset = Vector2(_cat.size.x * 0.5, _cat.size.y * 0.95)
		if is_singing:
			# Ống sáo lắc lư lượn sóng, thân người nhún nhẩy
			var flute_sway := sin(_anim_time * 4.2 + 2.2)
			_cat.rotation_degrees = flute_sway * 3.8
			_cat.offset_top = sin(_anim_time * 4.2) * 3.0
		else:
			_cat.rotation_degrees = sin(_anim_time * 2.0 + 3.0) * 2.0
			_cat.offset_top = sin(_anim_time * 2.0) * 1.5

		if _lit == 3: # Nốt F - Phím Mèo
			var pop := clampf(1.0 - (_lit_age / 0.35), 0.0, 1.0)
			_cat.scale = Vector2(1.0 - pop * 0.05, 1.0 + pop * 0.14)
			_cat.offset_top -= 5.0 * pop
		else:
			_cat.scale = Vector2.ONE

	# 5. VOI (Khiêu Vũ)
	if _elephant != null:
		_elephant.pivot_offset = Vector2(_elephant.size.x * 0.5, _elephant.size.y * 0.95)
		if is_singing:
			# Khiêu vũ đổi chân, đôi tai to đập nhịp phành phạch
			var dance_step := sin(_anim_time * 5.0 + 1.2)
			_elephant.rotation_degrees = dance_step * 4.2
			_elephant.offset_top = -abs(dance_step) * 4.5
			_elephant.scale.x = 1.0 + sin(_anim_time * 8.0) * 0.07
		else:
			_elephant.rotation_degrees = sin(_anim_time * 1.6) * 1.8
			_elephant.offset_top = sin(_anim_time * 1.6) * 1.5
			_elephant.scale.x = 1.0 + sin(_anim_time * 3.0) * 0.04

		if _lit == 5: # Nốt A - Phím Voi
			var pop := clampf(1.0 - (_lit_age / 0.40), 0.0, 1.0)
			_elephant.scale = Vector2.ONE * (1.0 + pop * 0.16)
			_elephant.offset_top -= 8.0 * pop
		else:
			_elephant.scale.y = 1.0

	# 6. CÚ MÈO (Ca Hát)
	if _owl != null:
		_owl.pivot_offset = Vector2(_owl.size.x * 0.5, _owl.size.y * 0.95)
		if is_singing:
			# Đầu nghiêng ngó ngộ nghĩnh, đôi cánh vỗ rộn rã
			var head_tilt := sin(_anim_time * 3.2 + 0.8)
			_owl.rotation_degrees = head_tilt * 5.5
			_owl.scale.y = 1.0 + sin(_anim_time * 10.0) * 0.12
			_owl.offset_top = sin(_anim_time * 5.0) * 2.5
		else:
			_owl.rotation_degrees = sin(_anim_time * 1.5) * 3.0
			_owl.scale.y = 1.0 + sin(_anim_time * 2.0) * 0.04
			_owl.offset_top = sin(_anim_time * 1.5) * 1.2

		if _lit == 6: # Nốt B - Phím Cú
			var pop := clampf(1.0 - (_lit_age / 0.35), 0.0, 1.0)
			_owl.scale.y = 1.0 + sin(_anim_time * 22.0) * 0.20
			_owl.scale.x = 1.0 + pop * 0.12
		else:
			_owl.scale.x = 1.0


func _enter(next: Phase) -> void:
	_phase = next
	_timer = 0.0
	match next:
		Phase.FRUIT:
			_tree.fruit()
			var ad := _get_audio()
			if ad != null and ad.has_method("play_sfx"):
				ad.play_sfx("chest_open")
		Phase.REST:
			_lit = -1
			_footer.visible = true
			finished.emit()


func _tick_singing() -> void:
	var due := int(_timer / NOTE_INTERVAL)
	while _played < _sequence.size() and due > _played:
		var note: int = _sequence[_played]
		var ad := _get_audio()
		if ad != null and ad.has_method("play_note_pitched"):
			ad.play_note_pitched(note, 1.0, CELEBRATION_DB)
		_tree.clear_singing()
		_tree.sing_leaf(note)
		_tree.bloom(note, _sequence.size())
		_lit = note
		_lit_age = 0.0
		_played += 1

	# Chuyển sang Phase.FRUIT khi đã tấu trọn vẹn giai điệu
	if _played >= _sequence.size() and _timer >= _sequence.size() * NOTE_INTERVAL:
		_enter(Phase.FRUIT)


func _get_audio() -> Node:
	return get_node_or_null("/root/AudioDirector")


func _on_continue() -> void:
	_stop_bgm()
	close_overlay()
	set_process(false)


func close_overlay() -> void:
	_stop_bgm()
	super()


func _play_bgm() -> void:
	var path := "res://assets/audio/bgm_chapter_end.ogg"
	if ResourceLoader.exists(path):
		if _bgm_player == null:
			_bgm_player = AudioStreamPlayer.new()
			_bgm_player.name = "ChapterEndBGM"
			_bgm_player.bus = &"Music" if AudioServer.get_bus_index(&"Music") != -1 else &"Master"
			add_child(_bgm_player)
		_bgm_player.stream = load(path)
		if is_inside_tree():
			_bgm_player.play()


func _stop_bgm() -> void:
	if _bgm_player != null and _bgm_player.playing:
		_bgm_player.stop()


func hint_visible() -> bool:
	return _footer != null and _footer.visible


func note_count() -> int:
	return _sequence.size()


func phase_name() -> String:
	return ["SPROUT", "SINGING", "FRUIT", "REST"][_phase]


func is_done() -> bool:
	return _phase == Phase.REST


# -------------------------------------------------------------------- vẽ VFX --

## 1. Hào quang kim quang tỏa sáng từ rương báu trên ngọn cây đậu thần
func _draw_chest_rays() -> void:
	if _screen_rays == null or _magic_screen == null:
		return

	var scr_size := _magic_screen.size
	if scr_size.x <= 0 or scr_size.y <= 0:
		return

	# Tọa độ rương báu ở khoảng giữa phía trên của màn tranh ma thuật
	var chest_center := Vector2(scr_size.x * 0.50, scr_size.y * 0.20)
	var ray_count := 12
	var ray_len := scr_size.y * 0.36
	var base_angle := _anim_time * 0.15
	var ray_alpha := 0.18

	if _phase == Phase.FRUIT:
		ray_alpha = 0.32 + 0.10 * sin(_anim_time * 8.0)
	elif _phase == Phase.SINGING:
		ray_alpha = 0.20 + 0.06 * sin(_anim_time * 4.0)

	# Quầng sáng hào quang trung tâm rương vàng (Radiant Chest Glow)
	_screen_rays.draw_circle(chest_center, 40.0, Color(1.0, 0.96, 0.65, ray_alpha * 1.6))
	_screen_rays.draw_circle(chest_center, 75.0, Color(1.0, 0.88, 0.40, ray_alpha * 0.8))

	# Các nan quạt kim quang xoay chuyển mềm mại
	for i in ray_count:
		var a1 := base_angle + float(i) * (TAU / float(ray_count))
		var a2 := a1 + 0.14
		var p1 := chest_center + Vector2(cos(a1), sin(a1)) * ray_len
		var p2 := chest_center + Vector2(cos(a2), sin(a2)) * ray_len
		var poly := PackedVector2Array([chest_center, p1, p2])
		_screen_rays.draw_colored_polygon(poly, Color(1.0, 0.92, 0.45, ray_alpha))


## 2. Hiệu ứng biểu diễn đặc thù của từng nhạc cụ trên sân khấu
func _draw_musicians_vfx() -> void:
	if _musicians_vfx == null:
		return

	# A. SÓNG ÂM CA HÁT TỪ MỎ CÚ MÈO
	if _owl != null and _owl.visible:
		var beak_pos := _owl.position + _owl.size * Vector2(0.42, 0.48)
		var ring_speed := 3.2 if _lit == 6 else 1.8
		for r_idx in 3:
			var ring_t := fmod(_anim_time * ring_speed + float(r_idx) * 0.33, 1.0)
			var radius := 6.0 + ring_t * 36.0
			var alpha := (1.0 - ring_t) * (0.85 if _lit == 6 else 0.45)
			_musicians_vfx.draw_arc(beak_pos, radius, -0.8, 0.8, 16, Color(1.0, 0.92, 0.45, alpha), 2.0)

	# B. LUỒNG GIÓ NỐT NHẠC TỪ ĐẦU ỐNG SÁO MÈO
	if _cat != null and _cat.visible:
		var flute_tip := _cat.position + _cat.size * Vector2(0.08, 0.42)
		for p_idx in 3:
			var pt := fmod(_anim_time * 1.5 + float(p_idx) * 0.33, 1.0)
			var px := flute_tip.x - 8.0 - pt * 28.0
			var py := flute_tip.y - 10.0 - pt * 32.0 + sin(pt * 6.0) * 6.0
			var dot_alpha := (1.0 - pt) * 0.65
			var dot_col := Color(0.45, 0.90, 0.80, dot_alpha) if p_idx % 2 == 0 else Color(1.0, 0.85, 0.35, dot_alpha)
			_musicians_vfx.draw_circle(Vector2(px, py), 3.5 * (1.0 - pt * 0.4), dot_col)

	# C. DÂY ĐÀN HARP GẤU PHÁT SÁNG LẤP LÁNH
	if _bear != null and _bear.visible:
		var harp_origin := _bear.position + _bear.size * Vector2(0.68, 0.38)
		for s in 4:
			var sx := harp_origin.x + float(s) * 5.0
			var sy_top := harp_origin.y
			var sy_bot := harp_origin.y + _bear.size.y * 0.35
			var wave := 0.5 + 0.5 * sin(_anim_time * 8.0 + float(s) * 1.2)
			var str_alpha := (0.35 + 0.50 * wave) if _lit == 1 else (0.15 + 0.25 * wave)
			_musicians_vfx.draw_line(Vector2(sx, sy_top), Vector2(sx, sy_bot), Color(1.0, 0.88, 0.35, str_alpha), 1.5)

	# D. SÓNG RUNG MẶT TRỐNG CỦA SƯ TỬ
	if _lion != null and _lion.visible and (_lit == 0 or (_phase == Phase.SINGING and fmod(_anim_time * 8.0, 1.0) < 0.25)):
		var drum_center := _lion.position + _lion.size * Vector2(0.52, 0.78)
		var d_ring := fmod(_anim_time * 4.0, 1.0)
		var d_rad := 8.0 + d_ring * 24.0
		var d_alpha := (1.0 - d_ring) * (0.8 if _lit == 0 else 0.4)
		_musicians_vfx.draw_arc(drum_center, d_rad, 0, TAU, 20, Color(1.0, 0.65, 0.25, d_alpha), 2.0)

	# E. BỤI SAO LẤP LÁNH TRÊN CHÓP NÓN PHÙ THỦY
	if _wizard != null and _wizard.visible:
		var star_pos := _wizard.position + _wizard.size * Vector2(0.31, 0.12)
		var star_pulse := 0.5 + 0.5 * sin(_anim_time * 6.0)
		var star_size := 4.0 + star_pulse * 4.0
		_musicians_vfx.draw_circle(star_pos, star_size, Color(1.0, 0.95, 0.50, 0.85))
		_musicians_vfx.draw_line(star_pos - Vector2(star_size * 1.8, 0), star_pos + Vector2(star_size * 1.8, 0), Color(1.0, 1.0, 0.8, 0.7), 1.5)
		_musicians_vfx.draw_line(star_pos - Vector2(0, star_size * 1.8), star_pos + Vector2(0, star_size * 1.8), Color(1.0, 1.0, 0.8, 0.7), 1.5)


## 3. Hào quang phát sáng trên phím piano tương ứng với nốt nhạc đang tấu
func _draw_key_glow() -> void:
	if _lit < 0 or _lit >= Notes.count() or _key_highlights == null:
		return

	var control_size := _key_highlights.size
	if control_size.x <= 0 or control_size.y <= 0:
		return

	# Texture gốc bàn phím: 1326 x 541 (STRETCH_KEEP_ASPECT_CENTERED)
	var tex_aspect: float = 1326.0 / 541.0
	var ctrl_aspect: float = control_size.x / control_size.y
	var draw_w := control_size.x
	var draw_h := control_size.y
	var offset_x := 0.0
	var offset_y := 0.0

	if ctrl_aspect > tex_aspect:
		draw_w = draw_h * tex_aspect
		offset_x = (control_size.x - draw_w) * 0.5
	else:
		draw_h = draw_w / tex_aspect
		offset_y = (control_size.y - draw_h) * 0.5

	# Vùng 7 phím trắng chuẩn: 9.1% đến 90.9%
	var key_area_x := offset_x + draw_w * 0.091
	var key_area_w := draw_w * 0.818
	var key_y := offset_y + draw_h * 0.28
	var key_h := draw_h * 0.65
	var single_w := key_area_w / float(Notes.count())

	var note_color: Color = Notes.TABLE[_lit]["color"]
	var life: float = clampf(1.0 - (_lit_age / NOTE_INTERVAL), 0.0, 1.0)
	var glow_alpha := life * 0.55

	var key_x := key_area_x + _lit * single_w
	var rect := Rect2(key_x + 4.0, key_y, single_w - 8.0, key_h)

	# Vệt sáng viền phím bo tròn nhẹ
	_key_highlights.draw_rect(rect, Color(note_color.r, note_color.g, note_color.b, glow_alpha), true)
	_key_highlights.draw_rect(rect, Color(1.0, 1.0, 0.9, glow_alpha * 0.8), false, 3.0)


func _draw_continue_arrow(face: Control) -> void:
	var c := face.size * 0.5
	var r := minf(face.size.x, face.size.y) * 0.28
	var ink := Color("#E8D9A0")

	if _arrow_next_tex != null:
		var arrow_size := r * 2.4
		var rect := Rect2(c.x - arrow_size * 0.5, c.y - arrow_size * 0.5, arrow_size, arrow_size)
		face.draw_texture_rect(_arrow_next_tex, rect, false, ink)
	else:
		face.draw_line(Vector2(c.x - r, c.y), Vector2(c.x + r, c.y), ink, 8.0, true)
		face.draw_line(
			Vector2(c.x + r, c.y), Vector2(c.x + r * 0.35, c.y - r * 0.6), ink, 8.0, true
		)
		face.draw_line(
			Vector2(c.x + r, c.y), Vector2(c.x + r * 0.35, c.y + r * 0.6), ink, 8.0, true
		)
