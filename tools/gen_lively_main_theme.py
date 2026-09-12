#!/usr/bin/env python3
"""
gen_lively_main_theme.py
Bản nhạc nền Main Menu mới: RỘN RÀNG, VUI TƯƠI, SÁNG BỪNG (Sunny Preschool Song).

Khắc phục triệt để cảm giác "u ám":
- BỎ HOÀN TOÀN pad ngân u ám, bỏ hợp âm thứ Am9/Em7 buồn bã.
- Nhịp điệu: 112 BPM tươi vui, nẩy tưng bừng (Upbeat Preschool Bounce).
- Phối khí chuẩn nhạc thiếu nhi hoạt hình (Cartoon Nursery Band):
  1. Giai điệu Lead (Toy Piano & Glockenspiel): Bắt tai, rõ từng câu nốt nhạc thiếu nhi, đanh giòn.
  2. Đệm nhịp (Ukulele / Guitar Chops): Chặt nhịp "chách... chách..." ở phách 2 và 4.
  3. Bass nảy (Oom-Pah Bass): Nốt gốc ở phách 1, nốt bậc năm ở phách 3 (nhảy chân sáo).
  4. Bộ gõ gỗ (Woodblock & Shaker): Lách cách vui tai, tạo sự hào hứng cho trẻ.
- Vòng hợp âm C Major thuần khiết: C - F - G - C | C - Am - Dm - G7 - C.
- Vòng lặp: 100% Seamless Loop toán học, 8 bars @ 112 BPM = 17.143 giây.
"""

import math
import os
import struct
import subprocess
import wave

SAMPLE_RATE = 44100
A4 = 440.0
BPM = 112.0
BARS = 8
BEATS_PER_BAR = 4
TOTAL_BEATS = BARS * BEATS_PER_BAR  # 32 beats
LOOP_SECONDS = (TOTAL_BEATS * 60.0) / BPM  # 17.14285714 s
BEAT_DUR = 60.0 / BPM  # ~0.5357 s

SEMITONE = {
    "C": -9, "C#": -8, "Db": -8,
    "D": -7, "D#": -6, "Eb": -6,
    "E": -5,
    "F": -4, "F#": -3, "Gb": -3,
    "G": -2, "G#": -1, "Ab": -1,
    "A": 0, "A#": 1, "Bb": 1,
    "B": 2
}

def note_hz(name: str) -> float:
    base = name[:-1]
    octave = int(name[-1])
    step = SEMITONE[base]
    return A4 * (2.0 ** (step / 12.0 + (octave - 4)))

def quantize(freq: float) -> float:
    k = max(1, round(freq * LOOP_SECONDS))
    return k / LOOP_SECONDS

# Vòng hợp âm 8 ô nhịp - 100% VUI TƯƠI, TRONG SÁNG (C Major Family)
# Bar 1: C Major  | Bar 2: F Major  | Bar 3: G7       | Bar 4: C Major
# Bar 5: C Major  | Bar 6: F Major  | Bar 7: G7sus4/G | Bar 8: C Major
CHORD_PROGRESSION = [
    # (Tên, Nốt Bass phách 1, Nốt Bass phách 3, Hợp âm phách 2 & 4)
    ("C",  "C3", "G2", ["E3", "G3", "C4", "E4"]),
    ("F",  "F2", "C3", ["F3", "A3", "C4", "F4"]),
    ("G7", "G2", "D3", ["F3", "G3", "B3", "D4"]),
    ("C",  "C3", "G2", ["E3", "G3", "C4", "E4"]),
    ("C",  "C3", "G2", ["E3", "G3", "C4", "E4"]),
    ("F",  "F2", "C3", ["F3", "A3", "C4", "F4"]),
    ("G7", "G2", "D3", ["F3", "G3", "B3", "D4"]),
    ("C",  "C3", "G2", ["E3", "G3", "C4", "E4"]),
]

