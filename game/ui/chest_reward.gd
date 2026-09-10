class_name ChestReward
extends PauseOverlay
## Màn Mở Rương Báu Thần & Trao Huy Hiệu Thú Cưng 3D (Peak Dopamine Reward).
##
## Xuất hiện khi hoàn thành trang cuối của chương hoặc chạm rương báu.
## Bung nắp rương, tỏa hào quang vàng và tặng huy hiệu bạn thú sưu tầm.

signal reward_claimed(badge_index: int)

var _badge_rect: TextureRect
var _badge_name_label: Label
var _current_badge: int = 0


func _ready() -> void:
	super()
	layer = 12
	_build()
	_set_controls_visible(false)


func _build() -> void:
	_add_backdrop(Color(0.02, 0.05, 0.04, 0.85))

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(580, 440)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.16, 0.10, 0.06, 0.98) # Gỗ sồi nâu ấm
	panel_style.border_color = Color(0.85, 0.72, 0.35, 0.95) # Viền mạ vàng
	panel_style.set_border_width_all(4)
	panel_style.set_corner_radius_all(28)
	panel_style.shadow_color = Color(0, 0, 0, 0.5)
	panel_style.shadow_size = 20
	panel_style.content_margin_left = 36
	panel_style.content_margin_right = 36
	panel_style.content_margin_top = 28
	panel_style.content_margin_bottom = 28
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	# Tiêu đề
	var title := Label.new()
	title.text = "RƯƠNG BÁU THẦN BUNG NẮP! ★"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.96, 0.86, 0.58))
	vbox.add_child(title)

	# Rương mở + Huy hiệu bay lên + Hào quang
	var reward_box := Control.new()
	reward_box.custom_minimum_size = Vector2(220, 200)
	vbox.add_child(reward_box)

	if ResourceLoader.exists("res://assets/art/fx_golden_burst.png"):
		var burst := TextureRect.new()
		burst.texture = load("res://assets/art/fx_golden_burst.png")
		burst.custom_minimum_size = Vector2(240, 220)
		burst.position = Vector2(-10, -40)
		burst.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		burst.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		burst.modulate.a = 0.85
		reward_box.add_child(burst)

	if ResourceLoader.exists("res://assets/art/chest_open.png"):
		var chest := TextureRect.new()
		chest.texture = load("res://assets/art/chest_open.png")
		chest.custom_minimum_size = Vector2(150, 150)
		chest.position = Vector2(35, 45)
		chest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		chest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		reward_box.add_child(chest)

	_badge_rect = TextureRect.new()
	_badge_rect.custom_minimum_size = Vector2(110, 110)
	_badge_rect.position = Vector2(55, -10)
	_badge_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_badge_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	reward_box.add_child(_badge_rect)

	# Tên huy hiệu
	_badge_name_label = Label.new()
	_badge_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_badge_name_label.add_theme_font_size_override("font_size", 18)
	_badge_name_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.65))
	vbox.add_child(_badge_name_label)

	# Nút Nhận Thưởng
	var claim_btn := Button.new()
	claim_btn.text = "NHẬN THƯỞNG 🌿"
	claim_btn.custom_minimum_size = Vector2(240, 52)
	claim_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var claim_style := StyleBoxFlat.new()
	claim_style.bg_color = Color(0.25, 0.58, 0.32, 0.95)
	claim_style.border_color = Color(0.45, 0.85, 0.55)
	claim_style.set_border_width_all(2)
	claim_style.set_corner_radius_all(26)
	claim_btn.add_theme_stylebox_override("normal", claim_style)
	claim_btn.add_theme_stylebox_override("hover", claim_style)
	claim_btn.add_theme_stylebox_override("pressed", claim_style)
	claim_btn.add_theme_font_size_override("font_size", 17)
	claim_btn.add_theme_color_override("font_color", Color.WHITE)
	claim_btn.pressed.connect(_on_claim_pressed)
	vbox.add_child(claim_btn)


func show_reward(badge_idx: int) -> void:
	_current_badge = badge_idx
	var animal_name := Notes.animal_of(badge_idx)
	_badge_name_label.text = "Huy Hiệu: Bạn %s Nhạc Sĩ!" % animal_name

	var badge_path := "res://assets/art/badge_%s.png" % animal_name.to_lower()
	# Map một số tên động vật tiếng Việt sang tên asset
	var map_names := {
		"Sư tử": "badge_lion.png",
		"Gấu": "badge_bear.png",
		"Thỏ": "badge_rabbit.png",
		"Mèo": "badge_cat.png",
		"Khỉ": "badge_monkey.png",
		"Voi": "badge_elephant.png",
		"Cú": "badge_owl.png"
	}
	if map_names.has(animal_name):
		badge_path = "res://assets/art/" + map_names[animal_name]

	if ResourceLoader.exists(badge_path):
		_badge_rect.texture = load(badge_path)

	open_overlay()

	# Hiệu ứng nảy huy hiệu
	_badge_rect.scale = Vector2(0.3, 0.3)
	_badge_rect.pivot_offset = _badge_rect.size * 0.5
	var tw := create_tween().bind_node(self)
	tw.tween_property(_badge_rect, "scale", Vector2(1.2, 1.2), 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_badge_rect, "scale", Vector2(1.0, 1.0), 0.15)


func _on_claim_pressed() -> void:
	if AudioDirector != null:
		AudioDirector.play_sfx("chest_open")
	close_overlay()
	reward_claimed.emit(_current_badge)
