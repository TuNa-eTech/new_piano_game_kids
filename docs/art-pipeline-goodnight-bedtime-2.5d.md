# QUY TRÌNH MỸ THUẬT 2.5D (GAME ART PIPELINE) & DANH MỤC ASSET PROMPT AI
# MÀN 10: CHÚC BÉ NGỦ NGON ("GOODNIGHT BEDTIME & SLEEPING PIANO DIORAMA")

> **Dự án**: Rừng Nhạc (Enchanted Music Forest) — Game Âm Nhạc Mầm Non 3–6 Tuổi  
> **Nguồn cảm hứng thiết kế**: [`docs/mock-goodnight-bedtime.jpeg`](file:///Users/anhtu/MySpace/new-piano/docs/mock-goodnight-bedtime.jpeg)  
> **Nền tảng mục tiêu**: Godot Engine 4.7+ (Forward Mobile / iOS Metal / Android Vulkan)  
> **Phong cách cốt lõi**: Cuốn Sách Nổi Ngủ Say 2.5D Diorama (Sleeping Pop-up Book & Animals)  
> **Tiêu chuẩn pháp lý & UX**: Apple Kids Category 1.3 (Nghi thức chúc ngủ ngon êm dịu, bảo vệ sức khỏe giấc ngủ trẻ em, khóa mở lại ứng dụng qua Cổng Phụ Huynh)

---

## PHẦN I: QUY TRÌNH MỸ THUẬT GAME 2.5D DÀNH CHO INDIE DEVELOPER (4 GIAI ĐOẠN)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                             2.5D GOODNIGHT BEDTIME ART PIPELINE                                 │
├───────────────────┬───────────────────┬───────────────────────────┬─────────────────────────────┤
│    1. CONCEPT     │    2. CREATION    │       3. CONVERSION       │     4. ASSET MANAGEMENT     │
│                   │                   │                           │                             │
│ • Bedtime Ritual  │ • Master Prompts  │ • AI Alpha Matting        │ • Godot 4.7 Import Presets  │
│ • Sleeping Book   │ • Grid Batching   │ • Defringe & Edge Dilation│ • Layer 18 Bedtime Modal    │
│ • Closed Eyes Keys│ • Style Lock      │ • Normal / ORM / Metal    │ • AudioDirector Lullaby     │
│ • Color Extraction│ • Neg-Prompt Safe │ • Texture Atlas Packing   │ • Apple Touch Target ≥ 88 pt│
└───────────────────┴───────────────────┴───────────────────────────┴─────────────────────────────┘
```

---

### Giai đoạn 1: Concept (Khái Niệm, Khóa Phong Cách Thị Giác & Nghi Thức Giờ Ngủ)

#### 1.1. Ngôn ngữ tạo hình & Không gian Sách Tranh Ngủ Say 2.5D (Sleeping Pop-Up Stage)
* **Thông điệp sư phạm & cảm xúc**: Kết thúc giờ chơi game một cách tích cực, không gây ức chế hay hụt hẫng cho bé mầm non. Thay vì thông báo khô khan *"Hết giờ"*, khu rừng âm nhạc cùng các bạn thú và Bé Phù Thủy đều **đi ngủ cùng bé**.
* **Cấu trúc 5 tầng thị giác chiều sâu 2.5D**:
  1. **Tầng 1 — Hậu cảnh Rừng Đêm Thanh Bình (Far Starlit Forest)**: Bầu trời đêm xanh lam thẫm ngập tràn sao, các ngôi nhà nấm nhỏ thắp đèn bí ngô vàng cam ấm áp, cành cây treo lồng đèn lung linh, đom đóm trôi nhẹ nhàng trong sương đêm.
  2. **Tầng 2 — Bảng Gỗ Lời Chúc Ngủ Ngon (Top Carved Sign Plaque)**: Bảng gỗ sồi uốn lượn phong cách cổ tích ở đỉnh màn hình: `Khu rừng đã ngủ say rồi. Chúc bé ngủ ngon! 🌙✨`.
  3. **Tầng 3 — Cuốn Sách Nổi 3D Bé Phù Thủy Say Giấc (Center Pop-up Book)**: Cuốn sách bìa da mạ vàng mở ra giữa màn hình, Bé Phù Thủy nằm ngủ ngon lành trên thân cây mục phủ rêu xanh, ôm bạn Sư Tử con vào lòng dưới chăn lá vàng ấm áp. Bên cạnh là Cây Đậu Thần phát sáng trắng dịu với **Dải Khuông Nhạc & Nốt Nhạc Pastel Bay Bổng** uốn lượn mềm mại.
  4. **Tầng 4 — Bàn Phím Đàn Gỗ Ngủ Say (Sleeping Animals Wooden Piano)**: Bàn phím đàn đồ chơi bằng gỗ bên dưới màn hình. Cả 7 bạn thú đại diện cho 7 nốt nhạc (`Sư tử, Gấu, Thỏ, Mèo, Khỉ, Voi, Cú`) đều **nhắm mắt mỉm cười say giấc nồng**. Các chữ nốt C-D-E-F-G-A-B phát sáng dịu nhẹ. Khi bé chạm nhẹ vào phím đàn, phím phát ra tiếng chuông ru ngủ êm ái kèm bong bóng chữ "Zzz" bay lên.
  5. **Tầng 5 — Cụm Nút Xúc Giác Gỗ Tròn (Tactile Wood Circle Buttons)**:
     - Nút `BACK` (Mũi tên quay lại): Kết nối trực tiếp đến **Cổng Phụ Huynh (Parental Gate)** để phụ huynh mở khóa nếu cần.
     - Nút `SOUND` (Loa âm thanh): Bật/Tắt giai điệu nhạc ru ngủ.

#### 1.2. Bảng Màu Chuẩn (Lượng Tử Hóa Từ `mock-goodnight-bedtime.jpeg`)
| Tên Màu | Mã Hex | Ứng Dụng Trong Màn 10 | Cảm Xúc & Tâm Lý |
|---|---|---|---|
| **Xanh Đêm Lam Thẫm** | `#0D1C2E` / `#162E48` | Bầu trời đêm, phông nền rừng, bìa sách | Êm dịu, giảm hưng phấn thần kinh, ru ngủ |
| **Cam Vàng Đèn Lồng** | `#FFA43B` / `#FFC857` | Lồng đèn bí ngô, ánh sáng cửa sổ | Ấm áp, cảm giác an toàn như vòng tay mẹ |
| **Trắng Bạc Ánh Trăng** | `#E6F3FA` / `#FFFDF0` | Cây đậu thần phát sáng, dải nốt nhạc ru | Huyền ảo, tinh khôi, thanh tịnh |
| **Kem Thớ Gỗ Phím Đàn** | `#F8E5C4` / `#E8CF9F` | Bề mặt 7 phím đàn thú ngủ say | Mộc mạc, xúc giác đồ chơi gỗ tự nhiên |
| **Nâu Gỗ Sồi Cổ** | `#52321C` / `#744525` | Khung đàn, bảng gỗ tiêu đề, nút tròn | Chắc chắn, bao bọc, thân thuộc |
| **Cầu Vồng Pastel Ru Ngủ**| `#F28E9B` / `#7AC7E7` | Dải nốt nhạc bay từ cây đậu thần | Rực rỡ nhưng dịu mắt, gợi giấc mơ đẹp |

---

## PHẦN II: CREATION (DANH MỤC MASTER PROMPT AI CHO MÀN 10)

### 2.1. Master Prompt Xương Sống Cho Màn 10
```
[CHỦ THỂ CỤ THỂ], layered 2.5D diorama storybook pop-up asset for bedtime ritual in a preschool music game. Cozy sleeping atmosphere, gentle moonlight and warm lantern glow, chunky rounded wooden toy aesthetic, soft dark outlines (never harsh black), peaceful relaxed mood. Palette: starlit night blue #0D1C2E, warm pumpkin lantern gold #FFA43B, moonlit white #E6F3FA, toy wood cream #F8E5C4, dark rustic oak #52321C. Clean solid white background, centered, isolated asset cutout, orthographic pop-up book view, zero artifacts --ar [TỈ LỆ] --style raw
```

### 2.2. Danh Mục 6 Master Prompts Cho Đồ Họa 2.5D
* **Prompt AI 01 — Cuốn Sách Nổi Bé Phù Thủy Ngủ Say (`book_sleeping_boy_beanstalk`)**:
  > `An open whimsical fairytale pop-up book displaying a serene bedtime scene. Inside, an adorable cartoon boy wizard sleeps peacefully curled up on a mossy log bed, hugging a cute plush baby lion cub under a cozy golden leaf blanket. Beside him grows a luminous white magical beanstalk tree. A swirling spiral of colorful pastel musical staff lines and glowing notes drifts from the tree. Warm storybook illustration, cozy lighting, isolated on solid white background --ar 16:9 --style raw`

* **Prompt AI 02 — Bảng Gỗ Tiêu Đề Lời Chúc Ngủ Ngon (`plaque_goodnight_wood_banner`)**:
  > `A charming hand-carved rustic dark oak wooden plaque banner shaped like a fairytale storybook sign. At the top are carved scroll ornaments with a small crescent moon and stars emblem. The surface is warm carved wood. Tactile preschool UI plaque, warm ambient evening light, isolated on pure white background --ar 3:1 --style raw`

* **Prompt AI 03 — Bàn Phím Đàn Gỗ 7 Bạn Thú Ngủ Say (`keys_piano_sleeping_animals`)**:
  > `A toy wooden piano keyboard with seven chunky cream-colored keys. On each key is an adorable cartoon animal face with eyes gently closed, smiling soundly in their sleep: lion, bear, rabbit, cat, monkey, elephant, owl. Below each animal is a soft colorful pastel circle with musical letters C, D, E, F, G, A, B. Tactile chunky wooden toy piano, smooth rounded edges, warm soft lighting, isolated on white background --ar 4:1 --style raw`

* **Prompt AI 04 — Nút Tròn Gỗ Mũi Tên Quay Lại (`ui_btn_wood_circle_back`)**:
  > `A chunky circular dark oak wooden button with an embossed light-cream curved arrow pointing left, labeled 'BACK' underneath. Tactile physical toy button, rounded bevels, preschool game navigation button, isolated on pure white background --ar 1:1 --style raw`

* **Prompt AI 05 — Nút Tròn Gỗ Loa Âm Thanh (`ui_btn_wood_circle_sound`)**:
  > `A chunky circular dark oak wooden button with an embossed light-cream speaker icon with gentle sound waves, labeled 'SOUND' underneath. Tactile physical toy button, rounded bevels, preschool game audio toggle, isolated on pure white background --ar 1:1 --style raw`

* **Prompt AI 06 — Phông Nền Toàn Cảnh Rừng Đêm Ngủ Ngon (`bg_goodnight_forest_25d`)**:
  > `Fairytale enchanted forest at deep peaceful twilight starlit night. Whimsical cottages with glowing pumpkin lantern windows nestled among ancient mossy trees. Warm carved pumpkin lanterns hang from sturdy branches, magical glowing fireflies hover lazily in the indigo evening air. Cozy, quiet, serene bedtime atmosphere, 16:9 panoramic wallpaper --ar 16:9 --style raw`

---

## PHẦN III: CONVERSION & AUDIO PIPELINE

### 3.1. Kỹ Thuật Tách Lớp & Xử Lý Alpha
* Tách riêng 3 thành phần chuyển động:
  - Trang sách mở có nhịp thở phập phồng của bé phù thủy.
  - Dải nốt nhạc cầu vồng có shader lấp lánh (Shimmer Note Trail Shader).
  - Bàn phím đàn thú nhắm mắt có tương tác nảy lò xo khi chạm.

### 3.2. Âm Thanh Ru Ngủ & Phản Hồi Xúc Giác (AudioDirector & Suno)
* **BGM Ru Ngủ (`lullaby_night_forest.ogg`)**:
  > Tiếng đàn Harp và hộp nhạc Celesta ngân nga giai điệu ngũ cung chậm rãi (52 BPM), hòa cùng tiếng dế mèn đêm rừng êm dịu, không có âm sắc gắt.
* **SFX Phím Đàn Ngủ**:
  - Khi bé bấm vào các phím thú: Âm sắc đàn piano/kalimba được lọc thông thấp (Low-pass filter 800 Hz) tạo cảm giác êm ái, kèm tiếng thở khò khè nhỏ đáng yêu.

---

## PHẦN IV: ASSET MANAGEMENT & GODOT 4.7 INTEGRATION

* **Vị trí Node & Layer**:
  - `layer = 18` (Che phủ toàn bộ màn chơi chính khi hết giờ hẹn).
* **Luồng Tương Tác Chuẩn Apple Kids Category 1.3**:
  - Nhấn nút `BACK` hoặc nút Đánh Thức: Không tự ý mở app ngay mà kích hoạt **Cổng Phụ Huynh (`ParentalGate`, layer 20)**.
  - Phụ huynh chạm đúng 3 quả dâu tây -> Cổng mở -> Màn Chúc Bé Ngủ Ngon đóng lại và reset bộ đếm giờ.
