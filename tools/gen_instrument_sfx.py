#!/usr/bin/env python3
"""
Bộ tổng hợp âm thanh SFX cho nhạc cụ Main Menu:
1. sfx_accordion_breath.wav: Hợp âm đàn accordion / phong cầm ấm áp kèm tiếng thở nếp gấp
2. sfx_violin_pluck.wav: Tiếng gảy dây đàn violin mộc (pizzicato) ấm áp, ngân vang
3. sfx_harp_chime.wav: Tiếng rải đàn hạc thần tiên trong trẻo
"""

import math
import struct
import wave
import os
import random

SAMPLE_RATE = 44100

def write_wav(filename: str, samples: list):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)      # Mono
        wav_file.setsampwidth(2)     # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        raw_data = bytearray()
        for s in samples:
            val = max(-1.0, min(1.0, s))
            int_val = int(val * 32767.0)
            raw_data.extend(struct.pack('<h', int_val))
        wav_file.writeframes(raw_data)
    print(f"Generated: {filename} ({len(samples)} samples, {len(samples)/SAMPLE_RATE:.2f}s)")

def gen_accordion_breath():
    # Hợp âm C trưởng (C4, E4, G4, C5) với âm sắc đặc trưng của lưỡi gà (reed) và tiếng gió nhẹ
    duration = 0.65
    total_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * total_samples
    
    notes = [261.63, 329.63, 392.00, 523.25]
    rng = random.Random(123)
    
    for note_idx, freq in enumerate(notes):
        phase = 0.0
        # Nhẹ nhàng điều chế vibrato nhẹ của nếp gấp
        vib_phase = 0.0
        for i in range(total_samples):
            t = i / SAMPLE_RATE
            vib = math.sin(vib_phase) * 1.5
            vib_phase += 2.0 * math.pi * 5.0 / SAMPLE_RATE
            
            curr_freq = freq + vib
            phase += 2.0 * math.pi * curr_freq / SAMPLE_RATE
            
            # Phong cầm có nhiều họa âm bậc lẻ và bậc chẵn
            sig = (
                math.sin(phase) * 0.40 +
                math.sin(phase * 2.0) * 0.25 +
                math.sin(phase * 3.0) * 0.18 +
                math.sin(phase * 4.0) * 0.10 +
                math.sin(phase * 5.0) * 0.05
            )
            
            # Envelope: Phồng lên êm ái (bellows push) rồi ngân nhẹ
            if t < 0.08:
                env = (t / 0.08) ** 1.2
            else:
                env = math.exp(-(t - 0.08) * 3.8)
                
            samples[i] += sig * env * 0.18
            
    # Thêm tiếng thở gió dịu nhẹ (air puff của nếp gấp)
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        noise = (rng.random() * 2.0 - 1.0)
        # Bellows air envelope
        if t < 0.06:
            air_env = (t / 0.06) * 0.04
        else:
            air_env = math.exp(-(t - 0.06) * 6.0) * 0.04
        samples[i] += noise * air_env
        
    return samples

def gen_violin_pluck():
    # Tiếng gảy dây vĩ cầm (violin pizzicato) với cộng hưởng thùng đàn gỗ
    duration = 0.50
    total_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * total_samples
    
    # Nốt La 4 (440Hz) kết hợp họa âm thân gỗ
    freq = 440.0
    phase = 0.0
    phase_wood = 0.0
    wood_freq = 280.0 # Tần số cộng hưởng thùng đàn
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        phase += 2.0 * math.pi * freq / SAMPLE_RATE
        phase_wood += 2.0 * math.pi * wood_freq / SAMPLE_RATE
        
        # Sóng gảy dây có attack bén rồi tắt nhanh
        # Họa âm dây đàn
        sig_string = (
            math.sin(phase) * 0.50 +
            math.sin(phase * 2.0) * 0.30 +
            math.sin(phase * 3.0) * 0.18 +
            math.sin(phase * 4.0) * 0.08
        )
        # Tiếng gõ ngón vào dây & thùng gỗ (thump ban đầu)
        sig_wood = math.sin(phase_wood) * 0.35
        
        # Envelope: Attack 2ms cực bén
        if t < 0.002:
            env_string = t / 0.002
            env_wood = t / 0.002
        else:
            env_string = math.exp(-(t - 0.002) * 8.5)
            env_wood = math.exp(-(t - 0.002) * 35.0) # Thump tắt cực nhanh
            
        samples[i] = (sig_string * env_string * 0.45) + (sig_wood * env_wood * 0.25)
        
    return samples

def gen_harp_chime():
    # Tiếng rải đàn hạc thần tiên (glissando 5 nốt ngũ cung cao vút)
    duration = 0.70
    total_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * total_samples
    
    # Các nốt chuông đàn hạc: C5, E5, G5, C6, E6
    notes = [
        (0.00, 523.25, 0.45),
        (0.06, 659.25, 0.42),
        (0.12, 783.99, 0.40),
        (0.18, 1046.50, 0.36),
        (0.24, 1318.51, 0.32),
    ]
    
    for start_t, freq, amp in notes:
        start_idx = int(start_t * SAMPLE_RATE)
        phase = 0.0
        for i in range(start_idx, total_samples):
            t = (i - start_idx) / SAMPLE_RATE
            phase += 2.0 * math.pi * freq / SAMPLE_RATE
            
            # Sóng dây hạc: sine mượt + họa âm sáng bậc 2 và 3
            sig = math.sin(phase) * 0.65 + math.sin(phase * 2.0) * 0.25 + math.sin(phase * 3.0) * 0.10
            
            # Envelope: Attack 3ms, decay ngân dài dịu êm
            if t < 0.003:
                env = t / 0.003
            else:
                env = math.exp(-(t - 0.003) * 5.0)
                
            samples[i] += sig * env * amp * 0.40
            
    return samples

if __name__ == "__main__":
    base_dir = "assets/audio"
    print("=== Dang tong hop bo SFX nhac cu Main Menu ===")
    write_wav(os.path.join(base_dir, "sfx_accordion_breath.wav"), gen_accordion_breath())
    write_wav(os.path.join(base_dir, "sfx_violin_pluck.wav"), gen_violin_pluck())
    write_wav(os.path.join(base_dir, "sfx_harp_chime.wav"), gen_harp_chime())
    print("=== Hoan tat tong hop am thanh ===")
