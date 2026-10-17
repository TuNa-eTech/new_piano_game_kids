class_name ChapterCard
extends Button
## Một thẻ chương trên bản đồ 2.5D Diorama (khớp 100% với mock-chapter-map.jpeg).
##
## Thẩm mỹ Sách Tranh Nổi 2.5D & Animation System:
## - Pop-up intro: Nhô lên nhún nảy từ trang sách mở với hiệu ứng đàn hồi (TRANS_BACK)
## - Idle animation: Trôi bồng bềnh nhẹ nhàng trong không gian 2.5D, nhịp thở hào quang vàng
## - Hover / Touch drag: Nghiêng phối cảnh 2.5D theo ngón tay bé, nâng thẻ lên khỏi trang sách
## - Phản hồi xúc giác: Nhún nén nhả bung sao vàng khi mở, rung lắc ổ khóa kim loại khi bị khóa

var chapter: int = 0
var _face: Control
var _shadow: Panel
var _card_art: TextureRect
var _dim_overlay: Panel
var _glow_border: Panel
var _strap_rect: TextureRect
var _padlock_rect: TextureRect
var _cradle_rect: TextureRect
var _dots_layer: Control

var _shader_mat: ShaderMaterial
var _tilt_tween: Tween
var _entry_tween: Tween
var _idle_time: float = 0.0
var _card_tex: Texture2D = null
var _star_jar_cradle_tex: Texture2D = null
var _padlock_tex: Texture2D = null
var _leather_strap_tex: Texture2D = null


func setup(index: int) -> void:
	chapter = index
	var card_paths := [
		"res://assets/art/card_ch1_flute.png",
		"res://assets/art/card_ch2_kalimba.png",
		"res://assets/art/card_ch3_chimes.png"
	]
	if index >= 0 and index < card_paths.size() and ResourceLoader.exists(card_paths[index]):
		_card_tex = load(card_paths[index])
	elif ResourceLoader.exists("res://assets/art/card_chapter.png"):
		_card_tex = load("res://assets/art/card_chapter.png")

	if ResourceLoader.exists("res://assets/art/spr_star_jar_cradle.png"):
		_star_jar_cradle_tex = load("res://assets/art/spr_star_jar_cradle.png")
	if ResourceLoader.exists("res://assets/art/spr_padlock_brass.png"):
		_padlock_tex = load("res://assets/art/spr_padlock_brass.png")
	if ResourceLoader.exists("res://assets/art/spr_leather_belt_strap.png"):
		_leather_strap_tex = load("res://assets/art/spr_leather_belt_strap.png")

	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP

	# 1. Khung chứa chính để diễn hoạt ảnh nhô lên và trôi nổi (Pop-up Book Face)
	_face = Control.new()
	_face.name = "Face"
	_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_face.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_face)

	# 2. Bóng đổ tiếp xúc 2.5D (Contact Drop Shadow lên trang sách)
	_shadow = Panel.new()
	_shadow.name = "DropShadow"
	_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shadow_style := StyleBoxFlat.new()
	shadow_style.bg_color = Color(0.12, 0.07, 0.03, 0.28)
	shadow_style.set_corner_radius_all(20)
	_shadow.add_theme_stylebox_override("panel", shadow_style)
	_face.add_child(_shadow)

	# 3. Tranh minh họa thế giới 2.5D với Shader nghiêng & vệt sáng
	_card_art = TextureRect.new()
	_card_art.name = "CardArt"
	_card_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	_card_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_card_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if _card_tex != null:
		_card_art.texture = _card_tex

	if ResourceLoader.exists("res://game/diorama/shaders/card_tilt_25d.gdshader"):
		var sh := load("res://game/diorama/shaders/card_tilt_25d.gdshader") as Shader
		if sh != null:
			_shader_mat = ShaderMaterial.new()
			_shader_mat.shader = sh
			_card_art.material = _shader_mat
	_face.add_child(_card_art)

	# 4. Lớp phủ mờ khi bị khóa (Dim Overlay)
	_dim_overlay = Panel.new()
	_dim_overlay.name = "DimOverlay"
	_dim_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	var dim_style := StyleBoxFlat.new()
	dim_style.bg_color = Color(0.04, 0.06, 0.08, 0.50)
	dim_style.set_corner_radius_all(18)
	_dim_overlay.add_theme_stylebox_override("panel", dim_style)
	_face.add_child(_dim_overlay)

	# 5. Viền hào quang vàng nhấp nháy khi mở khóa (Active Glow Border)
	_glow_border = Panel.new()
	_glow_border.name = "GlowBorder"
	_glow_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow_border.set_anchors_preset(Control.PRESET_FULL_RECT)
	var glow_style := StyleBoxFlat.new()
	glow_style.bg_color = Color.TRANSPARENT
	glow_style.draw_center = false
	glow_style.border_color = Color(1.0, 0.88, 0.45, 0.75)
	glow_style.set_border_width_all(3)
	glow_style.set_corner_radius_all(18)
	_glow_border.add_theme_stylebox_override("panel", glow_style)
	_face.add_child(_glow_border)

	# 6. Đai da thắt ngang cho thẻ khóa (Leather Belt Strap)
	_strap_rect = TextureRect.new()
	_strap_rect.name = "LeatherStrap"
	_strap_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_strap_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_strap_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if _leather_strap_tex != null:
		_strap_rect.texture = _leather_strap_tex
	_face.add_child(_strap_rect)

	# 7. Ổ khóa đồng hoàng gia 3D (Brass Padlock)
	_padlock_rect = TextureRect.new()
	_padlock_rect.name = "Padlock"
	_padlock_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_padlock_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_padlock_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if _padlock_tex != null:
		_padlock_rect.texture = _padlock_tex
	_face.add_child(_padlock_rect)

	# 8. Đạo cụ Lọ sao nôi lá non nổi bật ở chân Thẻ Chương 1
	_cradle_rect = TextureRect.new()
	_cradle_rect.name = "StarJarCradle"
	_cradle_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cradle_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cradle_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if _star_jar_cradle_tex != null:
		_cradle_rect.texture = _star_jar_cradle_tex
	_face.add_child(_cradle_rect)

	# 9. Lớp vẽ 5 chấm tròn tiến độ bài hát (Progress Dots)
	_dots_layer = Control.new()
	_dots_layer.name = "ProgressDotsLayer"
	_dots_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dots_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dots_layer.draw.connect(_draw_dots)
	_face.add_child(_dots_layer)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	item_rect_changed.connect(_on_resized)

	_update_layout_rects()
	refresh()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		pivot_offset = size * 0.5
		_update_layout_rects()


