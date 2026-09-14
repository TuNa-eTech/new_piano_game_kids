# NGHIÊN CỨU KIẾN TRÚC & LỘ TRÌNH REFACTOR

> **Dự án**: Rừng Nhạc (Enchanted Music Forest) — Godot 4.7 Mobile
> **Mục đích**: Trả lời câu hỏi "kiến trúc tốt nhất, dễ hiểu, dễ update" bằng số liệu đo được
> trên mã nguồn hiện tại, rồi xếp hạng việc cần làm theo tỉ lệ **lợi ích ÷ rủi ro**.
> **Trạng thái**: Tài liệu nghiên cứu — CHƯA sửa một dòng code nào.

---

## 0. Kết Luận Ngắn (đọc cái này là đủ)

**Kiến trúc lõi đã đúng và KHÔNG nên thay.** Autoload giữ trạng thái, signal nối dây,
state machine giữ luật chơi, `main.gd` chỉ nối dây chứ không chứa luật — đây chính là
idiom chuẩn của Godot. Mọi đề xuất bên dưới đều **giữ nguyên khung này**.

**Vấn đề nằm gọn ở tầng UI.** 16 script giao diện, **6.638 dòng**, nhưng chỉ có **1 file `.tscn`**.
Toàn bộ màn hình được dựng bằng code trong các hàm `_build()` dài 100–300 dòng. Hệ quả là
bốn loại trùng lặp đo đếm được — và một máy trạng thái overlay được cài đặt bằng
"các câu lệnh phòng thủ rải rác" thay vì một cấu trúc tường minh.

**Thứ tự ưu tiên (KHÔNG phải thứ tự trực giác):**

| # | Việc | Mua được gì | Rủi ro |
| :---: | :--- | :--- | :--- |
| **1** | Ngăn xếp overlay tường minh trong `ScreenRouter` | **Tính đúng đắn** — xoá 3 lỗi đã từng xảy ra | Trung bình |
| **2** | Gộp 6 lớp hiệu ứng hạt trùng lặp | Gọn, dễ chỉnh hiệu ứng một chỗ | **Rất thấp** |
| **3** | Một `Theme` `.tres` thay 153 dòng `add_theme_*` | Đổi style cả game ở một chỗ | Thấp |
| **4** | Sổ đăng ký đường dẫn asset (258 chuỗi `res://assets/`) | Đổi tên asset không vỡ game | Thấp |
| **5** | Bỏ 22 chỗ tra cứu autoload kiểu vòng vo | Bớt nhiễu, nhất quán | **Rất thấp** |
| **6** | Tách `tools/` + `game/dev/` khỏi bản phát hành | Gọn cây thư mục, gọn bản build | Rất thấp |

> ⚠️ Việc "chuyển UI sang `.tscn`" **KHÔNG nằm trong 6 việc trên**. Lý do ở mục 5.

---

## 1. Những Điều PHẢI Giữ Nguyên (đừng "refactor" mất)

Đây là phần khó nhất của tài liệu này: chỉ ra cái đang **đúng**, để không ai phá nhầm.

### 1.1. Phân vai đã sạch sẵn
| Thành phần | Sở hữu điều gì | Đánh giá |
| :--- | :--- | :--- |
| `GameState` | Trạng thái ván chơi (trang, sao, chế độ) | ✅ Sạch |
| `SaveStore` | Lưu trữ, và **chỉ** lưu trữ | ✅ Sạch |
| `AudioDirector` | Phát âm thanh, polyphony, bus | ✅ Sạch |
| `CallResponse` | Luật chơi gọi–đáp (state machine 6 trạng thái) | ✅ Sạch |
| `main.gd` | **Chỉ nối dây** — 190 dòng, không chứa luật | ✅ Sạch |
| `PauseOverlay` | Chủ sở hữu **duy nhất** của `get_tree().paused` | ✅ Ý tưởng đúng (cài đặt cần nâng — mục 4) |

Đây đã là "clean architecture" theo đúng nghĩa Godot rồi. **Không** áp khuôn
entities / use-cases / repository vào đây — đó là idiom của backend, không phải của engine game.
Ép vào sẽ làm dự án khó hiểu hơn, tức là đi ngược đúng mục tiêu bạn đặt ra.

