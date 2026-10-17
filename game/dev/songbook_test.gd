extends SceneTree

const Songbook = preload("res://game/songbook.gd")
const Notes = preload("res://game/notes.gd")

func _init() -> void:
	print("=== KIỂM THỬ THƯ VIỆN BÀI HÁT SONGBOOK ===")
	var total_songs := Songbook.count()
	print("Tổng số bài hát: %d (Kỳ vọng: 15)" % total_songs)
	assert(total_songs == 15, "Phải có đúng 15 bài hát (3 chương x 5 bài)!")

	var all_ok := true
	for i in range(total_songs):
		var song := Songbook.get_song(i)
		var s_id: String = song.get("id", "")
		var title: String = song.get("title", "")
		var phrases_cnt := Songbook.phrase_count(i)
		var bgm_path: String = song.get("bgm_path", "")
		
		# Kiểm tra file audio tồn tại
		var file_exists := FileAccess.file_exists(bgm_path)
		print("  [%s] %d. %s (%s) - %d câu - Audio: %s" % [
			"OK" if file_exists else "THIẾU AUDIO",
			i + 1,
			title,
			s_id,
			phrases_cnt,
			bgm_path
		])
		if not file_exists:
			all_ok = false
			
		# Kiểm tra chuỗi nốt từng câu
		for p in range(phrases_cnt):
			var seq := Songbook.get_phrase_sequence(i, p)
			assert(seq.size() > 0, "Câu %d của bài %s không có nốt!" % [p, s_id])
			for note_idx in seq:
				assert(Notes.is_valid(note_idx), "Chỉ số nốt %d trong bài %s không hợp lệ!" % [note_idx, s_id])

	if all_ok:
		print("===> TẤT CẢ 15 BÀI HÁT VÀ TỆP ÂM THANH ĐỀU CHUẨN XÁC 100%!")
	else:
		print("===> CẢNH BÁO: Có tệp âm thanh chưa tìm thấy!")
	quit()
