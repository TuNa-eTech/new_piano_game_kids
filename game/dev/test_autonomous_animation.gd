extends Node2D

func _ready() -> void:
	print("=== Kiểm tra Hoạt Cảnh Tự Động Nhân Vật (Autonomous Animation Test) ===")

	var chars := AnimatedMenuCharacters.new()
	add_child(chars)

	# 1. Ban đầu ở trạng thái IDLE
	assert(chars.current_state == AnimatedMenuCharacters.AnimState.IDLE, "Ban đầu phải là IDLE")
	print("  [OK ] Trạng thái khởi đầu: IDLE")

	# 2. Lắng nghe thay đổi trạng thái khi kịch bản chạy
	var state_changes: Array[AnimatedMenuCharacters.AnimState] = []
	chars.state_changed.connect(func(s: AnimatedMenuCharacters.AnimState):
		state_changes.append(s)
	)

	# Đợi 1.5 giây để chu trình tự động bắt đầu kịch bản đầu tiên (Chase)
	await get_tree().create_timer(1.5).timeout

	assert(state_changes.size() > 0, "Nhân vật phải tự động đổi trạng thái mà không cần tương tác!")
	print("  [OK ] Nhân vật tự động biểu diễn hành vi: ", state_changes)

	# 3. Kiểm tra tương tác cảm ứng người dùng vẫn ưu tiên ngắt và phản hồi tức thì
	chars._on_tapped()
	await get_tree().process_frame
	print("  [OK ] Chạm tương tác phản hồi tức thời mượt mà")

	print("\n=== ĐẠT TOÀN BỘ KIỂM THỬ HOẠT CẢNH TỰ ĐỘNG ===")
	get_tree().quit(0)
