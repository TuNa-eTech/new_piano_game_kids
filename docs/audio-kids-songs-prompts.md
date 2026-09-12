# Sổ Tay Prompt AI Âm Thanh Cho 10 Bài Hát Thiếu Nhi
*(Cập nhật: 2026-09-11 · Hướng dẫn thực hành cho Suno v4, Udio, ElevenLabs & Bark)*

Tài liệu này chứa toàn bộ prompt đã được chuẩn hóa để sinh âm thanh cho 10 bài hát thiếu nhi trong game đàn piano cho bé (`new-piano`).

---

## 1. Nguyên Tắc Cốt Lõi Khi Sinh Âm Thanh Thiếu Nhi Bằng AI

1. **Âm thanh mộc mạc, nhẹ nhàng (Preschool / Storybook Aesthetic):**
   - Luôn sử dụng từ khóa: `gentle acoustic`, `warm ukulele`, `soft harp`, `music box`, `celesta`, `storybook nursery rhyme`, `calm bedtime`.
   - **Tuyệt đối tránh:** `EDM, heavy synth, distorted bass, trap drums, loud cymbals, sudden drops`.
2. **Âm lượng và Nhịp điệu (Tempo & Mixing):**
   - Tempo lý tưởng cho trẻ 1-6 tuổi: **68 BPM – 86 BPM** (nhịp thong thả, trẻ dễ bắt chước).
   - Âm lượng backing track trong game luôn đặt ở **−18 dBFS** (để khi bé bấm đàn, tiếng nốt đàn ở −3 dBFS luôn nổi bật, trong trẻo).
3. **Giọng hát AI (Voice Prompts):**
   - Tránh giọng người lớn quá kịch tính hoặc opera.
   - Ưu tiên: `warm motherly voice`, `friendly cartoon character humming`, `clear bedtime storytelling tone`.

---

## 2. Bảng Prompt Chi Tiết Cho 10 Bài Hát (Suno / Udio)

Dán trực tiếp đoạn prompt vào chế độ **Custom Mode** (Bật `Instrumental` cho BGM, tắt `Instrumental` nếu muốn sinh giọng hát mẫu).

### 1. Baby Shark
* **Phong cách:** Ukulele & Marimba vui nhộn, ấm áp
* **Tempo:** 85 BPM · **Tone:** C Major
```text
[Prompt]
Gentle acoustic preschool nursery rhyme, soft sunny ukulele strumming, warm marimba tines, light wooden shaker, 85 BPM, key of C major, playful and cozy, toddler storybook music, no EDM, no harsh drums, clean mix, seamless loop.
[Style Tags]
Acoustic, Ukulele, Nursery Rhyme, Toddler, Warm, Instrumental
```

### 2. The Wheels on the Bus
* **Phong cách:** Bouncing Pizzicato Strings & Xylophone
* **Tempo:** 80 BPM · **Tone:** C Major
```text
[Prompt]
Playful gentle acoustic children's song, bouncing pizzicato cello and violin, soft wooden xylophone, warm acoustic guitar, happy toddler afternoon, 80 BPM, key of C major, rounded tone, no loud percussion, cozy preschool storybook feel.
[Style Tags]
Pizzicato, Xylophone, Playful, Storybook, Acoustic, Instrumental
```

### 3. Johny Johny Yes Papa
* **Phong cách:** Music Box & Thư thái ru ngủ
* **Tempo:** 76 BPM · **Tone:** C Major
```text
[Prompt]
Whimsical music box and gentle classical guitar, soft kalimba arpeggios, chord progression C - G - Am - F, 76 BPM, bedtime nursery rhyme, warm and comforting, peaceful preschool music, no drums, no sudden hits.
[Style Tags]
Music Box, Kalimba, Acoustic Guitar, Bedtime Lullaby, Instrumental
```

### 4. Twinkle Twinkle Little Star
* **Phong cách:** Celesta & Đàn Hạc (Harp) Lấp Lánh
* **Tempo:** 68 BPM · **Tone:** C Major
```text
[Prompt]
Dreamy celestial nursery lullaby, soft sparkling celesta bells, glockenspiel, warm concert harp arpeggios, gentle ambient string pad, 68 BPM, key of C major, peaceful starry bedtime atmosphere, calm and soothing, no drums.
[Style Tags]
Celesta, Harp, Glockenspiel, Dreamy Lullaby, Bedtime, Instrumental
```

### 5. If You're Happy and You Know It
* **Phong cách:** Happy Kalimba & Gõ Gỗ Nhẹ
* **Tempo:** 84 BPM · **Tone:** C Major
```text
[Prompt]
Happy acoustic preschool song, bouncy thumb piano kalimba, light acoustic rhythm guitar, wooden claves, cheerful toddler playtime, 84 BPM, key of C major, bright and friendly, no loud snare, warm low end.
[Style Tags]
Kalimba, Acoustic Guitar, Cheerful, Toddler, Playtime, Instrumental
```

