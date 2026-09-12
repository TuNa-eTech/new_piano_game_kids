# Sổ tay âm thanh — Bước 3

Hai việc trong một file: **bộ prompt để dán** ở trên, **sổ ghi nguồn + giấy phép** ở dưới.

Hướng đã chốt: **sinh bằng AI** (giọng thú, SFX, nhạc nền).

---

## 1 · 18 file, không phải 30

| Nhóm | Số | Định dạng | Tên |
|---|---|---|---|
| Giọng thú, mẫu gốc **G4** | 7 | WAV mono 44,1 kHz 16-bit | `voice_lion_g4.wav` · `voice_bear_g4.wav` · `voice_rabbit_g4.wav` · `voice_cat_g4.wav` · `voice_monkey_g4.wav` · `voice_elephant_g4.wav` · `voice_owl_g4.wav` |
| Nốt đàn nền | 1 | WAV mono | `note_base_g4.wav` |
| Pad hoà âm | 1 | OGG stereo, **loop** | `bgm_forest_loop.ogg` |
| SFX | 8 | WAV mono | xem mục 4 |
| Nhạc màn kết chương | 1 | OGG stereo | `bgm_chapter_end.ogg` |

Đặt trong `assets/audio/`.

---

## 2 · Vì sao TẤT CẢ giọng thú đều sinh ở G4

Mỗi phím là một con vật gắn với đúng một nốt, nên nghe qua thì mỗi giọng chỉ cần một cao độ — sinh thẳng cao độ đó là xong. **Đừng làm thế.**

- Bảy file sinh riêng từng cao độ sẽ **lệch tông với pad nền theo bảy kiểu khác nhau**, và lỗi đó rất khó nghe ra khi thử từng phím một.
- Sinh cùng một nốt gốc thì chỉnh tông là chỉnh **một** file, không phải bảy.
- G4 nằm giữa thang nên khoảng dịch tối đa chỉ ±7 nửa cung — đủ để giọng thú không biến thành tiếng chuột hay tiếng quái vật.

Godot dịch cao độ bằng `pitch_scale`:

| Phím | Con vật | Nốt | `pitch_scale` |
|---|---|---|---|
| 0 | Sư tử | C4 · 261,63 Hz | 0,667 |
| 1 | Gấu | D4 · 293,66 Hz | 0,749 |
| 2 | Thỏ | E4 · 329,63 Hz | 0,841 |
| 3 | Mèo | G4 · 392,00 Hz | **1,000** (gốc) |
| 4 | Khỉ | A4 · 440,00 Hz | 1,122 |
| 5 | Voi | C5 · 523,25 Hz | 1,335 |
| 6 | Cú | D5 · 587,33 Hz | 1,498 |

Đổi `pitch_scale` cũng làm mẫu ngắn/dài đi theo. Với tiếng thú 0,4–0,8 giây thì không thành vấn đề — thậm chí còn duyên.

---

## 3 · Prompt giọng thú

Đổi `[ANIMAL]`, giữ nguyên phần còn lại:

```
A friendly cartoon [ANIMAL] singing one short warm musical note, like a
children's picture-book character humming. Soft, round, gentle. Not a
realistic animal sound. Single sustained note, 0.6 seconds, clean, no
reverb, no background noise, mono.
```

Bảy `[ANIMAL]`: `lion` · `bear` · `rabbit` · `cat` · `monkey` · `elephant` · `owl`

### Cái bẫy lớn nhất

Công cụ AI sẽ mặc định cho ra **tiếng thú thật** — sư tử gầm, voi rống. Thứ đó dùng không được: game này là sách tranh, và tiếng gầm thật sẽ làm bé 3 tuổi **giật mình**.

Hai câu `Not a realistic animal sound` và `like a children's picture-book character humming` phải giữ nguyên trong mọi lần sinh.

Nếu công cụ vẫn cứ ra tiếng thật, **chuyển hẳn sang giọng người hát nguyên âm**:

```
A warm friendly human voice humming "ooo" on one single sustained note,
gentle and round, like a parent singing to a toddler. 0.6 seconds, clean,
no reverb, mono.
```

Bảy con vật khi đó khác nhau ở **chất giọng**, không ở loài: sư tử giọng trầm dày · gấu trầm ấm · thỏ nhẹ và cao · mèo mảnh · khỉ tinh nghịch · voi tròn và sâu · cú nhẹ và hơi rung. Cách này nghe hợp sách tranh hơn hẳn.

---

## 4 · Prompt SFX

Đuôi dùng chung:

```
[SUBJECT]. Short, soft, gentle UI sound for a children's game. Warm and
rounded, no harsh transient, no metallic ring, mono, under 0.5 seconds.
```

