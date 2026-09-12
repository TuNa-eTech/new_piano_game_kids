@tool
extends SceneTree
## Kịch bản kiểm thử màn hình ParentalCorner 2.5D Diorama

const ParentalCornerClass := preload("res://game/ui/parental_corner.gd")

func _init() -> void:
	print("=== BẮT ĐẦU KIỂM THỬ PARENTAL CORNER SCREEN ===")

	var pc := ParentalCornerClass.new()
	pc.name = "ParentalCorner"
	root.add_child(pc)

	process_frame.connect(_run_test.bind(pc), CONNECT_ONE_SHOT)


func _run_test(pc: Node) -> void:
	print("1. Đã khởi tạo ParentalCorner và gắn vào SceneTree root thành công")

	var state := {
		"closed": false,
		"timer_mins": -1,
		"vol_val": -1.0,
		"lullaby_state": false
	}
	pc.closed.connect(func(): state["closed"] = true)
	pc.bedtime_timer_changed.connect(func(m: int): state["timer_mins"] = m)
	pc.volume_changed.connect(func(v: float): state["vol_val"] = v)
	pc.lullaby_toggled.connect(func(en: bool): state["lullaby_state"] = en)

	# 1. Mở màn hình góc phụ huynh
	pc.open_corner()
	if not pc.is_open():
		printerr("LỖI: ParentalCorner chưa mở sau khi gọi open_corner()")
		quit(1)
		return
	print("2. Đã mở open_corner() thành công")

	# 2. Kiểm thử điều chỉnh thanh trượt âm lượng
	pc._on_volume_changed(0.50)
	if absf(pc._volume_val - 0.50) > 0.01 or absf(state["vol_val"] - 0.50) > 0.01:
		printerr("LỖI: Âm lượng không được cập nhật đúng 0.50")
		quit(1)
		return
	print("3. Kiểm thử thanh trượt âm lượng: Đạt chuẩn (val = 0.50)")

	# 3. Kiểm thử đĩa quay hẹn giờ đi ngủ
	# Preset ban đầu khi GameState = 0: index 0 (0m / Tắt)
	# Nhấn lần 1 -> chuyển sang 15 phút
	pc._on_timer_dial_pressed()
	if pc._timer_presets[pc._timer_idx] != 15 or state["timer_mins"] != 15:
		printerr("LỖI: Hẹn giờ không chuyển sang 15 phút sau khi nhấn đĩa quay lần 1")
		quit(1)
		return
	print("4. Đĩa quay hẹn giờ: Chuyển sang 15 phút thành công")

	# Nhấn lần 2 -> chuyển sang 30 phút
	pc._on_timer_dial_pressed()
	if pc._timer_presets[pc._timer_idx] != 30 or state["timer_mins"] != 30:
		printerr("LỖI: Hẹn giờ không chuyển sang 30 phút sau khi nhấn đĩa quay lần 2")
		quit(1)
		return
	print("5. Đĩa quay hẹn giờ: Chuyển sang 30 phút thành công")

	# Bấm tiếp sang 45m, 60m, 0m (Tắt)
	pc._on_timer_dial_pressed() # 45
	pc._on_timer_dial_pressed() # 60
	pc._on_timer_dial_pressed() # 0 (Tắt)
	if pc._timer_presets[pc._timer_idx] != 0 or state["timer_mins"] != 0:
		printerr("LỖI: Hẹn giờ không chuyển về 0 (Tắt)")
		quit(1)
		return
	print("6. Đĩa quay hẹn giờ: Chu kỳ xoay tuần hoàn về 0 phút (TẮT) chuẩn xác")

	# 4. Kiểm thử công tắc nhạc ru ngủ (Lullaby Toggle)
	# Mặc định đang bật (true) -> bấm tắt
	pc._on_lullaby_toggle_pressed()
	if pc._lullaby_enabled != false or state["lullaby_state"] != false:
		printerr("LỖI: Lullaby không tắt khi nhấn toggle")
		quit(1)
		return
	print("6. Công tắc nhạc ru ngủ: Đã TẮT thành công")

	pc._on_lullaby_toggle_pressed()
	if pc._lullaby_enabled != true or state["lullaby_state"] != true:
		printerr("LỖI: Lullaby không BẬT lại khi nhấn toggle")
		quit(1)
		return
	print("7. Công tắc nhạc ru ngủ: Đã BẬT lại thành công")

	# 5. Kiểm thử tương tác bé phù thủy ngủ say
	pc._on_sleeping_boy_tapped()
	print("8. Tương tác mascot bé phù thủy ngủ say phản hồi mượt mà")

	# 6. Kiểm thử nút Đóng
	pc._on_close_pressed()
	if not state["closed"] or pc.is_open():
		printerr("LỖI: ParentalCorner chưa đóng sau khi nhấn nút Đóng")
		quit(1)
		return
	print("9. Tín hiệu closed phát ra và lớp phủ đã đóng chuẩn xác")

	print("=== TẤT CẢ KIỂM THỬ PARENTAL CORNER ĐỀU ĐẠT CHUẨN 100%! ===")
	quit(0)
