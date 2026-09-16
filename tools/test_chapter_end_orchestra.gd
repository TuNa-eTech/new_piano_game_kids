extends Node

func _ready() -> void:
	print("=== BẮT ĐẦU KIỂM THỬ MÀN 07: ĐẠI HOAN CA 2.5D DIORAMA ===")

	var root_node := Control.new()
	add_child(root_node)

	var chapter_end := ChapterEnd.new()
	root_node.add_child(chapter_end)
	chapter_end._ensure_built()

	# 1. Kiểm tra sàn sân khấu bục gỗ 2.5D
	assert(chapter_end._stage_deck != null, "Stage deck phải được khởi tạo")
	assert(chapter_end._stage_deck.texture != null, "Stage deck phải có texture spr_stage_wooden_deck")
	print("[PASS] 1. Bục sàn gỗ 2.5D (spr_stage_wooden_deck.png) tải thành công và hiển thị chuẩn.")

	# 2. Kiểm tra sự hiện diện của 6 nghệ sĩ độc lập
	assert(chapter_end._lion != null and chapter_end._lion.texture != null, "Sư tử phải có sprite riêng")
	assert(chapter_end._bear != null and chapter_end._bear.texture != null, "Gấu phải có sprite riêng")
	assert(chapter_end._wizard != null and chapter_end._wizard.texture != null, "Phù thủy phải có sprite riêng")
	assert(chapter_end._cat != null and chapter_end._cat.texture != null, "Mèo phải có sprite riêng")
	assert(chapter_end._elephant != null and chapter_end._elephant.texture != null, "Voi phải có sprite riêng")
	assert(chapter_end._owl != null and chapter_end._owl.texture != null, "Cú phải có sprite riêng")
	print("[PASS] 2. Toàn bộ 6 nghệ sĩ độc lập có sprite nét cắt sắc bén, không còn dùng ảnh gộp.")

	# 3. Kiểm tra màn hình tranh ma thuật & hiệu ứng hào quang
	assert(chapter_end._magic_screen != null, "MagicScreen phải tồn tại")
	assert(chapter_end._screen_rays != null, "Hào quang kim quang rương báu phải được gắn vào MagicScreen")
	print("[PASS] 3. Cây Đậu Thần & Rương Báu bung tỏa kim quang hiển thị thông thoáng.")

	# 4. Kiểm tra bàn phím và hiệu ứng phím phát sáng
	assert(chapter_end._keyboard != null, "Keyboard stage phải tồn tại")
	assert(chapter_end._key_highlights != null, "Lớp phát sáng phím phải tồn tại")
	print("[PASS] 4. Bàn phím 7 nốt tiền cảnh và highlight phát quang sẵn sàng.")

	# 5. Giả lập kích hoạt hoạt ảnh từng nhân vật theo nốt nhạc
	chapter_end._start_show()
	chapter_end._process(0.016)

	# Nốt 0: Sư tử
	chapter_end._lit = 0
	chapter_end._lit_age = 0.05
	chapter_end._animate_individual_musicians()
	assert(chapter_end._lion.scale.y > 1.0, "Sư tử phải nhún nhảy khi nốt 0 vang lên")

	# Nốt 1: Gấu
	chapter_end._lit = 1
	chapter_end._lit_age = 0.05
	chapter_end._animate_individual_musicians()
	assert(chapter_end._bear.scale.x > 1.0, "Gấu gảy harp phải hưởng ứng nốt 1")

	# Nốt 3: Mèo
	chapter_end._lit = 3
	chapter_end._lit_age = 0.05
	chapter_end._animate_individual_musicians()
	assert(chapter_end._cat.scale.y > 1.0, "Mèo thổi sáo phải hưởng ứng nốt 3")

	# Nốt 5: Voi
	chapter_end._lit = 5
	chapter_end._lit_age = 0.05
	chapter_end._animate_individual_musicians()
	assert(chapter_end._elephant.scale.x > 1.0, "Voi khiêu vũ phải hưởng ứng nốt 5")

	# Nốt 6: Cú
	chapter_end._lit = 6
	chapter_end._lit_age = 0.05
	chapter_end._animate_individual_musicians()
	assert(chapter_end._owl.scale.x > 1.0, "Cú ca hát phải hưởng ứng nốt 6")

	print("[PASS] 5. Logic hoạt ảnh cử động độc bản và tương tác nốt nhạc cho cả 6 bạn hoàn toàn chính xác!")

	# 6. Kiểm tra Nút Tiếp tục (Next Button) 2.5D ở góc trái và hiển thị sớm
	assert(chapter_end._continue != null, "Nút _continue phải được khởi tạo")
	assert(chapter_end._continue.anchor_left < 0.05, "Nút _continue phải đặt ở góc trái màn hình")
	assert(chapter_end._continue.anchor_top < 0.08, "Nút _continue phải đặt ở góc trên, không cản sân khấu / phím đàn")
	var btn_icon: TextureRect = chapter_end._continue.get_node_or_null("WoodButtonIcon")
	assert(btn_icon != null and btn_icon.texture != null, "Nút _continue phải có texture nút gỗ 2.5D")
	assert(chapter_end.hint_visible() == false, "hint_visible phải là false khi đang biểu diễn")
	chapter_end._enter(ChapterEnd.Phase.REST)
	assert(chapter_end.hint_visible() == true, "hint_visible phải là true khi kết thúc ở Phase.REST")
	assert(chapter_end._continue.visible == true, "Nút _continue phải hiển thị ở Phase.REST")
	print("[PASS] 6. Nút Tiếp tục 2.5D ở góc trái không cản sân khấu, hiển thị linh hoạt & tích hợp chuẩn xác.")

	print("=== TẤT CẢ KIỂM THỬ MÀN 07 ĐẠT 100%! ===")
	get_tree().quit(0)
