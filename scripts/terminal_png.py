#!/usr/bin/env python3
"""Render .txt logs as PNG for LMS screenshots."""
from pathlib import Path
import sys

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    sys.exit(0)

def render(txt_path: Path, png_path: Path) -> None:
    text = txt_path.read_text(errors="replace")
    lines = text.splitlines() or [""]
    line_h = 18
    h = max(200, 40 + line_h * len(lines))
    w = 920
    img = Image.new("RGB", (w, h), (24, 24, 24))
    draw = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Menlo.ttc", 14)
    except OSError:
        font = ImageFont.load_default()
    y = 20
    for line in lines[:120]:
        draw.text((16, y), line[:110], fill=(210, 230, 210), font=font)
        y += line_h
    png_path.write_bytes(b"")
    img.save(png_path)

def main() -> None:
    out = Path(sys.argv[1])
    for txt in sorted(out.glob("*.txt")):
        render(txt, out / (txt.stem + ".png"))

if __name__ == "__main__":
    main()
