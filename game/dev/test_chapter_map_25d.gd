extends Node

var _passed: int = 0
var _failed: int = 0


func _ready() -> void:
	print("\n=== Kiểm tra Animation & UI/UX Màn 04: Bản Đồ 3 Chương Sách Nổi ===")

	var map := ChapterMap.new()
	add_child(map)

	# 1. Kiểm tra cấu trúc Node UI/UX
	_check("Tìm thấy DioramaStage", map.has_node("DioramaStage"))
	var stage: Control = map.get_node("DioramaStage")
	_check("Tìm thấy Nút Quay lại (BtnBack)", stage.has_node("BtnBack"))
	_check("Tìm thấy Lọ Sao Thủy Tinh (StarJarBtn)", stage.has_node("StarJarBtn"))
	_check("Tìm thấy Lớp Bùng Nổ Bụi Sao (StarlightBurstLayer)", map.has_node("StarlightBurstLayer"))

	# 2. Kiểm tra 3 Thẻ Chương và Shader 2.5D
	var cards := map._cards
	_check("Đủ 3 thẻ chương 2.5D", cards.size() == 3)
	for i in cards.size():
		var c: ChapterCard = cards[i]
		_check("Thẻ %d có ShaderMaterial 2.5D" % (i + 1), c._shader_mat != null)

	# 3. Kiểm tra Hoạt Cảnh Mở Màn Hình (Entry Pop-up Sequence)
	map.open_map()
	await get_tree().process_frame
	_check("Map mở thành công (is_open)", map.is_open())
	_check("Thẻ 1 đang chạy animation pop-up", cards[0].scale.x < 1.0 or cards[0].scale.x > 1.0 or cards[0]._entry_tween != null)

	# 4. Kiểm tra Tương Tác Xúc Giác & Hạt Bụi Sao (Lọ Sao)
	# Kiểu giờ là StarlightBurst dùng chung (game/fx/), không còn lớp nội bộ của ChapterMap.
	var burst: StarlightBurst = map.get_node("StarlightBurstLayer")
	var initial_particles := burst._particles.size()
	map._on_star_jar_pressed()
	_check("Lọ sao bấm phát sinh hạt bụi sao (Starlight Burst)", burst._particles.size() > initial_particles)

	# 5. Kiểm tra Hoạt Cảnh Lơ Lửng (Idle Floating Wave)
	var prev_face_y: float = cards[0]._face.position.y
	cards[0]._process(0.25)
	_check("Thẻ chương có hoạt ảnh trôi bồng bềnh 2.5D (Floating Wave)", cards[0]._face.position.y != prev_face_y or cards[0]._idle_time > 0.0)

	# 6. Kiểm tra Chạm Thẻ Mở (Chapter 1) và Thẻ Khóa (Chapter 3)
	var burst_before_tap := burst._particles.size()
	map._on_card_pressed(0)
	_check("Chạm Thẻ Mở bung chùm sao bùng nổ", burst._particles.size() > burst_before_tap)

	map.close_map()
	await get_tree().process_frame

	print("\n=== KẾT QUẢ: %d ĐẠT, %d THẤT BẠI ===" % [_passed, _failed])
	if _failed == 0:
		print("=== ĐẠT TOÀN BỘ TIÊU CHÍ ANIMATION & UI/UX 2.5D ===")
	get_tree().quit(0 if _failed == 0 else 1)


func _check(desc: String, condition: bool) -> void:
	if condition:
		_passed += 1
		print("  [OK ] %s" % desc)
	else:
		_failed += 1
		print("  [FAIL] %s" % desc)
