# 🌿 Rừng Nhạc — Enchanted Music Forest 🎵

<p align="center">
  <img src="docs/mock-main-menu.jpeg" alt="Rừng Nhạc - Bìa Sách Khởi Đầu" width="820" style="border-radius: 12px; box-shadow: 0 8px 24px rgba(0,0,0,0.25);" />
</p>

<p align="center">
  <strong>Sách Tranh Nổi Tương Tác Âm Nhạc 3D Dành Riêng Cho Trẻ 3–6 Tuổi</strong><br>
  <em>Interactive 3D Musical Pop-Up Picture Book for Preschoolers</em>
</p>

<p align="center">
  <a href="https://godotengine.org/"><img src="https://img.shields.io/badge/Godot_Engine-4.7_Mobile-478CBF?style=for-the-badge&logo=godotengine&logoColor=white" alt="Godot 4.7"></a>
  <a href="https://developer.apple.com/app-store/kids-apps/"><img src="https://img.shields.io/badge/Apple_Kids-Guideline_1.3_Compliant-000000?style=for-the-badge&logo=apple&logoColor=white" alt="Apple Kids"></a>
  <a href="https://www.ftc.gov/legal-library/browse/rules/childrens-online-privacy-protection-rule-coppa"><img src="https://img.shields.io/badge/COPPA-Child_Safe_Certified-4CAF50?style=for-the-badge" alt="COPPA"></a>
  <a href="#"><img src="https://img.shields.io/badge/Platform-iOS_%7C_Android_%7C_Desktop-FF7043?style=for-the-badge" alt="Platform"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="License"></a>
</p>

---

## 📖 Mục Lục (Table of Contents)