### 6. Old MacDonald Had a Farm
* **Phong cách:** Rustic Folk Trẻ Em (Guitar mộc & Banjo dịu)
* **Tempo:** 82 BPM · **Tone:** C Major
```text
[Prompt]
Gentle rustic acoustic folk for kids, soft fingerpicked acoustic guitar, mellow banjo plucks, wooden percussion shaker, sunny barnyard morning, 82 BPM, key of C major, friendly and calm, preschool storybook.
[Style Tags]
Folk, Acoustic Guitar, Friendly, Kids Country, Instrumental
```

### 7. ABC Song
* **Phong cách:** Lullaby Bells & Piano Trẻ Em
* **Tempo:** 70 BPM · **Tone:** C Major
```text
[Prompt]
Gentle educational alphabet lullaby, warm upright piano, soft music box chimes, floating violin pad, 70 BPM, key of C major, sweet and patient, preschool learning atmosphere, peaceful and round sound.
[Style Tags]
Upright Piano, Chimes, Educational, Gentle Lullaby, Instrumental
```

### 8. Baa Baa Black Sheep
* **Phong cách:** Sáo Gỗ & Dây Trầm Êm Dịu
* **Tempo:** 72 BPM · **Tone:** C Major
```text
[Prompt]
Soft pastoral nursery rhyme, gentle wooden recorder flute, acoustic nylon guitar, warm cello accompaniment, 72 BPM, key of C major, peaceful countryside pasture, calm toddler music, no drums.
[Style Tags]
Woodwind, Nylon Guitar, Pastoral, Warm Cello, Lullaby, Instrumental
```

### 9. Five Little Monkeys
* **Phong cách:** Cheeky Wood & Marimba Nhí Nhảnh
* **Tempo:** 80 BPM · **Tone:** C Major
```text
[Prompt]
Cheeky bouncing acoustic groove for toddlers, wooden marimba, playful double bass pizzicato, soft woodblock, light triangle chime, 80 BPM, key of C major, funny and cozy, bedtime nursery rhyme, no synth.
[Style Tags]
Marimba, Woodblock, Playful, Pizzicato, Kids, Instrumental
```

### 10. Heads, Shoulders, Knees and Toes
* **Phong cách:** Playful Tines & Ukulele Vận Động
* **Tempo:** 86 BPM · **Tone:** C Major
```text
[Prompt]
Playful motion song for preschoolers, cheerful ukulele strum, bright glockenspiel tines, light shaker, 86 BPM, key of C major, inviting movement and laughter, warm and clear audio, gentle high frequencies.
[Style Tags]
Ukulele, Glockenspiel, Movement Song, Preschool, Happy, Instrumental
```

---

## 3. Bộ Prompt Giọng Hát Mẫu (Voice Guides / Vocals)
Dùng với **ElevenLabs** (Voice Library: `Motherly / Female Warm Narration` hoặc `Cartoon Kid`) hoặc **Suno Custom Mode** (chọn `Vocal`):

### Cấu trúc Prompt:
```text
A gentle, smiling motherly voice singing [SONG_NAME] with soft syllables 'la la la' or simple clear words, 76 BPM, clean vocal, close condenser mic, zero reverb, dry vocal stem, intimate bedtime lullaby style.
```

Ví dụ cho bài Baby Shark:
```text
Lyrics:
"Ba-by shark, doo-doo, doo-doo, doo-doo.
Mom-my shark, doo-doo, doo-doo, doo-doo.
Dad-dy shark, doo-doo, doo-doo, doo-doo.
Ba-by shark!"
```

---

## 4. Quy Trình Xử Lý Hậu Kỳ (Post-Processing Commands)

Khi tải file từ AI về, dùng `ffmpeg` để chuẩn hóa trước khi đưa vào thư mục `assets/audio/songbook/`:

```bash
# 1. Cắt khoảng lặng đầu (Attack < 10ms)
ffmpeg -i input.wav -af "silenceremove=start_periods=1:start_duration=0.01:start_threshold=-50dB" trimmed.wav

# 2. Chuẩn hóa âm lượng về -18 dBFS (cho BGM)
ffmpeg -i trimmed.wav -filter:a "volume=-18dB" -c:a libvorbis -q:a 4 bgm_song_normalized.ogg

# 3. Chuẩn hóa âm lượng về -6 dBFS (cho Giọng hát mẫu)
ffmpeg -i trimmed.wav -filter:a "volume=-6dB" -c:a pcm_s16le voice_guide.wav
```
