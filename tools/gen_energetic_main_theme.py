#!/usr/bin/env python3
"""
gen_energetic_main_theme.py
BẢN NHẠC NỀN SÔI ĐỘNG BÙNG NỔ NGAY TỪ GIÂY ĐẦU TIÊN:
"Đại Nhạc Hội Rừng Xanh Rực Rỡ" (The High-Energy Forest Carnival Fanfare)

Cải tiến vượt bậc:
1. Mở màn bùng nổ ngay từ giây đầu tiên (Explosive Beat 0 Fanfare):
   - Hợp âm kèn đồng mạ vàng đại tấu (7-voice Brass Fanfare Tutti Hit: C3-G3-C4-E4-G4-C5-E5)
   - Tiếng vuốt chuông sao lấp lánh (12-note Fairy Chime Glissando C4 -> G6)
   - Tiếng chũm chọe vàng tung bụi sao (Carnival Splash Cymbal Shimmer)
   - Trống bass mộc đập chắc nịch kết hợp gõ mõ chào đón (Timpani & Woodblock Clatter)
2. Tiết tấu sôi động nhảy múa (128 BPM Carnival Dance):
   - Nhịp điệu Charleston/Samba thiếu nhi nảy tưng tưng: Kick đồng bộ nhịp nhảy,
     tiếng vỗ tay ròn rã (Handclaps) kép + Snare Rimshot trên phách 2 & 4.
   - Tambourine lắc liên tục nốt móc 16 (16th-note train beat).
   - Mõ gỗ đôi gõ lách cách (Woodblock dialogue) mang phong cách đồ chơi mộc.
3. Dàn nhạc thiếu nhi đầy đặn, rực rỡ:
   - Tuba & Walking Bass nảy tưng bừng dưới đáy.
   - Marimba & Mộc Cầm (Wooden Xylophone) gõ giòn tan.
   - Toy Piano & Chuông Vàng (Glockenspiel) lĩnh xướng giai điệu bắt tai.
   - Kèn phím & Accordion đệm nhịp vui tươi.
   - Sáo trúc hoạt hình (Playful Flute) huýt sáo điểm xuyết.
4. Cấu trúc 16 Ô Nhịp @ 128 BPM = 30.000 giây (Toán học vòng lặp liền mạch 100% không click).
   - Ô 15-16: Đoạn dồn trống rực lửa + chuỗi rải mộc cầm vuốt vút lên cao, đâm thẳng vào
     phách 1 của Ô 1 để vòng lặp quay lại đầy năng lượng không một khoảnh khắc chùng xuống!
"""

import array
import math
import os
import struct
import subprocess
import wave

SAMPLE_RATE = 44100
A4 = 440.0
BPM = 128.0
BARS = 16
BEATS_PER_BAR = 4
TOTAL_BEATS = BARS * BEATS_PER_BAR  # 64 beats
LOOP_SECONDS = (TOTAL_BEATS * 60.0) / BPM  # 30.00000000 s
BEAT_DUR = 60.0 / BPM  # ~0.46875 s
NUM_SAMPLES = int(SAMPLE_RATE * LOOP_SECONDS)  # Exactly 1,323,000 samples

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
    # Với LOOP_SECONDS = 30.0s, k chu kỳ hoàn chỉnh đảm bảo pha đầu cuối = 0
    k = max(1, round(freq * LOOP_SECONDS))
    return k / LOOP_SECONDS

def swing_time(beat_float: float) -> float:
    base_beat = int(beat_float)
    frac = beat_float - base_beat
    if frac < 0.001:
        swung_frac = 0.0
    elif abs(frac - 0.5) < 0.05:
        swung_frac = 0.56  # Độ nhún nhảy chân sáo nhẹ
    else:
        swung_frac = frac
    return (base_beat + swung_frac) * BEAT_DUR