- [🌟 Giới Thiệu (Overview)](#-giới-thiệu-overview)
- [✨ Kim Chỉ Nam Thiết Kế (Design North Star)](#-kim-chỉ-nam-thiết-kế-design-north-star)
- [🎮 Tính Năng Nổi Bật (Core Features)](#-tính-năng-nổi-bật-core-features)
- [🖼️ Hệ Thống 10 Màn Hình & Trải Nghiệm Thị Giác](#️-hệ-thống-10-màn-hình--trải-nghiệm-thị-giác)
- [🎶 Hệ Thống Âm Nhạc & Nhạc Lý Ngũ Cung](#-hệ-thống-âm-nhạc--nhạc-lý-ngũ-cung)
- [🏛️ Kiến Trúc Mã Nguồn & Công Nghệ](#️-kiến-trúc-mã-nguồn--công-nghệ)
- [📂 Cấu Trúc Dự Án (Project Structure)](#-cấu-trúc-dự-án-project-structure)
- [🚀 Hướng Dẫn Cài Đặt & Khởi Chạy (Getting Started)](#-hướng-dẫn-cài-đặt--khởi-chạy-getting-started)
- [🧪 Bộ Kiểm Thử Tự Động (Dev & Test Harness)](#-bộ-kiểm-thử-tự-động-dev--test-harness)
- [📦 Hướng Dẫn Đóng Gói (Build & Export)](#-hướng-dẫn-đóng-gói-build--export)
- [📄 Giấy Phép & Đóng Góp (License & Contributing)](#-giấy-phép--đóng-góp-license--contributing)

---

## 🌟 Giới Thiệu (Overview)

**Rừng Nhạc (Enchanted Music Forest)** là một tác phẩm trò chơi âm nhạc giáo dục sớm chất lượng cao được xây dựng trên nền tảng **Godot Engine 4.7 Mobile**. Lấy cảm hứng từ những cuốn sách tranh pop-up 3D ấm áp cổ điển, trò chơi mở ra một thế giới diệu kỳ nơi mỗi trang sách là một vùng rừng thần tiên, mỗi phím đàn là một người bạn muông thú dễ thương biết hát, và từng nốt nhạc của bé sẽ đánh thức Cây Đậu Thần vươn cao chạm tới Rương Báu Trời Xanh.

Dự án được nghiên cứu và thiết kế tỉ mỉ theo các chuẩn mực phát triển tâm lý trẻ em lứa tuổi mầm non (3–6 tuổi) cùng các yêu cầu kiểm duyệt nghiêm ngặt nhất của **Apple Kids Category** và luật bảo vệ quyền riêng tư trẻ em **COPPA**.

---

## ✨ Kim Chỉ Nam Thiết Kế (Design North Star)

Trò chơi kiên định với 3 nguyên tắc bất biến định hình toàn bộ trải nghiệm tương tác:

1. **Trải Nghiệm Không Chữ (Zero-Text Reliance)**:
   - Trẻ 3–5 tuổi **chưa biết đọc chữ**. Mọi thuật ngữ hàn lâm (`Score`, `Combo`, `Level`, nốt `C4`, `D4`) và lời thoại văn bản đều bị loại bỏ hoàn toàn khỏi giao diện gameplay.
   - Hướng dẫn trực quan qua **Ánh Sáng Hào Quang (Glowing Aura)**, **Cử Động Nhún Nhảy Của Thú (Bouncing Animals)**, và **Dải Cầu Vồng Âm Nhạc (Magic Ribbon Trail)** uốn lượn nối từ ngọn cây xuống phím đàn.
2. **Không Bao Giờ Bế Tắc (Zero Dead Ends)**:
   - Không có màn hình thất bại (Game Over), không tính điểm phạt, không làm mất sao khi bé ấn nhầm phím.
   - Bất kỳ nốt nhạc nào bé gõ đều phát ra âm thanh hòa âm du dương, khích lệ bé tự do khám phá thế giới âm thanh.
   - Mọi nút bấm chuyển màn đều to bản (chuẩn Apple Kids $\ge 88\text{ pt}$), nhạy cảm ứng và có độ trễ giữ an toàn chống chạm vô thức.
3. **An Toàn Tuyệt Đối & Giấc Ngủ Sinh Học (Apple Kids 1.3 & Bedtime Sleep Lock)**:
   - **Cổng Phụ Huynh (Parental Gate)** chống trẻ vô tình vào cài đặt bằng câu đố thị giác xúc giác (*"Chạm vào 3 quả dâu tây đỏ"*).
   - **Đồng Hồ Giờ Ngủ Sinh Học (Bedtime Lock)**: Tự động đưa khu rừng vào giấc ngủ đêm với nhạc ru êm dịu sau 15 hoặc 30 phút chơi, bảo vệ thị lực và nhịp sinh học của bé.
   - Hoàn toàn **không quảng cáo**, **không mua hàng trong ứng dụng (No IAP)**, **không thu thập dữ liệu người dùng**.

---

## 🎮 Tính Năng Nổi Bật (Core Features)

| Tính Năng | Mô Tả Trải Nghiệm |
| :--- | :--- |
| 🎹 **7 Phím Thú Ngũ Cung** | 7 bạn thú 3D sống động đại diện cho thang âm ngũ cung `C4 · D4 · E4 · G4 · A4 · C5 · D5`. Khi nhấn phím, bạn thú mở miệng hát nốt nhạc tương ứng và nhún nhảy theo nhịp điệu. |
| 🌱 **Cây Đậu Thần Sinh Trưởng** | Vòng lặp **Gọi - Đáp (Call & Response)**: Phù thủy đàn mẫu nốt nhạc, bé bấm theo để truyền ánh sáng nuôi cây mọc thêm đốt, đơm hoa kết trái và đưa Rương Báu vươn lên mây trời. |
| 🪕 **Chế Độ Jam Party (Chơi Tự Do)** | Bé thỏa sức bấm đàn sáng tạo theo sở thích cùng 5 bộ nhạc cụ cổ điển: **Piano gỗ**, **Kalimba**, **Sáo trúc**, **Chuông gió**, và **Dàn thú rừng**. |
| 🗺️ **3 Chương Sách Nổi & 15 Bài Hát** | Bản đồ sách 3D mở ra 3 thế giới cổ tích: *Chương 1: Sáo Trúc Rừng Xanh*, *Chương 2: Hồ Nước Kalimba*, *Chương 3: Lâu Đài Chuông Gió*. |
| 🏆 **Rương Thần & Bộ Sưu Tập Huy Hiệu** | Khi hoàn thành mỗi bài hát, Rương Báu bung nắp trào suối ánh sáng và ban tặng Huy Hiệu Hoàng Gia của các bạn thú để bé cất vào Lọ Sao (Star Jar). |
| 🎭 **Đại Hoan Ca Buổi Diễn Rừng Xanh** | Phần thưởng sau khi hoàn thành 5 bài của mỗi chương: Toàn bộ 7 bạn thú cùng Phù Thủy bước lên sân khấu múa rối gỗ rực rỡ và biểu diễn bản hòa tấu 12 giây rộn rã. |
| 🔒 **Góc Phụ Huynh An Toàn** | Quản lý âm lượng độc lập, tùy chỉnh hẹn giờ giới hạn phiên chơi (Tắt / 15 Phút / 30 Phút) với Cổng bảo vệ xúc giác đạt chuẩn quốc tế. |

---

## 🖼️ Hệ Thống 10 Màn Hình & Trải Nghiệm Thị Giác

Dự án hoàn thiện toàn diện bộ 10 màn hình chuẩn hóa theo mockup nghệ thuật và sơ đồ điều phối tập trung [`ScreenRouter`](game/ui/screen_router.gd):

<table align="center">
  <tr>
    <td align="center" width="50%">
      <img src="docs/mock-main-menu.jpeg" alt="Màn 01: Bìa Sách Khởi Đầu" /><br>
      <strong>Màn 01: Menu Bìa Sách Khởi Đầu</strong><br>
      <em>Cuốn sách bìa da dập vàng, nút Chơi khóa son khổng lồ</em>
    </td>
    <td align="center" width="50%">
      <img src="docs/mock-game-play.jpeg" alt="Màn 02: Sân Khấu Chơi Chính" /><br>
      <strong>Màn 02: Sân Khấu Chơi Chính (Core Loop)</strong><br>
      <em>Vòng gọi-đáp, Cây Đậu Thần và Dải ruy băng ma thuật</em>
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <img src="docs/mock-free-play.jpeg" alt="Màn 03: Chơi Tự Do Jam Party" /><br>
      <strong>Màn 03: Sân Khấu Chơi Tự Do (Jam Party)</strong><br>
      <em>Đổi 5 loại nhạc cụ, bong bóng nốt nhạc ngũ sắc</em>
    </td>
    <td align="center" width="50%">
      <img src="docs/mock-chapter-map.jpeg" alt="Màn 04: Bản Đồ 3 Chương" /><br>
      <strong>Màn 04: Bản Đồ 3 Chương Sách Nổi</strong><br>
      <em>Khung trang sách mở với 3 thẻ chương 3D sống động</em>
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <img src="docs/mock-level-select.jpeg" alt="Màn 05: Chọn 5 Màn Chơi" /><br>
      <strong>Màn 05: Chọn 5 Màn Chơi (Level Select)</strong><br>
      <em>Con đường lát đá rêu dẫn lối cùng Bạn Thỏ dẫn đường</em>
    </td>
    <td align="center" width="50%">
      <img src="docs/mock-chest-reward.jpeg" alt="Màn 06: Mở Rương Báu Thần" /><br>
      <strong>Màn 06: Mở Rương Báu Thần</strong><br>
      <em>Rương gỗ bung nắp, suối sao vàng và Huy hiệu Thú 3D</em>
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <img src="docs/mock-grand-finale.jpeg" alt="Màn 07: Đại Hoan Ca Buổi Diễn" /><br>
      <strong>Màn 07: Đại Hoan Ca Buổi Diễn Rừng Xanh</strong><br>
      <em>Sân khấu múa rối gỗ rèm nhung, hòa tấu chúc mừng vinh quang</em>
    </td>
    <td align="center" width="50%">
      <img src="docs/mock-parental-gate.jpeg" alt="Màn 08: Cổng Phụ Huynh Bảo Vệ" /><br>
      <strong>Màn 08: Cổng Phụ Huynh Bảo Vệ (Parental Gate)</strong><br>
      <em>Bảng gỗ xích sắt, câu đố xúc giác: "Chạm 3 quả dâu tây đỏ"</em>
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <img src="docs/mock-parental-corner.jpeg" alt="Màn 09: Góc Cài Đặt Phụ Huynh" /><br>
      <strong>Màn 09: Góc Cài Đặt Phụ Huynh</strong><br>
      <em>Bàn gỗ rừng đêm, thanh trượt âm lượng và hẹn giờ 15m/30m</em>
    </td>
    <td align="center" width="50%">
      <img src="docs/mock-goodnight-bedtime.jpeg" alt="Màn 10: Chúc Bé Ngủ Ngon" /><br>
      <strong>Màn 10: Chúc Bé Ngủ Ngon (Bedtime Lock)</strong><br>
      <em>Ánh trăng dịu êm, Bé Phù Thủy say ngủ và nhạc ru êm ái</em>
    </td>
  </tr>
</table>

---

## 🎶 Hệ Thống Âm Nhạc & Nhạc Lý Ngũ Cung

Khác biệt với các ứng dụng piano thông thường chứa thang âm Chromatic phức tạp dễ gây chói tai khi bé gõ ngẫu nhiên, **Rừng Nhạc** sử dụng **Thang Âm Ngũ Cung Tự Nhiên (Pentatonic Major Scale)**:

$$\{ C_4, D_4, E_4, G_4, A_4, C_5, D_5 \}$$

### 🦁 Bảng Ánh Xạ Phím Thú & Tần Số

| Phím (Index) | Linh Vật | Nốt | Tần Số (Hz) | Mẫu Gốc | Tỉ Lệ Dịch Cao Độ (`pitch_scale`) |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **0** | 🦁 Sư Tử | **C4** | 261.63 Hz | G4 | `0.667` (-7 st) |
| **1** | 🐻 Gấu Nâu | **D4** | 293.66 Hz | G4 | `0.749` (-5 st) |
| **2** | 🐰 Thỏ Trắng | **E4** | 329.63 Hz | G4 | `0.841` (-3 st) |
| **3** | 🐱 Mèo Con | **G4** | 392.00 Hz | **G4** | **`1.000` (Gốc)** |
| **4** | 🐒 Khỉ Vàng | **A4** | 440.00 Hz | G4 | `1.122` (+2 st) |
| **5** | 🐘 Voi Con | **C5** | 523.25 Hz | G4 | `1.335` (+5 st) |
| **6** | 🦉 Cú Mèo | **D5** | 587.33 Hz | G4 | `1.498` (+7 st) |

> 💡 **Kỹ thuật Audio Độc Quyền**: Tất cả 7 giọng thú đều được thu âm/tổng hợp đồng nhất tại nốt gốc **G4** (mono, 44.1 kHz, 16-bit uncompressed). Godot tính toán biến thiên tần số qua `pitch_scale`, triệt tiêu hoàn toàn sự lệch pha hoà âm giữa giọng thú và thảm âm nền (Pad loop BGM).

---

## 🏛️ Kiến Trúc Mã Nguồn & Công Nghệ

```
                                  ┌─────────────────────────────┐
                                  │      AudioDirector          │
                                  │ (Polyphonic Voice & SFX)   │
                                  └──────────────▲──────────────┘
                                                 │
┌──────────────────────────┐      ┌──────────────┴──────────────┐      ┌──────────────────────────┐
│        GameState         │◄────►│         Main Scene          │◄────►│        SaveStore         │
│ (Active Chapter & State) │      │      (game/main.tscn)       │      │ (Encrypted / Persisted)  │
└──────────────────────────┘      └──────────────┬──────────────┘      └──────────────────────────┘
                                                 │
                                  ┌──────────────▼──────────────┐
                                  │        ScreenRouter         │
                                  │  (10 Overlays Coordinator)  │
                                  └──────────────┬──────────────┘
                 ┌───────────────────────────────┼───────────────────────────────┐
                 ▼                               ▼                               ▼
       ┌──────────────────┐            ┌──────────────────┐            ┌──────────────────┐
       │   PianoKeyboard  │            │    MagicTree     │            │   DioramaStage   │
       │ (Touch & Animal) │            │ (Procedural 3D)  │            │ (Shaders & FX)   │
       └──────────────────┘            └──────────────────┘            └──────────────────┘
```

- **Engine Core**: Godot Engine 4.7 Mobile (Mobile Renderer, Direct3D 12 / Metal / Vulkan).
- **Physics Engine**: Jolt Physics 3D tích hợp xử lý va chạm và gia tốc rơi hạt sao.
- **Event Bus Pattern**: Toàn bộ hệ thống giao tiếp qua Godot Signals thuần túy, hoàn toàn phân tách logic hiển thị, âm thanh và trạng thái trò chơi.
- **Singletons (Autoload)**:
  - `AudioDirector`: Quản lý phát đa âm (polyphony), loop nền BGM, cân bằng âm lượng tự động khi có giọng hát thú.
  - `GameState`: Nắm giữ tiến trình, chế độ chơi (`MODE_CALL_RESPONSE` hoặc `MODE_FREE_PLAY`), bài hát hiện tại.
  - `SaveStore`: Lưu trữ cục bộ tiến độ mở khóa chương và số lượng sao thu thập an toàn.
  - `ScreenRouter`: Điều phối chuyển tiếp giữa 10 màn hình không gây giật lag bộ nhớ (Zero-latency overlay transitions).

---

## 📂 Cấu Trúc Dự Án (Project Structure)

```text
new-piano/
├── assets/
│   ├── art/                   # Hơn 170+ tài nguyên đồ họa 3D/2D sách nổi chất lượng cao
│   │   ├── animal_*.png       # Sprite trạng thái Idle & Sing của 7 bạn thú
│   │   ├── badge_*.png        # Huy hiệu phần thưởng hoàng gia
│   │   ├── tree_stage_*.png   # 8 giai đoạn sinh trưởng của Cây Đậu Thần
│   │   └── ...                # Khung sách, background ngày/đêm, nhạc cụ
│   ├── audio/                 # Âm thanh giọng thú (G4), SFX nảy phím, BGM rừng xanh
│   └── placeholder/           # Tài nguyên dự phòng tự tạo
├── docs/                      # Tài liệu kỹ thuật, sổ tay mỹ thuật & ảnh mockup chuẩn 10 màn
│   ├── art-log.md             # Sổ tay màu sắc & quy chuẩn tạo asset mỹ thuật
│   ├── audio-log.md           # Quy chuẩn tần số & thiết kế âm thanh nhạc cụ
│   ├── screen-flow-guide.md   # Hướng dẫn chi tiết luồng chuyển tiếp 10 màn hình
│   └── mock-*.jpeg            # 10 file hình ảnh Mockup chuẩn
├── game/
│   ├── autoload/              # Các Singleton toàn cục (AudioDirector, GameState, SaveStore)
│   ├── dev/                   # Bộ công cụ Test tự động, Đo độ trễ & Chụp màn hình
│   ├── diorama/               # Sân khấu 3D diorama, Dải ruy băng ma thuật, Shader lật trang
│   ├── hud/                   # Thanh tiến độ bài học, Lọ thu thập sao ma thuật
│   ├── piano/                 # Logic bàn phím, Phím đàn thú nhún nhảy (animal_key.gd)
│   ├── story/                 # Cây Đậu Thần (magic_tree.gd)
│   ├── ui/                    # 10 Màn hình UI & Bộ điều phối trung tâm ScreenRouter
│   ├── main.gd                # Nối dây các tín hiệu cốt lõi
│   ├── main.tscn              # Scene gốc của trò chơi
│   ├── call_response.gd       # Logic vòng lặp chơi Gọi - Đáp
│   ├── melodies.gd            # Kho bài hát ngũ cung theo từng chương
│   └── notes.gd               # Định nghĩa nốt, màu sắc nhận diện & ánh xạ phím
├── tools/                     # Các kịch bản Python hỗ trợ tạo audio & pad âm thanh
├── export_presets.cfg         # Cấu hình xuất xưởng iOS (com.tudavid.pianokids) & Android
└── project.godot              # Tệp cấu hình gốc dự án Godot 4.7
```

---

## 🚀 Hướng Dẫn Cài Đặt & Khởi Chạy (Getting Started)

### Yêu Cầu Hệ Thống
- **Godot Engine**: Phiên bản **4.7-stable** (khuyến nghị bản Standard hoặc .NET với Mobile Renderer).
- **Hệ Điều Hành**: macOS 13+, Windows 10/11, hoặc Ubuntu 22.04+.

### Các Bước Cài Đặt
1. **Clone mã nguồn dự án**:
   ```bash
   git clone https://github.com/TuNa-eTech/new_piano_game_kids.git
   cd new_piano_game_kids
   ```

2. **Mở dự án trong Godot**:
   - Khởi động **Godot Engine 4.7**.
   - Nhấn nút **Import** (Nhập dự án).
   - Chọn đường dẫn tới tệp `project.godot` trong thư mục vừa clone.
   - Nhấn **Import & Edit** để mở Editor.

3. **Chạy Trò Chơi**:
   - Nhấn **F5** (hoặc nút Play ở góc trên cùng bên phải) để khởi chạy Scene chính: `res://game/main.tscn`.

---

## 🧪 Bộ Kiểm Thử Tự Động (Dev & Test Harness)

Dự án tích hợp sẵn bộ kịch bản kiểm thử toàn diện đặt trong `game/dev/` giúp nhà phát triển xác minh độ ổn định không cần thao tác tay:

| Scene Kiểm Thử | Tệp Nguồn | Mục Đích Kiểm Thử |
| :--- | :--- | :--- |
| **Vòng Lặp Chơi Nhạc** | `res://game/dev/loop_test.tscn` | Tự động mô phỏng bé gõ phím, kiểm tra tính toán Gọi-Đáp, Cây lớn và chuyển màn. |
| **Điều Hướng 10 Màn** | `res://game/dev/navigation_flow_test.tscn` | Thử nghiệm toàn bộ tín hiệu mở/đóng giữa 10 màn hình qua `ScreenRouter`. |
| **Chụp Màn Hình Toàn Diện** | `res://game/dev/screen_capture_all.tscn` | Tự động tuần tự mở 10 màn hình và xuất ảnh chụp sắc nét để kiểm tra giao diện (Visual QA). |
| **Đo Độ Trễ Âm Thanh** | `res://game/dev/latency_probe.tscn` | Đo lường độ trễ từ lúc chạm phím cảm ứng đến khi AudioDriver phát âm thanh (mục tiêu $<30\text{ ms}$). |
| **Kiểm Thử Độ Bền (Soak Test)**| `res://game/dev/soak_test.tscn` | Chạy liên tục vòng lặp gõ đàn ngẫu nhiên 30 phút nhằm phát hiện rò rỉ bộ nhớ (Memory Leaks). |

---

## 📦 Hướng Dẫn Đóng Gói (Build & Export)

Dự án đã định cấu hình sẵn trong `export_presets.cfg` tối ưu cho nền tảng di động:

### 🍎 Xuất Bản iOS (Apple App Store)
- Bundle Identifier: `com.tudavid.pianokids`
- Kiến trúc hỗ trợ: `arm64` (iOS 15.0+)
- Đạt danh mục: **Kids (Ages 5 and Under / Ages 6–8)**
- Trong Godot: Menu `Project` ➔ `Export...` ➔ Chọn preset `iOS` ➔ `Export Project` để xuất Xcode Project.

### 🤖 Xuất Bản Android (Google Play)
- Tỉ lệ màn hình: Khóa ngang (Landscape)
- Viewport gốc: `1280 x 720` (Scale mode: `canvas_items`, Aspect: `expand`)
- Input: Hỗ trợ đa chạm (Multi-touch) tự nhiên mượt mà trên mọi kích cỡ màn hình máy tính bảng và điện thoại.

---

## 📄 Giấy Phép & Đóng Góp (License & Contributing)

- **Mã nguồn (Source Code)**: Phát hành theo giấy phép [MIT License](LICENSE).
- **Tài nguyên Hình ảnh & Âm thanh (Art & Sound Assets)**: Thuộc bản quyền của `TuNa-eTech`. Nghiêm cấm trích xuất phục vụ mục đích thương mại ngoài phạm vi dự án khi chưa được đồng ý bằng văn bản.
- **Đóng Góp (Contributions)**: Mọi ý kiến đóng góp, báo lỗi (Issue) hoặc đề xuất tính năng (Pull Request) đều được chào đón nồng nhiệt!

---

<p align="center">
  Được xây dựng với tất cả tình yêu thương dành cho nụ cười và tâm hồn âm nhạc của các bé thơ 💖🌿<br>
  <strong>TuNa-eTech © 2026. All rights reserved.</strong>
</p>
