# QUY TRÌNH MỸ THUẬT 2.5D (GAME ART PIPELINE) & DANH MỤC ASSET PROMPT AI
# MÀN 07: ĐẠI HOAN CA BUỔI DIỄN RỪNG XANH ("GRAND FINALE STAGE")

> **Dự án**: Rừng Nhạc (Enchanted Music Forest) — Game Âm Nhạc Trẻ Em 3–6 Tuổi  
> **Nguồn cảm hứng thiết kế cốt lõi**: [`docs/mock-grand-finale.jpeg`](file:///Users/anhtu/MySpace/new-piano/docs/mock-grand-finale.jpeg)  
> **Nền tảng mục tiêu**: Godot Engine 4.7+ (Forward Mobile / iOS Metal / Android Vulkan)  
> **Phong cách mỹ thuật**: Sách Tranh Nổi 2.5D Diorama (Layered Pop-up Puppet Theater) kết hợp đồ chơi gỗ xúc giác ấm áp  
> **Kỹ thuật sinh AI**: Tách phông xanh đồng nhất (**Solid Chroma Key Green `#00FF00`**) chống lem viền cho toàn bộ Sprite/Prop/UI  
> **Triết lý tương tác**: Zero-Text Preschool UX (Trực quan hóa 100%, phản hồi đa giác quan, bảo vệ trọn vẹn 12 giây vinh quang)

---

## PHẦN I: QUY TRÌNH MỸ THUẬT 2.5D CHO INDIE DEVELOPER (4 GIAI ĐOẠN)

Quy trình 2.5D Pop-up Diorama giúp một nhà phát triển độc lập đạt chất lượng hình ảnh tương đương studio lớn bằng cách kết hợp AI thế hệ mới với hậu kỳ tự động hóa và kiến trúc phân tầng chuyên sâu trong Godot 4.7+.

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                          2.5D GRAND FINALE DIORAMA ART PIPELINE                                 │
├───────────────────┬───────────────────┬───────────────────────────┬─────────────────────────────┤
│    1. CONCEPT     │    2. CREATION    │       3. CONVERSION       │     4. ASSET MANAGEMENT     │
│                   │                   │                           │                             │
│ • Sân khấu múa rối│ • Master Prompts  │ • Python Chroma Keying    │ • Godot 4.7 Import Presets  │
│ • Bảng màu chuẩn  │ • Phông xanh #00FF│ • Spill Suppression khử lẻ│ • Phân tầng Z-Index 2.5D    │
│ • 2.5D Multi-plane│ • Grid Batching   │ • Emission & Normal Maps  │ • Performance Budget Mobile │
│ • Zero-Text Rule  │ • Neg-Prompt Safe │ • 9-Slice & Texture Atlas │ • Draw Calls & Headroom     │
└───────────────────┴───────────────────┴───────────────────────────┴─────────────────────────────┘
```

---

### Giai đoạn 1: Concept (Khái Niệm, Khóa Phong Cách Thị Giác & Chiều Sâu 2.5D)

#### 1.1. Ngôn ngữ tạo hình & Cấu trúc Sân khấu Múa Rối 2.5D (Puppet Stage Diorama)
* **Bối cảnh & Ý nghĩa nghệ thuật**:
  - Màn 07 là khoảnh khắc đỉnh cao (**Dopamine Climax**) của toàn bộ chương sách sau khi bé hoàn thành 5 bài học nhạc.
  - Sân khấu được dựng theo cấu trúc **Sân khấu múa rối gỗ rèm nhung (Puppet Theater Diorama)**: Một khung gỗ sồi uốn lượn tinh xảo, rèm nhung đỏ viền vàng buông nhẹ hai bên, ở giữa là màn hình tranh ma thuật (Magic Canvas) nơi Cây Đậu Thần vươn cao ngậm Rương Báu bung nắp tỏa hào quang.
  - Phía trước sân khấu là dàn nghệ sĩ tí hon gồm 7 bạn thú và Cậu bé phù thủy cùng hòa tấu giai điệu 12 giây mà bé vừa hoàn thành. Dưới chân là bàn phím piano gỗ 7 phím (C-D-E-F-G-A-B) với các huy hiệu đầu thú phát sáng rực rỡ theo nhịp gõ.
* **Góc phối cảnh 2.5D**: Chiếu xiên $15^\circ - 18^\circ$ (Oblique Stage View) kết hợp độ cao sàn diễn $3$ tầng (Keyboard Tier $\rightarrow$ Stage Floor $\rightarrow$ Magic Backdrop Screen) tạo chiều sâu lập thể rõ rệt.
* **Cấu trúc 5 tầng thị giác (Multi-plane Layers)**:
  1. **Tầng 1: Nền rừng sâu & Nhà nấm (Far Background Parallax - Z: -30)**: Tán rừng già xanh ngọc thẫm, vạt nắng chiều rọi qua kẽ lá, hai ngôi nhà nấm nhỏ hai bên bìa rừng với ô cửa sổ tròn phát ánh sáng ấm cúng.
  2. **Tầng 2: Màn hình tranh ma thuật (Magic Canvas Screen - Z: -20)**: Khung gương gỗ mạ vàng viền xanh ngọc, bên trong là Cây Đậu Thần xoắn ốc vươn lên mây biếc với lá hình nốt nhạc, suối nốt nhạc uốn lượn và chiếc Rương Thần bung mở tỏa ánh sáng rực rỡ.
  3. **Tầng 3: Sàn diễn múa rối & Dàn nhạc (Puppet Stage & Ensemble - Z: -10)**: Bục sàn lát các thanh gỗ sồi ấm áp, nơi Dàn nhạc 7 bạn thú cử động:
     - Sư tử: Đánh bộ 3 trống con đỏ viền vàng.
     - Gấu: Gảy đàn hạc vàng tao nhã.
     - Cậu bé phù thủy: Đội mũ chóp tím, áo choàng tím viền vàng, chơi đàn piano gỗ upright.
     - Mèo: Thổi sáo ngang trúc mộc.
     - Voi: Nhún nhảy vui nhộn vung vòi.
     - Cú mèo: Đập cánh ca hát, mắt tròn xoe rạng rỡ.
     - Thỏ: Nhảy múa lấp lánh (hoặc gõ chuông).
  4. **Tầng 4: Bàn phím Piano 2.5D & Bục Thạch Anh (Interactive Piano Stage - Z: 0)**:
     - Khung viền gỗ sồi chạm khắc uốn lượn ôm trọn 7 phím piano trắng ngà kem to bản cùng các phím đen cổ điển.
     - Trên mỗi phím là huy hiệu tròn mặt bạn thú kèm nốt nhạc ngũ sắc: C (Đỏ - Sư tử), D (Cam - Gấu), E (Hồng - Thỏ), F (Xanh lá - Mèo), G (Xanh dương - Khỉ), A (Tím - Voi), B (Nâu - Cú).
     - Phím phát hào quang nở rộng khi nốt vang lên.
     - Hai bên bục gỗ là 2 cụm tinh thể thạch anh: Thạch anh xanh Cyan (góc trái) và Thạch anh tím Magenta (góc phải). Góc phải dưới là chiếc rương gỗ nhỏ đóng khóa.
  5. **Tầng 5: Khung rèm & HUD Vinh quang (Proscenium & HUD - Z: +20)**:
     - Bảng hiệu gỗ uốn lượn dập nổi dòng chữ mạ vàng kim: **BUỔI DIỄN RỪNG XANH** với hai ngôi sao vàng lấp lánh hai bên.
     - Nút Mũi tên tiếp tục (Continue) bằng gỗ bo tròn, chỉ xuất hiện nhẹ nhàng sau khi 12 giây kết thúc.

#### 1.2. Bảng Màu Chuẩn (Color Palette Hút Thật Từ `mock-grand-finale.jpeg`)
Các giá trị màu sắc được lượng tử hóa và chọn lọc chính xác:

| Tên Màu | Mã Hex | Tỷ Lệ % | Ứng Dụng Trong Màn 07 | Ý Nghĩa Cảm Xúc & Thị Giác Trẻ Nhỏ |
|---|---|---|---|---|
| **Vàng Kim Hoàng Gia** | `#F8CF58` / `#E8A838` | 18% | Chữ tiêu đề, ngôi sao, rương báu bung mở, nốt nhạc bay, viền hoa văn | Vinh quang, chiến thắng, rạng rỡ, kích hoạt dopamine tích cực |
| **Nâu Gỗ Sồi Ấm** | `#784424` / `#582E16` | 22% | Khung bảng hiệu, sàn sân khấu, thân đàn piano, bệ phím đàn | Xúc giác ấm áp, an toàn, thân thuộc như đồ chơi Montessori bằng gỗ |
| **Kem Phím Đàn** | `#FDF3DA` / `#F0DCB0` | 15% | Thân phím piano, bụng các bạn thú, mảng sáng sân khấu | Dịu mắt, thanh nhã, tôn bật các huy hiệu màu sắc phía trên |
| **Xanh Rừng Thẫm** | `#0D3832` / `#082420` | 15% | Tán lá rừng sâu, viền bóng đổ, hậu cảnh xa | Chiều sâu không gian bí ẩn, tương phản mạnh với sân khấu sáng |
| **Xanh Lá Cây Đậu** | `#2EB86A` / `#44D882` | 10% | Thân và lá cây đậu thần vươn cao, thảm cỏ rêu | Sự sống mơn mởn, tươi mới, biểu tượng của sự lớn khôn |
| **Tím Mộng Mơ** | `#5C3E8A` / `#3D2660` | 8% | Mũ và áo choàng Phù Thủy nhỏ, tinh thể thạch anh phải | Huyền diệu, ma thuật nhiệm màu, kích thích trí tưởng tượng |
| **Cyan Tinh Thể** | `#34D2D8` / `#2298A0` | 6% | Tinh thể thạch anh trái, vệt hào quang nốt nhạc | Tinh khôi, mát mẻ, điểm nhấn ánh sáng lân tinh |
| **Đỏ Nâu & Ngói Cổ** | `#A84832` / `#C8583E` | 6% | Rèm nhung sân khấu, ngói nhà nấm, mặt trống sư tử | Ấm cúng, không khí lễ hội tưng bừng, đón mừng thắng lợi |

#### 1.3. Triết Lý Zero-Text & Bảo Vệ 12 Giây Vinh Quang (Apple Kids 1.3 Compliance)
1. **12 Giây Điện Ảnh Không Bị Cắt Ngang**:
   - Trong suốt 12 giây hòa tấu, **tuyệt đối không hiển thị bất kỳ nút bấm hay popup nào**. Trẻ 3–5 tuổi dễ bị xao nhãng hoặc vô tình bấm trúng nút thoát làm hỏng mất khoảnh khắc thành tựu.
   - Sân khấu tự động biểu diễn giai điệu hoàn chỉnh của chương, cây thần vươn cao, rương báu bung nở hoa trái.
2. **Dành Riêng Cho Phụ Huynh Quay Video**:
   - Khoảnh khắc này được thiết kế để cha mẹ quay video kỷ niệm gửi ông bà người thân. Vì thế, khung hình phải trong trẻo, không chứa chữ "Score", "Combo", "Time" hay nút bấm vướng víu.
3. **Nút Tiếp Tục Tự Nhiên & Dễ Bấm**:
   - Sau khi buổi diễn hoàn tất, nút Mũi tên gỗ bo tròn ($\ge 96\text{ pt}$) mới mờ dần hiện ra ở góc dưới. Nếu bé không bấm, buổi diễn sẽ tự động nghỉ 4 giây rồi nhẹ nhàng lặp lại, bé có thể xem bao nhiêu lần tùy thích.

---

### Giai đoạn 2: Creation (Tạo Hình Bằng AI Prompting & Kỹ Thuật Phông Xanh `#00FF00`)

#### 2.1. Tại Sao Phải Dùng Phông Xanh Chroma Key (`#00FF00`)?
- Khi sinh hình ảnh dạng tranh sách cổ tích với nền trắng (`white background`), các chi tiết sáng màu như phím đàn kem (`#FDF3DA`), hào quang vàng (`#F8CF58`), lông bụng thỏ trắng (`#FFFFFF`) sẽ bị thuật toán tách nền xóa nhầm hoặc để lại viền trắng xơ xác.
- Đặt đối tượng trên **Nền Xanh Lá Tươi Thuần Khiết (`solid pure chroma key green background #00FF00`)** tạo ra khoảng cách màu sắc (Color Distance $\Delta E > 0.85$) cực đại so với màu vàng sồi, kem phím đàn, tím phù thủy và đỏ trống.
- Kết hợp với thuật toán **Khử Ám Xanh (Green Spill Suppression)** trong khâu hậu kỳ, từng sợi viền gỗ, viền áo và nốt nhạc sẽ giữ được độ sắc nét và màu viền gốc mà không bị ám màu xanh lá.

#### 2.2. Master Prompt Framework (Khuôn Prompt Xương Sống Cho Phông Xanh)
Mọi prompt sinh asset cho Màn 07 tuân thủ cấu trúc sau:

```
[CHỦ THỂ CHI TIẾT], fairytale 2.5d storybook diorama game asset, wooden toy aesthetic, painted oak wood texture, soft clay finish, warm diffused spotlight from above, gilded gold trim, vibrant fairytale colors. Cozy whimsical atmosphere for kids. Completely isolated on solid pure chroma key green background #00FF00, sharp clean edges, studio cutout view, no shadows on background, centered composition --ar [TỶ LỆ] --style raw
```

#### 2.3. Negative Prompt Chuẩn
```
text, letters, words, watermark, logo, signature, realistic fur, hyperrealistic, dark, scary, sharp fangs, evil grin, photorealism, 3d polygon wireframe, jagged edges, low resolution, green tint on character, partial crop, overlapping borders, cast shadow on green background
```

---

### Giai đoạn 3: Conversion (Hậu Kỳ, Tách Nền Phông Xanh, PBR & Đóng Gói)

#### 3.1. Thuật Toán Tách Phông Xanh (Soft Chroma Key Matting & Spill Suppression)
Quy trình thực thi qua script `tools/process_chroma_asset.py`:
1. **Color Distance Calculation**:
   - Tính khoảng cách Euclidean giữa pixel và mã màu phông xanh `#00FF00`.
   - Thiết lập ngưỡng $T_{low} = 0.22$ (trong suốt tuyệt đối) và $T_{high} = 0.38$ (chuyển tiếp alpha mềm mịn $1.0\text{px}$).
2. **Green Spill Suppression (Khử Ám Xanh Biên)**:
   - Với các pixel biên có $G > (R + B) \times 0.55$, thuật toán tự động ép kênh Green về giá trị trung bình của Red và Blue ($G = (R + B) \times 0.5$), loại bỏ hoàn toàn hiện tượng "viền xanh lá" phản chiếu từ phông nền.
3. **Bounding Box Crop & Padding**:
   - Tự động xén sát mép hình (Auto-Trim) và thêm đệm an toàn $+4\text{px}$ mỗi cạnh để chống hiện tượng texture bleeding khi mipmap/filtering.

#### 3.2. Bản Đồ Tự Phát Sáng (Emission Maps) Cho 2.5D
- Tách riêng kênh phát sáng của các chi tiết: Rương vàng thần kỳ, ngôi sao trên bảng hiệu, nốt nhạc bay, tinh thể thạch anh và phím đàn đang kích hoạt.
- Trong Godot 4.7, kết hợp với `WorldEnvironment` hoặc CanvasItem Material có chế độ Additive Blending để tạo hiệu ứng hào quang rung rinh mà không tốn draw call 3D.

#### 3.3. Đóng Gói Texture Atlas
- Gom toàn bộ 7 huy hiệu thú, nốt nhạc và tinh thể vào 1 Atlas duy nhất $1024 \times 1024\text{ px}$.
- Các asset lớn như Sân khấu, Banner gỗ và Cây đậu thần giữ kích thước gốc $2048 \times 1024$ hoặc $1280 \times 720$ với định dạng PNG Lossless.

---

### Giai đoạn 4: Asset Management & Tích Hợp Vào Godot 4.7

#### 4.1. Quy Ước Đặt Tên (Naming Convention)
- `spr_stage_finale_banner.png`: Bảng gỗ "BUỔI DIỄN RỪNG XANH"
- `spr_stage_curtain_frame.png`: Khung rèm nhung đỏ viền vàng
- `spr_stage_orchestra_ensemble.png`: Dàn nghệ sĩ 7 bạn thú và phù thủy nhỏ
- `spr_stage_magic_tree_chest.png`: Cây đậu thần mang rương báu mở bung sáng
- `spr_prop_crystal_cyan.png` / `spr_prop_crystal_purple.png`: Tinh thể thạch anh
- `spr_keyboard_wood_frame.png`: Bệ gỗ nâng 7 phím đàn
- `tex_key_white_normal.png` / `tex_key_white_pressed.png`: Mặt phím đàn piano ngà kem
- `vfx_magic_stardust.tres`: Hạt bụi sao vàng bung tỏa
- `vfx_musical_notes.tres`: Nốt nhạc ngũ sắc bay lượn
- `bgm_grand_finale_orchestra.ogg`: Bản đại hòa tấu 12s

#### 4.2. Cấu Hình Import Chuẩn Cho Godot 4.7
```ini
[remap]
importer="texture"
type="CompressedTexture2D"

[params]
compress/mode=0              ; Lossless PNG cho Sprite 2.5D & UI
compress/high_quality=true
mipmaps/generate=false       ; Tắt mipmaps để bảo tồn chi tiết sắc nét và tiết kiệm 33% VRAM
process/fix_alpha_border=true; Tự động xử lý màu viền alpha
editor/scale_with_editor_scale=false
detect_3d/compress_to=1
```

#### 4.3. Kiến Trúc Cây Scene Tree 2.5D Diorama Trong `chapter_end.gd`
```
ChapterEnd (PauseOverlay - CanvasLayer 12)
└── DioramaStage (Control - PRESET_FULL_RECT)
    ├── EnvironmentFar (Parallax / CanvasGroup - Z: -30)
    │   ├── ForestBackdrop (TextureRect - Tán rừng xanh thẫm & vệt nắng)
    │   └── MushroomCottages (Sprite2D Trái & Phải)
    ├── MagicScreen (Control - Z: -20)
    │   ├── ScreenFrame (TextureRect - Khung tranh ma thuật)
    │   ├── MagicVineTree (Sprite2D - Cây đậu thần lá nốt nhạc)
    │   ├── GlowingChest (Sprite2D - Rương báu mở bung tỏa kim quang)
    │   └── GodRaysOverlay (ColorRect - Shader ánh sáng thiên đường)
    ├── PuppetStageFloor (Control - Z: -10)
    │   ├── WoodenPlankFloor (TextureRect - Sàn gỗ sồi sân khấu)
    │   └── OrchestraEnsemble (Node2D - Dàn 7 bạn thú + Phù thủy nhỏ)
    │       ├── WizardBoyPiano (AnimatedSprite2D - Đánh đàn upright)
    │       ├── LionDrummer (AnimatedSprite2D - Gõ 3 trống)
    │       ├── BearHarpist (AnimatedSprite2D - Gảy đàn hạc)
    │       ├── CatFlutist (AnimatedSprite2D - Thổi sáo)
    │       ├── ElephantDancer (AnimatedSprite2D - Vẫy vòi múa)
    │       └── OwlSinger (AnimatedSprite2D - Vỗ cánh hát)
    ├── InteractiveKeyboard (Control - Z: 0)
    │   ├── KeyboardFrame (TextureRect - Bệ gỗ chạm khắc)
    │   ├── KeysContainer (HBoxContainer - 7 phím C D E F G A B)
    │   ├── CrystalLeft (Sprite2D - Thạch anh Cyan phát quang)
    │   ├── CrystalRight (Sprite2D - Thạch anh Magenta phát quang)
    │   └── SmallChestDecor (Sprite2D - Rương gỗ nhỏ góc phải)
    ├── ProsceniumFrame (Control - Z: +10)
    │   ├── VelvetCurtainLeft (TextureRect - Rèm nhung đỏ trái)
    │   ├── VelvetCurtainRight (TextureRect - Rèm nhung đỏ phải)
    │   └── WoodenTitleBanner (TextureRect - Biển gỗ "BUỔI DIỄN RỪNG XANH" + 2 sao)
    ├── VFXContainer (Control - Z: +20)
    │   ├── StardustParticles (GPUParticles2D - Bụi sao vàng tuôn trào)
    │   ├── MusicalNotesEmitter (GPUParticles2D - Nốt nhạc ngũ sắc)
    │   └── ConfettiCelebration (GPUParticles2D - Pháo giấy tưng bừng)
    └── NavigationHUD (Control - Z: +30)
        └── BtnContinue (Button - Nút tròn mũi tên gỗ nảy mượt mà, chỉ hiện khi hết diễn)
```

---

## PHẦN II: BREAKDOWN CHI TIẾT ASSET LIST & MASTER AI PROMPTS

Mọi asset dưới đây đều được chuẩn bị sẵn mã Prompt chất lượng cao với yêu cầu **Solid Chroma Key Green Background `#00FF00`** phục vụ việc sinh hình ảnh trực tiếp.

---

### MỤC 1: 2.5D ASSETS (SPRITES, TEXTURES, BACKGROUNDS, PROPS)

#### 1.1. Sprites & Sprite Sheets (Dàn Nghệ Sĩ & Nhạc Cụ)

##### ASSET 01: Dàn Nhạc Hòa Tấu 7 Bạn Thú & Cậu Bé Phù Thủy
* **Mã file**: `assets/art/spr_stage_orchestra_ensemble.png`
* **Mô tả**: Toàn bộ dàn nghệ sĩ tí hon đang biểu diễn hân hoan trên một hàng ngang. Cậu bé phù thủy ở giữa chơi piano gỗ upright; Sư tử đánh 3 trống con; Gấu gảy đàn hạc vàng; Mèo thổi sáo trúc; Voi nhảy múa vung vòi; Cú mèo vỗ cánh ca hát.
* **AI Prompt**:
  ```
  Masterpiece fairytale 2.5d storybook orchestra band ensemble for kids game, cute animal musicians performing together on a straight horizontal row: in the center a cute little boy wizard with purple pointed hat and star playing a charming wooden upright piano, on the left a happy lion cub drummer with sticks playing three small red drums with gold rims, a friendly bear sitting playing a golden classical harp, on the right a lovely ginger cat playing a wooden bamboo flute, a baby blue elephant dancing cheerfully with trunk raised, a chubby little owl singing happily with fluttering wings. Toy diorama style, painted oak wood texture, soft clay surface, warm vibrant colors, golden hour diffused lighting, joyous celebration expressions. Isolated completely on solid pure chroma key green background #00FF00, studio lighting, sharp edges, no shadows on green background, centered, full bodies visible --ar 16:9 --style raw
  ```

##### ASSET 02: Cậu Bé Phù Thủy Chơi Đàn Piano Upright (Solo Sprite)
* **Mã file**: `assets/art/spr_char_wizard_pianist.png`
* **Mô tả**: Cậu bé phù thủy tóc nâu hạt dẻ, ánh mắt lấp lánh cười tươi, đội mũ chóp phù thủy màu tím có ngôi sao vàng, áo choàng tím viền vàng kim, hai tay nhỏ nhắn lướt trên phím đàn piano gỗ đứng cổ kính.
* **AI Prompt**:
  ```
  Cute little boy wizard pianist, children picture-book 2.5d diorama style, wearing an oversized whimsical purple wizard hat with a golden star, royal purple cloak with warm gold trim, smiling with big joyful eyes, sitting on a wooden stool playing a charming miniature wooden upright piano with ivory keys. Warm painted wood texture, soft rounded edges, gentle diffused lighting from above, warm rim light. Completely isolated on solid pure chroma key green background #00FF00, sharp crisp cutout edges, centered, full body and instrument visible --ar 1:1 --style raw
  ```

##### ASSET 03: Sư Tử Nhạc Công Gõ Bộ 3 Trống Con (Solo Sprite)
* **Mã file**: `assets/art/spr_char_lion_drummer.png`
* **Mô tả**: Chú sư tử con bờm nâu tròn mập mạp, hai tay cầm hai dùi trống gỗ gõ tưng bừng trên bộ 3 chiếc trống con da màu đỏ viền dập đinh tán vàng.
* **AI Prompt**:
  ```
  Cute baby lion cub drummer, fairytale storybook 2.5d diorama style, friendly round fluffy mane, joyful smile, holding two wooden drumsticks playing a set of three cute wooden snare drums with warm red shells and golden brass rims. Tactile wooden toy aesthetic, soft clay details, warm diffused lighting. Completely isolated on solid pure chroma key green background #00FF00, crisp cutout edges, centered, full body and drums visible --ar 1:1 --style raw
  ```

##### ASSET 04: Chú Gấu Gảy Đàn Hạc Vàng (Solo Sprite)
* **Mã file**: `assets/art/spr_char_bear_harpist.png`
* **Mô tả**: Chú gấu nâu hiền lành mũm mĩm, ngồi ôm cây đàn hạc cổ điển chạm khắc mạ vàng sáng bóng, các ngón tay múp míp đang gảy dây đàn.
* **AI Prompt**:
  ```
  Adorable chubby brown bear harpist, fairytale storybook 2.5d diorama asset, gentle smiling expression, seated comfortably holding and plucking an elegant curved golden classical harp with glowing strings. Tactile hand-painted wood texture, warm cozy lighting, soft shadows. Completely isolated on solid pure chroma key green background #00FF00, sharp cutout edges, centered, full body and harp visible --ar 1:1 --style raw
  ```

##### ASSET 05: Chú Mèo Thổi Sáo Trúc (Solo Sprite)
* **Mã file**: `assets/art/spr_char_cat_flutist.png`
* **Mô tả**: Chú mèo mướp vàng cam dễ thương, đứng nghiêng đầu thổi chiếc sáo trúc ngang, hai mắt nhắm tít say sưa theo điệu nhạc.
* **AI Prompt**:
  ```
  Cute ginger tabby cat flutist, fairytale storybook 2.5d diorama style, standing gracefully playing a transverse wooden bamboo flute, peaceful happy face with closed eyes enjoying the melody, fluffy tail curling happily. Painted wood and soft felt texture, warm golden highlights. Completely isolated on solid pure chroma key green background #00FF00, crisp edges, centered, full body visible --ar 1:1 --style raw
  ```

##### ASSET 06: Chú Voi Nhỏ Nhảy Múa & Vỗ Tay (Solo Sprite)
* **Mã file**: `assets/art/spr_char_elephant_dancer.png`
* **Mô tả**: Chú voi con màu xám xanh pastel, tai to vểnh hồng, vòi cong lên vui sướng, hai chân nhún nhảy nhảy múa chúc mừng chiến thắng.
* **AI Prompt**:
  ```
  Playful baby blue-gray elephant dancer, fairytale storybook 2.5d diorama style, large friendly ears with soft pink insides, trunk curled upward happily trumpeting in celebration, cute dancing pose with one foot slightly lifted. Smooth clay and tactile matte finish, warm rim light. Completely isolated on solid pure chroma key green background #00FF00, sharp clean edges, centered, full body visible --ar 1:1 --style raw
  ```

##### ASSET 07: Cú Mèo Nhỏ Ca Hát Vỗ Cánh (Solo Sprite)
* **Mã file**: `assets/art/spr_char_owl_singer.png`
* **Mô tả**: Chú cú mèo tròn vo lông nâu đốm hạt dẻ, mỏ vàng nhỏ đang mở hót líu lo, hai cánh vỗ nhè nhẹ, đôi mắt to tròn long lanh hạnh phúc.
* **AI Prompt**:
  ```
  Cute chubby little owl singer, fairytale storybook 2.5d diorama asset, fluffy speckled brown and cream feathers, small golden beak open singing happily, wings gently flapping in joyful rhythm, big sparkly wide eyes. Painted wooden toy charm, soft ambient lighting. Completely isolated on solid pure chroma key green background #00FF00, sharp clean cutout edges, centered, full body visible --ar 1:1 --style raw
  ```

---

#### 1.2. Textures & Bối Cảnh (Backgrounds, Stage Screen & Curtains)

##### ASSET 08: Khung Sân Khấu Múa Rối Rèm Nhung Đỏ & Viền Vàng
* **Mã file**: `assets/art/spr_stage_curtain_frame.png`
* **Mô tả**: Khung sân khấu kịch múa rối bằng gỗ sồi điêu khắc uốn lượn, hai bên là rèm nhung đỏ thẫm nếp gấp mềm mại có dây thừng tua rua vàng óng buộc lại, viền trên là dải rèm lượn sóng viền chỉ vàng kim.
* **AI Prompt**:
  ```
  Puppet theater proscenium stage frame with luxury red velvet curtains, 2.5d diorama pop-up book asset, richly carved warm oak wood border with embossed golden filigree, deep crimson velvet side drapes tied back with braided golden silk cords and tassels, scalloped velvet valance at top. Elegant storybook theatrical aesthetic, warm ambient highlights. Completely isolated on solid pure chroma key green background #00FF00, center transparent stage opening, crisp clean border edges --ar 16:9 --style raw
  ```

##### ASSET 09: Màn Hình Tranh Ma Thuật: Cây Đậu Thần & Rương Báu Bung Tỏa Hào Quang
* **Mã file**: `assets/art/spr_stage_magic_tree_chest.png`
* **Mô tả**: Bức tranh cổ tích kỳ ảo đóng khung gỗ mạ vàng viền xanh ngọc: Cây Đậu Thần xanh mướt uốn lượn vươn cao, các phiến lá hình nốt nhạc phát sáng; trên ngọn cây là chiếc Rương Báu Thần bằng gỗ mạ vàng đang bung nắp tỏa ra những luồng hào quang vàng rực rỡ, các nốt nhạc ngũ sắc và pháo hoa bay lơ lửng giữa nền trời hoàng hôn khu rừng.
* **AI Prompt**:
  ```
  Magical beanstalk tree with treasure chest reward inside an ornate gilded picture frame, fairytale 2.5d storybook diorama style: giant spiraling emerald green musical vine growing upwards with glowing leaves shaped like musical notes, at the very top sits an open antique wooden treasure chest radiating brilliant golden light beams, sparkling stardust and rainbow musical clefs swirling into the sky. Soft enchanted twilight forest in background with warm glowing fairy cottage in distance. Warm rich colors, divine volumetric lighting, painterly storybook texture. Completely isolated on solid pure chroma key green background #00FF00, centered, complete frame visible --ar 16:9 --style raw
  ```

##### ASSET 10: Hậu Cảnh Rừng Già & Nhà Nấm Cổ Tích (Parallax Background)
* **Mã file**: `assets/art/tex_bg_twilight_forest.png`
* **Mô tả**: Khung cảnh khu rừng cổ tích lúc hoàng hôn buông xuống, tán cây cổ thụ màu xanh ngọc thẫm, những tia nắng vàng ấm áp rọi qua vòm lá, hai bên bìa rừng là hai ngôi nhà nấm nhỏ mái ngói đỏ và tím với ánh đèn vàng ấm áp hắt ra từ ô cửa sổ.
* **AI Prompt**:
  ```
  Enchanted twilight forest background for children storybook game, deep teal and navy green canopy, soft magical god rays streaming down through lush leaves, cozy whimsical fairy mushroom cottages with glowing warm yellow windows nestled among the trees on left and right, soft mossy ground. Dreamy, peaceful, painterly art style, rich atmospheric depth. Seamless landscape view, 1280x720 composition --ar 16:9 --style raw
  ```

---

#### 1.3. Đạo Cụ & Chi Tiết Sân Khấu (Props & Keyboard Stage)

##### ASSET 11: Bàn Phím Piano Gỗ 7 Phím 2.5D Cùng Huy Hiệu Thú
* **Mã file**: `assets/art/spr_keyboard_stage_base.png`
* **Mô tả**: Bàn phím piano gỗ sồi uốn lượn cổ tích đặt trên sàn cỏ, gồm 7 phím trắng ngà kem to bản và các phím đen. Trên mỗi phím trắng có một huy hiệu tròn nổi in hình mặt bạn thú và chữ cái nốt nhạc ngũ sắc (C, D, E, F, G, A, B).
* **AI Prompt**:
  ```
  Fairytale wooden piano keyboard tier for kids game, 2.5d diorama diorama stage element, carved warm oak wood chassis with smooth organic swirls, seven large ivory white piano keys and black keys, each white key has a cute round colorful animal face badge with note letter: C (lion red), D (bear orange), E (rabbit pink), F (cat green), G (monkey blue), A (elephant purple), B (owl brown). Soft glossy finish, tactile wooden toy aesthetic, warm lighting. Completely isolated on solid pure chroma key green background #00FF00, straight horizontal angle, clean cutout edges --ar 16:9 --style raw
  ```

##### ASSET 12: Cụm Tinh Thể Thạch Anh Xanh Cyan Phát Quang
* **Mã file**: `assets/art/spr_prop_crystal_cyan.png`
* **Mô tả**: Cụm tinh thể pha lê thạch anh xanh ngọc cyan nhiều góc cạnh mọc trên gốc cây gỗ mục, phát ra ánh sáng huỳnh quang xanh ngọc dịu êm.
* **AI Prompt**:
  ```
  Glowing cyan quartz crystals cluster growing on an aged mossy tree stump, fairytale storybook 2.5d diorama asset, translucent magical turquoise and aqua gemstones with glowing facets, soft bioluminescent inner light, cute rounded crystal tips for children safety aesthetic. Completely isolated on solid pure chroma key green background #00FF00, clean sharp edges, centered --ar 1:1 --style raw
  ```

##### ASSET 13: Cụm Tinh Thể Thạch Anh Tím Magenta Phát Quang
* **Mã file**: `assets/art/spr_prop_crystal_purple.png`
* **Mô tả**: Cụm tinh thể thạch anh màu tím hồng magenta lấp lánh mọc trên gốc cây gỗ, phát ra ánh hào quang tím ma thuật ấm áp.
* **AI Prompt**:
  ```
  Glowing magenta purple quartz crystal cluster on an antique wood base, fairytale storybook 2.5d game asset, translucent violet and pink crystal prisms emitting a soft magical glow, charming storybook feel. Completely isolated on solid pure chroma key green background #00FF00, clean cutout edges, centered --ar 1:1 --style raw
  ```

##### ASSET 14: Chiếc Rương Gỗ Nhỏ Khóa Đồng Góc Sân Khấu
* **Mã file**: `assets/art/spr_prop_small_closed_chest.png`
* **Mô tả**: Chiếc rương báu bằng gỗ nhỏ gọn gàng nằm trên thảm cỏ, có đai nẹp bằng đồng dập hoa văn và một chiếc ổ khóa đồng hình lỗ khóa tròn ngộ nghĩnh.
* **AI Prompt**:
  ```
  Small closed wooden treasure chest resting on grass, fairytale storybook 2.5d diorama asset, warm oak wood planks, brass metal bands with round rivets, cute brass keyhole lock, gentle whimsical styling. Completely isolated on solid pure chroma key green background #00FF00, sharp clean edges, centered --ar 1:1 --style raw
  ```

---

### MỤC 2: UI / UX ASSETS (HUD, MENUS, ICONS, TYPOGRAPHY)

#### 2.1. HUD & Bảng Hiệu Tiêu Đề

##### ASSET 15: Bảng Hiệu Gỗ Uốn Lượn "BUỔI DIỄN RỪNG XANH"
* **Mã file**: `assets/art/ui_banner_grand_finale.png`
* **Mô tả**: Bảng ruy băng gỗ sồi chạm khắc uốn lượn sang trọng đặt trên đỉnh sân khấu, viền dập nổi hoa văn vàng kim, đính hai ngôi sao vàng 5 cánh tỏa sáng ở hai đầu, ở giữa là dòng chữ chạm khắc mạ vàng nổi bật: `BUỔI DIỄN RỪNG XANH`.
* **AI Prompt**:
  ```
  Whimsical curved wooden banner ribbon plaque with golden border and two glowing 3d gold stars on each end, fairytale storybook 2.5d diorama UI asset, warm polished oak wood texture, embossed gilded gold lettering that reads 'BUỔI DIỄN RỪNG XANH' in friendly rounded bold font, gentle sparkles around the stars. Completely isolated on solid pure chroma key green background #00FF00, centered horizontal ribbon, crisp cutout edges --ar 16:9 --style raw
  ```

##### ASSET 16: Nút Điều Hướng Gỗ Mũi Tên Tiếp Tục (Continue Button)
* **Mã file**: `assets/art/ui_btn_continue_arrow.png`
* **Mô tả**: Nút tròn bằng gỗ sồi to bản chạm khắc viền lá cây xanh ngọc, ở giữa là biểu tượng mũi tên màu vàng kem bo tròn thân thiện, xúc giác nảy mềm mại khi chạm.
* **AI Prompt**:
  ```
  Chunky circular wooden game button with forward arrow icon, children storybook UI asset, polished warm wood texture with soft rounded beveled edge, carved ivory cream right-facing arrow symbol, tactile Montessori wooden toy aesthetic. Completely isolated on solid pure chroma key green background #00FF00, clean circle cutout, centered --ar 1:1 --style raw
  ```

#### 2.2. Bộ 7 Huy Hiệu Tròn Đầu Thú Cho Phím Đàn (Animal Badges 1:1)
* **Quy chuẩn kích thước**: $256 \times 256\text{ px}$, bo tròn hoàn hảo, viền màu đại diện nốt nhạc.
* **Prompt Bộ Lô (Grid Batch)**:
  ```
  Grid of seven circular animal face token badges for preschool piano keys: Lion (red C), Bear (orange D), Rabbit (pink E), Cat (green F), Monkey (cyan G), Elephant (purple A), Owl (brown B). Each badge is a thick wooden token with raised smooth enamel animal face, joyful smiling expressions, friendly big eyes. Uniform lighting, same circle size. Completely isolated on solid pure chroma key green background #00FF00, sharp circular borders, evenly spaced --ar 1:1 --style raw
  ```

#### 2.3. Typography & Style Guide Màn 07
* **Phông chữ chủ đạo**: Phông không chân bo tròn (Rounded Sans-Serif / Hand-drawn Storybook Font như *Fredoka One*, *Baloo 2*, hoặc *Patrick Hand*).
* **Quy tắc cỡ chữ & khả năng tiếp cận**:
  - Tiêu đề Banner: Dập nổi 3D mạ vàng, cỡ chữ tương đương $42 - 48\text{ pt}$.
  - Gợi ý cho phụ huynh (Footer): Dòng chữ mảnh dịu dàng mờ $50\%$ mod white: *"Muốn giữ lại buổi diễn? Bật quay màn hình của máy — buổi diễn sẽ tự chạy lại."* (Dành cho mắt người lớn nhìn qua vai, không làm phiền trải nghiệm thị giác của bé).
  - Vùng chạm (Touch Target): Nút bấm $\ge 96 \times 96\text{ pt}$, đạt tiêu chuẩn tối đa của Apple Kids Category.

---

### MỤC 3: AUDIO ASSETS (SFX, MUSIC, VOICE LINES)

Màn 07 là phần thưởng về thính giác cao nhất của trò chơi, kết hợp trọn vẹn dàn nhạc mộc mạc và âm hưởng vinh quang.

#### 3.1. Âm Nhạc Đại Hòa Tấu (Music)
* **File**: `assets/audio/bgm_grand_finale_orchestra.ogg`
* **Thời lượng**: Đúng $12.0\text{ giây}$ (khớp với tiến trình hoạt ảnh cây đậu thần và phím đàn).
* **Cấu trúc hòa âm**:
  - 0.0s – 1.0s: Tiếng rương báu bung mở ngân vang kèm tiếng chuông gió lấp lánh (Wind Chimes glissando).
  - 1.0s – 10.2s: Giai điệu ngũ cung chính xác của chương được tấu lên với sự hòa quyện của 5 nhạc cụ:
    * Tiếng gõ trống tưng bừng giữ nhịp (Lion's drums).
    * Hợp âm đàn hạc rải ngọc ngà (Bear's harp arpeggios).
    * Tiếng sáo trúc lảnh lót dẫn dắt giai điệu (Cat's bamboo flute).
    * Tiếng piano gỗ ấm áp đệm hợp âm tròn trịa (Wizard's piano).
    * Tiếng chuông lắc và tiếng vỗ tay rộn ràng (Elephant & Owl).
  - 10.2s – 12.0s: Hợp âm kết thúc hùng tráng, tiếng pháo giấy bung nổ nhẹ và tiếng reo hò êm ái của muôn loài rừng xanh.

#### 3.2. Hiệu Ứng Âm Thanh (SFX)
1. `sfx_chest_triumph_open.wav`: Tiếng gỗ mở "cạch" mộc mạc kèm tiếng ngân vang ma thuật của kho báu cổ tích (Stereo, 44.1kHz, 24-bit).
2. `sfx_drum_roll_trio.wav`: Tiếng gõ 3 chiếc trống con da thuộc ấm áp, tạo nhịp điệu rộn ràng.
3. `sfx_harp_glissando_gold.wav`: Tiếng vuốt dây đàn hạc mạ vàng trong trẻo, réo rắt.
4. `sfx_flute_happy_trill.wav`: Tiếng láy sáo trúc mộc mạc, tươi vui như tiếng chim hót mùa xuân.
5. `sfx_piano_sparkle_chord.wav`: Hợp âm piano gỗ vang ấm, tạo nền giai điệu sâu lắng.
6. `sfx_forest_cheer_applause.wav`: Tiếng vỗ tay và tiếng reo vui của các em nhỏ kết hợp tiếng muôn thú chúc mừng chiến thắng (ấm áp, không chói gắt).

#### 3.3. Tiếng Kêu Vui Của Các Bạn Thú (Animal Voice Lines)
Mỗi bạn thú phát ra âm thanh đặc trưng thân thiện khi nốt nhạc tương ứng vang lên:
- Sư tử: *"Graoo~!"* (tiếng gầm con nít đáng yêu).
- Gấu: *"Uhm-hum~!"* (tiếng ậm ừ hiền lành).
- Thỏ: *"Chíp-chíp!"* (tiếng tặc lưỡi nhảy múa).
- Mèo: *"Meo-meo~!"* (tiếng thánh thót nũng nịu).
- Khỉ: *"Khẹc-khẹc!"* (tiếng cười khúc khích).
- Voi: *"Pa-wooo!"* (tiếng vòi thổi vui mừng).
- Cú: *"Gu-gu, hú-hú!"* (tiếng ca hát đêm trăng).

---

### MỤC 4: VFX & SHADERS (PARTICLES, SCREEN EFFECTS, SHADERS)

#### 4.1. Hệ Thống Hạt Hiệu Ứng (Particle Effects)
1. **`vfx_magic_stardust.tres` (Bụi Sao Vàng Kim)**:
   - GPUParticles2D phát ra từ miệng rương thần trên đỉnh cây đậu.
   - Texture: Ngôi sao 4 cánh mạ vàng và hạt ngọc lấp lánh.
   - Chuyển động: Bung tỏa hình quạt lên trên rồi xoay tròn rơi chậm chạp theo trọng lực $g = 40\text{ px/s}^2$.
2. **`vfx_musical_notes_ribbon.tres` (Dải Nốt Nhạc Ngũ Sắc Bay)**:
   - GPUParticles2D phát ra từ các phím đàn và các nhạc cụ.
   - Texture: Khóa son, nốt móc đơn, móc kép màu đỏ, cam, vàng, lục, lam, tím.
   - Chuyển động: Uốn lượn hình sin bay lên cao về phía Cây Đậu Thần.
3. **`vfx_confetti_celebration.tres` (Pháo Giấy Ăn Mừng)**:
   - Rơi nhẹ nhàng từ đỉnh khung rèm nhung xuống hai bên cánh gà tạo không khí lễ hội.

#### 4.2. Shaders Tối Ưu Cho 2.5D Mobile
1. **Shader Rèm Nhung Óng Ả (`velvet_curtain.gdshader`)**:
   - Tính toán độ bóng mờ Fresnel và vệt sáng dọc theo nếp gấp (Fabric Anisotropy) tạo cảm giác vải nhung mềm mại mà không cần lưới 3D nặng nề.
2. **Shader Hào Quang Phím Đàn (`key_glow_pulse.gdshader`)**:
   - Tạo quầng sáng phát quang xung quanh viền phím đàn khi nốt nhạc được kích hoạt, mượt mà chuyển tiếp theo chu kỳ $\sin(\omega t)$.
3. **Shader Cây Thần Vươn Nở (`magic_vine_bloom.gdshader`)**:
   - Sử dụng kênh Alpha Clip hoặc UV Reveal theo trục Y để thân cây đậu thần vươn cao nhịp nhàng từ gốc lên ngọn đồng bộ với 23 nốt nhạc của buổi diễn.

---

## PHẦN III: HƯỚNG DẪN THỰC THI TUẦN TỰ CHO INDIE DEVELOPER

```
[BƯỚC 1: SINH ẢNH PHÔNG XANH] ──► [BƯỚC 2: TÁCH NỀN TỰ ĐỘNG] ──► [BƯỚC 3: CẤU HÌNH GODOT] ──► [BƯỚC 4: LẮP RÁP DIORAMA]
  Master AI Prompts (#00FF00)      process_chroma_asset.py       make_godot_import.py          game/ui/chapter_end.gd
```

1. **Bước 1 — Sinh hình ảnh trên phông xanh**: Dùng `generate_image` với các prompt ở Mục 1 & 2, luôn chỉ định rõ nền xanh thuần khiết `#00FF00`.
2. **Bước 2 — Chạy script tách nền và khử ám xanh**:
   ```bash
   /usr/local/bin/python3 tools/process_chroma_asset.py \
     --input "path/to/raw_generated.png" \
     --output "assets/art/spr_stage_orchestra_ensemble.png" \
     --color-key "#00FF00" \
     --tolerance 0.25 \
     --spill-suppression \
     --feather 1.0 \
     --trim --padding 4
   ```
3. **Bước 3 — Tạo cấu hình `.import` cho Godot 4.7**:
   ```bash
   /usr/local/bin/python3 .agents/skills/godot-asset-generator/scripts/make_godot_import.py \
     --input "assets/art/spr_stage_orchestra_ensemble.png" \
     --preset storybook-hd
   ```
4. **Bước 4 — Lắp ráp và đồng bộ hóa trong `chapter_end.gd`**:
   - Thay thế toàn bộ logic nạp ảnh tĩnh bằng kiến trúc 2.5D Diorama Stage.
   - Đồng bộ nhịp nốt nhạc với hoạt ảnh nhún nhảy của các bạn thú, thân cây đậu nở hoa và rương báu bung sáng.
5. **Bước 5 — Kiểm thử và tối ưu hóa**:
   - Chạy Godot headless và visual capture test để bảo đảm VRAM < 65MB, không drop frame trên thiết bị di động.
