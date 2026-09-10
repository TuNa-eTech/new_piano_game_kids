# Sổ tay mỹ thuật — Bước 2

Hai việc trong một file: **bộ prompt để dán** ở trên, **sổ ghi asset đã sinh** ở dưới.

Tài liệu gốc: `production-pipeline.html` mục 2. Kế hoạch chi tiết: xem plan Bước 2+3.

---

## 0 · Ba luật đọc trước khi sinh file đầu tiên

**① Ảnh mock là khoá PHONG CÁCH, không phải khuôn NỘI DUNG.**
`docs/mock-game-play.jpeg` cho bảng màu, nét viền, ánh sáng, tỉ lệ nhân vật. Nhưng nội dung trong đó đã bị các Quyết định loại bỏ — sinh lại y nguyên là bake lỗi vào art:

| Có trong mock | Vì sao KHÔNG được sinh lại |
|---|---|
| Chữ `C D E F G A B` trên phím | Sai thang. Game là **ngũ cung** C4 D4 E4 G4 A4 C5 D5. Và v1 **không lời** |
| `SCORE: 1250` · `COMBO: 15` | Quyết định 04 đã bỏ, thay bằng lọ hạt sao |
| Bong bóng thoại tiếng Anh | Người chơi 3–5 tuổi chưa đọc được chữ |
| Hai nút `MENU` + `LEVELS` | Tuần 3 đã gộp thành một nút giữ 2 giây |
| Phù thủy nhỏ | Không còn vai trò sau khi bỏ bong bóng thoại — ngoài phạm vi v1 |

**② Sinh theo LÔ, không sinh lẻ.** Cả nhóm trong một ảnh rồi cắt ra. Một khung ép chúng cùng phong cách, cùng ánh sáng, cùng tỉ lệ — mạnh hơn mọi thủ thuật tham số. Đây là mẹo quan trọng nhất của cả Bước 2.

**③ Duyệt bằng contact sheet.** Xếp mọi biến thể vào một trang, thu nhỏ 30%, nhìn một lượt. Cái nào "nhảy ra" khỏi tấm chung là cái lạc phong cách. **Đừng bao giờ duyệt một asset khi nhìn nó một mình** — đứng riêng thì cái nào cũng ổn.

---

## 1 · Bảng màu — hút thật từ ảnh mock

Đo bằng cách lượng tử hoá `docs/mock-game-play.jpeg` và đếm diện tích, cộng một lượt tìm điểm bão hoà cao. Không phải ước lượng bằng mắt.

| Vai trò | Hex |
|---|---|
| Kem — thân phím đàn | `#FCE4B4` |
| Kem phụ — vùng sáng | `#E4CC9C` |
| Mòng két sâu — nền rừng | `#0C3C3C` |
| Navy sâu — bóng tối nền | `#0C243C` |
| Mòng két nhấn — ánh sáng phép | `#328296` |
| Xanh dương nhấn | `#326E96` |
| Nâu gỗ — thân đàn, thân cây | `#84543C` |
| Nâu gỗ tối — viền, bóng | `#6C3C24` |
| Đỏ nâu ấm — mái nhà, điểm nhấn | `#824632` |

---

## 2 · PROMPT XƯƠNG SỐNG — dán nguyên khối vào mọi lần sinh

Chỉ đổi phần `[CHỦ THỂ]` ở dòng đầu. Mọi thứ còn lại giữ y nguyên, kể cả dấu chấm.

```
[CHỦ THỂ]. Children's picture-book illustration, soft rounded shapes,
gentle outlines in a darker tone of the base color (never pure black),
warm diffused light from above, soft shadows only, flat 2D digital
painting with soft cel shading. Palette: cream #FCE4B4, deep teal
#0C3C3C, deep navy #0C243C, teal accent #328296, blue accent #326E96,
warm wood #84543C, dark wood #6C3C24, warm red-brown #824632.
Friendly big-eyed character, head to body ratio about 1 : 1.5.
Cosy, safe, gentle — made for a 3-year-old.
Plain white background, centered, whole subject visible with margin.
```