### 1.2. Các comment "TẠI SAO" là tài sản, không phải rác
Mã nguồn này giải thích **lý do**, không phải **hành vi** — thứ hiếm và đắt:

- `save_store.gd:42` — thứ tự nối signal: *"đây là thứ tự CÓ Ý NGHĨA, đừng đảo"*
- `save_store.gd:20` — vì sao lưu ở 2 mốc: *"trên iOS `NOTIFICATION_WM_CLOSE_REQUEST` KHÔNG đáng tin"*
- `pause_overlay.gd:8` — vì sao phải đếm chồng: *"bé nghe tiếng đàn phát ra từ một bàn phím không nhìn thấy"*
- `main.gd:145` — vì sao phải `release_all()` trước khi pause: ngón đang giữ sẽ kẹt

> **Ràng buộc bắt buộc cho mọi giai đoạn refactor bên dưới:**
> Khi di chuyển code, **comment lý do phải đi theo tới chỗ mới**. Một refactor
> làm mất các comment này khiến dự án *khó hiểu hơn* — ngược hẳn mục tiêu.

---

## 2. Số Liệu Đo Được

```
game/ (không tính dev/):   42 script  ·  13.421 dòng
game/ui/:                  16 script  ·   6.638 dòng  ·  1 file .tscn
Tổng .tscn ngoài dev/:     7 file
```

| Chỉ số | Số lượng | Ý nghĩa |
| :--- | ---: | :--- |
| Chuỗi `res://assets/` viết cứng trong `game/` | **258** | Đổi tên 1 asset → phải sửa tay nhiều nơi |
| Dòng `add_theme_*` rải rác | **153** | Không có nguồn sự thật về style |
| Dòng `ResourceLoader.exists(...)` | **123** | Mẫu "tải asset có dự phòng" chép đi chép lại |
| Lớp nội bộ (`class ... extends`) | **17** | Trong đó **6** là lớp hạt gần trùng nhau |
| Tra cứu `get_node_or_null("/root/...")` | **22** | Trong khi **262** chỗ khác gọi thẳng autoload |
| Script dùng một lần trong `tools/` | **46** | Nằm chung với mã phát hành |

---

## 3. Bốn Loại Trùng Lặp (có bằng chứng)

### 3.1. Sáu lớp hiệu ứng hạt chép tay
```
main_menu.gd:610        class StarlightBurstLayer
chapter_map.gd:271      class StarlightBurstLayer      ← trùng tên, khác nội dung
level_select.gd:538     class LevelStarlightBurstLayer
parental_gate.gd:306    class GateStarlightBurstLayer
parental_corner.gd:495  class CornerBurstLayer
chest_reward.gd:378     class ChestStarlightFountain
goodnight_screen.gd:393 class GoodnightZzzBurstLayer
```
So sánh trực tiếp `main_menu.gd:610` và `chapter_map.gd:271`: **cùng một thuật toán**,
chỉ khác vài con số phép thuật — hệ số hãm `0.92` vs `0.91`, quầng sáng `1.8` vs `1.9`,
dải tốc độ `60–220` vs `50–210`. Đây là chép-dán đúng nghĩa đen.

> 📌 **Lưu ý quan trọng**: `docs/art-pipeline-level-select-2.5d.md:358` đã quy định hiệu ứng
> phải là **PackedScene `GPUParticles2D`** (`vfx_golden_ring_aura.tscn`, `vfx_music_notes_trail.tscn`…).
> Nghĩa là code hiện tại (vẽ tay bằng `_draw()` trên CPU) đang **lệch khỏi pipeline mỹ thuật
> đã chốt**. Gộp lại vừa dọn trùng lặp, vừa kéo code về đúng tài liệu — và còn được lợi
> hiệu năng trên máy di động.

### 3.2. Style rải rác — 153 dòng `add_theme_*`
`main_menu.gd` 31 dòng · `parental_corner.gd` 24 · `level_select.gd` 18 · `goodnight_screen.gd` 17 …
Muốn đổi màu nút "to bản chuẩn Apple Kids ≥ 88pt" cho cả game → phải sửa 16 file.

