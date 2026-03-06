#!/usr/bin/env python3
"""Generate App Store promotional screenshots (1284x2778)."""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# App Store required size
W, H = 1284, 2778

# Phone screenshot area (with padding for "frame" effect)
PHONE_W = 1050
PHONE_H = 2280
CORNER_RADIUS = 60

# Colors (app's dark green theme)
BG_TOP = (8, 25, 18)       # dark green-black
BG_BOT = (4, 12, 8)        # near black
ACCENT = (34, 197, 94)     # green accent
TEXT_COLOR = (255, 255, 255)

SCREENSHOTS = [
    ("01_market.png",        "Рынок\nв реальном\nвремени"),
    ("02_signals.png",       "Торговые\nсигналы"),
    ("03_history.png",       "Полная история\nсделок"),
    ("04_profile.png",       "Управление\nаккаунтом"),
    ("05_ticker_detail.png", "Детальная\nаналитика"),
]

def rounded_rectangle_mask(size, radius):
    """Create a rounded rectangle mask."""
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), (size[0]-1, size[1]-1)], radius=radius, fill=255)
    return mask

def create_gradient(w, h, top_color, bot_color):
    """Create a vertical gradient."""
    img = Image.new("RGB", (w, h))
    for y in range(h):
        ratio = y / h
        r = int(top_color[0] * (1 - ratio) + bot_color[0] * ratio)
        g = int(top_color[1] * (1 - ratio) + bot_color[1] * ratio)
        b = int(top_color[2] * (1 - ratio) + bot_color[2] * ratio)
        for x in range(w):
            img.putpixel((x, y), (r, g, b))
    return img

def create_gradient_fast(w, h, top_color, bot_color):
    """Create a vertical gradient using numpy-like approach."""
    import array
    pixels = []
    for y in range(h):
        ratio = y / h
        r = int(top_color[0] * (1 - ratio) + bot_color[0] * ratio)
        g = int(top_color[1] * (1 - ratio) + bot_color[1] * ratio)
        b = int(top_color[2] * (1 - ratio) + bot_color[2] * ratio)
        row = bytes([r, g, b] * w)
        pixels.append(row)
    data = b''.join(pixels)
    img = Image.frombytes("RGB", (w, h), data)
    return img

def draw_text_with_shadow(draw, text, position, font, fill, shadow_color=(0,0,0,128), shadow_offset=4):
    """Draw text with a shadow."""
    x, y = position
    # Shadow
    draw.text((x + shadow_offset, y + shadow_offset), text, font=font, fill=shadow_color, anchor="mt")
    # Main text
    draw.text((x, y), text, font=font, fill=fill, anchor="mt")

