# QUY TRÌNH MỸ THUẬT 2.5D (GAME ART PIPELINE) & DANH MỤC ASSET PROMPT AI
# MÀN 09: GÓC PHỤ HUYNH ("PARENTAL CORNER & COZY BEDTIME CONTROL")

> **Dự án**: Rừng Nhạc (Enchanted Music Forest) — Game Âm Nhạc Mầm Non 3–6 Tuổi  
> **Nguồn cảm hứng thiết kế**: [`docs/mock-parental-corner.jpeg`](file:///Users/anhtu/MySpace/new-piano/docs/mock-parental-corner.jpeg)  
> **Nền tảng mục tiêu**: Godot Engine 4.7+ (Mobile / iOS Metal / Android Vulkan)  
> **Phong cách cốt lõi**: Bàn Gỗ Chạm Khắc 2.5D Diorama, Điều Khiển Xúc Giác Ấm Áp (Tactile Wood Controls)  
> **Tiêu chuẩn pháp lý & UX**: Apple Kids Category 1.3 (Được bảo vệ bởi Cổng Phụ Huynh Màn 08, giao diện thân thiện, bảo vệ giấc ngủ và thính giác của trẻ)

---

## PHẦN I: QUY TRÌNH MỸ THUẬT GAME 2.5D DÀNH CHO INDIE DEVELOPER (4 GIAI ĐOẠN)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                             2.5D PARENTAL CORNER ART PIPELINE                                   │
├───────────────────┬───────────────────┬───────────────────────────┬─────────────────────────────┤
│    1. CONCEPT     │    2. CREATION    │       3. CONVERSION       │     4. ASSET MANAGEMENT     │
│                   │                   │                           │                             │
│ • Cozy Night Mood │ • Master Prompts  │ • AI Alpha Matting        │ • Godot 4.7 Import Presets  │
│ • Wood Relief Desk│ • Grid Batching   │ • Defringe & Edge Dilation│ • Layer 19 Modal Overlay    │
│ • Tactile Dials   │ • Style Lock      │ • Normal / ORM / Metal    │ • AudioServer & GameState   │
│ • Color Extraction│ • Neg-Prompt Safe │ • Texture Atlas Packing   │ • Touch Target ≥ 88 pt      │
└───────────────────┴───────────────────┴───────────────────────────┴─────────────────────────────┘
```

---

### Giai đoạn 1: Concept (Khái Niệm, Khóa Phong Cách Thị Giác & Bố Cục 2.5D)

#### 1.1. Ngôn ngữ tạo hình & Không gian Bàn Gỗ Cổ Thụ 2.5D Diorama
* **Không gian tổng thể**: Một góc thung lũng rừng đêm thanh bình, trăng sao vằng vặc, đèn lồng bí ngô phát ánh sáng vàng ấm áp từ các ngôi nhà nấm nhỏ. Ở trung tâm là chiếc **Bàn Gỗ Sồi Chạm Khắc** đặt trên bậc gỗ vững chãi.
* **Cấu trúc 5 tầng thị giác chiều sâu 2.5D**:
  1. **Tầng 1 — Hậu cảnh Rừng Đêm (Far Night Forest Background)**: Rừng cổ thụ đêm, bầu trời xanh chàm lấp lánh đom đóm, 2 ngôi nhà cổ tích có cửa sổ sáng đèn, tinh thể đá lam ngọc bên trái, rương báu bằng gỗ bên phải.
  2. **Tầng 2 — Bàn Gỗ Chạm Khắc Phù Điêu (Oak Relief Desk)**: Bàn gỗ sồi uốn lượn phong cách Baroque với họa tiết dây leo, chạm nổi hình **Chú Gấu Con Đang Say Giấc** ở bệ đỡ dưới đáy. Tấm biển da dê uốn lượn mang tiêu đề `GÓC PHỤ HUYNH`.
  3. **Tầng 3 — Cụm Điều Khiển Xúc Giác (Tactile Controls Panel)**:
     - **Thanh trượt Âm lượng (Volume Slider)**: Rãnh trượt gỗ thẳng đứng kèm núm gạt gỗ bo tròn, hai biểu tượng loa nhỏ / to.
     - **Đĩa quay Hẹn Giờ Ngủ (Bedtime Timer Dial)**: Vòng tròn gỗ chạm khắc viền xoay, ánh sáng vàng kim tỏa ra từ bên trong, biểu tượng Mặt Trăng Nhắm Mắt Ngủ kèm Ngôi Sao Vàng, số hiển thị `15 Phút` (chu kỳ: Tắt / 15 / 30 / 45 / 60 phút).
     - **Công tắc Nhạc Ru Ngủ (Lullaby Toggles)**: Cụm nút gạt bo tròn viên thuốc hình gỗ công thái học (Bật/Tắt nhạc ru ngủ và Chọn giai điệu).
  4. **Tầng 4 — Mascot Bé Phù Thủy Ngủ Ngon (Sleeping Wizard Boy)**: Nằm bên phải bàn gỗ trên chiếc giường gốc cây phủ rêu xanh và chăn lá mềm, tay ôm chú sư tử bông nhỏ, cạnh chiếc đèn lồng dầu thắp sáng dịu êm.
  5. **Tầng 5 — Thanh Tiêu Đề Góc Trên (Header Bar)**:
     - Khay bộ sưu tập nhạc cụ (Violin, Sáo trúc, Trống, Kèn, Đàn Harp).
     - Bảng gỗ ghi ngày tháng & trạng thái.
     - Nút Home (Nhà hồng) và Nút Levels (Ngôi sao 1-2-3).

#### 1.2. Bảng Màu Chuẩn (Lượng Tử Hóa Từ `mock-parental-corner.jpeg`)
| Tên Màu | Mã Hex | Ứng Dụng Trong Màn 09 | Cảm Xúc & Tâm Lý |
|---|---|---|---|
| **Nâu Gỗ Sồi Cổ** | `#5A3319` / `#7B4825` | Khung bàn gỗ, viền đĩa quay, núm slider | Ấm cúng, mộc mạc, vững chắc |
| **Giấy Da Dê Vàng Nhạt** | `#FBF2DB` / `#ECDAB7` | Mặt bảng điều khiển, tấm biển chữ | Tương phản êm dịu cho mắt ban đêm |
| **Vàng Hào Quang Đèn** | `#FFD768` / `#F5A623` | Viền đĩa quay giờ ngủ, đèn lồng, mặt trăng | Ấm áp, thư thái, dịu êm |
| **Xanh Chàm Rừng Đêm** | `#14293D` / `#0C1824` | Phông nền rừng, bầu trời, mái nhà | Thư giãn, báo hiệu giờ ngủ của bé |
| **Rêu Xanh Êm Ả** | `#457B3B` / `#2F5927` | Giường rêu của bé phù thủy, chăn lá cây | Thiên nhiên trong lành, bình yên |
| **Lam Ngọc Pha Lê** | `#42B6D9` / `#2682A8` | Tinh thể pha lê lấp lánh góc trái | Kỳ ảo, ma thuật nhẹ nhàng |
| **Xanh Đêm Sao Ngủ** | `#2B3B6B` | Bộ đồ ngủ pajama sao vàng của bé phù thủy | Thân thương, ấm áp tuổi thơ |

---

## PHẦN II: CREATION (DANH MỤC MASTER PROMPT AI CHO MÀN 09)

### 2.1. Master Prompt Xương Sống Cho Màn 09
```
[CHỦ THỂ CỤ THỂ], layered 2.5D diorama storybook asset for bedtime settings in a preschool music game. Warm cozy fairytale aesthetic, hand-carved oak wood details, soft ambient evening lighting from lanterns, gentle rounded organic bevels, no harsh shadows. Palette: dark rustic oak #5A3319, warm parchment #FBF2DB, glowing amber gold #FFD768, moss green #457B3B, night indigo #14293D. Clean solid white background, centered, isolated asset cutout, orthographic pop-up book view, zero artifacts --ar [TỈ LỆ] --style raw
```

### 2.2. Danh Mục 6 Master Prompts Cho Đồ Họa 2.5D
* **Prompt AI 01 — Bàn Gỗ Chạm Khắc Phù Điêu Gấu Ngủ (`board_parental_desk_relief`)**:
  > `An ornate hand-carved dark oak wooden desk frame standing on rustic wooden deck steps for a preschool game UI. The top has an arched header with a whimsical parchment scroll banner. The thick wooden border features carved botanical leaf motifs, and at the bottom edge is an adorable wood relief carving of a tiny cozy baby bear cub sleeping curled up. Inside is a large warm cream parchment rectangular board with soft rounded corners. Tactile wooden diorama look, warm golden lantern lighting, clean white background, isolated cutout --ar 16:9 --style raw`

* **Prompt AI 02 — Đĩa Quay Hẹn Giờ Mặt Trăng Ru Ngủ (`dial_timer_moon_ring`)**:
  > `A circular chunky wooden clock timer dial knob for a bedtime app. The outer rim is beveled dark carved wood with subtle graduation notches. The center is warm glowing parchment with an amber halo ring. Above the dial sits an embossed golden crescent moon with eyes gently closed asleep, accompanied by a small smiling star. Tactile physical wooden toy knob, preschool cozy bedtime UI, isolated on pure white background --ar 1:1 --style raw`

* **Prompt AI 03 — Cụm Thanh Trượt Âm Lượng Gỗ Xúc Giác (`ui_volume_slider_wood`)**:
  > `A vertical wooden volume slider control for a children's audio app. A recessed vertical groove cut into warm cream wood, with a chunky rounded dark oak slider thumb knob in the middle. At the bottom is a small carved wooden low-volume speaker icon, and at the top a high-volume speaker icon with sound waves. Tactile toy wood finish, soft drop shadows, clean white background, isolated --ar 1:3 --style raw`

* **Prompt AI 04 — Công Tắc Viên Thuốc Gỗ Nhạc Ru Ngủ (`ui_toggle_pill_switch`)**:
  > `Two chunky pill-shaped wooden toggle switches for a preschool game settings menu. The top switch is in active state with a soft green indicator and wooden checkmark and pause symbols. The bottom switch is in natural oak finish with a musical eighth note icon. Rounded organic pill shape, tactile wooden bevel, warm studio lighting, clean white background, isolated --ar 2:1 --style raw`

* **Prompt AI 05 — Bé Phù Thủy Say Giấc Nồng Ôm Sư Tử (`char_sleeping_wizard_bed`)**:
  > `An adorable little cartoon boy wizard sleeping soundly on a cozy mossy tree stump bed. He wears dark blue starry pajamas and a purple floppy wizard hat tilted back. He cuddles a small cute plush toy lion cub against his cheek, covered with a soft green leaf blanket. A glowing brass oil lantern rests beside him casting warm amber light on his peaceful smiling face. Storybook illustration, cozy bedtime atmosphere, isolated on white background --ar 1:1 --style raw`

* **Prompt AI 06 — Phông Nền Toàn Cảnh Rừng Đêm Bình Yên (`bg_parental_corner_forest_25d`)**:
  > `Fairytale enchanted forest clearing at quiet starlit night. Cozy whimsical cottages with warm lit lantern windows nestled under ancient oak trees. Glowing warm lanterns hang from sturdy branches, magical fireflies drift lazily in the indigo air. On the left is a tree stump with glowing cyan crystals, on the right a wooden treasure chest on the grass. Peaceful, serene, comforting bedtime aesthetic, no characters in center, 16:9 wide background --ar 16:9 --style raw`

---

## PHẦN III: CONVERSION & AUDIO PIPELINE

### 3.1. Kỹ Thuật Tách Lớp & Xử Lý Alpha
* Tách riêng bệ đỡ gỗ, đĩa tròn hẹn giờ, núm trượt âm lượng và mascot bé phù thủy để có thể nhún nhảy độc lập theo nhịp thở.
* Khử viền răng cưa (Alpha Defringe & Edge Bleed Dilation 2px) bảo đảm hiển thị trong suốt hoàn hảo trên mọi nền.

### 3.2. Âm Thanh Ru Ngủ & Phản Hồi Xúc Giác (Suno / ElevenLabs / Godot Audio)
* **Nhạc Ru Ngủ (`lullaby_music_box.ogg`)**:
  > **Prompt Suno AI**: `Soothing gentle bedtime lullaby for toddlers, delicate celesta, music box, acoustic harp, warm strings, slow 60 BPM, peaceful, comforting, looping ambient sleep track, no drums, no sudden brass`
* **SFX Xúc Giác Gỗ**:
  - `slider_slide.wav`: Tiếng trượt ma sát gỗ mượt mà, tần số trầm ấm ($180\text{ Hz}$).
  - `dial_click.wav`: Tiếng nấc xoay bánh răng gỗ tinh xảo ("Lách tách").
  - `toggle_pop.wav`: Tiếng bật nảy nhẹ của nút công tắc viên thuốc.
  - `snore_sigh.wav`: Tiếng thở phào nhẹ nhõm cực êm ái của bé phù thủy khi chạm vào.

---

## PHẦN IV: ASSET MANAGEMENT & GODOT 4.7 INTEGRATION

* **Vị trí Node & Layer**:
  - `layer = 19` (Nằm ngay dưới Cổng Phụ Huynh `layer = 20` và trên Goodnight Screen `layer = 18`).
* **Liên kết Hệ Thống**:
  - **Âm lượng**: Điều khiển trực tiếp `AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)`.
  - **Hẹn giờ ngủ**: Kết nối với `GameState.set_bedtime_timer(minutes)`. Khi đồng hồ đếm lùi về 0, phát tín hiệu `bedtime_expired` kích hoạt Goodnight Screen.
  - **Bé Phù Thủy Xúc Giác**: Nhấn vào bé phù thủy sẽ phát nhịp thở nảy nhẹ và tiếng thở êm dịu, sinh chùm sao ru ngủ.
