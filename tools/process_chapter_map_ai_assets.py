#!/usr/bin/env python3
"""
Process raw AI generated assets for Screen 04: Chapter Selection Map
Outputs:
- assets/art/tex_bg_chapter_forest.png (1376x768)
- assets/art/card_ch1_flute.png
- assets/art/card_ch2_kalimba.png
- assets/art/card_ch3_chimes.png
- assets/art/spr_star_jar_cradle.png
- assets/art/spr_padlock_brass.png
- assets/art/spr_leather_belt_strap.png
- assets/art/ui_banner_ribbon_title.png
- assets/audio/sfx_padlock_rattle.wav
"""

import os
import math
import wave
import struct
import numpy as np
from PIL import Image, ImageFilter

ARTIFACT_DIR = "/Users/anhtu/.gemini/antigravity-ide/brain/19075892-5377-470a-8cfb-dc01a119d4c6"
BG_SRC = os.path.join(ARTIFACT_DIR, "chapter_map_bg_1789481024426.jpg")
CARDS_SRC = os.path.join(ARTIFACT_DIR, "chapter_cards_trio_1789481062808.jpg")
STAR_JAR_SRC = os.path.join(ARTIFACT_DIR, "star_jar_cradle_1789481105785.jpg")
LOCK_STRAP_SRC = os.path.join(ARTIFACT_DIR, "padlock_and_strap_1789481150957.jpg")
BANNER_SRC = os.path.join(ARTIFACT_DIR, "chapter_map_banner_1789481218498.jpg")

OUT_ART = "assets/art"
OUT_AUDIO = "assets/audio"


def remove_white_bg(img: Image.Image, threshold: float = 0.94, feather: int = 2) -> Image.Image:
    """Removes pure/near-white background and produces smooth alpha channel."""
    rgba = img.convert("RGBA")
    arr = np.array(rgba, dtype=np.float32) / 255.0
    r, g, b, a = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2], arr[:, :, 3]
    
    # Distance to pure white
    dist = np.sqrt((1.0 - r)**2 + (1.0 - g)**2 + (1.0 - b)**2) / math.sqrt(3.0)
    
    # When color is very close to white (dist < (1.0 - threshold)), alpha fades to 0
    tol = 1.0 - threshold
    alpha = np.clip(dist / (tol + 1e-5), 0.0, 1.0)
    
    # Defringe: where semi-transparent, blend color inwards slightly
    alpha_mask = Image.fromarray((alpha * 255.0).astype(np.uint8), mode="L")
    if feather > 0:
        alpha_mask = alpha_mask.filter(ImageFilter.GaussianBlur(radius=feather))
    
    rgba.putalpha(alpha_mask)
    return rgba


def crop_tight(img: Image.Image, padding: int = 4) -> Image.Image:
    bbox = img.getbbox()
    if bbox:
        x0, y0, x1, y1 = bbox
        x0 = max(0, x0 - padding)
        y0 = max(0, y0 - padding)
        x1 = min(img.width, x1 + padding)
        y1 = min(img.height, y1 + padding)
        return img.crop((x0, y0, x1, y1))
    return img


def process_background():
    print("1. Processing Background (tex_bg_chapter_forest.png)...")
    bg = Image.open(BG_SRC).convert("RGB")
    bg_resized = bg.resize((1376, 768), Image.Resampling.LANCZOS)
    out_path = os.path.join(OUT_ART, "tex_bg_chapter_forest.png")
    bg_resized.save(out_path, "PNG", optimize=True)
    print(f"   [OK] Saved {out_path} ({bg_resized.size})")


def process_cards():
    print("2. Slicing and Processing Three Chapter Cards...")
    trio = Image.open(CARDS_SRC)
    w, h = trio.size
    
    trio_gray = np.array(trio.convert("L"), dtype=float) / 255.0
    non_white = (trio_gray < 0.95).astype(float)
    col_density = np.mean(non_white, axis=0)
    
    active_cols = np.where(col_density > 0.05)[0]
    min_x, max_x = active_cols[0], active_cols[-1]
    span = max_x - min_x
    card_width_approx = span / 3.0
    
    padding_split = int(card_width_approx * 0.06)
    
    cuts = [
        (min_x, int(min_x + card_width_approx + padding_split)),
        (int(min_x + card_width_approx - padding_split), int(min_x + 2 * card_width_approx + padding_split)),
        (int(min_x + 2 * card_width_approx - padding_split), max_x)
    ]
    
    out_files = [
        "card_ch1_flute.png",
        "card_ch2_kalimba.png",
        "card_ch3_chimes.png"
    ]
    
    for i, (x0, x1) in enumerate(cuts):
        crop = trio.crop((x0, 0, x1, h))
        cutout = remove_white_bg(crop, threshold=0.96, feather=1)
        tight = crop_tight(cutout, padding=2)
        
        # Standardize height to 600px maintaining natural aspect ratio
        target_h = 600
        aspect = tight.width / tight.height
        target_w = int(target_h * aspect)
        card_final = tight.resize((target_w, target_h), Image.Resampling.LANCZOS)
        
        out_path = os.path.join(OUT_ART, out_files[i])
        card_final.save(out_path, "PNG", optimize=True)
        print(f"   [OK] Card {i+1} saved to {out_path} ({card_final.size})")


