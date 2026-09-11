#!/usr/bin/env python3
"""
pack_spritesheet.py
Packs individual animation frame images into a single sprite sheet for Godot.
Generates an optional JSON metadata file with frame coordinates [x, y, w, h].
"""

import argparse
import glob
import json
import math
import os
import re
import sys
from PIL import Image

def natural_sort_key(s):
    return [int(text) if text.isdigit() else text.lower() for text in re.split(r'(\d+)', s)]

def resolve_inputs(input_patterns):
    files = []
    for pattern in input_patterns:
        matched = glob.glob(pattern)
        if matched:
            files.extend(matched)
        elif os.path.exists(pattern):
            files.append(pattern)
    files = sorted(list(set(files)), key=natural_sort_key)
    return files

def main():
    parser = argparse.ArgumentParser(description="Pack sprite frames into a Godot-ready sprite sheet.")
    parser.add_argument("--input", nargs="+", required=True, help="Input image files or glob patterns")
    parser.add_argument("--output", required=True, help="Output sprite sheet image path (.png)")
    parser.add_argument("--columns", type=int, default=0, help="Number of columns (default: auto)")
    parser.add_argument("--padding", type=int, default=0, help="Padding in pixels around each frame")
    parser.add_argument("--metadata", help="Output JSON metadata path for frame coordinates")

    args = parser.parse_args()

    files = resolve_inputs(args.input)
    if not files:
        print(f"Error: no input files found matching '{args.input}'.", file=sys.stderr)
        sys.exit(1)

    images = []
    max_w = 0
    max_h = 0
    for f in files:
        img = Image.open(f).convert("RGBA")
        images.append((os.path.splitext(os.path.basename(f))[0], img))
        if img.width > max_w:
            max_w = img.width
        if img.height > max_h:
            max_h = img.height

    total_frames = len(images)
    columns = args.columns
    if columns <= 0:
        columns = math.ceil(math.sqrt(total_frames))
    rows = math.ceil(total_frames / columns)

    pad = args.padding
    cell_w = max_w
    cell_h = max_h

    sheet_w = pad + columns * (cell_w + pad)
    sheet_h = pad + rows * (cell_h + pad)

    sheet = Image.new("RGBA", (sheet_w, sheet_h), (0, 0, 0, 0))
    metadata_frames = []

    for index, (name, img) in enumerate(images):
        col = index % columns
        row = index // columns

        # Center frame in cell
        x = pad + col * (cell_w + pad) + (cell_w - img.width) // 2
        y = pad + row * (cell_h + pad) + (cell_h - img.height) // 2

        sheet.paste(img, (x, y))

        metadata_frames.append({
            "name": name,
            "x": x,
            "y": y,
            "width": img.width,
            "height": img.height
        })

    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    sheet.save(args.output, "PNG")
    print(f"Saved sprite sheet ({sheet_w}x{sheet_h}, {total_frames} frames) to: {args.output}")

    if args.metadata:
        os.makedirs(os.path.dirname(os.path.abspath(args.metadata)), exist_ok=True)
        meta_data = {
            "image": os.path.basename(args.output),
            "size": {"width": sheet_w, "height": sheet_h},
            "columns": columns,
            "rows": rows,
            "frames": metadata_frames
        }
        with open(args.metadata, "w", encoding="utf-8") as f:
            json.dump(meta_data, f, indent=2)
        print(f"Saved metadata to: {args.metadata}")

if __name__ == "__main__":
    main()
