@tool
extends SceneTree
## Kịch bản kiểm thử màn hình ParentalGate 2.5D Diorama

const ParentalGateClass := preload("res://game/ui/parental_gate.gd")

func _init() -> void:
	print("=== BẮT ĐẦU KIỂM THỬ PARENTAL GATE SCREEN ===")

	var pg := ParentalGateClass.new()
	pg.name = "ParentalGate"
	root.add_child(pg)

	process_frame.connect(_run_test.bind(pg), CONNECT_ONE_SHOT)


func _run_test(pg: Node) -> void:
	print("1. Đã khởi tạo ParentalGate và gắn vào SceneTree root thành công")

	var state := {
		"gate_unlocked": false,
		"gate_cancelled": false
	}
	pg.gate_unlocked.connect(func(): state["gate_unlocked"] = true)
	pg.gate_cancelled.connect(func(): state["gate_cancelled"] = true)

	# Mở cổng
	pg.open_gate()
	print("2. Đã gọi open_gate() thành công")

	# Test 1: Nhấn sai quả (banana) -> reset đếm
	var dummy_btn := Button.new()
	pg._on_fruit_pressed(dummy_btn, "banana", 0)
	if pg._tapped_count != 0:
		printerr("LỖI: Tapped count không bằng 0 khi bấm sai quả")
		quit(1)
		return
	print("3. Bấm sai quả xử lý đúng: reset _tapped_count = 0")

	# Test 2: Bấm 1 quả dâu -> count = 1
	pg._on_fruit_pressed(dummy_btn, "strawberry", 2)
	if pg._tapped_count != 1:
		printerr("LỖI: Tapped count không tăng khi bấm dâu tây")
		quit(1)
		return
	print("4. Bấm 1 quả dâu tây thành công: _tapped_count = 1")

	# Test 3: Bấm táo -> count reset về 0
	pg._on_fruit_pressed(dummy_btn, "apple", 1)
	if pg._tapped_count != 0:
		printerr("LỖI: Tapped count không reset khi bấm táo sau dâu tây")
		quit(1)
		return
	print("5. Bấm quả táo xen giữa đã reset _tapped_count về 0 chuẩn xác")

	# Test 4: Bấm liên tiếp 3 quả dâu tây -> kích hoạt mở khóa
	pg._on_fruit_pressed(dummy_btn, "strawberry", 2)
	pg._on_fruit_pressed(dummy_btn, "strawberry", 3)
	pg._on_fruit_pressed(dummy_btn, "strawberry", 4)
	print("6. Đã bấm đủ 3 quả dâu tây, chờ animation mở khóa...")

	create_timer(0.8).timeout.connect(func():
		if not state["gate_unlocked"]:
			printerr("LỖI: Tín hiệu gate_unlocked không phát ra sau khi mở khóa!")
			quit(1)
			return
		print("7. Tín hiệu gate_unlocked đã phát ra chuẩn xác!")

		# Test 5: Kiểm tra nút đóng / hủy cổng
		pg.open_gate()
		pg._on_close_pressed()
		if state["gate_cancelled"]:
			print("8. Tín hiệu gate_cancelled phát ra chuẩn xác khi nhấn Đóng!")
			print("=== TẤT CẢ KIỂM THỬ PARENTAL GATE ĐỀU ĐẠT CHUẨN 100%! ===")
			quit(0)
		else:
			printerr("LỖI: gate_cancelled không phát ra khi nhấn đóng!")
			quit(1)
	)