# GIAI ĐIỆU CHÍNH (Catchy Preschool Melody)
# Danh sách nốt: (beat_index, duration_in_beats, note_name)
MELODY_NOTES = [
    # --- Đoạn 1: Rộn ràng mở đầu (Bar 1 & 2) ---
    (0.0, 0.5, "C4"), (0.5, 0.5, "E4"), (1.0, 0.5, "G4"), (1.5, 0.5, "A4"),
    (2.0, 1.0, "G4"), (3.0, 1.0, "E4"),
    (4.0, 0.5, "F4"), (4.5, 0.5, "A4"), (5.0, 1.0, "C5"),
    (6.0, 1.0, "A4"), (7.0, 1.0, "F4"),

    # --- Đoạn 2: Tung tăng nảy nhịp (Bar 3 & 4) ---
    (8.0, 0.5, "D4"), (8.5, 0.5, "F4"), (9.0, 0.5, "G4"), (9.5, 0.5, "B4"),
    (10.0, 1.0, "D5"), (11.0, 1.0, "B4"),
    (12.0, 1.0, "C5"), (13.0, 0.5, "G4"), (13.5, 0.5, "E4"),
    (14.0, 1.5, "C4"), (15.5, 0.5, "G4"),

    # --- Đoạn 3: Điệp khúc cao trào vui nhộn (Bar 5 & 6) ---
    (16.0, 0.5, "E5"), (16.5, 0.5, "D5"), (17.0, 0.5, "C5"), (17.5, 0.5, "A4"),
    (18.0, 1.0, "G4"), (19.0, 1.0, "E4"),
    (20.0, 0.5, "F4"), (20.5, 0.5, "G4"), (21.0, 0.5, "A4"), (21.5, 0.5, "C5"),
    (22.0, 1.0, "D5"), (23.0, 1.0, "G4"),

    # --- Đoạn 4: Kết câu rực rỡ chào đón (Bar 7 & 8) ---
    (24.0, 0.5, "E5"), (24.5, 0.5, "D5"), (25.0, 0.5, "C5"), (25.5, 0.5, "B4"),
    (26.0, 1.0, "A4"), (27.0, 1.0, "G4"),
    (28.0, 0.5, "C4"), (28.5, 0.5, "E4"), (29.0, 0.5, "G4"), (29.5, 0.5, "D5"),
    (30.0, 2.0, "C5"),
]

