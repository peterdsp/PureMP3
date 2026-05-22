from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "Assets"
ICONSET = ASSETS / "PureMP3.iconset"
ICONSET.mkdir(parents=True, exist_ok=True)


def rounded_mask(size, radius):
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size, size), radius=radius, fill=255)
    return mask


def make_icon(size):
    scale = size / 1024
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    base = Image.new("RGBA", (size, size), (0, 0, 0, 255))
    draw = ImageDraw.Draw(base)

    for y in range(size):
        t = y / max(size - 1, 1)
        r = int(2 + 12 * (1 - t))
        g = int(8 + 32 * (1 - t))
        b = int(16 + 58 * (1 - t))
        draw.line((0, y, size, y), fill=(r, g, b, 255))

    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse(
        (
            int(size * 0.10),
            int(size * 0.10),
            int(size * 0.92),
            int(size * 0.88),
        ),
        fill=(0, 132, 255, 92),
    )
    glow_draw.ellipse(
        (
            int(size * -0.12),
            int(size * 0.46),
            int(size * 0.62),
            int(size * 1.18),
        ),
        fill=(0, 230, 180, 58),
    )
    base = Image.alpha_composite(base, glow.filter(ImageFilter.GaussianBlur(int(70 * scale))))

    glass = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    glass_draw = ImageDraw.Draw(glass)
    glass_draw.rounded_rectangle(
        (
            int(size * 0.17),
            int(size * 0.18),
            int(size * 0.83),
            int(size * 0.82),
        ),
        radius=int(size * 0.17),
        fill=(255, 255, 255, 28),
        outline=(255, 255, 255, 90),
        width=max(1, int(3 * scale)),
    )
    glass_draw.rounded_rectangle(
        (
            int(size * 0.24),
            int(size * 0.25),
            int(size * 0.76),
            int(size * 0.40),
        ),
        radius=int(size * 0.08),
        fill=(255, 255, 255, 26),
    )
    base = Image.alpha_composite(base, glass)

    mark = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    mark_draw = ImageDraw.Draw(mark)
    cx = size * 0.50
    stem_width = max(5, int(size * 0.05))
    blue = (40, 146, 255, 255)
    white = (238, 246, 255, 255)

    for index, height in enumerate([0.18, 0.33, 0.48, 0.33, 0.18]):
        x = size * (0.28 + index * 0.11)
        h = size * height
        mark_draw.rounded_rectangle(
            (
                int(x - stem_width / 2),
                int(size * 0.52 - h / 2),
                int(x + stem_width / 2),
                int(size * 0.52 + h / 2),
            ),
            radius=max(2, int(stem_width / 2)),
            fill=blue if index in (1, 2, 3) else white,
        )

    mark_draw.rounded_rectangle(
        (
            int(cx - size * 0.18),
            int(size * 0.70),
            int(cx + size * 0.18),
            int(size * 0.755),
        ),
        radius=int(size * 0.022),
        fill=(238, 246, 255, 225),
    )
    base = Image.alpha_composite(base, mark)

    shine = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shine_draw = ImageDraw.Draw(shine)
    shine_draw.arc(
        (
            int(size * 0.12),
            int(size * 0.10),
            int(size * 0.88),
            int(size * 0.88),
        ),
        205,
        330,
        fill=(255, 255, 255, 94),
        width=max(1, int(8 * scale)),
    )
    base = Image.alpha_composite(base, shine.filter(ImageFilter.GaussianBlur(max(1, int(0.8 * scale)))))

    image.alpha_composite(base)
    image.putalpha(rounded_mask(size, int(size * 0.225)))
    return image


def save_iconset():
    sizes = [
        (16, "icon_16x16.png"),
        (32, "icon_16x16@2x.png"),
        (32, "icon_32x32.png"),
        (64, "icon_32x32@2x.png"),
        (128, "icon_128x128.png"),
        (256, "icon_128x128@2x.png"),
        (256, "icon_256x256.png"),
        (512, "icon_256x256@2x.png"),
        (512, "icon_512x512.png"),
        (1024, "icon_512x512@2x.png"),
    ]

    master = make_icon(1024)
    master.save(ASSETS / "app-icon.png", optimize=True)

    for size, name in sizes:
        master.resize((size, size), Image.Resampling.LANCZOS).save(ICONSET / name, optimize=True)


if __name__ == "__main__":
    save_iconset()
    print("Generated app icon assets")
