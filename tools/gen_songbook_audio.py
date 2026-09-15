#!/usr/bin/env python3
"""
gen_songbook_audio.py
Bộ sinh nhạc nền hòa âm mộc (Acoustic Backing Loops) cho 10 Bài Hát Thiếu Nhi.

Triết lý âm thanh (docs/audio-log.md):
- Dành cho trẻ 1-6 tuổi: ấm áp, mộc mạc (Harp, Kalimba, Acoustic Guitar, Celesta).
- Không trống điện tử, không bass dồn dập, không gây giật mình.
- Mức âm lượng: chuẩn hóa về -18 dBFS cho bus Music (không lấn át tiếng đàn của bé).
- Vòng lặp tuần hoàn toán học (circular crossfade + frequency quantization) để
  nối loop 100% mượt mà, không tiếng tách (zero-click seamless loop).
- Tự động xuất OGG qua ffmpeg và tạo file .import tương thích chuẩn Godot 4.

Chạy: python3 tools/gen_songbook_audio.py
"""

import math
import os
import shutil
import struct
import subprocess
import wave

SAMPLE_RATE = 44100
A4 = 440.0
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

def quantize(freq: float, loop_len: float) -> float:
    k = max(1, round(freq * loop_len))
    return k / loop_len

# Định nghĩa 10 bài hát kèm vòng hợp âm, tempo và đặc tính nhạc cụ.
# Engine v2 (2026-09): mỗi bài có rhythm/bass/perc/motif/fill riêng để nghe ra
# 10 tính cách. Vẫn giữ: tông C/Am tương đối (hợp ngũ cung của bé), loop
# seamless (quantize + crossfade), normalize -18 dBFS, OGG stereo 44.1kHz.
# 3 bài trùng tune gốc (Twinkle/ABC/Baa) được phân biệt bằng voicing + timbre.
SONG_CONFIGS = [
    {
        "id": "bgm_baby_shark",
        "title": "Baby Shark",
        "bpm": 85,
        "beats_per_bar": 4,
        "bars": 4,
        # C - C - Am - F (giữ)
        "chords": [
            ["C3", "G3", "C4", "E4"],
            ["C3", "G3", "C4", "E4"],
            ["A2", "E3", "A3", "C4"],
            ["F2", "C3", "F3", "A3"],
        ],
        "style": "ukulele_marimba",
        "rhythm": "bounce_offbeat",
        "bass": "bounce_root_fifth",
        "perc": "shaker_8ths",
        # Motif doo-doo-doo marimba ở bar cuối
        "motif_bar": 3,
        "motif": [(0.0, "G5"), (0.5, "G5"), (1.0, "G5")],
        "motif_timbre": "marimba",
        "motif_gain": 0.30,
    },
    {
        "id": "bgm_wheels_on_the_bus",
        "title": "The Wheels on the Bus",
        "bpm": 80,
        "beats_per_bar": 4,
        "bars": 4,
        # C - G - F - C (thêm F passing để khác bản cũ C-G-C-C)
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["G2", "D3", "G3", "B3"],
            ["F2", "A2", "C3", "F3"],
            ["C3", "E3", "G3", "C4"],
        ],
        "style": "bouncing_pizzicato",
        "rhythm": "oom_pah",
        "bass": "oom_pah",
        "perc": "busbell",
        # Motif bánh lăn đi lên ở bar cuối
        "motif_bar": 3,
        "motif": [(0.0, "C5"), (0.5, "D5"), (1.0, "E5"), (1.5, "G5")],
        "motif_timbre": "pizz",
        "motif_gain": 0.30,
    },
    {
        "id": "bgm_johny_johny",
        "title": "Johny Johny Yes Papa",
        "bpm": 76,
        "beats_per_bar": 4,
        "bars": 4,
        # C - G - Am - G (thêm Am để mềm câu hỏi-đáp)
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["G2", "B2", "D3", "G3"],
            ["A2", "E3", "A3", "C4"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "music_box",
        "rhythm": "qa_musicbox",
        "bass": "whole_soft",
        "perc": "none",
        # Motif hỏi-đáp: E5 (hỏi) -> D5 (đáp)
        "motif_bar": 3,
        "motif": [(0.0, "E5"), (1.5, "D5")],
        "motif_timbre": "musicbox",
        "motif_gain": 0.28,
    },
    {
        "id": "bgm_twinkle_twinkle",
        "title": "Twinkle Twinkle Little Star",
        "bpm": 68,
        "beats_per_bar": 4,
        "bars": 4,
        # C - F - Dm - G (Dm thay C ở bar 3 để khác ABC/Baa)
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["F2", "A2", "C3", "F3"],
            ["D3", "F3", "A3", "D4"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "celesta_harp",
        "rhythm": "lullaby_long",
        "bass": "whole_soft",
        "perc": "none",
        # Ánh sao lấp lánh vút lên
        "motif_bar": 3,
        "motif": [(0.0, "G5"), (1.0, "C6"), (2.0, "E6")],
        "motif_timbre": "celesta",
        "motif_gain": 0.20,
    },
    {
        "id": "bgm_if_youre_happy",
        "title": "If You're Happy and You Know It",
        "bpm": 84,
        "beats_per_bar": 4,
        "bars": 4,
        # C - G - C - G + Em passing ở bar 3 (C -> Em -> G cảm giác)
        "chords": [
            ["C3", "G3", "C4", "E4"],
            ["G2", "D3", "G3", "B3"],
            ["E3", "G3", "B3", "E4"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "happy_kalimba",
        "rhythm": "clap_2_4",
        "bass": "bouncy_8ths",
        "perc": "clap_2_4",
        # Vỗ tay: 2 nốt nhấn
        "motif_bar": 3,
        "motif": [(1.0, "C5"), (3.0, "C5")],
        "motif_timbre": "kalimba",
        "motif_gain": 0.30,
    },
    {
        "id": "bgm_old_macdonald",
        "title": "Old MacDonald Had a Farm",
        "bpm": 82,
        "beats_per_bar": 4,
        "bars": 4,
        # C - F - Dm - G (Dm thay C ở bar 3 cho có màu đồng quê)
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["F2", "C3", "F3", "A3"],
            ["D3", "F3", "A3", "D4"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "rustic_guitar",
        "rhythm": "folk_pick",
        "bass": "folk_alt",
        "perc": "folk_shaker",
        # Motif guitar đi xuống mộc mạc
        "motif_bar": 3,
        "motif": [(0.0, "G4"), (1.0, "E4"), (2.0, "D4"), (3.0, "C4")],
        "motif_timbre": "guitar",
        "motif_gain": 0.28,
    },
    {
        "id": "bgm_abc_song",
        "title": "ABC Song",
        "bpm": 70,
        "beats_per_bar": 4,
        "bars": 4,
        # C - Am - F - G (khác Twinkle C-F-Dm-G và Baa C-Dm-F-G)
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["A2", "E3", "A3", "C4"],
            ["F2", "A2", "C3", "F3"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "lullaby_bells",
        "rhythm": "learn_slow",
        "bass": "whole_soft",
        "perc": "none",
        # Chuông học chữ chậm rãi đi lên
        "motif_bar": 3,
        "motif": [(0.0, "C5"), (1.0, "D5"), (2.0, "E5")],
        "motif_timbre": "musicbox",
        "motif_gain": 0.26,
    },
    {
        "id": "bgm_baa_baa_black_sheep",
        "title": "Baa Baa Black Sheep",
        "bpm": 72,
        "beats_per_bar": 4,
        "bars": 4,
        # C - Dm - F - G (khác Twinkle và ABC)
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["D3", "F3", "A3", "D4"],
            ["F2", "A2", "C3", "F3"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "warm_flute_pad",
        "rhythm": "pastoral_flow",
        "bass": "whole_soft",
        "perc": "none",
        # Sáo gỗ lead nốt dài trôi
        "motif_bar": 3,
        "motif": [(0.0, "G4"), (1.5, "A4"), (2.5, "G4")],
        "motif_timbre": "flute",
        "motif_gain": 0.26,
    },
    {
        "id": "bgm_five_little_monkeys",
        "title": "Five Little Monkeys",
        "bpm": 80,
        "beats_per_bar": 4,
        "bars": 4,
        # C - G - Am - G (Am thay C ở bar 3 cho tinh nghịch)
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["G2", "B2", "D3", "G3"],
            ["A2", "C3", "E3", "A3"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "cheeky_wood",
        "rhythm": "shuffle_jump",
        "bass": "shuffle_bass",
        "perc": "woodblock",
        # Nhảy tưng: 3 nốt dồn
        "motif_bar": 3,
        "motif": [(0.0, "E5"), (0.25, "G5"), (0.5, "A5")],
        "motif_timbre": "marimba",
        "motif_gain": 0.30,
    },
    {
        "id": "bgm_heads_shoulders",
        "title": "Heads, Shoulders, Knees and Toes",
        "bpm": 86,
        "beats_per_bar": 4,
        "bars": 4,
        # C - G - Am - F - G gộp 4 bars: C - G - Am - G (F lướt ở fill)
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["G2", "D3", "G3", "B3"],
            ["A2", "C3", "E3", "A3"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "playful_tines",
        "rhythm": "motion_8th",
        "bass": "drive_8ths",
        "perc": "motion_shaker",
        # Chạm tay đi lên theo cơ thể
        "motif_bar": 3,
        "motif": [(0.0, "G4"), (0.5, "A4"), (1.0, "C5"), (1.5, "D5")],
        "motif_timbre": "kalimba",
        "motif_gain": 0.30,
    }
]

def chord_envelope(t: float, index: int, num_chords: int, loop_len: float, crossfade: float) -> float:
    span = loop_len / num_chords
    center = (index + 0.5) * span
    d = abs((t - center + loop_len / 2.0) % loop_len - loop_len / 2.0)
    half = span / 2.0
    if d <= half - crossfade / 2.0:
        return 1.0
    if d >= half + crossfade / 2.0:
        return 0.0
    x = (d - (half - crossfade / 2.0)) / crossfade
    return 0.5 * (1.0 + math.cos(math.pi * x))

def get_style_partials(style: str):
    if "music_box" in style or "celesta" in style or "bells" in style:
        # Trong trẻo, chuông pha lê (nhiều bội âm lẻ và cao)
        return [(1.0, 1.0), (2.0, 0.45), (3.0, 0.25), (4.0, 0.08), (5.8, 0.15)]
    elif "ukulele" in style or "guitar" in style or "pizzicato" in style:
        # Dây gảy mộc, ấm và tự nhiên
        return [(1.0, 1.0), (2.0, 0.50), (3.0, 0.18), (4.0, 0.08)]
    elif "kalimba" in style or "tines" in style or "wood" in style:
        # Đàn phím gỗ / kalimba gõ kim loại
        return [(1.0, 1.0), (2.76, 0.22), (3.0, 0.08), (5.4, 0.12)]
    else:
        # Pad ấm dịu cơ bản
        return [(1.0, 1.0), (2.0, 0.35), (3.0, 0.12), (4.0, 0.05)]

def get_motif_partials(timbre: str):
    """Bội âm cho motif signature — đặt ở 1-3kHz để loa rẻ vẫn nghe thấy."""
    if timbre in ("celesta", "musicbox"):
        return [(1.0, 1.0), (2.0, 0.40), (3.0, 0.22), (4.0, 0.07)]
    if timbre in ("marimba", "kalimba"):
        return [(1.0, 1.0), (2.76, 0.20), (4.0, 0.08), (5.4, 0.10)]
    if timbre in ("pizz", "guitar"):
        return [(1.0, 1.0), (2.0, 0.48), (3.0, 0.16), (4.0, 0.07)]
    if timbre == "flute":
        return [(1.0, 1.0), (2.0, 0.25), (3.0, 0.08)]
    return [(1.0, 1.0), (2.0, 0.35), (3.0, 0.12)]


def _perc_events(cfg, loop_len: float):
    """Sinh danh sách sự kiện gõ gỗ (thời điểm giây, tần số, gain).
    Toàn bộ là sine ping dịu, decay nhanh — không trống điện tử."""
    perc = cfg.get("perc", "none")
    if perc == "none":
        return []
    bpm = cfg["bpm"]
    bpb = cfg["beats_per_bar"]
    bars = cfg["bars"]
    beat = 60.0 / bpm
    bar_len = beat * bpb
    ev = []
    if perc == "shaker_8ths":
        # Lắc gỗ nhẹ mỗi nửa phách, nhấn nhẹ phách 1
        t = 0.0
        eighth = beat / 2.0
        k = 0
        while t < loop_len - 0.05:
            g = 0.050 if (k % 2 == 0) else 0.032
            ev.append((t, 3200.0, g, 0.045))
            t += eighth
            k += 1
    elif perc == "busbell":
        # Chuông xe ting-ting ở bar cuối + shaker thưa
        t = 0.0
        while t < loop_len - 0.05:
            ev.append((t, 2800.0, 0.030, 0.05))
            t += beat
        base = 3 * bar_len
        ev.append((base + 0.0 * beat, 2489.0, 0.070, 0.30))  # B5-ish bell
        ev.append((base + 0.5 * beat, 2489.0, 0.070, 0.30))
    elif perc == "clap_2_4":
        # Vỗ tay gỗ vào phách 2 & 4 mỗi bar + shaker nhẹ
        for b in range(bars):
            base = b * bar_len
            ev.append((base + 1 * beat, 1250.0, 0.075, 0.09))
            ev.append((base + 3 * beat, 1250.0, 0.075, 0.09))
            ev.append((base + 0 * beat, 3000.0, 0.028, 0.05))
            ev.append((base + 2 * beat, 3000.0, 0.028, 0.05))
    elif perc == "folk_shaker":
        for b in range(bars):
            base = b * bar_len
            ev.append((base + 0 * beat, 2600.0, 0.045, 0.06))
            ev.append((base + 2 * beat, 2600.0, 0.038, 0.06))
            ev.append((base + 1 * beat, 1800.0, 0.028, 0.05))
            ev.append((base + 3 * beat, 1800.0, 0.028, 0.05))
    elif perc == "woodblock":
        # Shuffle: nhấn lệch "and" — nhí nhảnh
        for b in range(bars):
            base = b * bar_len
            ev.append((base + 0.0 * beat, 950.0, 0.065, 0.07))
            ev.append((base + 0.66 * beat, 1350.0, 0.045, 0.06))
            ev.append((base + 2.0 * beat, 950.0, 0.060, 0.07))
            ev.append((base + 2.66 * beat, 1350.0, 0.045, 0.06))
    elif perc == "motion_shaker":
        t = 0.0
        eighth = beat / 2.0
        k = 0
        while t < loop_len - 0.05:
            g = 0.048 if (k % 2 == 0) else 0.030
            ev.append((t, 3000.0 if k % 2 == 0 else 3600.0, g, 0.04))
            t += eighth
            k += 1
    return ev


def _bass_note_at(cfg, t: float, loop_len: float, chord_roots):
    """Trả về (freq, gain, decay) của bass tại thời điểm t, hoặc None.
    Bass dùng sine tròn + ít họa âm — ấm, không dồn dập."""
    bass = cfg.get("bass", "whole_soft")
    bpm = cfg["bpm"]
    bpb = cfg["beats_per_bar"]
    bars = cfg["bars"]
    beat = 60.0 / bpm
    bar_len = beat * bpb
    bar_idx = min(bars - 1, int(t / bar_len))
    beat_in_bar = (t - bar_idx * bar_len) / beat  # 0..bpb
    root = chord_roots[bar_idx]
    fifth = root * 1.5

    def onset_at(beats_list):
        for bb in beats_list:
            if abs(beat_in_bar - bb) * beat < 0.012:
                return True, bb
        return False, 0.0

    if bass == "whole_soft":
        hit, _ = onset_at([0.0])
        if hit:
            return (root, 0.16, 1.2)
        return None
    if bass == "oom_pah":
        hit0, _ = onset_at([0.0, 2.0])
        hit1, _ = onset_at([1.0, 3.0])
        if hit0:
            return (root, 0.22, 0.9)
        if hit1:
            return (fifth, 0.16, 0.7)
        return None
    if bass == "bounce_root_fifth":
        # Nhún doo-doo: root phách 1, fifth offbeat 2.5
        hit0, _ = onset_at([0.0])
        hit1, _ = onset_at([1.5])
        if hit0:
            return (root, 0.24, 0.8)
        if hit1:
            return (fifth, 0.18, 0.6)
        return None
    if bass == "bouncy_8ths":
        # 8th root-5 xen kẽ, nhẹ
        eighth_idx = int(beat_in_bar * 2 + 1e-6)
        if abs(beat_in_bar * 2 - eighth_idx) * (beat / 2) < 0.012:
            f = root if eighth_idx % 2 == 0 else fifth
            return (f, 0.15, 0.45)
        return None
    if bass == "folk_alt":
        hit0, _ = onset_at([0.0, 2.0])
        hit1, _ = onset_at([1.0, 3.0])
        if hit0:
            return (root, 0.20, 0.9)
        if hit1:
            return (fifth, 0.14, 0.7)
        return None
    if bass == "shuffle_bass":
        hit0, _ = onset_at([0.0, 2.0])
        hit1, _ = onset_at([0.66, 2.66])
        if hit0:
            return (root, 0.22, 0.7)
        if hit1:
            return (fifth, 0.15, 0.5)
        return None
    if bass == "drive_8ths":
        eighth_idx = int(beat_in_bar * 2 + 1e-6)
        if abs(beat_in_bar * 2 - eighth_idx) * (beat / 2) < 0.012:
            seq = [root, fifth, root * 1.122, fifth]  # root-5-6-5 (6=A dịu)
            f = seq[eighth_idx % 4]
            return (f, 0.15, 0.4)
        return None
    return None


def render_backing(cfg) -> list:
    bpm = cfg["bpm"]
    bars = cfg["bars"]
    beats = bars * cfg["beats_per_bar"]
    # Độ dài vòng lặp chính xác theo số phách nhịp
    loop_len = (beats * 60.0) / bpm
    chords = cfg["chords"]
    num_chords = len(chords)
    crossfade = min(0.8, (loop_len / num_chords) * 0.45)
    partials = get_style_partials(cfg["style"])

    n_samples = int(SAMPLE_RATE * loop_len)
    freqs = [
        [quantize(note_hz(x), loop_len) for x in chord] for chord in chords
    ]
    chord_roots = [quantize(note_hz(ch[0]), loop_len) for ch in chords]

    # Chuẩn bị sự kiện perc + motif (tính 1 lần, không tính trong vòng mẫu)
    perc_ev = _perc_events(cfg, loop_len)
    motif_partials = get_motif_partials(cfg.get("motif_timbre", ""))
    motif_gain = float(cfg.get("motif_gain", 0.28))
    motif_bar = int(cfg.get("motif_bar", bars - 1))
    bar_len = loop_len / num_chords
    motif_base = motif_bar * bar_len
    motif_notes = []
    for off_beats, nm in cfg.get("motif", []):
        f = quantize(note_hz(nm), loop_len)
        motif_notes.append((motif_base + off_beats * (60.0 / bpm), f))

    samples = [0.0] * n_samples
    peak_seen = 0.0

    beat_dur = 60.0 / bpm
    last_bar_start = (num_chords - 1) * (loop_len / num_chords)

    # Precompute decay cho perc theo mẫu (tránh exp mỗi mẫu cho mỗi event)
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        acc = 0.0

        # 1. Pad nền hòa âm ấm áp
        for c in range(num_chords):
            env = chord_envelope(t, c, num_chords, loop_len, crossfade)
            if env <= 0.0:
                continue
            for f in freqs[c]:
                for mult, amp in partials:
                    acc += 0.45 * env * amp * math.sin(2.0 * math.pi * f * mult * t)

        # 2. Tiếng gảy Arpeggio nhẹ nhàng theo từng phách nhịp
        #    Bar cuối: chạy thang đi lên + to hơn 30% như fill báo vòng lặp mới.
        cur_beat_idx = int(t / beat_dur)
        beat_phase = (t % beat_dur) / beat_dur
        # Pluck envelope
        pluck_env = math.exp(-beat_phase * 4.2)
        chord_idx = min(num_chords - 1, int(t / (loop_len / num_chords)))
        if t >= last_bar_start:
            arp_notes = sorted(freqs[chord_idx])
            arp_note_idx = cur_beat_idx % len(arp_notes)
            arp_freq = arp_notes[arp_note_idx] * 2.0
            acc += 0.45 * pluck_env * math.sin(2.0 * math.pi * arp_freq * t)
        else:
            arp_note_idx = cur_beat_idx % len(freqs[chord_idx])
            arp_freq = freqs[chord_idx][arp_note_idx] * 2.0  # Cao hơn 1 quãng 8 cho lấp lánh
            acc += 0.35 * pluck_env * math.sin(2.0 * math.pi * arp_freq * t)

        # 3. Bass mộc theo pattern riêng từng bài
        b = _bass_note_at(cfg, t, loop_len, chord_roots)
        if b is not None:
            bf, bg, bdec = b
            # envelope từ onset gần nhất: dùng beat_phase gần đúng cho gọn
            # (bass onset luôn rơi vào lưới beat/8th nên tái dùng pluck-like decay)
            acc += bg * math.exp(-beat_phase * bdec * 2.0) * math.sin(2.0 * math.pi * bf * t)
            acc += 0.3 * bg * math.exp(-beat_phase * bdec * 2.0) * math.sin(2.0 * math.pi * bf * 2.0 * t)

        # 4. Gõ gỗ / chuông nhẹ (chỉ tính khi gần event để nhẹ CPU)
        for (pt, pf, pg, pdec) in perc_ev:
            dt = t - pt
            if 0.0 <= dt < 0.25:
                acc += pg * math.exp(-dt / pdec) * math.sin(2.0 * math.pi * pf * t)

        # 5. Motif signature 2s ở bar đã định (envelope tấn công mềm)
        for (mt, mf) in motif_notes:
            dt = t - mt
            if 0.0 <= dt < 1.6:
                a_env = min(1.0, dt / 0.012)  # attack 12ms, không click
                d_env = math.exp(-dt * 2.6)
                for mult, amp in motif_partials:
                    acc += motif_gain * a_env * d_env * amp * math.sin(2.0 * math.pi * mf * mult * t)

        samples[i] = acc
        if abs(acc) > peak_seen:
            peak_seen = abs(acc)

    # Chuẩn hóa về mức -18 dBFS (target peak ~ 0.126)
    TARGET_PEAK = 0.126
    norm = TARGET_PEAK / peak_seen if peak_seen > 0 else 1.0
    final_samples = [max(-1.0, min(1.0, s * norm)) for s in samples]
    return final_samples, loop_len

def make_godot_ogg_import(ogg_path: str, loop: bool = True):
    import_path = f"{ogg_path}.import"
    rel_path = ogg_path.replace("/Users/anhtu/MySpace/new-piano/", "").replace("./", "")
    filename = os.path.basename(ogg_path)
    base_no_ext = filename.replace(".ogg", "")
    loop_str = "true" if loop else "false"
    
    content = f"""[remap]

importer="oggvorbisstr"
type="AudioStreamOggVorbis"
uid="uid://{rel_path.replace('/', '_').replace('.', '_')}"
path="res://.godot/imported/{filename}-{base_no_ext}.oggvorbisstr"

[deps]

source_file="res://{rel_path}"
dest_files=["res://.godot/imported/{filename}-{base_no_ext}.oggvorbisstr"]

[params]

loop={loop_str}
loop_offset=0
bpm=0
beat_count=0
bar_beats=4
"""
    with open(import_path, 'w', encoding='utf-8') as f:
        f.write(content)


# ---------------------------------------------------------------- Phase 2 --
# Lớp pet + vocal guide la-la. Pet tái dùng voice thú thật có sẵn (0.6s);
# vocal guide là giọng hum "la" synth theo đúng câu hát đầu của từng bài để
# bé nhại theo khi ngồi im. Cả hai đều dịu, không nốt lạ ngoài ngũ cung.

# song id (không tiền tố bgm_) -> file voice thú thật trong assets/audio/
PET_VOICE_BY_ID = {
    "baby_shark": "voice_bear_g4.wav",       # cá mập không có voice riêng -> gấu trầm
    "wheels_on_the_bus": "voice_bear_g4.wav",
    "johny_johny": "voice_cat_g4.wav",
    "twinkle_twinkle": "voice_owl_g4.wav",
    "if_youre_happy": "voice_rabbit_g4.wav",
    "old_macdonald": "voice_bear_g4.wav",    # bò không có voice riêng -> gấu trầm
    "abc_song": "voice_lion_g4.wav",
    "baa_baa_black_sheep": "voice_rabbit_g4.wav",  # cừu -> thỏ nhẹ
    "five_little_monkeys": "voice_monkey_g4.wav",
    "heads_shoulders": "voice_elephant_g4.wav",
}

# Chỉ số phím ngũ cung (Notes.TABLE) của CÂU HÁT ĐẦU từng bài (copy từ songbook.gd)
PENTA_NAMES = ["C4", "D4", "E4", "G4", "A4", "C5", "D5"]
VOICEGUIDE_PHRASES = {
    "baby_shark": [1, 2, 3, 3, 3, 3, 3, 3],
    "wheels_on_the_bus": [0, 2, 2, 2, 2, 4, 5, 4, 3],
    "johny_johny": [0, 0, 2, 3],
    "twinkle_twinkle": [0, 0, 3, 3, 4, 4, 3],
    "if_youre_happy": [0, 0, 2, 2, 2, 2, 1, 2, 3],
    "old_macdonald": [0, 0, 0, 3, 4, 4, 3],
    "abc_song": [0, 0, 3, 3, 4, 4, 3],
    "baa_baa_black_sheep": [0, 0, 3, 3, 4, 4, 4, 4, 3],
    "five_little_monkeys": [2, 2, 2, 0, 2, 2, 3],
    "heads_shoulders": [3, 3, 2, 0, 2, 3, 2, 0],
}

PET_PEAK = 0.050  # ~-26dBFS: nghe thấy trên loa rẻ nhưng không lấn pad


def _load_pet_samples(repo_root: str, wav_name: str) -> list:
    path = os.path.join(repo_root, "assets", "audio", wav_name)
    if not os.path.exists(path):
        return []
    with wave.open(path, "rb") as w:
        n = w.getnframes()
        raw = w.readframes(n)
        fmt = "<%dh" % n
        vals = struct.unpack(fmt, raw)
        peak = max(1, max(abs(v) for v in vals))
        scale = (PET_PEAK * 32767) / peak
        out = []
        total = len(vals)
        fade = min(1200, total // 10)
        for idx, v in enumerate(vals):
            s = v * scale / 32767.0
            if idx < fade:
                s *= idx / fade
            elif idx >= total - fade:
                s *= max(0.0, (total - idx) / fade)
            out.append(s)
        return out


def mix_pet_into(samples: list, loop_len: float, cfg, repo_root: str) -> list:
    """Trộn 1 tiếng pet vào giữa vòng loop (bar 2, phách 1) — xa motif (bar 4)."""
    song_key = cfg["id"].replace("bgm_", "", 1)
    wav_name = PET_VOICE_BY_ID.get(song_key, "")
    if not wav_name:
        return samples
    pet = _load_pet_samples(repo_root, wav_name)
    if not pet:
        return samples
    offset_sec = loop_len / 2.0  # giữa vòng: bar 3 phách 1 với bars=4
    start = int(offset_sec * SAMPLE_RATE)
    mixed = list(samples)
    for k, s in enumerate(pet):
        j = start + k
        if 0 <= j < len(mixed):
            mixed[j] += s
    peak = max(1e-9, max(abs(s) for s in mixed))
    if peak > 0.126:
        norm = 0.126 / peak
        mixed = [s * norm for s in mixed]
    return mixed


def render_voiceguide(song_key: str, bpm: int, loop_len: float) -> list:
    """Giọng hum 'la' mềm theo câu hát đầu — bé nghe để nhại theo lúc idle."""
    phrase = VOICEGUIDE_PHRASES.get(song_key, [0, 2, 3])
    note_dur = min(0.65, max(0.42, (60.0 / bpm) * 0.72))
    gap = 0.04
    total = len(phrase) * (note_dur + gap) + 0.4
    n = int(SAMPLE_RATE * total)
    out = [0.0] * n
    for ni, idx in enumerate(phrase):
        nm = PENTA_NAMES[max(0, min(6, idx))]
        f = quantize(note_hz(nm), loop_len)
        t0 = 0.2 + ni * (note_dur + gap)
        i0 = int(t0 * SAMPLE_RATE)
        i1 = min(n, int((t0 + note_dur) * SAMPLE_RATE))
        for i in range(i0, i1):
            dt = (i - i0) / SAMPLE_RATE
            a = min(1.0, dt / 0.05)
            r = min(1.0, (i1 - i) / SAMPLE_RATE / 0.08)
            env = a * r
            t = i / SAMPLE_RATE
            out[i] += env * (
                0.50 * math.sin(2.0 * math.pi * f * t)
                + 0.20 * math.sin(2.0 * math.pi * f * 2.0 * t)
                + 0.08 * math.sin(2.0 * math.pi * f * 3.0 * t)
            )
    peak = max(1e-9, max(abs(s) for s in out))
    target = 0.20  # ~-14dBFS: rõ hơn BGM nhưng vẫn dưới tiếng đàn (-3dBFS)
    norm = target / peak
    return [max(-1.0, min(1.0, s * norm)) for s in out]


def _write_ogg_s16(samples: list, ogg_path: str, ffmpeg_bin: str):
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    wav_path = ogg_path.replace(".ogg", "._tmp.wav")
    int_data = bytearray()
    for s in samples:
        int_data += struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767))
    with wave.open(wav_path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        w.writeframes(int_data)
    cmd = [ffmpeg_bin, "-y", "-i", wav_path, "-ac", "2", "-c:a", "vorbis",
           "-strict", "-2", ogg_path]
    subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if os.path.exists(wav_path):
        os.remove(wav_path)

def main():
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    out_dir = os.path.join(repo_root, "assets", "audio", "songbook")
    os.makedirs(out_dir, exist_ok=True)

    print("==========================================================")
    print(" BẮT ĐẦU SINH NHẠC NỀN HÒA ÂM MỘC CHO 10 BÀI HÁT THIẾU NHI")
    print("==========================================================")

    ffmpeg_bin = shutil.which("ffmpeg") or "/opt/homebrew/bin/ffmpeg"
    total_vg_kb = 0

    for cfg in SONG_CONFIGS:
        song_id = cfg["id"]
        title = cfg["title"]
        wav_path = os.path.join(out_dir, f"{song_id}.wav")
        ogg_path = os.path.join(out_dir, f"{song_id}.ogg")

        samples, loop_len = render_backing(cfg)
        # Phase 2: trộn 1 tiếng pet thật vào giữa vòng loop
        samples = mix_pet_into(samples, loop_len, cfg, repo_root)

        # Lưu file WAV trung gian (16-bit 44.1kHz Mono)
        int_data = bytearray()
        for s in samples:
            int_data += struct.pack("<h", int(s * 32767))

        with wave.open(wav_path, "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(SAMPLE_RATE)
            w.writeframes(int_data)

        # Chuyển đổi sang OGG Vorbis stereo chất lượng cao bằng ffmpeg
        cmd = [
            ffmpeg_bin, "-y",
            "-i", wav_path,
            "-ac", "2",
            "-c:a", "vorbis",
            "-strict", "-2",
            ogg_path
        ]
        result = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        
        # Xóa file WAV tạm để tiết kiệm dung lượng repo
        if os.path.exists(wav_path):
            os.remove(wav_path)

        # Tạo file .import cho Godot
        make_godot_ogg_import(ogg_path)

        file_size_kb = os.path.getsize(ogg_path) // 1024 if os.path.exists(ogg_path) else 0
        print(f" ✓ {title:<32} | {loop_len:5.1f}s | {cfg['bpm']:2d} BPM | {file_size_kb:3d} KB -> {os.path.basename(ogg_path)}")

        # Phase 2: vocal guide la-la theo câu hát đầu (one-shot, không loop)
        song_key = song_id.replace("bgm_", "", 1)
        vg_samples = render_voiceguide(song_key, cfg["bpm"], loop_len)
        vg_path = os.path.join(out_dir, f"voiceguide_{song_key}.ogg")
        _write_ogg_s16(vg_samples, vg_path, ffmpeg_bin)
        make_godot_ogg_import(vg_path, loop=False)
        vg_kb = os.path.getsize(vg_path) // 1024 if os.path.exists(vg_path) else 0
        total_vg_kb += vg_kb
        print(f"   └ voiceguide ({len(VOICEGUIDE_PHRASES.get(song_key, []))} nốt) -> {os.path.basename(vg_path)} {vg_kb} KB")

    print("==========================================================")
    print(f" Hoàn tất xuất 10 file OGG seamless loop tại:\n {out_dir}")
    print(f" + 10 voiceguide one-shot ({total_vg_kb} KB)")
    print("==========================================================")

if __name__ == "__main__":
    main()
