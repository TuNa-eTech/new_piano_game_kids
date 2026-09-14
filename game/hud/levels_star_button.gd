class_name LevelsStarButton
extends Control
## Nút Levels hình Ngôi Sao 3 Màu góc phải trên (docs/mock-game-play.jpeg).

signal activated

## Apple Kids Category: touch-target tối thiểu 88x88 pt.
const BTN_SIZE := Vector2(96.0, 96.0)

var _tex_rect: TextureRect
var _is_pressed: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS

	_tex_rect = TextureRect.new()
	_tex_rect.name = "Texture"
	_tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
	_tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if ResourceLoader.exists("res://assets/art/ui_btn_levels_star.png"):
		_tex_rect.texture = load("res://assets/art/ui_btn_levels_star.png")
	add_child(_tex_rect)

	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		_is_pressed = true
		_animate_press()
		accept_event()
	elif (event is InputEventScreenTouch and not event.pressed) or (event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		if _is_pressed:
			_is_pressed = false
			_animate_release()
			activated.emit()
			var audio = get_node_or_null("/root/AudioDirector")
			if audio != null and audio.has_method("play_ting"):
				audio.play_ting()
		accept_event()


func _animate_press() -> void:
	var tw := create_tween().bind_node(self)
	tw.tween_property(_tex_rect, "scale", Vector2(0.92, 0.92), 0.08) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _animate_release() -> void:
	var tw := create_tween().bind_node(self)
	tw.tween_property(_tex_rect, "scale", Vector2.ONE, 0.18) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
