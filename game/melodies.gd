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
	PackedInt32Array([0, 2, 3]),                 # C  E  G      — đi lên, dễ đoán nhất
	PackedInt32Array([3, 2, 0, 2]),              # G  E  C  E
	PackedInt32Array([0, 3, 4, 3, 0]),           # C  G  A  G  C
	PackedInt32Array([5, 4, 3, 2, 0]),           # C5 A  G  E  C — đi xuống
	PackedInt32Array([0, 2, 4, 5, 4, 2]),        # C  E  A  C5 A  E
	PackedInt32Array([3, 5, 6, 5, 3, 2, 0]),     # G  C5 D5 C5 G  E  C
]

## docs/gameplay-design.html · Phạm vi v1: "3 chương × 5 trang".
const PAGES_PER_CHAPTER := 5


static func count() -> int:
	return TABLE.size()


## Giai điệu cho một trang. Số trang vượt quá số giai điệu thì quay vòng —
## v1 có 15 trang (3 chương × 5) nhưng chỉ 6 giai điệu.
static func for_page(page_index: int) -> PackedInt32Array:
	return TABLE[page_index % TABLE.size()]
