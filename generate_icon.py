#!/usr/bin/env python3
"""Generate NexNote premium app icon — indigo-to-lavender gradient with stylized 'N'."""

from PIL import Image, ImageDraw, ImageFont
import math
import os

SIZE = 1024

def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(len(c1)))

def create_icon():
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # --- Gradient Background (diagonal: top-left indigo → bottom-right lavender) ---
    indigo = (108, 99, 255)
    lavender = (179, 136, 255)
    soft_purple = (214, 165, 255)

    for y in range(SIZE):
        for x in range(SIZE):
            t = (x / SIZE * 0.6 + y / SIZE * 0.4)
            t = max(0.0, min(1.0, t))
            if t < 0.5:
                color = lerp_color(indigo, lavender, t * 2)
            else:
                color = lerp_color(lavender, soft_purple, (t - 0.5) * 2)
            img.putpixel((x, y), (*color, 255))

    # --- Subtle glass overlay (top-left lighter area) ---
    overlay = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay)
    for y in range(SIZE // 2):
        alpha = int(35 * (1 - y / (SIZE // 2)))
        overlay_draw.line([(0, y), (SIZE, y)], fill=(255, 255, 255, alpha))
    img = Image.alpha_composite(img, overlay)

    # --- Inner subtle glow (center) ---
    glow = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    cx, cy = SIZE // 2, SIZE // 2
    max_r = SIZE // 3
    for r in range(max_r, 0, -1):
        alpha = int(20 * (1 - r / max_r))
        glow_draw.ellipse(
            [cx - r, cy - r, cx + r, cy + r],
            fill=(255, 255, 255, alpha)
        )
    img = Image.alpha_composite(img, glow)

    draw = ImageDraw.Draw(img)

    # --- Layered abstract shapes behind the N (three translucent planes) ---
    planes = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    planes_draw = ImageDraw.Draw(planes)

    # Layer 1 — back (offset left-down)
    planes_draw.rounded_rectangle(
        [260, 310, 660, 760],
        radius=32,
        fill=(255, 255, 255, 25)
    )
    # Layer 2 — middle
    planes_draw.rounded_rectangle(
        [300, 280, 700, 730],
        radius=32,
        fill=(255, 255, 255, 30)
    )
    # Layer 3 — front
    planes_draw.rounded_rectangle(
        [340, 250, 740, 700],
        radius=32,
        fill=(255, 255, 255, 20)
    )
    img = Image.alpha_composite(img, planes)

    draw = ImageDraw.Draw(img)

    # --- Stylized "N" ---
    # Draw a bold geometric N using polygon shapes
    n_layer = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    n_draw = ImageDraw.Draw(n_layer)

    # N dimensions
    left = 310
    right = 714
    top = 260
    bottom = 764
    stroke_w = 80  # width of vertical strokes
    diag_w = 85    # width of diagonal

    # Left vertical bar
    n_draw.rounded_rectangle(
        [left, top, left + stroke_w, bottom],
        radius=20,
        fill=(255, 255, 255, 240)
    )

    # Right vertical bar
    n_draw.rounded_rectangle(
        [right - stroke_w, top, right, bottom],
        radius=20,
        fill=(255, 255, 255, 240)
    )

    # Diagonal stroke (polygon)
    n_draw.polygon(
        [
            (left + stroke_w - 10, top),
            (left + stroke_w + diag_w - 20, top),
            (right - stroke_w + 10, bottom),
            (right - stroke_w - diag_w + 20, bottom),
        ],
        fill=(255, 255, 255, 235)
    )

    # Subtle shadow under the N
    shadow = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle(
        [left + 4, top + 6, right + 4, bottom + 6],
        radius=20,
        fill=(50, 30, 100, 30)
    )
    img = Image.alpha_composite(img, shadow)
    img = Image.alpha_composite(img, n_layer)

    # --- Small "dot" accent (bottom-right of N) ---
    draw = ImageDraw.Draw(img)
    dot_x, dot_y = right - 20, bottom - 20
    dot_r = 18
    draw.ellipse(
        [dot_x - dot_r, dot_y - dot_r, dot_x + dot_r, dot_y + dot_r],
        fill=(255, 255, 255, 200)
    )

    return img


def save_all_sizes(icon):
    """Save icon at all required iOS sizes."""
    base = os.path.dirname(os.path.abspath(__file__))
    asset_dir = os.path.join(base, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')

    sizes = {
        'Icon-App-1024x1024@1x.png': 1024,
        'Icon-App-20x20@1x.png': 20,
        'Icon-App-20x20@2x.png': 40,
        'Icon-App-20x20@3x.png': 60,
        'Icon-App-29x29@1x.png': 29,
        'Icon-App-29x29@2x.png': 58,
        'Icon-App-29x29@3x.png': 87,
        'Icon-App-40x40@1x.png': 40,
        'Icon-App-40x40@2x.png': 80,
        'Icon-App-40x40@3x.png': 120,
        'Icon-App-60x60@2x.png': 120,
        'Icon-App-60x60@3x.png': 180,
        'Icon-App-76x76@1x.png': 76,
        'Icon-App-76x76@2x.png': 152,
        'Icon-App-83.5x83.5@2x.png': 167,
    }

    for filename, size in sizes.items():
        resized = icon.resize((size, size), Image.LANCZOS)
        # Convert to RGB (iOS icons must not have alpha)
        rgb = Image.new('RGB', (size, size), (108, 99, 255))
        rgb.paste(resized, mask=resized.split()[3] if resized.mode == 'RGBA' else None)
        path = os.path.join(asset_dir, filename)
        rgb.save(path, 'PNG')
        print(f'  ✓ {filename} ({size}x{size})')

    print(f'\nAll icons saved to:\n  {asset_dir}')


if __name__ == '__main__':
    print('Generating NexNote app icon…')
    icon = create_icon()
    save_all_sizes(icon)
    print('Done!')
