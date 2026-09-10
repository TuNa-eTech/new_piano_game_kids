extends Node
## Máy đo tự động kiểm tra Hướng 3: Tương tác thế giới 3D (Interactive Diorama Juice).
##
## Chạy:  Godot --headless --path . res://game/dev/interactive_diorama_test.tscn

var _fails: int = 0


func _check(label: String, ok: bool, detail: String = "") -> void:
	if not ok:
		_fails += 1
	print("  [%s] %s%s" % ["OK " if ok else "SAI", label, ("  — " + detail) if detail else ""])


func _ready() -> void:
	print("=== Kiểm tra Hướng 3: Interactive Diorama Juice ===\n")

	await _test_diorama_props_interaction()
	await _test_star_jar_interaction()
	await _test_keyboard_boundary_safety()

	print("\n=== %s ===" % ("ĐẠT TOÀN BỘ" if _fails == 0 else "TRƯỢT (%d lỗi)" % _fails))
	get_tree().quit(0 if _fails == 0 else 1)


func _test_diorama_props_interaction() -> void:
	print("① Kiểm tra tương tác các đạo cụ Diorama")
	var scene := preload("res://game/diorama/diorama_stage.tscn")
	var diorama: DioramaStage = scene.instantiate()
	add_child(diorama)
	diorama.size = Vector2(1280, 460)
	await get_tree().process_frame

	var received: Array[String] = []
	diorama.prop_interacted.connect(func(prop): received.append(prop))

	# 1. Chú Phù Thủy
	diorama.interact_wizard()
	_check("Chạm Phù Thủy phát tín hiệu", received.has("wizard"))
	_check("Chùm sao Phù Thủy kích hoạt", diorama._wizard_sparkles != null and diorama._wizard_sparkles.emitting)
	_check("Bong bóng thoại có chữ", not diorama._speech_label.text.is_empty())

	# 2. Thạch anh xanh
	diorama.interact_crystal_cyan()
	_check("Chạm Thạch Anh Xanh phát tín hiệu", received.has("crystal_cyan"))
	_check("Bụi ngọc xanh kích hoạt", diorama._cyan_sparkles != null and diorama._cyan_sparkles.emitting)

	# 3. Thạch anh hồng
	diorama.interact_crystal_magenta()
	_check("Chạm Thạch Anh Hồng phát tín hiệu", received.has("crystal_magenta"))
	_check("Bụi ngọc hồng kích hoạt", diorama._magenta_sparkles != null and diorama._magenta_sparkles.emitting)

	# 4. Rương báu
	diorama.interact_chest()
	_check("Chạm Rương Báu phát tín hiệu", received.has("chest"))
	_check("Hạt sao từ rương kích hoạt", diorama._chest_sparkles != null and diorama._chest_sparkles.emitting)

	# 5. Sách
	diorama.interact_book(Vector2(400, 200))
	_check("Chạm Trang Sách phát tín hiệu", received.has("book"))

	diorama.queue_free()


func _test_star_jar_interaction() -> void:
	print("\n② Kiểm tra tương tác Lọ Hạt Sao (StarJar)")
	var jar := StarJar.new()
	add_child(jar)
	jar.size = Vector2(66, 90)
	await get_tree().process_frame

	var jar_clicks: Array[bool] = []
	jar.jar_interacted.connect(func(): jar_clicks.append(true))

	jar.wiggle()
	_check("Lọ sao lắc lư phát tín hiệu jar_interacted", not jar_clicks.is_empty())
	_check("Lọ sao có hiệu ứng sáng lấp lánh (flash)", jar._flash > 0.5)

	jar.queue_free()


func _test_keyboard_boundary_safety() -> void:
	print("\n③ Kiểm tra ranh giới an toàn không đè phím đàn")
	var main: Node = load("res://game/main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame

	var diorama: DioramaStage = main.get_node("UI/DioramaStage")
	var keyboard: PianoKeyboard = main.get_node("UI/PianoKeyboard")

	_check("DioramaStage tồn tại", diorama != null)
	_check("PianoKeyboard tồn tại", keyboard != null)

	# Kiểm tra tọa độ y không giao thoa
	var diorama_bottom: float = diorama.global_position.y + diorama.size.y
	var keyboard_top: float = keyboard.global_position.y
	_check("DioramaStage kết thúc tại hoặc trước đỉnh bàn phím (y=460)",
		diorama_bottom <= keyboard_top + 1.0,
		"diorama_bottom=%.1f, keyboard_top=%.1f" % [diorama_bottom, keyboard_top])

	main.queue_free()