func _on_resized() -> void:
	pivot_offset = size * 0.5
	_update_layout_rects()


func _update_layout_rects() -> void:
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return

	# Bóng đổ hơi lệch xuống dưới và sang phải nhẹ
	if _shadow != null:
		_shadow.position = Vector2(w * 0.03, h * 0.03)
		_shadow.size = Vector2(w * 0.94, h * 0.94)

	# Đai da ở độ cao 48%
	if _strap_rect != null:
		var strap_h := h * 0.16
		_strap_rect.position = Vector2(-w * 0.04, h * 0.48 - strap_h * 0.5)
		_strap_rect.size = Vector2(w * 1.08, strap_h)

	# Ổ khóa đồng ở tâm đai da
	if _padlock_rect != null:
		var lock_w := w * 0.44
		var lock_h := lock_w * 1.25
		_padlock_rect.position = Vector2(w * 0.5 - lock_w * 0.5, h * 0.48 - lock_h * 0.48)
		_padlock_rect.size = Vector2(lock_w, lock_h)

	# Nôi sao nôi lá non ở chân thẻ Chương 1 (đặt ở 68% chiều cao để không đè chấm tiến độ)
	if _cradle_rect != null:
		var cradle_w := w * 0.68
		var cradle_h := cradle_w
		_cradle_rect.position = Vector2(w * 0.5 - cradle_w * 0.5, h * 0.70 - cradle_h * 0.5)
		_cradle_rect.size = Vector2(cradle_w, cradle_h)


func _process(delta: float) -> void:
	_idle_time += delta
	if _face != null:
		# Hiệu ứng trôi bồng bềnh 2.5D tự nhiên (Floating wave)
		_face.position.y = sin(_idle_time * 2.2 + chapter * 1.4) * 3.5

	# Hoạt ảnh nhịp thở cho viền sáng vàng kim
	if _glow_border != null and _glow_border.visible:
		var pulse := 0.5 + 0.5 * sin(_idle_time * 2.8)
		_glow_border.modulate.a = 0.50 + 0.45 * pulse

	# Hoạt ảnh nhún nhẹ cho Nôi Sao
	if _cradle_rect != null and _cradle_rect.visible:
		var jar_float := sin(_idle_time * 2.5) * 2.5
		var h := size.y
		var cradle_h := _cradle_rect.size.y
		_cradle_rect.position.y = (h * 0.70 - cradle_h * 0.5) + jar_float


