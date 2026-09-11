#!/usr/bin/env python3
"""
process_asset.py
Post-processes raw AI-generated images into game-ready sprites for Godot.
Features:
- Smart background removal (corner sampling or explicit --color-key) with alpha feathering
- Bounding box trimming of transparent space
- Sprite padding
- Resizing with nearest neighbor (pixel art) or Lanczos (HD storybook)
"""

import argparse
import math
import os
import sys
from PIL import Image

def hex_to_rgb(hex_str):
    hex_str = hex_str.lstrip("#")
    if len(hex_str) == 3:
        hex_str = "".join([c * 2 for c in hex_str])
    return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))

def color_distance(c1, c2):
    # Normalized Euclidean distance in RGB space [0.0, 1.0]
    r_diff = (c1[0] - c2[0]) / 255.0
    g_diff = (c1[1] - c2[1]) / 255.0
    b_diff = (c1[2] - c2[2]) / 255.0
    return math.sqrt(r_diff * r_diff + g_diff * g_diff + b_diff * b_diff) / 1.7320508

def sample_background_color(img):
    # Sample 4 corners
    w, h = img.size
    corners = [
        img.getpixel((0, 0))[:3],
        img.getpixel((w - 1, 0))[:3],
        img.getpixel((0, h - 1))[:3],
        img.getpixel((w - 1, h - 1))[:3]
    ]
    # Average corners
    avg_r = sum(c[0] for c in corners) // 4
    avg_g = sum(c[1] for c in corners) // 4
    avg_b = sum(c[2] for c in corners) // 4
    return (avg_r, avg_g, avg_b)

def remove_background(img, bg_color, tolerance=0.15, feather=0.04):
    img = img.convert("RGBA")
    data = img.getdata()
    new_data = []

    t_low = tolerance
    t_high = tolerance + feather if feather > 0 else tolerance

    for item in data:
        dist = color_distance(item[:3], bg_color)
        if dist <= t_low:
            # Completely transparent
            new_data.append((item[0], item[1], item[2], 0))
        elif dist < t_high:
            # Smooth feathered transition
            ratio = (dist - t_low) / (t_high - t_low)
            alpha = int(ratio * item[3])
            new_data.append((item[0], item[1], item[2], alpha))
        else:
            new_data.append(item)

    img.putdata(new_data)
    return img

def trim_transparent(img, padding=0):
    bbox = img.getbbox()
    if not bbox:
        return img
    cropped = img.crop(bbox)
    if padding <= 0:
        return cropped

    # Add padding around trimmed content
    new_w = cropped.width + padding * 2
    new_h = cropped.height + padding * 2
    padded = Image.new("RGBA", (new_w, new_h), (0, 0, 0, 0))
    padded.paste(cropped, (padding, padding))
    return padded

def main():
    parser = argparse.ArgumentParser(description="Clean and process game sprite assets.")
    parser.add_argument("--input", required=True, help="Input image path")
    parser.add_argument("--output", required=True, help="Output image path")
    parser.add_argument("--remove-bg", action="store_true", help="Remove background automatically")
    parser.add_argument("--color-key", help="Specific hex color to make transparent (e.g. #FFFFFF)")
    parser.add_argument("--tolerance", type=float, default=0.15, help="Color distance tolerance (0.0 - 1.0, default 0.15)")
    parser.add_argument("--feather", type=float, default=0.04, help="Alpha feathering range (default 0.04)")
    parser.add_argument("--trim", action="store_true", help="Trim transparent whitespace")
    parser.add_argument("--padding", type=int, default=0, help="Padding in pixels around trimmed sprite")
    parser.add_argument("--resize", help="Resize to WxH (e.g. 64x64 or 256x256)")
    parser.add_argument("--filter", choices=["nearest", "lanczos", "bilinear", "bicubic"], default="lanczos", help="Resampling filter")

    args = parser.parse_args()

    if not os.path.exists(args.input):
        print(f"Error: input file '{args.input}' does not exist.", file=sys.stderr)
        sys.exit(1)

    img = Image.open(args.input).convert("RGBA")

    if args.remove_bg or args.color_key:
        if args.color_key:
            bg_color = hex_to_rgb(args.color_key)
        else:
            bg_color = sample_background_color(img)
        img = remove_background(img, bg_color, tolerance=args.tolerance, feather=args.feather)

    if args.trim:
        img = trim_transparent(img, padding=args.padding)

    if args.resize:
        try:
            w_str, h_str = args.resize.lower().split("x")
            target_size = (int(w_str), int(h_str))
        except ValueError:
            print(f"Error: invalid resize format '{args.resize}'. Use WxH (e.g. 128x128).", file=sys.stderr)
            sys.exit(1)

        filter_map = {
            "nearest": Image.Resampling.NEAREST,
            "lanczos": Image.Resampling.LANCZOS,
            "bilinear": Image.Resampling.BILINEAR,
            "bicubic": Image.Resampling.BICUBIC,
        }
        resample_filter = filter_map.get(args.filter, Image.Resampling.LANCZOS)
        img = img.resize(target_size, resample=resample_filter)

    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    img.save(args.output, "PNG")
    print(f"Saved processed asset to: {args.output}")

if __name__ == "__main__":
    main()
