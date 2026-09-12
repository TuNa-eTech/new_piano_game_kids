# QUY TRÌNH MỸ THUẬT 2.5D (GAME ART PIPELINE) & DANH MỤC ASSET PROMPT AI
# MÀN 08: CỔNG PHỤ HUYNH BẢO VỆ ("PARENTAL GATE & TACTILE FRUIT PUZZLE")

> **Dự án**: Rừng Nhạc (Enchanted Music Forest) — Game Âm Nhạc Trẻ Em 3–6 Tuổi  
> **Nguồn cảm hứng thiết kế**: [`docs/mock-parental-gate.jpeg`](file:///Users/anhtu/MySpace/new-piano/docs/mock-parental-gate.jpeg)  
> **Nền tảng mục tiêu**: Godot Engine 4.7+ (Forward Mobile / iOS Metal / Android Vulkan)  
> **Phong cách cốt lõi**: Bảng Gỗ Treo 2.5D Diorama kết hợp đồ chơi xúc giác trái cây gỗ  
> **Tiêu chuẩn pháp lý & UX**: Apple App Store Kids Category Guidelines 1.3 (Parental Gate nghiêm ngặt, chặn mọi thao tác vô tình của trẻ mầm non)

---

## PHẦN I: QUY TRÌNH MỸ THUẬT GAME 2.5D DÀNH CHO INDIE DEVELOPER (4 GIAI ĐOẠN)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                              2.5D PARENTAL GATE ART PIPELINE                                    │
├───────────────────┬───────────────────┬───────────────────────────┬─────────────────────────────┤
│    1. CONCEPT     │    2. CREATION    │       3. CONVERSION       │     4. ASSET MANAGEMENT     │
│                   │                   │                           │                             │
│ • Apple Kids 1.3  │ • Master Prompts  │ • AI Alpha Matting        │ • Godot 4.7 Import Presets  │
│ • Rope Physics    │ • Grid Batching   │ • Defringe & Edge Dilation│ • Layer 20 Highest Modal    │
│ • Color Extraction│ • Style Lock      │ • Normal / ORM / Metal    │ • Draw Call Budget ≤ 2      │
│ • Text vs Visual  │ • Neg-Prompt Safe │ • Texture Atlas 9-Slice   │ • Apple Touch Target ≥ 88 pt│
└───────────────────┴───────────────────┴───────────────────────────┴─────────────────────────────┘
```

---

### Giai đoạn 1: Concept (Khái Niệm, Khóa Phong Cách Thị Giác & Cơ Chế Bảo Vệ)

#### 1.1. Ngôn ngữ tạo hình & Không gian Sân khấu Cổng Treo 2.5D (Suspended Board Stage)
* **Không gian tổng thể**: Giữa thung lũng rừng cổ tích huyền thoại, một chiếc **Bảng Gỗ Sồi Cổ Thụ** khổng lồ được treo lơ lửng bằng 2 sợi dây thừng bện chắc chắn buông từ cành cây cao.
* **Cơ chế câu đố xúc giác bảo vệ trẻ em (Apple Kids 1.3 Tactile Puzzle)**:
  - Trên mặt bảng gỗ có khay đựng **5 loại trái cây gỗ bo tròn (3D Wooden Fruits)**: Chuối vàng, Táo xanh, Dâu tây đỏ.
  - Dòng chữ hướng dẫn viết bằng tiếng Việt có dấu rõ ràng: *"CỔNG PHỤ HUYNH: Hãy chạm vào 3 quả dâu tây đỏ để mở khóa"*.
  - Trẻ mầm non 3–5 tuổi **chưa biết đọc chữ** sẽ không thể vượt qua câu đố bằng cách bấm mò (vì bấm sai sẽ reset câu đố). Người lớn đọc hiểu sẽ chạm 3 lần vào đúng 3 quả dâu tây đỏ.
  - Khi hoàn thành, chiếc **Ổ Khóa Đồng To Bản Hoàng Gia** ở đáy bảng sẽ bung quai phát tiếng "Tách!", bảng gỗ kéo vút lên tán cây kèm hào quang starlight mở lối vào Góc Phụ Huynh.
* **Cấu trúc 4 tầng thị giác 2.5D**:
  1. **Tầng Hậu cảnh (Far Background)**: Thung lũng rừng cổ tích ban ngày với vòm cây cao, 2 ngôi nhà cổ tích hai bên và luồng ánh sáng ma thuật uốn lượn.
  2. **Tầng Bảng Gỗ Treo (Center Hanging Board)**: Bảng gỗ sồi chạm khắc Baroque, 2 nút thắt dây thừng góc trên, khay gỗ chìm chứa 5 quả trái cây.
  3. **Tầng Ổ Khóa Đồng & Xích (Lock & Chains)**: Ổ khóa đồng to bản có lỗ khóa cổ kính, liên kết với mép dưới bảng bằng hai mắt xích đồng.
  4. **Tầng Nút Thoát (Close Button)**: Nút tròn gỗ dập nổi chữ "X" ở góc phải trên (`ui_btn_close_wood_x.png`) với đường kính $\ge 88\text{ pt}$.

#### 1.2. Bảng Màu Chuẩn (Hút Trực Tiếp Từ `mock-parental-gate.jpeg`)
| Tên Màu | Mã Hex | Ứng Dụng Trong Màn 08 | Cảm Xúc & Tâm Lý |
|---|---|---|---|
| **Nâu Gỗ Sồi Cổ** | `#754323` / `#4E2A14` | Bảng gỗ treo, nút đóng chữ X, khay đựng | Chắc chắn, mộc mạc, đáng tin cậy |
| **Đỏ Dâu Tây Mọng** | `#D9384E` / `#E84D63` | 3 quả dâu tây, cuống xanh lá tươi | Ngon mắt, nổi bật, đối tượng cần chạm |
| **Xanh Táo Giòn** | `#5EB83D` / `#4BAE4F` | Quả táo xanh có cuống lá | Tươi mát, tương phản tự nhiên |
| **Vàng Chuối Chín** | `#FCD04B` / `#F5CE42` | Quả chuối vàng cong | Ấm áp, vui tươi, phân loại dễ dàng |
| **Đồng Thau Cổ Kính** | `#C2923C` / `#825A1E` | Ổ khóa đồng, xích sắt, đinh tán góc | Vững chắc, bí mật, kích thích mở khóa |
| **Dây Thừng Gai Mộc** | `#A88258` / `#8A663E` | 2 sợi dây thừng treo bảng, nút thắt | Cơ học tự nhiên, vật lý treo 2.5D |
| **Kem Chữ Khắc** | `#FFF5D0` / `#FBE3B5` | Dòng chữ hướng dẫn trên thớ gỗ | Tương phản WCAG AAA, người lớn đọc rõ |

---

### Giai đoạn 2: Creation (Kỹ Thuật Prompting AI Chuyên Sâu)

#### 2.1. Master Prompt Framework (Bảng Gỗ Treo & Bộ Trái Cây 2.5D)
```
[CHỦ THỂ CỤ THỂ], layered 2.5D diorama pop-up asset for a preschool fairytale music game. Chunky rounded shapes, tactile toy wooden aesthetic, soft darker tone outline (never pure black), warm overhead golden-hour diffused lighting, amber rim light. Palette: rustic oak wood #754323, brass metal #C2923C, ripe strawberry red #D9384E, crisp apple green #5EB83D, sweet banana yellow #FCD04B, hemp rope brown #A88258. Cozy, gentle, playful tactile preschool feeling. Clean solid white background, centered, isolated asset cutout, orthographic pop-up book view, zero artifacts --ar [TỈ LỆ] --style raw
```

#### 2.2. Master AI Prompts Danh Mục Màn 08
* **Prompt AI 01 — Bảng Gỗ Treo Dây Thừng Baroque (`board_parental_gate_hanging`)**:
  > **Prompt**: `A large hanging rectangular dark oak wooden sign board suspended by two thick twisted hemp ropes tied with chunky knots at the top corners, for a children's storybook game. The sign has beveled rustic wooden borders with carved Baroque scroll filigree and brass corner rivets. In the center is a recessed horizontal wooden tray groove. Tactile wooden toy aesthetic, warm golden lighting, isolated on solid pure white background, studio cutout --ar 16:9 --style raw`

* **Prompt AI 02 — Bộ 3 Loại Trái Cây Gỗ Xúc Giác (Sprite Sheet Grid)**:
  > **Prompt**: `Sprite sheet of three chunky tactile wooden toy fruits arranged side by side on a clean pure white background: 1. A curved bright yellow banana with a small brown stem; 2. A crisp round lime-green apple with a tiny brown stem and cute green leaf; 3. A plump vibrant red strawberry with tiny golden seed dots and a fresh leafy green calyx. Smooth toy painted wood finish, rounded friendly corners for toddlers, soft shadows, warm overhead studio lighting, isolated on white --ar 3:1 --style raw`

* **Prompt AI 03 — Ổ Khóa Đồng To Bản Kèm Xích Treo (`padlock_brass_gate_closed`)**:
  > **Prompt**: `An antique chunky brass padlock with two short brass hanging chain links at the top and a classic keyhole in the center. Friendly rounded heavy metal body, polished warm golden brass sheen, gentle dark outlines, tactile preschool toy aesthetic, warm lighting, isolated on pure white background, studio cutout --ar 1:1 --style raw`

* **Prompt AI 04 — Nút Tròn Gỗ Chữ 'X' Bo Tròn (`ui_btn_close_wood_x`)**:
  > **Prompt**: `A chunky circular dark oak wooden button with an embossed rounded cream-colored 'X' cross icon in the center and beveled gold-trimmed borders. Tactile physical wooden toy button, preschool game close button, warm ambient light, isolated on solid white background --ar 1:1 --style raw`

---

### Giai đoạn 3: Conversion (Hậu Kỳ, PBR & Đóng Gói)

* **Alpha Matting**: Tách sợi dây thừng và cuống lá dâu tây không để lại quầng trắng.
* **PBR Maps**:
  - Normal Map cho thớ vân gỗ sồi, vòng xích đồng và bề mặt lấm tấm hạt dâu tây.
  - ORM Map: Táo nhẵn bóng (Roughness $\sim 0.25$), Gỗ sần (Roughness $\sim 0.70$), Ổ khóa kim loại (Metallic $\sim 0.90$).
* **Texture Atlas**: Đóng gói bảng gỗ, nút X, ổ khóa và 3 quả trái cây vào atlas $1024 \times 1024$ (Draw Calls $\le 1$).

---

### Giai đoạn 4: Asset Management (Quản Lý & Tích Hợp Godot 4.7+)

* **Z-Index Layer**: `Layer 20` (Lớp phủ modal cao nhất, che chắn toàn bộ gameplay và menu).
* **Vật lý đung đưa 2.5D (Pendulum Swing)**: Bảng gỗ đung đưa nhẹ quanh trục treo với nhịp sin chậm ($T = 3.2\text{s}$, biên độ $0.8^\circ$).
* **Touch Target**: Nút bấm trái cây đạt kích thước $\ge 88 \times 88\text{ pt}$, Nút đóng đạt $\ge 72 \times 72\text{ pt}$.
