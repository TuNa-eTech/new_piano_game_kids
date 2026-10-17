---
name: godot-asset-generator
description: Use when creating game assets, 2D sprites, UI icons, tilesets, or animation sprite sheets for Godot using Antigravity image generation and Python post-processing without external API keys.
---

# Godot Asset Generator (Antigravity Edition)

Generate game assets using Antigravity's built-in image generator and prepare them for Godot 4.x with local Python post-processing. Zero external API keys or paid subscriptions required.

## When to Use This Skill

Use this skill when:
- Generating 2D game sprites, characters, objects, or backgrounds for Godot
- Creating UI elements, buttons, icons, or HUD panels
- Batch-generating and packing animation frames into sprite sheets
- Post-processing raw AI output (removing backgrounds, feathering alpha, trimming, padding, resizing)
- Generating Godot 4 `.import` files with optimal texture filtering and compression
- Ensuring art style consistency with existing project assets

Do NOT use this skill when:
- Creating 3D models or skeletal 3D rigs (use 3D modeling tools)
- Doing manual frame-by-frame pixel manipulation
- Editing Godot project settings unrelated to assets

## Prerequisites

**Required:**
- Antigravity IDE (provides native `generate_image` tool)
- Python 3 with `Pillow` installed (`python3 -c "import PIL"`)

**No external API keys (`OPENAI_API_KEY`, `REPLICATE_API_TOKEN`, `FAL_KEY`) or Deno runtime needed.**

## Core Workflow

```
[1. Prompt & Ref Assets] ──> [2. generate_image tool] ──> [3. process_asset.py] ──> [4. make_godot_import.py] ──> [Godot Project]
```

### Step 1: Prompt & Reference Images
1. Formulate a prompt based on the target art style (see Style Presets below).
2. For character/style consistency, select up to 3 reference images from `assets/art/` and provide their paths in `ImagePaths`.

### Step 2: Generate Image with Antigravity
Invoke the native `generate_image` tool:
- `Prompt`: Detailed description + style keywords + background hint (e.g. "isolated on pure white background").
- `AspectRatio`: `'1:1'` for sprites/icons, `'4:3'` or `'16:9'` for backgrounds, `'2:3'` or `'3:4'` for vertical cards.
- `ImagePaths`: `["/path/to/existing_character.png"]` for visual guidance.
- `ImageName`: Descriptive artifact name (e.g. `animal_fox_idle`).

The generated file is saved in your conversation's artifact directory.

### Step 3: Post-Process Asset
Run `process_asset.py` to remove backgrounds, feather edges, crop whitespace, and resize:
```bash
python3 .agents/skills/godot-asset-generator/scripts/process_asset.py \
  --input "/path/to/artifact.png" \
  --output "assets/art/animal_fox_idle.png" \
  --remove-bg \
  --feather 0.05 \
  --trim \
  --padding 4 \
  --resize 256x256 \
  --filter lanczos
```

### Step 4: Generate Godot Import File
Generate Godot 4 `.import` file:
```bash
python3 .agents/skills/godot-asset-generator/scripts/make_godot_import.py \
  --input "assets/art/animal_fox_idle.png" \
  --preset storybook-hd
```

---

## Art Style Presets & Prompt Formulas

### 1. Fairytale 2.5D Storybook (Specialized for `new-piano`)
For cute fairytale characters, wooden instruments, whimsical UI, and dioramas:
```
"fairytale storybook 2.5d diorama style, [SUBJECT], cute whimsical character, soft clay and painted wood texture, warm vibrant colors, charming details, gentle ambient occlusion lighting, isolated on solid white background"
```
**Key modifiers:** `fairytale storybook`, `2.5d diorama`, `whimsical`, `painted wood texture`, `soft clay`, `isolated on solid white background`  
**Avoid:** `hyperrealistic`, `grimdark`, `photorealistic`, `cyberpunk`

### 2. Pixel Art
For retro 16-bit sprites and tiles:
```
"pixel art [SUBJECT], 16-bit style, clean pixels, no anti-aliasing, limited color palette, retro game sprite, solid white background"
```
**Key modifiers:** `16-bit`, `pixel art`, `clean pixels`, `no anti-aliasing`, `retro game sprite`  
**Post-processing tip:** Always use `--filter nearest` and preset `pixel-art`.

### 3. Vector / Flat UI
For UI buttons, icons, currency badges:
```
"flat design game icon of [SUBJECT], vector art style, clean sharp edges, solid vibrant colors, minimal shading, game UI, solid white background"
```
**Key modifiers:** `flat design`, `game icon`, `clean sharp edges`, `vector art`, `solid colors`  
**Post-processing tip:** Use `--filter lanczos` and preset `ui`.

