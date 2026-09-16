#!/usr/bin/env python3
"""
Process raw AI generated assets for Màn 05: Level Select 2.5D Diorama.
Performs intelligent flood-fill background removal, defringing, and resizing.
"""
from PIL import Image, ImageFilter
import numpy as np
from collections import deque
import os

ARTIFACT_DIR = "/Users/anhtu/.gemini/antigravity-ide/brain/19075892-5377-470a-8cfb-dc01a119d4c6"
TARGET_DIR = "/Users/anhtu/MySpace/new-piano/assets/art"

def remove_background_floodfill(img_path: str, bg_thresh: int = 242, tolerance: int = 25) -> Image.Image:
    """Flood-fill from corners to find all connected background pixels without touching interior white regions."""
    img = Image.open(img_path).convert("RGB")
    w, h = img.size
    arr = np.array(img, dtype=np.int32)
    
    # Check if a pixel is near-white
    is_white = (arr[:, :, 0] >= bg_thresh - tolerance) & \
               (arr[:, :, 1] >= bg_thresh - tolerance) & \
               (arr[:, :, 2] >= bg_thresh - tolerance)
    
    # 2D BFS from border pixels
    visited = np.zeros((h, w), dtype=bool)
    queue = deque()
    
    for x in range(w):
        if is_white[0, x]:
            queue.append((0, x))
            visited[0, x] = True
        if is_white[h - 1, x]:
            queue.append((h - 1, x))
            visited[h - 1, x] = True
            
    for y in range(h):
        if is_white[y, 0] and not visited[y, 0]:
            queue.append((y, 0))
            visited[y, 0] = True
        if is_white[y, w - 1] and not visited[y, w - 1]:
            queue.append((y, w - 1))
            visited[y, w - 1] = True
            
    while queue:
        cy, cx = queue.popleft()
        for dy, dx in [(-1,0), (1,0), (0,-1), (0,1)]:
            ny, nx = cy + dy, cx + dx
            if 0 <= ny < h and 0 <= nx < w and not visited[ny, nx]:
                if is_white[ny, nx]:
                    visited[ny, nx] = True
                    queue.append((ny, nx))
                    
    # Create alpha channel: visited background -> 0, foreground -> 255
    alpha = np.where(visited, 0, 255).astype(np.uint8)
    
    # Soften alpha edge with small blur
    alpha_img = Image.fromarray(alpha, mode='L').filter(ImageFilter.GaussianBlur(0.8))
    
    rgba = img.convert("RGBA")
    rgba.putalpha(alpha_img)
    return rgba

def crop_and_resize(rgba: Image.Image, target_size: tuple, pad_ratio: float = 0.04) -> Image.Image:
    """Crop to non-transparent bounding box with padding, then resize with aspect ratio preserved."""
    bbox = rgba.getbbox()
    if bbox:
        w, h = rgba.size
        bw = bbox[2] - bbox[0]
        bh = bbox[3] - bbox[1]
        pad_x = int(bw * pad_ratio)
        pad_y = int(bh * pad_ratio)
        crop_box = (
            max(0, bbox[0] - pad_x),
            max(0, bbox[1] - pad_y),
            min(w, bbox[2] + pad_x),
            min(h, bbox[3] + pad_y)
        )
        cropped = rgba.crop(crop_box)
    else:
        cropped = rgba
        
    out = Image.new("RGBA", target_size, (0, 0, 0, 0))
    scale = min(target_size[0] / cropped.width, target_size[1] / cropped.height)
    new_w = int(cropped.width * scale)
    new_h = int(cropped.height * scale)
    resized = cropped.resize((new_w, new_h), Image.LANCZOS)
    
    paste_x = (target_size[0] - new_w) // 2
    paste_y = (target_size[1] - new_h) // 2
    out.paste(resized, (paste_x, paste_y), resized)
    return out

def process_circular_button(img_path: str, target_size: int = 180) -> Image.Image:
    """Extract circular medallion with smooth circular alpha mask, perfectly centered."""
    img = Image.open(img_path).convert("RGBA")
    w, h = img.size
    
    # Bounding box of content
    arr = np.array(img.convert("RGB"), dtype=np.int32)
    is_dark = (arr[:, :, 0] < 235) | (arr[:, :, 1] < 235) | (arr[:, :, 2] < 235)
    y_indices, x_indices = np.where(is_dark)
    
    if len(x_indices) > 0 and len(y_indices) > 0:
        min_x, max_x = int(np.min(x_indices)), int(np.max(x_indices))
        min_y, max_y = int(np.min(y_indices)), int(np.max(y_indices))
        bw = max_x - min_x
        # Exclude bottom contact shadow: medallion is round, so height should match width
        bh = bw
        cx = (min_x + max_x) // 2
        cy = min_y + bw // 2 + 10 # Center of circular medallion
        
        half_side = int(bw * 0.51)
        crop_box = (
            max(0, cx - half_side),
            max(0, cy - half_side),
            min(w, cx + half_side),
            min(h, cy + half_side)
        )
        cropped = img.crop(crop_box)
    else:
        cropped = img
        
    scaled = cropped.resize((target_size, target_size), Image.LANCZOS)
    
    # Create smooth circular alpha mask
    mask = Image.new("L", (target_size * 4, target_size * 4), 0)
    from PIL import ImageDraw
    draw = ImageDraw.Draw(mask)
    margin = 12
    draw.ellipse([margin, margin, target_size * 4 - margin, target_size * 4 - margin], fill=255)
    mask = mask.resize((target_size, target_size), Image.LANCZOS)
    
    scaled.putalpha(mask)
    return scaled

