@tool
extends SceneTree
## Kiểm thử luồng điều hướng giữa ScreenRouter và LevelSelect

func _init() -> void:
	print("=== BẮT ĐẦU KIỂM THỬ SCREEN ROUTER -> LEVEL SELECT ===")

	var router := ScreenRouter.new()
	router.name = "ScreenRouter"
	root.add_child(router)

	process_frame.connect(_test_flow.bind(router), CONNECT_ONE_SHOT)


func _test_flow(router: ScreenRouter) -> void:
	print("1. Khởi tạo ScreenRouter thành công")

	var ls := router.get_level_select()
	if ls == null:
		printerr("LỖI: không tìm thấy LevelSelect trong ScreenRouter")
		quit(1)
		return
	print("2. LevelSelect đã được đăng ký trong ScreenRouter")

	# Mở LevelSelect từ router
	router.open_level_select(0)
	if not ls.is_open():
		printerr("LỖI: LevelSelect chưa mở sau router.open_level_select(0)")
		quit(1)
		return
	print("3. LevelSelect đã mở thành công qua router.open_level_select(0)")

	# Đóng LevelSelect qua router
	router.close_active_overlay()
	if ls.is_open():
		printerr("LỖI: LevelSelect chưa đóng sau close_active_overlay()")
		quit(1)
		return
	print("4. LevelSelect đã đóng thành công qua router.close_active_overlay()")

	print("=== KIỂM THỬ ĐIỀU HƯỚNG ROUTER -> LEVEL SELECT ĐẠT 100%! ===")
	quit(0)
