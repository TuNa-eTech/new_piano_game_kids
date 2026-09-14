extends Node2D
## Canh BẤT BIẾN của ngăn xếp lớp phủ (Giai Đoạn 1):
##   ván chơi chạy lại khi và CHỈ KHI ngăn xếp rỗng.
##
## Vì sao cần bài test RIÊNG: navigation_flow_test kiểm luồng đi giữa các màn,
## còn soak_test thì gõ đàn — không bài nào mở/đóng lớp phủ nhiều chu kỳ. Mà trôi
## bộ đếm chính là thứ chỉ lộ ra sau NHIỀU chu kỳ. Ba tình huống ở dưới đúng là
## ba lỗi mà biến đếm `_open_count` cũ từng mắc; giữ bài test này để chúng không
## quay lại.

var _fails: int = 0


func _check(label: String, ok: bool, detail: String = "") -> void:
	if not ok:
		_fails += 1
	print("  [%s] %s%s" % ["OK " if ok else "SAI", label, ("  — " + detail) if detail else ""])


func _ready() -> void:
	print("=== Kiểm tra Bất Biến Ngăn Xếp Lớp Phủ ===\n")
	SaveStore.reset_for_test()
	PauseOverlay.reset_pause_state()

	var main: Node = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	for i in 8:
		await get_tree().process_frame
	var r = main.router()
	_check("ScreenRouter sẵn sàng", r != null)
	if r == null:
		get_tree().quit()
		return

	var map = r.get_chapter_map()

	print("① Nhiều chu kỳ mở/đóng — chỗ bộ đếm cũ trôi số")
	for i in 30:
		r.open_chapter_map()
		await get_tree().process_frame
		map.close_map()
		await get_tree().process_frame
	_check("30 chu kỳ -> ngăn xếp rỗng", PauseOverlay.open_overlay_count() == 0,
		"còn %d" % PauseOverlay.open_overlay_count())
	_check("30 chu kỳ -> ván chơi chạy lại", not get_tree().paused)

	print("\n② Mở LẶP cùng một lớp (lỗi ①: đếm lên 2, đóng 1 lần không đủ)")
	r.open_chapter_map()
	r.open_chapter_map()
	r.open_chapter_map()
	await get_tree().process_frame
	_check("mở lặp 3 lần chỉ chiếm 1 ô", PauseOverlay.open_overlay_count() == 1,
		"có %d" % PauseOverlay.open_overlay_count())
	map.close_map()
	await get_tree().process_frame
	_check("đóng 1 lần là đủ để chạy lại", not get_tree().paused)

	print("\n③ Đóng một lớp đã đóng (lỗi ②: đếm xuống âm)")
	map.close_map()
	map.close_map()
	await get_tree().process_frame
	_check("đóng thừa không làm lệch ngăn xếp", PauseOverlay.open_overlay_count() == 0,
		"có %d" % PauseOverlay.open_overlay_count())

	print("\n④ Ngăn xếp SÂU 2 — luồng thật, Cổng Phụ Huynh chồng Màn Chúc Ngủ Ngon")
	r.open_goodnight_screen()
	await get_tree().process_frame
	r.open_parental_gate("wake_up")
	await get_tree().process_frame
	_check("ngăn xếp sâu 2", PauseOverlay.open_overlay_count() == 2,
		"có %d" % PauseOverlay.open_overlay_count())
	_check("sâu 2 thì ván chơi VẪN dừng", get_tree().paused)
	var top := PauseOverlay.top_overlay()
	_check("đỉnh ngăn xếp là ParentalGate", top == r.get_parental_gate(),
		"đỉnh = %s" % (top.name if top != null else "null"))

	print("\n⑤ close_active_overlay() phải dọn sạch cả ngăn xếp sâu")
	r.close_active_overlay()
	await get_tree().process_frame
	_check("dọn sạch ngăn xếp", PauseOverlay.open_overlay_count() == 0,
		"còn %d" % PauseOverlay.open_overlay_count())
	_check("dọn sạch -> ván chơi chạy lại", not get_tree().paused)

	print("\n⑥ Lớp bị giải phóng LÚC ĐANG MỞ (lỗi ③: game kẹt paused vĩnh viễn)")
	var orphan = load("res://game/ui/chapter_map.gd").new()
	get_tree().root.add_child(orphan)
	await get_tree().process_frame
	orphan.open_overlay()
	await get_tree().process_frame
	_check("lớp rời mở -> ngăn xếp có 1", PauseOverlay.open_overlay_count() == 1)
	orphan.free()
	await get_tree().process_frame
	_check("free lúc đang mở -> ngăn xếp tự dọn", PauseOverlay.open_overlay_count() == 0,
		"còn %d" % PauseOverlay.open_overlay_count())
	_check("free lúc đang mở -> KHÔNG kẹt paused", not get_tree().paused)

	print("\n=== %s ===" % ("ĐẠT TOÀN BỘ" if _fails == 0 else "TRƯỢT (%d lỗi)" % _fails))
	main.queue_free()
	get_tree().quit()
