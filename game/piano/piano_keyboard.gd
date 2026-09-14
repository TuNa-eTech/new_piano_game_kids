class_name PianoKeyboard
extends Control
## BỀ MẶT TƯƠNG TÁC DUY NHẤT của game (docs/gameplay-design.html · Quyết định 01).
##
## Khung truyện phía trên chỉ hiển thị, không nhận input. Mọi Control khác phải
## đặt mouse_filter = IGNORE, nếu không chúng nuốt sự kiện trước khi tới đây.
##
## Hướng B: Bàn đàn tràn 100% toàn chiều rộng màn hình (1280px).
## Thanh nẹp gỗ viền thẳng (Straight Wood Rail) 2.5D trực giao 100% với phím.
## 7 phím trắng siêu rộng (~181px/phím) cho trẻ thoải mái chạm.
## 5 phím đen (nốt phụ / accidentals) tương tác độc lập (âm thanh & animation).

signal note_played(index: int)
signal note_released(index: int)
signal black_note_played(slot_index: int)
signal black_note_released(slot_index: int)

const KEY_GAP := 2.0
## Vị trí 5 phím đen: nằm giữa các cặp phím trắng (C-D: 0, D-E: 1, F-G: 3, G-A: 4, A-B: 5)
const BLACK_KEY_SLOTS := [0, 1, 3, 4, 5]

var _key_rects: Array[Rect2] = []
var _keys: Array[AnimalKey] = []
## ngón (event.index) -> chỉ số phím trắng đang giữ
var _finger_to_key: Dictionary = {}

## Hệ thống phím đen tương tác (Accidentals)
var _black_key_rects: Dictionary = {}
var _black_key_pressed: Dictionary = {}
var _black_key_depress: Dictionary = {}
var _black_key_tweens: Dictionary = {}
## ngón (event.index) -> slot phím đen đang giữ
var _black_finger_to_slot: Dictionary = {}

var _black_layer: Control
var _black_key_tex: Texture2D

# Thanh nẹp gỗ viền thẳng 2.5D tràn 100% màn hình
var _top_rail: TextureRect
var _bottom_lip: TextureRect
var _keybed_felt: ColorRect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 0. Lớp lót nỉ tối màu (Keybed Felt) che kín nền giữa các khe phím
	_keybed_felt = ColorRect.new()
	_keybed_felt.name = "KeybedFelt"
	_keybed_felt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_keybed_felt.color = Color("#241913")
	add_child(_keybed_felt)

	_build_keys()

	_black_layer = get_node_or_null("BlackKeys")
	if _black_layer == null:
		_black_layer = Control.new()
		_black_layer.name = "BlackKeys"
		add_child(_black_layer)
	_black_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not _black_layer.draw.is_connected(_draw_black_keys):
		_black_layer.draw.connect(_draw_black_keys)

	# 1. Thanh nẹp gỗ trên (Top Rail) - Gờ gỗ chạm hoa văn cổ tích nẹp thẳng toàn màn hình
	_top_rail = TextureRect.new()
	_top_rail.name = "TopWoodRail"
	_top_rail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top_rail.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_top_rail.stretch_mode = TextureRect.STRETCH_SCALE
	if ResourceLoader.exists("res://assets/art/piano_top_rail_gen_25d.png"):
		_top_rail.texture = load("res://assets/art/piano_top_rail_gen_25d.png")
	add_child(_top_rail)

	# 2. Thanh nẹp gỗ đáy (Bottom Lip Rail) - Bệ đỡ phím thẳng chắc chắn
	_bottom_lip = TextureRect.new()
	_bottom_lip.name = "BottomLipRail"
	_bottom_lip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bottom_lip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bottom_lip.stretch_mode = TextureRect.STRETCH_SCALE
	if ResourceLoader.exists("res://assets/art/piano_bottom_rail_gen_25d.png"):
		_bottom_lip.texture = load("res://assets/art/piano_bottom_rail_gen_25d.png")
	add_child(_bottom_lip)

	resized.connect(_layout_keys)
	_layout_keys()

	# Thứ tự layer hiển thị:
	# 0: Bệ nỉ tối màu (_keybed_felt)
	# 1..7: Phím trắng (_keys)
	# 8: Phím đen (_black_layer)
	# 9: Thanh nẹp trên (_top_rail) che gờ trên của các phím
	# 10: Thanh nẹp đáy (_bottom_lip) che gờ dưới của các phím
	move_child(_keybed_felt, 0)
	move_child(_black_layer, get_child_count() - 1)
	move_child(_top_rail, get_child_count() - 1)
	move_child(_bottom_lip, get_child_count() - 1)

	if is_instance_valid(GameState):
		GameState.free_play_changed.connect(_on_free_play_changed)
		_on_free_play_changed(GameState.free_play)