### 3.3. Đường dẫn asset viết cứng — 258 chuỗi
Kèm theo mẫu dự phòng lặp lại 123 lần:
```gdscript
if ResourceLoader.exists(path_a):
    tex = load(path_a)
elif ResourceLoader.exists(path_b):
    tex = load(path_b)
```

> 🐞 **PHÁT HIỆN NGHIÊM TRỌNG NHẤT CỦA TÀI LIỆU NÀY — ảnh mockup đang được dùng làm
> tài nguyên phát hành.** Có **19 chỗ** trong `game/` trỏ vào `res://docs/`, phủ **8/8 màn hình**:
>
> | File | Dòng | Kiểu | Mức độ |
> | :--- | ---: | :--- | :--- |
> | `chapter_map.gd` | 58 | `if` — **nguồn DUY NHẤT** | 🔴 Nghiêm trọng |
> | `chest_reward.gd` | 88 | `if` — **nguồn DUY NHẤT** | 🔴 Nghiêm trọng |
> | `main_menu.gd` | 98 | `elif` — dự phòng | 🟡 |
> | `level_select.gd` | 127 | `elif` — dự phòng | 🟡 |
> | `goodnight_screen.gd` | 69 | `elif` — dự phòng | 🟡 |
> | `chapter_end.gd` | 113 | `elif` — dự phòng | 🟡 |
> | `parental_corner.gd` | 89 | `elif` — dự phòng | 🟡 |
> | `parental_gate.gd` | 75 | `elif` — dự phòng | 🟡 |
>
> Hai chỗ đầu dùng `if` chứ **không phải** `elif` — nghĩa là ảnh mockup không phải phương án
> dự phòng, nó là **phông nền chính thức đang chạy trong game**. Kèm theo:
> - `docs/mock-chapter-map.jpeg` ~766 KB và `docs/mock-chest-reward.jpeg` ~761 KB bị kéo vào
>   gói phát hành, cùng toàn bộ thư mục `docs/` (tổng các ảnh mock + png > 10 MB).
> - Ảnh JPEG mockup là bản vẽ concept phẳng — không phải asset 2.5D đã tách lớp mà
>   `docs/art-pipeline-*.md` quy định.
>
> **Đây là việc cần sửa ngay, tách riêng, không chờ refactor** — xem Giai Đoạn 0.

### 3.4. Truy cập autoload không nhất quán
`AudioDirector` và `GameState` **là autoload** — gọi thẳng tên là được.
Nhưng code đang dùng **hai kiểu song song**: 262 chỗ gọi thẳng, 22 chỗ đi đường vòng:
```gdscript
# screen_router.gd:117 — vòng vo, rồi còn phải has_method() từng hàm
var gs := get_node_or_null("/root/GameState")
if gs != null and gs.has_method("set_page"):
    gs.set_page(page)

# main.gd:180 — đúng và gọn
AudioDirector.play_sfx("chapter_unlock")
```
`has_method()` trên một class đã biết kiểu làm mất luôn kiểm tra kiểu lúc biên dịch:
gõ sai tên hàm sẽ **im lặng không làm gì** thay vì báo lỗi.

---

## 4. Vấn Đề Số 1: Vòng Đời Overlay

**Đây là mục duy nhất mua được tính đúng đắn, không chỉ sự gọn gàng.**

`screen_router.gd` tự ghi lại **ba lỗi đã từng xảy ra** ngay trong comment của nó:

| Vị trí | Lỗi đã xảy ra |
| :--- | :--- |
| `screen_router.gd:201` | *"trước đây là pass — menu tự đóng nhưng router không dọn các overlay khác nên có thể kẹt paused"* |
| `screen_router.gd:261` | *"trước đây mở chapter_end chồng lên chest chưa đóng — bộ đếm `_open_count` lệch, bé thấy 2 lớp phủ"* |
| `screen_router.gd:272` | *"chống mở chồng nếu chapter_end/chest đã mở (double signal)"* → 2 câu `return` phòng thủ |

Cộng thêm `pause_overlay.gd:20`: `_open_count` là biến **`static`**, sống qua cả lần dựng lại
scene, nên máy đo phải gọi `reset_pause_state()` để dọn (`pause_overlay.gd:101`).

