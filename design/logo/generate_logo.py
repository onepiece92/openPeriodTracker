#!/usr/bin/env python3
"""Generate the Open Period Tracker mark as SVG, then rasterise with headless Chrome.

Usage:
  python3 design/logo/generate_logo.py            # writes SVGs + PNGs into design/logo/out/
  python3 design/logo/generate_logo.py --svg-only

The mark is an "open" cycle ring: four arcs in the app's phase colours
(menstrual, follicular, ovulation, luteal) sized to a 28-day cycle, with an
opening at the top and a drop in the centre. Three colourways are produced so
one can be chosen; each colourway also gets an Android adaptive-icon
foreground (transparent, mark inside the 66% safe zone) and background.
"""
import math
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out")
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# App palette (lib/core/theme/app_theme.dart)
MENSTRUAL, FOLLICULAR, OVULATION, LUTEAL = "#E07088", "#5BA4B5", "#6AB88A", "#A386BF"
PLUM, PLUM_DEEP = "#2D2440", "#1F1830"
BG_STOPS = ["#FDF2F6", "#EDE4F5", "#E4EDF8", "#EEF6F2"]

SIZE = 1024
CX = CY = SIZE / 2


def pt(r, deg):
    a = math.radians(deg)
    return CX + r * math.sin(a), CY - r * math.cos(a)


def arc(r, a0, a1):
    x0, y0 = pt(r, a0)
    x1, y1 = pt(r, a1)
    large = 1 if (a1 - a0) > 180 else 0
    return f"M {x0:.2f} {y0:.2f} A {r} {r} 0 {large} 1 {x1:.2f} {y1:.2f}"


def ring(colors, r=300, stroke=88, gap=58, start_offset=0.0):
    """Four abutting arcs with an opening of `gap` degrees centred at 12 o'clock."""
    days = [5, 8, 3, 12]  # menstrual, follicular, ovulation, luteal
    span = 360 - gap
    a = gap / 2 + start_offset
    parts = []
    if len(set(colors)) == 1:
        # Single colour: one continuous arc, so no anti-aliasing seams at joints.
        parts.append(
            f'<path d="{arc(r, a, a + span)}" fill="none" stroke="{colors[0]}" '
            f'stroke-width="{stroke}" stroke-linecap="butt"/>'
        )
        a += span
    else:
        for d, c in zip(days, colors):
            sweep = span * d / sum(days)
            parts.append(
                f'<path d="{arc(r, a, a + sweep)}" fill="none" stroke="{c}" '
                f'stroke-width="{stroke}" stroke-linecap="butt"/>'
            )
            a += sweep
    # Round the two open ends.
    (xs, ys), (xe, ye) = pt(r, gap / 2 + start_offset), pt(r, a)
    parts.append(f'<circle cx="{xs:.2f}" cy="{ys:.2f}" r="{stroke/2}" fill="{colors[0]}"/>')
    parts.append(f'<circle cx="{xe:.2f}" cy="{ye:.2f}" r="{stroke/2}" fill="{colors[-1]}"/>')
    return "\n".join(parts)


def drop(color, h=250, cx=CX, cy=CY + 10):
    """Classic drop, height h, centred horizontally on cx with its visual centre near cy."""
    # Base shape in a 100x100 box, tip at (50,8), bowl centre (50,66) r=30.
    s = h / 92.0
    ox, oy = cx - 50 * s, cy - 50 * s
    d = (
        f"M {ox+50*s:.2f} {oy+8*s:.2f} "
        f"C {ox+50*s:.2f} {oy+8*s:.2f} {ox+20*s:.2f} {oy+46*s:.2f} {ox+20*s:.2f} {oy+66*s:.2f} "
        f"A {30*s:.2f} {30*s:.2f} 0 0 0 {ox+80*s:.2f} {oy+66*s:.2f} "
        f"C {ox+80*s:.2f} {oy+46*s:.2f} {ox+50*s:.2f} {oy+8*s:.2f} {ox+50*s:.2f} {oy+8*s:.2f} Z"
    )
    return f'<path d="{d}" fill="{color}"/>'


def svg(body, defs="", bg=None, transparent=False):
    rect = "" if transparent else f'<rect width="{SIZE}" height="{SIZE}" fill="{bg}"/>'
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{SIZE}" height="{SIZE}" '
        f'viewBox="0 0 {SIZE} {SIZE}">\n<defs>{defs}</defs>\n{rect}\n{body}\n</svg>\n'
    )