def synthesize():
    num_samples = int(SAMPLE_RATE * LOOP_SECONDS)
    print(f"Tổng hợp bản nhạc thiếu nhi rộn ràng ({LOOP_SECONDS:.2f}s, {BPM} BPM)...")

    left = [0.0] * num_samples
    right = [0.0] * num_samples

    # =========================================================================
    # 1. BASS NẢY "OOM - PAH" (PIZZICATO BASS - CHÂN SÁO VUI TƯƠI)
    # =========================================================================
    for bar_idx in range(BARS):
        chord_info = CHORD_PROGRESSION[bar_idx]
        bass_notes = [chord_info[1], chord_info[2]] # Phách 1 và Phách 3
        
        for p_idx, b_note in enumerate(bass_notes):
            beat_time = (bar_idx * 4 + p_idx * 2) * BEAT_DUR
            f_bass = quantize(note_hz(b_note))
            start_s = int(beat_time * SAMPLE_RATE)
            dur_s = int(0.55 * SAMPLE_RATE)
            
            for s in range(dur_s):
                idx = (start_s + s) % num_samples
                local_t = s / SAMPLE_RATE
                decay = math.exp(-local_t * 8.0)
                # Sóng âm bass ấm, nảy đanh
                sig = decay * (
                    1.00 * math.sin(2 * math.pi * f_bass * local_t) +
                    0.50 * math.sin(2 * math.pi * f_bass * 2.0 * local_t) +
                    0.15 * math.sin(2 * math.pi * f_bass * 3.0 * local_t)
                )
                # Center-Right (45% L, 55% R)
                left[idx] += sig * 0.22 * 0.45
                right[idx] += sig * 0.22 * 0.55

    # =========================================================================
    # 2. ĐỆM NHỊP UKULELE / GUITAR CHOP "CHÁCH - CHÁCH" (PHÁCH 2 VÀ 4)
    # =========================================================================
    for bar_idx in range(BARS):
        chord_notes = CHORD_PROGRESSION[bar_idx][3]
        chord_freqs = [quantize(note_hz(n)) for n in chord_notes]
        
        for off_beat in [1, 3]: # Phách 2 và 4 (0-indexed: 1, 3)
            beat_time = (bar_idx * 4 + off_beat) * BEAT_DUR
            start_s = int(beat_time * SAMPLE_RATE)
            dur_s = int(0.35 * SAMPLE_RATE)
            
            # Gảy chùm hợp âm ukulele
            for s in range(dur_s):
                idx = (start_s + s) % num_samples
                local_t = s / SAMPLE_RATE
                decay = math.exp(-local_t * 12.0) # Ngắt dứt khoát vui tai
                chop_val = 0.0
                for fn in chord_freqs:
                    chop_val += (
                        1.0 * math.sin(2 * math.pi * fn * local_t) +
                        0.4 * math.sin(2 * math.pi * fn * 2.0 * local_t)
                    )
                chop = decay * chop_val * 0.08
                # Pan Left 35% (65% L, 35% R)
                left[idx] += chop * 0.65
                right[idx] += chop * 0.35

    # =========================================================================
    # 3. BỘ GÕ GỖ LÁCH CÁCH (WOODBLOCK & SHAKER - RỘN RÃ)
    # =========================================================================
    for b_idx in range(TOTAL_BEATS):
        b_time = b_idx * BEAT_DUR
        start_s = int(b_time * SAMPLE_RATE)
        
        # Tiếng gõ gõ mộc (Woodblock) ở mỗi phách
        wb_dur = int(0.08 * SAMPLE_RATE)
        wb_freq = 820.0 if (b_idx % 2 == 0) else 1150.0
        for s in range(wb_dur):
            idx = (start_s + s) % num_samples
            local_t = s / SAMPLE_RATE
            wb_env = math.exp(-local_t * 45.0)
            wb_sig = wb_env * math.sin(2 * math.pi * wb_freq * local_t) * 0.09
            left[idx] += wb_sig * 0.40
            right[idx] += wb_sig * 0.60
            
        # Shaker nảy ở nửa phách (eighth note swing)
        shk_time = b_time + BEAT_DUR * 0.5
        shk_s = int(shk_time * SAMPLE_RATE)
        shk_dur = int(0.06 * SAMPLE_RATE)
        for s in range(shk_dur):
            idx = (shk_s + s) % num_samples
            local_t = s / SAMPLE_RATE
            shk_env = math.exp(-local_t * 50.0)
            # Giả lập hạt cát xào xạc bằng họa âm cao
            shk_sig = shk_env * (
                math.sin(2 * math.pi * 3200 * local_t) +
                math.sin(2 * math.pi * 4800 * local_t) * 0.7
            ) * 0.04
            left[idx] += shk_sig * 0.55
            right[idx] += shk_sig * 0.45

    # =========================================================================
    # 4. GIAI ĐIỆU CHÍNH (TOY PIANO + GLOCKENSPIEL - ĐANH GIÒN, TRONG TRẺO)
    # =========================================================================
    for b_time, dur_beats, n_str in MELODY_NOTES:
        start_t = b_time * BEAT_DUR
        dur_sec = dur_beats * BEAT_DUR
        fn = quantize(note_hz(n_str))
        
        start_s = int(start_t * SAMPLE_RATE)
        dur_s = int(max(dur_sec, 0.45) * SAMPLE_RATE)
        
        for s in range(dur_s):
            idx = (start_s + s) % num_samples
            local_t = s / SAMPLE_RATE
            
            # Envelope nốt đàn: Attack đanh 6ms, decay tự nhiên
            if local_t < 0.006:
                env = local_t / 0.006
            else:
                env = math.exp(-(local_t - 0.006) * 3.6)
                
            # Chuông Glockenspiel (Họa âm kim loại sáng bóng) + Toy Piano
            tone = (
                1.00 * math.sin(2 * math.pi * fn * local_t) +
                0.55 * math.sin(2 * math.pi * fn * 2.0 * local_t) +
                0.28 * math.sin(2 * math.pi * fn * 3.0 * local_t) +
                0.16 * math.sin(2 * math.pi * (fn * 2.76) * local_t) +  # Chùm chuông pha lê
                0.08 * math.sin(2 * math.pi * fn * 4.0 * local_t)
            )
            lead = env * tone * 0.32
            # Center stage nổi bật (50% L, 50% R)
            left[idx] += lead * 0.50
            right[idx] += lead * 0.50

    # =========================================================================
    # 5. MASTERING: NORMALIZE VỀ CHUẨN STUDIO PEAK -1.5 dBFS (0.84)
    # =========================================================================
    peak = 0.0
    for i in range(num_samples):
        peak = max(peak, abs(left[i]), abs(right[i]))

    TARGET_PEAK = 0.84
    norm = TARGET_PEAK / peak if peak > 0 else 1.0
    print(f"Peak ban đầu: {peak:.3f} -> Chuẩn hóa về -1.5 dBFS (Hệ số: {norm:.3f})")

    stereo_pcm = bytearray()
    for i in range(num_samples):
        l_val = int(max(-1.0, min(1.0, left[i] * norm)) * 32767)
        r_val = int(max(-1.0, min(1.0, right[i] * norm)) * 32767)
        stereo_pcm += struct.pack("<hh", l_val, r_val)

    return stereo_pcm

