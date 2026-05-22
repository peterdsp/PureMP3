from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "Assets"
ASSETS.mkdir(exist_ok=True)


def font(size, weight="regular"):
    candidates = {
        "regular": [
            "/System/Library/Fonts/SFNS.ttf",
            "/System/Library/Fonts/Supplemental/Arial.ttf",
        ],
        "bold": [
            "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
            "/System/Library/Fonts/SFNS.ttf",
        ],
    }

    for path in candidates[weight]:
        if Path(path).exists():
            return ImageFont.truetype(path, size)

    return ImageFont.load_default()


FONT_11 = font(22)
FONT_12 = font(24)
FONT_13 = font(26)
FONT_14 = font(28)
FONT_16 = font(32)
FONT_18 = font(36, "bold")
FONT_22 = font(44, "bold")
FONT_28 = font(56, "bold")


def rounded(draw, xy, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def text(draw, xy, value, fill, fnt, anchor=None):
    draw.text(xy, value, font=fnt, fill=fill, anchor=anchor)


def make_canvas():
    image = Image.new("RGB", (1600, 1000), "#0b0f14")
    draw = ImageDraw.Draw(image)

    for index in range(0, 1600, 3):
        tone = int(12 + index / 1600 * 14)
        draw.line((index, 0, index, 1000), fill=(tone, tone + 2, tone + 8))

    glow = Image.new("RGBA", image.size, (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse((1040, -260, 1840, 540), fill=(65, 120, 255, 42))
    glow_draw.ellipse((-260, 560, 520, 1340), fill=(31, 180, 145, 34))
    image = Image.alpha_composite(image.convert("RGBA"), glow.filter(ImageFilter.GaussianBlur(72)))
    return image.convert("RGB")


def draw_window(draw, state):
    window = (150, 120, 1450, 850)
    rounded(draw, window, 28, "#181b20", "#353a42", 2)
    draw.rectangle((150, 184, 1450, 186), fill="#2b3037")

    for i, color in enumerate(["#ff5f57", "#febc2e", "#28c840"]):
        draw.ellipse((188 + i * 34, 146, 208 + i * 34, 166), fill=color)

    text(draw, (210, 225), "PureMP3", "#f5f7fb", FONT_28)
    text(draw, (210, 286), "A small, honest MP3 converter powered by FFmpeg.", "#a7adb8", FONT_14)

    rounded(draw, (1030, 218, 1190, 272), 14, "#30343b")
    text(draw, (1056, 232), "+", "#f5f7fb", FONT_18)
    text(draw, (1090, 232), "Add files", "#f5f7fb", FONT_14)

    convert_fill = "#0a84ff" if state in ("ready", "done") else "#2b3036"
    convert_text = "#ffffff" if state in ("ready", "done") else "#747b86"
    rounded(draw, (1210, 218, 1390, 272), 14, convert_fill)
    text(draw, (1288, 232), "Convert", convert_text, FONT_14)

    draw.rectangle((150, 322, 504, 850), fill="#15181d")
    draw.line((504, 322, 504, 850), fill="#30343a", width=2)

    text(draw, (210, 364), "QUALITY", "#8f96a3", FONT_11)
    presets = [
        ("VBR Best", "Highest-quality VBR", False),
        ("VBR Balanced", "Best default", True),
        ("320 kbps", "Fixed 320 kbps", False),
        ("256 kbps", "Very good music quality", False),
        ("192 kbps", "General purpose", False),
    ]
    y = 398
    for title, subtitle, selected in presets:
        fill = "#10243f" if selected else "#15181d"
        outline = "#245b9f" if selected else "#15181d"
        rounded(draw, (196, y, 464, y + 60), 14, fill, outline)
        dot = "#0a84ff" if selected else "#8f96a3"
        draw.ellipse((218, y + 19, 240, y + 41), outline=dot, width=3)
        if selected:
            draw.ellipse((222, y + 23, 236, y + 37), fill=dot)
        text(draw, (260, y + 9), title, "#f0f3f7", FONT_13)
        text(draw, (260, y + 36), subtitle, "#98a0ab", FONT_11)
        y += 72

    draw.line((196, 772, 464, 772), fill="#2b3037", width=2)
    text(draw, (210, 802), "OUTPUT", "#8f96a3", FONT_11)
    rounded(draw, (300, 792, 464, 840), 12, "#2b3036")
    text(draw, (322, 806), "Music", "#e7ebf0", FONT_13)

    if state == "empty":
        rounded(draw, (690, 424, 1220, 686), 24, "#20242b", "#3b424d", 2)
        text(draw, (955, 486), "⇩", "#8f96a3", FONT_28, "mm")
        text(draw, (955, 550), "Drop files to convert", "#f5f7fb", FONT_22, "mm")
        text(draw, (955, 604), "MP4, M4A, WAV, FLAC, and MP3 are supported.", "#9ea6b2", FONT_13, "mm")
        rounded(draw, (870, 638, 1040, 690), 14, "#0a84ff")
        text(draw, (955, 664), "Choose files", "#ffffff", FONT_13, "mm")
    else:
        rows = [
            ("Live Set.mov", "04:18 to Live Set.mp3", "Ready"),
            ("Podcast Cut.m4a", "31:02 to Podcast Cut.mp3", "Ready"),
            ("Archive Track.mp3", "Already lossy MP3. Use original source if possible.", "Warn"),
        ]
        y = 388
        for title, subtitle, status in rows:
            rounded(draw, (566, y, 1390, y + 92), 16, "#20242a", "#2f3540", 1)
            text(draw, (606, y + 22), "≋", "#8f96a3", FONT_18)
            text(draw, (654, y + 20), title, "#f4f6fa", FONT_16)
            color = "#f5a524" if status == "Warn" else "#9ea6b2"
            text(draw, (654, y + 54), subtitle, color, FONT_12)
            chip_color = "#0a84ff" if state == "done" and status != "Warn" else "#2d333c"
            chip_text = "Done" if state == "done" and status != "Warn" else status
            rounded(draw, (1290, y + 28, 1354, y + 64), 12, chip_color)
            text(draw, (1322, y + 46), chip_text, "#ffffff", FONT_11, "mm")
            y += 110

    draw.rectangle((150, 850, 1450, 850), fill="#2f3540")
    text(draw, (190, 884), "› ffmpeg -i input.mp4 -vn -codec:a libmp3lame -q:a 2 output.mp3", "#9fa7b3", FONT_12)


def make_frame(state):
    image = make_canvas()
    draw = ImageDraw.Draw(image)
    draw_window(draw, state)
    return image


hero = make_frame("ready")
hero.save(ASSETS / "puremp3-app-preview.png", optimize=True)

frames = [make_frame("empty"), make_frame("ready"), make_frame("done")]
frames[0].save(
    ASSETS / "puremp3-demo.gif",
    save_all=True,
    append_images=frames[1:],
    duration=[900, 1100, 1100],
    loop=0,
    optimize=True,
)

print("Generated README assets")