func _on_free_play_changed(enabled: bool) -> void:
	for key in _keys:
		if is_instance_valid(key):
			key.set_rainbow_mode(enabled)


func _build_keys() -> void:
	var scene := preload("res://game/piano/animal_key.tscn")
	for i in Notes.count():
		var key: AnimalKey = scene.instantiate()
		add_child(key)
		key.setup(i)
		_keys.append(key)
	_key_rects.resize(Notes.count())


func _layout_keys() -> void:
	var n := Notes.count()
	if n == 0 or size.x <= 0.0 or size.y <= 0.0:
		return

	if _keybed_felt != null:
		_keybed_felt.position = Vector2.ZERO
		_keybed_felt.size = size

	# Thanh nẹp trên: cao 46px với hoa văn chạm khắc vàng
	var top_rail_h := 46.0
	if _top_rail != null:
		_top_rail.position = Vector2.ZERO
		_top_rail.size = Vector2(size.x, top_rail_h)

	# Thanh nẹp dưới: cao 20px bệ đỡ chân phím
	var bot_rail_h := 20.0
	if _bottom_lip != null:
		_bottom_lip.position = Vector2(0.0, size.y - bot_rail_h)
		_bottom_lip.size = Vector2(size.x, bot_rail_h)

	# P1: margin_t 40→48 để hở khỏi rail 46px +2px; phím trắng không còn
	# trượt dưới gờ gỗ, hết cảm giác "bấm mà không thấy".
	var margin_t := 48.0
	var margin_b := 16.0
	var kb_y := margin_t
	var kb_h := maxf(50.0, size.y - (margin_t + margin_b))

	# 7 phím trắng chia đều toàn bộ chiều rộng size.x (1280px)
	var gap := KEY_GAP
	var total_gap := gap * float(n - 1)
	var key_w := (size.x - total_gap) / float(n)
	var key_h := kb_h

	for i in n:
		var rx := float(i) * (key_w + gap)
		var r := Rect2(Vector2(rx, kb_y), Vector2(key_w, key_h))
		_key_rects[i] = r
		_keys[i].position = r.position
		_keys[i].size = r.size
		_keys[i].pivot_offset = r.size * 0.5

	# Tính toán vị trí 5 phím đen (Accidentals)
	# P1: rộng 40%→48% (≈87px, đạt Apple Kids 88pt), cao 42%→50% để
	# bé chạm trúng; dừng phía trên đầu thú, chuẩn concept.
	var bw := key_w * 0.48
	var bh := key_h * 0.50
	for slot in BLACK_KEY_SLOTS:
		if slot + 1 < _key_rects.size():
			var boundary: float = (_key_rects[slot].end.x + _key_rects[slot + 1].position.x) * 0.5
			_black_key_rects[slot] = Rect2(Vector2(boundary - bw * 0.5, kb_y), Vector2(bw, bh))
			if not _black_key_depress.has(slot):
				_black_key_depress[slot] = 0.0
				_black_key_pressed[slot] = false

	if _black_layer != null:
		_black_layer.position = Vector2.ZERO
		_black_layer.size = size
		_black_layer.queue_redraw()


# Cấu trúc StyleBoxFlat vẽ phím đen mận sô-cô-la 2.5D chuẩn Concept (Plum Chocolate Vector Keys)
var _sb_shadow: StyleBoxFlat
var _sb_front_bevel: StyleBoxFlat
var _sb_top_normal: StyleBoxFlat
var _sb_top_pressed: StyleBoxFlat


