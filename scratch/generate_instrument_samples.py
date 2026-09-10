#!/usr/bin/env python3
"""
generate_instrument_samples.py
Physical acoustic synthesis for 3 Chapter Instruments:
- Chapter 1: Sáo Trúc (Bamboo Flute)
- Chapter 2: Đàn Kalimba (Thumb Piano / Mbira)
- Chapter 3: Chuông Gió & Celesta (Wind Chimes / Metallophone)

7 Major Pentatonic Pitches:
C4 (261.63 Hz), D4 (293.66 Hz), E4 (329.63 Hz), G4 (392.00 Hz),
A4 (440.00 Hz), C5 (523.25 Hz), D5 (587.33 Hz)

16-bit 44.1kHz Mono PCM WAV, uncompressed for zero-latency playback.
"""

import os
import wave
import struct
import numpy as np

SAMPLE_RATE = 44100

PENTATONIC_NOTES = [
    ("c4", 261.626),
    ("d4", 293.665),
    ("e4", 329.628),
    ("g4", 391.995),
    ("a4", 440.000),
    ("c5", 523.251),
    ("d5", 587.330),
]

def save_wav(filename, samples):
    # Normalize to -1.5 dB peak to prevent clipping and maintain headroom
    peak = np.max(np.abs(samples))
    if peak > 0:
        samples = samples * (0.84 / peak)
    
    # 16-bit PCM conversion
    int_samples = (samples * 32767.0).astype(np.int16)
    
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(int_samples.tobytes())
    print(f"Saved: {filename} ({len(int_samples)/SAMPLE_RATE:.2f}s)")

def make_godot_import(wav_path):
    import_path = f"{wav_path}.import"
    rel_path = wav_path.replace("/Users/anhtu/MySpace/new-piano/", "").replace("./", "")
    content = f"""[remap]

importer="wav"
type="AudioStreamWAV"
uid="uid://{rel_path.replace('/', '_').replace('.', '_')}"
path="res://.godot/imported/{os.path.basename(wav_path)}-{os.path.basename(wav_path).replace('.wav', '')}.sample"

[deps]

source_file="res://{rel_path}"
dest_files=["res://.godot/imported/{os.path.basename(wav_path)}-{os.path.basename(wav_path).replace('.wav', '')}.sample"]

[params]

force/8_bit=false
force/mono=false
force/max_rate=false
force/max_rate_hz=44100
edit/trim=false
edit/normalize=false
edit/loop_mode=0
edit/loop_begin=0
edit/loop_end=-1
compress/mode=0
"""
    with open(import_path, 'w') as f:
        f.write(content)

# -------------------------------------------------------------
# 1. SÁO TRÚC (Bamboo Flute)
# -------------------------------------------------------------
def synth_flute(freq, duration=1.7):
    num_samples = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, num_samples, endpoint=False)
    
    # Subtle pitch vibrato (starts after 0.2s, 5.2 Hz rate)
    vibrato_env = np.clip((t - 0.2) / 0.5, 0.0, 1.0)
    vibrato = 1.0 + 0.008 * vibrato_env * np.sin(2 * np.pi * 5.2 * t)
    phase = 2 * np.pi * np.cumsum(freq * vibrato) / SAMPLE_RATE
    
    # Harmonics: Woodwind with open/stopped resonance
    # Strong fundamental, mellow 2nd, warm 3rd, soft 4th and 5th
    harmonics = (
        1.00 * np.sin(phase) +
        0.35 * np.sin(2 * phase) +
        0.22 * np.sin(3 * phase) +
        0.08 * np.sin(4 * phase) +
        0.05 * np.sin(5 * phase)
    )
    
    # Breath noise (pink noise filtered around 2.2 kHz)
    noise = np.random.randn(num_samples)
    # Simple lowpass / bandpass smoothing
    breath = np.convolve(noise, np.ones(8)/8.0, mode='same')
    breath_env = np.exp(-t * 3.5) * 0.25 + 0.04 * np.exp(-t * 1.5)
    
    # ADSR Envelope for gentle breath onset
    attack_samples = int(0.04 * SAMPLE_RATE)
    envelope = np.ones(num_samples)
    envelope[:attack_samples] = 0.5 * (1.0 - np.cos(np.pi * np.arange(attack_samples) / attack_samples))
    envelope[attack_samples:] = np.exp(-(t[attack_samples:] - 0.04) * 1.8)
    
    # Combine tone and breath
    signal = (harmonics + breath * breath_env) * envelope
    return signal

