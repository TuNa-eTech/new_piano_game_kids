#!/usr/bin/env python3
"""
Bộ tạo âm thanh hoạt hình hữu cơ dịu nhẹ (Organic Cartoon SFX Generator)
Sử dụng chuẩn thư viện Python thuần (wave, math, struct) - không cần dependencies.
Sinh 5 file SFX chất lượng cao 16-bit 44.1kHz cho game thiếu nhi Rừng Nhạc.
"""

import math
import struct
import wave
import os

SAMPLE_RATE = 44100

def write_wav(filename: str, samples: list[float]):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)      # Mono
        wav_file.setsampwidth(2)     # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        raw_data = bytearray()
        for s in samples:
            # Clamp to [-1.0, 1.0]
            val = max(-1.0, min(1.0, s))
            int_val = int(val * 32767.0)
            raw_data.extend(struct.pack('<h', int_val))
        wav_file.writeframes(raw_data)
    print(f"Generated: {filename} ({len(samples)} samples, {len(samples)/SAMPLE_RATE:.2f}s)")

def gen_soft_boing():
    # Tiếng nảy nhún đàn hồi mềm mại (soft marshmallow boing)
    duration = 0.28
    total_samples = int(duration * SAMPLE_RATE)
    samples = []
    
    phase = 0.0
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        progress = t / duration
        
        # Đường cong cao độ: 260Hz -> 510Hz rồi nảy nhẹ về 440Hz
        if progress < 0.45:
            freq = 260.0 + (510.0 - 260.0) * (progress / 0.45) ** 0.8
        else:
            p2 = (progress - 0.45) / 0.55
            freq = 510.0 - (510.0 - 440.0) * math.sin(p2 * math.pi * 0.5)
            
        phase += 2.0 * math.pi * freq / SAMPLE_RATE
        
        # Envelope: Attack êm 8ms, Decay tự nhiên
        if t < 0.008:
            env = t / 0.008
        else:
            env = math.exp(-(t - 0.008) * 9.5)
            
        # Sóng sine mềm + 20% harmonic bậc 2 tạo độ ấm mộc
        sig = math.sin(phase) + 0.22 * math.sin(phase * 2.0)
        samples.append(sig * env * 0.45)
        
    return samples

def gen_fairy_dust():
    # Tiếng bụi sao lấp lánh li ti (glittering fairy sparkle cascade)
    duration = 0.55
    total_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * total_samples
    
    # 5 nốt chuông sao ngũ cung cao vút
    sparkle_notes = [
        (0.00, 1760.0, 0.35), # A6
        (0.04, 2093.0, 0.40), # C7
        (0.09, 2637.0, 0.45), # E7
        (0.15, 3135.0, 0.42), # G7
        (0.22, 3520.0, 0.38), # A7
        (0.28, 4186.0, 0.30), # C8
    ]
    
    for start_t, freq, amp in sparkle_notes:
        start_idx = int(start_t * SAMPLE_RATE)
        note_dur = 0.26
        note_samples = int(note_dur * SAMPLE_RATE)
        
        phase = 0.0
        for i in range(note_samples):
            idx = start_idx + i
            if idx >= total_samples:
                break
            t_note = i / SAMPLE_RATE
            
            # Shimmer vibrato
            vib = 1.0 + 0.008 * math.sin(2.0 * math.pi * 14.0 * t_note)
            phase += 2.0 * math.pi * (freq * vib) / SAMPLE_RATE
            
            # Bell envelope: Fast attack 2ms, exponential ring-out
            if t_note < 0.003:
                env = t_note / 0.003
            else:
                env = math.exp(-(t_note - 0.003) * 12.0)
                
            val = (math.sin(phase) + 0.15 * math.sin(phase * 2.7)) * env * amp * 0.28
            samples[idx] += val
            
    return samples

def gen_giggle_cute():
    # Tiếng cười khúc khích đáng yêu "Hi-hi!"
    duration = 0.38
    total_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * total_samples
    
    # 2 xung cười: syllable 1 (0.00s) và syllable 2 (0.15s)
    pulses = [
        (0.02, 0.11, 640.0, 780.0, 0.38),
        (0.16, 0.13, 720.0, 890.0, 0.42),
    ]
    
    for start_t, dur, f_start, f_end, amp in pulses:
        start_idx = int(start_t * SAMPLE_RATE)
        pulse_samples = int(dur * SAMPLE_RATE)
        
        phase = 0.0
        for i in range(pulse_samples):
            idx = start_idx + i
            if idx >= total_samples:
                break
            t_p = i / SAMPLE_RATE
            p_prog = t_p / dur
            
            # Pitch rises playfully during chuckle
            freq = f_start + (f_end - f_start) * (p_prog ** 0.9)
            phase += 2.0 * math.pi * freq / SAMPLE_RATE
            
            # Bell/speech envelope
            env = math.sin(p_prog * math.pi) ** 1.5
            val = (math.sin(phase) + 0.18 * math.sin(phase * 2.0)) * env * amp * 0.35
            samples[idx] += val
            
    return samples

def gen_soft_plop():
    # Tiếng ngã lăn nhào lộn êm ái trên đệm rêu ("plop / bloop")
    duration = 0.18
    total_samples = int(duration * SAMPLE_RATE)
    samples = []
    
    phase = 0.0
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        prog = t / duration
        
        # Tần số quét xuống từ 240Hz -> 110Hz (tiếng đệm mút)
        freq = 240.0 * math.exp(-prog * 1.8)
        phase += 2.0 * math.pi * freq / SAMPLE_RATE
        
        # Envelope: Attack 4ms, Decay êm ái
        if t < 0.004:
            env = t / 0.004
        else:
            env = math.exp(-(t - 0.004) * 16.0)
            
        sig = math.sin(phase) * env * 0.42
        samples.append(sig)
        
    return samples

def gen_cute_purr():
    # Tiếng thở rừ rừ êm dịu của mèo con khi cuộn tròn ngủ
    duration = 0.60
    total_samples = int(duration * SAMPLE_RATE)
    samples = []
    
    phase_car = 0.0
    phase_mod = 0.0
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        prog = t / duration
        
        # Carrier: 105Hz, Tremor modulator: 22Hz
        phase_car += 2.0 * math.pi * 105.0 / SAMPLE_RATE
        phase_mod += 2.0 * math.pi * 22.0 / SAMPLE_RATE
        
        tremor = 0.5 + 0.5 * math.sin(phase_mod)
        # Envelope: thở vào nhẹ rồi thở ra êm
        env = math.sin(prog * math.pi) ** 1.3
        
        sig = (math.sin(phase_car) + 0.15 * math.sin(phase_car * 2.0)) * tremor * env * 0.28
        samples.append(sig)
        
    return samples

def main():
    target_dir = "assets/audio"
    write_wav(os.path.join(target_dir, "sfx_soft_boing.wav"), gen_soft_boing())
    write_wav(os.path.join(target_dir, "sfx_fairy_dust.wav"), gen_fairy_dust())
    write_wav(os.path.join(target_dir, "sfx_giggle_cute.wav"), gen_giggle_cute())
    write_wav(os.path.join(target_dir, "sfx_soft_plop.wav"), gen_soft_plop())
    write_wav(os.path.join(target_dir, "sfx_cute_purr.wav"), gen_cute_purr())
    print("=== TOÀN BỘ 5 FILE SFX HOẠT HÌNH HỮU CƠ ĐÃ ĐƯỢC TẠO XONG ===")

if __name__ == "__main__":
    main()
