extends Node
## Bộ chụp hình hoạt ảnh lật trang — chạy CÓ cửa sổ, KHÔNG dùng --headless
## (trình kết xuất dummy chỉ trả về ảnh trống).
##
##   /Applications/Godot.app/Contents/MacOS/Godot --path . \
##       res://game/dev/capture_page_flip.tscn -- <thư_mục_xuất>
##
## Không truyền thư mục thì ảnh rơi vào user://page_flip, KHÔNG rơi vào repo.
##
## Chụp từng mốc thời gian của cả hai chiều lật để mắt người soi được hình nếp
## cuộn, bóng đổ và thời điểm lộ trang mới — thứ mà log văn bản không nói được.

const FLIP_SECONDS := 1.0
const SHOT_RATIOS: Array[float] = [0.0, 0.2, 0.36, 0.52, 0.7, 0.88]

var _out_dir: String = "user://page_flip"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_out_dir = args[0]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))

	SaveStore.reset_for_test()
	PauseOverlay.reset_pause_state()
	var main: Node = load("res://game/main.tscn").instantiate()
	add_child(main)
	await _run(main)
	get_tree().quit()


func _run(main: Node) -> void:
	for i in 40:
		await get_tree().process_frame

	var diorama: DioramaStage = main.get_node_or_null("UI/DioramaStage")
	if diorama == null:
		push_error("Không tìm thấy UI/DioramaStage")
		return

	GameState.set_page(3)
	for i in 20:
		await get_tree().process_frame
	await _capture("00_truoc_khi_lat")

	await _sweep("toi", func(): diorama.flip_page(FLIP_SECONDS))
	for i in 30:
		await get_tree().process_frame

	if diorama.has_method("flip_page_back"):
		await _sweep("lui", func(): diorama.flip_page_back(FLIP_SECONDS))


## Chụp lần lượt các mốc trong một lần lật, canh theo đồng hồ thật.
func _sweep(tag: String, start: Callable) -> void:
	var t0 := Time.get_ticks_msec()
	start.call()
	for ratio in SHOT_RATIOS:
		var due := t0 + int(ratio * FLIP_SECONDS * 1000.0)
		while Time.get_ticks_msec() < due:
			await get_tree().process_frame
		await _capture("%s_%03d" % [tag, int(round(ratio * 100.0))])
	while Time.get_ticks_msec() < t0 + int(FLIP_SECONDS * 1000.0) + 250:
		await get_tree().process_frame
	await _capture("%s_ket_thuc" % tag)


func _capture(shot_name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [_out_dir, shot_name]
	img.save_png(path)
	print("CHỤP: ", path)
