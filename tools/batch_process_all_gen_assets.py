#!/usr/bin/env python3
import subprocess
import os

SCRIPT = ".agents/skills/godot-asset-generator/scripts/process_asset.py"
PYTHON = "/usr/local/bin/python"

ASSETS = [
    ("/Users/anhtu/.gemini/antigravity/brain/176de66d-0b1d-4aae-8254-01361e4a3c84/animal_lion_token_1789145527216.jpg", "assets/art/animal_lion_gen_25d.png", "160x160"),
    ("/Users/anhtu/.gemini/antigravity/brain/176de66d-0b1d-4aae-8254-01361e4a3c84/animal_bear_mascot_1789145438819.jpg", "assets/art/animal_bear_gen_25d.png", "160x160"),
    ("/Users/anhtu/.gemini/antigravity/brain/176de66d-0b1d-4aae-8254-01361e4a3c84/animal_rabbit_mascot_1789145453036.jpg", "assets/art/animal_rabbit_gen_25d.png", "160x160"),
    ("/Users/anhtu/.gemini/antigravity/brain/176de66d-0b1d-4aae-8254-01361e4a3c84/animal_cat_mascot_1789145468600.jpg", "assets/art/animal_cat_gen_25d.png", "160x160"),
    ("/Users/anhtu/.gemini/antigravity/brain/176de66d-0b1d-4aae-8254-01361e4a3c84/animal_monkey_mascot_1789145490545.jpg", "assets/art/animal_monkey_gen_25d.png", "160x160"),
    ("/Users/anhtu/.gemini/antigravity/brain/176de66d-0b1d-4aae-8254-01361e4a3c84/animal_elephant_mascot_1789145504182.jpg", "assets/art/animal_elephant_gen_25d.png", "160x160"),
    ("/Users/anhtu/.gemini/antigravity/brain/176de66d-0b1d-4aae-8254-01361e4a3c84/animal_owl_mascot_1789145514485.jpg", "assets/art/animal_owl_gen_25d.png", "160x160"),
    ("/Users/anhtu/.gemini/antigravity/brain/176de66d-0b1d-4aae-8254-01361e4a3c84/piano_white_key_tactile_1789145561032.jpg", "assets/art/piano_white_key_gen_25d.png", "180x320"),
    ("/Users/anhtu/.gemini/antigravity/brain/176de66d-0b1d-4aae-8254-01361e4a3c84/piano_black_key_tactile_1789145574545.jpg", "assets/art/piano_black_key_gen_25d.png", "120x220"),
]

for src, dst, resize in ASSETS:
    if not os.path.exists(src):
        print(f"Skipping missing {src}")
        continue
    cmd = [
        PYTHON, SCRIPT,
        "--input", src,
        "--output", dst,
        "--remove-bg",
        "--tolerance", "0.12",
        "--feather", "0.04",
        "--trim",
        "--padding", "4",
        "--resize", resize,
        "--filter", "lanczos"
    ]
    print(f"Processing {dst}...")
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"Error on {dst}: {res.stderr}")
    else:
        print(f"[OK] {dst}")

print("=== HOÀN THÀNH HẬU KỲ TẤT CẢ ASSETS 2.5D ===")
