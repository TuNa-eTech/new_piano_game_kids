class_name StarlightBurst
extends Control
## Lớp bụi sao — chùm hạt tròn bung ra từ một điểm rồi tắt dần.
##
## Gộp từ SÁU lớp chép tay gần như y hệt nhau (Giai Đoạn 2a, xem
## docs/architecture-refactor.md): StarlightBurstLayer ở main_menu và chapter_map,
## LevelStarlightBurstLayer, GateStarlightBurstLayer, CornerBurstLayer,
## GoodnightZzzBurstLayer. Cả sáu chạy ĐÚNG một thuật toán; khác nhau chỉ ở mấy
## con số — hệ số hãm 0.91/0.92/0.94, quầng sáng 1.8/1.9/2.0, dải tốc độ...
## Giờ những con số đó là thuộc tính có tên, đặt ngay tại nơi dùng.
##
## Mặc định ở đây là bộ số của Bản Đồ Chương và Chọn Màn Chơi — hai màn dùng
## nguyên trạng, không cần chỉnh gì. Các màn khác chỉ sửa vài dòng.
##
## KHÔNG gieo hạt ngẫu nhiên cố định: mỗi lần bung phải khác nhau thì mới sống
## động. Hệ quả cần nhớ khi kiểm thử: ảnh chụp hai lần chạy sẽ KHÁC nhau dù
## không sửa dòng code nào, nên đừng dùng "ảnh giống hệt" làm cổng kiểm chứng
## nếu chưa tắt lớp này.

## Dải tốc độ ban đầu của hạt (pixel/giây).
var speed_min: float = 50.0
var speed_max: float = 210.0

## Bán kính hạt lúc mới sinh (pixel).
var radius_min: float = 2.5
var radius_max: float = 5.0

## Tốc độ tắt — alpha giảm bấy nhiêu mỗi giây.
var decay_min: float = 1.6
var decay_max: float = 2.8

## Hệ số hãm mỗi khung hình: <1 nên hạt chậm dần rồi đứng lại.
var damping: float = 0.91

## Quầng sáng mờ vẽ quanh hạt: bội số bán kính, và độ mờ của nó.
var halo_scale: float = 1.9
var halo_alpha: float = 0.25

## Độ thiên lên trên. 0 = bung đều mọi hướng; >0 = hạt bay lên (Màn Chúc Ngủ
## Ngon dùng 0.4 để bụi sao lửng lơ bay lên như hơi thở).
var rise: float = 0.0

## Dùng khi nơi gọi không truyền màu.
var default_color: Color = Color(1.0, 0.92, 0.45, 0.95)
var default_count: int = 20

var _particles: Array[Dictionary] = []


## `color` lấy thẳng default_color làm giá trị mặc định (GDScript tính biểu thức
## này lúc GỌI, theo đúng instance — đã dò thực tế trên 4.7.2, không phải đoán).
## `count` thì KHÔNG làm thế được: 0 là số hạt hợp lệ ("đừng bắn gì cả"), nên nó
## cần một giá trị vô hiệu riêng là -1 để phân biệt với "chủ ý bắn 0 hạt".
func emit_burst(origin: Vector2, color: Color = default_color, count: int = -1) -> void:
	var n := count if count >= 0 else default_count
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for _i in n:
		var angle := rng.randf_range(0.0, TAU)
		var spd := rng.randf_range(speed_min, speed_max)
		_particles.append({
			"pos": origin,
			"vel": Vector2(cos(angle), sin(angle) - rise) * spd,
			"color": color,
			"alpha": 1.0,
			"radius": rng.randf_range(radius_min, radius_max),
			"decay": rng.randf_range(decay_min, decay_max),
		})


func _process(delta: float) -> void:
	if _step_particles(delta):
		queue_redraw()


## Đẩy mô phỏng đi một nhịp. Trả về true nếu có gì đó thay đổi và cần vẽ lại.
## Tách riêng khỏi _process để lớp con (MusicalNoteBurst) gộp được nhiều đàn hạt
## mà vẫn chỉ gọi queue_redraw() một lần.
func _step_particles(delta: float) -> bool:
	if _particles.is_empty():
		return false
	# Duyệt ngược: xoá phần tử giữa chừng không làm lệch chỉ số của phần chưa duyệt.
	var i := _particles.size() - 1
	while i >= 0:
		var p: Dictionary = _particles[i]
		p["pos"] += p["vel"] * delta
		p["vel"] *= damping
		p["alpha"] -= p["decay"] * delta
		if p["alpha"] <= 0.0:
			_particles.remove_at(i)
		i -= 1
	return true


func _draw() -> void:
	for p in _particles:
		var col: Color = p["color"]
		col.a *= p["alpha"]
		draw_circle(p["pos"], p["radius"] * p["alpha"], col)
		draw_circle(
			p["pos"],
			p["radius"] * halo_scale * p["alpha"],
			Color(col.r, col.g, col.b, col.a * halo_alpha)
		)