**Negative prompt** (dán vào ô negative, hoặc `--no` với Midjourney):

```
text, letters, numbers, words, watermark, signature, UI, score, buttons,
speech bubble, harsh shadows, dark or scary mood, fangs, sharp teeth,
photorealism, realistic fur detail, 3D render, drop shadow
```

---

## 3 · Giữ nhất quán theo từng công cụ

Phần khó không phải sinh ảnh, mà là giữ 47 ảnh trông như cùng một cuốn sách. Mọi cách đều lấy `docs/mock-game-play.jpeg` làm ảnh tham chiếu.

| Công cụ | Cách khoá phong cách |
|---|---|
| **Midjourney** | `--sref <URL ảnh mock> --sw 100 --ar 1:1 --style raw --no text,letters,numbers,watermark` · thêm `--cref` khi sinh tư thế thứ hai của cùng một con vật |
| **Gemini / Nano Banana** | Đính kèm ảnh mock **và lô vừa duyệt** trong cùng hội thoại: *"Match the style of the attached images exactly — same outlines, same lighting, same palette."* |
| **ChatGPT / DALL·E** | Đính kèm ảnh mock, *"same art style as the attached image"*. Giữ **một hội thoại duy nhất** cho cả bộ — mở hội thoại mới là mất phong cách |
| **SDXL / ComfyUI** | Cố định **seed**, IPAdapter trỏ vào ảnh mock, giữ nguyên sampler và CFG cho cả bộ |

---

## 4 · Prompt theo lô — dán `[CHỦ THỂ]` này vào xương sống ở mục 2

### 4.1 · Bảy con vật, tư thế nghỉ — **sinh lô này TRƯỚC TIÊN**

```
Seven cute animal faces in a row on a plain white background, evenly
spaced, all the same size, facing forward, friendly and smiling:
lion, bear, rabbit, cat, monkey, elephant, owl.
```

Thứ tự **bắt buộc đúng** — nó là thứ tự phím trong `game/notes.gd`:
`0 Sư tử · 1 Gấu · 2 Thỏ · 3 Mèo · 4 Khỉ · 5 Voi · 6 Cú`

### 4.2 · Bảy con vật, tư thế hát

Sinh trong **cùng hội thoại** với 4.1 để giữ y nguyên bảy khuôn mặt đó.

```
The same seven animals in the same row and the same order, now all
singing: mouths open in a happy "o", eyes closed and curved with joy.
```

### 4.3 · Cây thần, 8 giai đoạn

```
A magic glowing beanstalk shown in eight growth stages in a row, left to
right: stage 1 a tiny sprout just breaking the soil, stage 8 a tall
curling vine tree filling the frame. Translucent glowing leaves, curling
trunk, gentle magic sparkle. Plain white background.
```

### 4.4 · Lá phát sáng — chỉ **một** ảnh

Sinh **trắng/không màu**. Godot nhuộm 7 màu bằng `modulate`, tiết kiệm 13 file.

```
A single simple leaf shape, soft rounded, translucent and glowing from
within, pure white and pale grey only, no color. Plain white background.
```

### 4.5 · Rương báu — hai trạng thái

```
A small wooden treasure chest with gold trim, shown twice side by side:
closed on the left, open on the right with warm golden light and
sparkles pouring out. Plain white background.
```

### 4.6 · Thân đàn

```
A wooden toy piano body seen straight from the front, warm wood grain,
rounded soft edges, with one long cream-colored key surface and one
small dark decorative key. Plain white background.
```

**Lưu ý riêng cho phím:** thân phím **kem trơn, KHÔNG có chữ cái nào**. Màu con vật nằm ở một dải bo tròn chạy hết chiều ngang chân phím — dải đó do Godot vẽ, không cần sinh.

### 4.7 · Năm nhạc cụ — thanh tiến độ chương

```
Five cute toy musical instruments in a row on a plain white background,
all the same size, simple and rounded: violin, flute, drum, trumpet, harp.
```