**Chẩn đoán**: đây là một máy trạng thái được cài đặt bằng các câu lệnh phòng thủ rải rác.
Mỗi lỗi mới lại thêm một `if ... return`. Trách nhiệm đóng overlay cũng đang chia đôi
không nhất quán — `parental_gate.gd:262` tự đóng mình, còn `chest_reward` thì router đóng hộ.

**Hướng đề xuất**: một ngăn xếp overlay tường minh trong router, với bất biến:
> *Tại mọi thời điểm, có đúng một overlay ở đỉnh ngăn xếp sở hữu trạng thái pause.*

`push(overlay)` / `pop()` — router là nơi **duy nhất** đóng/mở. Khi đó cả 3 câu lệnh phòng thủ
và cả biến `static` đều tự biến mất.

**Câu hỏi then chốt**: có luồng nào **hợp lệ** cần hai overlay chồng nhau cùng lúc không?

Sơ đồ luồng (`screen-flow-guide.md` mục III) gợi ý là "không" — mọi chuyển màn đều tuần tự
(M06 → M07, M04 → M05). **Nhưng chạy test thật thì câu trả lời là CÓ**: `ParentalGate` chồng
lên `GoodnightScreen` là luồng đúng thiết kế. → **Xem mục 6.3 để biết thiết kế đã được
điều chỉnh thế nào.** Đây chính là lý do tài liệu này bắt buộc phải đo baseline trước
khi đề xuất: trực giác đọc sơ đồ đã cho ra kết luận sai.

---

## 5. Vì Sao KHÔNG Đề Xuất "Chuyển Toàn Bộ UI Sang `.tscn`"

Trực giác sẽ nói "không có `.tscn` = vấn đề lớn nhất". Xét theo **lợi ích ÷ rủi ro**, nó là
mục **tệ nhất**:

- **Khối lượng**: 8 màn hình × `_build()` 100–300 dòng ≈ 2.000+ dòng phải dựng lại bằng tay.
- **Không có lưới an toàn**: không một bài test nào kiểm tra *bố cục*. `navigation_flow_test`
  chỉ kiểm tra tín hiệu đóng/mở, không biết nút bị lệch 200px.
- **Ràng buộc bắt buộc**: `screen-flow-guide.md` mục V.5 quy định *"tuyệt đối không để phần tử UI
  nào đè lên vùng gõ đàn của trẻ (y ≥ 460px)"*. Dựng lại tay là đúng loại thao tác dễ phá điều này.
- **Đổi lại được gì?** Chủ yếu là chỉnh sửa trực quan trong Editor. Có giá trị — nhưng thấp hơn
  hẳn 6 mục kia, trong khi rủi ro cao hơn tất cả cộng lại.

**Đề xuất thay thế**: sau khi xong giai đoạn 2–3, làm **một màn hình thí điểm** (gợi ý:
`chest_reward.gd` — 533 dòng, `_build()` đã tách sẵn thành 6 hàm con rõ ràng, ít trạng thái nhất).
Nếu thí điểm thực sự dễ đọc hơn và không vỡ gì → mới bàn tiếp. Nếu không → dừng, và đó cũng
là một kết quả hợp lệ.

---

## 6. Lộ Trình Đề Xuất

**Điều kiện tiên quyết cho mọi giai đoạn:**
- **Cây làm việc phải sạch trước khi bắt đầu.** Hiện đang có nhiều file sửa dở chưa commit
  trên nhánh `main` (cả script lẫn asset Git-LFS, và danh sách này còn đang thay đổi).
  Refactor chồng lên đó sẽ rối không gỡ được. → **Commit hoặc stash trước, rồi tạo nhánh riêng.**
- Mỗi giai đoạn = **một nhánh, một PR**. Không gộp.