func _init_black_key_styles() -> void:
	# 1. Bóng đổ mềm mại ánh mận tím nhẹ (Warm Plum Shadow)
	_sb_shadow = StyleBoxFlat.new()
	_sb_shadow.bg_color = Color(0.18, 0.10, 0.16, 0.28)
	_sb_shadow.corner_radius_top_left = 6
	_sb_shadow.corner_radius_top_right = 6
	_sb_shadow.corner_radius_bottom_left = 8
	_sb_shadow.corner_radius_bottom_right = 8

	# 2. Mặt trước vát cạnh 3D sẫm màu (Dark Plum-Chocolate Front Bevel)
	_sb_front_bevel = StyleBoxFlat.new()
	_sb_front_bevel.bg_color = Color("#2C1721")
	_sb_front_bevel.corner_radius_top_left = 6
	_sb_front_bevel.corner_radius_top_right = 6
	_sb_front_bevel.corner_radius_bottom_left = 7
	_sb_front_bevel.corner_radius_bottom_right = 7
	_sb_front_bevel.border_width_bottom = 2
	_sb_front_bevel.border_color = Color("#1C0E15")

	# 3. Mặt trên phím màu mận sô-cô-la mịn như nhung (Velvety Plum Top Face)
	_sb_top_normal = StyleBoxFlat.new()
	_sb_top_normal.bg_color = Color("#543845")
	_sb_top_normal.corner_radius_top_left = 6
	_sb_top_normal.corner_radius_top_right = 6
	_sb_top_normal.corner_radius_bottom_left = 4
	_sb_top_normal.corner_radius_bottom_right = 4
	_sb_top_normal.border_width_top = 1
	_sb_top_normal.border_width_left = 1
	_sb_top_normal.border_color = Color("#825F73", 0.70)

	# 4. Mặt trên khi ấn: ửng hồng tím dạ quang cổ tích (Pressed Magical Glow)
	_sb_top_pressed = StyleBoxFlat.new()
	_sb_top_pressed.bg_color = Color("#6B475B")
	_sb_top_pressed.corner_radius_top_left = 6
	_sb_top_pressed.corner_radius_top_right = 6
	_sb_top_pressed.corner_radius_bottom_left = 4
	_sb_top_pressed.corner_radius_bottom_right = 4
	_sb_top_pressed.border_width_top = 2
	_sb_top_pressed.border_width_left = 2
	_sb_top_pressed.border_color = Color("#F5D2E8", 0.90)
	_sb_top_pressed.shadow_color = Color("#E598CA", 0.40)
	_sb_top_pressed.shadow_size = 6


func _draw_black_keys() -> void:
	if _black_key_rects.is_empty():
		return
	if _sb_front_bevel == null:
		_init_black_key_styles()

	var ci := _black_layer.get_canvas_item()

	for slot in BLACK_KEY_SLOTS:
		if not _black_key_rects.has(slot):
			continue
		var base_rect: Rect2 = _black_key_rects[slot]
		var depress: float = _black_key_depress.get(slot, 0.0)
		var is_pressed: bool = _black_key_pressed.get(slot, false)

		# 1. Đổ bóng 3D mềm mại lên phím trắng (khoảng cách bóng thu gần khi phím lún)
		var shadow_offset_y := lerpf(5.0, 2.0, depress / 6.0)
		var shadow_rect := Rect2(
			Vector2(base_rect.position.x - 1.0, base_rect.position.y + shadow_offset_y),
			Vector2(base_rect.size.x + 2.0, base_rect.size.y)
		)
		_sb_shadow.draw(ci, shadow_rect)

		# 2. Toạ độ phím dịch chuyển khi lún cơ học
		var key_rect := Rect2(
			Vector2(base_rect.position.x, base_rect.position.y + depress),
			base_rect.size
		)

		# 3. Quầng sáng ma thuật tỏa nhẹ khi chạm (giống phím đang phát sáng trong mock)
		if is_pressed:
			_black_layer.draw_circle(key_rect.get_center(), key_rect.size.x * 0.75, Color("#F0A8D8", 0.28))

		# 4. Mặt trước vát cạnh 3D (Front Bevel)
		_sb_front_bevel.draw(ci, key_rect)

		# 5. Mặt trên của phím (Top Face - dừng lại 11px trước đáy để lộ mặt vát trước, cách đều 2 mép 2px)
		var chamfer_h := 11.0
		var top_rect := Rect2(
			Vector2(key_rect.position.x + 2.0, key_rect.position.y),
			Vector2(key_rect.size.x - 4.0, key_rect.size.y - chamfer_h)
		)
		if is_pressed:
			_sb_top_pressed.draw(ci, top_rect)
		else:
			_sb_top_normal.draw(ci, top_rect)

		# 6. Gờ sáng cong nhẹ trên đỉnh và cạnh trái đón ánh nắng thế giới cổ tích
		var shine_color := Color(1.0, 0.94, 0.98, 0.45 if not is_pressed else 0.85)
		_black_layer.draw_line(
			Vector2(top_rect.position.x + 4.0, top_rect.position.y + 1.5),
			Vector2(top_rect.end.x - 4.0, top_rect.position.y + 1.5),
			shine_color, 1.2
		)
		_black_layer.draw_line(
			Vector2(top_rect.position.x + 1.5, top_rect.position.y + 4.0),
			Vector2(top_rect.position.x + 1.5, top_rect.end.y - 4.0),
			Color(1.0, 0.94, 0.98, 0.22 if not is_pressed else 0.55), 1.0
		)

		# 7. Đốm sáng sao 4 cánh ✦ lấp lánh cổ tích (Fairy Sparkle như trong concept gốc)
		var sparkle_pos := Vector2(top_rect.end.x - 10.0, top_rect.position.y + 12.0)
		if slot == 1 or slot == 4:
			sparkle_pos = Vector2(top_rect.position.x + 10.0, top_rect.position.y + 12.0)

		if is_pressed:
			_draw_fairy_star(sparkle_pos, 7.0, 1.8, Color.WHITE)
			# Hào quang điểm nhấn
			_black_layer.draw_circle(sparkle_pos, 4.0, Color(1.0, 0.85, 0.95, 0.40))
		elif slot == 0 or slot == 3 or slot == 5:
			# Idle key chỉ điểm xuyết ánh lấp lánh nhẹ nhàng ở vài phím để tránh rối mắt
			_draw_fairy_star(sparkle_pos, 3.8, 1.0, Color(1.0, 0.95, 0.98, 0.50))


