class_name Chapters
extends RefCounted
## Siêu dữ liệu 3 chương (docs/gameplay-design.html · Phạm vi v1: "3 chương × 5 trang").
##
## GIỚI HẠN NÓI THẲNG: v1 có đúng MỘT bối cảnh ("Rừng Thần lúc hoàng hôn") —
## Biển / Tuyết / Sa mạc là hàng sau. Nên ba chương khác nhau ở THỨ TỰ GIAI ĐIỆU
## và ĐỘ DÀI CHUỖI, không phải ở vật liệu mới. Melodies.for_page() quay vòng theo
## chỉ số trang tuyệt đối và chuỗi dài dần 3→7 nốt, nên chương sau tự khó hơn
## chương trước. Đó đúng bằng những gì Phạm vi v1 hứa, không hơn.
##
## static var chứ KHÔNG const: mỗi mục có một Color(...), mà lời gọi hàm dựng
## không phải biểu thức hằng trong GDScript. Bẫy này đã sập ở notes.gd và
## call_response.gd rồi.

static var TABLE: Array[Dictionary] = [
	{"name": "Rừng Sáo Trúc", "color": Color("#3F9455")},
	{"name": "Hồ Kalimba", "color": Color("#E08A2E")},
	{"name": "Lâu Đài Chuông Gió", "color": Color("#7C5CC4")},
]


static func count() -> int:
	return TABLE.size()


static func is_valid(chapter: int) -> bool:
	return chapter >= 0 and chapter < TABLE.size()


static func pages_per_chapter() -> int:
	return Melodies.PAGES_PER_CHAPTER


## Tổng số trang của v1: 3 × 5 = 15.
static func total_pages() -> int:
	return count() * Melodies.PAGES_PER_CHAPTER


static func first_page_of(chapter: int) -> int:
	return clampi(chapter, 0, count() - 1) * Melodies.PAGES_PER_CHAPTER


static func of_page(page: int) -> int:
	return clampi(page / Melodies.PAGES_PER_CHAPTER, 0, count() - 1)


static func name_of(chapter: int) -> String:
	return TABLE[chapter]["name"] if is_valid(chapter) else ""


static func color_of(chapter: int) -> Color:
	return TABLE[chapter]["color"] if is_valid(chapter) else Color.WHITE
