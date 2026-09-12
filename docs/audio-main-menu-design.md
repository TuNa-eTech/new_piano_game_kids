# Thiết Kế Nhạc Nền Main Menu: "Đại Nhạc Hội Rừng Xanh Rực Rỡ"
*(The High-Energy Forest Carnival Fanfare · bgm_main_menu_theme.ogg)*

Tài liệu thiết kế kiến trúc âm thanh cho màn hình khởi đầu / bìa sách cổ tích `MainMenu` của trò chơi `new-piano`.

---

## 1. Ý Tưởng Nghệ Thuật: "BÙNG NỔ NĂNG LƯỢNG NGAY TỪ GIÂY ĐẦU TIÊN"
Dựa trên phản hồi người dùng: *"làm cho nó sôi động hơn khi mới vào"*, kết hợp với tiêu chuẩn sound design từ các bom tấn hoạt hình & game trẻ em đỉnh cao (**Super Mario Wonder**, **Rayman Legends**, **Cocomelon**, **Toca Life World**):

1. **Mở Màn Bùng Nổ Ngay Phách 1 (Instant Explosive Beat 0 Fanfare):**
   - **Tutti Brass Fanfare Chord:** Hợp âm kèn đồng mạ vàng đại tấu 7 bè (`C3 - G3 - C4 - E4 - G4 - C5 - E5`) vang lên dõng dạc ngay tại `0.00s` ("TADAAA! Chào mừng bé đến với Rừng Nhạc!").
   - **Fairy Chime Glissando:** Dải 12 nốt chuông sao pha lê vuốt vút từ thấp lên cao (`C4 -> G6`) quét âm thanh từ loa trái sang loa phải.
   - **Carnival Splash Cymbal Shimmer:** Tiếng chũm chọe vàng bung tỏa bụi sao lấp lánh với dải tần cao rạng rỡ.
   - **Timpani & Punchy Kick Thump:** Trống bass mộc đập chắc nịch kết hợp gõ mõ lách cách tạo cú hích nhịp điệu dứt khoát.

2. **Tiết Tấu Nhảy Múa Sôi Động (128 BPM Carnival Dance):**
   - Nâng tempo lên **128 BPM** - "nhịp vàng" của các bài hát thiếu nhi sôi nổi nhất thế giới (Baby Shark, Wheels on the Bus).
   - **Syncopated Kick Pattern:** Trống bass không gõ đơn điệu mà nảy nhịp Carnival vui nhộn (Phách 1 mạnh, phách 2.5 nảy, phách 3 chắc, phách 4.5 lượn).
   - **Classroom Handclaps Kép & Snare Rimshot:** Tiếng vỗ tay phòng học ròn rã trên các phách 2 và 4, tạo cảm giác một khán phòng ngập tràn tiếng cười reo hò.
   - **Tambourine Shimmer Train:** Tiếng lắc xúc xắc 16th-note chạy rộn rã xuyên suốt hai bên tai.
   - **Mõ Gỗ Đôi (Temple Blocks):** Tiếng gõ lách cách ("cốc... cách, cốc-cách!") mộc mạc và chân thực.

3. **Dàn Nhạc Thiếu Nhi Đa Tầng Đầy Đặn (Multi-layer Toy Orchestra):**
   - **Tuba & Upright Walking Bass:** Tiếng tuba ấm nảy tưng tưng dưới đáy dải trầm.
   - **Mộc Cầm (Wooden Xylophone & Marimba):** Âm sắc gõ mộc giòn tan, vui tai đặc trưng của đồ chơi gỗ.
   - **Toy Piano & Glockenspiel Lead:** Giai điệu Đô Trưởng trong sáng, lảnh lót, dễ thuộc.
   - **Sáo Trúc Hoạt Hình & Chuông Celesta:** Những câu trill líu lo đối đáp tinh nghịch.

4. **Đoạn Kết Dồn Cao Trào & Vòng Lặp Bất Tận (Perpetual Re-Loop Crescendo):**
   - Ở Ô 15-16: Đoạn dồn trống dồn dập kết hợp chuỗi rải mộc cầm 16 nốt liên tục vút lên cao, đâm thẳng trở lại phách 1 bùng nổ của Ô 1.
   - Vòng lặp tuần hoàn 100% liền mạch toán học (30.00s tròn tại 128 BPM), không có bất kỳ khoảng hẫng hay giảm nhịp nào.

---

## 2. Cấu Trúc Bản Nhạc 16 Ô Nhịp (30.00s @ 128 BPM)

| Đoạn | Ô Nhịp | Tên Đoạn | Điểm Nhấn Âm Nhạc |
| :--- | :--- | :--- | :--- |
| **Intro** | Ô 1 - 2 | **Grand Welcome Fanfare** | Bùng nổ Tutti Hit kèn đồng + Vuốt chuông sao + Tiếng kèn xướng câu chào mừng |
| **Theme** | Ô 3 - 6 | **Carnival Forest Dance** | Giai điệu Đô Trưởng nảy chân sáo, Toy Piano & Mộc Cầm song tấu |
| **Bridge**| Ô 7 - 10| **Animal Call & Response** | Chuyển La thứ nhẹ nhàng, chuông cao gọi - kèn trầm đáp, mõ gõ tinh nghịch |
| **Chorus**| Ô 11 - 14| **Fairylights Carousel** | Cao trào rực lửa, tiếng vỗ tay ròn rã khắp phòng, chuông Celesta lấp lánh |
| **Outro** | Ô 15 - 16| **Rolling Crescendo Re-Loop**| Dồn dập trống & Chuỗi mộc cầm vút lên cao, nối thẳng vào cú nổ Fanfare Ô 1 |

---

## 3. Thông Số Kỹ Thuật (Audio Specs)

- **Tệp tin:** `assets/audio/bgm_main_menu_theme.ogg` (317 KB).
- **Thời lượng loop:** **30.00 giây** chính xác (64 phách tại 128 BPM, 1,323,000 samples @ 44.1kHz).
- **Vòng hợp âm:** `C - G7 - C - F - G7 - C - Am - F - Dm - G7 - F - C - Dm - G7 - F - G7`.
- **Độ sạch pha:** Lượng tử hóa tần số chính xác theo công thức $k / 30.0$ -> Zero-click loop.
- **Mastering Peak:** `-1.0 dBFS` (0.89), phát ở `+6.0 dB` trên Music Bus của Main Menu -> Âm lượng rực rỡ, cân đối hoàn hảo với tiếng đàn.
- **Đồng bộ thị giác:** Nút Khóa Son nảy đàn hồi (Spring Bounce) cùng 2 chùm bụi sao bùng nổ ngay khi mở màn hình.

---

## 4. Prompt Dành Cho Studio AI Cao Cấp (Suno v4 / Udio / Orchestral Stem)

```text
[Prompt]
An explosive, high-energy, joyful orchestral carnival fanfare for a children's cartoon game main menu, opening immediately with a triumphant brass fanfare tutti hit and sparkling magic wand glissando chime, followed by an upbeat bouncy carnival dance, punchy acoustic drums, cheerful handclaps, bouncy walking tuba bass, bright toy piano, wooden xylophone, and sweet piccolo trills, 128 BPM, C major, extremely catchy and celebratory, Pixar / Disney Junior soundtrack quality, seamless loop, crisp modern stereo mastering.
[Style Tags]
Kids Carnival Fanfare, Upbeat Cartoon Theme, Xylophone, Toy Piano, Brass Section, Handclaps, Tuba, Joyful, Energetic, 128 BPM
```