| GĐ | Việc | Cách kiểm chứng |
| :---: | :--- | :--- |
| **0** | Gỡ `docs/mock-*.jpeg` khỏi mã phát hành — ưu tiên 2 chỗ `if` (mục 3.3) | `grep -rn 'res://docs/' game/ --exclude-dir=dev` không còn kết quả |
| **1** | Ngăn xếp overlay **sâu ≥ 2** trong `ScreenRouter` (mục 4 + 6.3) | Đúng 3 lỗi nền, không lỗi mới; `soak_test` không tệ hơn |
| **2a** | Gộp 6 lớp hạt → 1 script tham số hoá, **giữ nguyên thuật toán CPU** | Soát code + 8/8 màn hình dựng được, không `push_error` |
| **2b** | *(tách riêng, sau)* Chuyển sang `GPUParticles2D` theo pipeline mỹ thuật | **Đổi hình ảnh có chủ đích** — bạn duyệt bằng mắt |
| **3** | Một `Theme` `.tres` thay 153 dòng `add_theme_*` | So ảnh trước/sau — **chỉ hợp lệ nếu tắt/gieo hạt lớp particle**, xem 6.4 |
| **4** | `game/asset_paths.gd` — gom **258** chuỗi `res://assets/` | Game khởi động, không có `push_error` thiếu asset |
| **5** | Bỏ 22 chỗ `get_node_or_null("/root/...")` + `has_method()` | Biên dịch sạch; đúng 3 lỗi nền, không lỗi mới |
| **6** | Chuyển `tools/` + `game/dev/` ra ngoài bản export | Export thử, kiểm tra dung lượng gói |
| **7** | *(tuỳ chọn)* Thí điểm `.tscn` trên `chest_reward` | So ảnh + đánh giá chủ quan "có dễ đọc hơn thật không" |

**Lệnh chạy test** (Godot 4.7.2 tại `/Applications/Godot.app`):
```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . \
    res://game/dev/navigation_flow_test.tscn
```

### 6.1. BASELINE ĐÃ ĐO — bộ test đang **TRƯỢT 3 lỗi** trên cây hiện tại

Đã chạy thật, log đầy đủ lưu tại [`docs/baseline-navigation-flow-test.log`](baseline-navigation-flow-test.log):

```
=== TRƯỢT (3 lỗi) ===
  [SAI] Đánh Thức Khu Rừng đóng GoodnightScreen
  [SAI] Game tiếp tục chơi bình thường
  [SAI] Chạm rương báu Diorama kích hoạt ChestReward
```
*(37/40 mục ĐẠT. Bài test mất ~6–10 phút, KHÔNG treo — stdout bị đệm khối khi ghi ra
file nên im lặng suốt quá trình chạy là bình thường, đừng tưởng nó chết.)*

> ⚠️ **Đây là mốc nền. Refactor mà không biết mốc này thì sẽ không phân biệt được
> "lỗi mình vừa tạo" với "lỗi vốn đã có".**
>
> **Quy tắc cổng cho MỌI giai đoạn: đúng ba lỗi có tên ở trên, không thêm lỗi mới.**
>
> 🚫 **Tuyệt đối KHÔNG sửa `navigation_flow_test.gd` cho xanh trước khi refactor.** Ba lỗi này
> đang báo đúng chức năng của chúng — chỉnh assertion cho ĐẠT ngay trước sáu giai đoạn
> dựa vào chính bài test đó là cách nhanh nhất để mất lưới an toàn. Riêng lỗi ③ còn có thể
> đang tố một tính năng chưa nối xong (mục 6.2b): sửa test = ghi cái dở dang thành "đúng".

### 6.2. Ba lỗi này nói lên điều gì — **tài liệu và mã nguồn đang mâu thuẫn**

Cả 3 lỗi đều KHÔNG phải lỗi lập trình cẩu thả. Chúng là chỗ `screen-flow-guide.md`
và code **quy định khác nhau**, và chưa ai chốt bên nào đúng:

| Lỗi | `screen-flow-guide.md` nói | Code làm | Kết luận |
| :--- | :--- | :--- | :--- |
| ①② Đánh thức rừng | Mục IV: M08 → **thẳng** M02 | `screen_router.gd:236` mở **ParentalGate** chồng lên, chờ giải xong mới đóng | **Code đúng** — tuân thủ Apple Kids 1.3, lý do đã ghi trong code. → Sửa tài liệu + sửa test. |
| ③ Chạm rương Diorama | Mục IV: M02 → M06 | `main.gd:167` chỉ mở khi `free_play == true` | ⚠️ **KHÔNG kết luận được — xem 6.2b** |