# 16 Ô NHỊP HÒA ÂM (C - G7 - C - F - G7 - C - Am - F - Dm - G7 - F - C - Dm - G7 - G7 - C)
CHORD_SHEET = [
    # --- BAR 1-2: KHỞI ĐỘNG BÙNG NỔ (FANFARE INTRO) ---
    ("C",  ["C3", "G2", "C3", "G2"], ["E3", "G3", "C4", "G4"]),
    ("G7", ["G2", "D3", "G2", "B2"], ["F3", "G3", "B3", "D4"]),
    
    # --- BAR 3-6: VŨ ĐIỆU RỪNG NHẠC (CARNIVAL MAIN THEME) ---
    ("C",  ["C3", "E3", "G2", "B2"], ["E3", "G3", "C4", "E4"]),
    ("F",  ["F2", "A2", "C3", "E3"], ["F3", "A3", "C4", "F4"]),
    ("G7", ["G2", "B2", "D3", "F3"], ["F3", "G3", "B3", "D4"]),
    ("C",  ["C3", "G2", "E3", "D3"], ["E3", "G3", "C4", "E4"]),

    # --- BAR 7-10: ĐOẠN ĐỐI ĐÁP TINH NGHỊCH (ANIMAL CALL & RESPONSE) ---
    ("Am", ["A2", "C3", "E3", "A2"], ["C4", "E4", "A4", "C5"]),
    ("F",  ["F2", "A2", "C3", "A2"], ["F3", "A3", "C4", "F4"]),
    ("Dm", ["D3", "F3", "A2", "C3"], ["F3", "A3", "D4", "F4"]),
    ("G7", ["G2", "B2", "D3", "F3"], ["F3", "G3", "B3", "D4"]),

    # --- BAR 11-14: CAO TRÀO ĐU QUAY BỤI SAO (FAIRYLIGHT CAROUSEL) ---
    ("F",  ["F2", "A2", "C3", "F3"], ["F3", "A3", "C4", "F4"]),
    ("C",  ["E3", "G3", "C3", "E3"], ["E3", "G3", "C4", "E4"]),
    ("Dm", ["D3", "F3", "A2", "C3"], ["F3", "A3", "D4", "F4"]),
    ("G7", ["G2", "D3", "F3", "B2"], ["F3", "G3", "B3", "D4"]),

    # --- BAR 15-16: DỒN TRỐNG & RẢI MỘC CẦM BÙNG NỔ RE-LOOP ---
    ("F",  ["F2", "A2", "C3", "F3"], ["F3", "A3", "C4", "F4"]),
    ("G7", ["G2", "D3", "G2", "B2"], ["F3", "G3", "B3", "D4"]),
]

