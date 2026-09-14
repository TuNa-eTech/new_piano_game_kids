class_name CottageMenuButton
extends Control
## Nút Menu hình Ngôi Nhà Nấm Cổ Tích góc phải trên (docs/mock-game-play.jpeg).
##
## Fix UI 7 nhóm (nhóm 4): thống nhất MỘT hành vi "giữ 2s mới mở bản đồ" cho cả
## Cottage (nhà nấm, bé dễ thấy) lẫn HoldButton (vòng tròn, máy đo dùng).
## Chạm nhả ngay chỉ nảy animation, KHÔNG mở map — chống bé thoát nhầm.
## Vòng tiến trình vàng vẽ đè lên nhà nấm để người lớn thấy đã giữ bao nhiêu.

signal activated
signal hold_progress(ratio: float)

## Apple Kids Category: touch-target tối thiểu 88x88 pt.
const BTN_SIZE := Vector2(96.0, 96.0)
## Quyết định 03 chốt 2 giây — khớp HoldButton.
const HOLD_SECONDS := 2.0
const RELEASE_SECONDS := 0.3
const RING_WIDTH := 6.0

var _tex_rect: TextureRect
var _holding: bool = false
var _held: float = 0.0
var _ratio: float = 0.0
## Ngón đang giữ nút này (event.index). gui_input đã cách ly với ngón trên
## đàn, nhưng vẫn phải nhớ đúng ngón để ngón thứ 2 chạm vào không reset
## lượt giữ dở, và để vuốt ra ngoài thì abort.
var _finger: int = -1
var _mouse_holding: bool = false


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED, \
		NOTIFICATION_APPLICATION_RESUMED, \
		NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			cancel()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS

	_tex_rect = TextureRect.new()
	_tex_rect.name = "Texture"
	_tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
	_tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if ResourceLoader.exists("res://assets/art/ui_btn_menu_cottage.png"):
		_tex_rect.texture = load("res://assets/art/ui_btn_menu_cottage.png")
	add_child(_tex_rect)
	_update_pivot()
	resized.connect(_update_pivot)

	gui_input.connect(_on_gui_input)


func _update_pivot() -> void:
	if _tex_rect != null:
		_tex_rect.pivot_offset = size * 0.5
	pivot_offset = size * 0.5


func _process(delta: float) -> void:
	var before := _ratio
	if _holding:
		_held += delta
		_ratio = minf(1.0, _held / HOLD_SECONDS)
		if _ratio >= 1.0:
			_holding = false
			_held = 0.0
			_ratio = 0.0
			_animate_release()
			var audio := get_node_or_null("/root/AudioDirector")
			if audio != null and audio.has_method("play_sfx"):
				audio.play_sfx("hold_complete")
			activated.emit()
			queue_redraw()
			return
	elif _ratio > 0.0:
		_ratio = maxf(0.0, _ratio - delta / RELEASE_SECONDS)

	if not is_equal_approx(before, _ratio):
		hold_progress.emit(_ratio)
		queue_redraw()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			# Lòng bàn tay úp lên nút (2 ngón cùng trên nút): bỏ lượt giữ,
			# chống bé thoát nhầm. Ngón thứ 2 ở NGOÀI nút (trên đàn) không
			# bao giờ tới được gui_input này nên phụ huynh vẫn mở map được
			# trong lúc bé đàn — khác HoldButton cũ đếm toàn màn hình.
			if _finger != -1:
				_finger = -1
				_holding = false
				_held = 0.0
				_animate_release()
				accept_event()
				return
			_finger = event.index
			_holding = true
			_held = 0.0
			_animate_press()
			accept_event()
		else:
			if event.index == _finger:
				_finger = -1
				# Nhả sớm: vòng chạy ngược về 0, không mở map.
				_holding = false
				_held = 0.0
				_animate_release()
			accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _mouse_holding:
				accept_event()
				return
			_mouse_holding = true
			_holding = true
			_held = 0.0
			_animate_press()
			accept_event()
		else:
			_mouse_holding = false
			_holding = false
			_held = 0.0
			_animate_release()
			accept_event()
	elif event is InputEventScreenDrag:
		# Ngón trượt ra khỏi nút thì bỏ lượt giữ — không còn là "giữ nút này" nữa.
		if event.index == _finger and not _contains(event.position):
			_finger = -1
			_holding = false
			_held = 0.0
			_animate_release()
			accept_event()
	elif event is InputEventMouseMotion:
		if _mouse_holding and not _contains(event.position):
			_mouse_holding = false
			_holding = false
			_held = 0.0
			_animate_release()
			accept_event()


func _contains(viewport_position: Vector2) -> bool:
	var local := get_global_transform().affine_inverse() * viewport_position
	return Rect2(Vector2.ZERO, size).has_point(local)


## Bỏ lượt giữ dở (gọi khi bản đồ đóng — lúc HUD bị pause nên không nhận được
## sự kiện nhả ngón, giống HoldButton.cancel()).
func cancel() -> void:
	_holding = false
	_held = 0.0
	_finger = -1
	_mouse_holding = false
	if _ratio > 0.0:
		_ratio = 0.0
		queue_redraw()


func progress() -> float:
	return _ratio


func is_holding() -> bool:
	return _holding


func _draw() -> void:
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.5 - RING_WIDTH
	# Affordance idle: vòng xám mờ luôn hiện để phụ huynh biết "phải giữ".
	# Khi đang giữ thì vòng vàng đè lên.
	if _ratio <= 0.0:
		draw_arc(c, r, 0.0, TAU, 48, Color(1, 1, 1, 0.25), RING_WIDTH, true)
		return
	draw_arc(c, r, 0.0, TAU, 48, Color(1, 1, 1, 0.22), RING_WIDTH, true)
	draw_arc(c, r, -PI * 0.5, -PI * 0.5 + TAU * _ratio, 48, Color("#F2C64B"), RING_WIDTH + 1.5, true)
	draw_arc(c, r, -PI * 0.5, -PI * 0.5 + TAU * _ratio, 48, Color.WHITE, 2.0, true)


func _animate_press() -> void:
	var tw := create_tween().bind_node(self)
	tw.tween_property(_tex_rect, "scale", Vector2(0.92, 0.92), 0.08) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _animate_release() -> void:
	var tw := create_tween().bind_node(self)
	tw.tween_property(_tex_rect, "scale", Vector2.ONE, 0.18) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