def find_font(size):
    """Try to find a bold system font."""
    font_paths = [
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/SFNSDisplay.ttf",
        "/System/Library/Fonts/SFNS.ttf",
        "/Library/Fonts/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    ]
    for fp in font_paths:
        if os.path.exists(fp):
            try:
                return ImageFont.truetype(fp, size)
            except:
                continue
    return ImageFont.load_default()

def make_promo(screenshot_path, title_text, output_path):
    """Create one promotional screenshot."""
    print(f"  Creating {os.path.basename(output_path)}...")
    
    # 1. Create gradient background
    bg = create_gradient_fast(W, H, BG_TOP, BG_BOT)
    
    # 2. Add subtle green accent glow at center
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    # Draw a large ellipse with low opacity green
    for i in range(5):
        r = 400 + i * 80
        alpha = max(5, 20 - i * 4)
        glow_draw.ellipse(
            [W//2 - r, H//2 - r + 200, W//2 + r, H//2 + r + 200],
            fill=(ACCENT[0], ACCENT[1], ACCENT[2], alpha)
        )
    glow_blurred = glow.filter(ImageFilter.GaussianBlur(radius=80))
    bg.paste(Image.alpha_composite(Image.new("RGBA", (W, H), (0,0,0,0)), glow_blurred).convert("RGB"), (0, 0))
    bg = bg.convert("RGBA")
    
    # 3. Load and resize screenshot
    screenshot = Image.open(screenshot_path).convert("RGBA")
    # Scale to fit phone area
    ss_ratio = min(PHONE_W / screenshot.width, PHONE_H / screenshot.height)
    new_ss_w = int(screenshot.width * ss_ratio)
    new_ss_h = int(screenshot.height * ss_ratio)
    screenshot = screenshot.resize((new_ss_w, new_ss_h), Image.LANCZOS)
    
    # 4. Create phone frame (dark border + rounded corners)
    frame_padding = 16
    frame_w = new_ss_w + frame_padding * 2
    frame_h = new_ss_h + frame_padding * 2
    
    # Phone bezel
    bezel = Image.new("RGBA", (frame_w, frame_h), (30, 30, 30, 255))
    bezel_mask = rounded_rectangle_mask((frame_w, frame_h), CORNER_RADIUS + 8)
    
    # Screenshot with rounded corners
    ss_mask = rounded_rectangle_mask((new_ss_w, new_ss_h), CORNER_RADIUS)
    
    # Compose phone
    phone = Image.new("RGBA", (frame_w, frame_h), (0, 0, 0, 0))
    phone.paste(bezel, (0, 0), bezel_mask)
    phone.paste(screenshot, (frame_padding, frame_padding), ss_mask)
    
    # 5. Position phone on background (lower half)
    phone_x = (W - frame_w) // 2
    phone_y = H - frame_h - 60  # 60px from bottom
    
    # Add subtle border glow
    border_glow = Image.new("RGBA", (frame_w + 8, frame_h + 8), (0, 0, 0, 0))
    bg_glow_draw = ImageDraw.Draw(border_glow)
    bg_glow_draw.rounded_rectangle(
        [(0, 0), (frame_w + 7, frame_h + 7)],
        radius=CORNER_RADIUS + 12,
        outline=(ACCENT[0], ACCENT[1], ACCENT[2], 60),
        width=3
    )
    border_glow = border_glow.filter(ImageFilter.GaussianBlur(radius=4))
    bg.paste(border_glow, (phone_x - 4, phone_y - 4), border_glow)
    
    # Paste phone
    bg.paste(phone, (phone_x, phone_y), phone)
    
    # 6. Add title text
    draw = ImageDraw.Draw(bg)
    
    # Calculate available space above phone
    text_area_top = 80
    text_area_bottom = phone_y - 40
    text_center_y = (text_area_top + text_area_bottom) // 2
    
    # Find font size that fits
    font_size = 120
    font = find_font(font_size)
    
    # Draw multi-line text
    lines = title_text.split('\n')
    line_height = font_size + 20
    total_text_height = len(lines) * line_height
    start_y = text_center_y - total_text_height // 2
    
    for i, line in enumerate(lines):
        y = start_y + i * line_height
        # Shadow
        draw.text((W // 2 + 3, y + 3), line, font=font, fill=(0, 0, 0, 180), anchor="mt")
        # Text
        draw.text((W // 2, y), line, font=font, fill=TEXT_COLOR, anchor="mt")
    
    # 7. Add accent line under text
    line_y = start_y + total_text_height + 20
    line_w = 120
    draw.rounded_rectangle(
        [(W//2 - line_w//2, line_y), (W//2 + line_w//2, line_y + 6)],
        radius=3,
        fill=ACCENT
    )
    
    # 8. Save
    bg = bg.convert("RGB")
    bg.save(output_path, "PNG")
    print(f"    ✅ Saved: {output_path}")

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    for i, (filename, title) in enumerate(SCREENSHOTS):
        input_path = os.path.join(script_dir, filename)
        output_path = os.path.join(script_dir, f"promo_{i+1:02d}_{filename}")
        
        if not os.path.exists(input_path):
            print(f"  ⚠️ Skipping {filename} — not found")
            continue
        
        make_promo(input_path, title, output_path)
    
    print("\n🎉 All promo screenshots created!")

if __name__ == "__main__":
    main()
