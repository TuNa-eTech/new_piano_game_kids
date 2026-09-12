@tool
extends SceneTree
## Kịch bản kiểm thử màn hình LevelSelect 2.5D Diorama

func _init() -> void:
	print("=== BẮT ĐẦU KIỂM THỬ LEVEL SELECT SCREEN ===")

	var ls := LevelSelect.new()
	ls.name = "LevelSelect"
	root.add_child(ls)

	# Chờ frame đầu tiên để node hoàn tất vào SceneTree và kích hoạt _ready()
	process_frame.connect(_run_test.bind(ls), CONNECT_ONE_SHOT)


func _run_test(ls: LevelSelect) -> void:
	print("1. Đã khởi tạo LevelSelect và gắn vào SceneTree root thành công")

	# Kiểm tra tín hiệu dùng Dictionary để lambda capture by reference
	var state := {
		"selected_page": -1,
		"back_called": false
	}
	ls.level_selected.connect(func(page: int): state["selected_page"] = page)
	ls.back_requested.connect(func(): state["back_called"] = true)

	# Mở chương 0 (Chương 1)
	ls.open_for_chapter(0)
	print("2. Đã mở open_for_chapter(0) thành công")

	# Giả lập nhấn nút quay lại
	ls._on_back_pressed()
	if state["back_called"]:
		print("3. Tín hiệu back_requested phát ra chuẩn xác")
	else:
		printerr("LỖI: back_requested không phát ra")
		quit(1)
		return

	# Mở lại và giả lập chọn bài 3
	ls.open_for_chapter(0)
	ls._on_level_btn_pressed(3, 3)
	print("4. Đã giả lập chọn bài 3 thành công")

	# Đợi timeout phản hồi
	create_timer(0.3).timeout.connect(func():
		if state["selected_page"] == 3:
			print("5. Tín hiệu level_selected phát ra chuẩn xác: page =", state["selected_page"])
			print("=== TẤT CẢ KIỂM THỬ LEVEL SELECT ĐỀU ĐẠT CHUẨN 100%! ===")
			quit(0)
		else:
			printerr("LỖI: level_selected không đúng trang: ", state["selected_page"])
			quit(1)
	)