### 4. Painterly Landscape / Background
For panoramic storybook stages and scenes:
```
"digital painting of [SUBJECT], storybook fairytale landscape, magical whimsical lighting, vibrant lush colors, concept art style, wide establishing view"
```
**Key modifiers:** `digital painting`, `storybook fairytale landscape`, `magical lighting`, `concept art`  
**Aspect ratio:** Use `'16:9'` or `'4:3'`.

---

## Script Reference

### `process_asset.py`
Cleans, crops, and resizes raw AI images.
```bash
python3 .agents/skills/godot-asset-generator/scripts/process_asset.py [options]

Options:
  --input <path>       Path to raw image artifact (required)
  --output <path>      Output file path (.png) (required)
  --remove-bg          Automatically detect and remove uniform background
  --color-key <hex>    Specify background hex color (e.g. #FFFFFF or #00FF00)
  --tolerance <float>  Color matching tolerance [0.0 - 1.0] (default: 0.15)
  --feather <float>    Alpha feathering transition width (default: 0.04)
  --trim               Trim transparent bounding whitespace
  --padding <px>       Padding around trimmed sprite (default: 0)
  --resize <WxH>       Target dimensions, e.g. 128x128 or 512x512
  --filter <type>      Resample filter: nearest, lanczos, bilinear, bicubic (default: lanczos)
```

### `pack_spritesheet.py`
Packs multiple animation frame images into a single grid sprite sheet.
```bash
python3 .agents/skills/godot-asset-generator/scripts/pack_spritesheet.py [options]

Options:
  --input <files...>   List of image files or glob pattern (e.g. "frames/*.png")
  --output <path>      Output sprite sheet path (.png) (required)
  --columns <n>        Number of columns in the sheet (default: auto)
  --padding <px>       Spacing between frames (default: 0)
  --metadata <path>    Optional JSON metadata path saving frame rectangles [x, y, w, h]
```

### `make_godot_import.py`
Generates Godot 4.x `.import` files with tuned presets.
```bash
python3 .agents/skills/godot-asset-generator/scripts/make_godot_import.py [options]

Options:
  --input <path>       Image file or directory to process (required)
  --preset <name>      storybook-hd (default), pixel-art, or ui
  --force              Overwrite existing .import files
```

---

## Godot Engine Usage Example

### Using Packed Sprite Sheet with `AtlasTexture` in GDScript:
```gdscript
var atlas := load("res://assets/art/fox_sheet.png") as Texture2D
var frame_tex := AtlasTexture.new()
frame_tex.atlas = atlas
frame_tex.region = Rect2(0, 0, 64, 64) # Coordinates from metadata JSON
$Sprite2D.texture = frame_tex
```

---

## Integration with `sprite-gen` (Component-Row Atlases & Advanced Pipelines)

This repository also includes the [`sprite-gen`](../sprite-gen/SKILL.md) skill at `.agents/skills/sprite-gen` (`SPRITE_GEN_ROOT=.agents/skills/sprite-gen`, CLI at `.agents/skills/sprite-gen/.venv/bin/sprite-gen`).

Use `sprite-gen` when you need:
- **Component-row animation atlases** (`prepare` → `gen-set` → `extract` → `compose-atlas`) with `sprite-sheet-alpha.png`, `manifest.json.frame_layout`, and **Breathe** idle animations
- **Video-to-loop sprite animations** (`video-set` / `video-canvas` → `video` → `video-frames` → `video-loop`)
- **Advanced chroma/matte extraction & slicing** (`cutout --white-check`, `slice-sheet`, `ui-kit`, `unpack-atlas`)
- **Deterministic palette swaps & asset tools** (`recolor`, `background-tile`, `shadow`, `inspect-motion`)

After generating or extracting PNGs/atlases with `sprite-gen`, run `make_godot_import.py` from this skill to produce the Godot 4 `.import` sidecar:
```bash
# Example: Cut out or compose atlas via sprite-gen, then generate Godot .import
.agents/skills/sprite-gen/.venv/bin/sprite-gen cutout raw_icon.png --out assets/art/icon.png --white-check
python3 .agents/skills/godot-asset-generator/scripts/make_godot_import.py --input assets/art/icon.png --preset ui
```

---

## Common Issues & Solutions

### White Halo Around Sprite
- **Cause**: AI antialiased the subject against a white background.
- **Solution**: Increase `--tolerance` (e.g. `0.20`) and `--feather` (e.g. `0.06`) in `process_asset.py`, or ensure `process/fix_alpha_border=true` in the `.import` file.

### Inconsistent Art Style Across Characters
- **Cause**: Generating images from text prompt alone without reference context.
- **Solution**: Pass 1-3 existing project assets in the `ImagePaths` parameter of `generate_image` (e.g. `["assets/art/animal_bear_idle.png"]`).

### Pixel Art Looks Blurry
- **Cause**: Linear filtering or downscaling with smoothing.
- **Solution**: Always use `--filter nearest` in `process_asset.py` and `--preset pixel-art` in `make_godot_import.py`.