### 4.8 · Năm icon giao diện

```
Five simple rounded app icons in a row on a plain white background, all
the same size, thick soft strokes, no text: a hamburger menu icon, a
music note, a closed padlock, a right arrow, a left arrow.
```

### 4.9 · Nền rừng — ba lớp thị sai, sinh RIÊNG từng lớp

Cùng một hội thoại, lần lượt:

```
(lớp xa)   A misty magical forest far background at dusk, deep teal and
           navy, soft silhouettes of tall trees, no detail, very calm.
(lớp giữa) Storybook forest middle layer: rounded trees with soft
           foliage and two small cosy cottages with warm glowing windows.
(lớp gần)  Foreground forest layer: large soft leaves and ferns framing
           the left and right edges, dark teal, plain center left empty.
```

Lớp gần **phải để trống ở giữa** — cây thần và khung truyện nằm ở đó.

### 4.10 · Khung sách 9-slice

```
An open storybook page frame, warm cream paper with soft gold rounded
border, empty in the middle, seen straight on. Plain white background.
```

### 4.11 · Lọ hạt sao + hạt

```
A small round glass jar with a cork lid, half full of glowing golden
star seeds, next to a single small glowing gold star. Plain white
background.
```

### 4.12 · Thẻ chương — chỉ **một** ảnh

Sinh **trung tính**, Godot nhuộm 3 màu chương bằng `modulate`.

```
A blank rounded storybook card, soft cream paper with a gentle border,
empty inside, portrait orientation. Plain white background.
```

### 4.13 · Hạt lấp lánh cho hiệu ứng

```
Two simple particle shapes side by side on a plain white background,
pure white only: a soft four-pointed sparkle, and a small round glow dot.
```

---

## 5 · Sau khi sinh — tách nền, chuẩn hoá, xuất

1. **Tách nền** (Krita): xoá nền trắng, xoá viền thừa, làm mượt rìa.
2. **Kiểm rìa không còn viền trắng.** Lỗi này *chỉ lộ ra khi đặt lên nền tối* — mà nền game là mòng két sâu, đúng bối cảnh làm nó lộ.
3. **Gốc toạ độ nhất quán:** chân con vật luôn ở cùng một `y`. Nếu lệch, cú nảy `SQUASH` sẽ làm bảy con vật nhún ở bảy độ cao khác nhau.
4. **Xuất PNG-24 có alpha**, đúng kích thước 2×.

### Kích thước xuất và tên file

| Asset | Số | Kích thước 2× | Khuôn tên |
|---|---|---|---|
| Con vật nghỉ + hát | 14 | 360×360 | `animal_lion_idle.png` · `animal_lion_sing.png` |
| Thân đàn | 3 | 2560×500 | `piano_key_white.png` · `piano_key_black.png` · `piano_body.png` |
| Cây thần | 8 | 1000×1600 | `tree_stage_01.png` … `tree_stage_08.png` |
| Lá | 1 | 160×160 | `leaf_white.png` |
| Rương báu | 2 | 400×400 | `chest_closed.png` · `chest_open.png` |
| Nền rừng | 3 | 2560×1440 | `bg_far.png` · `bg_mid.png` · `bg_near.png` |
| Khung sách | 1 | 9-slice | `frame_book.png` |
| Lọ sao + hạt | 2 | 180×180 · 64×64 | `ui_star_jar.png` · `ui_star.png` |
| Nhạc cụ | 5 | 180×180 | `progress_violin.png` … |
| Icon UI | 5 | 180×180 | `ui_menu.png` · `ui_free_play.png` · `ui_lock.png` · `ui_arrow_next.png` · `ui_arrow_back.png` |
| Thẻ chương | 1 | 480×620 | `card_chapter.png` |
| Hạt lấp lánh | 2 | 128×128 | `fx_sparkle.png` · `fx_glow.png` |

**Tổng: 47 file.** Đặt trong `assets/art/`.

### Import vào Godot

