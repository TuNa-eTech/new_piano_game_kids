class_name Melodies
extends RefCounted
## Giai điệu tự soạn cho vòng gọi–đáp.
##
## docs/gameplay-design.html · Phạm vi v1: "6 giai điệu tự soạn trên thang ngũ cung".
## Về bản quyền: tự soạn rẻ hơn nhiều so với thẩm định bản quyền dân ca — với 5
## nốt ngũ cung, viết một câu nhạc 3–7 nốt dễ nghe là việc của một buổi chiều.
##
## Mỗi số là CHỈ SỐ PHÍM trong Notes.TABLE, không phải cao độ:
##   0=C4 Sư tử · 1=D4 Gấu · 2=E4 Thỏ · 3=G4 Mèo · 4=A4 Khỉ · 5=C5 Voi · 6=D5 Cú
##
## Chuỗi dài dần theo trang, đúng Quyết định 03: "giai điệu mới, chuỗi dài thêm
## một nốt".

static var TABLE: Array[PackedInt32Array] = [
	# --- CHƯƠNG 1: RỪNG SÁO TRÚC (Tổng 23 nốt cho 5 trang đầu) ---
	PackedInt32Array([0, 2, 3]),                 # Lv1: Tiếng Chim Buổi Sớm (C, E, G)
	PackedInt32Array([3, 2, 0, 2]),              # Lv2: Suối Reo Róc Rách (G, E, C, E)
	PackedInt32Array([0, 3, 4, 3, 0]),           # Lv3: Gió Qua Rặng Tre (C, G, A, G, C)
	PackedInt32Array([5, 4, 3, 2, 0]),           # Lv4: Bướm Vờn Hoa Dại (C5, A, G, E, C)
	PackedInt32Array([0, 2, 4, 5, 4, 2]),        # Lv5: Lễ Hội Hạt Sồi (C, E, A, C5, A, E)

	# --- CHƯƠNG 2: HỒ NƯỚC KALIMBA ---
	PackedInt32Array([2, 3, 5]),                 # Lv6: Mặt Nước Phẳng Lặng (E, G, C5)
	PackedInt32Array([2, 0, 2, 3]),              # Lv7: Cá Nhảy Đớp Trăng (E, C, E, G)
	PackedInt32Array([3, 4, 5, 4, 3]),           # Lv8: Đom Đóm Thắp Đèn (G, A, C5, A, G)
	PackedInt32Array([4, 5, 6, 5, 3]),           # Lv9: Tiếng Mưa Tí Tách (A, C5, D5, C5, G)
	PackedInt32Array([0, 3, 2, 4, 5, 6]),        # Lv10: Hồ Sen Ngát Hương (C, G, E, A, C5, D5)

	# --- CHƯƠNG 3: LÂU ĐÀI CHUÔNG GIÓ ---
	PackedInt32Array([0, 2, 3, 5]),              # Lv11: Bậc Thang Mây Trắng (C, E, G, C5)
	PackedInt32Array([3, 5, 4, 6]),              # Lv12: Cổng Gió Reo Vui (G, C5, A, D5)
	PackedInt32Array([2, 4, 5, 6, 5]),           # Lv13: Vũ Điệu Sao Băng (E, A, C5, D5, C5)
	PackedInt32Array([0, 3, 4, 5, 6]),           # Lv14: Dạ Khúc Ánh Trăng (C, G, A, C5, D5)
	PackedInt32Array([0, 2, 3, 4, 5, 6, 5]),     # Lv15: Khúc Ca Vương Quốc (C, E, G, A, C5, D5, C5)
]

static var LEVEL_NAMES: Array[String] = [
	"Tiếng Chim Buổi Sớm",
	"Suối Reo Róc Rách",
	"Gió Qua Rặng Tre",
	"Bướm Vờn Hoa Dại",
	"Lễ Hội Hạt Sồi",
	"Mặt Nước Phẳng Lặng",
	"Cá Nhảy Đớp Trăng",
	"Đom Đóm Thắp Đèn",
	"Tiếng Mưa Tí Tách",
	"Hồ Sen Ngát Hương",
	"Bậc Thang Mây Trắng",
	"Cổng Gió Reo Vui",
	"Vũ Điệu Sao Băng",
	"Dạ Khúc Ánh Trăng",
	"Khúc Ca Vương Quốc",
]

## docs/gameplay-design.html · Phạm vi v1: "3 chương × 5 trang".
const PAGES_PER_CHAPTER := 5


static func count() -> int:
	return TABLE.size()


## Giai điệu cho một trang.
static func for_page(page_index: int) -> PackedInt32Array:
	return TABLE[clampi(page_index, 0, TABLE.size() - 1)]


static func level_name(page_index: int) -> String:
	var idx := clampi(page_index, 0, LEVEL_NAMES.size() - 1)
	return LEVEL_NAMES[idx]