| File | `[SUBJECT]` | Kích hoạt ở đâu |
|---|---|---|
| `sfx_star_ting.wav` | `A tiny magical star chime` | Mỗi nốt đúng — thay `play_ting()` |
| `sfx_chapter_select.wav` | `A soft page-flip whoosh` | Bé chọn một chương trên bản đồ |
| `sfx_chest_open.wav` | `A small wooden treasure chest opening` | Cây trổ quả, màn kết chương |
| `sfx_page_turn.wav` | `A gentle page turn` | Lật sang trang mới |
| `sfx_menu_open.wav` | `A soft woody click opening a menu` | Bản đồ chương mở |
| `sfx_hold_complete.wav` | `A warm confirming chime` | Vòng giữ 2 giây đầy — phản hồi cho **người lớn** |
| `sfx_chapter_unlock.wav` | `A bright unlocking sparkle` | Mở khoá chương mới |
| `sfx_free_play_toggle.wav` | `A light playful toggle` | Bật/tắt Chơi Tự Do |
| `sfx_soft_boing.wav` | `A soft bouncy marshmallow boing` | Sư tử/phù thủy bật nhảy tưng bừng (`-12dB`) |
| `sfx_fairy_dust.wav` | `A tiny shimmering fairy dust cascade` | Vung đũa phép, sao lấp lánh li ti (`-10dB`) |
| `sfx_giggle_cute.wav` | `A warm innocent cartoon baby giggle` | Hai bạn nhỏ chạm mặt, cười đùa (`-11dB`) |
| `sfx_soft_plop.wav` | `A gentle rounded cushion moss tumble` | Sư tử ngã nhào lộn trên đệm rêu (`-10dB`) |
| `sfx_cute_purr.wav` | `A soothing sleepy kitten purr` | Hai bạn cuộn tròn chợp mắt ngủ (`-13dB`) |

**Bộ SFX Hoạt Hình Hữu Cơ (Organic Cartoon Audio)**: Được thiết kế riêng cho các hoạt cảnh chờ của 2 nhân vật, phát với âm lượng nền dịu ngọt ($-10\text{dB}$ đến $-13\text{dB}$), hoàn toàn không mang nốt nhạc để không xung đột với bài BGM ru ngủ.

Tất cả các tên trên đã được nạp tự động qua `AudioDirector.SFX_NAMES` và gọi thông qua `AudioDirector.play_sfx(name, volume_db)`.

---

## 5 · Prompt nhạc

### Pad hoà âm nền — `bgm_forest_loop.ogg`

```
Gentle looping lullaby for a children's game. Soft harp and warm strings,
chord progression C - Am - F - G, 72 BPM, no drums, no percussion, no
harsh high frequencies, calm and sparse, seamless loop, 8 bars.
```

Phát lặp vô hạn ở **−18 dB**. Không bao giờ được lấn tiếng nốt.

### Nhạc màn kết chương — `bgm_chapter_end.ogg`

```
A short warm celebratory ending cue for a children's storybook game.
Soft harp, glockenspiel, gentle rising resolution. No drums. Calm and
joyful, not triumphant or loud.
```

Độ dài đích: **11,8 giây** — đúng bằng thời lượng buổi diễn đã đo trong `game/ui/chapter_end.gd`.

### Nốt đàn nền — `note_base_g4.wav`

```
A single soft kalimba note at G4, warm and round, short natural decay,
clean, no reverb, mono.
```

File này phát **chồng dưới** giọng thú ở mỗi cú chạm cho dày tiếng.

---

## 6 · Hậu kỳ — cùng một quy trình cho mọi file

1. **Cắt phần lặng ở đầu.** Attack **dưới 10 ms**. Mỗi mili-giây lặng là mili-giây trễ mà ngón tay bé cảm nhận được — ràng buộc cứng đã đo suốt Tuần 1.
2. **Chỉnh về đúng G4** (392,00 Hz) cho cả bảy giọng. Sai ở mẫu gốc thì cả 7 phím lệch tông so với pad nền.
3. **Fade out 30–50 ms** ở đuôi, tránh tiếng "cụp" khi âm bị cắt đột ngột.
4. **Normalize đỉnh về −3 dBFS**, rồi nghe cả bộ liên tiếp và chỉnh tay cho *cảm giác* to bằng nhau — voi nghe sẽ to hơn thỏ dù cùng số đo.
5. **Xuất** WAV mono 44,1 kHz 16-bit (nốt + SFX) · OGG stereo (nhạc).

Mono là cố ý: nhẹ hơn, và loa điện thoại vốn gần như mono.

---

## 7 · Bẫy import Godot — đã sập một lần

**`edit/loop_mode` của trình nhập WAV lệch một bậc.** Có mục *Detect From WAV* ở vị trí 0, nên:

| Giá trị | Nghĩa |
|---|---|
| 0 | Detect From WAV |
| 1 | **Disabled** |
| **2** | **Forward** ← muốn lặp thì dùng số này |