# GIAI ĐIỆU CHÍNH (TOY PIANO + GLOCKENSPIEL + MARIMBA)
# (start_beat, dur_beats, note)
LEAD_MELODY = [
    # --- BAR 1: MỞ MÀN BÙNG NỔ TADAAA! (Fanfare Call) ---
    (0.0, 0.5, "C5"), (0.5, 0.5, "E5"), (1.0, 0.5, "G5"), (1.5, 0.5, "C6"),
    (2.0, 1.0, "G5"), (3.0, 0.5, "E5"), (3.5, 0.5, "G5"),
    
    # --- BAR 2: ĐỐI ĐÁP KÈN LÁCH CÁCH ---
    (4.0, 0.5, "F5"), (4.5, 0.5, "A5"), (5.0, 0.5, "G5"), (5.5, 0.5, "F5"),
    (6.0, 1.0, "E5"), (7.0, 0.5, "D5"), (7.5, 0.5, "G4"),

    # --- BAR 3-6: CHỦ ĐỀ CHÍNH CARNIVAL (Bouncy Forest Dance) ---
    (8.0, 0.5, "C5"), (8.5, 0.5, "C5"), (9.0, 0.5, "E5"), (9.5, 0.5, "G5"),
    (10.0, 0.75, "E5"), (10.75, 0.25, "C5"), (11.0, 1.0, "D5"),
    
    (12.0, 0.5, "F5"), (12.5, 0.5, "A5"), (13.0, 0.5, "C6"), (13.5, 0.5, "A5"),
    (14.0, 1.0, "G5"), (15.0, 0.5, "E5"), (15.5, 0.5, "G4"),

    (16.0, 0.5, "B4"), (16.5, 0.5, "D5"), (17.0, 0.5, "F5"), (17.5, 0.5, "D5"),
    (18.0, 1.0, "E5"), (19.0, 0.5, "G5"), (19.5, 0.5, "B4"),

    (20.0, 0.5, "C5"), (20.5, 0.5, "D5"), (21.0, 0.5, "E5"), (21.5, 0.5, "G5"),
    (22.0, 1.5, "C5"), (23.5, 0.5, "G4"),

    # --- BAR 7-10: ĐỐI ĐÁP MUÔNG THÚ (Animal Dance & Woodblock) ---
    (24.0, 0.5, "A5"), (24.5, 0.5, "E5"), (25.0, 0.5, "A5"), (25.5, 0.5, "C6"),
    (26.0, 1.0, "B5"), (27.0, 0.5, "G5"), (27.5, 0.5, "E5"),

    (28.0, 0.5, "F5"), (28.5, 0.5, "C5"), (29.0, 0.5, "F5"), (29.5, 0.5, "A5"),
    (30.0, 1.0, "G5"), (31.0, 0.5, "E5"), (31.5, 0.5, "C5"),

    (32.0, 0.5, "D5"), (32.5, 0.5, "F5"), (33.0, 0.5, "A5"), (33.5, 0.5, "D5"),
    (34.0, 1.0, "G5"), (35.0, 0.5, "E5"), (35.5, 0.5, "D5"),

    (36.0, 0.5, "C5"), (36.5, 0.5, "E5"), (37.0, 0.5, "G5"), (37.5, 0.5, "B4"),
    (38.0, 1.5, "C5"), (39.5, 0.5, "G4"),

    # --- BAR 11-14: CAO TRÀO BỤI SAO & VỖ TAY RỰC LỬA ---
    (40.0, 0.5, "A5"), (40.5, 0.5, "C6"), (41.0, 0.5, "B5"), (41.5, 0.5, "A5"),
    (42.0, 1.0, "G5"), (43.0, 0.5, "E5"), (43.5, 0.5, "G5"),

    (44.0, 0.5, "E5"), (44.5, 0.5, "G5"), (45.0, 0.5, "F5"), (45.5, 0.5, "E5"),
    (46.0, 1.0, "D5"), (47.0, 0.5, "G4"), (47.5, 0.5, "B4"),

    (48.0, 0.5, "F5"), (48.5, 0.5, "A5"), (49.0, 0.5, "G5"), (49.5, 0.5, "F5"),
    (50.0, 1.0, "E5"), (51.0, 0.5, "G5"), (51.5, 0.5, "C6"),

    (52.0, 0.5, "D6"), (52.5, 0.5, "C6"), (53.0, 0.5, "B5"), (53.5, 0.5, "A5"),
    (54.0, 1.0, "G5"), (55.0, 0.5, "F5"), (55.5, 0.5, "D5"),

    # --- BAR 15-16: KHÚC DỒN CAO TRÀO RE-LOOP ---
    (56.0, 0.5, "C5"), (56.5, 0.5, "E5"), (57.0, 0.5, "G5"), (57.5, 0.5, "C6"),
    (58.0, 1.0, "B5"), (59.0, 0.5, "G5"), (59.5, 0.5, "F5"),
]

# CHUỖI RẢI MỘC CẦM VÚT LÊN Ở Ô 16 DẪN THẲNG VÀO PHÁCH 1 BÙNG NỔ (Ô 1)
XYLOPHONE_RUSH = [
    (60.0, 0.25, "C4"), (60.25, 0.25, "D4"), (60.5, 0.25, "E4"), (60.75, 0.25, "F4"),
    (61.0, 0.25, "G4"), (61.25, 0.25, "A4"), (61.5, 0.25, "B4"), (61.75, 0.25, "C5"),
    (62.0, 0.25, "D5"), (62.25, 0.25, "E5"), (62.5, 0.25, "F5"), (62.75, 0.25, "G5"),
    (63.0, 0.25, "A5"), (63.25, 0.25, "B5"), (63.5, 0.25, "C6"), (63.75, 0.25, "D6"),
]

# SÁO TRÚC ĐỐI ĐÁP & CHUÔNG CELESTA TRÊN CAO
FLUTE_AND_CELESTA = [
    # Đáp lại ở Bar 2
    (5.0, 0.25, "C6"), (5.25, 0.25, "E6"), (5.5, 0.5, "G6"),
    # Đáp lại ở Bar 6
    (21.0, 0.25, "E6"), (21.25, 0.25, "G6"), (21.5, 0.5, "C7"),
    # Trills ở Bar 10
    (37.0, 0.25, "G6"), (37.25, 0.25, "E6"), (37.5, 0.5, "C6"),
    # Lấp lánh ở Bar 14
    (53.0, 0.25, "G6"), (53.25, 0.25, "B6"), (53.5, 0.5, "D7"),
]


