#!/usr/bin/env python3
"""Sinh 7 file .wav placeholder cho thang ngu cung cua Rung Nhac.

Bước 3 (âm thanh thật) chưa xảy ra. Không có file wav thì không đo được gì,
nên script này dựng tạm 7 nốt đúng tần số thiết kế để chạy Spike B.

Ràng buộc lấy từ docs/gameplay-design.html (mục Kỹ thuật):
  - .wav, KHÔNG nén  -> bỏ chi phí giải mã trong đường nóng
  - attack < 10 ms   -> ở đây dùng 5 ms
  - PCM 16-bit mono 44.1 kHz

Chạy:  python3 tools/gen_placeholder_notes.py
"""

import math
import os
import struct
import wave

SAMPLE_RATE = 44100
DURATION = 1.2          # giây
ATTACK = 0.005          # 5 ms — tài liệu đòi < 10 ms
PEAK = 0.62             # chừa headroom, tránh clip khi bé bấm nhiều phím

# Phải khớp game/notes.gd. Thứ tự = chỉ số phím 0..6.
NOTES = [
    ("c4", 261.63, "su_tu"),
    ("d4", 293.66, "gau"),
    ("e4", 329.63, "tho"),
    ("g4", 392.00, "meo"),
    ("a4", 440.00, "khi"),
    ("c5", 523.25, "voi"),
    ("d5", 587.33, "cu"),
]

# Cộng thêm hoạ âm để ra tiếng kiểu marimba/celesta thay vì sine trần.
# (bội số, biên độ, hệ số decay) — hoạ âm cao tắt nhanh hơn, giống nhạc cụ gõ thật.
HARMONICS = [
    (1.0, 1.00, 1.0),
    (2.0, 0.34, 1.7),
    (3.0, 0.14, 2.6),
    (4.6, 0.05, 4.0),
]

BASE_DECAY = 3.2


def render(freq: float) -> bytes:
    n = int(SAMPLE_RATE * DURATION)
    attack_n = max(1, int(SAMPLE_RATE * ATTACK))
    out = bytearray()

    for i in range(n):
        t = i / SAMPLE_RATE

        sample = 0.0
        for mult, amp, decay_mult in HARMONICS:
            sample += amp * math.sin(2.0 * math.pi * freq * mult * t) \
                * math.exp(-BASE_DECAY * decay_mult * t)

        # Attack tuyến tính rất ngắn: chống click ở mẫu đầu mà không làm chậm phản hồi.
        if i < attack_n:
            sample *= i / attack_n

        # Fade cuối 30 ms để đuôi không bị cắt cụt thành tiếng "tách".
        tail = n - i
        fade_n = int(SAMPLE_RATE * 0.03)
        if tail < fade_n:
            sample *= tail / fade_n

        v = int(max(-1.0, min(1.0, sample * PEAK)) * 32767)
        out += struct.pack("<h", v)

    return bytes(out)


def main() -> None:
    here = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.path.join(os.path.dirname(here), "assets", "placeholder", "notes")
    os.makedirs(out_dir, exist_ok=True)

    for name, freq, animal in NOTES:
        path = os.path.join(out_dir, f"note_{name}_{animal}.wav")
        with wave.open(path, "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)        # 16-bit
            w.setframerate(SAMPLE_RATE)
            w.writeframes(render(freq))
        print(f"  {os.path.basename(path):32s} {freq:7.2f} Hz")

    print(f"\nXong: {len(NOTES)} file -> {out_dir}")


if __name__ == "__main__":
    main()