Commit `d06ed98` sửa đúng lỗi này: pad nền chết sau 8 giây suốt từ Tuần 1 vì file ghi `1` với ý định "Forward".

Ngoài ra:
- `compress/mode = 0` (PCM) cho mọi WAV. Mặc định của Godot là QOA.
- Với OGG: bật **Loop** trong tab Import cho `bgm_forest_loop.ogg`.

---

## 8 · Bus và mixing

| Bus | Mức | Ghi chú |
|---|---|---|
| Master | 0 dB | Có **HardLimiter** — chặn đỉnh giật mình khi bé đập 7 phím cùng lúc |
| Notes | −3 dB | Giọng thú + nốt nền. Ưu tiên cao nhất |
| Music | −18 dB | Pad nền. Không bao giờ được lấn tiếng nốt |
| SFX | −8 dB | Hạt sao, lá nở, rương mở |

**Nghe thử bằng loa ngoài của một chiếc điện thoại rẻ, không phải tai nghe.** Trẻ con chơi bằng loa ngoài nhỏ và méo; một bản mix hay trên tai nghe có thể biến mất hoàn toàn ở đó. Nghe ở 50% và 100% âm lượng, và bảo đảm không âm nào làm người lớn giật mình ở 100%.

---

## 9 · Bản quyền

Đọc điều khoản **của từng công cụ** xem có cho dùng thương mại không. App trên store là thương mại kể cả khi miễn phí. Điều này áp cho **cả âm thanh**, không riêng ảnh.

Nếu có lấy file từ thư viện ngoài, luật giấy phép:

| Giấy phép | Dùng được? | Việc phải làm |
|---|---|---|
| CC0 / Public Domain | Được, thoải mái | Vẫn lưu link nguồn |
| CC-BY | Được | **Bắt buộc** ghi công đúng tên tác giả ở màn Credits |
| CC-BY-**NC** | **Không** | "NC" = phi thương mại |
| "Free download" không ghi rõ | **Coi như không** | Bẫy phổ biến nhất. Không rõ giấy phép thì không dùng |
| Mua thư viện thương mại | Được | Lưu hoá đơn |

---

## 10 · SỔ GHI — điền dần, mỗi file một dòng

| File | Nguồn / công cụ | Prompt hoặc URL | Giấy phép | Tác giả | Ngày |
|---|---|---|---|---|---|
| `voice_lion_g4.wav` | Python formant synth | Cartoon lion singing warm short note at G4 | MIT / In-house | Antigravity | 2026-09-09 |
| `voice_bear_g4.wav` | Python formant synth | Cartoon bear warm round deep hum at G4 | MIT / In-house | Antigravity | 2026-09-09 |
| `voice_rabbit_g4.wav` | Python formant synth | Cartoon rabbit pure clear light hum at G4 | MIT / In-house | Antigravity | 2026-09-09 |
| `voice_cat_g4.wav` | Python formant synth | Cartoon cat gentle meow-hum at G4 | MIT / In-house | Antigravity | 2026-09-09 |
| `voice_monkey_g4.wav` | Python formant synth | Cartoon monkey bouncy playful hum at G4 | MIT / In-house | Antigravity | 2026-09-09 |
| `voice_elephant_g4.wav` | Python formant synth | Cartoon elephant deep round resonant hum at G4 | MIT / In-house | Antigravity | 2026-09-09 |
| `voice_owl_g4.wav` | Python formant synth | Cartoon owl gentle breathy vibrato hum at G4 | MIT / In-house | Antigravity | 2026-09-09 |
| `note_base_g4.wav` | Python tine synth | Soft warm kalimba pluck at G4 | MIT / In-house | Antigravity | 2026-09-09 |
| `bgm_forest_loop.ogg` | Python + ffmpeg | Gentle lullaby loop C-Am-F-G 72BPM -18dB | MIT / In-house | Antigravity | 2026-09-09 |
| `bgm_chapter_end.ogg` | Python + ffmpeg | Warm celebratory harp & glockenspiel 11.8s | MIT / In-house | Antigravity | 2026-09-09 |
| `sfx_star_ting.wav` | Python harmonic synth | A tiny magical star chime | MIT / In-house | Antigravity | 2026-09-09 |
| `sfx_chapter_select.wav` | Python synth | A soft page-flip whoosh | MIT / In-house | Antigravity | 2026-09-09 |
| `sfx_chest_open.wav` | Python synth | A small wooden treasure chest opening | MIT / In-house | Antigravity | 2026-09-09 |
| `sfx_page_turn.wav` | Python synth | A gentle page turn paper rustle | MIT / In-house | Antigravity | 2026-09-09 |
| `sfx_menu_open.wav` | Python synth | A soft woody click opening a menu | MIT / In-house | Antigravity | 2026-09-09 |
| `sfx_hold_complete.wav` | Python synth | A warm confirming chime for 2s hold | MIT / In-house | Antigravity | 2026-09-09 |
| `sfx_chapter_unlock.wav` | Python synth | A bright unlocking sparkle arpeggio | MIT / In-house | Antigravity | 2026-09-09 |
| `sfx_free_play_toggle.wav` | Python synth | A light playful toggle chime | MIT / In-house | Antigravity | 2026-09-09 |

