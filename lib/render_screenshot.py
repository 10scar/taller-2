#!/usr/bin/env python3
"""Render terminal text output to PNG screenshot."""
import argparse
import textwrap
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def load_font(size: int):
    candidates = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
        "/usr/share/fonts/TTF/DejaVuSansMono.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf",
    ]
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def render_text_to_png(text: str, output: Path, width: int = 1200) -> None:
    font = load_font(14)
    line_height = 18
    margin = 20
    max_chars = max(40, (width - 2 * margin) // 9)
    lines: list[str] = []
    for raw in text.splitlines():
        if not raw.strip():
            lines.append("")
            continue
        wrapped = textwrap.wrap(raw, width=max_chars, replace_whitespace=False, drop_whitespace=False)
        lines.extend(wrapped if wrapped else [""])

    height = margin * 2 + max(1, len(lines)) * line_height
    img = Image.new("RGB", (width, height), color=(24, 26, 32))
    draw = ImageDraw.Draw(img)
    y = margin
    for line in lines:
        draw.text((margin, y), line, fill=(220, 223, 228), font=font)
        y += line_height

    output.parent.mkdir(parents=True, exist_ok=True)
    img.save(output)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input", help="Text file with captured output")
    parser.add_argument("output", help="Output PNG path")
    args = parser.parse_args()
    text = Path(args.input).read_text(encoding="utf-8", errors="replace")
    render_text_to_png(text, Path(args.output))


if __name__ == "__main__":
    main()