def synthesize() -> bytearray:
    print(f"Tổng hợp Bản Nhạc Carnival Sôi Động Bùng Nổ ({LOOP_SECONDS:.2f}s, {BPM} BPM)...")

    left = array.array('f', [0.0] * NUM_SAMPLES)
    right = array.array('f', [0.0] * NUM_SAMPLES)

    # =========================================================================
    # 0. BÙNG NỔ PHÁCH 1 MỞ ĐẦU (TUTTI BRASS FANFARE HIT + CHIME GLISSANDO + CRASH)
    # =========================================================================
    # A. Hợp âm kèn đồng mạ vàng đại tấu (7-Voice Brass Fanfare Chord) ở Beat 0.0 & Beat 32.0
    fanfare_chords = [
        (0.0, ["C3", "G3", "C4", "E4", "G4", "C5", "E5"], 1.1),
        (32.0, ["C3", "G3", "C4", "E4", "G4", "C5"], 0.8),  # Giữa bài nhắc lại
    ]
    for b_start, chord_n, amp in fanfare_chords:
        f_start_s = int(b_start * BEAT_DUR * SAMPLE_RATE)
        f_dur_s = int(1.1 * SAMPLE_RATE)
        f_freqs = [quantize(note_hz(n)) for n in chord_n]
        for s in range(f_dur_s):
            idx = (f_start_s + s) % NUM_SAMPLES
            local_t = s / SAMPLE_RATE
            # Envelope kèn đồng: Vút mở cực nhanh (0.015s) rồi ngân vang rực rỡ
            if local_t < 0.018:
                env = local_t / 0.018
            else:
                env = math.exp(-(local_t - 0.018) * 3.8)
            brass_sum = 0.0
            for fn in f_freqs:
                # 5 họa âm kèn đồng mạ vàng rực rỡ
                brass_sum += (
                    1.00 * math.sin(2 * math.pi * fn * local_t) +
                    0.65 * math.sin(2 * math.pi * fn * 2.0 * local_t) +
                    0.35 * math.sin(2 * math.pi * fn * 3.0 * local_t) +
                    0.18 * math.sin(2 * math.pi * fn * 4.0 * local_t)
                )
            sig = env * brass_sum * 0.045 * amp
            left[idx] += sig * 0.50
            right[idx] += sig * 0.50

    # B. Tiếng vuốt chuông pha lê vút lên cao (12-note Fairy Chime Glissando) ngay từ 0.0s
    gliss_notes = ["C4", "E4", "G4", "A4", "C5", "D5", "E5", "G5", "A5", "C6", "E6", "G6"]
    for g_i, g_note in enumerate(gliss_notes):
        g_t = g_i * 0.028  # Trải đều trong 0.34s
        g_fn = quantize(note_hz(g_note))
        g_s = int(g_t * SAMPLE_RATE)
        g_dur = int(0.7 * SAMPLE_RATE)
        pan = g_i / float(len(gliss_notes))  # Quét từ trái sang phải
        for s in range(g_dur):
            idx = (g_s + s) % NUM_SAMPLES
            local_t = s / SAMPLE_RATE
            env = math.exp(-local_t * 5.2)
            sig = env * (
                1.00 * math.sin(2 * math.pi * g_fn * local_t) +
                0.45 * math.sin(2 * math.pi * g_fn * 2.0 * local_t) +
                0.25 * math.sin(2 * math.pi * (g_fn * 2.76) * local_t)
            ) * 0.16
            left[idx] += sig * (1.0 - pan)
            right[idx] += sig * pan

    # C. Tiếng chũm chọe vàng tung bụi sao (Carnival Splash Cymbal Shimmer) ở Beat 0.0 & Beat 32.0
    for crash_beat in [0.0, 32.0]:
        c_s = int(crash_beat * BEAT_DUR * SAMPLE_RATE)
        c_dur = int(1.2 * SAMPLE_RATE)
        # Giả lập kim loại rung cao tần rực rỡ (Metallic Shimmer)
        for s in range(c_dur):
            idx = (c_s + s) % NUM_SAMPLES
            local_t = s / SAMPLE_RATE
            c_env = math.exp(-local_t * 4.8)
            shimmer = (
                math.sin(2 * math.pi * 5200.0 * local_t) * 0.4 +
                math.sin(2 * math.pi * 7400.0 * local_t) * 0.35 +
                math.sin(2 * math.pi * 9600.0 * local_t) * 0.25 +
                math.sin(2 * math.pi * 11800.0 * local_t) * 0.20
            ) * c_env * 0.08
            left[idx] += shimmer * 0.55
            right[idx] += shimmer * 0.45

    # =========================================================================
    # 1. TRỐNG BASS MỘC CARNIVAL (PUNCHY KICK-THUMP CÓ NHỊP NHẢY SYNCOPATED)
    # =========================================================================
    # Nhịp nhảy thiếu nhi sôi nổi: Phách 1 (mạnh), Phách 2 rưỡi (syncopated), Phách 3 (chắc)
    for bar_i in range(BARS):
        bar_beat_start = bar_i * 4
        # Pattern kick mỗi ô nhịp: 0.0, 1.5, 2.0, 3.5
        kick_beats = [0.0, 1.5, 2.0, 3.5]
        for kb in kick_beats:
            b_val = bar_beat_start + kb
            k_t = swing_time(b_val)
            k_s = int(k_t * SAMPLE_RATE)
            k_dur = int(0.18 * SAMPLE_RATE)
            amp_mul = 1.25 if kb == 0.0 else 0.95
            for s in range(k_dur):
                idx = (k_s + s) % NUM_SAMPLES
                local_t = s / SAMPLE_RATE
                k_env = math.exp(-local_t * 24.0)
                # Pitch drop từ 150Hz về 48Hz (ấm, nẩy và chắc nịch)
                pitch = 48.0 + 102.0 * math.exp(-local_t * 32.0)
                k_sig = k_env * math.sin(2 * math.pi * pitch * local_t) * 0.32 * amp_mul
                left[idx] += k_sig * 0.50
                right[idx] += k_sig * 0.50

    # =========================================================================
    # 2. BASS TUBA & SLAP BASS (WALKING BASS NẢY TƯNG TƯNG DƯỚI ĐÁY)
    # =========================================================================
    for bar_idx in range(BARS):
        bass_line = CHORD_SHEET[bar_idx][1]
        for b_in_bar, note_name in enumerate(bass_line):
            beat_float = bar_idx * 4 + b_in_bar
            start_t = swing_time(beat_float)
            fn = quantize(note_hz(note_name))
            start_s = int(start_t * SAMPLE_RATE)
            dur_s = int(0.44 * SAMPLE_RATE)

            for s in range(dur_s):
                idx = (start_s + s) % NUM_SAMPLES
                local_t = s / SAMPLE_RATE
                # Slap click ở 10ms đầu
                click = math.sin(2 * math.pi * 180.0 * (1.0 - local_t * 50.0)) * 0.3 if local_t < 0.015 else 0.0
                decay = math.exp(-local_t * 8.0)
                sig = (decay * (
                    1.00 * math.sin(2 * math.pi * fn * local_t) +
                    0.60 * math.sin(2 * math.pi * fn * 2.0 * local_t) +
                    0.25 * math.sin(2 * math.pi * fn * 3.0 * local_t)
                ) + click) * 0.24
                left[idx] += sig * 0.48
                right[idx] += sig * 0.52

    # =========================================================================
    # 3. KÈN ĐỒ CHƠI & ACCORDION CHOP (BRIGHT BRASS STABS TRÊN CÁC PHÁCH OFFBEAT)
    # =========================================================================
    for bar_idx in range(BARS):
        chord_notes = CHORD_SHEET[bar_idx][2]
        chord_freqs = [quantize(note_hz(n)) for n in chord_notes]

        # Stabs trên phách 2 và 4, cộng thêm nốt nẩy ở phách 3.5 để tạo groove
        stab_beats = [1.0, 3.0, 3.5]
        for off_beat in stab_beats:
            beat_float = bar_idx * 4 + off_beat
            start_t = swing_time(beat_float)
            start_s = int(start_t * SAMPLE_RATE)
            dur_s = int(0.28 * SAMPLE_RATE)
            amp_mul = 0.6 if off_beat == 3.5 else 1.0

            for s in range(dur_s):
                idx = (start_s + s) % NUM_SAMPLES
                local_t = s / SAMPLE_RATE
                decay = math.exp(-local_t * 13.0)
                chop_sum = 0.0
                for fn in chord_freqs:
                    chop_sum += (
                        1.00 * math.sin(2 * math.pi * fn * local_t) +
                        0.60 * math.sin(2 * math.pi * fn * 2.0 * local_t) +
                        0.30 * math.sin(2 * math.pi * fn * 3.0 * local_t)
                    )
                stab = decay * chop_sum * 0.065 * amp_mul
                left[idx] += stab * 0.62
                right[idx] += stab * 0.38

    # =========================================================================
    # 4. BỘ GÕ CARNIVAL (HANDCLAPS KÉP, TAMBOURINE RỘN RÃ & MÕ GỖ ĐÔI)
    # =========================================================================
    for b_idx in range(TOTAL_BEATS):
        b_time = swing_time(b_idx)
        start_s = int(b_time * SAMPLE_RATE)

        # A. Tiếng vỗ tay ròn rã Handclap + Snare Rimshot ở phách 2 và 4 (indices 1 & 3)
        if (b_idx % 4) in [1, 3]:
            # Cụm vỗ tay phòng học (3 tiếng vỗ lệch 8ms tạo độ dày và chân thực)
            for clap_offset_ms in [0.0, 0.008, 0.016]:
                clap_s = start_s + int(clap_offset_ms * SAMPLE_RATE)
                clap_dur = int(0.12 * SAMPLE_RATE)
                for s in range(clap_dur):
                    idx = (clap_s + s) % NUM_SAMPLES
                    local_t = s / SAMPLE_RATE
                    clap_env = math.exp(-local_t * 28.0)
                    clap = clap_env * (
                        math.sin(2 * math.pi * 1150 * local_t) * 0.5 +
                        math.sin(2 * math.pi * 2300 * local_t) * 0.4 +
                        math.sin(2 * math.pi * 3400 * local_t) * 0.35
                    ) * 0.065
                    left[idx] += clap * 0.50
                    right[idx] += clap * 0.50

        # B. Tiếng mõ gỗ đôi (High-Low Wooden Temple Blocks) đối đáp lách cách
        wb_freq = 920.0 if (b_idx % 2 == 0) else 1520.0
        wb_dur = int(0.065 * SAMPLE_RATE)
        for s in range(wb_dur):
            idx = (start_s + s) % NUM_SAMPLES
            local_t = s / SAMPLE_RATE
            wb_env = math.exp(-local_t * 50.0)
            wb = wb_env * math.sin(2 * math.pi * wb_freq * local_t) * 0.09
            left[idx] += wb * 0.35
            right[idx] += wb * 0.65

        # C. Tambourine lắc liên tục nốt móc 16 (16th-note Shimmer Train)
        for sub_step in [0.0, 0.25, 0.5, 0.75]:
            tamb_t = swing_time(b_idx + sub_step)
            tamb_s = int(tamb_t * SAMPLE_RATE)
            tamb_dur = int(0.045 * SAMPLE_RATE)
            accent = 1.3 if sub_step in [0.0, 0.5] else 0.8
            for s in range(tamb_dur):
                idx = (tamb_s + s) % NUM_SAMPLES
                local_t = s / SAMPLE_RATE
                t_env = math.exp(-local_t * 55.0)
                t_sig = t_env * (
                    math.sin(2 * math.pi * 4800 * local_t) +
                    math.sin(2 * math.pi * 6800 * local_t) * 0.8 +
                    math.sin(2 * math.pi * 9200 * local_t) * 0.6
                ) * 0.028 * accent
                left[idx] += t_sig * 0.58
                right[idx] += t_sig * 0.42

    # =========================================================================
    # 5. GIAI ĐIỆU CHÍNH: TOY PIANO + GLOCKENSPIEL + MỘC CẦM (MARIMBA MALLETS)
    # =========================================================================
    for b_time, dur_beats, n_str in LEAD_MELODY:
        start_t = swing_time(b_time)
        dur_sec = dur_beats * BEAT_DUR
        fn = quantize(note_hz(n_str))
        start_s = int(start_t * SAMPLE_RATE)
        dur_s = int(max(dur_sec, 0.38) * SAMPLE_RATE)

        for s in range(dur_s):
            idx = (start_s + s) % NUM_SAMPLES
            local_t = s / SAMPLE_RATE

            if local_t < 0.003:
                env = local_t / 0.003
            else:
                env = math.exp(-(local_t - 0.003) * 3.8)

            # Âm sắc gõ mộc Marimba + Đàn đồ chơi Toy Piano + Chuông vàng
            lead = env * (
                1.00 * math.sin(2 * math.pi * fn * local_t) +
                0.60 * math.sin(2 * math.pi * fn * 2.0 * local_t) +
                0.35 * math.sin(2 * math.pi * fn * 3.0 * local_t) +
                0.22 * math.sin(2 * math.pi * (fn * 2.76) * local_t) +
                0.12 * math.sin(2 * math.pi * fn * 4.0 * local_t)
            ) * 0.30

            left[idx] += lead * 0.50
            right[idx] += lead * 0.50

    # =========================================================================
    # 6. CHUỖI RẢI MỘC CẦM Ở Ô 16 (XYLOPHONE RUSH BUILDING UP TO RE-LOOP)
    # =========================================================================
    for b_time, dur_beats, n_str in XYLOPHONE_RUSH:
        start_t = swing_time(b_time)
        fn = quantize(note_hz(n_str))
        start_s = int(start_t * SAMPLE_RATE)
        dur_s = int(0.24 * SAMPLE_RATE)
        # Pan quét từ trái qua phải khi chuỗi nốt leo thang
        pan = (b_time - 60.0) / 4.0

        for s in range(dur_s):
            idx = (start_s + s) % NUM_SAMPLES
            local_t = s / SAMPLE_RATE
            env = math.exp(-local_t * 9.5)
            # Âm sắc Mộc Cầm giòn lanh lảnh
            xylo = env * (
                1.00 * math.sin(2 * math.pi * fn * local_t) +
                0.70 * math.sin(2 * math.pi * fn * 2.0 * local_t) +
                0.40 * math.sin(2 * math.pi * (fn * 2.76) * local_t)
            ) * 0.28
            left[idx] += xylo * (1.0 - pan)
            right[idx] += xylo * pan

    # =========================================================================
    # 7. SÁO TRÚC & CHUÔNG CELESTA ĐỐI ĐÁP (SPARKLING COUNTERPOINTS)
    # =========================================================================
    for b_time, dur_beats, n_str in FLUTE_AND_CELESTA:
        start_t = swing_time(b_time)
        fn = quantize(note_hz(n_str))
        start_s = int(start_t * SAMPLE_RATE)
        dur_s = int(0.38 * SAMPLE_RATE)
        pan = 0.5 + 0.35 * math.sin(b_time * 0.8)

        for s in range(dur_s):
            idx = (start_s + s) % NUM_SAMPLES
            local_t = s / SAMPLE_RATE
            c_env = math.exp(-local_t * 7.5)
            chirp = c_env * (
                1.00 * math.sin(2 * math.pi * fn * local_t) +
                0.35 * math.sin(2 * math.pi * fn * 2.0 * local_t) +
                0.20 * math.sin(2 * math.pi * (fn * 2.76) * local_t)
            ) * 0.16
            left[idx] += chirp * pan
            right[idx] += chirp * (1.0 - pan)

    # =========================================================================
    # MASTERING: CHUẨN HÓA PEAK VỀ -1.0 dBFS (0.89) CHO ÂM THANH RỰC RỠ, NẢY CĂNG
    # =========================================================================
    peak = 0.0
    for i in range(NUM_SAMPLES):
        if abs(left[i]) > peak:
            peak = abs(left[i])
        if abs(right[i]) > peak:
            peak = abs(right[i])

    TARGET_PEAK = 0.89
    norm = TARGET_PEAK / peak if peak > 0 else 1.0
    print(f"Peak ban đầu: {peak:.3f} -> Chuẩn hóa về -1.0 dBFS (Hệ số: {norm:.3f})")

    stereo_pcm = bytearray()
    for i in range(NUM_SAMPLES):
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
    print(f" HOÀN TẤT XUẤT BẢN NHẠC CARNIVAL SÔI ĐỘNG BÙNG NỔ NGAY TỪ GIÂY ĐẦU:")
    print(f" -> {ogg_path}")
    print(f" Kích thước: {size_kb} KB | Thời lượng: {LOOP_SECONDS:.2f}s | Nhịp: {BPM} BPM Carnival")
    print("==================================================================")


if __name__ == "__main__":
    main()
