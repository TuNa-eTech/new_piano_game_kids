#!/usr/bin/env python3
"""
gen_master_main_theme.py
BẢN NHẠC NỀN MAIN MENU NÂNG CẤP ĐỈNH CAO:
"Vũ Điệu Muông Thú Rừng Nhạc" (The Animal Forest Swing Overture)

Học hỏi từ các tiêu chuẩn thiết kế âm thanh hàng đầu thế giới:
- Toca Boca & Sago Mini: Nhạc cụ đồ chơi mộc (Acoustic Toy Band), rộn rã, xúc giác tự nhiên.
- Nintendo (Yoshi's Island & Animal Crossing): Nhịp điệu Swing/Shuffle vui tươi,
  kỹ thuật Gọi–Đáp (Call & Response) lồng ghép ngay trong giai điệu.
- Cocomelon & Super Simple Songs: Giai điệu Đô Trưởng trong sáng, dễ thuộc, trẻ con lắc lư ngay.

Cấu trúc 16 Ô Nhịp Hoàn Chỉnh (34.29 giây @ 112 BPM Swing):
- Đoạn A (Ô 1-4): Tiếng Toy Piano & Ukulele dạo khúc ca chào đón rộn ràng
- Đoạn B (Ô 5-8): Giai điệu biến tấu tinh nghịch, Sáo Trúc và Marimba đối đáp
- Đoạn A' (Ô 9-12): Điệp khúc cao trào, vỗ tay và chuông vàng Celesta hòa tấu rực rỡ
- Đoạn C (Ô 13-16): Khúc kết ngập tràn bụi sao lấp lánh, dẫn về vòng lặp 100% liền mạch
"""

import math
import os
import struct
import subprocess
import wave

SAMPLE_RATE = 44100
A4 = 440.0
BPM = 112.0
BARS = 16
BEATS_PER_BAR = 4
TOTAL_BEATS = BARS * BEATS_PER_BAR  # 64 beats
LOOP_SECONDS = (TOTAL_BEATS * 60.0) / BPM  # 34.2857142857 s
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

# Hàm tính thời gian có độ nhún Swing (Shuffle Feel 60:40)
def swing_time(beat_float: float) -> float:
    base_beat = int(beat_float)
    frac = beat_float - base_beat
    if frac < 0.001:
        swung_frac = 0.0
    elif abs(frac - 0.5) < 0.05:
        # Nốt nửa phách bị trễ nhẹ theo nhịp swing (tạo độ nảy chân sáo)
        swung_frac = 0.58
    else:
        swung_frac = frac
    return (base_beat + swung_frac) * BEAT_DUR

# 16 Ô NHỊP HÒA ÂM TƯƠI SÁNG (C Major / F Major / G7)
# Walking Bass theo từng phách: [Beat 1, Beat 2, Beat 3, Beat 4]
CHORD_SHEET = [
    # --- ĐOẠN A: CHÀO ĐÓN RỪNG THẦN ---
    ("C",  ["C3", "E3", "G2", "B2"], ["E3", "G3", "C4"]),
    ("F",  ["F2", "A2", "C3", "E3"], ["F3", "A3", "C4"]),
    ("G7", ["G2", "B2", "D3", "F3"], ["F3", "G3", "B3"]),
    ("C",  ["C3", "G2", "E3", "D3"], ["E3", "G3", "C4"]),

    # --- ĐOẠN B: MUÔNG THÚ CHẠY NHẢY ---
    ("C",  ["C3", "E3", "G2", "C3"], ["E3", "G3", "C4"]),
    ("F",  ["F2", "A2", "C3", "A2"], ["F3", "A3", "C4"]),
    ("G7", ["G2", "D3", "B2", "D3"], ["F3", "G3", "B3"]),
    ("C",  ["C3", "E3", "G2", "B2"], ["E3", "G3", "C4"]),

    # --- ĐOẠN A': ĐIỆP KHÚC CAO TRÀO ---
    ("C",  ["C3", "G2", "C3", "E3"], ["E3", "G3", "C4"]),
    ("F",  ["F2", "C3", "F2", "A2"], ["F3", "A3", "C4"]),
    ("G7", ["G2", "D3", "G2", "B2"], ["F3", "G3", "B3"]),
    ("C",  ["C3", "E3", "G2", "C3"], ["E3", "G3", "C4"]),

    # --- ĐOẠN C: BÙNG NỔ BỤI SAO & KẾT VÒNG LẶP ---
    ("F",  ["F2", "A2", "C3", "F3"], ["F3", "A3", "C4"]),
    ("C",  ["E3", "G3", "C3", "E3"], ["E3", "G3", "C4"]),
    ("G7", ["D3", "F3", "G2", "B2"], ["F3", "G3", "B3"]),
    ("C",  ["C3", "G2", "C3", "G2"], ["E3", "G3", "C4"]),
]