# -------------------------------------------------------------
# 2. ĐÀN KALIMBA (Thumb Piano / Mbira)
# -------------------------------------------------------------
def synth_kalimba(freq, duration=1.9):
    num_samples = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, num_samples, endpoint=False)
    
    # Pluck attack transient (metallic click 8ms)
    click_dur = int(0.012 * SAMPLE_RATE)
    click = np.zeros(num_samples)
    click[:click_dur] = np.random.randn(click_dur) * np.linspace(1.0, 0.0, click_dur)**2
    
    # Clamped metal tine physics:
    # Fundamental + inharmonic tine overtone (~5.8x fundamental, rapid decay)
    f0 = freq
    f_tine = f0 * 5.82
    
    # Tone components with distinct decay rates
    fundamental = np.sin(2 * np.pi * f0 * t) * np.exp(-t * 2.2)
    overtone = 0.35 * np.sin(2 * np.pi * f_tine * t) * np.exp(-t * 12.0)
    second_harmonic = 0.15 * np.sin(2 * np.pi * 2.0 * f0 * t) * np.exp(-t * 4.5)
    
    # Warm wooden soundbox body resonance (175 Hz bump)
    box_res = 0.20 * np.sin(2 * np.pi * 175.0 * t) * np.exp(-t * 6.0)
    
    # Attack ramp (3ms to prevent DC click)
    attack_samples = int(0.003 * SAMPLE_RATE)
    attack_ramp = np.ones(num_samples)
    attack_ramp[:attack_samples] = np.linspace(0.0, 1.0, attack_samples)
    
    signal = (fundamental + overtone + second_harmonic + box_res + 0.18 * click) * attack_ramp
    return signal

# -------------------------------------------------------------
# 3. CHUÔNG GIÓ & CELESTA (Wind Chimes / Metallophone)
# -------------------------------------------------------------
def synth_chimes(freq, duration=2.4):
    num_samples = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, num_samples, endpoint=False)
    
    # Free-hanging tube / bell partials:
    # 1.0, 2.756, 5.404, 8.933 (Euler-Bernoulli beam theory)
    partials = [
        (1.000, 1.00, 1.4),   # Fundamental (slow decay)
        (2.756, 0.55, 2.8),   # 1st overtone (bright sparkle)
        (5.404, 0.30, 4.5),   # 2nd overtone (crystalline ring)
        (8.933, 0.12, 7.0),   # 3rd overtone (glass shimmer)
    ]
    
    signal = np.zeros(num_samples)
    for ratio, amp, decay_rate in partials:
        p_freq = freq * ratio
        # Avoid aliasing above Nyquist
        if p_freq < SAMPLE_RATE * 0.45:
            # Dual-beating chorus for natural chime movement (2.3 Hz beating)
            tone1 = np.sin(2 * np.pi * p_freq * t)
            tone2 = np.sin(2 * np.pi * (p_freq + 2.3) * t)
            signal += amp * (tone1 + 0.4 * tone2) * np.exp(-t * decay_rate)
    
    # Mallet strike click (4ms bright impulse)
    mallet_samples = int(0.006 * SAMPLE_RATE)
    mallet = np.zeros(num_samples)
    mallet[:mallet_samples] = np.sin(2 * np.pi * 3500.0 * t[:mallet_samples]) * np.linspace(1.0, 0.0, mallet_samples)
    
    # Attack smoothing
    attack_samples = int(0.002 * SAMPLE_RATE)
    attack_ramp = np.ones(num_samples)
    attack_ramp[:attack_samples] = np.linspace(0.0, 1.0, attack_samples)
    
    signal = (signal + 0.25 * mallet) * attack_ramp
    return signal


def main():
    base_dir = "/Users/anhtu/MySpace/new-piano/assets/audio/instruments"
    
    instruments = [
        ("ch1_flute", "flute", synth_flute),
        ("ch2_kalimba", "kalimba", synth_kalimba),
        ("ch3_chimes", "chimes", synth_chimes),
    ]
    
    total_generated = 0
    for folder, prefix, synth_func in instruments:
        out_dir = os.path.join(base_dir, folder)
        os.makedirs(out_dir, exist_ok=True)
        
        for idx, (note_name, freq) in enumerate(PENTATONIC_NOTES):
            out_file = os.path.join(out_dir, f"{prefix}_{idx}_{note_name}.wav")
            audio_data = synth_func(freq)
            save_wav(out_file, audio_data)
            make_godot_import(out_file)
            total_generated += 1
            
    print(f"\nSuccessfully generated {total_generated} acoustic instrument samples!")

if __name__ == "__main__":
    main()
