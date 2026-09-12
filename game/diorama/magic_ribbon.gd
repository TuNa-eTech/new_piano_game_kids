class_name MagicRibbon
extends Control
## Dải ruy băng nhạc sáng ma thuật nối từ phím đàn bay lên cuốn sách và cây thần.
## Tái hiện 100% dòng chảy âm nhạc nhiệm màu từ mock-game-play.jpeg:
## - Dải ngũ sắc uốn lượn liên tục (ambient musical staff stream)
## - Khóa Sol (𝄞) dạ quang lớn nổi bật ngay trên bệ đàn
## - Các nốt nhạc dạ quang (♪, ♫, ♬) bồng bềnh trôi theo dòng ánh sáng
## - Hạt sao lấp lánh (fx_sparkle) nhấp nháy dọc dải sáng
## - Luồng năng lượng tương tác (reactive beam) phóng lên cây khi bấm phím

const NOTE_ICONS: Array[String] = ["♪", "♫", "♬", "♩", "♫", "♪", "♬"]
const AMBIENT_COLORS: Array[Color] = [
	Color(1.0, 0.45, 0.75), # Pink/Magenta
	Color(0.28, 0.92, 0.95), # Cyan
	Color(1.0, 0.88, 0.40), # Golden yellow
	Color(0.65, 0.50, 1.0), # Lavender
	Color(0.35, 0.85, 1.0), # Sky blue
]

class ActiveBeam:
	var start_pos: Vector2
	var ctrl_pos: Vector2
	var end_pos: Vector2
	var color: Color
	var progress: float = 0.0 # 0.0 -> 1.0
	var speed: float = 2.4 # hoàn thành trong ~0.4s
	var notes: Array[Dictionary] = []

var _beams: Array[ActiveBeam] = []
var _sparkle_tex: Texture2D
var _time: float = 0.0

# Đường cong dòng chảy âm nhạc ambient (Spline Control Points)
# Nối từ cây đậu thần -> lượn qua bệ đàn piano -> vút lên chú phù thủy
var _ambient_points: Array[Vector2] = [
	Vector2(870.0, 360.0), # Gốc cành đậu thần
	Vector2(810.0, 420.0), # Uốn xuống thân cây
	Vector2(680.0, 455.0), # Vắt qua phía trên phím đàn (phải)
	Vector2(530.0, 465.0), # Vắt qua tâm phím đàn
	Vector2(415.0, 435.0), # Điểm đỗ Khóa Sol
	Vector2(345.0, 390.0), # Uốn lên về phía trang sách trái
	Vector2(310.0, 320.0), # Vút tới đôi tay chú phù thủy
]

var _guide_from: Vector2
var _guide_to: Vector2
var _guide_color: Color
var _guide_active: bool = false
var _guide_time: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists("res://assets/art/fx_sparkle.png"):
		_sparkle_tex = load("res://assets/art/fx_sparkle.png")
	set_process(true)


func emit_ribbon(from_pos: Vector2, to_pos: Vector2, color: Color) -> void:
	var beam := ActiveBeam.new()
	beam.start_pos = from_pos
	var mid := (from_pos + to_pos) * 0.5
	var normal := Vector2(-(to_pos.y - from_pos.y), to_pos.x - from_pos.x).normalized()
	beam.ctrl_pos = mid + normal * 120.0
	beam.end_pos = to_pos
	beam.color = color
	beam.progress = 0.0

	for i in 4:
		beam.notes.append({
			"t_offset": float(i) * 0.18,
			"char": NOTE_ICONS[i % NOTE_ICONS.size()],
			"rot": randf_range(-0.3, 0.3)
		})

	_beams.append(beam)
	queue_redraw()


func set_guiding_stream(from_leaf_pos: Vector2, to_key_pos: Vector2, color: Color) -> void:
	_guide_from = from_leaf_pos
	_guide_to = to_key_pos
	_guide_color = color
	_guide_active = true
	queue_redraw()


func clear_guiding_stream() -> void:
	_guide_active = false
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	if _guide_active:
		_guide_time += delta

	var i := _beams.size() - 1
	while i >= 0:
		var beam := _beams[i]
		beam.progress += delta * beam.speed
		if beam.progress >= 1.35:
			_beams.remove_at(i)
		i -= 1

	queue_redraw()


