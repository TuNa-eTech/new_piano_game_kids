class_name CottageMenuButton
extends Control
## Nút Menu hình Ngôi Nhà Nấm Cổ Tích góc phải trên (docs/mock-game-play.jpeg).
##
## Mở bản đồ chương ngay khi chạm (single tap) — không còn giữ 2 giây.

signal activated

## Apple Kids Category: touch-target tối thiểu 88x88 pt.
const BTN_SIZE := Vector2(96.0, 96.0)

var _tex_rect: TextureRect
## Ngón đang giữ nút này (event.index), để nhận đúng sự kiện nhả của chính ngón đó.
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


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_finger = event.index
			_animate_press()
			accept_event()
		elif event.index == _finger:
			_finger = -1
			_animate_release()
			_activate()
			accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_mouse_holding = true
			_animate_press()
			accept_event()
		elif _mouse_holding:
			_mouse_holding = false
			_animate_release()
			_activate()
			accept_event()
	elif event is InputEventScreenDrag:
		# Ngón trượt ra khỏi nút thì bỏ, không tính là chạm nút nữa.
		if event.index == _finger and not _contains(event.position):
			_finger = -1
			_animate_release()
			accept_event()
	elif event is InputEventMouseMotion:
		if _mouse_holding and not _contains(event.position):
			_mouse_holding = false
			_animate_release()
			accept_event()


func _activate() -> void:
	AudioDirector.play_sfx("hold_complete")
	activated.emit()


func _contains(viewport_position: Vector2) -> bool:
	var local := get_global_transform().affine_inverse() * viewport_position
	return Rect2(Vector2.ZERO, size).has_point(local)


## Bỏ trạng thái chạm dở (gọi khi bản đồ đóng — lúc HUD bị pause nên không nhận
## được sự kiện nhả ngón).
func cancel() -> void:
	_finger = -1
	_mouse_holding = false


func _animate_press() -> void:
	var tw := create_tween().bind_node(self)
	tw.tween_property(_tex_rect, "scale", Vector2(0.92, 0.92), 0.08) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _animate_release() -> void:
	var tw := create_tween().bind_node(self)
	tw.tween_property(_tex_rect, "scale", Vector2.ONE, 0.18) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