func pop_up_intro(delay: float = 0.0) -> void:
	scale = Vector2(0.25, 0.25)
	modulate.a = 0.0
	if _entry_tween != null and _entry_tween.is_valid():
		_entry_tween.kill()
	_entry_tween = create_tween().set_parallel(false)
	if delay > 0.0:
		_entry_tween.tween_interval(delay)
	_entry_tween.tween_property(self, "modulate:a", 1.0, 0.12)
	_entry_tween.parallel().tween_property(self, "scale", Vector2(1.06, 1.06), 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_entry_tween.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE)


func refresh() -> void:
	var unlocked := GameState.chapter_unlocked(chapter)
	disabled = false
	if _shader_mat != null:
		_shader_mat.set_shader_parameter("is_unlocked", unlocked)

	if _dim_overlay != null:
		_dim_overlay.visible = not unlocked
	if _strap_rect != null:
		_strap_rect.visible = not unlocked
	if _padlock_rect != null:
		_padlock_rect.visible = not unlocked

	if _glow_border != null:
		_glow_border.visible = unlocked
	if _cradle_rect != null:
		_cradle_rect.visible = (unlocked and chapter == 0)

	if _dots_layer != null:
		_dots_layer.queue_redraw()


func play_tap_feedback() -> void:
	var unlocked := GameState.chapter_unlocked(chapter)
	if _tilt_tween != null and _tilt_tween.is_valid():
		_tilt_tween.kill()
	_tilt_tween = create_tween()

	if unlocked:
		# Hiệu ứng lò xo nhún nảy (Spring Bounce)
		_tilt_tween.tween_property(self, "scale", Vector2(0.92, 0.92), 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tilt_tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_tilt_tween.tween_property(self, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_SINE)
	else:
		# Hiệu ứng rung lắc ngang của ổ khóa đồng khi bị khóa (Jiggle Shake)
		var orig_x := position.x
		_tilt_tween.tween_property(self, "position:x", orig_x - 8.0, 0.04)
		_tilt_tween.tween_property(self, "position:x", orig_x + 8.0, 0.05)
		_tilt_tween.tween_property(self, "position:x", orig_x - 5.0, 0.04)
		_tilt_tween.tween_property(self, "position:x", orig_x + 5.0, 0.04)
		_tilt_tween.tween_property(self, "position:x", orig_x, 0.04)


func _on_mouse_entered() -> void:
	if _tilt_tween != null and _tilt_tween.is_valid():
		return
	create_tween().tween_property(self, "scale", Vector2(1.035, 1.035), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_mouse_exited() -> void:
	_reset_tilt()
	if _tilt_tween != null and _tilt_tween.is_valid():
		return
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		if size.x > 0.0 and size.y > 0.0:
			var pos: Vector2 = event.position
			var norm: Vector2 = (pos / size) - Vector2(0.5, 0.5)
			_set_tilt(norm * 1.5)
	elif event is InputEventMouseButton and not event.pressed:
		_reset_tilt()


func _set_tilt(offset: Vector2) -> void:
	if _shader_mat != null:
		_shader_mat.set_shader_parameter("tilt_offset", offset.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0)))


func _reset_tilt() -> void:
	if _shader_mat != null:
		_shader_mat.set_shader_parameter("tilt_offset", Vector2.ZERO)


func _draw_dots() -> void:
	if _dots_layer == null:
		return
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return

	# 5 chấm tiến độ nhỏ tinh tế ở cạnh dưới thẻ
	var pages := Chapters.pages_per_chapter()
	var first := Chapters.first_page_of(chapter)
	var dot_r := minf(w, h) * 0.038
	var dot_gap := dot_r * 3.2
	var dot_x := w * 0.5 - dot_gap * (pages - 1) * 0.5
	var dot_y := h * 0.92

	var max_page: int = GameState.max_page_reached
	var cur_page: int = GameState.page_index

	for i in pages:
		var page := first + i
		var centre := Vector2(dot_x + i * dot_gap, dot_y)
		if max_page > page:
			_dots_layer.draw_circle(centre, dot_r, Color("#F5D77F"))
		elif cur_page == page:
			_dots_layer.draw_circle(centre, dot_r * 1.3, Color("#FFFFFF"))
			_dots_layer.draw_circle(centre, dot_r * 0.8, Color("#F5D77F"))
		else:
			_dots_layer.draw_circle(centre, dot_r, Color(0.3, 0.35, 0.38, 0.6))