### 6.2b. 🔴 CÂU HỎI MỞ CHO CHỦ DỰ ÁN — màn Rương Báu gần như không tới được

Lần theo mọi đường gọi tới `ChestReward`, kết quả:

```
open_chest_reward()  ← gọi từ ĐÚNG 1 nơi: main.gd:167  (điều kiện: GameState.free_play == true)
show_reward()        ← screen_router.gd:278, nằm sau  `if enable_chest_before_concert:`
enable_chest_before_concert  ← khai báo `= false` ở screen_router.gd:27
                             ← KHÔNG nơi nào trong game/ hay tools/ gán `true`
```

**Đây là một cờ chết.** Hệ quả ở cấu hình mặc định: hoàn thành một bài hát **không** mở rương —
`_on_call_response_page_completed` chỉ gọi `_diorama.celebrate_completion()`; hết chương thì
`handle_chapter_completed` nhảy thẳng sang `ChapterEnd`. Rương chỉ mở khi bé **chạm vào prop
rương trong chế độ Chơi Tự Do**.

Nhưng cả hai tài liệu đều mô tả khác:
- `README.md` · Tính Năng Nổi Bật: *"**Khi hoàn thành mỗi bài hát**, Rương Báu bung nắp trào suối ánh sáng"*
- `screen-flow-guide.md` · mục III: `KeyHit --(Đủ chuỗi nốt)--> M06 --(Nhận Thưởng)--> PageTurn`
- `screen-flow-guide.md` · mục II hàng 06: *"**Đỉnh cao phần thưởng (Dopamine)**"*

> **Cần bạn quyết định — tài liệu này KHÔNG tự chốt:**
>
> **(A)** Vòng thưởng theo từng bài là tính năng **đã định nhưng chưa nối xong** → cần nối dây,
> và khi đó `navigation_flow_test` lỗi ③ đang báo **đúng**, đừng sửa test.
>
> **(B)** Đã cố ý bỏ vòng thưởng đó (ví dụ vì mở rương sau mỗi bài làm đứt mạch chơi) →
> cần sửa `README.md` + `screen-flow-guide.md` + test, và **xoá hẳn cờ chết**
> `enable_chest_before_concert` cho khỏi đánh lừa người đọc sau.
>
> Chọn sai hướng ở đây là hoặc xoá mất spec của một tính năng chưa làm xong, hoặc
> xây lại một tính năng đã bị cố ý bỏ. Vì vậy nó nằm ngoài phạm vi refactor.


### 6.3. Điều chỉnh thiết kế Giai Đoạn 1 (quan trọng)

Lỗi ①② vừa **trả lời câu hỏi bỏ ngỏ ở mục 4**:

> *Có luồng nào hợp lệ cần hai overlay chồng nhau cùng lúc không?* → **CÓ.**
> `ParentalGate` chồng lên `GoodnightScreen` là luồng **đúng theo thiết kế**, không phải lỗi.

Vậy nên Giai Đoạn 1 phải là **ngăn xếp thật (sâu ≥ 2)**, KHÔNG phải "một khe duy nhất".
Bất biến cần sửa lại cho chính xác:

> *Chỉ overlay ở **đỉnh** ngăn xếp nhận tương tác; ván chơi chạy lại khi và chỉ khi
> ngăn xếp rỗng.*

Với bất biến này, `_open_count` kiểu `static` được thay bằng chính độ sâu ngăn xếp —
và cả 3 câu lệnh phòng thủ ở `screen_router.gd:201 / 261 / 272` đều tự biến mất.

### 6.4. Cảnh báo về cách kiểm chứng bằng ảnh chụp

`screen_capture_all.tscn` (so ảnh trước/sau) là cổng kiểm chứng hấp dẫn, **nhưng nó sẽ nói dối**
nếu dùng nguyên trạng:

```gdscript
func emit_burst(origin: Vector2, color: Color, count: int = 20) -> void:
    var rng := RandomNumberGenerator.new()      # ← KHÔNG gieo hạt, tạo mới mỗi lần gọi
    ...
    var spd := rng.randf_range(60.0, 220.0)
```

