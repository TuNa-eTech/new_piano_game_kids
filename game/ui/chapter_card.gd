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
var _shader_mat: ShaderMaterial
var _tilt_tween: Tween
var _entry_tween: Tween
var _idle_time: float = 0.0


func setup(index: int) -> void:
	chapter = index
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP

	_face = Control.new()
	_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_face.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_face)
	_face.draw.connect(_draw_face)

	# Nạp shader phối cảnh 2.5D cho thẻ
	if ResourceLoader.exists("res://game/diorama/shaders/card_tilt_25d.gdshader"):
		var sh := load("res://game/diorama/shaders/card_tilt_25d.gdshader") as Shader
		if sh != null:
			_shader_mat = ShaderMaterial.new()
			_shader_mat.shader = sh
			_face.material = _shader_mat

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	item_rect_changed.connect(_on_resized)

	refresh()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		pivot_offset = size * 0.5


func _on_resized() -> void:
	pivot_offset = size * 0.5


func _process(delta: float) -> void:
	_idle_time += delta
	if _face != null:
		# Hiệu ứng trôi bồng bềnh 2.5D tự nhiên (Floating wave)
		_face.position.y = sin(_idle_time * 2.2 + chapter * 1.4) * 3.5
		_face.queue_redraw()


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
	var gs := _get_game_state()
	var unlocked := true
	if gs != null and gs.has_method("chapter_unlocked"):
		unlocked = gs.chapter_unlocked(chapter)
	disabled = false
	if _shader_mat != null:
		_shader_mat.set_shader_parameter("is_unlocked", unlocked)
	if _face != null:
		_face.queue_redraw()


func play_tap_feedback() -> void:
	var gs := _get_game_state()
	var unlocked := true
	if gs != null and gs.has_method("chapter_unlocked"):
		unlocked = gs.chapter_unlocked(chapter)
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


func _draw_face() -> void:
	var w := _face.size.x
	var h := _face.size.y
	var gs := _get_game_state()
	var unlocked := true
	if gs != null and gs.has_method("chapter_unlocked"):
		unlocked = gs.chapter_unlocked(chapter)
	var r := Rect2(0, 0, w, h)
	var pulse := 0.5 + 0.5 * sin(_idle_time * 2.8)

	if not unlocked:
		# Với Chương 3 (chapter == 2): Đã có sẵn ổ khóa và đai da vẽ tay trong concept
		if chapter == 2:
			return

		# Đối với các chương khác khi bị khóa
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.06, 0.08, 0.12, 0.52)
		style.set_corner_radius_all(24)
		_face.draw_style_box(style, r)

		_draw_leather_strap(w, h)
		_draw_lock(Vector2(w * 0.5, h * 0.52), minf(w, h) * 0.18)
		return

	# Khi chương mở: vẽ viền hào quang vàng nhịp thở mềm mại
	var glow_style := StyleBoxFlat.new()
	glow_style.bg_color = Color.TRANSPARENT
	glow_style.border_color = Color(1.0, 0.92, 0.50, 0.18 + 0.22 * pulse)
	glow_style.set_border_width_all(6)
	glow_style.set_corner_radius_all(26)
	_face.draw_style_box(glow_style, r.grow(3.0 * pulse))

	var active_style := StyleBoxFlat.new()
	active_style.bg_color = Color.TRANSPARENT
	active_style.border_color = Color(1.0, 0.88, 0.45, 0.65 + 0.30 * pulse)
	active_style.set_border_width_all(4)
	active_style.set_corner_radius_all(24)
	_face.draw_style_box(active_style, r)

	# Điểm nhấn bụi sao lấp lánh cho Thẻ Chương 1 (nơi có Lọ Sao nôi lá)
	if chapter == 0:
		var star_pos := Vector2(w * 0.5, h * 0.76)
		var star_pulse := 0.5 + 0.5 * sin(_idle_time * 3.6)
		_face.draw_circle(star_pos, 4.0 * (1.0 + 0.25 * star_pulse), Color(1.0, 0.96, 0.65, 0.75 + 0.25 * star_pulse))
		_face.draw_circle(star_pos, 9.0 * (1.0 + 0.25 * star_pulse), Color(1.0, 0.85, 0.35, 0.28 * star_pulse))

	# 5 chấm tiến độ nhỏ tinh tế ở cạnh dưới thẻ
	var pages := Chapters.pages_per_chapter()
	var first := Chapters.first_page_of(chapter)
	var dot_r := minf(w, h) * 0.038
	var dot_gap := dot_r * 3.2
	var dot_x := w * 0.5 - dot_gap * (pages - 1) * 0.5
	var dot_y := h * 0.88

	var max_page := 0
	var cur_page := 0
	if gs != null:
		if "max_page_reached" in gs:
			max_page = gs.max_page_reached
		if "page_index" in gs:
			cur_page = gs.page_index

	for i in pages:
		var page := first + i
		var centre := Vector2(dot_x + i * dot_gap, dot_y)
		if max_page > page:
			_face.draw_circle(centre, dot_r, Color("#F5D77F"))
		elif cur_page == page:
			_face.draw_circle(centre, dot_r * 1.3, Color("#FFFFFF"))
			_face.draw_circle(centre, dot_r * 0.8, Color("#F5D77F"))
		else:
			_face.draw_circle(centre, dot_r, Color(0.3, 0.35, 0.38, 0.6))


func _get_game_state() -> Node:
	return get_node_or_null("/root/GameState")


func _draw_leather_strap(w: float, h: float) -> void:
	var strap_h := h * 0.14
	var strap_y := h * 0.52 - strap_h * 0.5
	var strap_rect := Rect2(0, strap_y, w, strap_h)
	var leather_col := Color("#4E2E18")
	_face.draw_rect(strap_rect, leather_col, true)

	var stitch_col := Color("#C89E58")
	_face.draw_line(Vector2(0, strap_y + 2), Vector2(w, strap_y + 2), stitch_col, 1.5)
	_face.draw_line(Vector2(0, strap_y + strap_h - 2), Vector2(w, strap_y + strap_h - 2), stitch_col, 1.5)


func _draw_lock(c: Vector2, r: float) -> void:
	var gold := Color("#F8CE65")
	var dark_brass := Color("#825A1E")
	var brass_body := Color("#C2923C")

	var bw := r * 1.5
	var bh := r * 1.3
	var shackle_r := bw * 0.38
	var shackle_c := Vector2(c.x, c.y - bh * 0.28)
	_face.draw_arc(shackle_c, shackle_r, PI, TAU, 24, gold, 5.0, true)

	var body_rect := Rect2(c.x - bw * 0.5, c.y - bh * 0.25, bw, bh)
	_face.draw_rect(body_rect, brass_body, true)
	_face.draw_rect(body_rect, gold, false, 3.5)

	_face.draw_line(Vector2(body_rect.position.x + 2, body_rect.end.y - 2), Vector2(body_rect.end.x - 2, body_rect.end.y - 2), dark_brass, 2.0)

	var hole_y := c.y + bh * 0.15
	_face.draw_circle(Vector2(c.x, hole_y), r * 0.20, Color(0.12, 0.08, 0.04))
	_face.draw_rect(Rect2(c.x - r * 0.08, hole_y, r * 0.16, r * 0.28), Color(0.12, 0.08, 0.04), true)