# GIAI ĐIỆU CHÍNH (TOY PIANO & GLOCKENSPIEL LEAD)
LEAD_MELODY = [
    # Đoạn A: (beat, dur, note)
    (0.0, 0.5, "C4"), (0.5, 0.5, "E4"), (1.0, 0.5, "G4"), (1.5, 0.5, "A4"),
    (2.0, 1.0, "G4"), (3.0, 1.0, "E4"),
    (4.0, 0.5, "F4"), (4.5, 0.5, "A4"), (5.0, 1.0, "C5"),
    (6.0, 1.0, "A4"), (7.0, 1.0, "F4"),
    (8.0, 0.5, "D4"), (8.5, 0.5, "F4"), (9.0, 0.5, "G4"), (9.5, 0.5, "B4"),
    (10.0, 1.0, "D5"), (11.0, 1.0, "B4"),
    (12.0, 1.0, "C5"), (13.0, 0.5, "G4"), (13.5, 0.5, "E4"),
    (14.0, 1.5, "C4"), (15.5, 0.5, "G4"),

    # Đoạn B: Nảy nhịp đối đáp vui tươi
    (16.0, 0.5, "E4"), (16.5, 0.5, "G4"), (17.0, 0.5, "C5"), (17.5, 0.5, "E5"),
    (18.0, 1.0, "D5"), (19.0, 1.0, "C5"),
    (20.0, 0.5, "A4"), (20.5, 0.5, "C5"), (21.0, 0.5, "D5"), (21.5, 0.5, "E5"),
    (22.0, 1.0, "D5"), (23.0, 1.0, "G4"),
    (24.0, 0.5, "E4"), (24.5, 0.5, "G4"), (25.0, 0.5, "C5"), (25.5, 0.5, "E5"),
    (26.0, 1.0, "D5"), (27.0, 1.0, "C5"),
    (28.0, 0.5, "G4"), (28.5, 0.5, "A4"), (29.0, 0.5, "B4"), (29.5, 0.5, "D5"),
    (30.0, 2.0, "C5"),

    # Đoạn A': Điệp khúc cao trào rộn ràng
    (32.0, 0.5, "E5"), (32.5, 0.5, "D5"), (33.0, 0.5, "C5"), (33.5, 0.5, "A4"),
    (34.0, 1.0, "G4"), (35.0, 1.0, "E4"),
    (36.0, 0.5, "F4"), (36.5, 0.5, "G4"), (37.0, 0.5, "A4"), (37.5, 0.5, "C5"),
    (38.0, 1.0, "D5"), (39.0, 1.0, "G4"),
    (40.0, 0.5, "E5"), (40.5, 0.5, "D5"), (41.0, 0.5, "C5"), (41.5, 0.5, "B4"),
    (42.0, 1.0, "A4"), (43.0, 1.0, "G4"),
    (44.0, 0.5, "C4"), (44.5, 0.5, "E4"), (45.0, 0.5, "G4"), (45.5, 0.5, "D5"),
    (46.0, 2.0, "C5"),

    # Đoạn C: Khúc kết bùng nổ hoa lệ
    (48.0, 0.5, "A4"), (48.5, 0.5, "C5"), (49.0, 0.5, "E5"), (49.5, 0.5, "F5"),
    (50.0, 1.0, "E5"), (51.0, 1.0, "C5"),
    (52.0, 0.5, "G4"), (52.5, 0.5, "C5"), (53.0, 0.5, "E5"), (53.5, 0.5, "G5"),
    (54.0, 1.0, "F5"), (55.0, 1.0, "D5"),
    (56.0, 0.5, "B4"), (56.5, 0.5, "D5"), (57.0, 0.5, "F5"), (57.5, 0.5, "A5"),
    (58.0, 1.0, "G5"), (59.0, 1.0, "D5"),
    (60.0, 0.5, "E5"), (60.5, 0.5, "D5"), (61.0, 0.5, "C5"), (61.5, 0.5, "D5"),
    (62.0, 2.0, "C5"),
]

# CÂU ĐÁP SÁO TRÚC & CHUÔNG CELESTA (CALL & RESPONSE - NINTENDO / TOCA STYLE)
COUNTER_CHIRPS = [
    (3.0, 0.25, "G5"), (3.25, 0.25, "E5"), (3.5, 0.5, "C5"),
    (7.0, 0.25, "A5"), (7.25, 0.25, "F5"), (7.5, 0.5, "C5"),
    (11.0, 0.25, "B5"), (11.25, 0.25, "G5"), (11.5, 0.5, "D5"),
    (19.0, 0.25, "E5"), (19.25, 0.25, "G5"), (19.5, 0.5, "C6"),
    (23.0, 0.25, "D5"), (23.25, 0.25, "F5"), (23.5, 0.5, "B5"),
    (35.0, 0.25, "G5"), (35.25, 0.25, "E5"), (35.5, 0.5, "C5"),
    (39.0, 0.25, "A5"), (39.25, 0.25, "F5"), (39.5, 0.5, "D5"),
    (43.0, 0.25, "B5"), (43.25, 0.25, "G5"), (43.5, 0.5, "E5"),
]

