class_name Notes
extends RefCounted
## Bảng nốt — NGUỒN SỰ THẬT DUY NHẤT cho toàn bộ game.
##
## Ánh xạ nốt ↔ con vật ↔ màu ↔ tiếng được dùng lại ở:
##   - PianoKeyboard (Tuần 1)
##   - LeafSlots trên cây thần (Tuần 2)
##   - chuỗi giai điệu gọi–đáp (Tuần 3)
##   - ShareRenderer 9:16 (Tuần 4)
## Sửa ở đây, không hardcode lại chỗ nào khác.
##
## Thang ngũ cung trưởng — docs/gameplay-design.html · Quyết định 02.
## BỎ F và B: trong tập 7 nốt diatonic có nửa cung (E–F, B–C) và quãng ba cung
## (F–B), trẻ đập loạn sẽ ra âm nghịch tai, hỏng lời hứa "chạm đâu cũng hay".

## Dùng `static var`, KHÔNG dùng `const`.
## `const` trong GDScript đòi biểu thức hằng lúc biên dịch, mà `Color("#E0644F")`
## là một lời gọi constructor — khai báo const kèm Color sẽ không biên dịch được.
static var TABLE: Array[Dictionary] = [
	{
		"note": "C4", "freq": 261.63, "animal": "Sư tử", "color": Color("#E0644F"),
		"sample": "res://assets/placeholder/notes/note_c4_su_tu.wav",
		"voice": "lion", "pitch": 0.667,
	},
	{
		"note": "D4", "freq": 293.66, "animal": "Gấu", "color": Color("#E08A2E"),
		"sample": "res://assets/placeholder/notes/note_d4_gau.wav",
		"voice": "bear", "pitch": 0.749,
	},
	{
		"note": "E4", "freq": 329.63, "animal": "Thỏ", "color": Color("#D8619A"),
		"sample": "res://assets/placeholder/notes/note_e4_tho.wav",
		"voice": "rabbit", "pitch": 0.841,
	},
	{
		"note": "G4", "freq": 392.00, "animal": "Mèo", "color": Color("#3F9455"),
		"sample": "res://assets/placeholder/notes/note_g4_meo.wav",
		"voice": "cat", "pitch": 1.000,
	},
	{
		"note": "A4", "freq": 440.00, "animal": "Khỉ", "color": Color("#3877B5"),
		"sample": "res://assets/placeholder/notes/note_a4_khi.wav",
		"voice": "monkey", "pitch": 1.122,
	},
	{
		"note": "C5", "freq": 523.25, "animal": "Voi", "color": Color("#7C5CC4"),
		"sample": "res://assets/placeholder/notes/note_c5_voi.wav",
		"voice": "elephant", "pitch": 1.335,
	},
	{
		"note": "D5", "freq": 587.33, "animal": "Cú", "color": Color("#C7A017"),
		"sample": "res://assets/placeholder/notes/note_d5_cu.wav",
		"voice": "owl", "pitch": 1.498,
	},
]


static func count() -> int:
	return TABLE.size()


static func is_valid(index: int) -> bool:
	return index >= 0 and index < TABLE.size()


static func color_of(index: int) -> Color:
	return TABLE[index]["color"] if is_valid(index) else Color.MAGENTA


static func animal_of(index: int) -> String:
	return TABLE[index]["animal"] if is_valid(index) else "?"


static func note_of(index: int) -> String:
	return TABLE[index]["note"] if is_valid(index) else "?"


## Tên file giọng thú của Bước 3: assets/audio/voice_<voice>_g4.wav.
## Cả bảy giọng thu/sinh ở CÙNG nốt G4 rồi để Godot dịch cao độ — sinh riêng
## từng cao độ sẽ lệch tông với pad nền theo bảy kiểu khác nhau, và lỗi đó rất
## khó nghe ra khi thử từng phím một.
static func voice_of(index: int) -> String:
	return TABLE[index]["voice"] if is_valid(index) else ""


## Hệ số dịch cao độ từ G4 về nốt của phím này.
static func pitch_of(index: int) -> float:
	return TABLE[index]["pitch"] if is_valid(index) else 1.0
