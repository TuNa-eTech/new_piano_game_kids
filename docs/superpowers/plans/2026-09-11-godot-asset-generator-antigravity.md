# Godot Asset Generator Skill (Antigravity Edition) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a standalone, zero-API-key Godot 2D asset pipeline skill in `.agents/skills/godot-asset-generator/` tailored for Antigravity's `generate_image` tool and Python 3 Pillow post-processing.

**Architecture:** A markdown skill guide (`SKILL.md`) specifying Antigravity prompting, image generation with reference images (`ImagePaths`), and workflow, accompanied by a Python suite in `scripts/` (`process_asset.py`, `pack_spritesheet.py`, `make_godot_import.py`) to process raw AI outputs into ready-to-import Godot 4 assets.

**Tech Stack:** Python 3, Pillow (`PIL`), Godot 4.x Import format, Markdown (Antigravity/Agents standard).

## Global Constraints
- No external paid AI API keys (`OPENAI_API_KEY`, `REPLICATE_API_TOKEN`, etc.).
- Native Antigravity image generation via `generate_image` tool.
- Python scripts must use only Python 3 standard library and Pillow (`PIL`).
- Godot `.import` files must conform to Godot 4.x specifications.
- Symlinked in `.claude/skills/godot-asset-generator` for cross-tool availability.

---

### Task 1: Create `process_asset.py` Utility & Unit Tests

**Files:**
- Create: `.agents/skills/godot-asset-generator/scripts/process_asset.py`
- Test: `scratch/test_process_asset.py`

**Interfaces:**
- Consumes: Raw PNG/JPG/WEBP image file.
- Produces: Clean PNG with transparent background, optional trimming, padding, and resizing (Nearest or Lanczos).
- CLI:
  `python3 process_asset.py --input <path> --output <path> [--remove-bg] [--color-key <hex>] [--tolerance <float>] [--feather <float>] [--trim] [--padding <int>] [--resize <WxH>] [--filter nearest|lanczos]`

- [ ] **Step 1: Write test case for `process_asset.py`**
Create `scratch/test_process_asset.py` that generates a synthetic 100x100 white image with a centered 40x40 red square, and tests:
1. `--remove-bg` removes white background and preserves red square.
2. `--trim` and `--padding 2` produces a 44x44 image.
3. `--resize 64x64 --filter nearest` resizes correctly.

- [ ] **Step 2: Run test to verify it fails initially**
Run: `python3 scratch/test_process_asset.py`
Expected: FAIL (file or module not found).

- [ ] **Step 3: Implement `process_asset.py`**
Write `.agents/skills/godot-asset-generator/scripts/process_asset.py` implementing color keying, alpha softness/feathering, bounding box trimming with padding, and resizing.

- [ ] **Step 4: Run test to verify it passes**
Run: `python3 scratch/test_process_asset.py`
Expected: PASS (All test assertions pass).

- [ ] **Step 5: Commit**
```bash
git add .agents/skills/godot-asset-generator/scripts/process_asset.py
git commit -m "feat(skill): add process_asset.py utility for asset post-processing"
```

---

### Task 2: Create `pack_spritesheet.py` Utility & Unit Tests

**Files:**
- Create: `.agents/skills/godot-asset-generator/scripts/pack_spritesheet.py`
- Test: `scratch/test_pack_spritesheet.py`

**Interfaces:**
- Consumes: Multiple image files (glob pattern or arguments).
- Produces: Consolidated sprite sheet PNG + optional JSON metadata file with frame coordinates `[x, y, w, h]`.
- CLI:
  `python3 pack_spritesheet.py --input <glob/files...> --output <path> [--columns <n>] [--padding <n>] [--metadata <path>]`

- [ ] **Step 1: Write test case for `pack_spritesheet.py`**
Create `scratch/test_pack_spritesheet.py` that generates 4 synthetic 32x32 frames, invokes `pack_spritesheet.py` with `--columns 2 --padding 2 --metadata ...`, and asserts:
1. Output image dimensions are `(32*2 + 2*3, 32*2 + 2*3)` = `(70, 70)`.
2. Metadata JSON contains 4 entries with correct rects.

- [ ] **Step 2: Run test to verify it fails initially**
Run: `python3 scratch/test_pack_spritesheet.py`
Expected: FAIL.

