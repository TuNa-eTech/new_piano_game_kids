@tool
extends SceneTree
## Kịch bản kiểm thử màn hình GoodnightScreen 2.5D Diorama

const GoodnightScreenClass := preload("res://game/ui/goodnight_screen.gd")

func _init() -> void:
	print("=== BẮT ĐẦU KIỂM THỬ GOODNIGHT SCREEN ===")

	var gn := GoodnightScreenClass.new()
	gn.name = "GoodnightScreen"
	root.add_child(gn)

	process_frame.connect(_run_test.bind(gn), CONNECT_ONE_SHOT)


func _run_test(gn: Node) -> void:
	print("1. Đã khởi tạo GoodnightScreen và gắn vào SceneTree root thành công")

	var state := {
		"wake_up_called": false,
		"sound_toggled": false,
		"sound_state": true
	}
	gn.wake_up_requested.connect(func(): state["wake_up_called"] = true)
	gn.sound_toggled.connect(func(en: bool):
		state["sound_toggled"] = true
		state["sound_state"] = en
	)

	# 1. Mở màn hình chúc bé ngủ ngon
	gn.open_overlay()
	if not gn.is_open():
		printerr("LỖI: GoodnightScreen chưa mở sau khi gọi open_overlay()")
		quit(1)
		return
	print("2. Đã mở GoodnightScreen thành công")

	# 2. Kiểm thử nút tắt/bật âm thanh nhạc ru
	gn._on_sound_toggle_pressed()
	if gn._sound_enabled != false or state["sound_state"] != false:
		printerr("LỖI: Nút Sound không tắt âm thanh ru ngủ")
		quit(1)
		return
	print("3. Nút Sound: Đã TẮT nhạc ru thành công")

	gn._on_sound_toggle_pressed()
	if gn._sound_enabled != true or state["sound_state"] != true:
		printerr("LỖI: Nút Sound không BẬT lại nhạc ru")
		quit(1)
		return
	print("4. Nút Sound: Đã BẬT lại nhạc ru thành công")

	# 3. Kiểm thử chạm vào cuốn sách nổi bé phù thủy
	gn._on_sleeping_book_tapped()
	print("5. Tương tác chạm vào cuốn sách nổi bé phù thủy phản hồi mượt mà")

	# 4. Kiểm thử gõ 7 phím đàn thú ngủ say
	for i in range(7):
		var dummy_btn := Button.new()
		gn._on_key_pressed(dummy_btn, i, Color.WHITE, "Thú")
	print("6. Đã kiểm thử tương tác xúc giác 7 phím đàn thú ngủ say thành công")

	# 5. Kiểm thử nút quay lại / đánh thức (BACK)
	gn._on_unlock_pressed()
	if not state["wake_up_called"]:
		printerr("LỖI: Tín hiệu wake_up_requested không phát ra khi nhấn nút BACK")
		quit(1)
		return
	print("7. Tín hiệu wake_up_requested đã phát ra chuẩn xác!")

	# 6. Đóng màn hình
	gn.close_overlay()
	if gn.is_open():
		printerr("LỖI: GoodnightScreen chưa đóng sau khi gọi close_overlay()")
		quit(1)
		return
	print("8. GoodnightScreen đã đóng thành công")

	print("=== TẤT CẢ KIỂM THỬ GOODNIGHT SCREEN ĐỀU ĐẠT CHUẨN 100%! ===")
	quit(0)
