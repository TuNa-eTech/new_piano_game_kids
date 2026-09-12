# QUY TRÌNH MỸ THUẬT 2.5D (GAME ART PIPELINE) & DANH MỤC ASSET PROMPT AI
# MÀN 05: CHỌN 5 MÀN CHƠI ("LEVEL SELECTION / SONG ROAD")

> **Dự án**: Rừng Nhạc (Enchanted Music Forest) — Game Âm Nhạc Trẻ Em 3–6 Tuổi  
> **Nguồn cảm hứng thiết kế**: [`docs/mock-level-select.jpeg`](file:///Users/anhtu/MySpace/new-piano/docs/mock-level-select.jpeg)  
> **Nền tảng mục tiêu**: Godot Engine 4.7+ (Forward Mobile / iOS Metal / Android Vulkan)  
> **Phong cách cốt lõi**: Sách Tranh Nổi 2.5D Diorama (Layered Pop-up Book Diorama) kết hợp đồ chơi gỗ xúc giác cao cấp  
> **Triết lý tương tác**: Zero-Text Preschool UX (Trực quan hóa 100%, không chữ viết rào cản, bảo vệ toàn diện tâm lý trẻ nhỏ)

---

## PHẦN I: QUY TRÌNH MỸ THUẬT GAME 2.5D DÀNH CHO INDIE DEVELOPER (4 GIAI ĐOẠN)

Quy trình mỹ thuật 2.5D Diorama được thiết kế tối ưu hóa cho nhà phát triển độc lập (Indie Game Developer), tận dụng sức mạnh của các mô hình AI sinh hình ảnh hiện đại nhất, kết hợp quy trình hậu kỳ chuẩn hóa và kiến trúc phân lớp chuyên sâu của Godot 4.7+.

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                               2.5D POP-UP DIORAMA ART PIPELINE                                  │
├───────────────────┬───────────────────┬───────────────────────────┬─────────────────────────────┤
│    1. CONCEPT     │    2. CREATION    │       3. CONVERSION       │     4. ASSET MANAGEMENT     │
│                   │                   │                           │                             │
│ • Style Lock      │ • Master Prompts  │ • AI Alpha Matting        │ • Godot 4.7 Import Presets  │
│ • Color Extraction│ • Grid Batching   │ • Defringe & Color Bleed  │ • 2.5D Layering & Z-Index   │
│ • 2.5D Oblique    │ • Seed & StyleRef │ • Normal / Roughness / ORM│ • Draw Call & VRAM Budgets  │
│ • Zero-Text UX    │ • Neg-Prompt Safe │ • Texture Atlas & 9-Slice │ • Touch Target Standards    │
└───────────────────┴───────────────────┴───────────────────────────┴─────────────────────────────┘
```

---

### Giai đoạn 1: Concept (Khái Niệm, Khóa Phong Cách Thị Giác & Chiều Sâu 2.5D)

#### 1.1. Ngôn ngữ tạo hình & Không gian Sân khấu Sách Nổi 2.5D (Diorama Pop-up Stage)
* **Không gian tổng thể**: Một cuốn truyện tranh mở rộng đặt giữa thung lũng rừng xanh huyền thoại. Trên mặt trang giấy da kem mở rộng là một **sân khấu diorama 2.5D** mô phỏng một thung lũng cổ tích thu nhỏ:
  - Một **con đường đá cuội rêu xanh uốn lượn** dẫn lối qua rừng cây, thảm cỏ, khóm nấm đỏ chấm bi và các bụi hoa rừng.
  - Trên con đường là **5 bục gỗ khoanh cây cắt ngang (Tree Log Slice Pedestals)** đại diện cho 5 bài hát của chương.
  - **Bục số 4 (Đang chơi)**: Có **Vòng hào quang vàng ma thuật (Golden Aura Ring)** phát sáng xoay tròn trên mặt đất; trên bục là **Bạn Thỏ Trắng (White Bunny Mascot)** đứng hai chân, vẫy tay tươi cười, xung quanh là dải nốt nhạc ngũ sắc (hồng, cyan, vàng) bay bổng lượn lờ.
  - **Bục số 5 (Bài cuối chương / Rương báu)**: Đặt một **Chiếc Rương Báu Thần mạ vàng** tỏa ánh hào quang và các ngôi sao lấp lánh mời gọi bé chinh phục.
  - **Dọc con đường**: Có các **huy hiệu gỗ tròn mang hình các bạn thú** (Sư tử con, Gấu con, Mèo con) cắm cọc mốc hoặc nép sau bụi cây, đại diện cho bạn bè đồng hành hoặc thành tích đã đạt được.
* **Góc phối cảnh 2.5D**: Chiếu xiên nghiêng $18^\circ$ (Isometric/Oblique Tilt) nhìn từ trên xuống tạo chiều sâu sân khấu nhiều tầng.
* **Cấu trúc không gian 4 tầng thị giác**:
  1. **Tầng Hậu cảnh (Far Background - Parallax)**: Rừng trúc ngọc bích sương mờ mộng ảo, vòm cây cao vút với luồng sáng thần tiên (God rays) rọi từ khe sáng trung tâm, bầu trời xanh ngọc dịu êm.
  2. **Tầng Trung cảnh (Midground - Environment Wings)**:
     - Cánh gà trái: Ngôi nhà nấm/nhà gỗ cổ tích với mái ngói đỏ hồng, ống khói đá, cửa gỗ xanh lá với ô kính hình quả trám, cửa sổ áp mái tròn phát sáng ấm áp; gốc cây mục có cụm thạch anh xanh Cyan phát quang rực rỡ; thân cây cổ thụ uốn lượn vươn cành khép viền màn hình.
     - Cánh gà phải: Ngôi nhà cổ tích mái ngói xanh lam xám có gác xép đèn vàng; một chiếc rương gỗ nhỏ phụ trên thảm cỏ ven bìa rừng; thân cây cổ thụ uốn cong đối xứng.
  3. **Tầng Sân khấu Sách Nổi (Stage Ground - Storybook Base & 5 Pedestals)**:
     - Mặt trang sách da kem dày dặn, gáy sách uốn lượn hai bên, mép trang sách có độ cong 3D tự nhiên.
     - Con đường đá cuội xám viền rêu xanh dẫn từ bục 1 $\rightarrow$ 2 $\rightarrow$ 3 $\rightarrow$ 4 $\rightarrow$ 5.
     - 5 bục gỗ khoanh cây cắt ngang với vòng tuổi tự nhiên, vỏ cây nâu sần sùi, số nổi 3D (1, 2, 3, 4, 5).
     - Các bài đã hoàn thành (1, 2, 3) có cụm 3 ngôi sao vàng dập nổi bay lơ lửng bên trên.
     - Bục 4: Bạn Thỏ trắng nhún nhảy và vòng hào quang vàng xoay chuyển.
     - Bục 5: Rương báu thần lấp lánh ánh kim.
  4. **Tầng Điều hướng Tiền cảnh (Foreground HUD & Navigation)**:
     - Bảng gỗ sồi chạm khắc Baroque tiêu đề: `Chương 1: Sáo Trúc Rừng Xanh` (có thể thay đổi linh hoạt cho các chương khác).
     - Nút tròn gỗ bo tròn với icon mũi tên quay lại (`↶ Quay lại`) ở góc trái trên.
     - Hũ sao thủy tinh nắp bần (Star Jar) đựng ngôi sao vàng phát sáng ở góc phải trên.
     - Các lùm cây xanh mướt bo tròn mép trước cuốn sách tạo tiền cảnh che chở.

#### 1.2. Bảng Màu Chuẩn (Hút Trực Tiếp Từ `mock-level-select.jpeg`)
Đo đạc chính xác bằng phương pháp lượng tử hóa màu từ ảnh tham chiếu, giữ sự đồng bộ 100% với phong cách nghệ thuật của game:

| Tên Màu | Mã Hex | Ứng Dụng Trong Màn 05 | Cảm Xúc & Tâm Lý Trẻ Nhỏ |
|---|---|---|---|
| **Vàng Giấy Da Kem** | `#FBE3B5` / `#E8CF9F` | Trang sách mở, bề mặt thớt gỗ bục, số 3D | Ấm áp, hoài niệm, thân thiện như trang truyện cổ |
| **Nâu Gỗ Sồi Cổ** | `#754323` / `#4E2A14` | Bục gỗ khoanh cây, bảng gỗ tiêu đề, nút quay lại | Chắc chắn, xúc giác đồ chơi tự nhiên, an toàn |
| **Vàng Kim Hào Quang** | `#FCD04B` / `#FFE678` | Vòng hào quang bục 4, sao vàng 3 sao, rương báu | Lấp lánh, vương giả, khơi gợi cảm giác thành tựu |
| **Xanh Rêu Thảm Cỏ** | `#3D9A54` / `#5EB86E` | Nền cỏ xanh mướt, viền rêu đá cuội, lá cây | Tươi mát, tràn đầy sức sống, êm dịu cho mắt |
| **Xanh Rừng Trúc Sương Mờ** | `#1E6354` / `#16483C` | Rừng trúc hậu cảnh, tán lá sâu xa | Huyền bí, thanh bình, tạo độ sâu không gian thăm thẳm |
| **Cyan Thạch Anh & Nốt Nhạc**| `#4AE5D8` / `#2ABEB3` | Tinh thể thạch anh gốc cây, nốt nhạc bay, đom đóm | Ma thuật, tinh khôi, kích thích trí tò mò |
| **Hồng Sen & Đỏ Ngói** | `#D95B72` / `#ED7A8E` | Mái nhà nấm bên trái, nốt nhạc bay, tai thỏ | Ngọt ngào, vui tươi, ấm áp |
| **Xanh Lam Xám Ngói** | `#3B6B82` / `#528EA6` | Mái nhà cổ tích bên phải, đá cuội lát đường | Dịu mắt, tạo điểm cân bằng với tông đỏ ấm |
| **Trắng Tuyết Mềm Mại** | `#FFFDF7` / `#F0ECE1` | Bộ lông bé Thỏ trắng, đốm nấm, tia sáng | Thuần khiết, trong sáng, đáng yêu |

#### 1.3. Triết Lý Zero-Text Cho Trẻ Mầm Non (Preschool Friendly UX)
1. **Trực quan hóa trạng thái bài học (Level States Without Text)**:
   - Bé 3–5 tuổi không cần đọc số hay chữ để biết bài nào đã chơi hay đang chơi:
     * **Bài đã hoàn thành (Màn 1, 2, 3)**: Trên bục có **3 ngôi sao vàng rực rỡ** bay lơ lửng, mặt bục sáng rõ.
     * **Bài hiện tại (Màn 4)**: Có **Bạn Thỏ trắng đứng vẫy tay** nhún nhảy chào đón, chân bục có **Vòng hào quang vàng rực rỡ xoay tròn** kèm theo các nốt nhạc ngũ sắc bay lơ lửng. Bé nhìn là muốn chạm vào ngay!
     * **Bài đích đến / Phần thưởng (Màn 5)**: Đặt một **Chiếc Rương Báu Thần** mạ vàng đang lấp lánh phát quang, thôi thúc bé hoàn thành bài 4 để mở rương.
     * **Bài bị khóa (nếu có)**: Phủ một lớp sương mờ tối nhẹ và chiếc ổ khóa nhỏ bằng gỗ/đồng.
2. **Kích thước vùng chạm (Touch Target Standards)**:
   - Cả 5 bục gỗ đều có kích thước vùng chạm thực tế $\ge 120 \times 120\text{ pt}$, vượt xa tiêu chuẩn tối thiểu $44\text{ pt}$ của Apple Kids Category. Trẻ dùng cả bàn tay hay ngón tay cái chạm vào màn hình iPad đều ăn lệnh chính xác.
3. **Phản hồi xúc giác & âm thanh tức thời (Tactile & Auditory Delight)**:
   - Chạm vào bục: Bục gỗ nún xuống rồi nảy đàn hồi (Squash & Stretch), phát ra tiếng "Cộc!" của gỗ gõ kèm tiếng chuông gió/sáo trúc vui nhộn.
   - Bạn Thỏ nhảy cẫng lên reo vui khi bé chọn bài đang chơi.

---

### Giai đoạn 2: Creation (Tạo Hình Bằng Kỹ Thuật AI Prompting Chuyên Sâu)

#### 2.1. Quy Tắc Sinh Theo Lô (Grid Batch Generation)
* **Nguyên tắc cốt lõi**: Không sinh rời rạc từng bục gỗ hay từng nốt nhạc. Sinh trọn bộ 5 bục gỗ, bộ huy hiệu bạn thú, hoặc bộ đạo cụ trên một tấm bảng lưới (Sprite Sheet Grid) trên nền trắng tinh khiết (`pure white background, isolated studio product cutout`).
* **Đồng bộ nguồn sáng**: Nguồn sáng vàng ấm góc nghiêng $45^\circ$ từ trên rọi xuống (Top-down warm golden-hour light) kết hợp ánh sáng ven viền hổ phách (Amber Rim Light).

#### 2.2. Master Prompt Framework (Khung Prompt Xương Sống Cho Màn 05)
Mọi prompt tạo asset cho Màn 05 đều kế thừa cấu trúc xương sống sau:

```
[CHỦ THỂ CỤ THỂ], layered 2.5D pop-up diorama asset for preschool music game, storybook fairytale art style. Charming rounded shapes, tactile toy wooden aesthetic, soft darker tone outline (never pure black), warm overhead golden-hour diffused lighting, sparkling amber rim light. Palette: parchment cream #FBE3B5, warm oak wood #754323, embossed gold #FCD04B, mossy green #3D9A54, deep bamboo teal #1E6354, glowing cyan crystal #4AE5D8, fairytale pink #D95B72, soft white #FFFDF7. Cozy, gentle, playful for 3-year-olds. Clean solid white background, centered, isolated asset cutout, orthographic pop-up book view, zero artifacts --ar [TỈ LỆ] --style raw
```

#### 2.3. Negative Prompt Master (Bộ Từ Khóa Phủ Định Bắt Buộc)
```
photorealistic, human realism, scary, sharp teeth, aggressive, horror, dark gritty, mechanical metal wires, 3d low poly wireframe, pixelated, noisy textures, harsh pure black outlines, washed out colors, blurry, cropped, watermark, signature, modern UI, plastic gloss, messy borders, text gibberish
```

#### 2.4. Kỹ Thuật Giữ Tính Nhất Quán Theo Từng Công Cụ AI
* **Midjourney v6**:
  - Dùng `--sref res://docs/mock-level-select.jpeg --sw 700 --c 2 --style raw`.
  - Giữ tỷ lệ phù hợp: `--ar 16:9` cho phong cảnh và trang sách mở; `--ar 1:1` cho bục gỗ, huy hiệu bạn thú, rương báu; `--ar 3:4` cho nhân vật Thỏ.
* **Stable Diffusion XL / Flux.1**:
  - Checkpoint: Cartoon / Fairytale Anime (như *PonyDiffusion* hoặc *Flux.1 Dev*).
  - LoRA đề xuất: `children_storybook_illustration:0.8`, `wooden_toy_diorama:0.6`.
  - Cố định Seed và Scheduler: DPM++ 2M Karras, CFG Scale 6.0–6.5.
* **Google Gemini / Nano Banana**:
  - Đính kèm ảnh `docs/mock-level-select.jpeg` làm Style Anchor: *"Analyze the attached fairytale storybook image and generate the following asset matching the exact same warm wood carving, rounded cobblestone textures, soft pastel colored outlines, and magical fairytale lighting."*

---

### Giai đoạn 3: Conversion (Hậu Kỳ, Tách Nền, PBR & Đóng Gói)

#### 3.1. Sub-pixel Alpha Matting & Defringing (Tách Nền & Khử Viền)
* **Tách nền thông minh**: Sử dụng mô hình `BiRefNet` hoặc `rembg (birefnet-general)` để tách biên mượt mà các chi tiết như tai thỏ, nốt nhạc, hoa văn gỗ.
* **Khử viền mờ (Defringe & Color Bleed)**: Thực hiện giãn màu pixel biên (Edge Dilation) $2\text{px}$ ra vùng trong suốt để loại bỏ hoàn toàn viền trắng hoặc xám khi Godot thực hiện lọc tuyến tính (Linear Filter / Mipmaps).

#### 3.2. Sinh Bản Đồ Bề Mặt & Ánh Sáng Động 2.5D (PBR Maps Cho CanvasItem)
Godot 4.7 hỗ trợ `CanvasItemMaterial` và `Light2D` cực mạnh. Để tạo chiều sâu chân thực khi đom đóm hoặc hào quang quét qua:
1. **Normal Map**: Dùng Laigter hoặc NormalMap-Online sinh bản đồ pháp tuyến cho:
   - Thớ gỗ khoanh tròn của 5 bục gỗ.
   - Khối đá cuội gồ ghề của con đường.
   - Hoa văn chạm khắc Baroque của bảng gỗ tiêu đề và rương báu.
2. **Roughness / Metallic Map (ORM)**:
   - Kênh R: Ambient Occlusion (độ sâu hốc rãnh khoanh gỗ và kẽ đá).
   - Kênh G: Roughness (gỗ sồi sần nhám $\sim 0.7$, vàng kim & sao nhẵn $\sim 0.2$).
   - Kênh B: Metallic (gỗ $= 0.0$, chi tiết mạ vàng rương báu, ổ khóa, sao $= 0.9$).
3. **Emission Mask**: Mặt nạ phát sáng cho:
   - Vòng hào quang vàng quanh bục số 4.
   - Dải nốt nhạc bay ngũ sắc quanh bạn Thỏ.
   - Cụm thạch anh xanh Cyan bên gốc cây trái.
   - Đốm sáng trên rương báu bục số 5.

#### 3.3. Đóng Gói Texture Atlas & Thiết Lập 9-Slice (Patch-9)
* Gom toàn bộ các phần tử giao diện của Màn 05 vào Texture Atlas kích thước $2048 \times 2048\text{ px}$ (Power of Two):
  - Bảng ruy băng gỗ tiêu đề `Chương 1: Sáo Trúc Rừng Xanh`.
  - Nút quay lại bo tròn, hũ sao thủy tinh.
  - 5 bục gỗ khoanh cây và cụm sao vàng 1..3 sao.
  - Các huy hiệu bạn thú (Sư tử, Gấu, Mèo).
* **Hiệu quả**: Giảm Draw Calls của toàn bộ màn hình Level Select xuống chỉ còn **1–2 Draw Calls** duy nhất!

---

### Giai đoạn 4: Asset Management (Quản Lý & Tích Hợp Vào Godot 4.7+)

#### 4.1. Quy Ước Đặt Tên Chuẩn (Godot Asset Naming Convention)
* `spr_` (Sprite / Animated Sprite Sheet): `spr_bunny_maestro_idle.png`, `spr_level_pad_wood.png`, `spr_chest_gold_glow.png`
* `tex_` (Texture / Background / PBR Map): `tex_bg_level_select_forest.png`, `tex_book_cobblestone_stage.png`
* `ui_` (UI Widget / Button / Badge): `ui_banner_chapter_wood.png`, `ui_btn_back_wood.png`, `ui_star_jar_hud.png`
* `sfx_` (Sound Effects - WAV 16-bit 44.1kHz): `sfx_pad_hop.wav`, `sfx_star_ting.wav`, `sfx_chest_magic.wav`
* `bgm_` (Background Music - OGG Loop): `bgm_level_select_waltz.ogg`
* `vfx_` (PackedScene GPUParticles2D): `vfx_golden_ring_aura.tscn`, `vfx_music_notes_trail.tscn`
* `sh_` (Godot Shader File): `sh_level_select_tilt.gdshader`, `sh_golden_aura_ring.gdshader`

#### 4.2. Cấu Hình Import Trong Godot 4.7+
| Loại Asset | Định dạng | Godot Import Preset | Cấu hình kỹ thuật |
|---|---|---|---|
| **UI & Bục Gỗ** | PNG 32-bit | Lossless | `Compress: Lossless`, `Mipmaps: false`, `Filter: Linear` |
| **Hậu Cảnh Toàn Cảnh** | PNG 24-bit / WebP | VRAM Compressed | `Compress: VRAM (ASTC/ETC2)`, `Size: 2048x1152` |
| **Normal / ORM Maps** | PNG 24-bit | Normal Map / Basis Universal | `Roughness: Disabled`, `Normal Map: Enabled` |
| **Âm Thanh Tương Tác** | WAV 16-bit Mono | AudioStreamWAV | `Max Polyphony: 8`, nạp sẵn RAM (Zero Latency) |
| **Nhạc Nền BGM** | OGG Vorbis 160kbps | AudioStreamOggVorbis | `Loop: true`, stream từ đĩa |

#### 4.3. Kiến Trúc Cây Node & Phân Lớp Z-Index 2.5D Diorama
Cấu trúc Scene Tree của `LevelSelect` được thiết kế theo đúng mô hình Layer Cake và Signal Architecture của `godot-master`:

```
LevelSelect (CanvasLayer - Layer 11: Level Select Overlay)
├── BackdropDimmer (ColorRect - Lớp phủ làm dịu nền màn chơi chính)
├── DioramaStage (Control - Khung phối cảnh 2.5D)
│   ├── ParallaxForest (Control - Tầng Hậu Cảnh)
│   │   ├── DeepBambooForest (TextureRect - Rừng trúc ngọc bích sương mờ & vệt nắng)
│   │   ├── CottageLeft (TextureRect - Ngôi nhà nấm ngói đỏ & gốc cây thạch anh)
│   │   ├── CottageRight (TextureRect - Ngôi nhà cổ tích ngói xanh & rương phụ)
│   │   └── AmbientFireflies (GPUParticles2D - Đom đóm lơ lửng)
│   ├── OpenBookStage (Control - Tầng Sân Khấu Sách & Đường Đá)
│   │   ├── BookSpreadBase (TextureRect - Trang sách da kem mở đôi & mép da)
│   │   ├── CobblestonePath (TextureRect - Con đường đá cuội phủ rêu uốn lượn)
│   │   └── CompanionBadges (Control - Các mốc huy hiệu bạn thú ven đường)
│   │       ├── BadgeLion (TextureRect - Sư tử con cắm cọc bên bục 1-2)
│   │       ├── BadgeBear (TextureRect - Gấu con cắm cọc bên bục 2-3)
│   │       ├── BadgeCat (TextureRect - Mèo con cắm cọc bên bục 3-4)
│   │       └── ForegroundShrubBadges (TextureRect - 2 huy hiệu nhỏ nép lùm cây trước)
│   ├── LevelPadsContainer (Control - Tầng 5 Bục Gỗ Tương Tác)
│   │   ├── Pad1 (LevelPadButton: Bài 1 - Hoàn thành 3 sao)
│   │   ├── Pad2 (LevelPadButton: Bài 2 - Hoàn thành 3 sao)
│   │   ├── Pad3 (LevelPadButton: Bài 3 - Hoàn thành 3 sao)
│   │   ├── Pad4 (LevelPadButton: Bài 4 - Đang chơi / Bạn Thỏ / Hào quang vàng)
│   │   │   ├── GoldenAuraRing (Control với sh_golden_aura_ring.gdshader)
│   │   │   ├── BunnyMascot (TextureRect / AnimatedSprite2D - Bạn Thỏ vẫy tay)
│   │   │   └── MusicalNotesTrail (GPUParticles2D - Dải nốt nhạc ngũ sắc)
│   │   └── Pad5 (LevelPadButton: Bài 5 - Đích đến / Rương báu thần)
│   │       ├── TreasureChest (TextureRect - Rương mạ vàng)
│   │       └── ChestSparkles (GPUParticles2D - Bụi sao lấp lánh)
│   └── ForegroundFoliage (TextureRect - Bụi rậm và hoa rừng viền trước)
└── HUDOverlay (Control - Tầng Giao Diện Điều Hướng)
    ├── TopWoodBanner (TextureRect - 'Chương 1: Sáo Trúc Rừng Xanh')
    │   └── DynamicTitleLabel (Label - Font Baloo 2 mạ vàng khi đổi chương)
    ├── BtnBack (TextureButton - Nút gỗ tròn bo góc trái 'Quay lại')
    └── StarJarWidget (Control - Lọ sao thủy tinh tích lũy góc phải)
        ├── JarGlass (TextureRect)
        └── StarNumberLabel (Label - Số sao vàng)
```

---

## PHẦN II: BREAKDOWN CHI TIẾT DANH MỤC ASSET LIST & MASTER AI PROMPTS

---

### MỤC 1: 2.5D ASSETS (SPRITES, TEXTURES, BACKGROUNDS, PROPS & ILLUSTRATIONS)

#### 1.1. Sprites & Sprite Sheets (Bục Gỗ, Linh Vật & Đạo Cụ Động)
| Mã Asset | Kích thước xuất | Định dạng / Số Frame | Công dụng trong Godot |
|---|---|---|---|
| `spr_level_pad_tree_slice` | $512 \times 384\text{ px}$ | Sheet $5 \times 1$ (5 biến thể) | 5 bục gỗ khoanh cây với vân gỗ tự nhiên và số 3D nổi (1..5) |
| `spr_bunny_maestro_anim` | $512 \times 512\text{ px}$ | Sheet $4 \times 2$ (8 frames) | Bạn Thỏ trắng nhún nhảy vẫy tay ở bục số 4 (Idle & Cheer) |
| `spr_treasure_chest_gold` | $384 \times 384\text{ px}$ | PNG 32-bit (Single) | Chiếc rương báu mạ vàng Baroque trên bục số 5 |
| `spr_crystal_cyan_stump` | $320 \times 384\text{ px}$ | PNG 32-bit (Single) | Gốc cây mục và cụm thạch anh xanh Cyan phát sáng góc trái |
| `spr_magic_musical_notes` | $512 \times 256\text{ px}$ | Sheet $4 \times 2$ (8 notes) | Các nốt nhạc ngũ sắc (khóa son, nốt móc đôi) bay quanh Thỏ |
| `spr_companion_badges_set`| $768 \times 256\text{ px}$ | Sheet $3 \times 1$ (3 badges) | Bộ 3 huy hiệu bạn thú (Sư tử, Gấu, Mèo con) cắm cọc đường |

* **Prompt AI 01 — Bộ 5 Bục Gỗ Khoanh Cây Âm Nhạc (Grid Batch Generation)**:
  > **Prompt**: `Sprite sheet of five chunky whimsical wooden tree log slice pedestals for a preschool music game, arranged horizontally in a row on a clean pure white background: Each pedestal is crafted from a thick cross-cut rustic dark oak tree stump with visible concentric growth rings and bark texture. Each log has an embossed bold rounded 3D number carved on top from 1 to 5 in warm cream parchment tone #FBE3B5 with soft golden highlights. Cute tactile wooden toy diorama aesthetic, soft dark brown outlines (never harsh black), warm overhead golden-hour lighting, soft contact shadows below each log. Studio product cutout, 2.5d diorama perspective, isolated on white --ar 16:5 --style raw`  
  > **Negative**: `text, letters, words, watermark, photo, scary, sharp, mechanical, 3d wireframe, low-res, cropped, distorted borders`

* **Prompt AI 02 — Bạn Thỏ Trắng Nhạc Trưởng Vẫy Tay Nhún Nhảy (`spr_bunny_maestro_anim`)**:
  > **Prompt**: `Animation sprite sheet of an adorable chubby white bunny rabbit maestro waving happily, 8 sequential frames for a 2D preschool music game. The cheerful bunny stands on its hind legs with cute rounded body, pink inner ears, big shiny friendly eyes, rosy pink cheeks, waving its paw joyfully in a gentle looping rhythm. Whimsical children's picture-book illustration, soft warm outlines, soft cel shading, warm lighting. Isolated on clean solid white background, centered, full body visible --ar 16:9 --style raw`

* **Prompt AI 03 — Rương Báu Thần Mạ Vàng Trên Bục 5 (`spr_treasure_chest_gold`)**:
  > **Prompt**: `A charming whimsical fairytale treasure chest with gilded gold trims and polished dark oak wood for a preschool game. The chest has a rounded dome lid with ornate Baroque golden filigree brackets, a brass keyhole, warm golden starlight sparkles radiating outwards. Chunky tactile wooden toy aesthetic, friendly rounded corners, cozy magical atmosphere, isolated on pure white background, studio cutout --ar 1:1 --style raw`

* **Prompt AI 04 — Dải Nốt Nhạc Ma Thuật Ngũ Sắc Bay Lượn (`spr_magic_musical_notes`)**:
  > **Prompt**: `A whimsical swirling stream of magical floating cartoon musical notes and treble clefs for a children's storybook music game. Vibrantly colored in gentle pastel magenta pink #ED7A8E, luminous turquoise cyan #4AE5D8, and glowing golden yellow #FFE678 with tiny twinkling starlight sparkles around them. Soft rounded shapes, luminous inner glow, cozy fairytale feel, isolated on solid white background --ar 2:1 --style raw`

---

#### 1.2. Textures & PBR Maps (Bề Mặt & Chiều Sâu Vật Liệu)
| Mã Asset | Kích thước | Kênh Texture | Mô tả kỹ thuật |
|---|---|---|---|
| `tex_book_cobblestone_stage` | $2048 \times 1152$ | RGB Albedo | Trang sách mở đôi với con đường đá cuội rêu xanh uốn lượn |
| `tex_cobblestone_normal` | $1024 \times 1024$ | 16-bit Normal Map | Bản đồ pháp tuyến tạo độ gồ ghề cho các viên đá cuội |
| `tex_wood_pedestal_orm` | $1024 \times 1024$ | ORM Packed | Kênh R=AO, G=Roughness, B=Metallic cho bục gỗ khoanh cây |
| `tex_aura_emission_mask` | $512 \times 512$ | 8-bit Grayscale Mask | Mặt nạ phát sáng cho vòng hào quang xoay quanh bục số 4 |

* **Prompt AI 05 — Trang Sách Mở Đôi Với Con Đường Đá Cuội Uốn Lượn**:
  > **Prompt**: `Top-down oblique diorama view of an ancient fairytale pop-up book open wide on a mossy clearing. The open parchment pages form a vibrant green meadow with a winding cobblestone pebble pathway curling gently from left to right, bordered by tiny wildflowers, colorful mushrooms, and lush clover patches. The thick leather book binding is visible along the outer edges with warm gilded flourishes. Soft 3D page curl, cozy ambient fairytale lighting, no characters, no text, clean white background margin --ar 16:9 --style raw`

---

#### 1.3. Backgrounds & Parallax Layers (Phông Nền Đa Tầng Rừng Thần Tiên)
| Mã File | Kích thước | Độ trễ Parallax (`scroll_scale`) | Vai trò không gian |
|---|---|---|---|
| `bg_deep_bamboo_canopy` | $2560 \times 1440$ | $(0.04, 0.04)$ | Tán rừng trúc sương mờ ngọc bích, vệt nắng nghiêng xuyên lá |
| `bg_fairytale_cottage_wings` | $2560 \times 1440$ | $(0.10, 0.10)$ | Hai ngôi nhà cổ tích ngói hồng và xanh lam nép bên hai thân cây cổ thụ |
| `bg_book_foreground_stage` | $2560 \times 1000$ | $(1.00, 1.00)$ | Cuốn sách mở và đường đá cuội tương tác chính |

* **Prompt AI 06 — Hậu Cảnh Rừng Trúc Sương Mờ & 2 Ngôi Nhà Cổ Tích**:
  > **Prompt**: `Enchanted fairytale woodland clearing at peaceful golden hour, children's storybook background. In the center far distance, ethereal misty green bamboo groves with soft turquoise god rays beaming down from the canopy. Flanking the left is a whimsical mushroom cottage with a cozy pink-red tiled roof and glowing round honey-yellow windows; flanking the right is a rustic woodland cottage with slate-blue roof shingles. Majestic curving ancient tree trunks frame both sides like theater curtains. Cozy, gentle, magical atmosphere for young children, panoramic landscape view, zero characters, zero text --ar 16:9 --style raw`

---

#### 1.4. Concept Art & Illustrations (Bộ Huy Hiệu Bạn Thú Đồng Hành)
| Huy Hiệu | Linh Vật | Vị Trí Cắm Dọc Đường | Biểu Tượng |
|:---:|---|---|---|
| **01** | Sư Tử Con (`Lion Cub`) | Ven đường giữa Bục 1 & 2 | Bờm hoa mai tròn, mặt cười rạng rỡ |
| **02** | Gấu Con (`Bear Cub`) | Ven đường giữa Bục 2 & 3 | Tai tròn nâu, mặt hiền lành ấm áp |
| **03** | Mèo Con (`Kitten`) | Ven đường giữa Bục 3 & 4 | Tai nhọn cam, râu mèo dễ thương |

* **Prompt AI 07 — Bộ 3 Huy Hiệu Gỗ Bạn Thú Đồng Hành (`spr_companion_badges_set`)**:
  > **Prompt**: `Set of three circular tactile wooden companion badges mounted on short rustic wooden path signposts, for a preschool fairytale music game: 1. Cute smiling baby lion cub with a sunny round petal mane; 2. Friendly cozy baby bear cub with round ears; 3. Adorable ginger kitten with cheerful whiskers. Each badge is set inside a chunky carved dark oak wooden round frame with friendly beveled borders. Whimsical children's book illustration style, warm overhead lighting, isolated on solid pure white background, sheet of three --ar 3:1 --style raw`

---

### MỤC 2: UI / UX ASSETS (HUD, BỤC GỖ, SAO & STYLE GUIDE)

#### 2.1. HUD & Navigation Elements
| Mã Asset | Kích thước xuất | Trạng thái | Mô tả chi tiết trong Godot |
|---|---|---|---|
| `ui_banner_chapter_wood` | $1024 \times 240\text{ px}$ | Normal | Bảng gỗ sồi chạm khắc Baroque tiêu đề 'Chương 1: Sáo Trúc Rừng Xanh' |
| `ui_banner_chapter_wood_blank` | $1024 \times 240\text{ px}$ | 9-Slice Patch | Phôi bảng gỗ trống để chèn text động cho Chương 2, 3 |
| `ui_btn_back_wood_pill` | $260 \times 110\text{ px}$ | Normal / Pressed | Nút gỗ hình viên thuốc bo tròn mềm mại mang chữ 'Quay lại' và mũi tên cong |
| `ui_hud_star_jar` | $200 \times 240\text{ px}$ | Normal / Glow | Chiếc lọ thủy tinh nắp bần đựng ngôi sao vàng phát sáng tích lũy |
| `ui_stars_3_cluster` | $240 \times 120\text{ px}$ | Complete | Cụm 3 ngôi sao vàng dập nổi lơ lửng trên các bục đã vượt qua |

* **Prompt AI 08 — Bảng Gỗ Chạm Khắc Tiêu Đề Chương (`ui_banner_chapter_wood`)**:
  > **Prompt**: `An ornate carved dark oak wooden sign plaque with gilded Baroque scroll flourishes at the corners, embossed with the whimsical Vietnamese title 'Chương 1: Sáo Trúc Rừng Xanh' in bold cheerful warm cream serif lettering with golden bevels. The plaque is crafted from rich polished walnut wood with gentle wood grain relief, brass accent rivets, tactile preschool storybook title sign, isolated on pure white background, studio cutout --ar 4:1 --style raw`

* **Prompt AI 09 — Nút Gỗ 'Quay Lại' Viên Thuốc Bo Tròn (`ui_btn_back_wood_pill`)**:
  > **Prompt**: `A chunky rounded pill-shaped wooden button for a children's game UI, crafted from warm polished dark oak with beveled golden edges. On the button is a bold embossed cream-colored curved back arrow pointing left alongside the friendly title 'Quay lại' in rounded font. Tactile physical toy appearance, warm ambient lighting, isolated on solid white background --ar 2:1 --style raw`

* **Prompt AI 10 — Hũ Thủy Tinh Đựng Sao Vàng Góc Phải Trên (`ui_hud_star_jar`)**:
  > **Prompt**: `A charming fairytale glass mason jar with a rustic cork lid and tied twine, filled with a large glowing warm golden star inside. The glass jar has soft rounded reflections and radiates a gentle magical amber starlight aura. Tactile storybook UI icon, cozy and cheerful for toddlers, isolated on pure white background --ar 1:1 --style raw`

#### 2.2. Typography & Style Guide Chuẩn Mầm Non
* **Tiêu đề Bảng Gỗ (Chapter Title)**:
  - Phông chữ: **Baloo 2** (Extra-Bold 800) hoặc **Fredoka**.
  - Màu sắc: Kem vàng ngà `#FFF2A8` viền nét nâu sồi `#4E2A14` dày $3\text{px}$, đổ bóng $4\text{px}$.
* **Số Bục Gỗ (Level Numbers 1..5)**:
  - Phông chữ: **Fredoka** (Bold 700) với phong cách số nổi 3D dập chìm trên thớ gỗ.
  - Màu sắc: Trắng ngà `#FFFDF7` viền nâu gỗ hổ phách `#6C3C24`.
* **Quy chuẩn vùng chạm an toàn (Touch Target Standards)**:
  - Cả 5 bục gỗ có kích thước tương tác $\ge 120 \times 120\text{ pt}$.
  - Nút Quay lại đạt kích thước $\ge 180 \times 88\text{ pt}$, đảm bảo trẻ không bao giờ bấm trượt hay vô tình thoát game.

---

### MỤC 3: AUDIO ASSETS (SFX, MUSIC & VOICE LINES)

Tất cả hiệu ứng âm thanh (SFX) được nén định dạng **WAV 16-bit 44.1kHz Mono** nạp trực tiếp vào RAM (Zero Latency), nhạc nền định dạng **OGG Vorbis 160kbps Stereo** lặp vô tận.

#### 3.1. Nhạc Nền Màn Chọn Màn (BGM)
| Tên File | Thời lượng / BPM | Nhạc cụ & Cảm xúc | Chế độ lặp |
|---|---|---|:---:|
| `bgm_level_select_waltz.ogg` | 1:20 (84 BPM) | Điệu valse đồng quê êm ái kết hợp Sáo Trúc mộc mạc, Hộp Nhạc (Music Box), Đàn Kalimba, Guitar mộc rải ngón và bộ gõ gỗ nhẹ nhàng. Rộn rã, mời gọi, ấm cúng. | **Loop = true** |

* **Prompt AI Sinh Nhạc Nền (Suno AI / Udio / MusicFX)**:
  > **Prompt**: `Charming children's fairytale waltz at 84 bpm, loopable video game level select soundtrack. Cheerful melody played on wooden bamboo flute and delicate music box celesta, accompanied by gentle acoustic guitar fingerpicking, cozy kalimba, and soft pizzicato strings. Sunny morning woodland atmosphere, playful, comforting for 3-year-old toddlers, high studio production quality, zero brass, zero heavy bass, seamless loop`

---

#### 3.2. Hiệu Ứng Âm Thanh Tương Tác (SFX)
| Tên File SFX | Thể loại tương tác | Mô tả đặc tính âm thanh chi tiết |
|---|---|---|
| `sfx_pad_hop.wav` | Chạm vào bục màn chơi | Tiếng "Tung!" nảy nhẹ của khối gỗ có đệm mút cao su, âm sắc mộc mạc ấm áp ($< 90\text{ms}$). |
| `sfx_bunny_cheer.wav` | Chạm bục số 4 (Thỏ) | Tiếng Thỏ nhảy phóc lên kèm chuông sao leng keng vui nhộn ($< 250\text{ms}$). |
| `sfx_star_pop.wav` | Nhấp nháy sao vàng | Tiếng nảy hạt sao thủy tinh lách cách trong trẻo như giọt sương mai ($< 120\text{ms}$). |
| `sfx_chest_magic.wav` | Chạm bục số 5 (Rương) | Tiếng rung rinh hợp âm chuông vàng ngân vang báo hiệu phần thưởng quý giá ($< 400\text{ms}$). |
| `sfx_btn_wood_tap.wav` | Chạm nút 'Quay lại' | Tiếng gõ gõ mộc mạc của khối gỗ sồi già ($< 80\text{ms}$). |
| `sfx_flute_riff_short.wav` | Vào màn chọn màn | Giai điệu sáo trúc 3 nốt ngũ cung réo rắt vui tươi chào mừng bé trở lại. |

* **Prompt AI Sinh Hiệu Ứng Âm Thanh (ElevenLabs SFX / AudioCraft)**:
  > **Pad Hop**: `Chunky toy wooden block tap with a gentle playful bounce, warm acoustic pop, tactile game UI button sound`  
  > **Bunny Cheer**: `Cute whimsical cartoon hop sound with a tiny magical starlight glissando, joyful preschool cue`  
  > **Chest Magic**: `Magical golden treasure shimmer, soft warm chime glissando with sparkling fairy dust, cozy and rewarding`  
  > **Wood Tap**: `Mellow oak wood block knock, clean organic tactile click, preschool UI tap`

---

#### 3.3. Giọng Nói & Biểu Cảm Không Lời (Preschool Non-Verbal Vocal Cues)
* `vox_bunny_giggle.wav`: Tiếng cười khúc khích hồn nhiên "Hehehe!" của bé Thỏ khi được xoa đầu hoặc chọn bài.
* `vox_bunny_yoohoo.wav`: Tiếng gọi reo vui "Yoo-hoo!" mời bé bước vào bài hát mới.
* `vox_bunny_tada.wav`: Tiếng "Ta-da!" ngân nga rạng rỡ khi bé hoàn thành 5 bài mở được Rương Báu.

---

### MỤC 4: VFX & SHADERS (HẠT MA THUẬT & SHADER 2.5D)

#### 4.1. Hệ Thống Hạt (GPUParticles2D)
1. **`vfx_golden_ring_aura.tscn` (Vòng hào quang vàng bục số 4)**:
   - 30 hạt ánh sáng vàng kim xoay tròn theo quỹ đạo elip dẹt bao quanh chân bục số 4, tạo cảm giác một vùng đất âm nhạc đang thức giấc.
2. **`vfx_musical_notes_trail.tscn` (Dải nốt nhạc bay quanh Thỏ)**:
   - 16 hạt mang texture nốt nhạc ngũ sắc (hồng, cyan, vàng) bay lượn uốn lượn hình sin từ tay Thỏ vút lên không trung rồi tan biến dịu dàng.
3. **`vfx_ambient_fireflies.tscn` (Đom đóm rừng xanh)**:
   - 20 hạt đom đóm màu vàng chanh lơ lửng ngẫu nhiên khắp sân khấu với vận tốc nhẹ $10–20\text{ px/s}$.
4. **`vfx_chest_sparkle.tscn` (Bụi sao rương báu)**:
   - 15 hạt sao 4 cánh nhấp nháy phát sáng quanh rương báu ở bục số 5.

---

#### 4.2. Shader Vòng Hào Quang Vàng Xoay Động (`sh_golden_aura_ring.gdshader`)
Shader vẽ và làm chuyển động vòng tròn năng lượng vàng ma thuật dưới chân bục 4 mà không tốn draw call:

```glsl
shader_type canvas_item;

// Vòng hào quang vàng xoay động dưới chân bục đang chơi
uniform vec4 aura_color : source_color = vec4(1.0, 0.85, 0.32, 0.95);
uniform vec4 inner_color : source_color = vec4(1.0, 0.95, 0.65, 0.60);
uniform float ring_radius : hint_range(0.2, 0.5) = 0.42;
uniform float ring_thickness : hint_range(0.02, 0.15) = 0.06;
uniform float pulse_speed : hint_range(0.5, 5.0) = 2.4;
uniform float rotation_speed : hint_range(-3.0, 3.0) = 1.2;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	// Ép tỷ lệ elip 2.5D (nhìn xiên từ trên xuống)
	uv.y *= 1.55;
	float dist = length(uv);
	
	// Góc quay
	float angle = atan(uv.y, uv.x) + TIME * rotation_speed;
	
	// Hiệu ứng nhịp thở phập phồng
	float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);
	float cur_radius = ring_radius + pulse * 0.025;
	
	// Tạo độ dày và viền mờ cho vòng tròn
	float ring = smoothstep(cur_radius - ring_thickness, cur_radius, dist) 
	           - smoothstep(cur_radius, cur_radius + ring_thickness, dist);
	
	// Độ gợn sóng ánh sáng xoay quanh vòng
	float shimmer = 0.75 + 0.25 * sin(angle * 4.0);
	
	vec4 final_color = mix(aura_color, inner_color, pulse) * ring * shimmer;
	final_color.a *= (0.7 + 0.3 * pulse);
	
	COLOR = final_color;
}
```

---

#### 4.3. Shader Phối Cảnh Nghiêng 2.5D & Vệt Sáng Vàng Kim (`sh_level_select_tilt.gdshader`)
Shader áp dụng cho toàn bộ sân khấu sách hoặc từng bục gỗ để tạo cảm giác 3D nhún nhảy khi ngón tay bé chạm vào:

```glsl
shader_type canvas_item;

uniform vec2 tilt_offset = vec2(0.0, 0.0); // Tọa độ tương tác (-1.0 đến 1.0)
uniform float tilt_amount : hint_range(0.0, 0.1) = 0.035;
uniform vec4 gold_sheen_color : source_color = vec4(1.0, 0.92, 0.55, 0.75);
uniform float sheen_speed : hint_range(0.2, 3.0) = 1.0;
uniform bool is_active = true;

void vertex() {
	// Biến dạng đỉnh tạo cảm giác chiều sâu 3D diorama
	VERTEX.x += (UV.y - 0.5) * tilt_offset.x * tilt_amount * 100.0;
	VERTEX.y += (UV.x - 0.5) * tilt_offset.y * tilt_amount * 100.0;
}

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	if (is_active && col.a > 0.1) {
		// Vệt sáng vàng quét nghiêng
		float sweep = sin(UV.x * 3.0 - UV.y * 2.0 + TIME * sheen_speed);
		float sheen = smoothstep(0.7, 0.98, sweep);
		col.rgb += gold_sheen_color.rgb * sheen * 0.45;
	}
	COLOR = col;
}
```
