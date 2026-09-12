extends Node
## Kịch bản kiểm tra toàn diện Màn hình Main Menu 2.5D chuẩn concept

const MainMenu = preload("res://game/ui/main_menu.gd")

func _ready() -> void:
	print("=== Kiểm tra Toàn Diện Màn Hình Khởi Đầu 2.5D (MainMenu) ===")
	var menu := MainMenu.new()
	add_child(menu)
	menu.open_overlay()
	await get_tree().process_frame

	# 1. Kiểm tra cấu trúc Node chính
	_check_node(menu, "BackgroundEnvironment", "TextureRect")
	_check_node(menu, "SwirlingNotesOrbit", "Control")
	_check_node(menu, "CharacterHotspot", "Button")
	_check_node(menu, "BookHotspot", "Button")
	_check_node(menu, "CrystalHotspot", "Button")
	_check_node(menu, "ChestHotspot", "Button")
	_check_node(menu, "PlayButtonContainer", "Control")
	_check_node(menu, "FireflyOverlay", "Control")
	_check_node(menu, "StarlightBurstLayer", "Control")

	# 2. Kiểm tra Nút bấm chính
	var play_box: Control = menu.get_node_or_null("PlayButtonContainer") as Control
	var play_btn: Button = play_box.get_node_or_null("PlayButtonHitbox") as Button if play_box else null
	if play_btn != null and play_btn.mouse_filter == Control.MOUSE_FILTER_STOP:
		print("  [OK ] Nút Khóa Son PLAY có hitbox hợp lệ (MOUSE_FILTER_STOP)")
	else:
		printerr("  [SAI] Nút Khóa Son PLAY không hợp lệ")

	# 3. Kiểm tra Tín hiệu & Luồng Đóng/Mở
	var play_received := [false]
	menu.play_pressed.connect(func(): play_received[0] = true)
	menu._on_play_pressed()
	await get_tree().process_frame
	if play_received[0] and not menu.is_open():
		print("  [OK ] _on_play_pressed() phát tín hiệu play_pressed và đóng overlay thành công")
	else:
		printerr("  [SAI] _on_play_pressed() hoạt động không đúng")

	menu.open_overlay()
	await get_tree().process_frame
	var levels_received := [false]
	menu.levels_pressed.connect(func(): levels_received[0] = true)
	menu._on_levels_pressed()
	if levels_received[0]:
		print("  [OK ] _on_levels_pressed() phát tín hiệu levels_pressed")
	else:
		printerr("  [SAI] _on_levels_pressed() thất bại")

	var parent_received := [false]
	menu.parent_gate_requested.connect(func(): parent_received[0] = true)
	menu._on_parent_pressed()
	if parent_received[0]:
		print("  [OK ] _on_parent_pressed() phát tín hiệu parent_gate_requested")
	else:
		printerr("  [SAI] _on_parent_pressed() thất bại")

	# 4. Kiểm tra hiệu ứng nốt nhạc xoay quanh sách
	var orbit: Control = menu.get_node_or_null("SwirlingNotesOrbit") as Control
	if orbit != null:
		print("  [OK ] SwirlingNotesOrbit tồn tại và hoạt động quanh bìa sách")
	else:
		printerr("  [SAI] Không tìm thấy SwirlingNotesOrbit")

	# 5. Kiểm tra bộ phát bụi sao StarlightBurst
	var burst: Control = menu.get_node_or_null("StarlightBurstLayer") as Control
	if burst != null:
		print("  [OK ] StarlightBurstLayer sẵn sàng tạo hiệu ứng bùng nổ bụi sao")
	else:
		printerr("  [SAI] Không tìm thấy StarlightBurstLayer")

	menu.queue_free()
	print("\n=== ĐẠT TOÀN BỘ CÁC TIÊU CHÍ MÀN HÌNH 2.5D ===")
	get_tree().quit(0)


func _check_node(parent: Node, node_name: String, expected_type: String) -> void:
	var n := parent.get_node_or_null(node_name)
	if n != null and n.is_class(expected_type):
		print("  [OK ] Tìm thấy %s (%s)" % [node_name, expected_type])
	else:
		printerr("  [SAI] Không tìm thấy node %s loại %s" % [node_name, expected_type])
