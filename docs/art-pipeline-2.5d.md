# QUY TRÌNH MỸ THUẬT 2.5D (GAME ART PIPELINE) & DANH MỤC ASSET PROMPT AI
> **Dự án**: Rừng Nhạc (Enchanted Music Forest) — Game Âm Nhạc Trẻ Em 3–6 Tuổi  
> **Nền tảng**: Godot Engine 4.7+ (Forward Mobile / iOS Metal)  
> **Trọng tâm**: Hoàn thiện màn hình khởi đầu từ [`docs/mock-main-menu.jpeg`](file:///Users/anhtu/MySpace/new-piano/docs/mock-main-menu.jpeg) theo kiến trúc Sách Tranh Nổi 2.5D Diorama.

---

## PHẦN I: QUY TRÌNH MỸ THUẬT 2.5D CHO INDIE DEVELOPER (4 GIAI ĐOẠN)

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐      ┌──────────────────┐
│   1. CONCEPT    │ ───► │   2. CREATION   │ ───► │  3. CONVERSION  │ ───► │4. ASSET MANAGEM'T│
│ Style Lock/Spec │      │  AI Batch Gen   │      │ Matting/PBR/Atlas│      │ Godot Import/Tree│
└─────────────────┘      └─────────────────┘      └─────────────────┘      └──────────────────┘
```

### 1. Concept (Khái niệm & Khóa phong cách thị giác)
* **Bối cảnh & Ngôn ngữ tạo hình**:
  - Không gian: Sách tranh nổi ma thuật đặt trên bàn gỗ chạm khắc giữa khu rừng cổ tích lúc hoàng hôn (Twilight/Golden Hour).
  - Đối tượng thụ hưởng: Trẻ mầm non 3–6 tuổi $\rightarrow$ Triết lý **Zero-Text** (không chữ, trực quan 100%), góc bo tròn mềm mại, hình khối mập mạp thân thiện (tỉ lệ đầu/thân $1:1.5$).
  - Góc nhìn 2.5D: Chiếu nghiêng nhẹ $15^\circ - 20^\circ$ (Diorama / Pop-up stage tilt) tạo chiều sâu sân khấu nhiều tầng (Multi-plane Stage).
* **Bảng màu chuẩn (Hút trực tiếp từ `mock-main-menu.jpeg`)**:
  - `#FCE4B4` / `#E4CC9C`: Vàng kem phím đàn & trang sách cổ tích.
  - `#0C3C3C` / `#0C243C`: Xanh mòng két & Navy thẫm làm nền rừng sâu.
  - `#84543C` / `#6C3C24`: Nâu gỗ sồi ấm & nâu gỗ bóng đổ.
  - `#F2BE5C` / `#D49A24`: Vàng kim mạ nổi trên bìa sách và nút Khóa Son.
  - `#32CDC4` / `#54CDC1`: Tinh thể pha lê xanh ngọc phát quang.
  - `#824632`: Đỏ nâu ngói nhà cổ tích & ruy băng đánh dấu trang.
* **Quy tắc viền & ánh sáng**:
  - Viền nét (Outlines): Dày vừa phải, màu viền là sắc thái sẫm hơn của mảng màu nội tại (không bao giờ dùng đen tuyền `#000000`).
  - Nguồn sáng: Ánh sáng tản dịu từ trên xuống (Warm Top Diffused Light) kết hợp Rim Light vàng kim trên các cạnh nổi.

---

### 2. Creation (Tạo hình bằng AI Prompt Kỹ thuật cao)
* **Quy tắc sinh theo Lô (Batch Generation)**:
  - Tuyệt đối **không sinh lẻ từng asset rời rạc** để tránh lệch phong cách. Sinh cả bộ nhân vật/nhạc cụ trên cùng một trang (grid) rồi cắt ra.
  - Cố định thông số: Cùng Seed (với SDXL/ComfyUI) hoặc cùng ảnh tham chiếu `--sref` (với Midjourney v6) trỏ về `mock-main-menu.jpeg`.
* **Cấu trúc Prompt Xương Sống (Master Prompt Framework)**:
  - `[CHỦ THỂ CỤ THỂ], layered 2.5d diorama pop-up book asset, storybook illustration, friendly rounded forms, soft darker outline (no pure black), warm diffused golden-hour lighting from above, warm rim light, rich color palette: cream #FCE4B4, deep teal #0C3C3C, warm oak wood #84543C, embossed gilded gold #F2BE5C, glowing cyan crystal #32CDC4. Cozy, gentle, playful for 3-year-olds. Clean white background, centered, isolated asset, studio cutout view --ar [TỈ LỆ] --style raw`
* **Negative Prompt chuẩn**:
  - `text, watermark, signature, UI buttons, photo, hyperrealistic fur, sharp fangs, scary expression, dark horror, low-res, noisy artifacts, 3d polygon mesh wireframe, harsh black outline, cropped, out of frame`

---

### 3. Conversion (Hậu kỳ, Tách nền, PBR & Đóng gói)
* **Bước 3.1: Tách nền & Khử viền (Alpha Matting & Defringe)**:
  - Dùng Krita / Photoshop hoặc tool tách nền AI (`rembg` / `birefnet`).
  - Áp dụng lệnh làm mờ biên $0.5\text{px}$ và tính năng **Fix Alpha Border** (Color Bleed) để tránh viền trắng/xám khi đưa vào game.
* **Bước 3.2: Sinh bản đồ độ sâu & Normal Map cho 2.5D**:
  - Đưa sprite 2D qua bộ công cụ sinh Normal Map (Laigter / SpriteIlluminator / normalmap-online) để tạo hiệu ứng ánh sáng động (CanvasItem Lighting) khi đèn đom đóm bay qua.
  - Tạo Emission Mask (kênh đen-trắng) cho các chi tiết tự phát sáng: Nốt nhạc vàng, chữ mạ vàng, tinh thể pha lê cyan.
* **Bước 3.3: Đóng gói Texture Atlas**:
  - Gom các frame hoạt ảnh thành Sprite Sheet hoặc gom toàn bộ UI Main Menu vào một Texture Atlas duy nhất $2048 \times 2048\text{ px}$ (Power of Two - PoT).

---

### 4. Asset Management & Tích hợp vào Godot 4.7
* **Quy ước đặt tên (Naming Convention)**:
  - Cú pháp: `<loại>_<phân_hệ>_<tên_asset>_<trạng_thái>.<đuôi>`
  - Ví dụ:
    - `spr_char_wizard_idle_01.png`
    - `tex_bg_canopy_parallax.png`
    - `ui_btn_play_clef_normal.png`
    - `sfx_ui_wood_tap.wav`
* **Cấu hình Import trong Godot**:
  - `Compress Mode`: **Lossless (PNG)** đối với UI và Nhân vật; **VRAM Compressed (ETC2/ASTC)** đối với Background lớn.
  - `Mipmaps`: **Tắt (Disabled)** (tiết kiệm bộ nhớ vì game 2.5D cố định tỉ lệ).
  - `Filter`: **Linear (Bật)** (để tranh vẽ mịn màng trên màn hình Retina).
* **Phân lớp Z-Index & Scene Tree 2.5D Diorama**:
  ```
  MainMenu (CanvasLayer / Control)
  ├── Environment (Parallax / CanvasGroup)
  │   ├── Layer -30: FarForest (Nền rừng sâu + Sunbeams)
  │   ├── Layer -20: MidCottages (Nhà nấm cổ tích trái/phải)
  │   └── Layer -10: WoodenDesk (Bàn gỗ chạm khắc + Thảm rêu)
  ├── DioramaCenter (Control / Node2D)
  │   ├── Layer 0: MagicGrimoire (Cuốn sách "RỪNG NHẠC" + Đàn Accordion + Đàn Violin)
  │   ├── Layer +5: FloatingNotesStaff (Dải nốt nhạc vàng xoay quanh sách)
  │   └── Layer +10: Characters
  │       ├── WizardBoy (Sprite2D / AnimatedSprite2D vẫy tay)
  │       └── LionCub (Sprite2D nhún nhảy)
  ├── InteractiveProps (Control)
  │   ├── Layer +20: PlayButtonContainer (Bục gỗ + Khóa Son phát sáng)
  │   ├── Layer +21: ChestDecor (Rương báu gỗ)
  │   └── Layer +22: ManaCrystals (Cụm pha lê xanh phát quang)
  ├── VFXOverlay (Control)
  │   ├── FireflyParticles (GPUParticles2D)
  │   └── StarlightDust (GPUParticles2D)
  └── UIOverlay (CanvasLayer - Layer 30)
      ├── BtnLevels (Góc trái trên)
      └── BtnParents (Góc phải trên)
  ```

---

## PHẦN II: BREAKDOWN CHI TIẾT ASSET LIST & PROMPT AI

### MỤC 1: 2.5D ASSETS (NHÂN VẬT, BỐI CẢNH, ĐẠO CỤ)

#### 1.1. Sprites & Sprite Sheets Nhân Vật
| Tên Asset | Kích thước | Số frame / Dạng | Mục đích trong Godot |
|---|---|---|---|
| `spr_char_wizard_idle_wave` | $512 \times 512\text{ px}$ | Sheet $4 \times 2$ (8 frames) | Phù thủy nhỏ vẫy tay chào bé trên bàn gỗ |
| `spr_char_lion_idle_tail` | $384 \times 384\text{ px}$ | Sheet $4 \times 1$ (4 frames) | Sư tử con thở nhẹ, vẫy đuôi tinh nghịch |
| `spr_prop_accordion_breath` | $512 \times 384\text{ px}$ | 3 frames (co / giãn) | Đàn phong cầm tự phập phồng theo nhịp nhạc |

* **Prompt AI 01 (Bé Phù Thủy & Sư Tử Con - Bộ đôi trang bìa)**:
  > **Prompt**: `Character sheet of a cute preschool child wizard and a baby lion cub, children's storybook style. The boy wears a floppy purple wizard hat with small gold stars, a matching cozy purple tunic with a bronze belt buckle, brown boots, smiling happily and waving warmly. Next to him is an adorable round fluffy lion cub sitting happily with a friendly smile and wagging tail. Head-to-body ratio 1:1.5, soft dark brown outlines, warm top-down fairy-tale lighting, clean white background, separated characters, full body visible, flat 2d picture-book art style --ar 16:9 --style raw`  
  > **Negative**: `sharp teeth, claws, realistic fur texture, scary, adult, tall, 3d render, watermark, text`

* **Prompt AI 02 (Đàn Accordion & Nhạc cụ phụ trên bàn)**:
  > **Prompt**: `Set of miniature whimsical musical instruments resting on mossy wood: a vintage mini accordion with cream piano keys and pleated bellows, a tiny warm wooden violin with bow, a small carved bamboo flute, and a golden fairy harp. Storybook illustration, warm polished wood, polished brass accents, soft gentle outlines, warm lighting, isolated on pure white background, diorama prop sheet --ar 16:9 --style raw`

---

#### 1.2. Textures & PBR Maps (Bề Mặt & Chiều Sâu 2.5D)
| Tên Asset | Kích thước | Kênh Texture | Mô tả kỹ thuật |
|---|---|---|---|
| `tex_grimoire_leather_albedo` | $1024 \times 1024$ | RGB Albedo | Bìa da nâu sẫm dập vân cổ điển của cuốn sách |
| `tex_grimoire_gold_orm` | $1024 \times 1024$ | Occlusion/Roughness/Metallic | Kênh R=AO, G=Roughness, B=Metallic cho chữ mạ vàng |
| `tex_desk_wood_carving` | $2048 \times 512$ | Albedo + Normal | Vân gỗ sồi cổ và hoa văn chạm trổ chân bàn |
| `tex_crystal_emission` | $512 \times 512$ | Grayscale Mask | Mask phát sáng cho tinh thể pha lê cyan |

* **Prompt AI 03 (Cuốn Sách Bìa Da "MUSIC FOREST" & Chữ Mạ Vàng)**:
  > **Prompt**: `Front cover of a massive antique fairy-tale grimoire storybook, thick dark brown weathered leather cover with ornate golden filigree borders, embossed giant golden title 'MUSIC FOREST' centered in whimsical elegant serif font, red velvet bookmark ribbon peeking out, golden musical stave notes swirling around the edges. Rich warm gold accents, magical ambient glow, flat frontal diorama perspective, clean white background --ar 4:3 --style raw`

* **Prompt AI 04 (Thảm Rêu & Bàn Gỗ Cổ Thụ Tiền Cảnh)**:
  > **Prompt**: `Carved antique dark oak wooden table ledge covered in lush soft green moss and tiny woodland mushrooms, fairy tale diorama foreground stage, intricate floral wood carving reliefs along the bottom trim, seamless horizontal edge, warm overhead lighting, isolated on white background --ar 21:9 --style raw`

---

#### 1.3. Backgrounds & Parallax Layers (Phông Nền Đa Tầng)
| File Asset | Kích thước | Độ trễ Parallax (`scroll_scale`) | Vai trò không gian |
|---|---|---|---|
| `bg_layer01_deep_canopy.png` | $2560 \times 1440$ | $(0.05, 0.05)$ | Tán cây xa mờ ảo, tia nắng rọi qua kẽ lá (God rays) |
| `bg_layer02_cottages.png` | $2560 \times 1440$ | $(0.15, 0.15)$ | Hai ngôi nhà cổ tích mái vòm gỗ & ngói đỏ hai bên |
| `bg_layer03_stage_desk.png` | $2560 \times 720$ | $(1.0, 1.0)$ | Khung bàn gỗ tiền cảnh nơi đặt sách và nút bấm |

* **Prompt AI 05 (Hậu cảnh rừng thần tiên & Ngôi nhà cổ tích)**:
  > **Prompt**: `Background painting of an enchanted whimsical forest for a children's book. Cozy storybook wooden cottage houses with glowing round windows nestled among ancient mossy trees, warm sunbeams streaming through lush emerald tree canopy, soft bokeh forest depth, deep teal and navy shadows with warm amber daylight, fantasy atmosphere, no characters, landscape panorama --ar 16:9 --style raw`

---

### MỤC 2: UI / UX ASSETS (GIAO DIỆN & STYLE GUIDE)

#### 2.1. Menus, Badges & Interactive Buttons
| Tên Asset | Kích thước xuất | Trạng thái | Ghi chú Godot |
|---|---|---|---|
| `ui_btn_play_base` | $420 \times 420\text{ px}$ | Normal / Pressed | Bục gỗ tròn dày có vân nổi |
| `ui_btn_play_clef` | $320 \times 320\text{ px}$ | Idle / Glow | Khóa Son mạ vàng 3D phát hào quang |
| `ui_btn_star_levels` | $180 \times 180\text{ px}$ | Normal / Pressed | Huy hiệu gỗ viền đồng, ngôi sao vàng và số 1 |
| `ui_btn_moon_parents` | $180 \times 180\text{ px}$ | Normal / Pressed | Huy hiệu gỗ viền đồng, vầng trăng khuyết & sao nhỏ |
| `ui_panel_wood_frame` | $256 \times 256\text{ px}$ | 9-Slice Patch | Khung viền gỗ parchment co giãn cho popup |

* **Prompt AI 06 (Nút Khóa Son "PLAY" Khổng Lồ)**:
  > **Prompt**: `Large circular wooden button plate with a prominent glowing golden Treble Clef symbol, carved dark oak border with gold inlay, embossed word 'PLAY' in chunky joyful golden lettering underneath the clef. Warm magical yellow halo aura, tactile toy-like feel, children's game UI element, centered, isolated on white background --ar 1:1 --style raw`

* **Prompt AI 07 (Bộ Nút Gỗ Tròn UI: Levels & Parents)**:
  > **Prompt**: `Set of two round carved wooden game badge buttons with thick dark wood borders and brass rivets: Left button has a bright golden 5-point star with number '1' carved inside; Right button has a sleeping crescent moon with a tiny star. Cozy woodland aesthetic, tactile preschool game UI, isolated on pure white background --ar 2:1 --style raw`

#### 2.2. Typography & Style Guide
* **Tiêu đề Display (Title & Buttons)**:
  - Font đề xuất: **Baloo 2** (Extra Bold 800) hoặc **Fredoka**.
  - Xử lý bề mặt: Gradient vàng kim (`#FFE89C` $\rightarrow$ `#D49A24`), stroke viền nâu đậm $3\text{px}$ (`#5A321A`), drop shadow $4\text{px}$ mềm mại (`rgba(0,0,0,0.35)`).
* **Nhãn hướng dẫn (Labels - Levels/Parents)**:
  - Font: **Be Vietnam Pro** (Semi-Bold 600) / Quicksand.
  - Màu sắc: Kem sáng `#FFF5DE`, viền nổi nhẹ, cỡ chữ $\ge 22\text{pt}$ đảm bảo đọc rõ trên màn hình điện thoại.

---

### MỤC 3: AUDIO ASSETS (SFX, BGM, VOICE LINES)

Tất cả asset âm thanh được tối ưu chuẩn Godot 4.7: Nhạc nền nén định dạng `.ogg` (Vorbis loop), hiệu ứng tức thời dùng `.wav` 16-bit 44.1kHz (zero latency decode).

#### 3.1. Nhạc Nền (BGM)
| File Name | Thời lượng / BPM | Nhạc cụ & Cảm xúc | Loop |
|---|---|---|---|
| `bgm_main_menu_forest_waltz.ogg` | 1:20 (84 BPM) | Music box, phong cầm (accordion), guitar mộc, sáo gỗ, pizzicato strings. Êm đềm, kỳ ảo, mời gọi. | Có (Seamless Loop) |

* **Prompt AI Sinh Nhạc (Suno / Udio / MusicFX)**:
  > **Prompt**: `Gentle magical fairy tale waltz, acoustic music box melody, warm soft accordion chords, whimsical woodwinds flute, plucked acoustic guitar and subtle pizzicato cello, cozy bedtime forest adventure, playful and innocent for 3-year-old kids, 84 bpm, high production quality, loopable, calm joyful lullaby vibe`

---

#### 3.2. Hiệu Ứng Âm Thanh (SFX)
| File Name | Thể loại | Đặc tính âm thanh |
|---|---|---|
| `sfx_btn_wood_tap.wav` | Gõ nút thường | Tiếng gõ cốc gỗ tự nhiên, đầm ấm, có độ nảy cơ học ($<100\text{ms}$). |
| `sfx_btn_play_whoosh_chime.wav` | Nhấn nút PLAY | Hợp âm chuông gió glissando ngân vang + tiếng "vút" phép thuật bừng sáng. |
| `sfx_grimoire_open.wav` | Chuyển cảnh | Tiếng trang giấy da dập mạnh ấm áp, kết hợp tiếng hạt bụi sao rơi lấp lánh. |
| `sfx_crystal_ping_high.wav` | Tương tác chạm | Tiếng chuông pha lê trong vắt khi bé chạm vào các cụm thạch anh. |
| `sfx_lion_happy_purr.wav` | Thú cưng | Tiếng rừ rừ dễ thương và tiếng "húp" nghịch ngợm của chú sư tử con. |

* **Prompt AI Sinh Âm Thanh (ElevenLabs Sound Effects / AudioCraft)**:
  > **Wood Tap**: `Soft pleasant organic wooden block click, gentle marimba thud, tactile toy interaction, warm acoustic resonator, zero harshness`  
  > **Play Chime**: `Magical wind chime glissando with warm starlight sparkle burst, fairy dust whoosh, joyful fantasy game start chime`

---

#### 3.3. Giọng Nói & Ngân Nga (Non-Verbal Voice Lines)
Vì game dành cho trẻ 3–6 tuổi và triết lý Zero-Text, **tuyệt đối không dùng câu thoại ngôn ngữ dài dòng**, chỉ dùng âm thanh biểu cảm:
* `vo_wizard_giggle.wav`: Giọng cười khúc khích hồn nhiên của bé phù thủy ("Hihi!", "A-ha!").
* `vo_wizard_humming_pentatonic.wav`: Bé phù thủy ngân nga 3 nốt ngũ cung ngẫu hứng ("La la la~").
* `vo_lion_snore_cute.wav`: Tiếng khò khè êm đềm nếu bé để màn hình chờ quá 15 giây.

---

### MỤC 4: VFX & SHADERS (GODOT 4.7 NATIVE)

#### 4.1. Hệ thống Hạt GPUParticles2D
* **Hạt đom đóm rừng (`vfx_fireflies.tscn`)**:
  - Texture: Chấm tròn gradient mềm $32 \times 32\text{ px}$ (`#FFF8B0`).
  - Chuyển động: Vận tốc chậm $10 - 25\text{ px/s}$, chuyển động sóng sin uốn lượn, chu kỳ sáng mờ (alpha pulse $0.2 \rightarrow 0.9$).
* **Nốt nhạc phát quang xoay quanh sách (`vfx_swirling_notes.tscn`)**:
  - Texture: Sheet 4 nốt nhạc ngũ cung mạ vàng (khóa sol, móc đơn, nốt đen, nốt đôi).
  - Quỹ đạo: Đi theo đường cong Bezier elip xoay quanh cuốn sách "RỪNG NHẠC".
* **Bụi sao bùng nổ khi nhấn Play (`vfx_play_burst.tscn`)**:
  - Bắn ra 30 hạt sao vàng đa kích thước theo hình quạt tròn kèm vệt sáng huỳnh quang.

---

#### 4.2. Shaders Tối Ưu Cho 2.5D Diorama (GDShader Code Sẵn Sàng)

##### Shader 1: Hào quang & Vệt sáng quét qua Khóa Son (`gold_shimmer.gdshader`)
Áp dụng trực tiếp vào `TextureRect` của biểu tượng Khóa Son trên nút PLAY:

```gdshader
shader_type canvas_item;

uniform vec4 shine_color : source_color = vec4(1.0, 0.95, 0.6, 0.8);
uniform float speed : hint_range(0.5, 3.0) = 1.2;
uniform float shine_width : hint_range(0.05, 0.5) = 0.2;
uniform float pulse_intensity : hint_range(0.0, 0.5) = 0.15;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    if (tex.a < 0.05) {
        discard;
    }
    
    // Nhịp thở phát sáng nhẹ (breathing pulse)
    float pulse = sin(TIME * speed * 2.0) * pulse_intensity;
    
    // Vệt sáng vàng kim quét chéo góc 45 độ
    float shine_line = mod(TIME * speed, 3.5) - 1.0;
    float dist = abs((UV.x + UV.y * 0.5) - shine_line);
    float shine = smoothstep(shine_width, 0.0, dist);
    
    vec3 final_rgb = tex.rgb + pulse * vec3(0.3, 0.25, 0.05);
    final_rgb += shine * shine_color.rgb * shine_color.a;
    
    COLOR = vec4(final_rgb, tex.a);
}
```

##### Shader 2: Gió thổi đu đưa thảm rêu và tán lá (`diorama_sway.gdshader`)
Tạo chuyển động mềm mại sống động cho thảm rêu và ngọn cây:

```gdshader
shader_type canvas_item;

uniform float sway_speed : hint_range(0.5, 4.0) = 1.5;
uniform float sway_amplitude : hint_range(0.0, 15.0) = 4.0;

void vertex() {
    // Chỉ lay động phần đỉnh (UV.y nhỏ), giữ cố định phần gốc dưới
    float factor = 1.0 - UV.y;
    VERTEX.x += sin(TIME * sway_speed + VERTEX.y * 0.02) * sway_amplitude * factor;
}
```

---

## PHẦN III: KẾ HOẠCH BƯỚC THỰC THI CHO MÀN HÌNH MAIN MENU

1. **Giai đoạn Tạo Asset (Prompting & Polishing)**:
   - Dùng các Prompt AI ở Phần II để sinh bộ sprite tách lớp của `mock-main-menu.jpeg`.
   - Lưu trữ tại `res://assets/2.5d/main_menu/`.
2. **Refactor Scene `game/ui/main_menu.gd`**:
   - Chuyển đổi từ hiển thị 1 ảnh nền tĩnh sang ghép dựng cây Node phân cấp `CanvasLayer / DioramaStage` chuẩn 2.5D.
   - Gắn shader `gold_shimmer.gdshader` vào nút Khóa Son và bộ phát hạt `GPUParticles2D` đom đóm.
3. **Đấu nối Âm thanh & Tương tác**:
   - Tích hợp `AudioDirector.play_bgm("bgm_main_menu_forest_waltz")`.
   - Kết nối tín hiệu nút `play_pressed`, `levels_pressed`, `parent_gate_requested` theo đúng Ma Trận Điều Hướng đã phê duyệt.

---

## PHẦN IV: NGUYÊN LÝ HOẠT HỌA 12 NGUYÊN TẮC (ANIMATION PRINCIPLES) & BỘ PROMPT AI SPRITE SHEET HOÀN CHỈNH

Nhằm đảm bảo chuyển động của 2 nhân vật (Bé Phù Thủy & Chú Sư Tử Con) đạt độ tự nhiên, sống động và cuốn hút trẻ nhỏ 3–6 tuổi, hệ thống hoạt ảnh đã chuyển hóa từ các pose tĩnh độc lập sang **chuỗi hoạt ảnh nhiều khung hình (Multi-frame Sequential Sprite Sheets)** tuân thủ chặt chẽ 12 nguyên tắc hoạt họa cổ điển (Disney's 12 Basic Principles of Animation).

### 1. Cấu Trúc Khóa Pose Hoạt Ảnh Chuẩn (Key Poses Hierarchy)
Mỗi hành động (Action State) được cấu trúc thành chuỗi tuần tự 4 pha:
$$\text{Anticipation (Lấy đà)} \longrightarrow \text{Action / Apex (Động tác chính)} \longrightarrow \text{Recovery / Impact (Tiếp đất / Hồi phục)} \longrightarrow \text{Follow-through (Chuyển động tàn dư)}$$

---

### 2. Bộ Template Prompt Hoàn Chỉnh Cho AI (Gen Sprite Sheet Chuẩn)

#### 2.1. Khung Mẫu Prompt Tổng Quát (Master Template)
```text
Character [NAME] [ACTION] animation sprite sheet, [NUMBER] frames, 
[VIEW: side view / isometric 45° / 8-directional], 
[STYLE: pixel art 32x32 / stylized low-poly / anime cel-shaded / storybook illustration],
Key poses: [anticipation pose description] → [action pose] → [recovery pose],
Timing: [FPS range],
Technical: transparent background, consistent proportions, game-ready, 
aligned on same baseline, no perspective distortion
```

#### 2.2. Chi Tiết Prompt Sinh Hoạt Ảnh Cho Nhân Vật Game

##### Prompt 1: Bé Phù Thủy — Chuỗi Nhảy Bật (Wizard Jump Animation Sheet - 7 Frames)
> **Prompt**: `Character Little Wizard boy jump animation sprite sheet, 7 frames in a horizontal sequence, side view facing right, children's storybook illustration style, cute preschooler with floppy purple wizard hat and star wand. Key poses: Frame 1 standing idle → Frame 2 deep anticipation crouch with squashed body and bent knees → Frame 3 explosive upward takeoff stretch with arms swinging high → Frame 4 apex float at peak height waving glowing wand → Frame 5 downward descent with cape trailing upward → Frame 6 heavy landing impact with squashed knees and compressed boots → Frame 7 recovery standing upright with hat tip wobble follow-through. Timing: 8 to 12 FPS, Technical: transparent background, consistent proportions, game-ready, aligned on same ground baseline, no perspective distortion, clean crisp outlines --ar 16:9 --style raw`  
> **Negative**: `blurry, uneven baseline, inconsistent character clothes, missing hat, extra limbs, photo, realistic human, harsh black lines`

##### Prompt 2: Bé Phù Thủy — Chuỗi Bước Đi Lon Ton (Wizard Walk/Run Animation Sheet - 6 Frames)
> **Prompt**: `Character Little Wizard boy walk cycle animation sprite sheet, 6 sequential frames in horizontal strip, side view facing right, charming fairy-tale picture book art style, cute chibi wizard. Key poses: Frame 1 right foot contact with heel touching ground → Frame 2 down recoil pose with knees squashed slightly → Frame 3 passing position with left leg lifting forward → Frame 4 left foot contact → Frame 5 down recoil pose → Frame 6 passing position with right leg lifting forward. Flowing purple cloak overlapping action, hat tip bobbing up and down in gentle arc motion. Timing: 6 to 8 FPS, Technical: transparent background, uniform character height, game-ready, perfectly aligned on horizontal baseline, zero perspective distortion --ar 16:9 --style raw`

##### Prompt 3: Chú Sư Tử Con — Chuỗi Vồ Nhảy Tinh Nghịch (Lion Cub Jump & Pounce Sheet - 8 Frames)
> **Prompt**: `Character Baby Lion Cub playful jump and pounce animation sprite sheet, 8 sequential frames arranged horizontally, side view facing right, fluffy cute storybook illustration style with round face and cheerful expression. Key poses: Frame 1 happy sitting idle → Frame 2 anticipation low crouch with wiggling rear hips and flattened ears → Frame 3 spring launch with stretched elongated body and extended paws → Frame 4 high aerial apex arch flying over obstacle → Frame 5 paws-first downward descent → Frame 6 front paws impact squash on ground → Frame 7 rear paws landing with squashed belly → Frame 8 proud recovery standing upright with tail wagging follow-through. Timing: 8 to 12 FPS, Technical: transparent background, consistent proportions across all frames, game-ready, aligned on same baseline, no perspective distortion --ar 16:9 --style raw`

##### Prompt 4: Bé Phù Thủy — Chuỗi Vung Đũa Thần Kỳ (Wizard Cast/Attack Animation Sheet - 6 Frames)
> **Prompt**: `Character Little Wizard boy magical music spell attack animation sprite sheet, 6 frames, side view facing right, storybook illustration. Key poses: Frame 1 ready stance → Frame 2 anticipation drawing wand backward and shifting weight to back foot → Frame 3 dynamic forward thrust strike casting sparkling golden treble clef → Frame 4 full extension with star particle burst → Frame 5 wand recoil and wrist relax → Frame 6 recovery returning to center with fluttering cape. Timing: 10 FPS, Technical: transparent background, consistent proportions, game-ready, aligned on same baseline --ar 16:9 --style raw`

##### Prompt 5: Chú Sư Tử Con — Chuỗi Gõ Trống Vui Nhộn (Lion Drum Beat Sheet - 5 Frames)
> **Prompt**: `Character Baby Lion Cub rhythmic drum beat animation sprite sheet, 5 frames, side view, storybook style. Key poses: Frame 1 paws poised high above mushroom drum → Frame 2 swift downward swing with arc motion → Frame 3 double paw impact on drum with bouncy squash → Frame 4 upward elastic rebound recoil → Frame 5 proud ear-perk recovery. Timing: 8 FPS, Technical: transparent background, consistent proportions, game-ready, aligned on same baseline --ar 16:9 --style raw`

---

### 3. 5 Mẹo Vàng Giúp Hoạt Ảnh Tự Nhiên & Biểu Cảm Cho Trẻ Nhỏ

| Nguyên Lý | Bản Chất Hoạt Họa | Ứng Dụng Thực Tế Trong Godot 4.7 (`animated_menu_characters.gd`) |
| :--- | :--- | :--- |
| **1. Squash & Stretch** *(Nén và Dãn)* | Khi nhảy/tiếp đất, thể tích cơ thể không đổi nhưng hình dạng co giãn để tạo cảm giác mềm dẻo, đàn hồi (elastic). | - Khi lấy đà nhảy: `scale = Vector2(1.15, 0.85)` (nén bẹt).<br>- Khi bay vút lên: `scale = Vector2(0.88, 1.18)` (dãn dài).<br>- Khi chạm đất: `scale = Vector2(1.22, 0.78)` trong $0.08\text{s}$, sau đó bung về `Vector2(1.0, 1.0)`. |
| **2. Anticipation** *(Lấy đà / Dự báo)* | Trước mọi hành động mạnh (nhảy, vung đũa, vồ mồi) luôn có tư thế chuẩn bị ngược hướng chuyển động giúp trẻ đọc được ý đồ. | - Trước khi nhảy: Nhân vật hạ thấp trọng tâm $Y + 8\text{px}$, gập đầu gối trong 2 frame đầu ($0.15\text{s}$). Trẻ thấy rõ nhân vật "nhún gối lấy hơi" trước khi bay lên. |
| **3. Follow-through & Overlapping** *(Quá đà & Chuyển động chồng lấn)* | Các bộ phận phụ (chóp mũ phù thủy, tà áo choàng, chóp đuôi sư tử) tiếp tục chuyển động trễ 2–4 frame sau khi thân mình đã dừng hẳn. | - Khi phù thủy tiếp đất, thân mình dừng lại nhưng chóp mũ lắc lư thêm 2 nhịp sin wave trễ $0.2\text{s}$.<br>- Khi sư tử dừng chạy, chùm lông đuôi vẫy thêm 3 nhịp trước khi về tĩnh. |
| **4. Arc Motion** *(Chuyển động quỹ đạo cong)* | Sinh vật sống hầu như không bao giờ di chuyển theo đường thẳng tắp cứng nhắc mà luôn theo đường cong elip uốn lượn. | - Bước chạy: Độ cao $Y$ nhấp nhô nhịp nhàng theo chu kỳ $\sin(t \cdot \omega)$ tạo bước đi bập bùng thay vì trượt phẳng.<br>- Bước nhảy: Quỹ đạo parabol kết hợp `Tween.TRANS_QUAD` + `Tween.EASE_OUT` khi lên và `EASE_IN` khi xuống. |
| **5. Weight Shift** *(Chuyển dịch trọng tâm & Bóng đổ)* | Khi dồn trọng lượng sang chân này hay nhấc chân kia, điểm tựa và diện tích tiếp xúc với mặt đất thay đổi rõ rệt. | - Hệ thống **Dynamic Contact Shadow Canvas**: Khi nhân vật ở dưới đất, bóng đen hình elip đậm màu và dẹt phẳng ngay dưới bàn chân.<br>- Khi nhân vật nhảy lên cao, bóng vẫn nằm cố định trên mặt bàn gỗ nhưng tự động thu nhỏ bán kính và mờ dần tỉ lệ nghịch với độ cao $Y$. |

---

### 4. Quy Trình Bóc Tách Frame Tự Động Trong Godot Engine

Để chuyển đổi từ Sprite Sheet nguyên bản do AI tạo ra thành các asset game sẵn sàng sử dụng, dự án thiết lập kịch bản bóc tách tự động [`tools/slice_animation_frames.gd`](file:///Users/anhtu/MySpace/new-piano/tools/slice_animation_frames.gd):

1. **Khử Nền & Cắt Cạnh Thông Minh**: Tự động phát hiện viền nền trắng/kem, tính toán biên an toàn để loại bỏ đường baseline vẽ trên sheet.
2. **Chuẩn Hóa Kích Thước Khung Hình**: Toàn bộ các frame sau khi bóc tách được xuất ra định dạng PNG trong suốt (`RGBA8`), lưu trữ khoa học tại:
   - `res://assets/characters/wizard/anims/jump/jump_{0..6}.png` (7 frames)
   - `res://assets/characters/wizard/anims/walk/walk_{0..5}.png` (6 frames)
   - `res://assets/characters/lion/anims/jump/jump_{0..7}.png` (8 frames)
3. **Cơ Chế Phát Thời Gian Thực (Runtime Frame Player)**:
   - Trong `_process(delta)` của [`game/ui/animated_menu_characters.gd`](file:///Users/anhtu/MySpace/new-piano/game/ui/animated_menu_characters.gd):
   ```gdscript
   if _wizard_state == AnimState.WALK and not _wizard_walk_frames.is_empty():
       var idx: int = int(_wizard_anim_timer * 7.5) % _wizard_walk_frames.size()
       _wizard_rect.texture = _wizard_walk_frames[idx]
   elif _wizard_state == AnimState.JUMP and not _wizard_jump_frames.is_empty():
       var idx: int = clamp(int(_wizard_anim_timer * 9.0), 0, _wizard_jump_frames.size() - 1)
       _wizard_rect.texture = _wizard_jump_frames[idx]
   ```
   - Nhờ kết hợp frame vẽ tuần tự cùng với biến đổi vị trí và độ co giãn đàn hồi, nhân vật chuyển động mượt mà, sống động vượt bậc so với một hình ảnh xoay lật đơn điệu.