| Thiết lập | Giá trị | Vì sao |
|---|---|---|
| Filter | Linear (bật) | Art vẽ tay mềm, không phải pixel art |
| Mipmaps | Tắt | Game 2D không thu nhỏ nhiều |
| Compress | **Lossless** | Nén VRAM làm bẩn rìa alpha ở nét mềm |
| Fix Alpha Border | Bật | Chống viền tối quanh sprite |

---

## 6 · Bản quyền

Đọc điều khoản của **công cụ bạn dùng** xem có cho dùng thương mại không — khác nhau giữa các công cụ và giữa các gói thuê bao. App trên store là thương mại **kể cả khi miễn phí**.

Đừng sinh theo phong cách của một studio hay một nhân vật có bản quyền.

Ở một số nơi, nội dung sinh hoàn toàn bằng máy có thể **không** được bảo hộ quyền tác giả — dùng được nhưng khó ngăn người khác dùng lại. Với v1 chấp nhận được, chỉ cần biết mà quyết định.

---

## 7 · SỔ GHI — điền dần, mỗi asset một dòng

Viết dần thì mất 20 phút. Dựng lại từ trí nhớ sau ba tháng thì mất một ngày và vẫn sai.

| File | Lô / prompt chủ thể | Công cụ | Ngày | Ghi chú |
|---|---|---|---|---|
| `animal_lion_idle.png` | Cute lion face, friendly and smiling... | Imagen / Antigravity | 2026-09-09 | Lát cắt dọc 360x360, nền trong suốt |
| `animal_lion_sing.png` | The same cute lion character, singing happily (mouth open 'o', eyes curved joy)... | Imagen / Antigravity | 2026-09-09 | Cùng khuôn mặt & baseline y=345 với idle |
| `animal_bear_idle.png` | Cute friendly brown bear character, facing forward, smiling, sitting... | Imagen / Antigravity | 2026-09-09 | Lô 1, 360x360, nền trong suốt, baseline y=345 |
| `animal_bear_sing.png` | The same cute brown bear character, singing happily (mouth open 'o', eyes curved joy)... | Imagen / Antigravity | 2026-09-09 | Lô 1, 360x360, nền trong suốt, baseline y=345 |
| `animal_rabbit_idle.png` | Cute friendly cream-white bunny rabbit character, facing forward, smiling, sitting... | Imagen / Antigravity | 2026-09-09 | Lô 1, 360x360, nền trong suốt, baseline y=345 |
| `animal_rabbit_sing.png` | The same cute cream-white rabbit character, singing happily (mouth open 'o', eyes curved joy)... | Imagen / Antigravity | 2026-09-09 | Lô 1, 360x360, nền trong suốt, baseline y=345 |
| `animal_cat_idle.png` | Cute friendly ginger cat kitten character, facing forward, smiling, sitting... | Imagen / Antigravity | 2026-09-09 | Lô 1, 360x360, nền trong suốt, baseline y=345 |
| `animal_cat_sing.png` | The same cute ginger cat kitten character, singing happily (mouth open 'o', eyes curved joy)... | Imagen / Antigravity | 2026-09-09 | Lô 1, 360x360, nền trong suốt, baseline y=345 |
| `animal_monkey_idle.png` | A cute little monkey baby character, round ears, warm brown coat and tan face, sitting... | Imagen / Antigravity | 2026-09-09 | Lô 1, 360x360, nền trong suốt, baseline y=345 |
| `animal_monkey_sing.png` | The same cute baby monkey character, singing happily (mouth open 'o', eyes curved joy)... | Imagen / Antigravity | 2026-09-09 | Lô 1, 360x360, nền trong suốt, baseline y=345 |
| `animal_elephant_idle.png` | A cute little baby elephant character, gentle blue-grey pastel skin, cute curled trunk... | Imagen / Antigravity | 2026-09-09 | Lô 1, 360x360, nền trong suốt, baseline y=345 |
| `animal_elephant_sing.png` | The same cute baby elephant character, trunk raised joyfully, singing happily... | Imagen / Antigravity | 2026-09-09 | Lô 1, 360x360, nền trong suốt, baseline y=345 |
| `animal_owl_idle.png` | A cute little baby owl character, warm beige & amber feathers, big round curious eyes... | Imagen / Antigravity | 2026-09-09 | Lô 1, 360x360, nền trong suốt, baseline y=345 |
| `animal_owl_sing.png` | The same cute baby owl character, beak open singing happily, eyes curved joy... | Imagen / Antigravity | 2026-09-09 | Lô 1, 360x360, nền trong suốt, baseline y=345 |
| `progress_violin.png` | Five cute toy musical instruments in a row: violin... | Imagen / Antigravity | 2026-09-09 | Lô 2, 180x180, nền trong suốt, tiến độ trang 1 |
| `progress_flute.png` | Five cute toy musical instruments in a row: flute... | Imagen / Antigravity | 2026-09-09 | Lô 2, 180x180, nền trong suốt, tiến độ trang 2 |
| `progress_drum.png` | Five cute toy musical instruments in a row: drum... | Imagen / Antigravity | 2026-09-09 | Lô 2, 180x180, nền trong suốt, tiến độ trang 3 |
| `progress_trumpet.png` | Five cute toy musical instruments in a row: trumpet... | Imagen / Antigravity | 2026-09-09 | Lô 2, 180x180, nền trong suốt, tiến độ trang 4 |
| `progress_harp.png` | Five cute toy musical instruments in a row: harp... | Imagen / Antigravity | 2026-09-09 | Lô 2, 180x180, nền trong suốt, tiến độ trang 5 |
| `ui_menu.png` | Five simple rounded app icons: hamburger menu icon... | Imagen / Antigravity | 2026-09-09 | Lô 2, 180x180, nền trong suốt, nút Menu giữ 2s |
| `ui_free_play.png` | Five simple rounded app icons: playful music note icon... | Imagen / Antigravity | 2026-09-09 | Lô 2, 180x180, nền trong suốt, nút Chơi Tự Do |
| `ui_lock.png` | Five simple rounded app icons: brass and wood closed padlock icon... | Imagen / Antigravity | 2026-09-09 | Lô 2, 180x180, nền trong suốt, biểu tượng khoá thẻ chương |
| `ui_arrow_next.png` | Five simple rounded app icons: wooden right arrow icon... | Imagen / Antigravity | 2026-09-09 | Lô 2, 180x180, nền trong suốt, điều hướng tiến |
| `ui_arrow_back.png` | Five simple rounded app icons: wooden left arrow icon... | Imagen / Antigravity | 2026-09-09 | Lô 2, 180x180, nền trong suốt, nút quay lui bản đồ chương |
| `tree_stage_01.png` | A magical beanstalk tree in eight progressive growth stages: stage 1 sprout... | Imagen / Antigravity | 2026-09-09 | Lô 3, 1000x1600, nền trong suốt, mầm cây |
| `tree_stage_02.png` | A magical beanstalk tree in eight progressive growth stages: stage 2... | Imagen / Antigravity | 2026-09-09 | Lô 3, 1000x1600, nền trong suốt |
| `tree_stage_03.png` | A magical beanstalk tree in eight progressive growth stages: stage 3... | Imagen / Antigravity | 2026-09-09 | Lô 3, 1000x1600, nền trong suốt |
| `tree_stage_04.png` | A magical beanstalk tree in eight progressive growth stages: stage 4... | Imagen / Antigravity | 2026-09-09 | Lô 3, 1000x1600, nền trong suốt |
| `tree_stage_05.png` | A magical beanstalk tree in eight progressive growth stages: stage 5... | Imagen / Antigravity | 2026-09-09 | Lô 3, 1000x1600, nền trong suốt, thân gỗ |
| `tree_stage_06.png` | A magical beanstalk tree in eight progressive growth stages: stage 6... | Imagen / Antigravity | 2026-09-09 | Lô 3, 1000x1600, nền trong suốt |
| `tree_stage_07.png` | A magical beanstalk tree in eight progressive growth stages: stage 7... | Imagen / Antigravity | 2026-09-09 | Lô 3, 1000x1600, nền trong suốt |
| `tree_stage_08.png` | A magical beanstalk tree in eight progressive growth stages: stage 8 full tree with chest... | Imagen / Antigravity | 2026-09-09 | Lô 3, 1000x1600, nền trong suốt, cây trưởng thành |
| `leaf_white.png` | A single simple cute magical leaf shape, translucent, white monochrome... | Imagen / Antigravity | 2026-09-09 | Lô 3, 160x160, nền trong suốt, Godot modulate 7 màu nốt |
| `chest_closed.png` | A small cute toy wooden treasure chest with gold trim: closed... | Imagen / Antigravity | 2026-09-09 | Lô 3, 400x400, nền trong suốt, rương đóng |
| `chest_open.png` | A small cute toy wooden treasure chest with gold trim: open with golden starlight... | Imagen / Antigravity | 2026-09-09 | Lô 3, 400x400, nền trong suốt, rương mở trổ quả |
| `ui_star_jar.png` | A cute small round glass jar with cork lid filled with golden star seeds... | Imagen / Antigravity | 2026-09-09 | Lô 3, 180x180, nền trong suốt, lọ hạt sao HUD |
| `ui_star.png` | A single cute glowing golden star seed... | Imagen / Antigravity | 2026-09-09 | Lô 3, 64x64, nền trong suốt, hạt sao bay vào lọ |
| `bg_far.png` | A misty magical fairy tale forest far background layer at dusk... | Imagen / Antigravity | 2026-09-09 | Lô 4, 2560x1440, lớp xa thị sai nền rừng |
| `bg_mid.png` | Storybook enchanted forest middle layer: rounded trees, rolling hills, cosy cottages... | Imagen / Antigravity | 2026-09-09 | Lô 4, 2560x1440, lớp giữa thị sai nền rừng |
| `bg_near.png` | Foreground fairy forest vignette layer framing screen edges: large leaves, glowing ferns... | Imagen / Antigravity | 2026-09-09 | Lô 4, 2560x1440, lớp tiền cảnh bao quanh khung |
| `frame_book.png` | A whimsical fairy tale storybook border frame with parchment and wood trim... | Imagen / Antigravity | 2026-09-09 | Lô 4, 1376x768 (9-slice), khung viền sách truyện |
| `card_chapter.png` | A single blank rounded storybook card, portrait orientation, warm parchment... | Imagen / Antigravity | 2026-09-09 | Lô 5, 480x620, nền trong suốt, Godot modulate theo chương |
| `piano_body.png` | Toy piano body elements: horizontal warm wood piano beam board header... | Imagen / Antigravity | 2026-09-09 | Lô 5, 2560x160, nền trong suốt, nẹp gỗ thân đàn |
| `piano_key_white.png` | Smooth rounded vertical cream piano key surface #FCE4B4... | Imagen / Antigravity | 2026-09-09 | Lô 5, 360x500, nền trong suốt, thân phím trắng |
| `piano_key_black.png` | Small rounded dark wood decorative black key... | Imagen / Antigravity | 2026-09-09 | Lô 5, 140x320, nền trong suốt, phím đen trang trí |
| `fx_sparkle.png` | Soft four-pointed star sparkle particle with gaussian falloff, pure white... | Antigravity Engine | 2026-09-09 | Lô 5, 128x128, nền trong suốt, hạt lấp lánh |
| `fx_glow.png` | Smoothstep radial glow dot particle, pure white... | Antigravity Engine | 2026-09-09 | Lô 5, 128x128, nền trong suốt, hạt phát sáng |
| `app_icon_1024.png` | Cute baby lion head centered on warm gold-cream background #F6E7C4, no alpha channel | Imagen / Antigravity | 2026-09-09 | App Store Icon, 1024x1024 RGB, đóng gói phát hành |

