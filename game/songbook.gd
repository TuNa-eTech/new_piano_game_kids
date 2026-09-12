class_name Songbook
extends RefCounted
## Thư viện 10 Bài Hát Thiếu Nhi Phổ Biến Nhất (Songbook).
##
## Cung cấp siêu dữ liệu, giai điệu chuyển thể cho 7 phím ngũ cung (C4-D4-E4-G4-A4-C5-D5),
## lời bài hát từng nốt, vòng hợp âm đệm và đường dẫn audio cho vòng gọi–đáp.
##
## Ánh xạ chỉ số phím trong Notes.TABLE:
##   0=C4 Sư tử · 1=D4 Gấu · 2=E4 Thỏ · 3=G4 Mèo · 4=A4 Khỉ · 5=C5 Voi · 6=D5 Cú

static var SONGS: Array[Dictionary] = [
	# ------------------------------------------------------------------ 1. Baby Shark
	{
		"id": "baby_shark",
		"title": "Baby Shark",
		"vietnamese_title": "Cá Mập Con",
		"age_range": "1–6 tuổi",
		"bpm": 85,
		"bgm_path": "res://assets/audio/songbook/bgm_baby_shark.ogg",
		"color": Color("#3877B5"),
		"chords": ["C", "C", "Am", "F"],
		"description": "Điệu nhảy lặp lại vui tươi, câu hát ngắn gọn cực kỳ bắt tai",
		"phrases": [
			{
				"name": "Cá Mập Con (Câu 1)",
				"notes": PackedInt32Array([1, 2, 3, 3, 3, 3, 3, 3]),
				"solfege": ["Re", "Mi", "Sol", "Sol", "Sol", "Sol", "Sol", "Sol"],
				"lyrics": "Ba-by shark, doo-doo, doo-doo, doo-doo"
			},
			{
				"name": "Cá Mập Mẹ (Câu 2)",
				"notes": PackedInt32Array([1, 2, 3, 3, 3, 3, 3, 3]),
				"solfege": ["Re", "Mi", "Sol", "Sol", "Sol", "Sol", "Sol", "Sol"],
				"lyrics": "Mom-my shark, doo-doo, doo-doo, doo-doo"
			},
			{
				"name": "Cá Mập Bố (Câu 3)",
				"notes": PackedInt32Array([1, 2, 3, 3, 3, 3, 3, 3]),
				"solfege": ["Re", "Mi", "Sol", "Sol", "Sol", "Sol", "Sol", "Sol"],
				"lyrics": "Dad-dy shark, doo-doo, doo-doo, doo-doo"
			},
			{
				"name": "Gia Đình Cá Mập (Kết)",
				"notes": PackedInt32Array([3, 3, 2]),
				"solfege": ["Sol", "Sol", "Mi"],
				"lyrics": "Ba-by shark!"
			}
		]
	},

	# ------------------------------------------------------------------ 2. Wheels on the Bus
	{
		"id": "wheels_on_the_bus",
		"title": "The Wheels on the Bus",
		"vietnamese_title": "Bánh Xe Buýt Lăn Tròn",
		"age_range": "1–5 tuổi",
		"bpm": 80,
		"bgm_path": "res://assets/audio/songbook/bgm_wheels_on_the_bus.ogg",
		"color": Color("#E08A2E"),
		"chords": ["C", "G", "C", "C"],
		"description": "Chủ đề phương tiện giao thông, tương tác vận động sôi nổi",
		"phrases": [
			{
				"name": "Bánh xe lăn tròn (Câu 1)",
				"notes": PackedInt32Array([0, 2, 2, 2, 2, 4, 5, 4, 3]),
				"solfege": ["Do", "Mi", "Mi", "Mi", "Mi", "La", "Do5", "La", "Sol"],
				"lyrics": "The wheels on the bus go round and round"
			},
			{
				"name": "Lăn suốt ngày (Câu 2)",
				"notes": PackedInt32Array([1, 1, 1, 0, 0, 0]),
				"solfege": ["Re", "Re", "Re", "Do", "Do", "Do"],
				"lyrics": "Round and round, round and round"
			},
			{
				"name": "Bánh xe lăn tròn (Câu 3)",
				"notes": PackedInt32Array([0, 2, 2, 2, 2, 4, 5, 4, 3]),
				"solfege": ["Do", "Mi", "Mi", "Mi", "Mi", "La", "Do5", "La", "Sol"],
				"lyrics": "The wheels on the bus go round and round"
			},
			{
				"name": "Khắp phố phường (Câu 4)",
				"notes": PackedInt32Array([1, 3, 0]),
				"solfege": ["Re", "Sol", "Do"],
				"lyrics": "All through the town"
			}
		]
	},

	# ------------------------------------------------------------------ 3. Johny Johny Yes Papa
	{
		"id": "johny_johny",
		"title": "Johny Johny Yes Papa",
		"vietnamese_title": "Bé Johny Vâng Lời Bố",
		"age_range": "1–5 tuổi",
		"bpm": 76,
		"bgm_path": "res://assets/audio/songbook/bgm_johny_johny.ogg",
		"color": Color("#E0644F"),
		"chords": ["C", "G", "C", "G"],
		"description": "Cấu trúc đối đáp gọi–trả lời dí dỏm, rất tự nhiên cho game",
		"phrases": [
			{
				"name": "Bố gọi: Johny? (Câu 1)",
				"notes": PackedInt32Array([0, 0, 2, 3]),
				"solfege": ["Do", "Do", "Mi", "Sol"],
				"lyrics": "Joh-ny, Joh-ny?"
			},
			{
				"name": "Bé thưa: Yes, Papa! (Câu 2)",
				"notes": PackedInt32Array([2, 1, 0]),
				"solfege": ["Mi", "Re", "Do"],
				"lyrics": "Yes, Pa-pa!"
			},
			{
				"name": "Ăn đường à? (Câu 3)",
				"notes": PackedInt32Array([0, 0, 2, 3]),
				"solfege": ["Do", "Do", "Mi", "Sol"],
				"lyrics": "Eat-ing su-gar?"
			},
			{
				"name": "Dạ không ạ! (Câu 4)",
				"notes": PackedInt32Array([2, 1, 0]),
				"solfege": ["Mi", "Re", "Do"],
				"lyrics": "No, Pa-pa!"
			},
			{
				"name": "Há miệng ra nào! (Câu 5)",
				"notes": PackedInt32Array([3, 3, 2, 0]),
				"solfege": ["Sol", "Sol", "Mi", "Do"],
				"lyrics": "O-pen your mouth!"
			},
			{
				"name": "Ha ha ha! (Câu 6)",
				"notes": PackedInt32Array([1, 1, 0]),
				"solfege": ["Re", "Re", "Do"],
				"lyrics": "Ha, ha, ha!"
			}
		]
	},

	# ------------------------------------------------------------------ 4. Twinkle Twinkle Little Star
	{
		"id": "twinkle_twinkle",
		"title": "Twinkle Twinkle Little Star",
		"vietnamese_title": "Ngôi Sao Nhỏ Lấp Lánh",
		"age_range": "0–5 tuổi",
		"bpm": 68,
		"bgm_path": "res://assets/audio/songbook/bgm_twinkle_twinkle.ogg",
		"color": Color("#C7A017"),
		"chords": ["C", "F", "C", "G"],
		"description": "Giai điệu hát ru kinh điển, nốt khởi đầu mẫu mực cho học đàn",
		"phrases": [
			{
				"name": "Ngôi sao lấp lánh (Câu 1)",
				"notes": PackedInt32Array([0, 0, 3, 3, 4, 4, 3]),
				"solfege": ["Do", "Do", "Sol", "Sol", "La", "La", "Sol"],
				"lyrics": "Twin-kle, twin-kle, lit-tle star"
			},
			{
				"name": "Bạn là ai thế (Câu 2)",
				"notes": PackedInt32Array([3, 3, 2, 2, 1, 1, 0]),
				"solfege": ["Sol", "Sol", "Mi", "Mi", "Re", "Re", "Do"],
				"lyrics": "How I won-der what you are"
			},
			{
				"name": "Trên cao vời vợi (Câu 3)",
				"notes": PackedInt32Array([3, 3, 2, 2, 1, 1, 0]),
				"solfege": ["Sol", "Sol", "Mi", "Mi", "Re", "Re", "Do"],
				"lyrics": "Up a-bove the world so high"
			},
			{
				"name": "Như viên kim cương (Câu 4)",
				"notes": PackedInt32Array([0, 0, 3, 3, 4, 4, 3]),
				"solfege": ["Do", "Do", "Sol", "Sol", "La", "La", "Sol"],
				"lyrics": "Like a dia-mond in the sky"
			}
		]
	},

	# ------------------------------------------------------------------ 5. If You're Happy and You Know It
	{
		"id": "if_youre_happy",
		"title": "If You're Happy and You Know It",
		"vietnamese_title": "Nếu Bạn Đang Thấy Vui",
		"age_range": "2–6 tuổi",
		"bpm": 84,
		"bgm_path": "res://assets/audio/songbook/bgm_if_youre_happy.ogg",
		"color": Color("#3F9455"),
		"chords": ["C", "G", "C", "G"],
		"description": "Khuyến khích vận động vỗ tay, dậm chân và cười vui",
		"phrases": [
			{
				"name": "Vỗ tay nào (Câu 1)",
				"notes": PackedInt32Array([0, 0, 2, 2, 2, 2, 1, 2, 3]),
				"solfege": ["Do", "Do", "Mi", "Mi", "Mi", "Mi", "Re", "Mi", "Sol"],
				"lyrics": "If you're hap-py and you know it clap your hands"
			},
			{
				"name": "Vỗ tay nào (Câu 2)",
				"notes": PackedInt32Array([1, 1, 3, 3, 3, 3, 2, 3, 4]),
				"solfege": ["Re", "Re", "Sol", "Sol", "Sol", "Sol", "Mi", "Sol", "La"],
				"lyrics": "If you're hap-py and you know it clap your hands"
			},
			{
				"name": "Cùng sẻ chia niềm vui (Câu 3)",
				"notes": PackedInt32Array([4, 4, 5, 5, 5, 5, 4, 3, 2]),
				"solfege": ["La", "La", "Do5", "Do5", "Do5", "Do5", "La", "Sol", "Mi"],
				"lyrics": "If you're hap-py and you real-ly want to show it"
			},
			{
				"name": "Vỗ tay vang lừng (Câu 4)",
				"notes": PackedInt32Array([1, 1, 2, 2, 1, 0]),
				"solfege": ["Re", "Re", "Mi", "Mi", "Re", "Do"],
				"lyrics": "If you're hap-py, clap your hands"
			}
		]
	},

	# ------------------------------------------------------------------ 6. Old MacDonald Had a Farm
	{
		"id": "old_macdonald",
		"title": "Old MacDonald Had a Farm",
		"vietnamese_title": "Nông Trại Bác MacDonald",
		"age_range": "2–6 tuổi",
		"bpm": 82,
		"bgm_path": "res://assets/audio/songbook/bgm_old_macdonald.ogg",
		"color": Color("#D8619A"),
		"chords": ["C", "F", "C", "G"],
		"description": "Học âm thanh và tiếng kêu muông thú nông trại",
		"phrases": [
			{
				"name": "Nông trại bác MacDonald (Câu 1)",
				"notes": PackedInt32Array([0, 0, 0, 3, 4, 4, 3]),
				"solfege": ["Do", "Do", "Do", "Sol", "La", "La", "Sol"],
				"lyrics": "Old Mac-Don-ald had a farm"
			},
			{
				"name": "E-I-E-I-O (Câu 2)",
				"notes": PackedInt32Array([2, 2, 1, 1, 0]),
				"solfege": ["Mi", "Mi", "Re", "Re", "Do"],
				"lyrics": "E - I - E - I - O!"
			},
			{
				"name": "Và trên trang trại có chú vịt (Câu 3)",
				"notes": PackedInt32Array([0, 0, 0, 3, 4, 4, 3]),
				"solfege": ["Do", "Do", "Do", "Sol", "La", "La", "Sol"],
				"lyrics": "And on that farm he had a duck"
			},
			{
				"name": "E-I-E-I-O (Câu 4)",
				"notes": PackedInt32Array([2, 2, 1, 1, 0]),
				"solfege": ["Mi", "Mi", "Re", "Re", "Do"],
				"lyrics": "E - I - E - I - O!"
			}
		]
	},

	# ------------------------------------------------------------------ 7. ABC Song
	{
		"id": "abc_song",
		"title": "ABC Song",
		"vietnamese_title": "Bài Ca Bảng Chữ Cái",
		"age_range": "2–6 tuổi",
		"bpm": 70,
		"bgm_path": "res://assets/audio/songbook/bgm_abc_song.ogg",
		"color": Color("#7C5CC4"),
		"chords": ["C", "F", "C", "G"],
		"description": "Học bảng chữ cái tiếng Anh bằng giai điệu thân thuộc",
		"phrases": [
			{
				"name": "A B C D E F G (Câu 1)",
				"notes": PackedInt32Array([0, 0, 3, 3, 4, 4, 3]),
				"solfege": ["Do", "Do", "Sol", "Sol", "La", "La", "Sol"],
				"lyrics": "A - B - C - D - E - F - G"
			},
			{
				"name": "H I J K L M N (Câu 2)",
				"notes": PackedInt32Array([3, 3, 2, 2, 1, 1, 0]),
				"solfege": ["Sol", "Sol", "Mi", "Mi", "Re", "Re", "Do"],
				"lyrics": "H - I - J - K - L - M - N - O - P"
			},
			{
				"name": "Q R S và T U V (Câu 3)",
				"notes": PackedInt32Array([3, 3, 2, 2, 1, 1, 0]),
				"solfege": ["Sol", "Sol", "Mi", "Mi", "Re", "Re", "Do"],
				"lyrics": "Q - R - S and T - U - V"
			},
			{
				"name": "Giờ em đã thuộc ABC (Câu 4)",
				"notes": PackedInt32Array([0, 0, 3, 3, 4, 4, 3]),
				"solfege": ["Do", "Do", "Sol", "Sol", "La", "La", "Sol"],
				"lyrics": "Now I know my A - B - C"
			}
		]
	},

	# ------------------------------------------------------------------ 8. Baa Baa Black Sheep
	{
		"id": "baa_baa_black_sheep",
		"title": "Baa Baa Black Sheep",
		"vietnamese_title": "Chú Cừu Đen Ngoan Ngoãn",
		"age_range": "1–5 tuổi",
		"bpm": 72,
		"bgm_path": "res://assets/audio/songbook/bgm_baa_baa_black_sheep.ogg",
		"color": Color("#4A7C59"),
		"chords": ["C", "F", "C", "G"],
		"description": "Giai điệu đồng dao nhẹ nhàng về chú cừu và ba bao len",
		"phrases": [
			{
				"name": "Cừu đen có len không? (Câu 1)",
				"notes": PackedInt32Array([0, 0, 3, 3, 4, 4, 4, 4, 3]),
				"solfege": ["Do", "Do", "Sol", "Sol", "La", "La", "La", "La", "Sol"],
				"lyrics": "Baa baa black sheep have you an-y wool?"
			},
			{
				"name": "Ba bao len đầy (Câu 2)",
				"notes": PackedInt32Array([3, 3, 2, 2, 1, 1, 0]),
				"solfege": ["Sol", "Sol", "Mi", "Mi", "Re", "Re", "Do"],
				"lyrics": "Yes sir, yes sir, three bags full"
			},
			{
				"name": "Một bao cho chủ (Câu 3)",
				"notes": PackedInt32Array([3, 3, 3, 2, 2, 2, 1, 1, 0]),
				"solfege": ["Sol", "Sol", "Sol", "Mi", "Mi", "Mi", "Re", "Re", "Do"],
				"lyrics": "One for the mas-ter, one for the dame"
			},
			{
				"name": "Và một cho em nhỏ (Câu 4)",
				"notes": PackedInt32Array([3, 3, 2, 2, 1, 1, 0]),
				"solfege": ["Sol", "Sol", "Mi", "Mi", "Re", "Re", "Do"],
				"lyrics": "And one for the lit-tle boy down the lane"
			}
		]
	},

	# ------------------------------------------------------------------ 9. Five Little Monkeys
	{
		"id": "five_little_monkeys",
		"title": "Five Little Monkeys",
		"vietnamese_title": "Năm Chú Khỉ Nhảy Trên Giường",
		"age_range": "2–6 tuổi",
		"bpm": 80,
		"bgm_path": "res://assets/audio/songbook/bgm_five_little_monkeys.ogg",
		"color": Color("#8B5E3C"),
		"chords": ["C", "G", "C", "G"],
		"description": "Bài hát đếm số sinh động với câu chuyện chú khỉ tinh nghịch",
		"phrases": [
			{
				"name": "Năm chú khỉ nhảy nhót (Câu 1)",
				"notes": PackedInt32Array([2, 2, 2, 0, 2, 2, 3]),
				"solfege": ["Mi", "Mi", "Mi", "Do", "Mi", "Mi", "Sol"],
				"lyrics": "Five lit-tle mon-keys jump-ing on the bed"
			},
			{
				"name": "Một chú ngã đau đầu (Câu 2)",
				"notes": PackedInt32Array([2, 2, 2, 1, 0, 1, 2, 0]),
				"solfege": ["Mi", "Mi", "Mi", "Re", "Do", "Re", "Mi", "Do"],
				"lyrics": "One fell off and bumped his head"
			},
			{
				"name": "Mẹ gọi bác sĩ ngay (Câu 3)",
				"notes": PackedInt32Array([3, 2, 3, 2, 3, 3, 2]),
				"solfege": ["Sol", "Mi", "Sol", "Mi", "Sol", "Sol", "Mi"],
				"lyrics": "Ma-ma called the doc-tor and doc-tor said:"
			},
			{
				"name": "Không nhảy trên giường nữa! (Câu 4)",
				"notes": PackedInt32Array([2, 2, 1, 1, 1, 2, 0]),
				"solfege": ["Mi", "Mi", "Re", "Re", "Re", "Mi", "Do"],
				"lyrics": "No more mon-keys jump-ing on the bed!"
			}
		]
	},

	# ------------------------------------------------------------------ 10. Heads, Shoulders, Knees and Toes
	{
		"id": "heads_shoulders",
		"title": "Heads, Shoulders, Knees and Toes",
		"vietnamese_title": "Đầu, Vai, Đầu Gối, Ngón Chân",
		"age_range": "2–6 tuổi",
		"bpm": 86,
		"bgm_path": "res://assets/audio/songbook/bgm_heads_shoulders.ogg",
		"color": Color("#5E60CE"),
		"chords": ["C", "G", "C", "G"],
		"description": "Học các bộ phận cơ thể thông qua vận động chạm tay",
		"phrases": [
			{
				"name": "Đầu, vai, gối, chân (Câu 1)",
				"notes": PackedInt32Array([3, 3, 2, 0, 2, 3, 2, 0]),
				"solfege": ["Sol", "Sol", "Mi", "Do", "Mi", "Sol", "Mi", "Do"],
				"lyrics": "Head, shoul-ders, knees and toes, knees and toes"
			},
			{
				"name": "Đầu, vai, gối, chân (Câu 2)",
				"notes": PackedInt32Array([3, 3, 2, 0, 2, 3, 2, 0]),
				"solfege": ["Sol", "Sol", "Mi", "Do", "Mi", "Sol", "Mi", "Do"],
				"lyrics": "Head, shoul-ders, knees and toes, knees and toes"
			},
			{
				"name": "Và mắt, tai, miệng, mũi (Câu 3)",
				"notes": PackedInt32Array([3, 4, 5, 4, 3, 2, 1]),
				"solfege": ["Sol", "La", "Do5", "La", "Sol", "Mi", "Re"],
				"lyrics": "And eyes and ears and mouth and nose"
			},
			{
				"name": "Đầu, vai, gối, chân (Câu 4)",
				"notes": PackedInt32Array([3, 3, 2, 0, 2, 3, 2, 0]),
				"solfege": ["Sol", "Sol", "Mi", "Do", "Mi", "Sol", "Mi", "Do"],
				"lyrics": "Head, shoul-ders, knees and toes, knees and toes"
			}
		]
	}
]


static func count() -> int:
	return SONGS.size()


static func is_valid(index: int) -> bool:
	return index >= 0 and index < SONGS.size()


static func get_song(index: int) -> Dictionary:
	if not is_valid(index):
		return {}
	return SONGS[index]


static func find_by_id(id_str: String) -> Dictionary:
	for song in SONGS:
		if song["id"] == id_str:
			return song
	return {}


static func phrase_count(song_index: int) -> int:
	if not is_valid(song_index):
		return 0
	return (SONGS[song_index]["phrases"] as Array).size()


static func get_phrase(song_index: int, phrase_index: int) -> Dictionary:
	if not is_valid(song_index):
		return {}
	var phrases: Array = SONGS[song_index]["phrases"]
	var p_idx := clampi(phrase_index, 0, phrases.size() - 1)
	return phrases[p_idx]


static func get_phrase_sequence(song_index: int, phrase_index: int) -> PackedInt32Array:
	var phrase := get_phrase(song_index, phrase_index)
	if phrase.is_empty():
		return PackedInt32Array()
	return phrase.get("notes", PackedInt32Array())
