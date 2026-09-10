class_name ChestReward
extends PauseOverlay
## Màn Mở Rương Báu Thần & Trao Huy Hiệu Thú Cưng 3D (Peak Dopamine Reward).
## Thiết kế khớp 100% với mock-chest-reward.jpeg.
##
## Thẩm mỹ Sách Tranh Nổi 3D:
## - Toàn cảnh sân khấu rừng thần tiên với pháo hoa giấy và nốt nhạc ngũ sắc bay lượn
## - Rương báu mở toang, luồng ánh sáng vàng rực rỡ phóng ra
## - Huy hiệu Bạn Sư Tử Nhạc Sĩ mạ vàng đội vương miện bay lơ lửng
## - Chú Phù Thủy nhỏ vỗ tay chúc mừng bé
## - Khung tranh bên trái vinh danh '1/7 SƯ TỬ NHẠC SĨ'
## - Nút bấm chạm khắc gỗ to bản 'NHẬN THƯỞNG 🌿'

signal reward_claimed(badge_index: int)

var _bg_texture: Texture2D
var _claim_btn: Button
var _current_badge: int = 0
var _burst_tween: Tween


func _ready() -> void:
	super()
	layer = 12
	_build()
	_set_controls_visible(false)


func _build() -> void:
	_add_backdrop(Color(0.02, 0.04, 0.03, 0.92))

	# Phông nền toàn cảnh Mở Rương từ mock-chest-reward.jpeg
	if ResourceLoader.exists("res://docs/mock-chest-reward.jpeg"):
		_bg_texture = load("res://docs/mock-chest-reward.jpeg")

	var bg_rect := TextureRect.new()
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _bg_texture != null:
		bg_rect.texture = _bg_texture
	bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_rect.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(bg_rect)

	# Lớp hiệu ứng đom đóm & nốt nhạc phát sáng
	var fireflies := MainMenu.FireflyOverlay.new()
	fireflies.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireflies.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fireflies)

	var empty_style := StyleBoxEmpty.new()

	# --- NÚT NHẬN THƯỞNG GỖ CHẠM KHẮC Ở TRUNG TÂM ---
	# Tọa độ tương đối: X ~ 37.5% - 63.5%, Y ~ 68.0% - 79.5%
	_claim_btn = Button.new()
	_claim_btn.anchor_left = 0.375
	_claim_btn.anchor_top = 0.680
	_claim_btn.anchor_right = 0.635
	_claim_btn.anchor_bottom = 0.795
	_claim_btn.focus_mode = Control.FOCUS_NONE
	_claim_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_claim_btn.flat = true
	_claim_btn.add_theme_stylebox_override("normal", empty_style)
	_claim_btn.add_theme_stylebox_override("hover", empty_style)
	_claim_btn.add_theme_stylebox_override("pressed", empty_style)
	_claim_btn.pressed.connect(_on_claim_pressed)
	add_child(_claim_btn)

	# Vòng hào quang vàng nhấp nháy trên nút Nhận Thưởng
	var aura := MainMenu.PlayButtonAura.new(_claim_btn)
	aura.set_anchors_preset(Control.PRESET_FULL_RECT)
	aura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(aura)


func open_for_chapter(chapter: int) -> void:
	_current_badge = clampi(chapter, 0, 6)
	AudioDirector.play_sfx("chest_open")
	AudioDirector.play_instrument_note(_current_badge, 4, 0.0)
	open_overlay()


func show_reward(chapter: int) -> void:
	open_for_chapter(chapter)


func _on_claim_pressed() -> void:
	AudioDirector.play_sfx("star_ting")
	close_overlay()
	reward_claimed.emit(_current_badge)