def clean_bottom_shadow(rgba: Image.Image, bottom_pct: float = 0.12) -> Image.Image:
    """Remove faint contact shadows at bottom of sprite."""
    arr = np.array(rgba)
    h, w, _ = arr.shape
    start_y = int(h * (1.0 - bottom_pct))
    
    # In the bottom region, if pixel is near-white or grey shadow, fade alpha to 0
    for y in range(start_y, h):
        for x in range(w):
            r, g, b, a = arr[y, x]
            if a > 0:
                # If luminance is high and saturation is very low (grey/white shadow)
                max_c = max(r, g, b)
                min_c = min(r, g, b)
                sat = max_c - min_c
                if max_c > 190 or sat < 30:
                    arr[y, x, 3] = 0
    return Image.fromarray(arr, mode="RGBA")


def main():
    print("=== BẮT ĐẦU XỬ LÝ HẬU KỲ ASSETS 2.5D MÀN 05 (LEVEL SELECT) ===")
    
    # 1. tex_bg_level_select_clean.png
    bg_raw = os.path.join(ARTIFACT_DIR, "level_select_clean_stage_1789526217896.jpg")
    bg_out = os.path.join(TARGET_DIR, "tex_bg_level_select_clean.png")
    img_bg = Image.open(bg_raw).convert("RGB")
    img_bg = img_bg.resize((1280, 720), Image.LANCZOS)
    img_bg.save(bg_out, "PNG", optimize=True)
    print(f"[OK] 1. Phông nền sạch: {bg_out} (1280x720)")
    
    # 2. spr_level_pad_wood.png
    pad_raw = os.path.join(ARTIFACT_DIR, "level_pad_wood_1789526242733.jpg")
    pad_out = os.path.join(TARGET_DIR, "spr_level_pad_wood.png")
    pad_rgba = remove_background_floodfill(pad_raw, bg_thresh=244, tolerance=20)
    pad_final = crop_and_resize(pad_rgba, (240, 200), pad_ratio=0.03)
    pad_final.save(pad_out, "PNG", optimize=True)
    print(f"[OK] 2. Bục gỗ khoanh cây: {pad_out} (240x200)")
    
    # 3. spr_bunny_mascot_stand.png
    bunny_raw = os.path.join(ARTIFACT_DIR, "bunny_pure_white_1789526289333.jpg")
    bunny_out = os.path.join(TARGET_DIR, "spr_bunny_mascot_stand.png")
    bunny_rgba = remove_background_floodfill(bunny_raw, bg_thresh=248, tolerance=15)
    bunny_final = crop_and_resize(bunny_rgba, (180, 240), pad_ratio=0.02)
    bunny_final.save(bunny_out, "PNG", optimize=True)
    print(f"[OK] 3. Bạn Thỏ Trắng Mascot: {bunny_out} (180x240)")
    
    # 4. spr_level_chest_gold.png
    chest_raw = os.path.join(ARTIFACT_DIR, "level_chest_gold_1789526312926.jpg")
    chest_out = os.path.join(TARGET_DIR, "spr_level_chest_gold.png")
    chest_rgba = remove_background_floodfill(chest_raw, bg_thresh=245, tolerance=20)
    chest_final = crop_and_resize(chest_rgba, (200, 200), pad_ratio=0.03)
    chest_final = clean_bottom_shadow(chest_final, bottom_pct=0.15)
    chest_final.save(chest_out, "PNG", optimize=True)
    print(f"[OK] 4. Rương Báu Thần Bục 5: {chest_out} (200x200)")
    
    # 5. ui_stars_3_cluster.png
    stars_raw = os.path.join(ARTIFACT_DIR, "stars_trio_white_1789526366121.jpg")
    stars_out = os.path.join(TARGET_DIR, "ui_stars_3_cluster.png")
    stars_rgba = remove_background_floodfill(stars_raw, bg_thresh=248, tolerance=15)
    stars_final = crop_and_resize(stars_rgba, (200, 110), pad_ratio=0.03)
    stars_final = clean_bottom_shadow(stars_final, bottom_pct=0.15)
    stars_final.save(stars_out, "PNG", optimize=True)
    print(f"[OK] 5. Cụm 3 Sao Vàng: {stars_out} (200x110)")
    
    # 6. ui_btn_wood_back.png
    back_raw = os.path.join(ARTIFACT_DIR, "btn_wood_back_1789526387239.jpg")
    back_out = os.path.join(TARGET_DIR, "ui_btn_wood_back.png")
    back_final = process_circular_button(back_raw, target_size=180)
    back_final.save(back_out, "PNG", optimize=True)
    print(f"[OK] 6. Nút Quay Lại Gỗ Zero-Text: {back_out} (180x180)")
    
    print("=== HOÀN TẤT TOÀN BỘ 6/6 ASSET CHO MÀN 05! ===")

if __name__ == "__main__":
    main()
