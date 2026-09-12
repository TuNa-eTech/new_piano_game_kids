@tool
extends SceneTree
## Kiểm thử luồng điều hướng hoàn chỉnh: ScreenRouter -> ParentalGate -> ParentalCorner

func _init() -> void:
	print("=== BẮT ĐẦU KIỂM THỬ ROUTER -> GATE -> CORNER ===")

	var router := ScreenRouter.new()
	router.name = "ScreenRouter"
	root.add_child(router)

	process_frame.connect(_test_flow.bind(router), CONNECT_ONE_SHOT)


func _test_flow(router: ScreenRouter) -> void:
	print("1. Khởi tạo ScreenRouter thành công")

	var pg: Node = router.get_parental_gate()
	var pc: Node = router.get_parental_corner()
	if pg == null or pc == null:
		printerr("LỖI: ParentalGate hoặc ParentalCorner chưa đăng ký trong ScreenRouter")
		quit(1)
		return
	print("2. Cả ParentalGate và ParentalCorner đều đã hiện diện trong ScreenRouter")

	# Test 1: Mở cổng phụ huynh với đích đến là ParentalCorner
	router.open_parental_gate("parental_corner")
	if not pg.is_open():
		printerr("LỖI: ParentalGate chưa mở")
		quit(1)
		return
	print("3. Cổng Phụ Huynh mở thành công với mục tiêu 'parental_corner'")

	# Giải đúng câu đố trái cây (3 quả dâu tây)
	var dummy_btn := Button.new()
	pg._on_fruit_pressed(dummy_btn, "strawberry", 2)
	pg._on_fruit_pressed(dummy_btn, "strawberry", 3)
	pg._on_fruit_pressed(dummy_btn, "strawberry", 4)
	print("4. Đã giải câu đố 3 quả dâu tây, chờ mở khóa Cổng...")

	create_timer(0.8).timeout.connect(func():
		if not pc.is_open():
			printerr("LỖI: ParentalCorner chưa tự động mở sau khi vượt qua Cổng Phụ Huynh!")
			quit(1)
			return
		print("5. Vượt Cổng Phụ Huynh thành công! Góc Phụ Huynh (ParentalCorner) đã tự động mở ra!")

		# Thao tác điều khiển trên ParentalCorner
		pc._on_timer_dial_pressed()
		print("6. Thao tác đĩa quay hẹn giờ thành công trong Góc Phụ Huynh")

		# Đóng góc phụ huynh
		pc._on_close_pressed()
		if pc.is_open():
			printerr("LỖI: ParentalCorner chưa đóng")
			quit(1)
			return
		print("7. Đã đóng Góc Phụ Huynh thành công!")

		print("=== TOÀN BỘ LUỒNG GATE -> CORNER ĐẠT CHUẨN 100%! ===")
		quit(0)
	)