## Vẽ đốm sao 4 cánh hình kim cương lấp lánh cổ tích (Fairy Sparkle Star ✦)
func _draw_fairy_star(center: Vector2, outer_r: float, inner_r: float, color: Color) -> void:
	var pts := PackedVector2Array([
		center + Vector2(0.0, -outer_r),
		center + Vector2(inner_r, -inner_r),
		center + Vector2(outer_r, 0.0),
		center + Vector2(inner_r, inner_r),
		center + Vector2(0.0, outer_r),
		center + Vector2(-inner_r, inner_r),
		center + Vector2(-outer_r, 0.0),
		center + Vector2(-inner_r, -inner_r),
	])
	_black_layer.draw_colored_polygon(pts, color)
	_black_layer.draw_circle(center, inner_r * 0.9, Color(1.0, 1.0, 1.0, minf(1.0, color.a * 1.5)))


## Trả về slot phím đen tại vị trí viewport, hoặc -1 nếu không trúng
func _black_key_at(viewport_position: Vector2) -> int:
	var local := get_global_transform().affine_inverse() * viewport_position
	for slot in BLACK_KEY_SLOTS:
		if _black_key_rects.has(slot) and _black_key_rects[slot].has_point(local):
			return slot
	return -1


## Trả về chỉ số phím trắng tại một điểm trong toạ độ viewport, hoặc -1
func _key_at(viewport_position: Vector2) -> int:
	var local := get_global_transform().affine_inverse() * viewport_position
	for i in _key_rects.size():
		if _key_rects[i].has_point(local):
			return i
	return -1


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		# 1. Ưu tiên kiểm tra phím đen trước vì phím đen nằm đè trên phím trắng
		var slot := _black_key_at(event.position)
		if slot != -1:
			_black_finger_to_slot[event.index] = slot
			_strike_black_key(slot)
			get_viewport().set_input_as_handled()
			return

		# 2. Nếu không chạm phím đen, kiểm tra phím trắng
		var key := _key_at(event.position)
		if key != -1:
			_finger_to_key[event.index] = key
			_strike(key)
			get_viewport().set_input_as_handled()
	else:
		# Nhả chạm
		if _black_finger_to_slot.has(event.index):
			var slot: int = _black_finger_to_slot[event.index]
			_black_finger_to_slot.erase(event.index)
			_release_black_key(slot)
			get_viewport().set_input_as_handled()
		elif _finger_to_key.has(event.index):
			var key: int = _finger_to_key[event.index]
			_finger_to_key.erase(event.index)
			if key >= 0 and key < _keys.size():
				_keys[key].release()
				note_released.emit(key)
			get_viewport().set_input_as_handled()


