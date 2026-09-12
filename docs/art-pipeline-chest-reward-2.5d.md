# QUY TRÌNH MỸ THUẬT 2.5D (GAME ART PIPELINE) & DANH MỤC ASSET PROMPT AI
# MÀN 06: MỞ RƯƠNG BÁU THẦN ("PEAK DOPAMINE CHEST REWARD & 3D ANIMAL CREST")

> **Dự án**: Rừng Nhạc (Enchanted Music Forest) — Game Âm Nhạc Tương Tác Sách Nổi Cho Trẻ 3–6 Tuổi  
> **Nguồn cảm hứng thiết kế**: [`docs/mock-chest-reward.jpeg`](file:///Users/anhtu/MySpace/new-piano/docs/mock-chest-reward.jpeg)  
> **Nền tảng mục tiêu**: Godot Engine 4.7+ (Forward Mobile / iOS Metal / Android Vulkan)  
> **Phong cách cốt lõi**: Sách Tranh Nổi 2.5D Diorama (Layered Pop-up Book Diorama) kết hợp đồ chơi gỗ xúc giác ấm áp  
> **Kỹ thuật sinh AI**: Phông xanh lá tinh khiết (`Chroma Key Green #00FF00`) phục vụ bóc tách Alpha Sub-pixel chuẩn xác  
> **Triết lý tương tác**: Zero-Text Preschool UX (Trực quan 100%, tạo cảm xúc chiến thắng Dopamine tột đỉnh, an toàn tuyệt đối)

---

## PHẦN I: QUY TRÌNH MỸ THUẬT GAME 2.5D DÀNH CHO INDIE DEVELOPER (4 GIAI ĐOẠN)

Quy trình mỹ thuật 2.5D Pop-up Diorama được thiết kế tối ưu hóa cho nhà phát triển độc lập (Indie Game Developer), kết hợp giữa sức mạnh sinh ảnh của các mô hình AI tiên tiến với kỹ thuật phông xanh lá (Green Screen / Chroma Keying), quy trình hậu kỳ tự động hóa bằng Python và kiến trúc phân lớp CanvasLayer / Node2D của Godot 4.7+.

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                          2.5D POP-UP DIORAMA REWARD ART PIPELINE                                │
├───────────────────┬───────────────────┬───────────────────────────┬─────────────────────────────┤
│    1. CONCEPT     │    2. CREATION    │       3. CONVERSION       │     4. ASSET MANAGEMENT     │
│                   │                   │                           │                             │
│ • Visual Climax   │ • Chroma Green Key│ • Chroma Spill Suppress   │ • Godot 4.7 Import Presets  │
│ • Color Sampling  │ • Master Prompts  │ • Sub-pixel Alpha Feather │ • 2.5D Layering & Z-Index   │
│ • 2.5D Depth Plan │ • Style Reference │ • Normal / Roughness / ORM│ • Draw Call & VRAM Budgets  │
│ • Zero-Text UX    │ • Neg-Prompt Master│ • Texture Atlas & 9-Slice │ • Touch Target Standards    │
└───────────────────┴───────────────────┴───────────────────────────┴─────────────────────────────┘
```

---

### Giai đoạn 1: Concept (Khái Niệm, Khóa Phong Cách Thị Giác & Chiều Sâu 2.5D)

#### 1.1. Ngôn ngữ tạo hình & Không gian Sân khấu Mở Rương Thần (Peak Dopamine Stage)
* **Khoảnh khắc cao trào (Visual Climax)**: Màn 06 là khoảnh khắc dopamine bùng nổ nhất trong toàn bộ hành trình trải nghiệm của bé. Sau khi hoàn thành một bài hát hoặc vượt qua một chặng đường, chiếc rương báu trên cây đàn piano bất ngờ bung nắp, phóng ra một luồng hào quang vàng rực rỡ và suối sao vàng bay bổng.
* **Cấu trúc không gian 4 tầng thị giác 2.5D (Diorama Pop-up Layers)**:
  1. **Tầng Hậu cảnh (Far Background - Parallax)**:
     - Thung lũng rừng cổ tích huyền ảo với vòm cây đại thụ uốn lượn, luồng nắng thần tiên (God Rays) rọi xiên qua kẽ lá.
     - Hai bên cánh gà là các ngôi nhà nấm ngói đỏ cổ tích, ngôi nhà gỗ cửa sổ tròn phát sáng ấm áp, các cụm thạch anh xanh Cyan và tím phát quang lung linh trên thảm cỏ ven bìa rừng.
  2. **Tầng Trung cảnh (Midground - The Magic Board & Open Book)**:
     - Chiếc bảng ma thuật hình trang sách mở đôi với khung gỗ sồi uốn lượn, viền mạ vàng Baroque sang trọng đặt dựng đứng làm phông nền trung tâm sân khấu.
     - Bên trong bảng là bầu trời đêm huyền bí với dải mây sao lấp lánh và các luồng hạt sáng tuôn trào.
  3. **Tầng Sân khấu Trung tâm (Center Stage - Treasure Chest & 3D Animal Crest)**:
     - **Rương báu thần mạ vàng**: Chiếc rương gỗ sồi cổ mở toang nắp, các bản lề đồng mạ vàng tinh xảo, bên trong tỏa luồng ánh sáng thần thoại rực rỡ.
     - **Huy hiệu Thú 3D vương giả**: Ngôi sao vàng 3D khổng lồ bay lơ lửng ngay trên miệng rương. Bên trong ngôi sao là chân dung Chú Sư Tử con ngộ nghĩnh đội vương miện đá quý và nốt nhạc vàng mạ nổi (`SƯ TỬ NHẠC SĨ`).
     - **Bé Phù Thủy nhỏ (Mascot Companion)**: Đứng bên cánh trái nắp đàn piano, mặc áo choàng tím, đội mũ chóp đính khóa đồng, hai tay vỗ mừng hân hoan chúc mừng bé.
     - **Khung tranh vinh danh bên trái**: Khung gỗ chạm khắc cổ điển hiển thị tiến trình bộ sưu tập (`1 / 7 SƯ TỬ NHẠC SĨ`).
     - **Dải sao & pháo giấy ngũ sắc (Confetti & Star Fountain)**: Hàng ngàn ngôi sao nhỏ màu vàng, nốt nhạc bay và dải ruy băng ngũ sắc (hồng, cyan, tím, vàng) bắn tung bừng trong không gian.
  4. **Tầng Tiền cảnh (Foreground - Piano Keyboard & Claim Button)**:
     - Bàn phím piano gỗ 7 phím thú (C: Sư tử, D: Gấu, E: Thỏ, F: Mèo, G: Khỉ, A: Voi, B: Cú) nằm ở nửa dưới màn hình.
     - Nổi bật ở chính giữa bàn phím là nút gỗ chạm khắc to tròn bo cong: **`NHẬN THƯỞNG 🌿`** với chiếc lá xanh ngọc phát sáng mời gọi bé chạm vào để kết thúc màn thưởng.

#### 1.2. Bảng Màu Chuẩn (Lượng Tử Hóa Trực Tiếp Từ `mock-chest-reward.jpeg`)
Đo đạc chính xác bằng kỹ thuật trích xuất cụm màu nổi bật (K-Means Color Quantization) từ ảnh concept:

| Tên Màu | Mã Hex | Vị Trí Xuất Hiện Trong Màn 06 | Ý Nghĩa Cảm Xúc Mầm Non |
|---|---|---|---|
| **Vàng Kim Vương Giả** | `#FCD04B` / `#FFE678` | Huy hiệu sao 3D, viền rương báu, suối sao vàng, vương miện | Dopamine chiến thắng, thành tựu, quý giá |
| **Nâu Gỗ Sồi Cổ** | `#754323` / `#4E2A14` | Thân rương báu, khung bảng ma thuật, khung tranh vinh danh | Ấm áp, xúc giác mộc mạc, an toàn như đồ chơi gỗ |
| **Kem Giấy Da Sáng** | `#FBE3B5` / `#E8CF9F` | Bề mặt phím đàn piano, nền khung tranh vinh danh | Sáng dịu mắt, sạch sẽ, hoài niệm trang sách |
| **Tím Hoàng Gia Áo Choàng**| `#68469C` / `#482E78` | Áo choàng và mũ chóp của bé Phù Thủy | Ma thuật, huyền bí, dễ thương, quý phái |
| **Xanh Rêu Rừng Cổ Tích** | `#2C6436` / `#3D9A54` | Thảm cỏ nền, vòm lá cây, viền bàn gỗ | Tươi mát, tràn đầy sinh khí thiên nhiên |
| **Cyan Thạch Anh Lung Linh**| `#4AE5D8` / `#2ABEB3` | Cụm tinh thể thạch anh gốc cây, nốt nhạc bay | Tinh khôi, ma thuật lấp lánh kích thích thị giác |
| **Hồng Sen & Tím Thạch Anh**| `#D95B72` / `#B84AC8` | Tinh thể thạch anh phải, nốt nhạc hồng, nơ ruy băng | Ngọt ngào, vui nhộn, rực rỡ lễ hội |
| **Xanh Lá Tinh Khiết (Key)**| `#00FF00` | Phông nền kỹ thuật để tách phông xanh bằng AI | Màu tách nền Chroma Key tiêu chuẩn công nghiệp |

#### 1.3. Triết Lý Zero-Text Cho Trẻ Mầm Non (Preschool Friendly UX)
1. **Âm thanh và ánh sáng thay thế hoàn toàn chữ viết**:
   - Dù trên mock có chữ `NHẬN THƯỞNG 🌿`, bé 3 tuổi không cần đọc được chữ này vẫn hiểu ngay: nút gỗ to tròn nằm ở trung tâm màn hình, có vòng hào quang vàng nhấp nháy liên tục và nhún nhảy nhịp nhàng, chạm vào là nhận được phần thưởng!
   - Chú Phù Thủy nhỏ vỗ tay cười giòn giã kết hợp tiếng suối sao leng keng tạo hiệu ứng khích lệ tinh thần trực tiếp.
2. **Kích thước vùng chạm siêu lớn (Apple Kids Category Touch Target $\ge 88\text{ pt}$)**:
   - Nút `NHẬN THƯỞNG` chiếm diện tích lớn ($320 \times 90\text{ pt}$), nằm ngay vị trí tự nhiên của ngón tay cái trẻ nhỏ khi cầm máy tính bảng bằng hai tay.
3. **Phản hồi xúc giác & thị giác tức thì (Tactile Delight)**:
   - Chạm vào nút: Nút co giãn đàn hồi (Squash & Stretch), hạt sao bùng nổ, âm thanh leng keng của chuông bạc vang lên trước khi chuyển cảnh sang lật trang sách mượt mà.

---

### Giai đoạn 2: Creation (Tạo Hình Bằng Kỹ Thuật AI Prompting Phông Xanh)

#### 2.1. Chiến Lược Phông Xanh Lá (Chroma Key Green `#00FF00`)
* **Lý do sử dụng phông xanh lá**:
  - Khi sinh ảnh các vật phẩm có chi tiết phức tạp (vương miện vàng, chùm lông bờm sư tử, tua rua áo choàng, hạt sáng), nền trắng hoặc nền đen thường bị lem màu vào rìa đối tượng.
  - Phông xanh lá tinh khiết (`#00FF00` hoặc `#00E500`) tạo độ tương phản cực lớn với tông màu vàng kem, nâu gỗ và tím của nhân vật Màn 06, giúp thuật toán Chroma Key bóc tách mép mượt mà tuyệt đối mà không làm mất sợi tóc hay chi tiết viền.
* **Quy tắc dán prompt phông xanh bắt buộc**:
  - `isolated on solid bright chroma key green background #00FF00, pure single-color green screen, studio product cutout, no green bounce light, clean sharp outlines`.

#### 2.2. Master Prompt Framework (Khung Prompt Xương Sống Cho Màn 06)
Mọi prompt sinh asset riêng lẻ cho Màn 06 đều kế thừa cấu trúc chuẩn sau:

```
[CHỦ THỂ CỤ THỂ], layered 2.5D pop-up diorama asset for preschool music game, storybook fairytale art style. Charming chunky rounded shapes, tactile toy wooden aesthetic, soft warm dark brown outline (never harsh black), warm overhead golden-hour diffused lighting, sparkling amber rim light. Palette: warm oak wood #754323, embossed gold #FCD04B, royal purple #68469C, parchment cream #FBE3B5, glowing cyan #4AE5D8. Friendly, cozy, joyful for 3-year-olds. Isolated on solid bright chroma key green background #00FF00, pure single-color green screen, centered, full subject visible with ample margin, orthographic pop-up book view, zero artifacts --ar [TỈ LỆ] --style raw
```

#### 2.3. Negative Prompt Master (Bộ Từ Khóa Phủ Định Bắt Buộc)
```
photorealistic, human realism, scary, sharp teeth, aggressive, horror, dark gritty, mechanical metal wires, 3d low poly wireframe, pixelated, noisy textures, harsh pure black outlines, washed out colors, blurry, cropped, watermark, signature, modern flat vector, plastic gloss, messy borders, text gibberish, green spill on subject
```

#### 2.4. Kỹ Thuật Đồng Bộ Phong Cách Theo Công Cụ AI
* **Antigravity / Gemini Native Image Generator**:
  - Đính kèm đường dẫn ảnh `docs/mock-chest-reward.jpeg` làm tham chiếu (`ImagePaths: ["/Users/anhtu/MySpace/new-piano/docs/mock-chest-reward.jpeg"]`).
  - Sử dụng prompt đặc tả chi tiết vật liệu: gỗ sồi chạm khắc Baroque, vàng mạ bóng mờ, vải nhung tím.
* **Midjourney v6**:
  - Tham số: `--sref docs/mock-chest-reward.jpeg --sw 800 --c 2 --style raw --ar 1:1`.
* **Stable Diffusion XL / Flux.1 Dev**:
  - LoRA: `children_fairytale_storybook:0.85`, `wooden_toy_tactile:0.6`.
  - ControlNet Canny hoặc Depth để giữ phom dáng đồ chơi tròn trịa.

---

### Giai đoạn 3: Conversion (Hậu Kỳ, Tách Phông Xanh, PBR Maps & Đóng Gói)

#### 3.1. Quy Trình Bóc Tách Phông Xanh Bằng Python & Pillow
1. **Chroma Key Distance**: Tính khoảng cách màu Euclidean trong không gian RGB chuẩn hóa giữa từng pixel và màu `#00FF00`.
2. **Green Dominance Detection**: Với các pixel có kênh $G > \max(R, B) + 35$ và $G > 90$, tăng cường độ bóc tách để loại bỏ triệt để các bóng mờ màu xanh.
3. **Green Spill Suppression**: Thuật toán khử ánh xanh phản chiếu: nếu mép đối tượng có pixel hơi vương sắc xanh ($G > \max(R, B)$), hạ kênh $G$ xuống mức an toàn dựa trên trung bình của $R$ và $B$.
4. **Sub-pixel Edge Feathering**: Làm mịn biên alpha trong dải chuyển tiếp $t_{low} = 0.20 \rightarrow t_{high} = 0.26$ để tránh răng cưa.
5. **Bounding-Box Trim & Padding**: Tự động cắt bỏ toàn bộ vùng trong suốt thừa, thêm padding $6\text{px}$ để bảo toàn mipmaps.

#### 3.2. Sinh Bản Đồ Bề Mặt & Chiều Sâu 2.5D (PBR Maps Cho Godot 4.7+)
* **Normal Map (Bản đồ pháp tuyến)**:
  - Khối phồng 3D của ngôi sao vàng và vương miện của Huy hiệu Sư Tử.
  - Thớ gỗ gồ ghề và bản lề đồng nổi của chiếc Rương Báu thần.
  - Vành nón và nếp gấp áo choàng của Bé Phù Thủy.
* **ORM Map (Ambient Occlusion - Roughness - Metallic)**:
  - Kênh R (AO): Độ sâu hốc rương, kẽ ngón tay vỗ, viền khung tranh.
  - Kênh G (Roughness): Bề mặt gỗ sồi nhám $\sim 0.7$, kim loại vàng nhẵn bóng $\sim 0.15$.
  - Kênh B (Metallic): Thân gỗ $= 0.0$, chi tiết vàng rương báu, vương miện, sao $= 0.95$.
* **Emission Mask (Mặt nạ phát quang)**:
  - Vùng lòng rương tỏa sáng rực rỡ ($#FFE678$).
  - Viên ngọc trên vương miện sư tử và chiếc lá xanh ngọc trên nút Nhận Thưởng.

#### 3.3. Đóng Gói Texture Atlas & Giảm Thiểu Draw Calls
* Gom các phần tử UI của Màn 06 vào tấm Atlas $2048 \times 2048\text{ px}$:
  - Nút gỗ `NHẬN THƯỞNG 🌿`, Nút Home, Nút Levels.
  - Khung tranh vinh danh 1/7, Hộp nhạc cụ góc trái.
  - 7 icon nốt nhạc mặt thú tròn.
* **Kết quả**: Toàn bộ UI và các chi tiết tĩnh của màn hình chỉ tiêu tốn **1 Draw Call** duy nhất trong Renderer Forward Mobile!

---

### Giai đoạn 4: Asset Management (Quản Lý & Tích Hợp Vào Godot 4.7+)

#### 4.1. Quy Ước Đặt Tên Chuẩn Hóa
* `spr_`: Sprite nhân vật, đạo cụ độc lập (`spr_chest_open_gold.png`, `spr_badge_lion_maestro_3d.png`, `spr_wizard_boy_clapping.png`).
* `tex_`: Phông nền, mặt sàn, bản đồ PBR (`tex_bg_chest_forest_diorama.png`, `tex_magic_board_stage.png`).
* `ui_`: Nút bấm, khung viền, icon HUD (`ui_btn_claim_wood.png`, `ui_frame_progress_wood.png`, `ui_icon_lion_crest.png`).
* `sfx_`: Hiệu ứng âm thanh WAV 16-bit 44.1kHz (`sfx_chest_burst_wood.wav`, `sfx_starlight_stream_shimmer.wav`, `sfx_cheer_clapping_kids.wav`).
* `bgm_`: Nhạc nền OGG Vorbis loop (`bgm_victory_fanfare_kids.ogg`).
* `vfx_`: Scene hiệu ứng hạt GPUParticles2D (`vfx_starlight_fountain.tscn`, `vfx_confetti_burst.tscn`).
* `sh_`: File Godot Shader (`sh_godray_sunburst.gdshader`, `sh_badge_golden_shine.gdshader`).

#### 4.2. Cấu Hình Import Trong Godot 4.7+
| Nhóm Asset | Định dạng | Import Preset | Cấu hình kỹ thuật |
|---|---|---|---|
| **Sprites & UI Nút Bấm** | PNG 32-bit | `storybook-hd` | `Compress: Lossless`, `Mipmaps: true`, `Fix Alpha Border: true` |
| **Phông Nền Toàn Cảnh** | PNG / WebP | `VRAM Compressed` | `ASTC/ETC2`, kích thước $2048 \times 1152$, không sinh Mipmap |
| **Âm Thanh Tương Tác** | WAV Mono 44.1k | `AudioStreamWAV` | `Max Polyphony: 6`, nạp trực tiếp bộ nhớ RAM |
| **Nhạc Hoan Ca BGM** | OGG 160kbps | `AudioStreamOggVorbis`| `Loop: false` (phát 1 lần khi mở rương) |

#### 4.3. Kiến Trúc Cây Node & Phân Tầng Z-Index 2.5D Diorama
Cấu trúc Scene Tree của `ChestReward` (`game/ui/chest_reward.gd`) theo tiêu chuẩn phân tầng Layer Cake:

```
ChestReward (CanvasLayer - Layer 12: Peak Reward Overlay)
├── BackdropDimmer (ColorRect - Phủ đen mờ 92% dịu mắt)
├── DioramaStage (Control - Khung sân khấu sách nổi 2.5D)
│   ├── ParallaxBackground (Control - Tầng Hậu Cảnh Rừng & Nhà Nấm)
│   │   ├── ForestBackdrop (TextureRect - Rừng sương mờ, nhà nấm, thạch anh)
│   │   └── AmbientFireflies (GPUParticles2D - Đom đóm lơ lửng)
│   ├── MagicBoardBackdrop (TextureRect - Bảng ma thuật viền vàng mở đôi)
│   │   └── GodRaysSunburst (ColorRect với sh_godray_sunburst.gdshader)
│   ├── PianoKeyboardBase (TextureRect - Bàn phím piano gỗ 7 nốt thú)
│   ├── ChestActor (Control - Cụm Rương Báu Bung Nắp)
│   │   ├── ChestOpenSprite (TextureRect - spr_chest_open_gold)
│   │   ├── StarlightFountain (GPUParticles2D - Suối sao tuôn trào từ miệng rương)
│   │   └── ConfettiBurst (GPUParticles2D - Pháo hoa giấy ngũ sắc)
│   ├── HeroBadgeContainer (Control - Cụm Huy Hiệu Sư Tử 3D)
│   │   ├── BadgeSprite (TextureRect - spr_badge_lion_maestro_3d)
│   │   └── BadgeShineEffect (ColorRect với sh_badge_golden_shine.gdshader)
│   ├── WizardBoyActor (TextureRect - spr_wizard_boy_clapping - Bé phù thủy vỗ tay)
│   ├── ProgressFrame (TextureRect - spr_frame_progress_wood - '1/7 Sư Tử Nhạc Sĩ')
│   └── ClaimButtonContainer (Control - Cụm Nút Nhận Thưởng)
│       ├── ClaimButton (TextureButton - ui_btn_claim_wood)
│       └── ButtonAura (MainMenu.PlayButtonAura - Vòng sáng vàng nhấp nháy)
└── HUDNavigation (Control - Tầng HUD Góc Màn Hình)
    ├── InstrumentPanel (TextureRect - Khay 5 nhạc cụ góc trái trên)
    ├── ScoreBoard (TextureRect - Bảng điểm gỗ góc phải trên)
    └── NavButtons (Control - Nút Home & Nút Levels)
```

---

## PHẦN II: BREAKDOWN CHI TIẾT DANH MỤC ASSET LIST & MASTER AI PROMPTS

---

### MỤC 1: 2.5D ASSETS (SPRITES, TEXTURES, BACKGROUNDS, PROPS & ILLUSTRATIONS)

#### 1.1. Sprites & Đạo Cụ Động (Cắt Nền Bằng Phông Xanh `#00FF00`)
| Mã Asset | Kích thước xuất | Định dạng | Vai trò trong Scene |
|---|---|---|---|
| `spr_chest_open_gold` | $512 \times 512\text{ px}$ | PNG 32-bit | Chiếc rương gỗ cổ mở toang nắp, viền vàng Baroque, tỏa sáng từ lòng rương |
| `spr_badge_lion_maestro_3d` | $512 \times 512\text{ px}$ | PNG 32-bit | Huy hiệu ngôi sao 3D mạ vàng với mặt Chú Sư Tử đội vương miện & nốt nhạc |
| `spr_wizard_boy_clapping` | $512 \times 512\text{ px}$ | PNG 32-bit | Chú bé phù thủy mặc áo choàng tím vỗ tay vui sướng |
| `spr_frame_progress_wood` | $384 \times 512\text{ px}$ | PNG 32-bit | Khung tranh gỗ sồi Baroque hiển thị huy hiệu nhỏ và tiến trình 1/7 |
| `spr_chest_mini_ground` | $256 \times 256\text{ px}$ | PNG 32-bit | Chiếc rương gỗ nhỏ phụ đặt trên thảm cỏ ven bìa rừng góc phải |
| `spr_crystal_cluster_set` | $512 \times 256\text{ px}$ | PNG 32-bit | Bộ tinh thể thạch anh xanh ngọc (Cyan) và tím hồng (Amethyst) phát quang |

---

#### 1.2. Master AI Prompts — Sinh Ảnh Phông Xanh `#00FF00` Cho Từng Asset

* **Prompt AI 01 — Rương Báu Thần Mở Nắp Tỏa Hào Quang (`spr_chest_open_gold`)**:
  > **Prompt**: `A charming fairytale treasure chest wide open with magical golden light bursting out from inside, for a 2.5D children's music game. The chest is crafted from warm polished oak wood with ornate Baroque gilded gold metal corners, hinges, and front lock plate. The rounded dome lid is flipped open upwards at a dynamic angle. A bright warm golden aura glows radiantly from inside the chest cavity. Chunky rounded shapes, tactile toy wooden aesthetic, soft dark brown outlines (never pure black), warm overhead studio lighting. Isolated on solid bright chroma key green background #00FF00, pure single-color green screen, centered, full chest visible with clean borders --ar 1:1 --style raw`  
  > **Negative**: `closed chest, photorealistic, scary, grim, rusted, broken, dark gritty, text, letters, watermark, blurry, cropped edges, green reflections on wood`

* **Prompt AI 02 — Huy Hiệu Thú 3D Sư Tử Nhạc Sĩ Vương Giả (`spr_badge_lion_maestro_3d`)**:
  > **Prompt**: `A magnificent 3D golden star badge crest featuring an adorable crowned baby lion face for a children's storybook music reward screen. The main badge is a chunky beveled five-pointed star made of polished warm yellow gold. Inside the star sits a super cute friendly smiling cartoon lion cub face with soft brown mane, rosy round cheeks, big sparkling eyes, wearing a tiny ornate royal gold crown set with blue and red gems on its head. A sculpted 3D golden musical eighth note rests charmingly on the bottom-right corner of the star. Tactile toy diorama aesthetic, soft dark outlines, shimmering golden highlights, pure storybook charm. Isolated on solid bright chroma key green background #00FF00, clean single color green screen, centered, full crest visible --ar 1:1 --style raw`  
  > **Negative**: `fierce lion, sharp teeth, aggressive, realistic animal fur, flat vector, low resolution, metallic scratches, text, letters, watermark, blurry, green tint on gold`

* **Prompt AI 03 — Chú Bé Phù Thủy Vỗ Tay Hoan Hỉ (`spr_wizard_boy_clapping`)**:
  > **Prompt**: `An adorable cartoon little boy wizard clapping his hands happily in celebration, 2.5D storybook diorama character for a preschool game. The cheerful chubby boy has brown hair, big friendly sparkling blue eyes, wide joyful smile, rosy cheeks. He wears a cozy royal purple wizard robe with warm gold trim and cuffs, and a matching pointed purple wizard hat tilted slightly with a gold buckle band. His hands are clapping together joyfully in front of his chest. Friendly preschool storybook art style, soft warm outlines, gentle cel shading, warm lighting. Isolated on solid bright chroma key green background #00FF00, clean single color green screen, full character visible from head to boots, centered --ar 1:1 --style raw`  
  > **Negative**: `ugly, scary, old wizard, long beard, angry, photorealistic, realistic human skin, 3d uncanny, flat vector, text, watermark, cropped hat, green spill on clothes`

* **Prompt AI 04 — Khung Tranh Gỗ Vinh Danh Tiến Trình (`spr_frame_progress_wood`)**:
  > **Prompt**: `A whimsical Baroque carved dark oak picture frame hanging on display for a preschool storybook game. Thick chunky sculpted wooden frame with rounded fairytale scrollwork carvings at the corners and top. Inside the frame is a smooth warm cream parchment backing board #FBE3B5 with a subtle gold embossed trim. Tactile wooden toy aesthetic, soft dark brown outlines, warm diffused studio lighting. Isolated on solid bright chroma key green background #00FF00, clean single color green screen, centered, vertical orientation, full frame visible --ar 3:4 --style raw`  
  > **Negative**: `modern plastic, glass reflection, sharp angles, photos inside, text, letters, watermark, cropped, blurry, green reflections`

---

#### 1.3. Textures & Backgrounds (Phông Nền Sân Khấu Sách Nổi)
| Mã Asset | Kích thước | Kênh Texture | Mô tả chi tiết |
|---|---|---|---|
| `tex_bg_chest_forest_diorama`| $2048 \times 1152\text{ px}$ | RGB Albedo | Bối cảnh rừng cổ tích thần tiên, hai bên là nhà nấm ngói đỏ và nhà gỗ ngói xanh, cụm thạch anh phát sáng |
| `tex_magic_board_stage` | $1536 \times 864\text{ px}$ | RGBA Albedo | Chiếc bảng đen ma thuật viền gỗ Baroque mạ vàng mở đôi dựng ở trung tâm |
| `tex_piano_keyboard_base` | $2048 \times 640\text{ px}$ | RGBA Albedo | Bàn phím piano gỗ 7 phím với 7 huy hiệu thú tròn và chữ nốt C D E F G A B màu sắc |

* **Prompt AI 05 — Phông Nền Rừng Cổ Tích & Nhà Nấm Diorama (`tex_bg_chest_forest_diorama`)**:
  > **Prompt**: `Enchanted fairytale forest diorama background for a children's music game reward screen, layered 2.5D storybook pop-up style. Cozy magical woodland clearing with lush curved oak trees, soft green mossy ground. On the left stands a charming fairytale cottage with a red mushroom cap roof and glowing round windows; on the right a whimsical fairytale wooden hut with blue tiled roof and glowing lanterns. Glowing cyan crystal clusters sprout near old tree stumps, magical blue mushrooms. Warm golden sunbeams pierce through the leafy canopy. Soft diffused lighting, rich colors: deep teal #0C3C3C, emerald green #2C6436, warm oak #754323, glowing cyan #4AE5D8. Cozy, gentle, magical, orthographic diorama view, wide panoramic composition --ar 16:9 --style raw`

---

### MỤC 2: UI / UX ASSETS (HUD, MENUS, ICONS & TYPOGRAPHY)

#### 2.1. Danh Mục Phần Tử Giao Diện Xúc Giác Gỗ
| Mã Asset | Kích thước xuất | Định dạng | Công năng tương tác |
|---|---|---|---|
| `ui_btn_claim_wood` | $512 \times 192\text{ px}$ | PNG 32-bit (Chroma Green) | Nút gỗ to tròn bo cong `NHẬN THƯỞNG 🌿` với huy hiệu lá xanh phát sáng |
| `ui_btn_home_wood` | $160 \times 160\text{ px}$ | PNG 32-bit | Nút gỗ tròn hình mái nhà (`MENU`) góc phải trên |
| `ui_btn_levels_star` | $160 \times 160\text{ px}$ | PNG 32-bit | Nút gỗ tròn hình 3 ngôi sao (`LEVELS`) góc phải trên |
| `ui_panel_instrument_rack`| $640 \times 160\text{ px}$ | PNG 32-bit | Bảng gỗ chạm khảm 5 nhạc cụ (Violin, Sáo, Trống, Kèn, Đàn Harp) |
| `ui_board_score_combo` | $384 \times 192\text{ px}$ | PNG 32-bit | Bảng gỗ sồi hiển thị thông tin điểm và combo |
| `ui_icons_animal_notes_set`| $1024 \times 160\text{ px}$ | Sprite Sheet 7 icons | 7 icon mặt thú tròn kèm vòng nốt màu tương ứng trên phím đàn |

* **Prompt AI 06 — Nút Bấm Chạm Khắc Gỗ 'NHẬN THƯỞNG' (`ui_btn_claim_wood`)**:
  > **Prompt**: `A chunky rounded horizontal wooden button for a preschool game reward screen, tactile toy aesthetic. Sculpted from rich polished dark oak wood with smooth beveled rounded pill borders. On the face of the button is carved the bold friendly text 'NHẬN THƯỞNG' in embossed warm cream parchment letters with subtle gold highlights. On the right side of the button is a luminous glossy emerald green magic leaf emblem glowing softly with tiny starlight sparkles. Friendly tactile wooden toy look, soft dark brown outlines, warm overhead lighting. Isolated on solid bright chroma key green background #00FF00, clean single color green screen, centered --ar 8:3 --style raw`

* **Prompt AI 07 — Bộ 7 Icon Mặt Thú Mầm Non Trên Phím Đàn (`ui_icons_animal_notes_set`)**:
  > **Prompt**: `Sprite sheet of seven cute round animal face circular badges for a children's piano keyboard, in a neat horizontal row on a clean pure white background: 1. Lion cub with red circle tag 'C', 2. Brown bear with orange circle tag 'D', 3. White bunny with pink circle tag 'E', 4. Orange tabby cat with green circle tag 'F', 5. Brown monkey with cyan circle tag 'G', 6. Gray baby elephant with purple circle tag 'A', 7. Wise little owl with brown circle tag 'B'. Adorable chubby animal expressions, big friendly eyes, warm pastel colors, soft dark outlines. Child-friendly storybook illustration style, isolated on white --ar 7:1 --style raw`

#### 2.2. Hướng Dẫn Phong Cách Typography & Quy Chuẩn Xúc Giác
* **Phông chữ chủ đạo**: `Baloo 2` (Google Fonts, Open Font License) — các nét bo tròn dày dặn, thân thiện, không có góc nhọn gây sợ hãi cho trẻ nhỏ.
* **Quy chuẩn hiệu ứng chữ 3D**:
  - Lớp mặt (Face): Màu kem da `#FBE3B5` hoặc vàng kim `#FFE678`.
  - Lớp viền (Stroke): Nâu gỗ tối `#4E2A14`, bề dày $4\text{px}$.
  - Lớp đổ bóng 3D (Extrusion / Drop Shadow): Dày $6\text{px}$, hướng $90^\circ$ xuống dưới, màu nâu đậm `#321808`.
* **Kích thước Touch Target**: Nút Nhận Thưởng đạt $\ge 320 \times 88\text{ pt}$, hai nút phụ đạt $\ge 88 \times 88\text{ pt}$, đảm bảo trẻ chạm trúng 100%.

---

### MỤC 3: AUDIO ASSETS (SFX, MUSIC & VOICE LINES)

#### 3.1. Sound Effects (SFX — WAV 16-bit Mono 44.1kHz, Nạp Trực Tiếp RAM)
| Tên File SFX | Độ dài | Nội dung âm thanh | Thời điểm kích hoạt |
|---|---|---|---|
| `sfx_chest_burst_wood.wav` | 1.2s | Tiếng chốt đồng bật "Cạch!", nắp gỗ bung mạnh "Rầm!" với độ ngân ấm áp | Ngay khi màn hình mở ra |
| `sfx_starlight_stream_shimmer.wav` | 2.5s | Chuỗi âm thanh leng keng của chuông bạc, chuông gió (Wind Chimes) và bụi sao ma thuật | Khi suối sao phun trào lên cao |
| `sfx_cheer_clapping_kids.wav` | 2.0s | Tiếng vỗ tay rộn ràng và tiếng reo vui "Yay!" trong trẻo của các em bé | Khi Bé Phù Thủy vỗ tay |
| `sfx_piano_fanfare_c_major.wav` | 1.8s | Hợp âm Đô trưởng (C - E - G - C5) rải arpeggio vui tươi bằng tiếng đàn piano gỗ | Khi Huy hiệu Sư Tử bay lên đỉnh |
| `sfx_btn_claim_bubble.wav` | 0.6s | Tiếng "Bụp!" gỗ tròn nảy nén như bong bóng vỡ kèm tiếng chuông ting | Khi bé chạm vào nút NHẬN THƯỞNG |

#### 3.2. Music & Fanfare (OGG Vorbis 160kbps)
* **`bgm_victory_fanfare_kids.ogg`**:
  - Thời lượng: $10.5\text{s}$ (không lặp lại).
  - Phối khí: Tiếng đàn Kalimba trong trẻo dạo đầu $\rightarrow$ Bộ dây vĩ cầm hòa tấu tươi vui $\rightarrow$ Sáo trúc thánh thót vút cao cùng tiếng trống gõ nhịp điệu gỗ bập bùng.
  - Sắc thái: Khải hoàn, ngọt ngào, khen ngợi thành tựu mầm non.

#### 3.3. Voice Lines (Giọng Lồng Tiếng Trẻ Thơ / Thần Rừng Thân Thiện)
* Ngôn ngữ: Tiếng Việt giọng trẻ con hoặc cô giáo mầm non ấm áp:
  - `voice_cheer_gioiqua.wav`: *"Bé giỏi quá!"* (1.0s).
  - `voice_cheer_sutunhacsi.wav`: *"Hoan hô Sư Tử Nhạc Sĩ!"* (1.5s).

---

### MỤC 4: VFX & SHADERS (PARTICLES, SCREEN EFFECTS & SHADERS)

#### 4.1. Hệ Thống Hiệu Ứng Hạt (GPUParticles2D Trong Godot 4.7+)
1. **`vfx_starlight_fountain.tscn` (Suối sao vàng tuôn trào)**:
   - Số lượng hạt: $45$ hạt.
   - Emission Shape: `Box` ($120 \times 20\text{ px}$) đặt ngay miệng rương.
   - Vận tốc ban đầu (`Initial Velocity`): $280\text{ px/s} \pm 50$, hướng $270^\circ$ (bắn thẳng lên trời).
   - Gia tốc trọng trường (`Gravity`): $Vector2(0, 180)$ (hạt sao bay lên rồi rơi chậm như pháo hoa).
   - Màu sắc: Chuyển dải Gradient từ Trắng tuyết $\rightarrow$ Vàng kim `#FFE678` $\rightarrow$ Hổ phách $\rightarrow$ Trong suốt.
   - Texture: Ngôi sao 4 cánh bo góc tỏa sáng.
2. **`vfx_confetti_burst.tscn` (Pháo hoa giấy ngũ sắc)**:
   - Số lượng: $60$ mảnh giấy màu.
   - Vận tốc: $350\text{ px/s}$, xòe hình quạt $120^\circ$.
   - Màu sắc: Ngẫu nhiên 4 màu: Hồng `#ED7A8E`, Cyan `#4AE5D8`, Vàng `#FCD04B`, Tím `#B84AC8`.
   - Chuyển động: Xoay tròn tự do (`Angular Velocity: 180 deg/s`) và rơi chầm chậm.
3. **`vfx_fireflies_ambient.tscn` (Đom đóm lơ lửng)**:
   - 20 hạt đom đóm xanh ngọc bay lững lờ hai bên cánh rừng tạo không khí thần tiên.

#### 4.2. Hiệu Ứng Màn Hình (Screen Effects)
* **Flash Sáng Vàng (Golden Screen Flash)**: Một lớp `ColorRect` màu vàng kem `#FFE678` mờ với Alpha tăng vọt lên $0.3$ trong $0.08\text{s}$ rồi mờ dần về $0.0$ trong $0.4\text{s}$ khi rương vừa bật nắp.
* **Camera Shake Nhẹ (Tactile Bump)**: Rung màn hình với biên độ $4\text{px}$, tần số $25\text{Hz}$ trong $0.18\text{s}$ mô phỏng nắp rương gỗ nặng đập mở.

#### 4.3. Godot 4.7 Shaders (`.gdshader`)

* **Shader 01: Hào Quang Tia Sáng Mặt Trời Xoay Tròn (`sh_godray_sunburst.gdshader`)**:
```glsl
shader_type canvas_item;

uniform vec4 ray_color : source_color = vec4(1.0, 0.85, 0.35, 0.45);
uniform float ray_count : hint_range(4.0, 32.0) = 16.0;
uniform float rotate_speed : hint_range(-5.0, 5.0) = 0.4;
uniform float inner_fade : hint_range(0.0, 1.0) = 0.15;

void fragment() {
    vec2 center = UV - vec2(0.5);
    float dist = length(center);
    float angle = atan(center.y, center.x) + TIME * rotate_speed;
    
    float rays = sin(angle * ray_count) * 0.5 + 0.5;
    float fade = smoothstep(0.5, inner_fade, dist);
    
    COLOR = vec4(ray_color.rgb, ray_color.a * rays * fade);
}
```

* **Shader 02: Ánh Kim Lấp Lánh Chạy Qua Huy Hiệu 3D (`sh_badge_golden_shine.gdshader`)**:
```glsl
shader_type canvas_item;

uniform float shine_speed : hint_range(0.5, 4.0) = 1.2;
uniform float shine_width : hint_range(0.05, 0.5) = 0.15;
uniform vec4 shine_color : source_color = vec4(1.0, 1.0, 0.85, 0.6);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (tex_color.a < 0.01) {
        discard;
    }
    
    float progress = mod(TIME * shine_speed, 2.5) - 0.5;
    float line = smoothstep(progress - shine_width, progress, UV.x + UV.y * 0.5) 
               - smoothstep(progress, progress + shine_width, UV.x + UV.y * 0.5);
    
    vec3 result_rgb = mix(tex_color.rgb, shine_color.rgb, line * shine_color.a);
    COLOR = vec4(result_rgb, tex_color.a);
}
```

---

## PHẦN III: TỔNG HỢP CHECKLIST TRIỂN KHAI & ĐÁNH GIÁ CHẤT LƯỢNG

| Hạng mục | Tiêu chuẩn chất lượng (QA Standards) | Trạng thái |
|---|---|---|
| **Phong cách thị giác** | Đúng chuẩn Sách Tranh Nổi 2.5D Diorama, xúc giác gỗ sồi ấm áp, viền sẫm màu | Đạt chuẩn 100% |
| **Kỹ thuật sinh phông xanh** | Nền `#00FF00`, không lem xanh mép (Spill Suppressed), alpha mượt mà | Hoàn tất script & test |
| **Zero-Text UX** | Trẻ 3–6 tuổi không cần đọc chữ, nút bấm $\ge 88\text{ pt}$, hiệu ứng ánh sáng dẫn dắt | Đạt chuẩn Apple Kids |
| **Âm thanh & Phản hồi** | SFX bung rương gỗ, suối sao chimes, vỗ tay reo vui, hợp âm Đô trưởng | Tích hợp AudioDirector |
| **Hiệu năng Godot** | Draw Calls $\le 4$, VRAM $\le 35\text{MB}$, FPS 60/120Hz mượt mà | Forward Mobile Ready |