Mọi lớp hạt đều tạo `RandomNumberGenerator` mới, **không gieo hạt**, ở mỗi lần phát. Nghĩa là
hai lần chạy liên tiếp **không sửa một dòng code nào** cũng cho ra ảnh khác nhau. Cổng kiểm
chứng kiểu "ảnh phải giống hệt" do đó không phân biệt được lỗi hồi quy với nhiễu ngẫu nhiên.

**Cách xử lý — làm trước Giai Đoạn 3:**
- Thêm tuỳ chọn gieo hạt cố định (hoặc tắt hẳn lớp particle) khi chạy `screen_capture_all`;
- Chỉ khi đó, "ảnh giống hệt" mới là cổng hợp lệ cho Giai Đoạn 3 (trích `Theme` **phải**
  giữ nguyên từng pixel);
- Giai Đoạn 2a thì **không** dùng cổng ảnh — dùng soát code + "8/8 màn hình dựng được";
- Giai Đoạn 2b là đổi hình ảnh có chủ đích, cổng duy nhất là **mắt bạn**.

---

## 6.5. TIẾN ĐỘ THỰC THI

Nhánh: `refactor/kien-truc-giai-doan-1`. Baseline đo lại trên commit `6707617`
vẫn **đúng 3 lỗi cũ** — mốc nền không đổi.

| GĐ | Trạng thái | Commit | Kiểm chứng |
| :---: | :--- | :--- | :--- |
| **1** | ✅ Xong | `410c189` | 3 lỗi nền, không lỗi mới |
| **2a** | ✅ Xong | `fecc549` | 3 lỗi nền + 2 test 2.5D ĐẠT toàn bộ |
| **0** | 🟡 Xong 6/8 màn | *(đang làm)* | 19 tham chiếu `res://docs/` → còn 4 |
| **5** | ✅ Xong | *(đang làm)* | cổng nhanh sạch + 3 lỗi nền |
| 2b · 3 · 4 · 6 · 7 | ⬜ Chưa làm | — | — |

**Giai Đoạn 1** — `_open_count` (static int) → ngăn xếp giữ chính các đối tượng
`PauseOverlay`. Bất biến: ván chơi chạy lại ⟺ ngăn xếp rỗng. `close_active_overlay()`
từ 8 khối `if` liệt kê tay → đóng từ đỉnh xuống.

> 🐞 **Lỗi tiềm ẩn phát hiện thêm khi làm**: `ChapterEnd` và `ChestReward` **cùng
> `layer = 12`**. Hai `CanvasLayer` cùng số thì thứ tự vẽ rơi về thứ tự trong cây —
> đúng cặp đã gây ra lỗi "bé thấy 2 lớp phủ" ghi trong comment cũ của router.
> Đã đổi `ChapterEnd` → `layer = 13`, khớp với con số mà comment đầu
> `screen_router.gd` vẫn ghi từ trước (code và comment đã lệch nhau từ lâu).

**Giai Đoạn 2a** — 6 lớp hạt → `game/fx/starlight_burst.gd` + `musical_note_burst.gd`.
**−303 dòng** trong `game/ui/`, **+179 dòng** dùng chung. Mọi con số phép thuật
(0.91/0.92/0.94, 1.8/1.9/2.0, dải tốc độ) giờ là thuộc tính có tên đặt tại nơi dùng.

---

## 7. Những Điều KHÔNG Nên Làm

1. ❌ **Không** áp kiến trúc phân tầng backend (entities / use-cases / repository).
   Kiến trúc của Godot **là** scene composition + autoload. Dự án đã theo đúng rồi.
2. ❌ **Không** refactor đại trà nhiều mục cùng lúc. Mỗi giai đoạn một PR, có kiểm chứng.
3. ❌ **Không** làm mất các comment "tại sao" (mục 1.2).
4. ❌ **Không** động vào `CallResponse`, `SaveStore`, `GameState` — ba file này đã sạch.
   Sửa chúng là rủi ro thuần, không lợi ích.
5. ❌ **Không** bắt đầu khi cây làm việc còn 28 file sửa dở.
