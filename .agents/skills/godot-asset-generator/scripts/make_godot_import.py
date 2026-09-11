#!/usr/bin/env python3
"""
make_godot_import.py
Generates standard Godot 4.x .import files for 2D textures.
Presets:
- storybook-hd: High resolution 2D/2.5D with mipmaps on and lossless compression.
- pixel-art: Nearest filter, no mipmaps, lossless compression, fix alpha border.
- ui: Clean crisp UI textures without mipmaps.
"""

import argparse
import glob
import os
import sys

IMPORT_TEMPLATES = {
    "storybook-hd": """[remap]

importer="texture"
type="CompressedTexture2D"

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=true
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
""",
    "pixel-art": """[remap]

importer="texture"
type="CompressedTexture2D"

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
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
""",
    "ui": """[remap]

importer="texture"
type="CompressedTexture2D"

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
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
}

def create_import_file(image_path, preset="storybook-hd", force=False):
    import_path = image_path + ".import"
    if os.path.exists(import_path) and not force:
        print(f"Skipping existing: {import_path}")
        return

    content = IMPORT_TEMPLATES.get(preset, IMPORT_TEMPLATES["storybook-hd"])
    with open(import_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Created: {import_path} (preset: {preset})")

def main():
    parser = argparse.ArgumentParser(description="Generate Godot 4 .import files for textures.")
    parser.add_argument("--input", required=True, help="Image file path or directory")
    parser.add_argument("--preset", choices=["storybook-hd", "pixel-art", "ui"], default="storybook-hd", help="Import preset")
    parser.add_argument("--force", action="store_true", help="Overwrite existing .import files")

    args = parser.parse_args()

    target = args.input
    if os.path.isfile(target):
        create_import_file(target, args.preset, args.force)
    elif os.path.isdir(target):
        exts = ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        found = []
        for ext in exts:
            found.extend(glob.glob(os.path.join(target, "**", ext), recursive=True))
        if not found:
            print(f"No images found in directory: {target}")
            sys.exit(0)
        for img_path in sorted(found):
            create_import_file(img_path, args.preset, args.force)
    else:
        print(f"Error: input '{target}' is not a valid file or directory.", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
