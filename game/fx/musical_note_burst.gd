class_name MusicalNoteBurst
extends "res://game/fx/starlight_burst.gd"
## Bụi sao CỘNG THÊM nốt nhạc bay lên — chỉ Màn 01 Bìa Sách dùng.
##
## Tách khỏi StarlightBurst thay vì nhồi vào đó: năm màn còn lại không bắn nốt
## nhạc, không có lý do bắt chúng mang theo đoạn vẽ nốt móc đơn này.

const NOTE_COLORS: Array[Color] = [
	Color(1.0, 0.88, 0.38, 0.95),  # Vàng hổ phách
	Color(0.42, 0.96, 0.86, 0.95), # Xanh ngọc
	Color(1.0, 0.68, 0.88, 0.95),  # Hồng cổ tích
	Color(1.0, 0.98, 0.68, 0.95),  # Vàng ấm
]

var _musical_notes: Array[Dictionary] = []


func emit_musical_notes(origin: Vector2, count: int = 3) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in count:
		_musical_notes.append({
			"pos": origin + Vector2(rng.randf_range(-18, 18), rng.randf_range(-12, 12)),
			"vel": Vector2(rng.randf_range(-35.0, 35.0), rng.randf_range(-80.0, -140.0)),
			"rot": rng.randf_range(-0.35, 0.35),
			"rot_spd": rng.randf_range(-1.2, 1.2),
			"scale": rng.randf_range(0.85, 1.25),
			"color": NOTE_COLORS[i % NOTE_COLORS.size()],
			"alpha": 1.0,
			"decay": rng.randf_range(0.8, 1.3),
			"phase": rng.randf_range(0.0, TAU),
		})


func _process(delta: float) -> void:
	# Gọi cả hai TRƯỚC khi hợp `or`: toán tử `or` của GDScript nhảy tắt, viết
	# `_step_particles(d) or _step_notes(d)` sẽ bỏ qua đàn nốt nhạc khi đàn hạt
	# đang chạy — nốt nhạc đứng hình.
	var moved_particles := _step_particles(delta)
	var moved_notes := _step_notes(delta)
	if moved_particles or moved_notes:
		queue_redraw()


func _step_notes(delta: float) -> bool:
	if _musical_notes.is_empty():
		return false
	var i := _musical_notes.size() - 1
	while i >= 0:
		var n: Dictionary = _musical_notes[i]
		n["pos"] += n["vel"] * delta
		n["pos"].x += sin(n["phase"] + n["alpha"] * 5.0) * 0.8
		n["vel"].y *= 0.96
		n["rot"] += n["rot_spd"] * delta
		n["alpha"] -= n["decay"] * delta
		if n["alpha"] <= 0.0:
			_musical_notes.remove_at(i)
		i -= 1
	return true


func _draw() -> void:
	super()
	for n in _musical_notes:
		var col: Color = n["color"]
		col.a *= n["alpha"]
		_draw_musical_note(n["pos"], col, n["scale"], n["rot"])


func _draw_musical_note(p: Vector2, col: Color, sc: float, rot: float) -> void:
	var head_radius := 4.2 * sc
	var stem_h := 13.0 * sc
	draw_set_transform_matrix(Transform2D(rot, p))
	draw_circle(Vector2.ZERO, head_radius * 1.5, Color(col.r, col.g, col.b, col.a * 0.3))
	draw_circle(Vector2.ZERO, head_radius, col)
	var stem_x := head_radius * 0.72
	draw_line(Vector2(stem_x, 0), Vector2(stem_x, -stem_h), col, 1.8 * sc)
	draw_arc(Vector2(stem_x + 2.8 * sc, -stem_h + 3.2 * sc), 3.2 * sc, 0.0, PI * 0.7, 6, col, 1.8 * sc)
	draw_set_transform_matrix(Transform2D.IDENTITY)
