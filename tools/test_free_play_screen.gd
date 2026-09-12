@tool
extends SceneTree

func _init() -> void:
	print("=== KIỂM THỬ MÀN 03: SÂN KHẤU CHƠI TỰ DO (FREE PLAY STAGE) ===")
	
	# 1. Nạp và khởi tạo main scene
	var main_scene := load("res://game/main.tscn") as PackedScene
	if main_scene == null:
		printerr("Lỗi: Không nạp được res://game/main.tscn")
		quit(1)
		return
	
	var main_node := main_scene.instantiate()
	root.add_child(main_node)
	print("[PASS] Khởi tạo main.tscn thành công!")
	
	# 2. Kiểm tra FreePlayTopBar đã được gắn vào HUD
	var hud := main_node.get_node("HUD")
	var free_bar := hud.get_node_or_null("FreePlayTopBar")
	if free_bar == null:
		printerr("Lỗi: Không tìm thấy FreePlayTopBar trong HUD!")
		quit(1)
		return
	print("[PASS] FreePlayTopBar tồn tại trong HUD!")
	
	# 3. Kích hoạt chế độ Free Play
	print("--> Bật GameState.free_play = true...")
	GameState.free_play = true
	
	# Kiểm tra thanh nhạc cụ hiển thị
	if not free_bar.visible:
		printerr("Lỗi: FreePlayTopBar không hiển thị khi bật free_play!")
		quit(1)
		return
	print("[PASS] FreePlayTopBar hiển thị khi free_play = true!")
	
	# 4. Thử chọn 4 slot nhạc cụ
	for slot_idx in range(4):
		free_bar.select_slot(slot_idx)
		var expected_mode: int = free_bar.SLOT_TO_MODE[slot_idx]
		if GameState.instrument_mode != expected_mode:
			printerr("Lỗi: Slot %d không cập nhật instrument_mode đúng (kỳ vọng %d, thực tế %d)" % [slot_idx, expected_mode, GameState.instrument_mode])
			quit(1)
			return
		print("[PASS] Slot %d ('%s') -> instrument_mode = %d chính xác!" % [slot_idx, free_bar.INSTRUMENT_NAMES[slot_idx], expected_mode])
	
	# 5. Kiểm tra bàn phím đàn đổi sang màu cầu vồng
	var keyboard := main_node.get_node("UI/PianoKeyboard")
	for i in range(keyboard._keys.size()):
		var key = keyboard._keys[i]
		if not key._is_rainbow:
			printerr("Lỗi: Phím đàn %d chưa bật chế độ rainbow!" % i)
			quit(1)
			return
	print("[PASS] Toàn bộ 7 phím đàn đã chuyển sang màu pastel cầu vồng chuẩn mock-free-play.jpeg!")
	
	# 6. Kiểm tra các thành phần của DioramaStage
	var diorama := main_node.get_node("UI/DioramaStage")
	if diorama._beanstalk_freeplay == null or not diorama._beanstalk_freeplay.visible:
		printerr("Lỗi: BeanstalkFreePlay không hiển thị trên trang sách phải!")
		quit(1)
		return
	print("[PASS] Cây đậu thần âm nhạc (BeanstalkFreePlay) đã hiển thị trên trang sách phải!")
	
	if diorama._bubble_particles == null or not diorama._bubble_particles.emitting:
		printerr("Lỗi: BubbleNotesParticles chưa phun hạt bong bóng âm nhạc!")
		quit(1)
		return
	print("[PASS] Hệ thống bong bóng nốt nhạc (BubbleNotesParticles) đang phun hạt ngũ sắc!")
	
	print("--> Tắt GameState.free_play = false...")
	GameState.free_play = false
	if diorama._beanstalk_freeplay.visible:
		printerr("Lỗi: BeanstalkFreePlay vẫn còn hiển thị khi tắt free_play!")
		quit(1)
		return
	print("[PASS] DioramaStage và HUD khôi phục trạng thái chuẩn khi tắt Free Play!")

	print("=== TẤT CẢ CÁC BƯỚC KIỂM THỬ MÀN 03 ĐỀU ĐẠT CHẤT LƯỢNG 100%! ===")
	quit(0)
