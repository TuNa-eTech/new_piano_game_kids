#!/usr/bin/env python3
"""
chroma_key_process.py
Chuyen dung boc tach phong xanh la (Chroma Key Green #00FF00 / Green Screen)
cho pipeline do hoa 2.5D Godot Engine.

Tinh nang:
1. Thuat toan Flood-Fill Chroma Key (loang tu 4 mep anh vao):
   - Bao ve 100% cac chi tiet mau xanh la nam BEN TRONG doi tuong (nhu la cay xanh, ngoc xanh, mat meo xanh)
   - Chi xoa bo phong nen xanh ket noi voi duong vien ngoai
2. Green Spill Suppression (khu anh xanh phan xa nhe o mep vien ngoai)
3. Lam min bien alpha (Sub-pixel Feathering & Anti-aliased Edge)
4. Tu dong cat khoang thua trong suot (Bounding-box Trim) voi padding tuy chinh
5. Ho tro resize chat luong cao (Lanczos)
"""

import argparse
from collections import deque
import math
import os
import sys
from PIL import Image

def hex_to_rgb(hex_str: str) -> tuple:
    hex_str = hex_str.lstrip("#")
    if len(hex_str) == 3:
        hex_str = "".join([c * 2 for c in hex_str])
    return tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))

def color_distance(c1: tuple, c2: tuple) -> float:
    # Normalized Euclidean distance in RGB space [0.0, 1.0]
    r_diff = (c1[0] - c2[0]) / 255.0
    g_diff = (c1[1] - c2[1]) / 255.0
    b_diff = (c1[2] - c2[2]) / 255.0
    return math.sqrt(r_diff * r_diff + g_diff * g_diff + b_diff * b_diff) / 1.7320508

def is_green_pixel(r: int, g: int, b: int, key_color: tuple, tolerance: float) -> bool:
    dist = color_distance((r, g, b), key_color)
    max_rb = max(r, b)
    if g > max_rb + 35 and g > 85:
        return True
    return dist <= tolerance

def process_flood_fill_chroma_key(
    img: Image.Image,
    key_color: tuple = (0, 255, 0),
    tolerance: float = 0.22,
    feather: float = 0.05,
    spill_suppression: bool = True
) -> Image.Image:
    img = img.convert("RGBA")
    w, h = img.size
    pixels = img.load()

    # 1. BFS Flood Fill tu 4 mep ngoai de xac dinh dung phong nen
    bg_mask = [[False] * h for _ in range(w)]
    visited = [[False] * h for _ in range(w)]
    queue = deque()

    # Khoi tao hang doi tu toan bo 4 canh vien
    for x in range(w):
        for y in (0, h - 1):
            r, g, b, _ = pixels[x, y]
            if is_green_pixel(r, g, b, key_color, tolerance):
                queue.append((x, y))
                visited[x][y] = True
                bg_mask[x][y] = True

    for y in range(h):
        for x in (0, w - 1):
            if not visited[x][y]:
                r, g, b, _ = pixels[x, y]
                if is_green_pixel(r, g, b, key_color, tolerance):
                    queue.append((x, y))
                    visited[x][y] = True
                    bg_mask[x][y] = True

    # Lan truyen BFS 4 huong
    directions = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    while queue:
        cx, cy = queue.popleft()
        for dx, dy in directions:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < w and 0 <= ny < h and not visited[nx][ny]:
                visited[nx][ny] = True
                r, g, b, _ = pixels[nx, ny]
                if is_green_pixel(r, g, b, key_color, tolerance + 0.08):
                    bg_mask[nx][ny] = True
                    queue.append((nx, ny))

    # 2. Ap dung mat na va lam min bien
    t_low = tolerance
    t_high = tolerance + feather

    for x in range(w):
        for y in range(h):
            r, g, b, a = pixels[x, y]
            if bg_mask[x][y]:
                # Tinh do mo feather tai vung bien mep phong nen
                dist = color_distance((r, g, b), key_color)
                max_rb = max(r, b)
                if g > max_rb + 40:
                    pixels[x, y] = (r, g, b, 0)
                elif dist <= t_low:
                    pixels[x, y] = (r, g, b, 0)
                elif dist < t_high:
                    ratio = (dist - t_low) / (t_high - t_low)
                    pixels[x, y] = (r, g, b, int(ratio * 255))
                else:
                    pixels[x, y] = (r, g, b, 0)
            else:
                # Chi tiet ben trong: Neu o mep co anh huong xanh, khu spill nhe
                if spill_suppression:
                    # Kiem tra xem pixel nay co tiep giap pixel phong nen hay khong
                    has_bg_neighbor = False
                    for dx, dy in directions:
                        nx, ny = x + dx, y + dy
                        if 0 <= nx < w and 0 <= ny < h and bg_mask[nx][ny]:
                            has_bg_neighbor = True
                            break
                    if has_bg_neighbor:
                        max_rb = max(r, b)
                        if g > max_rb + 15:
                            g = max_rb + 5
                            pixels[x, y] = (r, g, b, a)

    return img

