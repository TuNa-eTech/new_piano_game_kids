# QUY TRÌNH MỸ THUẬT 2.5D (GAME ART PIPELINE) & DANH MỤC ASSET PROMPT AI
# MÀN HÌNH CHƠI TỰ DO: "SÂN KHẤU SÁNG TÁC NHẠC TỰ DO" (FREE PLAY / JAM PARTY)

> **Tài liệu đặc tả**: Quy trình từ Concept $\rightarrow$ Creation $\rightarrow$ Conversion $\rightarrow$ Asset Management cho Game 2.5D  
> **Nguồn cảm hứng thiết kế**: [`docs/mock-free-play.jpeg`](file:///Users/anhtu/MySpace/new-piano/docs/mock-free-play.jpeg) — Màn 03: Sân Khấu Chơi Tự Do  
> **Engine mục tiêu**: Godot Engine 4.7+ (Forward Mobile / iOS Metal / Android Vulkan)  
> **Đối tượng người chơi**: Trẻ em 3–6 tuổi (Triết lý Zero-Text, trực quan hóa 100%, tự do sáng tác, không áp lực điểm số hay chấm phạt)

---

## PHẦN I: QUY TRÌNH MỸ THUẬT GAME 2.5D DÀNH CHO INDIE DEVELOPER

Quy trình mỹ thuật 2.5D (2.5D Diorama Pop-up Pipeline) cho Màn 03 được chuẩn hóa thành 4 giai đoạn khép kín, tối ưu hóa công sức cho lập trình viên độc lập thông qua việc phối hợp giữa trí tuệ nhân tạo (Generative AI) sinh hình ảnh/âm thanh và kỹ thuật xử lý shader, ánh sáng động CanvasItem trong Godot 4.7.

```
┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│                           2.5D GAME ART PIPELINE — MÀN 03 FREE PLAY                            │
├───────────────────┬───────────────────┬───────────────────────────┬────────────────────────────┤
│    1. CONCEPT     │    2. CREATION    │       3. CONVERSION       │    4. ASSET MANAGEMENT     │
│                   │                   │                           │                            │
│ • Style Lock      │ • Master Prompts  │ • AI Alpha Matting        │ • Naming Conventions       │
│ • Color Extraction│ • Grid Batching   │ • Defringe & Color Bleed  │ • Godot 4.7 Import Presets │
│ • 2.5D Tilt Plane │ • Seed & StyleRef │ • Normal / Depth / Height │ • Z-Index & CanvasLayer    │
│ • Zero-Text UX    │ • Neg-Prompt Safe │ • Texture Atlas & Sheets  │ • Performance Budgets      │
└───────────────────┴───────────────────┴───────────────────────────┴────────────────────────────┘
```

---

### Giai đoạn 1: Concept (Khái Niệm, Khóa Phong Cách Thị Giác & Chiều Sâu 2.5D)

#### 1.1. Ngôn ngữ tạo hình & Không gian 2.5D Sân khấu Sách Nổi (Pop-up Book Diorama)
* **Góc nhìn 2.5D**: Chiếu nghiêng góc phối cảnh $15^\circ - 20^\circ$ (Isometric / Oblique Tilt) nhìn từ trên xuống cuốn sách tranh mở trên bàn gỗ sồi cổ tích.
* **Cấu trúc không gian 4 tầng chiều sâu**:
  1. **Hậu cảnh sâu (Far Background - Parallax Scale 0.05)**:
     - Tán rừng cổ tích lúc chập tối (Twilight Enchanted Forest) ngập tràn ánh xanh ngọc thẫm và xanh mòng két.
     - Các dây đèn lồng (fairy string lights) giăng mắc giữa các nhánh cây cổ thụ, phát ra các điểm sáng màu đỏ, vàng, ngọc bích, tím hồng lung linh.
  2. **Trung cảnh hậu (Mid-Background - Parallax Scale 0.15)**:
     - Hai ngôi nhà gỗ nấm cổ tích hai bên: Ngôi nhà bên trái với mái vòm nhọn nấm hồng, cửa vòm xanh ngọc; Ngôi nhà bên phải mái ngói gỗ xếp lớp. Cả hai đều có cửa sổ tròn phát ra ánh sáng vàng mật ong ấm áp.
     - Rương gỗ cổ điển đặt trên thảm cỏ hoa ven bìa rừng bên phải.
  3. **Trung cảnh chính (Midground / Book Stage Plane - Parallax Scale 0.6)**:
     - Cuốn sách cổ tích khổng lồ mở đôi với gáy sách uốn cong và viền mạ vàng hoa văn:
       - **Trang trái**: Bé Phù Thủy mặc áo choàng và mũ chóp tím với các ngôi sao vàng, **đeo kính mắt hình ngôi sao vàng vui nhộn**, đang hăng say lướt tay trên chiếc đàn piano mini bằng gỗ quý. Từ chiếc đàn mini tỏa ra các dải sóng cầu vồng ngũ sắc rực rỡ. Phía trên có khung bóng thoại viền mềm mại: *"Thỏa thích sáng tác nhạc nào! 🎵"*.
       - **Trang phải**: Cây Đậu Thần Âm Nhạc (Musical Beanstalk) uốn lượn vươn lên với các nốt nhạc phát sáng (♪, ♫, ♬) màu hồng cánh sen, xanh ngọc và vàng kim nở rộ như những chiếc lá/quả thần.
       - **Bong bóng âm nhạc (Musical Floating Bubbles)**: Hàng loạt bong bóng xà phòng ngũ sắc óng ánh bay lơ lửng từ cuốn sách lên không trung, bên trong mỗi bong bóng chứa một ký hiệu nốt nhạc đang phát quang.
       - **Dải lụa khuông nhạc cầu vồng (Rainbow Musical Ribbon)**: Dải sóng nhạc uốn lượn mềm mại mang theo các nốt nhạc phát sáng kết nối từ bàn phím đàn tiền cảnh bay vút lên quấn quanh cây đậu thần.
  4. **Tiền cảnh (Foreground / Keybed & Header Plane - Parallax Scale 1.0)**:
     - **Thanh 4 Nhạc Cụ Gỗ (Top Instrument Bar)**: Khung gỗ chạm khắc thủ công đặt ở vị trí trung tâm trên cùng màn hình, chứa 4 nút nhạc cụ:
       1. **Đại Cầm** (Grand Piano)
       2. **Đàn Kalimba Gỗ** (Wooden Kalimba)
       3. **Chuông Pha Lê** (Crystal Bell)
       4. **Giọng Thú Ngộ Nghĩnh** (Funny Animal Voices - Biểu tượng bạn Khỉ vui nhộn)
     - **Bục đàn piano gỗ chạm khắc**: Thân đàn bằng gỗ sồi ấm áp với hoa văn xoắn ốc hai bên đầu đàn.
     - **Dàn phím đàn Cầu Vồng (Rainbow Keys)**: Toàn bộ các phím trắng mang dải màu cầu vồng pastel ngọt ngào (Hồng pastel, Cam đào, Vàng kem, Xanh lá non, Bạc hà, Xanh lơ, Xanh da trời, Hồng san hô, Xanh mạ, Vàng bơ, Tím oải hương).
     - **Phím đen 3D vát cạnh**: 7 phím đen màu nâu chocolate thẫm bo tròn cạnh tạo cảm giác xúc giác cơ học.
     - **Cụm tinh thể thạch anh hai bên**: Thạch anh xanh ngọc (Cyan) trên gốc cây mục góc trái, Thạch anh hồng tím (Magenta) góc phải.

#### 1.2. Bảng Màu Chuẩn (Hút Trực Tiếp Từ `mock-free-play.jpeg`)
* **Tone Nền Rừng Chập Tối (Twilight Forest)**:
  - `#0B2D38` / `#0E434D`: Xanh mòng két thẫm (Deep Teal forest sky).
  - `#1A5B5A` / `#237C6E`: Xanh rêu huyền bí của tán cây và thảm cỏ.
  - `#FFE67A` / `#FFAB3D`: Ánh sáng vàng ấm phát ra từ cửa sổ ngôi nhà cổ tích.
* **Tone Gỗ Sồi Chạm Khắc & Khung Thanh Nhạc Cụ**:
  - `#784428` / `#5A331E`: Nâu gỗ sồi ấm áp của thân đàn và thanh tiêu đề.
  - `#9B5D38` / `#B8754A`: Đường viền vát cạnh và vân gỗ nổi.
  - `#E6C387` / `#D4A76A`: Màu vàng kim mạ nổi trên viền và chốt kim loại.
* **Tone Dàn Phím Cầu Vồng Pastel (Rainbow Keys)**:
  - Phím 1 (Do - C4): Hồng pastel `#F7B5D5`
  - Phím 2 (Re - D4): Cam đào `#FAC8A8`
  - Phím 3 (Mi - E4): Vàng kem `#FDF0A6`
  - Phím 4 (Fa - F4): Xanh lá non `#C4E8A3`
  - Phím 5 (Sol - G4): Bạc hà `#A5E6CE`
  - Phím 6 (La - A4): Xanh lơ nhạt `#A0DCF7`
  - Phím 7 (Si - B4): Xanh thiên thanh `#9BB8F5`
  - Phím 8 (Do2 - C5): Hồng san hô dịu `#F7AFA8`
  - Phím 9 (Re2 - D5): Xanh mạ ngọt `#B2E7AA`
  - Phím 10 (Mi2 - E5): Vàng bơ `#FDF3A7`
  - Phím 11 (Fa2 - F5): Tím oải hương `#DDB3F7`
* **Tone Phím Đen & Tinh Thể**:
  - `#2D1C1B` / `#3D2725`: Nâu đen chocolate của 7 phím bấm nổi khối.
  - `#32E6D4` / `#48F2E2`: Tinh thể thạch anh xanh Cyan phát sáng góc trái.
  - `#E656B8` / `#F77BD2`: Tinh thể thạch anh hồng Magenta phát sáng góc phải.
* **Tone Kính Ngôi Sao & Cầu Vồng Đàn**:
  - `#FFDC33` / `#FFB800`: Vàng tươi của kính mắt ngôi sao chú phù thủy.
  - `#63409E` / `#7B52C4`: Tím vương giả của áo choàng và mũ phù thủy.

---

### Giai đoạn 2: Creation (Tạo Hình Bằng AI Prompt Kỹ Thuật Cao)

#### 2.1. Quy tắc sinh theo Lô (Grid Batch Generation)
* Không sinh rời rạc từng icon hay nút bấm để đảm bảo độ dày nét viền, góc chiếu sáng và vật liệu gỗ/pha lê đồng nhất tuyệt đối.
* Gom 4 nút nhạc cụ lên cùng một tấm dạng Grid (`4-slot instrument tray layout`), các bong bóng âm nhạc lên cùng một sheet.
* Luôn sử dụng tham số Style Reference:
  - **Midjourney v6**: `--sref docs/mock-free-play.jpeg --sw 900 --c 3 --style raw`
  - **Flux.1 / SDXL**: Sử dụng bộ LoRA `children_storybook_clay_diorama`, Euler a, CFG Scale 5.5, Clip Skip 2.

#### 2.2. Master Prompt Framework (Khung Prompt Xương Sống)
```
[CHỦ THỂ CỤ THỂ], layered 2.5D diorama pop-up storybook illustration for preschool music app, whimsical fairytale art style, charming rounded forms, soft darker outline (no pure black), warm top-down diffused daylight with glowing rim lights, rich vibrant friendly colors: warm oak wood #784428, glowing turquoise cyan #32E6D4, magenta crystal #E656B8, rainbow pastel keys, deep twilight teal forest #0B2D38 with colorful glowing fairy lights, clean pure solid white background, orthographic diorama asset cutout, zero artifacts, high resolution --ar [TỈ LỆ] --style raw
```

#### 2.3. Negative Prompt Master (Bộ Từ Khóa Phủ Định Chuẩn)
```
photorealistic, 3d low-poly wireframe, harsh black borders, human realism, scary expressions, sharp edges, dark horror, violent themes, glitch, messy noisy textures, complex mechanical clutter, pixelated, washed-out desaturated colors, cropped, out of frame, signature, watermark, logo, gibberish text
```

---

### Giai đoạn 3: Conversion (Hậu Kỳ, Alpha Matting, PBR Normal Map & Đóng Gói)

#### 3.1. Alpha Matting & Defringing (Tách Nền & Khử Viền)
* Sử dụng mô hình `BiRefNet` / `Rembg (U2Net)` để trích xuất kênh Alpha với độ chính xác cao.
* **Khử viền trắng (Defringe / Color Bleed)**: Mở rộng các pixel màu ở biên ảnh thêm 2–3px vào vùng trong suốt để loại bỏ hoàn toàn viền xám khi texture được lọc tuyến tính (Bilinear filtering) trên màn hình Retina / High-DPI.

#### 3.2. Sinh Bản Đồ Chiều Sâu & Normal Map Cho CanvasItem 2.5D
* Sinh **Normal Map** cho:
  - Thân đàn gỗ chạm khắc và các phím đàn nổi khối 3D.
  - Thanh khung gỗ 4 nhạc cụ ở mép trên để bắt ánh sáng đèn đom đóm rọi xuống.
* Tạo **Emission Mask** (kênh RGB/Grayscale phát sáng) cho:
  - Tròng kính ngôi sao vàng của bé phù thủy.
  - Các nốt nhạc nở trên cây đậu thần và dải cầu vồng.
  - Các bóng đèn lồng giăng mắc trên cây rừng (Fairy string lights).
  - Tinh thể Cyan & Magenta.

#### 3.3. Đóng Gói Texture Atlas (Power of Two)
* Gom toàn bộ icon 4 nhạc cụ, các chi tiết bong bóng và hiệu ứng hạt vào Texture Atlas $2048 \times 2048\text{ px}$ (PoT).
* Giúp toàn bộ giao diện Màn 03 chỉ tiêu tốn 1–2 Draw Calls trên GPU di động.

---

### Giai đoạn 4: Asset Management (Quản Lý & Tích Hợp Vào Godot 4.7)

#### 4.1. Quy Ước Đặt Tên Chuẩn (Godot Style Guide Compliant)
| Tiền tố | Thể loại | Ví dụ |
|---|---|---|
| `spr_` | 2D Sprite / Sheet hoạt cảnh | `spr_wizard_star_party.png`, `spr_musical_beanstalk.png` |
| `tex_` | Texture bề mặt / Nền / PBR | `tex_top_bar_wood_carving.png`, `tex_piano_rainbow_keys.png` |
| `ui_` | Giao diện người dùng / Icon / Button | `ui_bar_freeplay_frame.png`, `ui_icon_grand_piano.png` |
| `vfx_` | Hiệu ứng hạt / PackedScene | `vfx_soap_bubbles.tscn`, `vfx_rainbow_sparkle.tscn` |
| `sfx_` | Âm thanh hiệu ứng (.wav 16-bit) | `sfx_bubble_pop.wav`, `sfx_fairy_glissando.wav` |
| `bgm_` | Nhạc nền lặp (.ogg Vorbis) | `bgm_free_play_acoustic_jam.ogg` |
| `sh_` | Mã shader (.gdshader) | `sh_soap_bubble.gdshader`, `sh_rainbow_ribbon.gdshader` |

#### 4.2. Thiết Lập Import Trong Godot 4.7
* **UI & Phím Đàn (`ui_`, `spr_`)**:
  - `Compress Mode`: **Lossless (PNG)**.
  - `Mipmaps`: **Generate = false**.
  - `Filter`: **Linear** (mịn màng trên thiết bị di động).
* **Backgrounds Khổng Lồ (`tex_bg_`)**:
  - `Compress Mode`: **VRAM Compressed (ASTC / ETC2 / BPTC)**.
  - Giảm dung lượng bộ nhớ từ $30\text{MB}$ xuống còn $\sim 4.5\text{MB}$ mỗi texture lớn.

#### 4.3. Phân Lớp Z-Index & Scene Tree 2.5D Diorama Màn 03
```
FreePlayStage (Main Scene / Node2D)
├── EnvironmentParallax (CanvasGroup - Layer -30 .. -10)
│   ├── Layer -30: FarTwilightForest (Nền rừng chập tối + Fairy string lights giăng mắc)
│   ├── Layer -20: WhimsicalCottages (Nhà nấm trái & Nhà gỗ phải có đèn vàng ấm)
│   └── Layer -10: MossyWoodLedge (Bàn gỗ tiền cảnh + Rêu xanh + Nấm nhỏ)
├── DioramaBookStage (Node2D - Layer 0 .. 15)
│   ├── Layer 0: OpenGrimoireSpread (Cuốn sách tranh mở đôi viền mạ vàng)
│   ├── Layer 5: MusicalBeanstalk (Cây đậu thần âm nhạc mang nốt nhạc phát quang - Trang phải)
│   ├── Layer 8: WizardStarParty (Bé phù thủy đeo kính sao gõ đàn mini - Trang trái)
│   ├── Layer 10: RainbowWaves (Dải sóng cầu vồng tỏa ra từ đàn mini)
│   └── Layer 12: SpeechBubbleParty ("Thỏa thích sáng tác nhạc nào! 🎵")
├── VFXBubblesAndRibbon (CanvasGroup - Layer 15 .. 25)
│   ├── Layer 16: MagicRibbonRainbow (Dải lụa khuông nhạc cầu vồng nối từ phím lên cây)
│   ├── Layer 18: SoapBubblesWithNotes (Bong bóng xà phòng ngũ sắc óng ánh bay lên)
│   └── Layer 20: StarlightSparkles (Bụi sao lấp lánh nảy ra khi chạm phím)
├── ForegroundPiano (Control - Layer 30)
│   ├── PianoWoodBody (Thân đàn gỗ sồi chạm trổ uốn lượn hai bên)
│   ├── RainbowWhiteKeys (11 phím trắng màu pastel cầu vồng)
│   ├── BlackKeys (7 phím đen chocolate 3D nổi khối)
│   ├── CrystalCyan (Gốc cây thạch anh xanh Cyan góc trái)
│   ├── CrystalMagenta (Gốc cây thạch anh hồng Magenta góc phải)
│   └── ChestDecor (Rương gỗ cổ tích ven bìa cỏ phải)
└── HUDOverlay (CanvasLayer - Layer 100)
    └── FreePlayTopBar (Thanh 4 nhạc cụ chạm khắc gỗ ở giữa trên cùng)
        ├── Slot 0: Đại Cầm (Grand Piano)
        ├── Slot 1: Đàn Kalimba Gỗ (Wooden Kalimba)
        ├── Slot 2: Chuông Pha Lê (Crystal Bell)
        └── Slot 3: Giọng Thú Ngộ Nghĩnh (Funny Animal Voices / Bạn Khỉ)
```

#### 4.4. Ngân Sách Hiệu Năng Kỹ Thuật (Technical Performance Budgets)
* **Draw Calls**: $\le 20$ draw calls toàn màn hình.
* **VRAM**: $\le 110\text{MB}$ VRAM trên iOS/Android.
* **Khung hình (FPS)**: Cố định $60\text{ FPS}$ (hoặc $120\text{ FPS}$ ProMotion trên iPad Pro).
* **Độ trễ âm thanh (Touch-to-Audio Latency)**: $< 60\text{ ms}$ (sử dụng `AudioStreamPolyphonic` với sample `.wav` 16-bit 44.1kHz đã nạp sẵn vào RAM).

---

## PHẦN II: BREAKDOWN CHI TIẾT ASSET LIST & BỘ CÂU LỆNH PROMPT AI

### MỤC 1: 2.5D ASSETS (NHÂN VẬT, BỐI CẢNH, ĐẠO CỤ)

#### 1.1. Sprites & Sprite Sheets Nhân Vật & Đạo Cụ Động
| Tên Asset | Kích thước | Số frame / Dạng | Mục đích trong Godot |
|---|---|---|---|
| `spr_wizard_star_party.png` | $768 \times 768\text{ px}$ | Tĩnh / 4 frames thở | Bé phù thủy đeo kính ngôi sao vàng ngồi đàn mini |
| `spr_musical_beanstalk.png` | $800 \times 1000\text{ px}$ | Layered Sprite | Cây đậu thần âm nhạc uốn lượn mang lá nốt nhạc |
| `spr_bubble_notes_sheet.png` | $1024 \times 1024\text{ px}$ | Sheet $4 \times 4$ (16 icons) | Bong bóng xà phòng trong suốt chứa nốt nhạc ♪ ♫ ♬ |
| `spr_rainbow_arcs.png` | $512 \times 512\text{ px}$ | Tách rời 3 lớp | Vòng sóng cầu vồng tỏa ra từ đàn mini của phù thủy |

* **Prompt AI 01 — Bé Phù Thủy Đeo Kính Sao Vui Nhộn Chơi Đàn (`spr_wizard_star_party`)**:
  > **Prompt**: `Charming preschool boy wizard wearing large funny yellow star-shaped glasses, joyful wide smile, wearing a floppy dark purple wizard hat adorned with small glowing golden stars, rich purple cozy tunic with golden trim and bronze belt buckle. He is sitting happily at a miniature upright antique wooden piano, excitedly playing the piano keys with both hands. Colorful vibrant rainbow waves and glittering music notes burst out from the top of the mini piano. Children's storybook picture-book illustration, soft warm darker outlines, warm golden overhead lighting, clean pure white background, centered, isolated full body asset, orthographic diorama view --ar 1:1 --style raw`  
  > **Negative Prompt**: `realistic human face, adult, scary, sharp teeth, dark horror, photorealistic 3d render, wireframe, harsh black borders, watermark, signature, blurry, cropped`

* **Prompt AI 02 — Cây Đậu Thần Âm Nhạc Với Nốt Nhạc Phát Sáng (`spr_musical_beanstalk`)**:
  > **Prompt**: `Magical whimsical musical beanstalk tree vine growing in a spiral curve, fairytale storybook illustration. The winding emerald green vine trunk has broad stylized leaves that resemble glowing musical notes, blooming with glowing pink, bright cyan, and sparkling golden musical symbols (eighth notes, quarter notes, treble clef). Soft bioluminescent inner glow, fairy dust sparkles floating around the branches. Soft dark outlines, warm magical lighting, pure solid white background, vertical composition, isolated diorama plant asset --ar 3:4 --style raw`  
  > **Negative Prompt**: `thorny vines, dark sinister plants, wilted leaves, realistic bark photos, 3d polygon mesh, harsh black lines, watermark, cropped`

* **Prompt AI 03 — Bong Bóng Xà Phòng Ngũ Sắc Chứa Nốt Nhạc (`spr_bubble_notes_sheet`)**:
  > **Prompt**: `Sprite sheet grid of 16 delicate translucent soap bubbles floating gently, children's storybook game asset. Each soap bubble has a magical iridescent rainbow sheen with subtle highlight glints, and inside each bubble floats a glowing pastel musical note (treble clef, single note, beamed notes in pink, cyan, yellow, lavender). Soft pastel glowing edges, clean transparent appearance, isolated on pure solid white background, grid sheet of 4x4 uniform bubbles --ar 1:1 --style raw`  
  > **Negative Prompt**: `opaque balls, solid spheres, flat 2d circles, dirty grunge, noisy artifacts, dark background, cropped`

---

#### 1.2. Textures & PBR Maps (Bề Mặt & Chiều Sâu 2.5D)
| Tên Asset | Kích thước | Kênh Texture | Mô tả kỹ thuật |
|---|---|---|---|
| `tex_top_bar_carving.png` | $1024 \times 256\text{ px}$ | Albedo + Normal | Khung gỗ chạm khắc uốn lượn thanh tiêu đề trên cùng |
| `tex_open_book_freeplay.png` | $1536 \times 1024\text{ px}$ | Albedo + Emission | Hai trang sách tranh mở đôi với viền mạ vàng |
| `tex_crystals_emission.png` | $512 \times 512\text{ px}$ | Grayscale Mask | Mask phát quang cho cụm thạch anh Cyan & Magenta |
| `tex_piano_keys_rainbow.png` | $2048 \times 512\text{ px}$ | Albedo Palette | Bộ 11 phím đàn màu pastel cầu vồng bóng bẩy |

* **Prompt AI 04 — Khung Gỗ Chạm Khắc Cổ Tích Thanh Tiêu Đề (`tex_top_bar_carving`)**:
  > **Prompt**: `Antique carved oak wood banner plaque header frame for kids game UI. Ornate whimsical wood scrollwork trim with soft leafy filigree carvings, polished warm honey oak wood grain, gentle rounded bevels, warm golden edge highlights. Symmetrical horizontal header sign with 4 recessed rounded wooden button slots, fairytale diorama aesthetic, pure solid white background, orthographic front view --ar 4:1 --style raw`

* **Prompt AI 05 — Trang Sách Tranh Nổi Mở Đôi Cổ Tích (`tex_open_book_freeplay`)**:
  > **Prompt**: `Spread pages of a giant antique fairytale pop-up storybook lying open, thick aged cream parchment pages with gilded embossed golden leaf ornamental borders, curved spine book gutter. Cozy enchanting forest background subtly painted on the page background with soft pastel trees and starry night sky, rich warm golden rim light on the book binding edges, isolated on pure white background, flat diorama perspective --ar 3:2 --style raw`

---

#### 1.3. Backgrounds & Parallax Layers (Phông Nền Rừng Chập Tối Đa Tầng)
| File Asset | Kích thước | Độ trễ Parallax (`scroll_scale`) | Vai trò không gian |
|---|---|---|---|
| `bg_twilight_canopy.png` | $2560 \times 1440\text{ px}$ | $(0.05, 0.05)$ | Tán rừng chập tối, bầu trời ngọc thẫm, các chuỗi đèn lồng |
| `bg_twilight_cottages.png` | $2560 \times 1440\text{ px}$ | $(0.15, 0.15)$ | Ngôi nhà nấm hồng bên trái và nhà gỗ mái ngói bên phải |
| `bg_fairy_lights_overlay.png` | $2560 \times 720\text{ px}$ | $(0.08, 0.08)$ | Lớp dây đèn lồng (đỏ, vàng, lục, lam) nhấp nháy phát quang |
| `bg_mossy_wood_desk.png` | $2560 \times 720\text{ px}$ | $(1.0, 1.0)$ | Bàn gỗ sồi tiền cảnh với rêu xanh và hoa cỏ ven đàn |

* **Prompt AI 06 — Hậu Cảnh Rừng Thần Tiên Chập Tối & Dây Đèn Lồng (`bg_twilight_canopy`)**:
  > **Prompt**: `Panoramic background painting of an enchanted fairytale forest at twilight for a preschool storybook game. Ancient mossy oak trees with sprawling branches silhouetted against a deep teal and navy twilight sky, twinkling distant stars and fireflies floating in the misty air. Colorful whimsical fairy string lights (glowing warm yellow, ruby red, cyan, pastel pink bulbs) gracefully draped across tree branches. Cozy storybook cottage houses in the midground with warm amber light glowing from round windows, dreamy bokeh atmospheric depth, no characters, landscape panorama --ar 16:9 --style raw`

---

#### 1.4. Portraits & Cutscene Illustrations
| Tên Asset | Kích thước | Trạng thái / Biểu cảm | Mục đích |
|---|---|---|---|
| `portrait_wizard_star_cheer` | $512 \times 512\text{ px}$ | Cười rạng rỡ, giơ ngón tay cái | Hiển thị khi bé đàn liên tục nhiều nốt vui tai |
| `portrait_wizard_star_listening` | $512 \times 512\text{ px}$ | Nghiêng đầu lắng nghe, mắt sao chớp | Hiển thị lúc bé dừng tay thưởng thức tiếng vang |

* **Prompt AI 07 — Chân Dung Bé Phù Thủy Kính Sao Biểu Cảm (`portrait_wizard_star_cheer`)**:
  > **Prompt**: `Storybook round portrait avatar of an adorable little boy wizard wearing funny golden star sunglasses, smiling with bright cheerful joy. He wears a dark purple pointed wizard hat with tiny gold stars. Soft warm lighting, painted storybook style, circular vignette border of carved honey oak wood with tiny musical notes, pure white background --ar 1:1 --style raw`

---

### MỤC 2: UI / UX ASSETS (GIAO DIỆN, HUD & STYLE GUIDE)

#### 2.1. Thanh Chọn 4 Nhạc Cụ (Top Instrument Bar)
| Tên Asset | Kích thước | Trạng thái | Ghi chú Godot |
|---|---|---|---|
| `ui_bar_frame_4slots.png` | $720 \times 120\text{ px}$ | Tĩnh | Khung gỗ chạm khắc 4 ô tròn đặt giữa trên |
| `ui_slot_glow_active.png` | $140 \times 140\text{ px}$ | Quầng sáng vàng | Vòng hào quang vàng kim chỉ báo nhạc cụ đang chọn |
| `ui_speech_bubble_party.png` | $420 \times 140\text{ px}$ | 9-patch / Sprite | Khung bóng thoại kem viền mềm mại kèm đuôi chỉ |

#### 2.2. Bộ 4 Icons Nhạc Cụ Chi Tiết (Theo Đúng Concept `mock-free-play.jpeg`)
1. **Đại Cầm (Grand Piano)**:
   - Icon chiếc đàn đại dương cầm màu đen bóng sang trọng mở nắp, lộ hàng phím trắng ngà trên nền gỗ sồi tròn.
2. **Đàn Kalimba Gỗ (Wooden Kalimba)**:
   - Icon chiếc đàn phiếm gỗ gõ ngón tay (Thumb Piano) với thân gỗ gụ ấm áp, lỗ thoát âm tròn và các phím kim loại sáng bóng.
3. **Chuông Pha Lê (Crystal Bell)**:
   - Icon chiếc chuông thủy tinh/pha lê màu xanh ngọc bích lấp lánh với cán cầm chạm bạc, phát ra các tia sáng lanh lảnh.
4. **Giọng Thú Ngộ Nghĩnh (Funny Animal Voices - Biểu Tượng Khỉ)**:
   - Icon đầu chú Khỉ con tinh nghịch màu nâu hạt dẻ, má hồng, đang cười toe toét ngộ nghĩnh.

* **Prompt AI 08 — Bộ 4 Icons Nhạc Cụ Game Thiếu Nhi (`icons_free_play_instruments`)**:
  > **Prompt**: `Set of 4 game UI icons for a kids music app, storybook toy aesthetic, arranged in a horizontal row on pure white background: 1. A miniature black grand piano with cream keys and open lid; 2. A warm polished mahogany wooden kalimba thumb piano with shiny silver metal tines; 3. A glittering magical crystal bell made of translucent cyan glass with silver handle and star sparkles; 4. An adorable friendly cartoon monkey face with cheerful smile and rosy cheeks. Each icon is set inside a gently rounded circular wooden medallion with golden beveled border, soft warm lighting, diorama icon sheet, ultra-clean edges --ar 16:5 --style raw`

#### 2.3. Typography & Style Guide Chuẩn Cho Trẻ 3–6 Tuổi
* **Triết lý Zero-Text**:
  - Dòng chữ *"Thỏa thích sáng tác nhạc nào! 🎵"* trên bóng thoại là điểm tựa duy nhất cho phụ huynh và tạo cảm giác sách kể chuyện. Với bé mầm non, hình ảnh phù thủy đeo kính sao lắc lư và dải cầu vồng là chỉ dẫn chính.
* **Bộ Font Chữ Trẻ Em (Kid-Friendly Rounded Typography)**:
  - **Font chính**: `Fredoka-Bold` hoặc `Baloo2-ExtraBold` (Hỗ trợ đầy đủ tiếng Việt có dấu, góc bo tròn tuyệt đối, không có chân sắc nhọn).
  - Màu chữ: Nâu cánh gián `#542813` trên nền bong bóng thoại vàng kem `#FFF8E7`.
* **Kích thước vùng chạm (Touch Target Size - Chuẩn Apple Kids Category)**:
  - Mỗi ô nhạc cụ trên thanh Top Bar: Tối thiểu $120 \times 100\text{ px}$ ($> 88\text{ pt}$ Retina), khoảng cách giữa 2 ô chạm $\ge 16\text{ px}$ để tránh trẻ chạm nhầm khi dùng ngón tay cái.

---

### MỤC 3: AUDIO ASSETS (SFX, NHẠC NỀN & VOICE LINES)

#### 3.1. Bộ Hiệu Ứng Âm Thanh Nhạc Cụ (Instrument SFX - 16-bit 44.1kHz PCM .wav)
Mỗi nhạc cụ sở hữu bộ mẫu âm thanh với thời gian kích hoạt cực ngắn (Attack $< 10\text{ ms}$) để đảm bảo độ trễ chạm thấp nhất:
1. **Bộ Âm Đại Cầm (`sfx_grand_piano_*.wav`)**:
   - Âm sắc piano đại dương cầm Steinway đầy đặn, ấm áp, vang ngân tự nhiên, độ phân rã (Decay) dài tạo cảm giác bao bọc.
2. **Bộ Âm Đàn Kalimba Gỗ (`sfx_kalimba_*.wav`)**:
   - Âm thanh gõ phiến kim loại mộc mạc, trong trẻo, tiếng "ting ting" nảy nở với âm bội gỗ trầm ấm.
3. **Bộ Âm Chuông Pha Lê (`sfx_crystal_bell_*.wav`)**:
   - Âm sắc thủy tinh lanh lảnh, ngân nga với hiệu ứng lấp lánh (sparkling sheen), tạo cảm giác phép thuật cổ tích.
4. **Bộ Âm Giọng Thú Ngộ Nghĩnh (`sfx_animal_monkey_*.wav`)**:
   - Chuỗi âm thanh tượng thanh vui nhộn ("Ooh-ooh-aah-aah!", tiếng chíp chíp, meo meo, gâu gâu) được tinh chỉnh đúng cao độ nhạc lý thang âm pentatonic để khi bé đập phím loạn xạ vẫn tạo thành bài hòa tấu hài hước.

#### 3.2. Hiệu Ứng Tương Tác Giao Diện & Ma Thuật (UI & Magic SFX)
| File SFX | Độ dài | Mô tả |
|---|---|---|
| `sfx_bubble_pop.wav` | $0.25\text{ s}$ | Tiếng "bốp" nhẹ nhàng êm tai khi chạm vỡ bong bóng xà phòng |
| `sfx_fairy_glissando.wav` | $1.2\text{ s}$ | Tiếng chuông gió kim sa lướt nhanh khi đổi nhạc cụ |
| `sfx_rainbow_sparkle.wav` | $0.4\text{ s}$ | Tiếng lấp lánh khi phím đàn cầu vồng nảy lên |
| `sfx_wood_tap_soft.wav` | $0.15\text{ s}$ | Tiếng gõ gỗ tròn trịa khi chạm nút chọn nhạc cụ |

#### 3.3. Nhạc Nền Sáng Tác Tự Do (Background Music - Seamless Loop .ogg)
* **File**: `bgm_free_play_acoustic_jam.ogg` (Thời lượng $2\text{ phút } 15\text{ giây}$, lặp vô tận).
* **Phong cách**: Acoustic Folk Lullaby & Jamming (Đàn guitar gỗ rải nhịp nhẹ nhàng, tiếng gõ mộc Marimba êm ái, đệm âm thanh Celesta lấp lánh).
* **Đặc tính kỹ thuật cốt tử**:
  - **Hòa âm trung tính (Non-Intrusive Harmony)**: Đi trên vòng hòa thanh mở $C - G - Am - F$ ở mức âm lượng $-20\text{ dB}$, không có giai điệu chính chiếm ưu thế để **nhường trọn vẹn sân khấu âm thanh cho bé tự do đàn mà không bị chỏi nốt hay rối tai**.

#### 3.4. Giọng Nói Lồng Tiếng Thiếu Nhi (Voice Lines Tiếng Việt)
* Diễn viên lồng tiếng bé 5 tuổi hoặc cô giáo mầm non ấm áp:
  - `vo_wizard_intro_freeplay.wav`: *"Thỏa thích sáng tác nhạc nào! 🎵"* (Âm điệu vui tươi, hào hứng, ngân nga).
  - `vo_cheer_great.wav`: *"Hay quá đi thôi!"*
  - `vo_cheer_magical.wav`: *"Khu rừng nở hoa rồi kìa!"*
  - `vo_wizard_giggle.wav`: Tiếng cười khúc khích hồn nhiên của bé phù thủy.

---

### MỤC 4: VFX & SHADERS (HIỆU ỨNG THỊ GIÁC ĐỘNG)

#### 4.1. Shader Bong Bóng Xà Phòng Ngũ Sắc (`sh_soap_bubble.gdshader`)
* **Mô tả**: Shader tính toán hiệu ứng khúc xạ ánh sáng (Fresnel) trên màng mỏng xà phòng, tạo viền phản quang cầu vồng óng ánh đổi màu theo thời gian kết hợp gợn sóng hình học nhẹ (vertex wobble) mô phỏng độ phập phồng tự nhiên của bong bóng trong không khí.

#### 4.2. Shader Dải Cầu Vồng Âm Nhạc (`sh_rainbow_ribbon.gdshader`)
* **Mô tả**: Shader tạo dải lụa phát quang mang dải màu quang phổ (Đỏ, Cam, Vàng, Lục, Lam, Chàm, Tím) cuộn trôi theo trục UV $x$, tích hợp độ sáng rực (Emission Bloom) để dải nốt nhạc bay từ phím đàn lên trời sáng rực rỡ trên nền rừng tối.

#### 4.3. Shader Tinh Thể Pha Lê Nhấp Nháy (`sh_crystal_glow.gdshader`)
* **Mô tả**: Shader tạo xung nhịp phát quang dịu êm (Breathing Pulse) và độ lóe sáng lăng kính cho cụm thạch anh xanh Cyan và hồng tím Magenta.

#### 4.4. Shader Dây Đèn Cổ Tích Nhấp Nháy (`sh_fairy_lights.gdshader`)
* **Mô tả**: Shader điều khiển hàng chục bóng đèn lồng trên tán cây nhấp nháy so le ngẫu nhiên theo pha lượng giác (Sine wave phase offset), tạo bầu không khí lễ hội thần tiên ấm áp.

#### 4.5. Hệ Thống Hạt GPUParticles2D / CPUParticles2D
1. **`vfx_soap_bubbles.tscn`**: Hệ thống phun bong bóng xà phòng mang nốt nhạc bay từ gốc cây đậu thần lên trời với vận tốc chậm, lắc lư nhẹ sang hai bên.
2. **`vfx_rainbow_sparkle.tscn`**: Hệ thống hạt kim sa bụi sao bung tỏa theo hình nan quạt mỗi khi một phím đàn cầu vồng được kích hoạt.

---

## PHẦN III: HƯỚNG DẪN TÍCH HỢP & TRIỂN KHAI VÀO GODOT 4.7

1. **Khởi tạo Shader**:
   - `game/diorama/shaders/soap_bubble.gdshader`
   - `game/diorama/shaders/rainbow_ribbon.gdshader`
   - `game/diorama/shaders/fairy_lights.gdshader`
2. **Tạo Component Thanh 4 Nhạc Cụ**:
   - `game/hud/free_play_top_bar.gd` và texture minh họa trực quan.
   - Kết nối với `GameState.instrument_mode` và `AudioDirector`.
3. **Nâng cấp Bàn Phím Đàn Cầu Vồng (Rainbow Keys)**:
   - Cập nhật `game/piano/piano_keyboard.gd` để áp dụng bảng màu pastel cầu vồng khi vào chế độ Free Play.
4. **Nâng cấp Sân Khấu Diorama (`game/diorama/diorama_stage.gd`)**:
   - Tự động chuyển bé phù thủy sang trang phục kính sao (`wizard_star_party.png`).
   - Cập nhật câu thoại tiếng Việt: *"Thỏa thích sáng tác nhạc nào! 🎵"*.
   - Kích hoạt luồng bong bóng xà phòng âm nhạc và dải cầu vồng.