def grad(id_, stops, x2="1", y2="1"):
    n = len(stops) - 1
    s = "".join(f'<stop offset="{i/n:.3f}" stop-color="{c}"/>' for i, c in enumerate(stops))
    return f'<linearGradient id="{id_}" x1="0" y1="0" x2="{x2}" y2="{y2}">{s}</linearGradient>'


def shadow(id_="sh", dy=18, blur=22, opacity=0.18, color="#2D2440"):
    return (
        f'<filter id="{id_}" x="-20%" y="-20%" width="140%" height="140%">'
        f'<feDropShadow dx="0" dy="{dy}" stdDeviation="{blur}" flood-color="{color}" flood-opacity="{opacity}"/>'
        f"</filter>"
    )


def scaled(body, k):
    """Scale the whole mark about the canvas centre (for adaptive-icon safe zone)."""
    return f'<g transform="translate({CX} {CY}) scale({k}) translate({-CX} {-CY})">{body}</g>'


PHASES = [MENSTRUAL, FOLLICULAR, OVULATION, LUTEAL]


def candidate_a():
    """Light: pastel app gradient, four-phase ring, pink drop."""
    defs = grad("bg", BG_STOPS) + shadow()
    mark = f'<g filter="url(#sh)">{ring(PHASES)}</g>' + drop(MENSTRUAL)
    return dict(
        icon=svg(mark, defs, bg="url(#bg)"),
        fg=svg(scaled(mark, 0.62), defs, transparent=True),
        bg=svg("", grad("bg", BG_STOPS), bg="url(#bg)"),
        bgcolor="#F5EBF6",
    )


def candidate_b():
    """Plum: deep background, same ring, soft glow. Stands out among pink icons."""
    defs = grad("bg", [ "#3A2D52", PLUM, PLUM_DEEP]) + shadow("glow", dy=0, blur=30, opacity=0.55, color="#E07088")
    mark = f'<g filter="url(#glow)">{ring(PHASES)}</g>' + drop("#FFD3DC")
    return dict(
        icon=svg(mark, defs, bg="url(#bg)"),
        fg=svg(scaled(mark, 0.62), defs, transparent=True),
        bg=svg("", grad("bg", ["#3A2D52", PLUM, PLUM_DEEP]), bg="url(#bg)"),
        bgcolor=PLUM,
    )


def candidate_c():
    """Mono: pink→lavender gradient, single white open ring and white drop. Boldest at 60px."""
    defs = grad("bg", [MENSTRUAL, "#C27AA8", LUTEAL]) + shadow("sh", dy=14, blur=18, opacity=0.22)
    mark = f'<g filter="url(#sh)">{ring(["#FFFFFF"]*4, stroke=96)}</g>' + drop("#FFFFFF", h=240)
    return dict(
        icon=svg(mark, defs, bg="url(#bg)"),
        fg=svg(scaled(mark, 0.62), defs, transparent=True),
        bg=svg("", grad("bg", [MENSTRUAL, "#C27AA8", LUTEAL]), bg="url(#bg)"),
        bgcolor="#C27AA8",
    )


CANDIDATES = {"a": candidate_a, "b": candidate_b, "c": candidate_c}


def render(svg_path, png_path, size=SIZE, transparent=False):
    if not os.path.exists(CHROME):
        print("Chrome not found; SVGs written, PNGs skipped")
        return False
    profile = tempfile.mkdtemp(prefix="chrome-logo-")
    args = [
        CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--no-first-run",
        f"--user-data-dir={profile}", "--force-device-scale-factor=1",
        f"--window-size={size},{size}", f"--screenshot={png_path}",
    ]
    if transparent:
        args.append("--default-background-color=00000000")
    args.append("file://" + os.path.abspath(svg_path))
    subprocess.run(args, check=True, capture_output=True, timeout=90)
    shutil.rmtree(profile, ignore_errors=True)
    return True


def main():
    svg_only = "--svg-only" in sys.argv
    os.makedirs(OUT, exist_ok=True)
    for key, fn in CANDIDATES.items():
        c = fn()
        for kind in ("icon", "fg", "bg"):
            p = os.path.join(OUT, f"icon-{key}-{kind}.svg")
            with open(p, "w") as f:
                f.write(c[kind])
            if not svg_only:
                render(p, p[:-4] + ".png", transparent=(kind == "fg"))
        print(f"candidate {key}: written (adaptive bg colour {c['bgcolor']})")
    print("output:", OUT)


if __name__ == "__main__":
    main()