def trim_image(img: Image.Image, padding: int = 4) -> Image.Image:
    bbox = img.getbbox()
    if not bbox:
        return img
    cropped = img.crop(bbox)
    if padding <= 0:
        return cropped

    new_w = cropped.width + padding * 2
    new_h = cropped.height + padding * 2
    padded = Image.new("RGBA", (new_w, new_h), (0, 0, 0, 0))
    padded.paste(cropped, (padding, padding))
    return padded

def main():
    parser = argparse.ArgumentParser(description="Chroma key background removal for 2.5D game assets.")
    parser.add_argument("--input", required=True, help="Input raw image path")
    parser.add_argument("--output", required=True, help="Output PNG path")
    parser.add_argument("--color-key", default="#00FF00", help="Chroma key hex color (default: #00FF00)")
    parser.add_argument("--tolerance", type=float, default=0.22, help="Color distance tolerance (default: 0.22)")
    parser.add_argument("--feather", type=float, default=0.05, help="Edge feather range (default: 0.05)")
    parser.add_argument("--no-spill", action="store_true", help="Disable green spill suppression")
    parser.add_argument("--trim", action="store_true", help="Trim transparent borders")
    parser.add_argument("--padding", type=int, default=6, help="Padding in px when trimming (default: 6)")
    parser.add_argument("--resize", help="Resize target WxH (e.g. 512x512)")

    args = parser.parse_args()

    if not os.path.exists(args.input):
        print(f"Error: Input file not found: {args.input}", file=sys.stderr)
        sys.exit(1)

    key_rgb = hex_to_rgb(args.color_key)
    print(f"Processing flood-fill chroma key on: {args.input}")
    print(f"Key color: {args.color_key} -> RGB{key_rgb}, Tolerance: {args.tolerance}")

    img = Image.open(args.input)
    processed = process_flood_fill_chroma_key(
        img,
        key_color=key_rgb,
        tolerance=args.tolerance,
        feather=args.feather,
        spill_suppression=not args.no_spill
    )

    if args.trim:
        processed = trim_image(processed, padding=args.padding)
        print(f"Trimmed to bounding box with padding {args.padding}px: {processed.size}")

    if args.resize:
        try:
            target_w, target_h = map(int, args.resize.lower().split("x"))
            processed = processed.resize((target_w, target_h), Image.Resampling.LANCZOS)
            print(f"Resized to {target_w}x{target_h} via Lanczos")
        except Exception as e:
            print(f"Warning: Failed to parse resize '{args.resize}': {e}", file=sys.stderr)

    out_dir = os.path.dirname(args.output)
    if out_dir and not os.path.exists(out_dir):
        os.makedirs(out_dir, exist_ok=True)

    processed.save(args.output, "PNG")
    print(f"Saved game-ready asset to: {args.output} ({processed.size[0]}x{processed.size[1]})")

if __name__ == "__main__":
    main()
