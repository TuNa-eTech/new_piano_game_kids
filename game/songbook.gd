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
		"voiceguide_path": "res://assets/audio/songbook/voiceguide_baby_shark.ogg",
		"rhythm": "bounce_offbeat",
		"motif": "doo-doo marimba",
		"hook_vi": "Nhún doo-doo cùng gia đình Cá Mập",
		"chords": ["C", "C", "Am", "F"],
		"chords_full": ["C", "C", "Am", "F"],
		"description": "Điệu nhảy lặp lại vui tươi, câu hát ngắn gọn cực kỳ bắt tai",
		"pet_name": "Bé Cá Mập",
		"pet_emoji": "🦈",
		"pet_id": "shark",
		"story_intro": "Cùng Leo lặn xuống biển xanh ngọc, gặp gỡ gia đình Cá Mập và đánh thức mầm cây san hô!",
		"scene_cue": "Mầm cây thần cựa mình nảy chồi giữa đại dương lấp lánh bong bóng ngọc",
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
		"voiceguide_path": "res://assets/audio/songbook/voiceguide_wheels_on_the_bus.ogg",
		"rhythm": "oom_pah",
		"motif": "bánh lăn đi lên + chuông ting-ting",
		"hook_vi": "Bánh xe lăn tròn, chuông xe ting-ting",
		"chords_full": ["C", "G", "F", "C"],
		"color": Color("#E08A2E"),
		"chords": ["C", "G", "F", "C"],
		"description": "Chủ đề phương tiện giao thông, tương tác vận động sôi nổi",
		"pet_name": "Bác Gấu Lái Xe",
		"pet_emoji": "🐻",
		"pet_id": "bear",
		"story_intro": "Bác Gấu nổ máy xe buýt vàng, đưa các bạn nhỏ băng qua khu rừng âm nhạc!",
		"scene_cue": "Cây đậu thần hóa thành trạm dừng xe buýt đầy hoa và chuông gió reo",
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
		"voiceguide_path": "res://assets/audio/songbook/voiceguide_johny_johny.ogg",
		"rhythm": "qa_musicbox",
		"motif": "hỏi-đáp music-box E5-D5",
		"hook_vi": "Bố hỏi, bé thưa cùng Mèo Con",
		"chords_full": ["C", "G", "Am", "G"],
		"color": Color("#E0644F"),
		"chords": ["C", "G", "Am", "G"],
		"description": "Cấu trúc đối đáp gọi–trả lời dí dỏm, rất tự nhiên cho game",
		"pet_name": "Mèo Con Tinh Nghịch",
		"pet_emoji": "🐱",
		"pet_id": "cat",
		"story_intro": "Mèo Con trèo lên cây đậu ăn vụng kẹo ngọt rồi cười xòa Ha Ha Ha!",
		"scene_cue": "Những chiếc lá đậu thần nở ra kẹo mút và quả dâu tây ngọt ngào",
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
		"voiceguide_path": "res://assets/audio/songbook/voiceguide_twinkle_twinkle.ogg",
		"rhythm": "lullaby_long",
		"motif": "sao băng celesta vút lên",
		"hook_vi": "Sao lấp lánh cùng Cú Mèo đêm",
		"chords_full": ["C", "F", "Dm", "G"],
		"color": Color("#C7A017"),
		"chords": ["C", "F", "Dm", "G"],
		"description": "Giai điệu hát ru kinh điển, nốt khởi đầu mẫu mực cho học đàn",
		"pet_name": "Cú Mèo Sao Đêm",
		"pet_emoji": "🦉",
		"pet_id": "owl",
		"story_intro": "Cú Mèo chớp mắt thông thái, dẫn lối cho cây đậu thần vươn chạm ngàn sao lấp lánh!",
		"scene_cue": "Đỉnh cây đậu thần chạm tới mây xanh, đón những vì sao kim cương rơi xuống",
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
		"voiceguide_path": "res://assets/audio/songbook/voiceguide_if_youre_happy.ogg",
		"rhythm": "clap_2_4",
		"motif": "vỗ tay gỗ phách 2-4",
		"hook_vi": "Vỗ tay, dậm chân cùng Thỏ Trắng",
		"chords_full": ["C", "G", "Em", "G"],
		"color": Color("#3F9455"),
		"chords": ["C", "G", "Em", "G"],
		"description": "Khuyến khích vận động vỗ tay, dậm chân và cười vui",
		"pet_name": "Thỏ Trắng Tinh Anh",
		"pet_emoji": "🐰",
		"pet_id": "rabbit",
		"story_intro": "Thỏ Trắng rung rinh đôi tai, vỗ tay và rủ bé cùng nhún nhảy theo điệu nhạc!",
		"scene_cue": "Các nốt nhạc bật nảy như những quả bóng sắc màu quanh thảm cỏ xanh",
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
		"voiceguide_path": "res://assets/audio/songbook/voiceguide_old_macdonald.ogg",
		"rhythm": "folk_pick",
		"motif": "guitar đồng quê đi xuống",
		"hook_vi": "Về nông trại nghe thú kêu",
		"chords_full": ["C", "F", "Dm", "G"],
		"color": Color("#D8619A"),
		"chords": ["C", "F", "Dm", "G"],
		"description": "Học âm thanh và tiếng kêu muông thú nông trại",
		"pet_name": "Bác Bò Sữa & Vịt Vàng",
		"pet_emoji": "🐮",
		"pet_id": "cow",
		"story_intro": "Chào mừng bé đến nông trại rộn ràng của Bác Bò Sữa và Vịt Vàng!",
		"scene_cue": "Cây đậu thần nở hoa vàng rực rỡ và những chiếc chuông gió nông trại",
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
		"voiceguide_path": "res://assets/audio/songbook/voiceguide_abc_song.ogg",
		"rhythm": "learn_slow",
		"motif": "chuông học chữ đi lên",
		"hook_vi": "Đoàn tàu chữ cái cùng Sư Tử Vua",
		"chords_full": ["C", "Am", "F", "G"],
		"color": Color("#7C5CC4"),
		"chords": ["C", "Am", "F", "G"],
		"description": "Học bảng chữ cái tiếng Anh bằng giai điệu thân thuộc",
		"pet_name": "Sư Tử Vua",
		"pet_emoji": "🦁",
		"pet_id": "lion",
		"story_intro": "Sư Tử Vua uy nghiêm nhưng rất hiền từ, dẫn đầu đoàn tàu chữ cái A-B-C!",
		"scene_cue": "Các quả táo chữ cái trên cành đậu thần rung rinh phát sáng",
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
		"voiceguide_path": "res://assets/audio/songbook/voiceguide_baa_baa_black_sheep.ogg",
		"rhythm": "pastoral_flow",
		"motif": "sáo gỗ lead trôi",
		"hook_vi": "Mây len bồng bềnh cùng Cừu Bông",
		"chords_full": ["C", "Dm", "F", "G"],
		"color": Color("#4A7C59"),
		"chords": ["C", "Dm", "F", "G"],
		"description": "Giai điệu đồng dao nhẹ nhàng về chú cừu và ba bao len",
		"pet_name": "Cừu Bông Trắng Đen",
		"pet_emoji": "🐑",
		"pet_id": "sheep",
		"story_intro": "Chú Cừu Đen mang những cuộn len mềm mại kết thành những đám mây âm nhạc bồng bềnh!",
		"scene_cue": "Mây bông len trắng muốt trôi quanh thân cây đậu thần ấm áp",
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
		"voiceguide_path": "res://assets/audio/songbook/voiceguide_five_little_monkeys.ogg",
		"rhythm": "shuffle_jump",
		"motif": "nhảy tưng marimba + woodblock",
		"hook_vi": "Nhào lộn tưng tưng cùng Khỉ Con",
		"chords_full": ["C", "G", "Am", "G"],
		"color": Color("#8B5E3C"),
		"chords": ["C", "G", "Am", "G"],
		"description": "Bài hát đếm số sinh động với câu chuyện chú khỉ tinh nghịch",
		"pet_name": "Khỉ Con Tinh Nghịch",
		"pet_emoji": "🐵",
		"pet_id": "monkey",
		"story_intro": "Đàn Khỉ Con tinh nghịch đu cành đậu thần nhào lộn làm rơi những quả chuối vàng!",
		"scene_cue": "Các nốt nhạc nảy tưng tưng theo những cú nhào lộn của Khỉ Con",
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
		"voiceguide_path": "res://assets/audio/songbook/voiceguide_heads_shoulders.ogg",
		"rhythm": "motion_8th",
		"motif": "chạm tay đi lên",
		"hook_vi": "Chạm đầu-vai-gối-chân cùng Voi Con",
		"chords_full": ["C", "G", "Am", "G"],
		"color": Color("#5E60CE"),
		"chords": ["C", "G", "Am", "G"],
		"description": "Học các bộ phận cơ thể thông qua vận động chạm tay",
		"pet_name": "Voi Con Đáng Yêu",
		"pet_emoji": "🐘",
		"pet_id": "elephant",
		"story_intro": "Bạn Voi Con dùng vòi lắc lư theo điệu nhảy Đầu - Vai - Gối - Chân cực kỳ vui nhộn!",
		"scene_cue": "Voi Con phun nước vồng cầu vồng rực rỡ và hoa nhạc nở rộ trên cây thần",
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
	},

	# ------------------------------------------------------------------ 11. Ode to Joy (Chương 3 - Bài 1)
	{
		"id": "ode_to_joy",
		"title": "Ode to Joy",
		"vietnamese_title": "Khúc Ca Hân Hoan",
		"age_range": "3–6 tuổi",
		"bpm": 78,
		"bgm_path": "res://assets/audio/songbook/bgm_ode_to_joy.ogg",
		"voiceguide_path": "res://assets/audio/songbook/voiceguide_ode_to_joy.ogg",
		"rhythm": "pastoral_flow",
		"motif": "chuông pha lê celesta",
		"hook_vi": "Ngân vang khúc ca hân hoan cùng Cú Mèo",
		"chords_full": ["C", "G", "Am", "G"],
		"color": Color("#7C5CC4"),
		"chords": ["C", "G", "Am", "G"],
		"description": "Giai điệu cổ điển tươi sáng được chuyển soạn êm dịu trên thang âm ngũ cung",
		"pet_name": "Cú Mèo Thông Thái",
		"pet_emoji": "🦉",
		"pet_id": "owl",
		"story_intro": "Trên đỉnh Lâu Đài Chuông Gió, bác Cú Mèo gõ nhịp chuông pha lê mừng đón bình minh!",
		"scene_cue": "Chuông pha lê tỏa ánh sáng tím vàng lấp lánh khắp tòa lâu đài trên mây",
		"phrases": [
			{
				"name": "Khúc ca mở màn (Câu 1)",
				"notes": PackedInt32Array([2, 2, 3, 4, 4, 3, 2, 1]),
				"solfege": ["Mi", "Mi", "Sol", "La", "La", "Sol", "Mi", "Re"],
				"lyrics": "Joy-ful, joy-ful, sing to-geth-er"
			},
			{
				"name": "Hòa nhịp niềm vui (Câu 2)",
				"notes": PackedInt32Array([0, 0, 1, 2, 2, 1, 1]),
				"solfege": ["Do", "Do", "Re", "Mi", "Mi", "Re", "Re"],
				"lyrics": "Hand in hand beneath the sun"
			},
			{
				"name": "Ngân vang khắp rừng (Câu 3)",
				"notes": PackedInt32Array([2, 2, 3, 4, 4, 3, 2, 1]),
				"solfege": ["Mi", "Mi", "Sol", "La", "La", "Sol", "Mi", "Re"],
				"lyrics": "Ev-ery heart is full of mu-sic"
			},
			{
				"name": "Khúc kết rạng ngời (Câu 4)",
				"notes": PackedInt32Array([0, 0, 1, 2, 1, 0, 0]),
				"solfege": ["Do", "Do", "Re", "Mi", "Re", "Do", "Do"],
				"lyrics": "Shining bright for ev-ery-one!"
			}
		]
	},

	# ------------------------------------------------------------------ 12. Jingle Bells (Chương 3 - Bài 2)
	{
		"id": "jingle_bells",
		"title": "Jingle Bells",
		"vietnamese_title": "Tiếng Chuông Ngân Vang",
		"age_range": "2–6 tuổi",
		"bpm": 84,
		"bgm_path": "res://assets/audio/songbook/bgm_jingle_bells.ogg",
		"voiceguide_path": "res://assets/audio/songbook/voiceguide_jingle_bells.ogg",
		"rhythm": "bounce_offbeat",
		"motif": "chuông bạc leng keng",
		"hook_vi": "Lắc chuông gió leng keng cùng Thỏ Trắng",
		"chords_full": ["C", "F", "C", "G"],
		"color": Color("#4AE5D8"),
		"chords": ["C", "F", "C", "G"],
		"description": "Điệp khúc chuông ngân rộn ràng giúp bé luyện gõ nốt lặp tiết tấu đều đặn",
		"pet_name": "Thỏ Trắng Nhạc Sĩ",
		"pet_emoji": "🐰",
		"pet_id": "rabbit",
		"story_intro": "Gió thổi qua ban công lâu đài làm dàn chuông bạc ngân lên khúc nhạc leng keng vui tai!",
		"scene_cue": "Những bông tuyết ánh sao nhảy múa theo từng tiếng chuông ngân",
		"phrases": [
			{
				"name": "Chuông ngân vang (Câu 1)",
				"notes": PackedInt32Array([2, 2, 2, 2, 2, 2]),
				"solfege": ["Mi", "Mi", "Mi", "Mi", "Mi", "Mi"],
				"lyrics": "Jin-gle bells, jin-gle bells"
			},
			{
				"name": "Ngân vang suốt chặng đường (Câu 2)",
				"notes": PackedInt32Array([2, 3, 0, 1, 2]),
				"solfege": ["Mi", "Sol", "Do", "Re", "Mi"],
				"lyrics": "Jin-gle all the way!"
			},
			{
				"name": "Cùng vui bước (Câu 3)",
				"notes": PackedInt32Array([3, 3, 3, 2, 2, 2]),
				"solfege": ["Sol", "Sol", "Sol", "Mi", "Mi", "Mi"],
				"lyrics": "Oh what fun it is to ride"
			},
			{
				"name": "Hát vang khúc ca (Câu 4)",
				"notes": PackedInt32Array([2, 1, 1, 2, 1, 3]),
				"solfege": ["Mi", "Re", "Re", "Mi", "Re", "Sol"],
				"lyrics": "In a one-horse o-pen sleigh!"
			}
		]
	},

	# ------------------------------------------------------------------ 13. Yankee Doodle (Chương 3 - Bài 3)
	{
		"id": "yankee_doodle",
		"title": "Yankee Doodle",
		"vietnamese_title": "Bước Chân Nhộn Nhịp",
		"age_range": "3–6 tuổi",
		"bpm": 82,
		"bgm_path": "res://assets/audio/songbook/bgm_yankee_doodle.ogg",
		"voiceguide_path": "res://assets/audio/songbook/voiceguide_yankee_doodle.ogg",
		"rhythm": "oom_pah",
		"motif": "pizzicato hành khúc",
		"hook_vi": "Dạo bước nhộn nhịp cùng Mèo Nhỏ",
		"chords_full": ["C", "G", "C", "G"],
		"color": Color("#ED7A8E"),
		"chords": ["C", "G", "C", "G"],
		"description": "Giai điệu hành khúc vui tươi giúp bé làm quen với bước nhảy quãng ngắn",
		"pet_name": "Mèo Nhỏ Đáng Yêu",
		"pet_emoji": "🐱",
		"pet_id": "cat",
		"story_intro": "Bạn Mèo Nhỏ đội chiếc mũ gắn lông vũ, tung tăng dạo bước quanh vườn mây!",
		"scene_cue": "Những chiếc lông vũ cầu vồng bay lượn theo bước chân Mèo Nhỏ",
		"phrases": [
			{
				"name": "Dạo bước đến thị trấn (Câu 1)",
				"notes": PackedInt32Array([0, 0, 1, 2, 0, 2, 1]),
				"solfege": ["Do", "Do", "Re", "Mi", "Do", "Mi", "Re"],
				"lyrics": "Yan-kee Doo-dle went to town"
			},
			{
				"name": "Cưỡi chú ngựa nhỏ (Câu 2)",
				"notes": PackedInt32Array([0, 0, 1, 2, 0, 1]),
				"solfege": ["Do", "Do", "Re", "Mi", "Do", "Re"],
				"lyrics": "A-rid-ing on a po-ny"
			},
			{
				"name": "Cài lông vũ lên mũ (Câu 3)",
				"notes": PackedInt32Array([0, 0, 1, 2, 3, 2, 1]),
				"solfege": ["Do", "Do", "Re", "Mi", "Sol", "Mi", "Re"],
				"lyrics": "Stuck a feath-er in his cap"
			},
			{
				"name": "Vẫy chào bạn bè (Câu 4)",
				"notes": PackedInt32Array([0, 1, 2, 1, 0, 0]),
				"solfege": ["Do", "Re", "Mi", "Re", "Do", "Do"],
				"lyrics": "And called it mac-a-ro-ni!"
			}
		]
	},

	# ------------------------------------------------------------------ 14. Brahms' Lullaby (Chương 3 - Bài 4)
	{
		"id": "brahms_lullaby",
		"title": "Brahms' Lullaby",
		"vietnamese_title": "Khúc Hát Ru Ánh Trăng",
		"age_range": "2–6 tuổi",
		"bpm": 66,
		"bgm_path": "res://assets/audio/songbook/bgm_brahms_lullaby.ogg",
		"voiceguide_path": "res://assets/audio/songbook/voiceguide_brahms_lullaby.ogg",
		"rhythm": "lullaby_long",
		"motif": "hộp nhạc ru êm",
		"hook_vi": "Đung đưa khúc hát ru cùng Gấu Nâu",
		"chords_full": ["C", "G", "F", "C"],
		"color": Color("#C48D52"),
		"chords": ["C", "G", "F", "C"],
		"description": "Khúc hát ru kinh điển dịu dàng giúp bé thư giãn và cảm nhận nhịp điệu êm ái",
		"pet_name": "Gấu Nâu Ấm Áp",
		"pet_emoji": "🐻",
		"pet_id": "bear",
		"story_intro": "Ánh trăng bạc dịu dàng chiếu qua khung cửa lâu đài, Gấu Nâu ngân nga khúc hát ru êm đềm.",
		"scene_cue": "Đom đóm vàng và sao đêm nhẹ nhàng đung đưa quanh cành đậu thần",
		"phrases": [
			{
				"name": "Hát ru đêm lành (Câu 1)",
				"notes": PackedInt32Array([2, 2, 3, 2, 2, 3]),
				"solfege": ["Mi", "Mi", "Sol", "Mi", "Mi", "Sol"],
				"lyrics": "Lul-la-by and good night"
			},
			{
				"name": "Dưới bầu trời đầy sao (Câu 2)",
				"notes": PackedInt32Array([2, 3, 5, 4, 3, 3, 2]),
				"solfege": ["Mi", "Sol", "Do5", "La", "Sol", "Sol", "Mi"],
				"lyrics": "With pinkaz ros-es be-dight"
			},
			{
				"name": "Giấc mơ ngọt ngào (Câu 3)",
				"notes": PackedInt32Array([1, 2, 3, 1, 2, 3]),
				"solfege": ["Re", "Mi", "Sol", "Re", "Mi", "Sol"],
				"lyrics": "Lay thee down now and rest"
			},
			{
				"name": "Ngủ ngoan tới sáng mai (Câu 4)",
				"notes": PackedInt32Array([5, 4, 3, 2, 1, 0]),
				"solfege": ["Do5", "La", "Sol", "Mi", "Re", "Do"],
				"lyrics": "May thy slum-ber be blest!"
			}
		]
	},

	# ------------------------------------------------------------------ 15. Forest Grand Parade (Chương 3 - Bài 5)
	{
		"id": "little_star_march",
		"title": "Forest Grand Parade",
		"vietnamese_title": "Đại Hợp Xướng Rừng Nhạc",
		"age_range": "3–6 tuổi",
		"bpm": 84,
		"bgm_path": "res://assets/audio/songbook/bgm_little_star_march.ogg",
		"voiceguide_path": "res://assets/audio/songbook/voiceguide_little_star_march.ogg",
		"rhythm": "clap_2_4",
		"motif": "hợp xướng cả khu rừng",
		"hook_vi": "Cùng Sư Tử Nhạc Trưởng ngân vang cả 7 nốt!",
		"chords_full": ["C", "F", "Dm", "G"],
		"color": Color("#F4A261"),
		"chords": ["C", "F", "Dm", "G"],
		"description": "Bản hòa tấu kết thúc hành trình đi qua trọn vẹn 7 phím ngũ cung từ C4 tới D5",
		"pet_name": "Sư Tử Nhạc Trưởng",
		"pet_emoji": "🦁",
		"pet_id": "lion",
		"story_intro": "Tất cả muông thú trong Rừng Nhạc cùng tụ họp dưới Lâu Đài Chuông Gió cho buổi Đại Hợp Xướng!",
		"scene_cue": "Pháo hoa sao vàng và cầu vồng 7 sắc bừng sáng từ phím Đô trầm tới Rê cao",
		"phrases": [
			{
				"name": "Bậc thang ánh sáng đi lên (Câu 1)",
				"notes": PackedInt32Array([0, 1, 2, 3, 4, 5, 6]),
				"solfege": ["Do", "Re", "Mi", "Sol", "La", "Do5", "Re5"],
				"lyrics": "Sing to-geth-er up the sky!"
			},
			{
				"name": "Bậc thang ánh sáng đi xuống (Câu 2)",
				"notes": PackedInt32Array([6, 5, 4, 3, 2, 1, 0]),
				"solfege": ["Re5", "Do5", "La", "Sol", "Mi", "Re", "Do"],
				"lyrics": "Floating gen-tly from on high!"
			},
			{
				"name": "Muông thú hòa ca (Câu 3)",
				"notes": PackedInt32Array([0, 2, 3, 5, 6, 5, 3]),
				"solfege": ["Do", "Mi", "Sol", "Do5", "Re5", "Do5", "Sol"],
				"lyrics": "Ev-ery friend is here to play"
			},
			{
				"name": "Khúc kết Đại Hợp Xướng (Câu 4)",
				"notes": PackedInt32Array([4, 3, 2, 1, 0, 3, 5]),
				"solfege": ["La", "Sol", "Mi", "Re", "Do", "Sol", "Do5"],
				"lyrics": "Musi-cal For-est hip hoo-ray!"
			}
		]
	}
]