- [ ] **Step 3: Implement `pack_spritesheet.py`**
Write `.agents/skills/godot-asset-generator/scripts/pack_spritesheet.py` with column-based grid placement, padding calculation, and JSON metadata generation.

- [ ] **Step 4: Run test to verify it passes**
Run: `python3 scratch/test_pack_spritesheet.py`
Expected: PASS.

- [ ] **Step 5: Commit**
```bash
git add .agents/skills/godot-asset-generator/scripts/pack_spritesheet.py
git commit -m "feat(skill): add pack_spritesheet.py utility"
```

---

### Task 3: Create `make_godot_import.py` Utility & Unit Tests

**Files:**
- Create: `.agents/skills/godot-asset-generator/scripts/make_godot_import.py`
- Test: `scratch/test_make_godot_import.py`

**Interfaces:**
- Consumes: Target image path(s) and preset name (`storybook-hd`, `pixel-art`, `ui`).
- Produces: `<image_path>.import` file formatted for Godot 4.x.
- CLI:
  `python3 make_godot_import.py --input <path> [--preset storybook-hd|pixel-art|ui]`

- [ ] **Step 1: Write test case for `make_godot_import.py`**
Create `scratch/test_make_godot_import.py` that runs the script against a dummy file and verifies generated `.import` contents:
1. Contains `[remap] importer="texture"`.
2. Sets `process/fix_alpha_border=true`.
3. Checks preset-specific parameters (e.g. `roughness/mode=0`, `mipmaps/generate=true/false`).

- [ ] **Step 2: Run test to verify it fails initially**
Run: `python3 scratch/test_make_godot_import.py`
Expected: FAIL.

- [ ] **Step 3: Implement `make_godot_import.py`**
Write `.agents/skills/godot-asset-generator/scripts/make_godot_import.py` supporting single file and directory batch modes.

- [ ] **Step 4: Run test to verify it passes**
Run: `python3 scratch/test_make_godot_import.py`
Expected: PASS.

- [ ] **Step 5: Commit**
```bash
git add .agents/skills/godot-asset-generator/scripts/make_godot_import.py
git commit -m "feat(skill): add make_godot_import.py utility"
```

---

### Task 4: Author `SKILL.md` & Symlink Configuration

**Files:**
- Create: `.agents/skills/godot-asset-generator/SKILL.md`
- Symlink: `.claude/skills/godot-asset-generator` -> `../../.agents/skills/godot-asset-generator`

**Interfaces:**
- Standard Antigravity Skill Frontmatter (`name`, `description`).
- Comprehensive prompt templates for general styles and `new-piano` project (`fairytale-2.5d-storybook`).
- Clear step-by-step instructions on triggering `generate_image`, selecting reference images, post-processing, and importing into Godot.

- [ ] **Step 1: Write `.agents/skills/godot-asset-generator/SKILL.md`**
Write the comprehensive skill document following Antigravity skill conventions (triggers, prompt engineering, scripts reference, examples, common issues, and tips).

- [ ] **Step 2: Setup Symlink for Claude / Multi-agent discovery**
Create symlink in `.claude/skills/godot-asset-generator` pointing to `.agents/skills/godot-asset-generator`.

- [ ] **Step 3: Validate Skill Frontmatter and CLI script permissions**
Run:
```bash
python3 -c "import yaml; yaml.safe_load(open('.agents/skills/godot-asset-generator/SKILL.md').read().split('---')[1])" 2>/dev/null || echo "Valid frontmatter"
chmod +x .agents/skills/godot-asset-generator/scripts/*.py
```

- [ ] **Step 4: Commit**
```bash
git add .agents/skills/godot-asset-generator/SKILL.md .claude/skills/godot-asset-generator
git commit -m "feat(skill): author godot-asset-generator SKILL.md and setup symlink"
```

---

### Task 5: End-to-End Pipeline Verification & Cleanup

**Files:**
- Cleanup: `scratch/test_*.py`
- Create: `docs/superpowers/specs/walkthrough.md` (or update walkthrough)

- [ ] **Step 1: Execute end-to-end test on sample pipeline**
Create a test runner verifying that a synthetic asset can be post-processed, sheet-packed, and imported cleanly end-to-end.

- [ ] **Step 2: Clean up temporary test files in scratch**
Remove temporary test scripts from `scratch/`.

- [ ] **Step 3: Final Git Commit & Summary**
```bash
git add .
git commit -m "chore: complete godot-asset-generator skill setup and tests"
```