### 5. Nhạc cụ mộc 3 chương (Hướng 3 — Acoustic Sampling)

| Tên file | Nhạc cụ | Cao độ | Đặc tính âm thanh | Giấy phép | Tác giả | Ngày tạo |
|---|---|---|---|---|---|---|
| `flute_0_c4.wav` .. `flute_6_d5.wav` (7 files) | Sáo Trúc (Bamboo Flute) | C4, D4, E4, G4, A4, C5, D5 | Sóng mộc, breath chiff lọc thông dải 2.2kHz, vibrato 5Hz | MIT / In-house | Antigravity | 2026-09-10 |
| `kalimba_0_c4.wav` .. `kalimba_6_d5.wav` (7 files) | Đàn Kalimba (Thumb Piano) | C4, D4, E4, G4, A4, C5, D5 | Xung gõ phiến kim loại 12ms, họa âm phiến 5.8x, vang thùng gỗ 175Hz | MIT / In-house | Antigravity | 2026-09-10 |
| `chimes_0_c4.wav` .. `chimes_6_d5.wav` (7 files) | Chuông Gió & Celesta (Wind Chimes) | C4, D4, E4, G4, A4, C5, D5 | Búa gõ pha lê, chùm họa âm ống kim loại (1.0, 2.76, 5.4, 8.9), beating chorus | MIT / In-house | Antigravity | 2026-09-10 |

---

### 6. Nhạc Nền 10 Bài Hát Thiếu Nhi (Songbook - In-house Acoustic Synth)

Đặt tại: `assets/audio/songbook/` · Âm lượng chuẩn `-18 dBFS` · OGG Vorbis Stereo Seamless Loop.

| Tên file | Bài hát | Nhịp | Vòng hợp âm | Giấy phép | Tác giả | Ngày tạo |
|---|---|---|---|---|---|---|
| `bgm_main_menu_theme.ogg` | "Kỳ Diệu Rừng Nhạc" (Main Menu Theme) | 84 BPM | C Maj9 - F Maj7 - Am9 - Gsus4 (Harp, Celesta, Marimba, Flute) | MIT / In-house | Antigravity | 2026-09-11 |
| `bgm_baby_shark.ogg` | Baby Shark | 85 BPM | C - C - Am - F (Ukulele & Marimba) | MIT / In-house | Antigravity | 2026-09-11 |
| `bgm_wheels_on_the_bus.ogg` | The Wheels on the Bus | 80 BPM | C - G - C - C (Bouncing Pizzicato) | MIT / In-house | Antigravity | 2026-09-11 |
| `bgm_johny_johny.ogg` | Johny Johny Yes Papa | 76 BPM | C - G - C - G (Music Box & Guitar) | MIT / In-house | Antigravity | 2026-09-11 |
| `bgm_twinkle_twinkle.ogg` | Twinkle Twinkle Little Star | 68 BPM | C - F - C - G (Celesta & Concert Harp) | MIT / In-house | Antigravity | 2026-09-11 |
| `bgm_if_youre_happy.ogg` | If You're Happy and You Know It | 84 BPM | C - G - C - G (Happy Kalimba & Rhythm) | MIT / In-house | Antigravity | 2026-09-11 |
| `bgm_old_macdonald.ogg` | Old MacDonald Had a Farm | 82 BPM | C - F - C - G (Rustic Folk Guitar) | MIT / In-house | Antigravity | 2026-09-11 |
| `bgm_abc_song.ogg` | ABC Song | 70 BPM | C - F - C - G (Lullaby Bells & Piano) | MIT / In-house | Antigravity | 2026-09-11 |
| `bgm_baa_baa_black_sheep.ogg` | Baa Baa Black Sheep | 72 BPM | C - F - C - G (Pastoral Flute & Pad) | MIT / In-house | Antigravity | 2026-09-11 |
| `bgm_five_little_monkeys.ogg` | Five Little Monkeys | 80 BPM | C - G - C - G (Cheeky Marimba & Bass) | MIT / In-house | Antigravity | 2026-09-11 |
| `bgm_heads_shoulders.ogg` | Heads, Shoulders, Knees and Toes | 86 BPM | C - G - C - G (Playful Tines & Ukulele) | MIT / In-house | Antigravity | 2026-09-11 |



