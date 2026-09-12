#!/usr/bin/env python3
"""
process_chroma_asset.py
Chroma Key (#00FF00 Green Screen) Post-Processor for Godot 2.5D Game Assets.
- Soft Chroma Key Matting with adjustable tolerance & smooth feathering
- Green Spill Suppression: removes green color fringe on borders
- Bounding Box Trim with custom padding
- Optional resizing with Lanczos interpolation
- Generates Godot 4.x .import file automatically
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

def green_spill_suppression(r, g, b):
    """
    Suppresses green color spill/fringe on edges.
    If green is noticeably higher than average of red and blue, clamp it.
    """
    rb_avg = (r + b) / 2.0
    if g > rb_avg:
        # Blend green towards the average of red and blue to eliminate green halo
        g = int(rb_avg + (g - rb_avg) * 0.2)
    return (r, g, b)

def chroma_key_remove(img, key_color=(0, 255, 0), tolerance=0.25, feather=0.08, spill_suppression=True, flood_fill=False):
    img = img.convert("RGBA")
    w, h = img.size
    pixels = img.load()

    is_green_key = (key_color[1] > key_color[0] and key_color[1] > key_color[2])

    t_low = tolerance
    t_high = tolerance + feather if feather > 0 else tolerance

    def is_key_match(r, g, b):
        dist = color_distance((r, g, b), key_color)
        if is_green_key and g > 60:
            other_max = max(r, b)
            if g > other_max:
                green_prominence = (g - other_max) / 255.0
                if green_prominence > 0.35:
                    dist = min(dist, (1.0 - green_prominence) * 0.4)
        return dist <= t_low, dist

    if flood_fill:
        # BFS flood fill from edges to only remove contiguous background
        from collections import deque
        visited = bytearray(w * h)
        queue = deque()

        # Enqueue border pixels that match
        for x in range(w):
            for y in (0, h - 1):
                idx = y * w + x
                r, g, b, a = pixels[x, y]
                match, dist = is_key_match(r, g, b)
                if match and not visited[idx]:
                    visited[idx] = 1
                    queue.append((x, y))

        for y in range(h):
            for x in (0, w - 1):
                idx = y * w + x
                r, g, b, a = pixels[x, y]
                match, dist = is_key_match(r, g, b)
                if match and not visited[idx]:
                    visited[idx] = 1
                    queue.append((x, y))

        while queue:
            cx, cy = queue.popleft()
            pixels[cx, cy] = (0, 0, 0, 0)
            for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                if 0 <= nx < w and 0 <= ny < h:
                    nidx = ny * w + nx
                    if not visited[nidx]:
                        visited[nidx] = 1
                        r, g, b, a = pixels[nx, ny]
                        match, dist = is_key_match(r, g, b)
                        if match or (dist < t_high and is_green_key and g > max(r, b)):
                            queue.append((nx, ny))
                        elif dist < t_high:
                            ratio = (dist - t_low) / (t_high - t_low)
                            alpha = int(ratio * a)
                            if spill_suppression and is_green_key:
                                r, g, b = green_spill_suppression(r, g, b)
                            pixels[nx, ny] = (r, g, b, alpha)
        return img

    data = img.getdata()
    new_data = []

    for item in data:
        r, g, b, a = item
        # Check distance to chroma key
        dist = color_distance((r, g, b), key_color)

        # Also green prominence heuristic if keying green
        green_prominence = 0.0
        if is_green_key and g > 60:
            other_max = max(r, b)
            if g > other_max:
                green_prominence = (g - other_max) / 255.0

        effective_dist = dist
        if is_green_key and green_prominence > 0.35:
            effective_dist = min(effective_dist, (1.0 - green_prominence) * 0.4)

        if effective_dist <= t_low:
            # Completely transparent background
            new_data.append((0, 0, 0, 0))
        elif effective_dist < t_high:
            # Semi-transparent feathered edge
            ratio = (effective_dist - t_low) / (t_high - t_low)
            alpha = int(ratio * a)
            if spill_suppression and is_green_key:
                r, g, b = green_spill_suppression(r, g, b)
            new_data.append((r, g, b, alpha))
        else:
            # Solid foreground pixel
            if spill_suppression and is_green_key:
                # Still check subtle green fringing on borderline pixels
                if dist < t_high + 0.15:
                    r, g, b = green_spill_suppression(r, g, b)
            new_data.append((r, g, b, a))

    img.putdata(new_data)
    return img

def trim_transparent(img, padding=0):
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

def make_import_file(output_path):
    import_path = output_path + ".import"
    content = f"""; Auto-generated by process_chroma_asset.py for Godot 4.x
[remap]
importer="texture"
type="CompressedTexture2D"
uid="uid://chroma_{os.path.basename(output_path).replace('.', '_')}"

[params]
compress/mode=0
compress/high_quality=true
compress/lossless_quality=0.85
compress/bptc_ldr=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
"""
    with open(import_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"  [+] Godot 4 .import generated: {import_path}")

def main():
    parser = argparse.ArgumentParser(description="Chroma Key Green Screen processor for Godot game assets.")
    parser.add_argument("--input", required=True, help="Path to input image")
    parser.add_argument("--output", required=True, help="Path to output PNG image")
    parser.add_argument("--color-key", default="#00FF00", help="Chroma key hex color (default: #00FF00)")
    parser.add_argument("--tolerance", type=float, default=0.25, help="Color tolerance (default: 0.25)")
    parser.add_argument("--feather", type=float, default=0.08, help="Feather transition range (default: 0.08)")
    parser.add_argument("--spill-suppression", action="store_true", default=True, help="Suppress green spill on edges")
    parser.add_argument("--trim", action="store_true", default=True, help="Trim transparent whitespace")
    parser.add_argument("--padding", type=int, default=4, help="Padding in pixels around trimmed image (default: 4)")
    parser.add_argument("--flood-fill", action="store_true", help="Use flood fill from edges to only remove exterior background")
    parser.add_argument("--resize", help="Resize to WxH (e.g. 512x512)")
    parser.add_argument("--make-import", action="store_true", default=True, help="Generate Godot .import file")

    args = parser.parse_args()

    if not os.path.exists(args.input):
        print(f"Error: Input file '{args.input}' not found.", file=sys.stderr)
        sys.exit(1)

    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)

    key_rgb = hex_to_rgb(args.color_key)
    print(f"Processing '{args.input}' with key {args.color_key} ({key_rgb})...")

    img = Image.open(args.input)
    processed = chroma_key_remove(
        img,
        key_color=key_rgb,
        tolerance=args.tolerance,
        feather=args.feather,
        spill_suppression=args.spill_suppression,
        flood_fill=args.flood_fill
    )

    if args.trim:
        processed = trim_transparent(processed, padding=args.padding)
        print(f"  [+] Trimmed to {processed.size[0]}x{processed.size[1]} px (padding: {args.padding})")

    if args.resize:
        try:
            w_str, h_str = args.resize.lower().split("x")
            target_w = int(w_str)
            target_h = int(h_str)
            processed = processed.resize((target_w, target_h), Image.Resampling.LANCZOS)
            print(f"  [+] Resized to {target_w}x{target_h} px")
        except Exception as e:
            print(f"Warning: Failed to parse resize '{args.resize}': {e}", file=sys.stderr)

    processed.save(args.output, "PNG", optimize=True)
    print(f"  [+] Saved processed asset to: {args.output}")

    if args.make_import:
        make_import_file(args.output)

if __name__ == "__main__":
    main()
