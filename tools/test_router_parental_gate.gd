@tool
extends SceneTree
## Kiểm thử luồng điều hướng giữa ScreenRouter và ParentalGate (Apple Kids 1.3)

func _init() -> void:
	print("=== BẮT ĐẦU KIỂM THỬ SCREEN ROUTER -> PARENTAL GATE ===")

	var router := ScreenRouter.new()
	router.name = "ScreenRouter"
	root.add_child(router)

	process_frame.connect(_test_flow.bind(router), CONNECT_ONE_SHOT)


func _test_flow(router: ScreenRouter) -> void:
	print("1. Khởi tạo ScreenRouter thành công")

	var pg: Node = router.get_parental_gate()
	if pg == null:
		printerr("LỖI: không tìm thấy ParentalGate trong ScreenRouter")
		quit(1)
		return
	print("2. ParentalGate đã được đăng ký trong ScreenRouter")

	# Test 1: Mở cổng trực tiếp qua router
	router.open_parental_gate("parental_corner")
	if not pg.is_open():
		printerr("LỖI: ParentalGate chưa mở sau router.open_parental_gate()")
		quit(1)
		return
	print("3. ParentalGate mở thành công qua router.open_parental_gate()")

	# Đóng cổng
	router.close_active_overlay()
	if pg.is_open():
		printerr("LỖI: ParentalGate chưa đóng sau close_active_overlay()")
		quit(1)
		return
	print("4. ParentalGate đóng thành công qua router.close_active_overlay()")

	# Test 2: Mở GoodnightScreen rồi Đánh thức -> Tự động bật Parental Gate (Apple Kids Category 1.3)
	router.open_goodnight()
	var gn := router.get_goodnight_screen()
	if not gn.is_open():
		printerr("LỖI: GoodnightScreen chưa mở")
		quit(1)
		return
	print("5. GoodnightScreen đã mở thành công")

	# Kích hoạt wake up từ GoodnightScreen -> Phải gọi Parental Gate
	router._on_goodnight_wake_up()
	if not pg.is_open():
		printerr("LỖI: ParentalGate không tự động mở khi bé bấm đánh thức GoodnightScreen!")
		quit(1)
		return
	print("6. Cổng Phụ Huynh tự động kích hoạt bảo vệ giấc ngủ (Apple Kids 1.3 chuẩn xác)")

	# Giải đúng câu đố trái cây (3 dâu tây)
	var dummy_btn := Button.new()
	pg._on_fruit_pressed(dummy_btn, "strawberry", 2)
	pg._on_fruit_pressed(dummy_btn, "strawberry", 3)
	pg._on_fruit_pressed(dummy_btn, "strawberry", 4)
	print("7. Đã giải đúng câu đố trái cây dâu tây, chờ mở khóa...")

	create_timer(0.8).timeout.connect(func():
		if gn.is_open():
			printerr("LỖI: GoodnightScreen chưa đóng sau khi phụ huynh mở khóa thành công!")
			quit(1)
			return
		print("8. GoodnightScreen đã được mở khóa và đóng thành công!")
		print("=== TẤT CẢ KIỂM THỬ ROUTER -> PARENTAL GATE ĐỀU ĐẠT CHUẨN 100%! ===")
		quit(0)
	)