def make_godot_ogg_import(ogg_path: str):
    import_path = f"{ogg_path}.import"
    rel_path = ogg_path.replace("/Users/anhtu/MySpace/new-piano/", "").replace("./", "")
    filename = os.path.basename(ogg_path)
    base_no_ext = filename.replace(".ogg", "")

    content = f"""[remap]

importer="oggvorbisstr"
type="AudioStreamOggVorbis"
uid="uid://{rel_path.replace('/', '_').replace('.', '_')}"
path="res://.godot/imported/{filename}-{base_no_ext}.oggvorbisstr"

[deps]

source_file="res://{rel_path}"
dest_files=["res://.godot/imported/{filename}-{base_no_ext}.oggvorbisstr"]

[params]

loop=true
loop_offset=0
bpm={BPM}
beat_count={TOTAL_BEATS}
bar_beats=4
"""
    with open(import_path, 'w', encoding='utf-8') as f:
        f.write(content)

def main():
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    out_dir = os.path.join(repo_root, "assets", "audio")
    os.makedirs(out_dir, exist_ok=True)

    wav_path = os.path.join(out_dir, "bgm_main_menu_theme.wav")
    ogg_path = os.path.join(out_dir, "bgm_main_menu_theme.ogg")

    pcm_data = synthesize()

    with wave.open(wav_path, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        w.writeframes(pcm_data)

    print("Mã hóa sang OGG Vorbis Stereo bằng ffmpeg...")
    cmd = [
        "/opt/homebrew/bin/ffmpeg", "-y",
        "-i", wav_path,
        "-ac", "2",
        "-c:a", "vorbis",
        "-strict", "-2",
        ogg_path
    ]
    subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)

    if os.path.exists(wav_path):
        os.remove(wav_path)

    make_godot_ogg_import(ogg_path)

    size_kb = os.path.getsize(ogg_path) // 1024
    print("==================================================================")
    print(f" ĐÃ TẠO XONG BẢN NHẠC THIẾU NHI RỘN RÀNG:")
    print(f" -> {ogg_path}")
    print(f" Kích thước: {size_kb} KB | Thời lượng: {LOOP_SECONDS:.2f}s | Nhịp: {BPM} BPM (Vui tươi, nảy tưng bừng!)")
    print("==================================================================")

if __name__ == "__main__":
    main()