func _handle_drag(event: InputEventScreenDrag) -> void:
	# Nếu ngón đang giữ phím đen
	if _black_finger_to_slot.has(event.index):
		var prev_slot: int = _black_finger_to_slot[event.index]
		var cur_slot := _black_key_at(event.position)
		if cur_slot == prev_slot:
			return
		_release_black_key(prev_slot)
		_black_finger_to_slot.erase(event.index)
		if cur_slot != -1:
			_black_finger_to_slot[event.index] = cur_slot
			_strike_black_key(cur_slot)
		else:
			var cur_key := _key_at(event.position)
			if cur_key != -1:
				_finger_to_key[event.index] = cur_key
				_strike(cur_key)
		return

	# Nếu ngón đang giữ phím trắng
	if _finger_to_key.has(event.index):
		var prev_key: int = _finger_to_key[event.index]
		var cur_slot := _black_key_at(event.position)
		if cur_slot != -1:
			if prev_key >= 0 and prev_key < _keys.size():
				_keys[prev_key].release()
				note_released.emit(prev_key)
			_finger_to_key.erase(event.index)
			_black_finger_to_slot[event.index] = cur_slot
			_strike_black_key(cur_slot)
			return

		var cur_key := _key_at(event.position)
		if cur_key == -1 or cur_key == prev_key:
			return
		if prev_key >= 0 and prev_key < _keys.size():
			_keys[prev_key].release()
			note_released.emit(prev_key)
		_finger_to_key[event.index] = cur_key
		_strike(cur_key)


func _strike(key: int) -> void:
	# Âm thanh TRƯỚC, hình ảnh sau: độ trễ nghe được, còn một khung hình thì không.
	AudioDirector.play_note(key)
	if key >= 0 and key < _keys.size():
		_keys[key].press()
	GameState.note_was_played(key)
	note_played.emit(key)


## Gõ phím tự động (cho chế độ Auto-Play / Concert)
func play_auto_key(key: int, hold_duration: float = 0.25) -> void:
	if key < 0 or key >= _keys.size():
		return
	_strike(key)
	var tw := create_tween().bind_node(self)
	tw.tween_interval(hold_duration)
	tw.tween_callback(func():
		if key >= 0 and key < _keys.size():
			_keys[key].release()
			note_released.emit(key)
	)


func _strike_black_key(slot: int) -> void:
	AudioDirector.play_black_key(slot)
	_black_key_pressed[slot] = true

	if _black_key_tweens.has(slot) and is_instance_valid(_black_key_tweens[slot]):
		_black_key_tweens[slot].kill()

	# Lún phím đen 6px với đàn hồi nảy êm
	var tw := create_tween().bind_node(self)
	_black_key_tweens[slot] = tw
	tw.tween_method(func(v: float):
		_black_key_depress[slot] = v
		if _black_layer != null:
			_black_layer.queue_redraw()
	, _black_key_depress.get(slot, 0.0), 6.0, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	black_note_played.emit(slot)
	if _black_layer != null:
		_black_layer.queue_redraw()


func _release_black_key(slot: int) -> void:
	_black_key_pressed[slot] = false

	if _black_key_tweens.has(slot) and is_instance_valid(_black_key_tweens[slot]):
		_black_key_tweens[slot].kill()

	var tw := create_tween().bind_node(self)
	_black_key_tweens[slot] = tw
	tw.tween_method(func(v: float):
		_black_key_depress[slot] = v
		if _black_layer != null:
			_black_layer.queue_redraw()
	, _black_key_depress.get(slot, 0.0), 0.0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	black_note_released.emit(slot)
	if _black_layer != null:
		_black_layer.queue_redraw()


## Buông mọi ngón đang giữ (cả phím trắng và phím đen)
func release_all() -> void:
	for finger in _finger_to_key.keys():
		var key: int = _finger_to_key[finger]
		if key >= 0 and key < _keys.size():
			_keys[key].release()
			note_released.emit(key)
	_finger_to_key.clear()

	for finger in _black_finger_to_slot.keys():
		var slot: int = _black_finger_to_slot[finger]
		_release_black_key(slot)
	_black_finger_to_slot.clear()


func fingers_down() -> int:
	return _finger_to_key.size() + _black_finger_to_slot.size()


var _hint_key: int = -1

func set_hint_key(key_index: int) -> void:
	if _hint_key == key_index:
		return
	if _hint_key >= 0 and _hint_key < _keys.size():
		_keys[_hint_key].set_hint_active(false)
	_hint_key = key_index
	if _hint_key >= 0 and _hint_key < _keys.size():
		_keys[_hint_key].set_hint_active(true)


func clear_hint_key() -> void:
	if _hint_key >= 0 and _hint_key < _keys.size():
		_keys[_hint_key].set_hint_active(false)
	_hint_key = -1


## Trả về toạ độ toàn cục tâm của phím trắng
func get_key_global_position(index: int) -> Vector2:
	if index >= 0 and index < _key_rects.size():
		return global_position + _key_rects[index].get_center()
	return global_position


## Trả về toạ độ toàn cục tâm của phím đen
func get_black_key_global_position(slot: int) -> Vector2:
	if _black_key_rects.has(slot):
		return global_position + _black_key_rects[slot].get_center()
	return global_position