def process_star_jar():
    print("3. Processing Star Jar Cradle (spr_star_jar_cradle.png)...")
    raw = Image.open(STAR_JAR_SRC)
    cutout = remove_white_bg(raw, threshold=0.96, feather=1)
    tight = crop_tight(cutout, padding=2)
    final = tight.resize((320, 320), Image.Resampling.LANCZOS)
    out_path = os.path.join(OUT_ART, "spr_star_jar_cradle.png")
    final.save(out_path, "PNG", optimize=True)
    print(f"   [OK] Saved {out_path} ({final.size})")


def process_lock_and_strap():
    print("4. Processing Padlock and Leather Strap...")
    raw = Image.open(LOCK_STRAP_SRC)
    w, h = raw.size
    
    # Padlock: top-left chunky brass padlock
    padlock_crop = raw.crop((int(w * 0.02), int(h * 0.02), int(w * 0.28), int(h * 0.35)))
    padlock_cut = remove_white_bg(padlock_crop, threshold=0.96, feather=1)
    padlock_tight = crop_tight(padlock_cut, padding=2)
    padlock_final = padlock_tight.resize((160, 200), Image.Resampling.LANCZOS)
    padlock_path = os.path.join(OUT_ART, "spr_padlock_brass.png")
    padlock_final.save(padlock_path, "PNG", optimize=True)
    print(f"   [OK] Saved padlock: {padlock_path} ({padlock_final.size})")
    
    # Leather strap: straight buckle strap in lower-middle
    strap_crop = raw.crop((int(w * 0.035), int(h * 0.62), int(w * 0.82), int(h * 0.77)))
    strap_cut = remove_white_bg(strap_crop, threshold=0.96, feather=1)
    strap_tight = crop_tight(strap_cut, padding=2)
    strap_final = strap_tight.resize((450, 80), Image.Resampling.LANCZOS)
    strap_path = os.path.join(OUT_ART, "spr_leather_belt_strap.png")
    strap_final.save(strap_path, "PNG", optimize=True)
    print(f"   [OK] Saved leather strap: {strap_path} ({strap_final.size})")


def process_banner():
    print("5. Processing Banner Ribbon (ui_banner_ribbon_title.png)...")
    raw = Image.open(BANNER_SRC)
    cutout = remove_white_bg(raw, threshold=0.96, feather=1)
    tight = crop_tight(cutout, padding=4)
    aspect = tight.width / tight.height
    new_w = 580
    new_h = int(new_w / aspect)
    final = tight.resize((new_w, new_h), Image.Resampling.LANCZOS)
    out_path = os.path.join(OUT_ART, "ui_banner_ribbon_title.png")
    final.save(out_path, "PNG", optimize=True)
    print(f"   [OK] Saved banner: {out_path} ({final.size})")


def generate_padlock_sfx():
    print("6. Generating Padlock Rattle SFX (sfx_padlock_rattle.wav)...")
    # Generate pleasant tactile metallic jiggle sound (brass lock rattle)
    rate = 44100
    duration = 0.38
    num_samples = int(rate * duration)
    
    samples = np.zeros(num_samples, dtype=np.float32)
    
    # 3 quick metallic clicks/clinks
    clink_times = [0.0, 0.065, 0.14]
    clink_freqs = [
        [1850.0, 2400.0, 3100.0, 4200.0],
        [1920.0, 2550.0, 3350.0, 4600.0],
        [1780.0, 2300.0, 2980.0, 3950.0]
    ]
    clink_decays = [0.045, 0.055, 0.090]
    clink_gains = [0.45, 0.70, 0.85]
    
    for t_idx, start_t in enumerate(clink_times):
        start_sample = int(start_t * rate)
        decay = clink_decays[t_idx]
        gain = clink_gains[t_idx]
        freqs = clink_freqs[t_idx]
        
        for i in range(start_sample, min(start_sample + int(decay * 5 * rate), num_samples)):
            t = (i - start_sample) / rate
            env = math.exp(-t / decay)
            val = 0.0
            for f_idx, f in enumerate(freqs):
                val += math.sin(2.0 * math.pi * f * t) * (0.3 / (f_idx + 1))
            # Subtle resonant thud for body weight
            val += math.sin(2.0 * math.pi * 380.0 * t) * 0.25 * math.exp(-t / (decay * 0.8))
            samples[i] += val * env * gain
            
    # Normalize with headroom
    max_amp = np.max(np.abs(samples))
    if max_amp > 0:
        samples = (samples / max_amp) * 0.85
        
    out_path = os.path.join(OUT_AUDIO, "sfx_padlock_rattle.wav")
    with wave.open(out_path, "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2) # 16-bit
        wf.setframerate(rate)
        int_data = (samples * 32767.0).astype(np.int16)
        wf.writeframes(int_data.tobytes())
        
    print(f"   [OK] Saved audio SFX: {out_path} ({duration:.2f}s, 44.1kHz mono)")


if __name__ == "__main__":
    process_background()
    process_cards()
    process_star_jar()
    process_lock_and_strap()
    process_banner()
    generate_padlock_sfx()
    print("\n=== ALL AI ASSETS POST-PROCESSED SUCCESSFULLY! ===")
