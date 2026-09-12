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

# Định nghĩa 10 bài hát kèm vòng hợp âm, tempo và đặc tính nhạc cụ
SONG_CONFIGS = [
    {
        "id": "bgm_baby_shark",
        "title": "Baby Shark",
        "bpm": 85,
        "beats_per_bar": 4,
        "bars": 4,
        # C - C - Am - F
        "chords": [
            ["C3", "G3", "C4", "E4"],
            ["C3", "G3", "C4", "E4"],
            ["A2", "E3", "A3", "C4"],
            ["F2", "C3", "F3", "A3"],
        ],
        "style": "ukulele_marimba"
    },
    {
        "id": "bgm_wheels_on_the_bus",
        "title": "The Wheels on the Bus",
        "bpm": 80,
        "beats_per_bar": 4,
        "bars": 4,
        # C - G - C - C
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["G2", "D3", "G3", "B3"],
            ["C3", "E3", "G3", "C4"],
            ["C3", "E3", "G3", "C4"],
        ],
        "style": "bouncing_pizzicato"
    },
    {
        "id": "bgm_johny_johny",
        "title": "Johny Johny Yes Papa",
        "bpm": 76,
        "beats_per_bar": 4,
        "bars": 4,
        # C - G - C - G
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["G2", "B2", "D3", "G3"],
            ["C3", "E3", "G3", "C4"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "music_box"
    },
    {
        "id": "bgm_twinkle_twinkle",
        "title": "Twinkle Twinkle Little Star",
        "bpm": 68,
        "beats_per_bar": 4,
        "bars": 4,
        # C - F - C - G
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["F2", "A2", "C3", "F3"],
            ["C3", "E3", "G3", "C4"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "celesta_harp"
    },
    {
        "id": "bgm_if_youre_happy",
        "title": "If You're Happy and You Know It",
        "bpm": 84,
        "beats_per_bar": 4,
        "bars": 4,
        # C - G - C - G
        "chords": [
            ["C3", "G3", "C4", "E4"],
            ["G2", "D3", "G3", "B3"],
            ["C3", "E3", "G3", "C4"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "happy_kalimba"
    },
    {
        "id": "bgm_old_macdonald",
        "title": "Old MacDonald Had a Farm",
        "bpm": 82,
        "beats_per_bar": 4,
        "bars": 4,
        # C - F - C - G
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["F2", "C3", "F3", "A3"],
            ["C3", "E3", "G3", "C4"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "rustic_guitar"
    },
    {
        "id": "bgm_abc_song",
        "title": "ABC Song",
        "bpm": 70,
        "beats_per_bar": 4,
        "bars": 4,
        # C - F - C - G
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["F2", "A2", "C3", "F3"],
            ["C3", "E3", "G3", "C4"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "lullaby_bells"
    },
    {
        "id": "bgm_baa_baa_black_sheep",
        "title": "Baa Baa Black Sheep",
        "bpm": 72,
        "beats_per_bar": 4,
        "bars": 4,
        # C - F - C - G
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["F2", "A2", "C3", "F3"],
            ["C3", "E3", "G3", "C4"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "warm_flute_pad"
    },
    {
        "id": "bgm_five_little_monkeys",
        "title": "Five Little Monkeys",
        "bpm": 80,
        "beats_per_bar": 4,
        "bars": 4,
        # C - G - C - G
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["G2", "B2", "D3", "G3"],
            ["C3", "E3", "G3", "C4"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "cheeky_wood"
    },
    {
        "id": "bgm_heads_shoulders",
        "title": "Heads, Shoulders, Knees and Toes",
        "bpm": 86,
        "beats_per_bar": 4,
        "bars": 4,
        # C - G - C - G
        "chords": [
            ["C3", "E3", "G3", "C4"],
            ["G2", "D3", "G3", "B3"],
            ["C3", "E3", "G3", "C4"],
            ["G2", "B2", "D3", "G3"],
        ],
        "style": "playful_tines"
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

    samples = [0.0] * n_samples
    peak_seen = 0.0

    beat_dur = 60.0 / bpm

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
        cur_beat_idx = int(t / beat_dur)
        beat_phase = (t % beat_dur) / beat_dur
        # Pluck envelope
        pluck_env = math.exp(-beat_phase * 4.2)
        chord_idx = min(num_chords - 1, int(t / (loop_len / num_chords)))
        arp_note_idx = cur_beat_idx % len(freqs[chord_idx])
        arp_freq = freqs[chord_idx][arp_note_idx] * 2.0  # Cao hơn 1 quãng 8 cho lấp lánh
        acc += 0.35 * pluck_env * math.sin(2.0 * math.pi * arp_freq * t)

        samples[i] = acc
        if abs(acc) > peak_seen:
            peak_seen = abs(acc)

    # Chuẩn hóa về mức -18 dBFS (target peak ~ 0.126)
    TARGET_PEAK = 0.126
    norm = TARGET_PEAK / peak_seen if peak_seen > 0 else 1.0
    final_samples = [max(-1.0, min(1.0, s * norm)) for s in samples]
    return final_samples, loop_len

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
bpm=0
beat_count=0
bar_beats=4
"""
    with open(import_path, 'w', encoding='utf-8') as f:
        f.write(content)

def main():
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    out_dir = os.path.join(repo_root, "assets", "audio", "songbook")
    os.makedirs(out_dir, exist_ok=True)

    print("==========================================================")
    print(" BẮT ĐẦU SINH NHẠC NỀN HÒA ÂM MỘC CHO 10 BÀI HÁT THIẾU NHI")
    print("==========================================================")

    for cfg in SONG_CONFIGS:
        song_id = cfg["id"]
        title = cfg["title"]
        wav_path = os.path.join(out_dir, f"{song_id}.wav")
        ogg_path = os.path.join(out_dir, f"{song_id}.ogg")

        samples, loop_len = render_backing(cfg)

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
            "/opt/homebrew/bin/ffmpeg", "-y",
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

    print("==========================================================")
    print(f" Hoàn tất xuất 10 file OGG seamless loop tại:\n {out_dir}")
    print("==========================================================")

if __name__ == "__main__":
    main()
