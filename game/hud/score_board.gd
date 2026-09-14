class_name ScoreBoard
extends Control
## DEPRECATED (Fix UI 7 nhóm): vi phạm Zero-Text + Quyết định 04 bỏ SCORE/COMBO.
## Đã gỡ khỏi main.tscn. Giữ file để không vỡ lịch sử, KHÔNG dùng cho màn mới.
## Dùng StarJar (mực nước sao) thay cho mọi hiển thị tiến độ của bé.

@onready var _bg: TextureRect = $Background

var _score: int = 1250
var _combo: int = 15


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS

	if _bg != null:
		_bg.stretch_mode = TextureRect.STRETCH_SCALE
		if ResourceLoader.exists("res://assets/art/ui_board_score_combo.png"):
			_bg.texture = load("res://assets/art/ui_board_score_combo.png")

	var gs = get_node_or_null("/root/GameState")
	if gs != null and gs.has_signal("stars_changed"):
		gs.stars_changed.connect(_on_stars_changed)


func _on_stars_changed(new_stars: int) -> void:
	_score = 1200 + new_stars * 10
	_combo += 1
	_pop_animation()


func _pop_animation() -> void:
	var tw := create_tween().bind_node(self)
	tw.tween_property(self, "scale", Vector2(1.08, 1.08), 0.08) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.16) \
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