def synthesize():
    num_samples = int(SAMPLE_RATE * LOOP_SECONDS)
    print(f"Tổng hợp Bản Giao Hưởng Thiếu Nhi 16 Bars ({LOOP_SECONDS:.2f}s, {BPM} BPM Swing)...")

    left = [0.0] * num_samples
    right = [0.0] * num_samples

    # =========================================================================
    # 1. WALKING BASS NẢY TƯNG BỪNG (ACOUSTIC PIZZICATO BASS - 4 PHÁCH MỖI BAR)
    # =========================================================================
    for bar_idx in range(BARS):
        bass_line = CHORD_SHEET[bar_idx][1]
        for b_in_bar, note_name in enumerate(bass_line):
            beat_float = bar_idx * 4 + b_in_bar
            start_t = swing_time(beat_float)
            fn = quantize(note_hz(note_name))
            start_s = int(start_t * SAMPLE_RATE)
            dur_s = int(0.52 * SAMPLE_RATE)

            for s in range(dur_s):
                idx = (start_s + s) % num_samples
                local_t = s / SAMPLE_RATE
                decay = math.exp(-local_t * 7.5)
                # Bouncy upright bass
                bass_wave = decay * (
                    1.00 * math.sin(2 * math.pi * fn * local_t) +
                    0.55 * math.sin(2 * math.pi * fn * 2.0 * local_t) +
                    0.18 * math.sin(2 * math.pi * fn * 3.0 * local_t)
                )
                # Đặt hơi nghiêng phải (45% L, 55% R)
                left[idx] += bass_wave * 0.20 * 0.45
                right[idx] += bass_wave * 0.20 * 0.55

    # =========================================================================
    # 2. ĐỆM UKULELE & GUITAR CHOP "CHÁCH - CHÁCH" (PHÁCH 2 & 4 SWING)
    # =========================================================================
    for bar_idx in range(BARS):
        chord_triad = CHORD_SHEET[bar_idx][2]
        chord_freqs = [quantize(note_hz(n)) for n in chord_triad]

        for off_beat in [1, 3]: # Phách 2 và 4
            beat_float = bar_idx * 4 + off_beat
            start_t = swing_time(beat_float)
            start_s = int(start_t * SAMPLE_RATE)
            dur_s = int(0.38 * SAMPLE_RATE)

            for s in range(dur_s):
                idx = (start_s + s) % num_samples
                local_t = s / SAMPLE_RATE
                decay = math.exp(-local_t * 11.0)
                chop_sum = 0.0
                for fn in chord_freqs:
                    chop_sum += (
                        1.0 * math.sin(2 * math.pi * fn * local_t) +
                        0.4 * math.sin(2 * math.pi * fn * 2.0 * local_t)
                    )
                sig = decay * chop_sum * 0.075
                # Pan Trái 35% (65% L, 35% R)
                left[idx] += sig * 0.65
                right[idx] += sig * 0.35

    # =========================================================================
    # 3. BỘ GÕ MẦM NON (HANDCLAPS TRÊN 2&4, WOODBLOCK & SHAKER NẢY NHỊP)
    # =========================================================================
    for b_idx in range(TOTAL_BEATS):
        start_t = swing_time(b_idx)
        start_s = int(start_t * SAMPLE_RATE)

        # A. Tiếng mõ gỗ tinh nghịch (Woodblock)
        wb_freq = 780.0 if (b_idx % 2 == 0) else 1200.0
        wb_dur = int(0.07 * SAMPLE_RATE)
        for s in range(wb_dur):
            idx = (start_s + s) % num_samples
            local_t = s / SAMPLE_RATE
            wb_env = math.exp(-local_t * 48.0)
            sig = wb_env * math.sin(2 * math.pi * wb_freq * local_t) * 0.08
            left[idx] += sig * 0.40
            right[idx] += sig * 0.60

        # B. Tiếng vỗ tay trẻ thơ (Handclap) ở phách 2 và 4
        if (b_idx % 4) in [1, 3]:
            clap_dur = int(0.12 * SAMPLE_RATE)
            for s in range(clap_dur):
                idx = (start_s + s) % num_samples
                local_t = s / SAMPLE_RATE
                clap_env = math.exp(-local_t * 28.0)
                # Mô phỏng tiếng vỗ tay bằng đa tần số mộc
                clap_sig = clap_env * (
                    math.sin(2 * math.pi * 1100 * local_t) * 0.5 +
                    math.sin(2 * math.pi * 1850 * local_t) * 0.4 +
                    math.sin(2 * math.pi * 2600 * local_t) * 0.3
                ) * 0.07
                left[idx] += clap_sig * 0.50
                right[idx] += clap_sig * 0.50

        # C. Tiếng xúc xắc Shaker nảy ở nhịp swing
        shk_t = swing_time(b_idx + 0.5)
        shk_s = int(shk_t * SAMPLE_RATE)
        shk_dur = int(0.06 * SAMPLE_RATE)
        for s in range(shk_dur):
            idx = (shk_s + s) % num_samples
            local_t = s / SAMPLE_RATE
            shk_env = math.exp(-local_t * 45.0)
            shk_sig = shk_env * (
                math.sin(2 * math.pi * 3600 * local_t) +
                math.sin(2 * math.pi * 5200 * local_t) * 0.7
            ) * 0.035
            left[idx] += shk_sig * 0.55
            right[idx] += shk_sig * 0.45

    # =========================================================================
    # 4. GIAI ĐIỆU CHÍNH (TOY PIANO + GLOCKENSPIEL LEAD - ĐANH GIÒN, RÕ NÉT)
    # =========================================================================
    for b_time, dur_beats, n_str in LEAD_MELODY:
        start_t = swing_time(b_time)
        dur_sec = dur_beats * BEAT_DUR
        fn = quantize(note_hz(n_str))

        start_s = int(start_t * SAMPLE_RATE)
        dur_s = int(max(dur_sec, 0.48) * SAMPLE_RATE)

        for s in range(dur_s):
            idx = (start_s + s) % num_samples
            local_t = s / SAMPLE_RATE

            if local_t < 0.005:
                env = local_t / 0.005
            else:
                env = math.exp(-(local_t - 0.005) * 3.4)

            # Âm sắc Toy Piano + Glockenspiel mạ vàng
            lead_wave = env * (
                1.00 * math.sin(2 * math.pi * fn * local_t) +
                0.55 * math.sin(2 * math.pi * fn * 2.0 * local_t) +
                0.28 * math.sin(2 * math.pi * fn * 3.0 * local_t) +
                0.16 * math.sin(2 * math.pi * (fn * 2.76) * local_t) +
                0.08 * math.sin(2 * math.pi * fn * 4.0 * local_t)
            ) * 0.30
            # Center stage
            left[idx] += lead_wave * 0.50
            right[idx] += lead_wave * 0.50

    # =========================================================================
    # 5. CÂU ĐÁP SÁO TRÚC & CHUÔNG CELESTA (CALL & RESPONSE LẢNH LÓT)
    # =========================================================================
    for b_time, dur_beats, n_str in COUNTER_CHIRPS:
        start_t = swing_time(b_time)
        dur_sec = dur_beats * BEAT_DUR
        fn = quantize(note_hz(n_str))

        start_s = int(start_t * SAMPLE_RATE)
        dur_s = int(0.40 * SAMPLE_RATE)

        # Panning lượn từ trái qua phải tạo hiệu ứng đom đóm/bụi sao
        pan_factor = 0.5 + 0.35 * math.sin(b_time * 0.8)

        for s in range(dur_s):
            idx = (start_s + s) % num_samples
            local_t = s / SAMPLE_RATE
            chirp_env = math.exp(-local_t * 7.5)
            # Sáo chim / chuông gió trong veo
            chirp_wave = chirp_env * (
                1.00 * math.sin(2 * math.pi * fn * local_t) +
                0.35 * math.sin(2 * math.pi * fn * 2.0 * local_t) +
                0.20 * math.sin(2 * math.pi * (fn * 2.76) * local_t)
            ) * 0.16

            left[idx] += chirp_wave * pan_factor
            right[idx] += chirp_wave * (1.0 - pan_factor)

    # =========================================================================
    # 6. MASTERING & NORMALIZE VỀ CHUẨN ĐỈNH STUDIO -1.4 dBFS (0.85)
    # =========================================================================
    peak = 0.0
    for i in range(num_samples):
        peak = max(peak, abs(left[i]), abs(right[i]))

    TARGET_PEAK = 0.85
    norm = TARGET_PEAK / peak if peak > 0 else 1.0
    print(f"Peak ban đầu: {peak:.3f} -> Chuẩn hóa về -1.4 dBFS (Hệ số: {norm:.3f})")

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
    print(f" HOÀN TẤT NÂNG CẤP BẢN GIAO HƯỞNG THIẾU NHI 16 BARS ĐỈNH CAO:")
    print(f" -> {ogg_path}")
    print(f" Kích thước: {size_kb} KB | Thời lượng: {LOOP_SECONDS:.2f}s | Nhịp: {BPM} BPM Swing")
    print("==================================================================")

if __name__ == "__main__":
    main()
