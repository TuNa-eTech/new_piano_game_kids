class_name MagicRibbon
extends Control
## Dải ruy băng nhạc sáng ma thuật nối từ phím đàn bay lên cuốn sách và cây thần.
## Đúng như ảnh mock: luồng ánh sáng uốn lượn với nốt nhạc phát quang (khóa Sol, nốt đơn, nốt đôi).

const NOTE_ICONS := ["♪", "♫", "♬", "𝄞"]

class ActiveBeam:
	var start_pos: Vector2
	var ctrl_pos: Vector2
	var end_pos: Vector2
	var color: Color
	var progress: float = 0.0 # 0.0 -> 1.0
	var speed: float = 2.4 # hoàn thành trong ~0.4s
	var notes: Array[Dictionary] = [] # vị trí các nốt bay dọc dải

var _beams: Array[ActiveBeam] = []
var _sparkle_tex: Texture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/fx_sparkle.png"):
		_sparkle_tex = load("res://assets/art/fx_sparkle.png")


func emit_ribbon(from_pos: Vector2, to_pos: Vector2, color: Color) -> void:
	var beam := ActiveBeam.new()
	beam.start_pos = from_pos
	# Điểm uốn cong Bezier bay lượn qua giữa màn hình
	var mid := (from_pos + to_pos) * 0.5
	var normal := Vector2(-(to_pos.y - from_pos.y), to_pos.x - from_pos.x).normalized()
	beam.ctrl_pos = mid + normal * 120.0
	beam.end_pos = to_pos
	beam.color = color
	beam.progress = 0.0

	# Tạo 4 nốt nhạc phân bố dọc dải
	for i in 4:
		beam.notes.append({
			"t_offset": float(i) * 0.18,
			"char": NOTE_ICONS[i % NOTE_ICONS.size()],
			"rot": randf_range(-0.4, 0.4)
		})

	_beams.append(beam)
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	if _beams.is_empty():
		set_process(false)
		return

	var i := _beams.size() - 1
	while i >= 0:
		var beam := _beams[i]
		beam.progress += delta * beam.speed
		if beam.progress >= 1.35: # để đuôi tan biến hẳn
			_beams.remove_at(i)
		i -= 1

	queue_redraw()


func _draw() -> void:
	for beam in _beams:
		_draw_single_beam(beam)


func _draw_single_beam(beam: ActiveBeam) -> void:
	var segments := 24
	var points := PackedVector2Array()
	var colors := PackedColorArray()

	var head_p := clampf(beam.progress, 0.0, 1.0)
	var tail_p := clampf(beam.progress - 0.45, 0.0, 1.0)

	if head_p <= tail_p:
		return

	for s in range(segments + 1):
		var sub_t := float(s) / float(segments)
		var t := lerpf(tail_p, head_p, sub_t)
		# Quadratic bezier: B(t) = (1-t)^2 P0 + 2(1-t)t P1 + t^2 P2
		var p := (1.0 - t) * (1.0 - t) * beam.start_pos + 2.0 * (1.0 - t) * t * beam.ctrl_pos + t * t * beam.end_pos
		points.append(p)

		var alpha := sin(sub_t * PI) * 0.85
		colors.append(Color(beam.color.r, beam.color.g, beam.color.b, alpha))

	if points.size() >= 2:
		# Vẽ vệt sáng huỳnh quang (Glow core + soft border)
		draw_polyline_colors(points, colors, 10.0, true)
		draw_polyline_colors(points, colors, 3.5, true)

	# Vẽ các nốt nhạc và hạt sao bay dọc dải
	var font := ThemeDB.fallback_font
	for n in beam.notes:
		var nt: float = beam.progress - n["t_offset"]
		if nt >= 0.0 and nt <= 1.0:
			var np := (1.0 - nt) * (1.0 - nt) * beam.start_pos + 2.0 * (1.0 - nt) * nt * beam.ctrl_pos + nt * nt * beam.end_pos
			var note_color := Color.WHITE.lerp(beam.color, 0.3)
			note_color.a = sin(nt * PI)

			# Hạt sao lấp lánh
			if _sparkle_tex != null:
				var s_rect := Rect2(np.x - 14, np.y - 14, 28, 28)
				draw_texture_rect(_sparkle_tex, s_rect, false, note_color)

			# Ký tự nốt nhạc
			draw_string(font, np + Vector2(-8, 8), n["char"], HORIZONTAL_ALIGNMENT_CENTER, -1, 24, note_color)
