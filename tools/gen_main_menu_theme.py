#!/usr/bin/env python3
"""
gen_main_menu_theme.py
Bộ tổng hợp âm thanh chuyên nghiệp: Nhạc nền chính (Main Menu Theme)
cho màn hình Menu Khởi Đầu / Sách Ma Thuật "MUSIC FOREST".

Phong cách âm nhạc:
- Tác phẩm: "Kỳ Diệu Rừng Nhạc" (The Magic Music Forest Overture).
- Không khí: Hoạt hình cổ tích (Ghibli / Disney Junior), ấm áp, kỳ diệu, tinh nghịch.
- 5 lớp phối khí hòa quyện (5 Orchestral Storybook Layers):
  1. Warm Concert Harp & Nylon Guitar (Rải arpeggio dịu dàng)
  2. Celesta & Glockenspiel Starlight (Chuông pha lê lấp lánh theo dải nốt xoay)
  3. Wooden Marimba & Pizzicato (Bước chân đồ chơi tinh nghịch của bé & chú sư tử)
  4. Mellow Bamboo Flute Lead (Giai điệu ngũ cung chào đón ngọt ngào)
  5. Warm Orchestral Pad Bed (Lớp đệm hòa âm êm ái, sâu lắng)

Kỹ thuật:
- Tempo: 84 BPM, Nhịp 4/4, 8 ô nhịp = 32 phách = 22.857 giây.
- Vòng hợp âm: C Maj9 -> F Maj7 -> Am9 -> Gsus4/G -> C Maj9 -> Em7 -> Fadd9 -> G7sus4 -> C.
- Không gian âm thanh: Stereo Panning đa chiều (Harp trái, Marimba phải, Celesta lượn vòng).
- Vòng lặp: 100% Seamless Loop toán học (tần số lượng tử hóa chính xác, không tiếng click).
- Chuẩn hóa: -14 dBFS đỉnh, xuất OGG Vorbis Stereo chất lượng cao bằng ffmpeg.
"""

import math
import os
import struct
import subprocess
import wave

SAMPLE_RATE = 44100
A4 = 440.0
BPM = 84.0
BEATS = 32  # 8 bars x 4 beats
LOOP_SECONDS = (BEATS * 60.0) / BPM  # 22.857142857 s

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

# 8 Hợp âm cho 8 Bars (mỗi bar 4 phách = 2.857s)
BAR_CHORDS = [
    ["C3", "G3", "D4", "E4", "B4"],  # Bar 1: C Maj9 (Rạng rỡ, kỳ ảo)
    ["F2", "C3", "A3", "C4", "E4"],  # Bar 2: F Maj7 (Bay bổng)
    ["A2", "E3", "G3", "C4", "B4"],  # Bar 3: Am9 (Đêm rừng đom đóm)
    ["G2", "D3", "G3", "C4", "D4"],  # Bar 4: Gsus4 -> G (Mong chờ)
    ["C3", "G3", "C4", "E4", "G4"],  # Bar 5: C Maj (Điệp khúc rộn ràng)
    ["E2", "B2", "G3", "D4", "G4"],  # Bar 6: Em7 (Êm dịu)
    ["F2", "C3", "G3", "A3", "C4"],  # Bar 7: Fadd9 (Tươi vui, bước chân tung tăng)
    ["G2", "F3", "G3", "C4", "D4"],  # Bar 8: G7sus4 -> Giải về C liền mạch
]

# Giai điệu Sáo Trúc Ngũ Cung (Flute Lead) cho 8 ô nhịp: (bar_idx, beat_in_bar, note, duration_beats)
FLUTE_MELODY = [
    # Bar 1: Chào đón Do - Re - Mi
    (0, 0.0, "G4", 1.5), (0, 1.5, "E4", 1.0), (0, 2.5, "G4", 1.5),
    # Bar 2: Bay lên La - Do5
    (1, 0.0, "A4", 1.5), (1, 1.5, "C5", 1.0), (1, 2.5, "A4", 1.5),
    # Bar 3: Lắng đọng Sol - Mi
    (2, 0.0, "G4", 1.0), (2, 1.0, "E4", 1.0), (2, 2.0, "D4", 1.0), (2, 3.0, "E4", 1.0),
    # Bar 4: Ngân câu mở đầu
    (3, 0.0, "G4", 2.5), (3, 2.5, "A4", 1.5),
    # Bar 5: Điệp khúc cao trào vui nhộn
    (4, 0.0, "C5", 1.5), (4, 1.5, "D5", 1.0), (4, 2.5, "C5", 1.5),
    # Bar 6: Nốt cao Cú và Voi (D5 - C5)
    (5, 0.0, "A4", 1.5), (5, 1.5, "G4", 1.0), (5, 2.5, "A4", 1.5),
    # Bar 7: Bước nhảy Sư tử - Gấu - Thỏ
    (6, 0.0, "E4", 1.0), (6, 1.0, "G4", 1.0), (6, 2.0, "E4", 1.0), (6, 3.0, "D4", 1.0),
    # Bar 8: Về nốt Đô ấm áp khép lại vòng lặp
    (7, 0.0, "C4", 3.0)
]

