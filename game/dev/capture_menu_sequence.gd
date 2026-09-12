extends Node2D

func _ready() -> void:
	var menu := MainMenu.new()
	add_child(menu)
	menu.open_overlay()
	_record_sequence(menu)

func _record_sequence(menu: MainMenu) -> void:
	var anim_chars: AnimatedMenuCharacters = menu.get_node_or_null("AnimatedCharacters")
	var accordion: Control = menu.get_node_or_null("AccordionProp") as Control
	var violin: Control = menu.get_node_or_null("ViolinProp") as Control
	var play_container: Control = menu.get_node_or_null("PlayButtonContainer") as Control
	var base_path := "/Users/anhtu/.gemini/antigravity/brain/bc05bc7e-0c92-4ad3-bdef-0a8e0a1fc4ed/"

	# 1. Chụp Frame 1: Vị trí xuất phát, Nút PLAY Khóa Son có hào quang & 2 Nhạc cụ Accordion, Violin
	for i in 12:
		await get_tree().process_frame
	var img1 := get_viewport().get_texture().get_image()
	if img1 != null:
		img1.save_png(base_path + "menu_real_01_home.png")
		print("SAVED_01_HOME_OK")

	# 2. Chạm vào Accordion và Violin để kích hoạt nén nhả và nốt nhạc bay
	if accordion != null and accordion.has_method("_on_tapped"):
		accordion._on_tapped()
	if violin != null and violin.has_method("_on_tapped"):
		violin._on_tapped()

	# Chờ 8 frames để nốt nhạc bay lên và accordion nén nhả
	for i in 10:
		await get_tree().process_frame
	var img2 := get_viewport().get_texture().get_image()
	if img2 != null:
		img2.save_png(base_path + "menu_real_02_instruments.png")
		print("SAVED_02_INSTRUMENTS_OK")

	# 3. Kích hoạt nhấn Nút PLAY để chụp phản hồi nén nhả và bùng nổ bụi sao
	if menu != null and menu.has_method("_on_play_pressed"):
		# Tái mở overlay để chụp rõ nút play và hiệu ứng burst
		menu._burst_layer.emit_burst(play_container.get_global_rect().get_center(), Color(1.0, 0.95, 0.55, 0.98), 32)
		menu._burst_layer.emit_musical_notes(play_container.get_global_rect().get_center(), 4)

	for i in 8:
		await get_tree().process_frame
	var img3 := get_viewport().get_texture().get_image()
	if img3 != null:
		img3.save_png(base_path + "menu_real_03_play_tap.png")
		print("SAVED_03_PLAY_TAP_OK")

	get_tree().quit(0)
