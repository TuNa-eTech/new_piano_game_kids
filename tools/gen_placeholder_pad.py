#!/usr/bin/env python3
"""Sinh pad hoà âm nền placeholder cho Rừng Nhạc.

docs/gameplay-design.html · Quyết định 02:
  "Nền hòa âm: một pad dây/harp trải hợp âm C — Am — F — G lặp vô hạn ở âm
   lượng -18 dB. Nó biến mọi nốt bé bấm thành một phần của bản nhạc, và lấp
   khoảng lặng khi bé nghĩ."

Pad chứa F và B (trong hợp âm F và G) dù thang giai điệu đã bỏ hai nốt đó —
đúng chủ ý: giai điệu ngũ cung chồng lên vòng hợp âm này thì nốt nào cũng thuận.

VÒNG LẶP LIỀN MẠCH — điểm kỹ thuật đáng chú ý nhất của file này:
mọi tần số được làm tròn về bội số của 1/L (L = độ dài vòng lặp), nên dạng
sóng tuần hoàn CHÍNH XÁC qua L. Sai lệch cao độ dưới 0,125 Hz, tai không nghe
ra, đổi lại điểm nối vòng lặp không có tiếng "tách". Bao hình cũng tuần hoàn
theo L bằng số học modulo, nên nó cũng nối liền.

Chạy:  python3 tools/gen_placeholder_pad.py
"""

import math
import os
import struct
import wave

SAMPLE_RATE = 44100
LOOP_SECONDS = 8.0        # 4 hợp âm × 2 giây
CHORDS = 4
CROSSFADE = 0.9           # giây, phần chồng lấp giữa hai hợp âm
PEAK = 0.42               # bus Music còn hạ tiếp -18 dB

# C - Am - F - G, thế bấm giữ chung nhiều nốt để chuyển hợp âm mượt.
CHORD_NOTES = [
    ["C3", "E3", "G3", "C4"],
    ["A2", "C3", "E3", "A3"],
    ["F2", "A2", "C3", "F3"],
    ["G2", "B2", "D3", "G3"],
]

# Hoạ âm nhẹ, nghiêng về dây/harp: cơ bản mạnh, bội âm mờ dần.
PARTIALS = [(1.0, 1.00), (2.0, 0.30), (3.0, 0.12), (4.0, 0.05)]

A4 = 440.0
SEMITONE = {"C": -9, "D": -7, "E": -5, "F": -4, "G": -2, "A": 0, "B": 2}


def note_hz(name: str) -> float:
    step = SEMITONE[name[0]]
    octave = int(name[1:])
    return A4 * (2.0 ** (step / 12.0 + (octave - 4)))


def quantize(freq: float, loop_len: float) -> float:
    """Làm tròn về bội số của 1/loop_len để sóng tuần hoàn đúng độ dài vòng lặp."""
    k = max(1, round(freq * loop_len))
    return k / loop_len


def chord_envelope(t: float, index: int) -> float:
    """Bao hình tuần hoàn cho một hợp âm, cộng lại bằng 1 và nối liền qua mốc lặp."""
    span = LOOP_SECONDS / CHORDS
    # khoảng cách vòng tròn từ t tới tâm của hợp âm này
    center = (index + 0.5) * span
    d = abs((t - center + LOOP_SECONDS / 2) % LOOP_SECONDS - LOOP_SECONDS / 2)
    half = span / 2.0
    if d <= half - CROSSFADE / 2:
        return 1.0
    if d >= half + CROSSFADE / 2:
        return 0.0
    x = (d - (half - CROSSFADE / 2)) / CROSSFADE
    return 0.5 * (1.0 + math.cos(math.pi * x))


def render() -> bytes:
    n = int(SAMPLE_RATE * LOOP_SECONDS)
    freqs = [
        [quantize(note_hz(x), LOOP_SECONDS) for x in chord] for chord in CHORD_NOTES
    ]

    out = bytearray()
    peak_seen = 0.0
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        acc = 0.0
        for c in range(CHORDS):
            env = chord_envelope(t, c)
            if env <= 0.0:
                continue
            for f in freqs[c]:
                for mult, amp in PARTIALS:
                    acc += env * amp * math.sin(2.0 * math.pi * f * mult * t)
        samples.append(acc)
        peak_seen = max(peak_seen, abs(acc))

    norm = PEAK / peak_seen if peak_seen > 0 else 1.0
    for v in samples:
        out += struct.pack("<h", int(max(-1.0, min(1.0, v * norm)) * 32767))
    return bytes(out)


def main() -> None:
    here = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.path.join(os.path.dirname(here), "assets", "placeholder", "music")
    os.makedirs(out_dir, exist_ok=True)
    path = os.path.join(out_dir, "pad_c_am_f_g.wav")

    data = render()
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        w.writeframes(data)

    print("  %s  %.1f s  %d KB" % (os.path.basename(path), LOOP_SECONDS, len(data) // 1024))
    print("  vòng hợp âm: " + " - ".join("".join(c[0][0] for _ in [0]) for c in CHORD_NOTES))
    print("\nXong -> %s" % out_dir)


if __name__ == "__main__":
    main()