def bar_envelope(t: float, bar_idx: int, bar_dur: float, crossfade: float) -> float:
    center = (bar_idx + 0.5) * bar_dur
    d = abs((t - center + LOOP_SECONDS / 2.0) % LOOP_SECONDS - LOOP_SECONDS / 2.0)
    half = bar_dur / 2.0
    if d <= half - crossfade / 2.0:
        return 1.0
    if d >= half + crossfade / 2.0:
        return 0.0
    x = (d - (half - crossfade / 2.0)) / crossfade
    return 0.5 * (1.0 + math.cos(math.pi * x))

def synthesize_main_theme():
    print(f"Tổng hợp nhạc nền Main Menu ({LOOP_SECONDS:.2f} giây, {BPM} BPM, {BEATS} phách)...")
    bar_dur = LOOP_SECONDS / 8.0
    beat_dur = 60.0 / BPM
    num_samples = int(SAMPLE_RATE * LOOP_SECONDS)
    
    # Chuẩn bị tần số lượng tử hóa cho từng hợp âm
    chord_freqs = [
        [quantize(note_hz(note)) for note in chord] for chord in BAR_CHORDS
    ]

    # Khởi tạo buffer Stereo (kênh Trái và Phải)
    left_channel = [0.0] * num_samples
    right_channel = [0.0] * num_samples

    # =========================================================================
    # LỚP 1 & 5: PAD DÂY HÒA ÂM (WARM STRINGS) & CONCERT HARP BASS
    # =========================================================================
    crossfade = bar_dur * 0.45
    pad_partials = [(1.0, 0.90), (2.0, 0.40), (3.0, 0.15), (4.0, 0.06)]

    for i in range(num_samples):
        t = i / SAMPLE_RATE
        for b in range(8):
            env = bar_envelope(t, b, bar_dur, crossfade)
            if env <= 0.0:
                continue
            for f in chord_freqs[b]:
                for mult, amp in pad_partials:
                    wave_val = env * amp * math.sin(2.0 * math.pi * f * mult * t)
                    # Pad rải đều stereo rộng mở
                    left_channel[i] += wave_val * 0.16
                    right_channel[i] += wave_val * 0.16

    # =========================================================================
    # LỚP 1B: ĐÀN HẠC & GUITAR GẢY ARPEGGIO (HARP PLUCKS - PAN TRÁI 30%)
    # =========================================================================
    # Mỗi phách gảy 2 nốt móc đơn (eighth notes)
    arp_interval = beat_dur / 2.0
    total_arps = int(LOOP_SECONDS / arp_interval)
    
    for a in range(total_arps):
        start_t = a * arp_interval
        bar_idx = min(7, int(start_t / bar_dur))
        chord = chord_freqs[bar_idx]
        note_idx = a % len(chord)
        note_freq = chord[note_idx]
        
        # Pluck duration ~ 1.2s decay
        start_sample = int(start_t * SAMPLE_RATE)
        dur_samples = int(1.2 * SAMPLE_RATE)
        for s in range(dur_samples):
            idx = (start_sample + s) % num_samples
            local_t = s / SAMPLE_RATE
            decay = math.exp(-local_t * 3.8)
            # Họa âm dây gảy mộc
            sig = decay * (
                1.00 * math.sin(2.0 * math.pi * note_freq * local_t) +
                0.40 * math.sin(2.0 * math.pi * (note_freq * 2.0) * local_t) +
                0.15 * math.sin(2.0 * math.pi * (note_freq * 3.0) * local_t)
            )
            # Panning nghiêng trái: 70% Left, 30% Right
            left_channel[idx] += sig * 0.18 * 0.70
            right_channel[idx] += sig * 0.18 * 0.30

    # =========================================================================
    # LỚP 2: CELESTA & BỤI SAO LẤP LÁNH (SWIRLING CELESTA CHIMES - PAN ĐA CHIỀU)
    # =========================================================================
    # Celesta rải những nốt cao lấp lánh ở phách 2 và 4
    for b_idx in range(BEATS):
        beat_t = b_idx * beat_dur
        # Chỉ đánh các phách lấp lánh (2 và 4 của mỗi bar)
        if (b_idx % 4) in [1, 3]:
            bar_i = min(7, int(beat_t / bar_dur))
            chord = chord_freqs[bar_i]
            # Nốt cao nhất quãng 8 trên
            top_freq = chord[-1] * 2.0
            pan_angle = (b_idx / 4.0) * math.pi
            pan_l = 0.5 + 0.4 * math.cos(pan_angle)
            pan_r = 0.5 - 0.4 * math.cos(pan_angle)
            
            start_s = int(beat_t * SAMPLE_RATE)
            dur_s = int(1.6 * SAMPLE_RATE)
            for s in range(dur_s):
                idx = (start_s + s) % num_samples
                local_t = s / SAMPLE_RATE
                bell_decay = math.exp(-local_t * 4.5)
                # Bội âm kim loại trong trẻo (1.0, 2.76, 5.4)
                bell = bell_decay * (
                    1.00 * math.sin(2.0 * math.pi * top_freq * local_t) +
                    0.28 * math.sin(2.0 * math.pi * (top_freq * 2.76) * local_t) +
                    0.12 * math.sin(2.0 * math.pi * (top_freq * 5.4) * local_t)
                )
                left_channel[idx] += bell * 0.12 * pan_l
                right_channel[idx] += bell * 0.12 * pan_r

    # =========================================================================
    # LỚP 3: MARIMBA GỖ & PIZZICATO ĐỒ CHƠI (TICK-TOCK PLAYFUL - PAN PHẢI 25%)
    # =========================================================================
    for b_idx in range(BEATS):
        beat_t = b_idx * beat_dur
        bar_i = min(7, int(beat_t / bar_dur))
        root_freq = chord_freqs[bar_i][0] * 0.5  # Âm bass mộc
        start_s = int(beat_t * SAMPLE_RATE)
        dur_s = int(0.45 * SAMPLE_RATE)
        for s in range(dur_s):
            idx = (start_s + s) % num_samples
            local_t = s / SAMPLE_RATE
            pizz_decay = math.exp(-local_t * 9.5)
            pizz = pizz_decay * (
                1.00 * math.sin(2.0 * math.pi * root_freq * local_t) +
                0.35 * math.sin(2.0 * math.pi * (root_freq * 2.0) * local_t)
            )
            # Panning nghiêng phải: 35% Left, 65% Right
            left_channel[idx] += pizz * 0.14 * 0.35
            right_channel[idx] += pizz * 0.14 * 0.65

    # =========================================================================
    # LỚP 4: SÁO TRÚC MỘC (MELLOW FLUTE LEAD - CENTER STAGE)
    # =========================================================================
    for bar_num, beat_offset, note_str, dur_b in FLUTE_MELODY:
        start_t = (bar_num * 4.0 + beat_offset) * beat_dur
        freq = quantize(note_hz(note_str))
        dur_s = int(dur_b * beat_dur * SAMPLE_RATE)
        start_s = int(start_t * SAMPLE_RATE)
        
        for s in range(dur_s):
            idx = (start_s + s) % num_samples
            local_t = s / SAMPLE_RATE
            note_dur_sec = dur_b * beat_dur
            
            # Envelope sáo trúc: attack 40ms, sustain êm, release 80ms
            if local_t < 0.04:
                env = local_t / 0.04
            elif local_t > note_dur_sec - 0.08:
                env = max(0.0, (note_dur_sec - local_t) / 0.08)
            else:
                env = 1.0
                
            # Vibrato nhẹ 5.2Hz bắt đầu sau 0.15s
            vib_depth = 0.006 * max(0.0, min(1.0, (local_t - 0.15) / 0.3))
            vib = 1.0 + vib_depth * math.sin(2.0 * math.pi * 5.2 * local_t)
            phase = 2.0 * math.pi * freq * vib * local_t
            
            # Harmonics của sáo trúc
            flute_wave = (
                1.00 * math.sin(phase) +
                0.32 * math.sin(2.0 * phase) +
                0.14 * math.sin(3.0 * phase) +
                0.05 * math.sin(4.0 * phase)
            )
            # Center stage: 50% Left, 50% Right
            lead_val = env * flute_wave * 0.22
            left_channel[idx] += lead_val * 0.50
            right_channel[idx] += lead_val * 0.50

    # =========================================================================
    # MASTERING & NORMALIZE VỀ -14 dBFS PEAK (Target peak = 0.20)
    # =========================================================================
    max_peak = 0.0
    for i in range(num_samples):
        max_peak = max(max_peak, abs(left_channel[i]), abs(right_channel[i]))

    TARGET_PEAK = 0.85  # -1.4 dBFS (chuẩn studio đầy đặn, rõ nét, không bị chìm)
    norm = TARGET_PEAK / max_peak if max_peak > 0 else 1.0

    print(f"Peak ban đầu: {max_peak:.3f} -> Chuẩn hóa về -1.4 dBFS (Hệ số: {norm:.3f})")

    # Ghép 2 kênh thành Stereo interleaved 16-bit PCM
    stereo_pcm = bytearray()
    for i in range(num_samples):
        l_val = int(max(-1.0, min(1.0, left_channel[i] * norm)) * 32767)
        r_val = int(max(-1.0, min(1.0, right_channel[i] * norm)) * 32767)
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
bpm=84.0
beat_count=32
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

    pcm_data = synthesize_main_theme()

    # Ghi WAV Stereo
    with wave.open(wav_path, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        w.writeframes(pcm_data)

    print(f"Đã tạo WAV trung gian: {os.path.getsize(wav_path) // 1024} KB")

    # Chuyển đổi sang Vorbis OGG Stereo
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

    file_size_kb = os.path.getsize(ogg_path) // 1024
    print("==================================================================")
    print(f" THÀNH CÔNG: Đã xuất bản nhạc nền Main Menu đỉnh cao:")
    print(f" -> {ogg_path}")
    print(f" Kích thước: {file_size_kb} KB | Thời lượng: {LOOP_SECONDS:.2f}s | Nhịp: {BPM} BPM")
    print("==================================================================")

if __name__ == "__main__":
    main()
