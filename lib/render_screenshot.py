#!/usr/bin/env python3
"""Render terminal text output to PNG with syntax highlighting."""
import argparse
import re
import textwrap
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

# Colors (dark terminal theme)
BG = (24, 26, 32)
TITLE_BAR = (40, 44, 58)
TITLE_TEXT = (180, 186, 200)
DEFAULT = (220, 223, 228)
PROMPT_USER = (110, 231, 183)      # green — $ attacker
PROMPT_ROOT = (125, 211, 252)      # cyan — # server
BOX = (100, 108, 130)
SUCCESS = (110, 231, 183)
WARN = (255, 203, 107)
ERROR = (240, 113, 120)
MUTED = (140, 147, 160)


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


def classify_line(line: str) -> tuple[str, tuple[int, int, int]]:
    s = line.strip()
    if s.startswith("╔") or s.startswith("║") or s.startswith("╚"):
        return line, BOX
    if re.match(r"^oscar@lab\s+\$", line):
        return line, PROMPT_USER
    if re.match(r"^oscar@lab\s+#", line):
        return line, PROMPT_ROOT
    if s.startswith("[+]"):
        return line, SUCCESS
    if s.startswith("[!]") or s.startswith("[-]"):
        return line, ERROR if s.startswith("[-]") else WARN
    if s.startswith("[*]"):
        return line, MUTED
    if "MITIGADO" in s or "neutralizado" in s.lower() or "bloqueado" in s.lower():
        return line, SUCCESS
    if "error" in s.lower() or "fail" in s.lower() or "timeout" in s.lower():
        return line, ERROR
    return line, DEFAULT


def wrap_lines(text: str, max_chars: int) -> list[str]:
    lines: list[str] = []
    for raw in text.splitlines():
        if not raw.strip():
            lines.append("")
            continue
        if raw.startswith("╔") or raw.startswith("║") or raw.startswith("╚"):
            lines.append(raw[:max_chars])
            continue
        wrapped = textwrap.wrap(
            raw, width=max_chars, replace_whitespace=False, drop_whitespace=False
        )
        lines.extend(wrapped if wrapped else [""])
    return lines


def render_text_to_png(text: str, output: Path, width: int = 1200) -> None:
    font = load_font(14)
    font_title = load_font(13)
    line_height = 20
    margin = 16
    title_h = 32
    max_chars = max(40, (width - 2 * margin) // 9)

    body_lines = wrap_lines(text, max_chars)
    height = title_h + margin * 2 + max(1, len(body_lines)) * line_height

    img = Image.new("RGB", (width, height), color=BG)
    draw = ImageDraw.Draw(img)

    # Title bar
    draw.rectangle([0, 0, width, title_h], fill=TITLE_BAR)
    draw.text((margin, 8), "Taller 2 — Captura de laboratorio", fill=TITLE_TEXT, font=font_title)

    y = title_h + margin
    for raw in body_lines:
        line, color = classify_line(raw)
        draw.text((margin, y), line, fill=color, font=font)
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
