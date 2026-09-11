# Godot Asset Generator Skill (Antigravity Edition) Design Specification

## Overview & Background
The upstream `godot-asset-generator` skill (from `claude-skill-registry`) provided a full 2D asset pipeline for Godot 4.x, but had two major limitations for this project:
1. **External API Key Dependency**: Required user-provided API keys (`OPENAI_API_KEY`, `REPLICATE_API_TOKEN`, `FAL_KEY`) and the Deno runtime, incurring costs and friction.
2. **Generic Style Presets**: Did not include specialized prompt guidelines or reference image techniques matching the active project's distinct 2.5D fairytale storybook diorama aesthetic (`new-piano`).

This design specifies a localized, fully self-contained skill for Antigravity and Godot 4.x that:
- Replaces external API calls with Antigravity's built-in `generate_image` tool (zero API keys, free, interactive, multi-aspect-ratio).
- Leverages reference image guidance via `ImagePaths` (up to 3 images) for high character and style consistency.
- Bundles lightweight, standalone Python 3 + Pillow utilities in `scripts/` to handle background removal, alpha feathering, whitespace trimming, sprite sheet packing, and Godot `.import` file generation.
- Supports both general Godot art styles (Pixel Art, Vector UI, Painterly) and a specialized preset for the `new-piano` project (`fairytale-2.5d-storybook`).

---

## Architecture & Directory Layout

The skill will be created directly within the project's workspace customization root (`.agents/skills/`) and symlinked to `.claude/skills/`:

```
.agents/skills/godot-asset-generator/
├── SKILL.md                          # Main skill guide & prompt reference
└── scripts/
    ├── process_asset.py              # Background removal, alpha feathering, trim, resize
    ├── pack_spritesheet.py           # Multi-frame sprite sheet packer with metadata output
    └── make_godot_import.py          # Godot 4 .import file generator
```

A symlink from `.claude/skills/godot-asset-generator` points to `.agents/skills/godot-asset-generator` to ensure compatibility across agent runtimes.

---

## Detailed Components

### 1. `SKILL.md` Specification
- **Frontmatter**:
  ```yaml
  ---
  name: godot-asset-generator
  description: Use when generating game art, 2D sprites, UI icons, or sprite sheets for Godot without external API keys using Antigravity image generation and Python post-processing.
  ---
  ```
- **Sections**:
  1. **Overview & Philosophy**: Antigravity-native generation + local post-processing.
  2. **When to Use / When Not to Use**.
  3. **Core Generation Workflow**:
     - Formulate prompt using style formulas.
     - Identify up to 3 reference images from `assets/art/` to pass into `ImagePaths`.
     - Call `generate_image` with chosen `AspectRatio` (`1:1`, `4:3`, `16:9`, `3:4`, `9:16`).
     - Post-process the generated artifact using `scripts/` into `res://assets/art/`.
     - Generate `.import` file for Godot 4.
  4. **Art Style Presets & Prompt Engineering**:
     - `fairytale-2.5d` (Primary preset for `new-piano`): Cute whimsical storybook diorama, tactile wood/clay texture, vibrant colors, soft lighting, isolated on white background.
     - `pixel-art`: 16-bit, clean pixels, no anti-aliasing, transparent/solid background.
     - `vector-ui`: Flat design, clean borders, minimal shading, icon centric.
     - `painterly-bg`: Storybook landscape, lush scenery, fairytale backdrop.
  5. **CLI Scripts Documentation & Options**.
  6. **Troubleshooting & Edge Cases**: Dealing with halos, antialiasing downscaling, frame inconsistencies.

---

### 2. Python Utilities Specification (`scripts/`)

#### A. `process_asset.py`
- **Purpose**: Cleans raw AI artifacts into game-ready sprites.
- **Dependencies**: Python 3 standard library + `PIL` (Pillow).
- **Arguments**:
  - `--input <path>` (Required): Path to raw image artifact.
  - `--output <path>` (Required): Target destination file (PNG).
  - `--remove-bg`: Removes uniform background by sampling corner pixels or targeted luminance.
  - `--color-key <hex>`: Hex color to make transparent (e.g. `#FFFFFF` or `#00FF00`).
  - `--tolerance <float>`: Color distance tolerance (default: 0.15).
  - `--feather <float>`: Alpha feather softness radius (default: 0.04) to avoid harsh borders or white halos.
  - `--trim`: Auto-crops excess transparent bounding pixels.
  - `--padding <int>`: Adds border padding around cropped image (default: 4).
  - `--resize <WxH>`: Resizes output to explicit width and height.
  - `--filter <nearest|lanczos>`: Resampling filter (`nearest` for pixel art, `lanczos` for HD storybook).

#### B. `pack_spritesheet.py`
- **Purpose**: Packs animation frames or modular sprite parts into a single texture atlas.
- **Dependencies**: Python 3 standard library + `PIL` (Pillow).
- **Arguments**:
  - `--input <glob/paths...>` (Required): List of input PNG files or glob pattern.
  - `--output <path>` (Required): Target sprite sheet PNG path.
  - `--columns <int>`: Number of columns in sheet (default: auto).
  - `--padding <int>`: Pixel spacing between frames.
  - `--metadata <path>`: Optional JSON file path detailing bounding boxes `{"frames": [{"name": ..., "x": ..., "y": ..., "w": ..., "h": ...}]}`.

#### C. `make_godot_import.py`
- **Purpose**: Generates standard Godot 4 `.png.import` files so Godot imports the asset with optimal texture settings automatically.
- **Arguments**:
  - `--input <path>` (Required): Image file or directory of images.
  - `--preset <storybook-hd|pixel-art|ui>`:
    - `storybook-hd`: Lossless compression, Linear Mipmap filter, `fix_alpha_border=true`, mipmaps enabled.
    - `pixel-art`: Lossless compression, Nearest filter, `fix_alpha_border=true`, mipmaps disabled.
    - `ui`: Lossless compression, Linear filter, mipmaps disabled.

---

## Verification & Testing Plan
1. **Script Validation**:
   - Run unit tests on a sample test image using `process_asset.py` (color keying, feathering, padding, and resizing).
   - Run `pack_spritesheet.py` on multiple frames to generate a packed sheet and verify metadata JSON.
   - Run `make_godot_import.py` to create a `.import` file and verify its contents against Godot 4.x specification.
2. **Skill Verification**:
   - Verify skill file syntax, frontmatter conformity, and discovery path in `.agents/skills/`.
   - Verify symlink in `.claude/skills/`.