static func count() -> int:
	return SONGS.size()


static func is_valid(index: int) -> bool:
	return index >= 0 and index < SONGS.size()


static func get_song(index: int) -> Dictionary:
	if SONGS.is_empty():
		return {}
	var idx := posmod(index, SONGS.size())
	return SONGS[idx]


static func find_by_id(id_str: String) -> Dictionary:
	for song in SONGS:
		if song["id"] == id_str:
			return song
	return {}


static func phrase_count(song_index: int) -> int:
	var s := get_song(song_index)
	var phrases: Array = s.get("phrases", [])
	return phrases.size()


static func get_phrase(song_index: int, phrase_index: int) -> Dictionary:
	var s := get_song(song_index)
	var phrases: Array = s.get("phrases", [])
	if phrases.is_empty():
		return {}
	var p_idx := clampi(phrase_index, 0, phrases.size() - 1)
	return phrases[p_idx]


static func get_phrase_sequence(song_index: int, phrase_index: int) -> PackedInt32Array:
	var phrase := get_phrase(song_index, phrase_index)
	if phrase.is_empty():
		return PackedInt32Array()
	return phrase.get("notes", PackedInt32Array())


## Đường dẫn nhạc nền BGM của bài hát. Trống nếu chưa có.
static func get_bgm_path(song_index: int) -> String:
	var s := get_song(song_index)
	return s.get("bgm_path", "")


## Đường dẫn vocal guide la-la theo câu hát đầu (Phase 2). Trống nếu chưa có.
static func get_voiceguide(song_index: int) -> String:
	var s := get_song(song_index)
	return s.get("voiceguide_path", "")

