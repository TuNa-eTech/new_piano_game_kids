# QUY TRÌNH MỸ THUẬT 2.5D (GAME ART PIPELINE) & DANH MỤC ASSET PROMPT AI
# MÀN HÌNH GAMEPLAY CHÍNH: "RỪNG NHẠC THẦN TIÊN"

> **Tài liệu đặc tả**: Quy trình từ Concept $\rightarrow$ Creation $\rightarrow$ Conversion $\rightarrow$ Asset Management cho Game 2.5D  
> **Nguồn cảm hứng thiết kế**: [`docs/mock-game-play.jpeg`](file:///Users/anhtu/MySpace/new-piano/docs/mock-game-play.jpeg)  
> **Engine mục tiêu**: Godot Engine 4.7+ (Forward Mobile / iOS Metal / Android Vulkan)  
> **Đối tượng người chơi**: Trẻ em 3–6 tuổi (Triết lý Zero-Text, trực quan hóa 100%, xúc giác đồ chơi gỗ cao cấp)

---

## PHẦN I: QUY TRÌNH MỸ THUẬT GAME 2.5D DÀNH CHO INDIE DEVELOPER

Quy trình mỹ thuật 2.5D (2.5D Diorama Pop-up Pipeline) chia làm 4 giai đoạn chuẩn mực, khép kín, tối ưu hóa công sức của indie developer bằng công nghệ AI sinh hình ảnh kết hợp hậu kỳ tự động và tích hợp engine Godot 4.7.

```
┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   2.5D GAME ART PIPELINE                                      │
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
* **Góc nhìn 2.5D**: Chiếu nghiêng phối cảnh $15^\circ - 20^\circ$ (Isometric / Oblique Tilt) nhìn vào cuốn sách tranh mở trên bàn gỗ sồi cổ tích.
* **Cấu trúc không gian 3 tầng chiều sâu**:
  1. **Hậu cảnh (Background / Far-Plane)**: Tán rừng thần tiên mơ màng với những ngôi nhà nấm mái ngói ấm áp, cửa sổ phát ánh sáng vàng mật ong, vệt nắng (God rays) xuyên qua kẽ lá.
  2. **Trung cảnh (Midground / Book Stage Plane)**: Cuốn sách cổ tích khổng lồ mở đôi với gáy sách uốn cong viền mạ vàng hoa văn:
     - **Trang trái**: Bé Phù Thủy mặc áo choàng và mũ chóp tím chơi chiếc đàn piano mini bằng gỗ quý, phát ra bong bóng thoại chứa chỉ dẫn tương tác kèm các nốt nhạc bay lơ lửng.
     - **Trang phải**: Cây Đậu Thần (Beanstalk) ma thuật uốn lượn vươn cao với 7 chiếc lá ngọc phát quang mang các ký tự nốt nhạc (♪, ♫, ♬). Đỉnh cây đỡ chiếc Rương Báu Hoàng Gia (Treasure Chest) mạ vàng phát hào quang bụi sao rực rỡ.
     - **Dải cầu vồng âm nhạc (Magic Ribbon Staff)**: Dải lụa phát sáng uốn lượn nối từ phím đàn và đàn của phù thủy, bay qua trang sách và quấn quanh thân cây đậu thần hướng thẳng tới rương báu.
  3. **Tiền cảnh (Foreground / Keybed Plane)**:
     - Bục đàn piano gỗ chạm khắc thủ công với hai đầu xoắn ốc (whimsical wood scroll).
     - 7 phím trắng ngà voi rộng rãi được bo góc mềm mại, mỗi phím dập nổi huy hiệu 3D đầu thú (Sư tử, Gấu, Thỏ, Mèo, Khỉ, Voi, Cú) và nút tròn chứa chữ cái nốt nhạc (C, D, E, F, G, A, B).
     - 5 phím đen nổi khối 3D vát cạnh tạo độ sâu cơ học.
     - Hai góc bàn phím là các cụm tinh thể thạch anh phát sáng (Thạch anh xanh Cyan góc trái, Thạch anh hồng Magenta góc phải).
     - Rương gỗ phụ đặt bên phải trên thảm cỏ ven bục đàn.

#### 1.2. Bảng Màu Chuẩn (Hút Trực Tiếp Từ `mock-game-play.jpeg`)
* **Vàng ngà phím đàn & Giấy da cổ tích**: `#FFF2DB` (Mặt phím), `#F5E3C3` (Trang sách), `#DEC088` (Vát cạnh 3D phím).
* **Nâu gỗ sồi ấm & Khung chạm khắc**: `#5A371F` (Thân đàn), `#3E2312` (Vân gỗ tối), `#8A5432` (Viền bảng điểm & nút).
* **Xanh rừng & Xanh ngọc ma thuật**: `#184E5A` (Nền thanh nhạc cụ), `#288E9B` (Nước biển ngọc), `#39E5D4` (Lá cây & tinh thể Cyan).
* **Vàng kim mạ nổi & Hào quang rương báu**: `#FFE566` (Hạt sao), `#F2B82E` (Vàng kim rương), `#C98616` (Đồng thau viền sách).
* **Tím ma thuật áo phù thủy & Tinh thể Magenta**: `#5D4B8C` (Mũ & áo phù thủy), `#D65DA0` (Tinh thể hồng), `#F082C5` (Ánh hào quang tím).
* **Bảng màu 7 Phím Đàn Trẻ Em**:
  - `C` (Sư tử): Đỏ cam thân thiện `#E0533C`
  - `D` (Gấu): Cam mật ong `#E88A25`
  - `E` (Thỏ): Hồng phấn ngọt ngào `#E85F9E`
  - `F` (Mèo): Xanh lá chanh `#4CAF50`
  - `G` (Khỉ): Xanh da trời `#29B6F6`
  - `A` (Voi): Tím hoa cà `#9C6ADE`
  - `B` (Cú): Nâu vàng hổ phách `#AF8B3A`

---

### Giai đoạn 2: Creation (Tạo Hình Bằng AI Prompt Kỹ Thuật Cao)

#### 2.1. Quy tắc sinh theo Lô (Grid Batch Generation)
* **Tuyệt đối tránh sinh lẻ tẻ từng icon/sprite rời**: Sinh lẻ sẽ dẫn tới việc mỗi ảnh có một kiểu nét viền, góc chiếu sáng và độ bão hòa màu khác nhau làm vỡ phong cách thống nhất của game.
* **Phương pháp Grid Sheet**: Gom các đối tượng cùng nhóm (ví dụ: bộ 7 huy hiệu thú, bộ 5 nhạc cụ, các giai đoạn cây) lên cùng một tấm ảnh dạng lưới (Sprite Sheet Grid) với nền trắng tinh khiết (`pure solid white background, isolated cutout`).
* **Cố định Seed & Style Reference**:
  - Trong Midjourney v6: Luôn đính kèm tham số `--sref [URL_mock-game-play.jpeg] --sw 850 --c 5 --style raw`.
  - Trong Stable Diffusion XL / Flux: Áp dụng LoRA phong cách sách tranh thiếu nhi (`storybook_watercolor_clay_lora:0.75`), cố định Clip Skip 2, Euler a / DPM++ 2M Karras.

#### 2.2. Master Prompt Framework (Khung Prompt Xương Sống)
```
[CHỦ THỂ CỤ THỂ], layered 2.5D pop-up storybook diorama asset for preschool kids music game, whimsical fairytale aesthetic, charming rounded shapes, warm diffused top-down daylight with soft golden rim light, gentle dark-tone outline (no harsh black outline), rich vibrant friendly color palette: warm cream ivory, polished oak wood brown, sparkling gold leaf trim, luminous turquoise teal glow, clean solid white background, studio product cutout, orthographic diorama view, zero artifacts --ar [TỈ LỆ] --style raw
```

#### 2.3. Negative Prompt Master (Bộ Từ Khóa Phủ Định Chuẩn)
```
photorealistic, adult, scary, dark horror, violent, sharp teeth, evil expression, complex mechanical parts, 3d low poly wireframe, pixelated, noisy textures, harsh pure black outlines, human realism, washed out colors, blurry, cropped, watermark, signature, text, ui gibberish, messy borders
```

---

### Giai đoạn 3: Conversion (Hậu Kỳ, Alpha Matting, PBR Normal Map & Đóng Gói)

#### 3.1. Alpha Matting & Defringing (Tách Nền & Khử Viền)
* **Công cụ**: Sử dụng mô hình `BiRefNet` / `Rembg` (U2Net) để trích xuất kênh Alpha với độ chính xác sub-pixel.
* **Color Bleed / Defringe**: Mở rộng màu các pixel biên thêm 2–3px vào vùng trong suốt để loại bỏ hoàn toàn viền trắng/xám khi texture được lọc tuyến tính (Bilinear filtering) trong Godot.

#### 3.2. Sinh Bản Đồ Chiều Sâu & Normal Map Cho CanvasItem
* Dù là game 2D/2.5D, Godot 4.7 hỗ trợ `CanvasItem Material` với `NormalMap` và `Light2D`.
* Dùng Laigter hoặc NormalMap generator để tạo Normal Map cho bục đàn gỗ, phím đàn và rương báu. Nhờ đó khi dải nốt nhạc phát sáng bay qua, ánh sáng sẽ đổ bóng thực tế lên các gờ chạm khắc gỗ!
* Tạo **Emission Map** (kênh đen-trắng hoặc RGB phát sáng) cho các hạt sao, nốt nhạc, lá cây thần và tinh thể thạch anh.

#### 3.3. Đóng Gói Texture Atlas (TexturePacker / Godot AtlasTexture)
* Gom toàn bộ UI elements và Icons vào Texture Atlas kích thước Lũy thừa 2 (PoT - Power of Two): $2048 \times 2048\text{ px}$.
* Giảm số lượng Draw Calls từ hàng chục xuống còn 1–2 Draw Calls cho toàn bộ UI và Piano Keyboard.

---

### Giai đoạn 4: Asset Management (Quản Lý & Tích Hợp Vào Godot 4.7)

#### 4.1. Quy Ước Đặt Tên Chuẩn (Godot Style Guide Compliant)
| Tiền tố | Thể loại | Ví dụ |
|---|---|---|
| `spr_` | 2D Sprite / Sheet hoạt ảnh | `spr_wizard_piano_idle.png` |
| `tex_` | Texture bề mặt / Nền / PBR | `tex_piano_wood_carving.png` |
| `ui_` | Giao diện người dùng / Icon / Button | `ui_bar_instruments_frame.png` |
| `vfx_` | Hiệu ứng hạt / PackedScene | `vfx_magic_ribbon_stave.tscn` |
| `sfx_` | Âm thanh hiệu ứng (.wav 16-bit) | `sfx_key_c4_lion.wav` |
| `bgm_` | Nhạc nền lặp (.ogg Vorbis) | `bgm_gameplay_storybook_waltz.ogg` |
| `sh_` | Mã shader (.gdshader) | `sh_magic_ribbon.gdshader` |

#### 4.2. Thiết Lập Import Trong Godot 4.7
* **UI & Phím Đàn (`ui_`, `spr_`)**:
  - `Compress Mode`: **Lossless (PNG)**.
  - `Mipmaps`: **Generate = false** (game 2.5D cố định khoảng cách camera).
  - `Filter`: **Linear** (mịn màng trên màn hình Retina / High-DPI).
* **Backgrounds Khổng Lồ (`tex_bg_`)**:
  - `Compress Mode`: **VRAM Compressed (ETC2 / ASTC)** cho mobile để giải phóng băng thông VRAM.
* **Âm thanh**:
  - SFX ngắn $(< 3\text{s})$: Import dạng **WAV (16-bit, 44.1kHz, Mono)**, nạp thẳng vào RAM để đạt độ trễ cực tiểu ($< 15\text{ms}$).
  - BGM: Import dạng **Ogg Vorbis (160kbps, Stereo)**, bật cờ `Loop = true`.

#### 4.3. Kiến Trúc Cây Node & Phân Lớp Z-Index 2.5D (Visual Depth Layering)
```
Main (Node2D)
├── UI (CanvasLayer - Layer 10: Gameplay Stage)
│   ├── DioramaStage (Control)
│   │   ├── BGFar (Layer -30: Tán rừng xa mờ ảo & tia nắng)
│   │   ├── BGMid (Layer -20: Hai ngôi nhà nấm cổ tích 2 bên)
│   │   ├── BGNear (Layer -10: Lùm cây & thảm hoa tiền cảnh)
│   │   ├── BookSpread (Layer 0: Cuốn sách cổ tích mở đôi)
│   │   │   ├── Wizard (Layer +5: Bé phù thủy chơi đàn mini bên trái)
│   │   │   ├── SpeechBubble (Layer +6: "TAP THE MUSICAL LEAVES TO FIND THE TREASURE!")
│   │   │   └── MagicTree (Layer +10: Cây đậu thần & 7 lá nốt nhạc)
│   │   │       ├── BeanstalkTrunk (Cành dây leo uốn lượn)
│   │   │       ├── MusicalLeaves (7 lá ngọc C-D-E-F-G-A-B phát sáng)
│   │   │       └── ChestApex (Rương báu mạ vàng trên ngọn cây)
│   │   ├── CrystalCyan (Layer +15: Cụm thạch anh xanh góc trái)
│   │   ├── CrystalMagenta (Layer +15: Cụm thạch anh hồng góc phải)
│   │   └── ChestGround (Layer +15: Rương gỗ thảm cỏ góc phải)
│   ├── MagicRibbon (Layer +18: Dải ánh sáng nối phím đàn lên cây đậu thần)
│   └── PianoKeyboard (Layer +20: Bục đàn gỗ 2.5D & 7 Phím Thú)
│       ├── WoodBody (Vỏ đàn chạm khắc xoắn ốc 2 đầu)
│       ├── WhiteKeys (7 phím trắng ngà: Lion, Bear, Bunny, Cat, Monkey, Elephant, Owl)
│       └── BlackKeys (5 phím đen nổi khối 3D)
└── HUD (CanvasLayer - Layer 20: Tầng Giao Diện Cố Định)
    ├── TopInstrumentBar (Góc trái trên: Khung gỗ 5 nhạc cụ Vĩ cầm, Sáo, Trống, Trumpet, Hạc)
    ├── ScoreComboBoard (Góc phải trên: Bảng gỗ SCORE: 1250 / COMBO: 15)
    ├── BtnMenu (Góc phải trên cùng: Nút Nhà nấm hồng "MENU")
    └── BtnLevels (Góc phải: Nút Ngôi sao 3 màu "LEVELS")
```

---

## PHẦN II: BREAKDOWN CHI TIẾT ASSET LIST & PROMPT AI

---

### MỤC 1: 2.5D ASSETS (NHÂN VẬT, ĐẠO CỤ, BỐI CẢNH)

#### 1.1. Sprites & Sprite Sheets
| Tên Asset | Kích thước | Frames | Mục đích trong Godot 4.7 |
|---|---|---|---|
| `spr_wizard_piano_idle_play` | $1024 \times 1024$ | Grid $3 \times 2$ (6 frames) | Bé phù thủy nhún nhảy đánh đàn piano gỗ mini |
| `spr_beanstalk_growth_8stages` | $2048 \times 2048$ | Grid $4 \times 2$ (8 stages) | 8 giai đoạn lớn dần của Cây Đậu Thần leo trời |
| `spr_chest_golden_apex` | $768 \times 512$ | 3 frames (Idle, Wobble, Open) | Rương báu ngọn cây lắc lư và mở bung tia sáng |
| `spr_leaf_musical_notes` | $512 \times 512$ | Grid $4 \times 2$ (7 lá + 1 hoa) | 7 lá ngọc hình nốt nhạc tương ứng 7 màu |

* **Prompt AI 01 — Bé Phù Thủy Đánh Đàn Piano Mini (Wizard Pianist)**:
  > **Prompt**: `Sprite sheet grid of a cute 4-year-old child wizard boy playing an ornate miniature upright piano, children's storybook art style. The boy wears an oversized floppy purple wizard hat with a golden star buckle, cozy lavender hooded tunic, cute boots, sitting on a tiny stool happily playing piano keys with both hands, cheerful smiling face. The piano is carved polished dark oak with gold trim. Six progressive animation frames: idle playing piano keys, nodding head to the music, raising one hand cheerfully, laughing joyfully. Soft rounded dark outlines, warm magical lighting, clean white background, evenly spaced sprite sheet grid --ar 1:1 --style raw`  
  > **Negative**: `adult, realistic hands, scary face, dark, evil, messy lines, watermark, cropped`

* **Prompt AI 02 — Cây Đậu Thần Phát Triển 8 Giai Đoạn (Magic Beanstalk Stages)**:
  > **Prompt**: `Sprite sheet showing 8 progressive growth stages of a whimsical magical beanstalk vine for a preschool fairy-tale game, arranged in a clean 4x2 grid. Stage 1 is a tiny cute green sprout with one glowing leaf; Stage 8 is a majestic thick twisting emerald beanstalk with glowing turquoise leaves carrying glowing musical note runes (quarter note, eighth note, treble clef), spiraling upwards gracefully into magical sparkling clouds. Soft watercolor texture, fairy-tale storybook aesthetic, vibrant emerald green, mint green and turquoise tones, warm golden rim highlights, clean solid white background, isolated sprites --ar 1:1 --style raw`  
  > **Negative**: `monstrous plant, thorny vines, dark horror, photorealistic, tangled mess, text, blur`

* **Prompt AI 03 — Rương Báu Hoàng Gia Trên Đỉnh Cây (Apex Treasure Chest)**:
  > **Prompt**: `Set of 3 animation keyframes for a whimsical golden treasure chest resting on magic beanstalk foliage: Frame 1: closed antique wooden chest with polished brass bands and keyhole; Frame 2: trembling and bouncing with golden starlight leaks; Frame 3: top lid bursting open releasing sparkling golden musical notes and star confetti. Chunky tactile toy aesthetic, rounded beveled edges, rich polished amber oak wood, polished gold metal filigree, clean white background, isolated prop cutout --ar 3:2 --style raw`

---

#### 1.2. Textures & PBR Materials
| Tên Asset | Kích thước | Kênh Texture | Mô tả |
|---|---|---|---|
| `tex_piano_casing_albedo` | $2048 \times 1024$ | RGB Albedo | Bục đàn gỗ sồi nâu ấm với 2 xoắn ốc uốn lượn nghệ thuật |
| `tex_piano_casing_normal` | $2048 \times 1024$ | Normal Map | Chiều sâu vân gỗ và hoa văn chạm khắc nổi |
| `tex_piano_keys_ivory` | $1024 \times 1024$ | Albedo + Roughness | Bề mặt ngà kem nhẵn bóng mịn màng của 7 phím đàn |
| `tex_book_parchment_spread` | $2048 \times 1152$ | RGB Albedo | Cuốn sách tranh mở đôi với gáy sách uốn cong và viền mạ vàng |
| `tex_crystals_emission` | $512 \times 512$ | RGB Emission | Ánh sáng phát quang cho cụm pha lê Cyan & Magenta |

* **Prompt AI 04 — Bục Đàn Gỗ Sồi Chạm Khắc 2.5D (Carved Piano Base)**:
  > **Prompt**: `Foreground diorama piano base casing texture for a 2.5D fairy-tale game, carved dark polished oak wood with whimsical spiral flourishes on left and right flanks, elegant organic woodworking with floral vine engravings, warm honey-brown and chestnut woodgrain, soft golden ambient highlights on top beveled edges, flat frontal diorama perspective, seamless bottom edge, isolated on clean white background --ar 2:1 --style raw`

* **Prompt AI 05 — Cuốn Sách Tranh Mở Khổng Lồ (Open Storybook Spread)**:
  > **Prompt**: `Large open pop-up storybook spread laid flat on a wooden surface, whimsical fairy-tale picture book. Left and right pages made of rich warm cream parchment with soft gentle paper curve towards the center binding spine, ornate embossed golden filigree borders around page margins, fairy tale illuminated manuscript style, soft warm ambient lighting, top-down oblique diorama angle, pure white background cutout --ar 16:9 --style raw`

---

#### 1.3. Backgrounds & Parallax Layers (Phông Nền Rừng Cổ Tích Đa Tầng)
| File Asset | Kích thước | Parallax Ratio | Nội dung thị giác |
|---|---|---|---|
| `bg_layer01_far_forest.png` | $2560 \times 1440$ | $(0.05, 0.05)$ | Tán rừng xanh thẫm, vệt sáng rọi từ trên trời (God rays) |
| `bg_layer02_mid_cottages.png` | $2560 \times 1440$ | $(0.15, 0.15)$ | Hai ngôi nhà nấm cổ tích mái vòm gỗ & ngói hồng 2 bên |
| `bg_layer03_near_foliage.png` | $2560 \times 1440$ | $(0.35, 0.35)$ | Lùm cây xanh mướt, hoa dại, thạch anh và rương cỏ |

* **Prompt AI 06 — Hậu Cảnh Rừng Thần Tiên & Ngôi Nhà Cổ Tích (Fairytale Forest)**:
  > **Prompt**: `Layered background illustration of a whimsical enchanted forest for a children's storybook game. Charming storybook cottage houses with glowing circular windows, thatched and red tiled roofs nestled between ancient giant moss-covered oak trees. Soft warm sunlight filtering down through deep emerald and teal forest foliage creating gentle god rays. Peaceful twilight atmosphere, no characters, rich saturated cozy palette, horizontal panoramic landscape --ar 16:9 --style raw`

---

#### 1.4. Portraits & Cutscene Illustrations (7 Huy Hiệu Thú Cưng)
| File Asset | Nốt | Linh vật | Màu chủ đạo | Ký tự nốt |
|---|---|---|---|---|
| `badge_lion.png` | C | Sư tử con bờm tròn xoe | Đỏ cam `#E0533C` | C |
| `badge_bear.png` | D | Gấu nâu tai tròn tinh nghịch | Cam mật `#E88A25` | D |
| `badge_rabbit.png` | E | Thỏ trắng má hồng ngây thơ | Hồng phấn `#E85F9E` | E |
| `badge_cat.png` | F | Mèo mướp vàng mắt to tròn | Xanh lá `#4CAF50` | F |
| `badge_monkey.png` | G | Khỉ con cười toe toét | Xanh dương `#29B6F6` | G |
| `badge_elephant.png` | A | Voi con vòi cong đáng yêu | Tím cà `#9C6ADE` | A |
| `badge_owl.png` | B | Cú mèo đeo kính thông thái | Hổ phách `#AF8B3A` | B |

* **Prompt AI 07 — Trọn Bộ 7 Huy Hiệu Thú Cưng Dán Phím Đàn (7 Animal Badges Grid)**:
  > **Prompt**: `Grid set of 7 round cute baby animal head badges for children's musical piano keys, storybook cartoon illustration: 1. Baby lion with fluffy round mane; 2. Baby brown bear with round ears; 3. Cute white bunny with pink cheeks; 4. Friendly ginger tabby cat; 5. Playful monkey with curly ears; 6. Baby pastel blue-grey elephant with cute trunk; 7. Sweet little owl with big curious eyes. Each animal head is enclosed in a thick circular badge with soft wooden or enameled bevel, chunky 3D toy tactile appearance, warm soft lighting, pure white background, perfectly organized 7 items in a single horizontal row --ar 7:1 --style raw`  
  > **Negative**: `sharp fangs, scary expressions, realistic fur, low resolution, asymmetrical shapes`

---

### MỤC 2: UI / UX ASSETS (GIAO DIỆN, HUD, MENUS, ICONS & STYLE GUIDE)

#### 2.1. HUD (Head-Up Display)
* **Bảng Điểm Gỗ (`ui_board_score_combo.png`)**:
  - Tấm biển gỗ sồi nâu sẫm dập vân cổ điển, viền khắc nổi họa tiết uốn lượn.
  - Hiển thị dòng chữ:
    - `SCORE: 1250` (Font Baloo 2, chữ vàng kem `#FFF2DB` viền nâu sẫm).
    - `COMBO: 15` (Font Baloo 2, chữ vàng kim rực rỡ `#FFD54F`).
* **Bong Bóng Thoại Phù Thủy (`ui_speech_bubble.png`)**:
  - Bong bóng thoại trắng kem mây bồng bềnh, bo tròn góc mềm, đuôi chỉ vào bé phù thủy.
  - Dòng chữ: `"TAP THE MUSICAL LEAVES TO FIND THE TREASURE!"`.

* **Prompt AI 08 — Bảng Điểm Gỗ Chạm Khắc (Wood Score Signboard)**:
  > **Prompt**: `Horizontal rectangular game HUD wooden signboard plaque, carved dark polished oak wood with rounded corners, beveled edge with warm brass rivets, clean blank inner parchment wooden plate for score display. Rich warm chocolate brown and golden amber wood tones, tactile preschool toy feel, isolated on pure white background --ar 2:1 --style raw`

---

#### 2.2. Menus & Interactive Buttons
* **Thanh 5 Nhạc Cụ Góc Trái Trên (`ui_bar_instruments_frame.png`)**:
  - Khung gỗ bo tròn mềm mại chứa rãnh màu xanh ngọc phát quang (`#184E5A` $\rightarrow$ `#39E5D4`).
  - Chứa 5 icon nhạc cụ:
    1. **Violin (Đàn Vĩ Cầm)**: Trạng thái đang kích hoạt (Active) với hào quang sáng xanh bao quanh.
    2. **Flute (Sáo Gỗ Vàng)**: Ống sáo tre chạm khắc nhỏ gọn.
    3. **Drum (Trống Đội Viên)**: Trống đỏ viền vàng với hai dùi trống gỗ.
    4. **Trumpet (Kèn Đồng)**: Kèn trumpet vàng óng ánh.
    5. **Harp (Đàn Hạc Thần Tiên)**: Đàn hạc mini viền vàng dây bạc.
* **Nút Menu Nhà Nấm (`ui_btn_menu_cottage.png`)**:
  - Khung bục gỗ bo tròn chứa biểu tượng ngôi nhà nấm nhỏ mái đỏ/hồng, chữ `MENU` dập nổi phía dưới.
* **Nút Levels Ngôi Sao (`ui_btn_levels_star.png`)**:
  - Huy hiệu ngôi sao vàng 5 cánh với 3 sọc số màu sắc (1 xanh ngọc, 2 cam, 3 tím), chữ `LEVELS` phía dưới.

* **Prompt AI 09 — Thanh Chọn 5 Nhạc Cụ Cổ Tích (Instrument Selector Bar)**:
  > **Prompt**: `Game UI horizontal instrument selector bar for a fantasy kids music game. An ornate carved wooden plaque holding 5 distinct musical instruments in individual rounded slots: 1. Classic wooden violin; 2. Golden bamboo flute; 3. Colorful marching drum; 4. Shiny brass trumpet; 5. Elegant golden fairy harp. The violin slot has a magical glowing cyan halo indicating selection. Storybook wooden toy aesthetic, rich colors, isolated on white background --ar 4:1 --style raw`

* **Prompt AI 10 — Bộ Nút Bấm Góc Phải (Menu Cottage & Levels Star Buttons)**:
  > **Prompt**: `Set of 2 fairy-tale game UI buttons, storybook diorama style: Left button: a cute rounded wooden plaque featuring a cozy pink-roofed fairytale cottage house with the word 'MENU' carved below; Right button: a vibrant golden five-point star badge showing numbers '1, 2, 3' on colored stripes with the word 'LEVELS' carved below. Chunky tactile preschool toy aesthetic, warm lighting, isolated on white background --ar 2:1 --style raw`

---

#### 2.3. Typography & Style Guide
* **Font Display Chính**: **Baloo 2** (Extra Bold 800) hoặc **Fredoka Bold**.
  - Xử lý bề mặt chữ: Gradient kem vàng (`#FFFFFF` $\rightarrow$ `#FFE89C`), Stroke viền nâu đậm $3.5\text{px}$ (`#4A2810`), Drop Shadow mềm $4\text{px}$ lệch $(0, 3)\text{px}$ (`rgba(0,0,0,0.4)`).
* **Font Nhãn Hướng Dẫn**: **Be Vietnam Pro** (Bold 700) hoặc **Quicksand Bold**.
  - Chữ màu xám đen ấm `#2C1E14` trên nền bong bóng thoại trắng ngà `#FFFDF5`.

---

### MỤC 3: AUDIO ASSETS (SFX, MUSIC, VOICE LINES)

Tất cả asset âm thanh được tối ưu chuẩn Godot 4.7: Âm thanh phím đàn đạt độ trễ $<15\text{ms}$ (WAV 16-bit uncompressed), nhạc nền lặp mượt mà (Ogg Vorbis).

#### 3.1. Hiệu Ứng Âm Thanh (SFX)
| File Asset | Loại | Mô tả & Cảm xúc âm thanh |
|---|---|---|
| `sfx_piano_c4_to_b4.wav` | 7 Nốt Piano Cơ | Mẫu âm thanh đại dương cầm (Grand Piano) mộc, ấm áp, vang ngân tròn trịa |
| `sfx_inst_violin_c4.wav` | Nhạc cụ Vĩ Cầm | Tiếng kéo đàn violin ấm áp mượt mà (legato string) |
| `sfx_inst_flute_c4.wav` | Nhạc cụ Sáo | Tiếng thổi sáo gỗ trong trẻo có hơi gió êm dịu |
| `sfx_inst_drum_hit.wav` | Nhạc cụ Trống | Tiếng gõ trống gỗ rộn ràng, có độ nảy da trống |
| `sfx_inst_trumpet_c4.wav` | Nhạc cụ Kèn | Tiếng kèn trumpet vang rộn ràng, hào hứng |
| `sfx_inst_harp_c4.wav` | Nhạc cụ Đàn Hạc | Tiếng gảy đàn hạc ngân vang như sương mai |
| `sfx_leaf_jingle_bell.wav` | Chạm Lá Nhạc | Tiếng chuông ngọc leng keng thanh khiết khi chạm đúng lá |
| `sfx_chest_apex_open.wav` | Rương Báu Mở | Hợp âm chuông gió glissando ngân dài + tiếng bung nắp rương |
| `sfx_magic_ribbon_whoosh.wav` | Vệt Sáng Nốt Bay | Tiếng "vút" nhẹ nhàng kèm bụi sao lấp lánh khi nốt nhạc bay |
| `sfx_crystal_hum_cyan.wav` | Chạm Tinh Thể | Âm thoa pha lê ngân nga êm dịu |

* **Prompt AI Sinh Âm Thanh (ElevenLabs SFX / AudioCraft)**:
  > **Leaf Bell**: `Pure crystal glass chime bell, magical twinkling resonance, high pitch gentle chime, musical toy chime, zero harshness, studio recording`  
  > **Chest Open**: `Whimsical fairy tale chest opening, joyful chime glissando, starlight sparkle burst, brass latch click, magical reward sound`

---

#### 3.2. Nhạc Nền (BGM)
| File Asset | Thời lượng / BPM | Cấu trúc & Cảm xúc |
|---|---|---|
| `bgm_gameplay_storybook_waltz.ogg` | 1:45 (88 BPM) | Nhịp 3/4 nhẹ nhàng, giai điệu đàn music box, guitar mộc rải ngón, sáo gỗ và phong cầm êm dịu. Seamless Loop. |

* **Prompt AI Sinh Nhạc (Suno / Udio)**:
  > **Prompt**: `Enchanted fairy tale waltz, 88 bpm in 3/4 time signature, acoustic music box melody, warm acoustic guitar fingerpicking, whimsical wooden flute, soft pizzicato strings, cozy magical forest atmosphere, joyful innocent playful music for 3-6 year old preschool children, peaceful lullaby adventure vibe, high quality production, seamless loopable`

---

#### 3.3. Giọng Biểu Cảm (Non-Verbal Voice Lines)
* `vo_wizard_wow.wav`: Bé phù thủy reo lên "Wao!" thích thú khi rương báu mở.
* `vo_wizard_laugh.wav`: Tiếng cười khúc khích đáng yêu "Hihi!" khi bé đàn đúng cả câu nhạc.
* `vo_animal_7sounds.wav`: Bộ 7 âm thanh linh vật hoạt hình ngộ nghĩnh (tiếng gầm nhẹ "roar-meow" của sư tử, tiếng "woof-purr" của mèo, tiếng "ooh-aah" tinh nghịch của khỉ...).

---

### MỤC 4: VFX & SHADERS (GODOT 4.7 NATIVE)

---

#### 4.1. Hệ Thống Hạt (GPUParticles2D / CPUParticles2D)
1. **Dải Nốt Nhạc Lượn Sóng (`vfx_magic_ribbon_stave.tscn`)**:
   - Dải lụa phát sáng mềm cong theo đường cong Bezier nối từ phím đàn lên Cây Đậu Thần.
   - Các nốt nhạc màu sắc (♪, ♫, ♬, 𝄞) và hạt bụi sao vàng bay dạt dào dọc dải sáng.
2. **Bụi Sao Phím Đàn (`vfx_key_sparkles.tscn`)**:
   - Khi bé chạm ngón tay vào phím đàn, 12 hạt bụi sao vàng cam bùng nở theo hình nón hướng lên trên.
3. **Đom Đóm Tự Nhiên (`vfx_ambient_fireflies.tscn`)**:
   - 25 hạt đom đóm xanh vàng lập lòe bay lượn ngẫu nhiên trong không gian tán rừng và quanh cuốn sách.
4. **Hào Quang Rương Báu Mở (`vfx_chest_sunburst.tscn`)**:
   - Vòng hào quang đa sắc vàng kim xoay tròn và các tia sáng rực rỡ tỏa ra từ nắp rương.

---

#### 4.2. Mã Nguồn Shaders (GDShader Sẵn Sàng Triển Khai)

##### Shader 1: Dải Sáng Âm Nhạc Lượn Sóng (`magic_ribbon.gdshader`)
```gdshader
shader_type canvas_item;

uniform vec4 ribbon_color : source_color = vec4(0.3, 0.9, 1.0, 0.9);
uniform vec4 core_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flow_speed : hint_range(0.5, 4.0) = 2.0;
uniform float wave_freq : hint_range(1.0, 10.0) = 4.0;
uniform float wave_amp : hint_range(0.01, 0.2) = 0.05;

void fragment() {
    vec2 uv = UV;
    // Tạo sóng sin uốn lượn theo thời gian
    float wave = sin(uv.x * wave_freq - TIME * flow_speed) * wave_amp;
    float dist_to_center = abs((uv.y + wave) - 0.5);
    
    // Gradient từ tâm sáng trắng ra viền màu ngọc
    float core = smoothstep(0.08, 0.0, dist_to_center);
    float glow = smoothstep(0.45, 0.0, dist_to_center);
    
    vec4 col = mix(ribbon_color, core_color, core);
    col.a *= glow;
    
    COLOR = col;
}
```

##### Shader 2: Viền Hào Quang Phát Quang Cho Lá Nhạc (`magical_rim_glow.gdshader`)
```gdshader
shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.3, 1.0, 0.8, 1.0);
uniform float pulse_speed : hint_range(0.5, 5.0) = 2.5;
uniform float glow_intensity : hint_range(0.2, 2.0) = 1.0;
uniform float rim_threshold : hint_range(0.01, 0.4) = 0.15;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    if (tex.a < 0.01) {
        discard;
    }
    
    // Nhịp thở phát sáng (breathing pulse)
    float pulse = 0.65 + 0.35 * sin(TIME * pulse_speed);
    
    // Tính viền hào quang từ gradient alpha
    float rim = smoothstep(0.0, rim_threshold, tex.a) * (1.0 - smoothstep(rim_threshold, 0.8, tex.a));
    vec3 result_rgb = tex.rgb + glow_color.rgb * rim * pulse * glow_intensity;
    
    COLOR = vec4(result_rgb, tex.a);
}
```

##### Shader 3: Ánh Kim Quét Qua Bục Gỗ & Phím Đàn (`wood_shimmer.gdshader`)
```gdshader
shader_type canvas_item;

uniform vec4 shimmer_color : source_color = vec4(1.0, 0.95, 0.6, 0.6);
uniform float shimmer_speed : hint_range(0.2, 2.0) = 0.6;
uniform float shimmer_width : hint_range(0.05, 0.4) = 0.18;
uniform float shimmer_interval : hint_range(2.0, 8.0) = 4.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    if (tex.a < 0.01) {
        discard;
    }
    
    // Chu kỳ quét vệt sáng chéo 45 độ
    float progress = mod(TIME * shimmer_speed, shimmer_interval);
    float line_pos = progress * 2.0 - 0.5;
    float dist = abs((UV.x + UV.y * 0.4) - line_pos);
    float shimmer = smoothstep(shimmer_width, 0.0, dist);
    
    vec3 out_rgb = tex.rgb + shimmer_color.rgb * shimmer * shimmer_color.a;
    COLOR = vec4(out_rgb, tex.a);
}
```

---

## PHẦN III: KẾT QUẢ TRIỂN KHAI & ĐỒNG BỘ MÀN HÌNH GAMEPLAY TRÊN GODOT 4.7

1. **Tài liệu hóa hoàn tất**: Lưu tại [`docs/art-pipeline-gameplay-2.5d.md`](file:///Users/anhtu/MySpace/new-piano/docs/art-pipeline-gameplay-2.5d.md).
2. **Shaders Native**: Đã tích hợp sẵn vào thư mục shaders để áp dụng ngay lên các Control node và Sprite2D.
3. **UI / HUD Đồng Bộ**:
   - `TopInstrumentBar`: Cung cấp thanh 5 nhạc cụ ngang cố định góc trái trên.
   - `ScoreBoard`: Bảng gỗ điểm số và combo cố định góc phải trên.
   - 7 Phím Đàn: Phân bổ đều đặn C-D-E-F-G-A-B với đầy đủ huy hiệu 3D đầu thú và nút nốt tròn.
   - Diorama Stage: Thể hiện trọn vẹn Cuốn sách mở, Bé phù thủy đánh đàn, Cây Đậu Thần và Rương báu ngọn cây cùng Rương báu thảm cỏ tiền cảnh.