func _draw() -> void:
	# 1. Vẽ dải ánh sáng âm nhạc thường trực (Ambient Musical Ribbon)
	_draw_ambient_stream()

	# 2. Vẽ luồng hướng dẫn gợi ý nốt (Guiding Stream) nếu đang bật
	if _guide_active:
		_draw_guiding_stream()

	# 3. Vẽ các tia xung năng lượng khi bé gõ phím (Active Interactive Beams)
	for beam in _beams:
		_draw_single_beam(beam)


## Đánh giá điểm trên chuỗi spline Catmull-Rom / B-Spline
func _sample_spline(u: float) -> Vector2:
	var n := _ambient_points.size()
	if n == 0:
		return Vector2.ZERO
	if n == 1:
		return _ambient_points[0]
	var total_t := u * float(n - 1)
	var seg := clampi(int(total_t), 0, n - 2)
	var t := total_t - float(seg)

	var p0: Vector2 = _ambient_points[maxi(0, seg - 1)]
	var p1: Vector2 = _ambient_points[seg]
	var p2: Vector2 = _ambient_points[seg + 1]
	var p3: Vector2 = _ambient_points[mini(n - 1, seg + 2)]

	# Catmull-Rom interpolation
	var t2 := t * t
	var t3 := t2 * t
	return 0.5 * (
		(2.0 * p1) +
		(-p0 + p2) * t +
		(2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
		(-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
	)


func _draw_ambient_stream() -> void:
	var segments := 54
	var offsets := [-6.5, -2.0, 2.0, 6.5] # 4 đường khuông nhạc phát sáng
	var line_colors := [
		Color(0.35, 0.95, 1.0),  # Cyan
		Color(1.0, 0.55, 0.85),  # Pink
		Color(1.0, 0.90, 0.45),  # Golden
		Color(0.50, 0.80, 1.0)   # Sky Blue
	]

	# 1. Vẽ 4 sợi khuông nhạc phát sáng uốn lượn
	for line_idx in offsets.size():
		var base_off: float = offsets[line_idx]
		var col: Color = line_colors[line_idx]
		var points := PackedVector2Array()
		var colors_glow := PackedColorArray()
		var colors_core := PackedColorArray()

		for s in range(segments + 1):
			var u := float(s) / float(segments)
			var pt := _sample_spline(u)

			# Tính vector pháp tuyến để dịch theo độ rộng khuông nhạc + sóng sin động
			var next_u := clampf(u + 0.02, 0.0, 1.0)
			var tangent := (_sample_spline(next_u) - pt).normalized()
			var normal := Vector2(-tangent.y, tangent.x)

			var wave := sin(u * 12.0 - _time * 2.8 + float(line_idx) * 0.8) * 3.5
			var final_pos := pt + normal * (base_off + wave)
			points.append(final_pos)

			var alpha := sin(u * PI) * 0.75
			colors_glow.append(Color(col.r, col.g, col.b, alpha * 0.35))
			colors_core.append(Color(1.0, 1.0, 1.0, alpha * 0.85))

		if points.size() >= 2:
			# Glow halo ngoài
			draw_polyline_colors(points, colors_glow, 7.0, true)
			# Core sáng trắng bên trong
			draw_polyline_colors(points, colors_core, 2.2, true)

	# 2. Khóa Sol (𝄞) dạ quang lớn ngay trên bệ đàn tại điểm nhấn (mock-game-play.jpeg)
	var clef_base_pos := _sample_spline(0.66) + Vector2(0.0, sin(_time * 2.2) * 5.0)
	var font := ThemeDB.fallback_font
	var clef_color := Color(1.0, 0.50, 0.90)

	# Hào quang tỏa sáng của Khóa Sol
	draw_circle(clef_base_pos + Vector2(0, -6), 28.0, Color(clef_color.r, clef_color.g, clef_color.b, 0.22))
	draw_circle(clef_base_pos + Vector2(0, -6), 16.0, Color(1.0, 1.0, 1.0, 0.35))
	# Đổ bóng mềm
	draw_string(font, clef_base_pos + Vector2(-15, 12), "𝄞", HORIZONTAL_ALIGNMENT_CENTER, -1, 46, Color(0.12, 0.05, 0.15, 0.6))
	# Ký tự chính Khóa Sol màu dạ quang
	draw_string(font, clef_base_pos + Vector2(-16, 10), "𝄞", HORIZONTAL_ALIGNMENT_CENTER, -1, 46, Color.WHITE.lerp(clef_color, 0.35))

	# 3. Các nốt nhạc dạ quang lơ lửng dọc dải ruy băng
	var note_count := 8
	for i in note_count:
		var u_base := float(i) / float(note_count)
		var u := fposmod(u_base + _time * 0.04, 1.0)
		var pt := _sample_spline(u)
		var bob := sin(_time * 3.0 + float(i) * 1.5) * 6.0
		var note_pos := pt + Vector2(0.0, bob)
		var note_color: Color = AMBIENT_COLORS[i % AMBIENT_COLORS.size()]
		var note_sym: String = NOTE_ICONS[i % NOTE_ICONS.size()]

		var note_alpha := sin(u * PI) * 0.95
		var note_draw_col := Color(note_color.r, note_color.g, note_color.b, note_alpha)

		# Quầng hào quang nốt nhạc
		draw_circle(note_pos, 12.0, Color(note_color.r, note_color.g, note_color.b, note_alpha * 0.28))
		# Ký tự nốt nhạc sắc nét
		draw_string(font, note_pos + Vector2(-8, 8), note_sym, HORIZONTAL_ALIGNMENT_CENTER, -1, 22, note_draw_col)

		# Hạt sao lấp lánh (Sparkles)
		if _sparkle_tex != null and (i % 2 == 0):
			var sp_pulse := 0.6 + 0.4 * sin(_time * 4.0 + float(i) * 2.0)
			var sp_size := 22.0 * sp_pulse
			var sp_pos := note_pos + Vector2(14.0, -10.0)
			var sp_rect := Rect2(sp_pos.x - sp_size * 0.5, sp_pos.y - sp_size * 0.5, sp_size, sp_size)
			draw_texture_rect(_sparkle_tex, sp_rect, false, Color(1.0, 1.0, 1.0, note_alpha * sp_pulse))


func _draw_guiding_stream() -> void:
	var segments := 28
	var points := PackedVector2Array()
	var colors := PackedColorArray()

	var mid := (_guide_from + _guide_to) * 0.5
	var normal := Vector2(-(_guide_to.y - _guide_from.y), _guide_to.x - _guide_from.x).normalized()
	var ctrl := mid + normal * 80.0

	var pulse := 0.65 + 0.35 * sin(_guide_time * 3.2)

	for s in range(segments + 1):
		var t := float(s) / float(segments)
		var p := (1.0 - t) * (1.0 - t) * _guide_from + 2.0 * (1.0 - t) * t * ctrl + t * t * _guide_to
		points.append(p)
		var a := sin(t * PI) * (0.35 + 0.25 * pulse)
		colors.append(Color(_guide_color.r, _guide_color.g, _guide_color.b, a))

	if points.size() >= 2:
		draw_polyline_colors(points, colors, 14.0, true)
		draw_polyline_colors(points, colors, 4.0, true)

	var font := ThemeDB.fallback_font
	for i in 5:
		var raw_t := fposmod((_guide_time * 0.45) + float(i) * 0.20, 1.0)
		var note_pos := (1.0 - raw_t) * (1.0 - raw_t) * _guide_from + 2.0 * (1.0 - raw_t) * raw_t * ctrl + raw_t * raw_t * _guide_to
		var note_a := sin(raw_t * PI) * 0.88
		var sym: String = NOTE_ICONS[i % NOTE_ICONS.size()]
		draw_string(font, note_pos + Vector2(-8, 8), sym, HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color(1.0, 1.0, 1.0, note_a))


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
		var p := (1.0 - t) * (1.0 - t) * beam.start_pos + 2.0 * (1.0 - t) * t * beam.ctrl_pos + t * t * beam.end_pos
		points.append(p)

		var alpha := sin(sub_t * PI) * 0.90
		colors.append(Color(beam.color.r, beam.color.g, beam.color.b, alpha))

	if points.size() >= 2:
		draw_polyline_colors(points, colors, 12.0, true)
		draw_polyline_colors(points, colors, 3.8, true)

	var font := ThemeDB.fallback_font
	for n in beam.notes:
		var nt: float = beam.progress - n["t_offset"]
		if nt >= 0.0 and nt <= 1.0:
			var np := (1.0 - nt) * (1.0 - nt) * beam.start_pos + 2.0 * (1.0 - nt) * nt * beam.ctrl_pos + nt * nt * beam.end_pos
			var note_color := Color.WHITE.lerp(beam.color, 0.3)
			note_color.a = sin(nt * PI)

			if _sparkle_tex != null:
				var s_rect := Rect2(np.x - 14, np.y - 14, 28, 28)
				draw_texture_rect(_sparkle_tex, s_rect, false, note_color)

			draw_string(font, np + Vector2(-8, 8), n["char"], HORIZONTAL_ALIGNMENT_CENTER, -1, 24, note_color)
