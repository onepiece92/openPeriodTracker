#!/usr/bin/env python3
"""Compose raw simulator captures into store screenshots.

Input : design/screenshots/raw/<name>.png  (from integration_test/screenshots_test.dart)
Output: design/screenshots/out/<size>/<nn>_<name>.png

  python3 design/screenshots/compose.py                 # iPhone 6.9" set (1320x2868)
  python3 design/screenshots/compose.py --ipad          # also iPad 13" set (2064x2752)
  python3 design/screenshots/compose.py --only 01_home  # one shot

Each image is an HTML page (app palette, Playfair Display + Outfit) rendered
with headless Chrome, so captions and layout are easy to tweak below.
"""
import base64
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "raw")
OUT = os.path.join(HERE, "out")
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Order matters: Apple shows the first three in search results.
# (raw name, headline, subline, accent colour)
SHOTS = [
    ("01_home", "Offline. Open source.\nNo account.", "Track your cycle without giving your data away.", "#E07088"),
    ("02_insights", "Know what's coming", "A seven-day forecast built from your own history.", "#A386BF"),
    ("09_log_sheet", "Log a day in seconds", "Flow, moods, symptoms and notes for any date.", "#5BA4B5"),
    ("03_doctor", "Bring data to your doctor", "A medical checklist you can export and share.", "#6AB88A"),
    ("04_analytics", "See your patterns", "Cycle trends, moods and symptoms over time.", "#A386BF"),
    ("05_diagnosis", "Health insights,\non your phone", "Score and summary are computed locally, never uploaded.", "#E07088"),
    ("06_diet", "Eat for your phase", "Food and supplement guidance for each cycle phase.", "#6AB88A"),
    ("08_profile", "Your data, your backup", "Export or import any time. Free, no ads.", "#5BA4B5"),
]

# Canvas presets: (width, height, phone width ratio, phone top, side pad, h1 px, p px, copy top)
SIZES = {
    "iphone69": (1320, 2868, 0.80, 700, 96, 92, 44, 170),
    "ipad13": (2064, 2752, 0.52, 760, 160, 110, 52, 190),
}

RAW_W, RAW_H = 1320, 2868  # iPhone 17 Pro Max capture size

TEMPLATE = """<!doctype html><html><head><meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Outfit:wght@400;500;600&display=block" rel="stylesheet">
<style>
html,body{{margin:0;width:{W}px;height:{H}px;overflow:hidden}}
body{{position:relative;background:linear-gradient(160deg,#FDF2F6 0%,#EDE4F5 42%,#E4EDF8 76%,#EEF6F2 100%);font-family:Outfit,sans-serif;color:#2D2440}}
.blob{{position:absolute;width:{BLOB}px;height:{BLOB}px;border-radius:50%;background:{ACCENT};opacity:.16;filter:blur(140px);right:-28%;top:-8%}}
.blob2{{position:absolute;width:{BLOB2}px;height:{BLOB2}px;border-radius:50%;background:{ACCENT};opacity:.10;filter:blur(160px);left:-30%;bottom:-10%}}
.copy{{position:absolute;left:{PAD}px;right:{PAD}px;top:{TOP}px}}
h1{{font:600 {H1}px/1.08 'Playfair Display',serif;margin:0 0 {GAP}px;letter-spacing:-.012em;white-space:pre-line}}
p{{font:400 {P}px/1.32 Outfit,sans-serif;margin:0;color:#6B5F7D;max-width:{PMAX}px}}
.phone{{position:absolute;left:50%;top:{PTOP}px;transform:translateX(-50%);width:{PW}px;height:{PH}px;border-radius:{R}px;background:#1F1830;padding:{BZ}px;box-sizing:border-box;box-shadow:0 70px 140px rgba(45,36,64,.30),0 20px 40px rgba(45,36,64,.12)}}
.screen{{position:relative;width:100%;height:100%;border-radius:{RI}px;overflow:hidden;background:#fff}}
.screen img{{display:block;width:100%;height:auto}}
.status{{position:absolute;top:0;left:0;right:0;height:{SB}px;display:flex;align-items:center;justify-content:space-between;padding:0 {SBP}px;font:600 {SBF}px Outfit,sans-serif;color:#2D2440}}
.status .r{{display:flex;gap:{SBG}px;align-items:center}}
.status svg{{height:{SBI}px;width:auto;display:block}}
</style></head><body>
<div class="blob"></div><div class="blob2"></div>
<div class="copy"><h1>{HEADLINE}</h1><p>{SUB}</p></div>
<div class="phone"><div class="screen">
<img src="data:image/png;base64,{IMG}">
<div class="status"><span>9:41</span><span class="r">
<svg viewBox="0 0 20 14" fill="#2D2440"><rect x="0" y="9" width="3.5" height="5" rx=".8"/><rect x="5.5" y="6.5" width="3.5" height="7.5" rx=".8"/><rect x="11" y="3.5" width="3.5" height="10.5" rx=".8"/><rect x="16.5" y="0" width="3.5" height="14" rx=".8"/></svg>
<svg viewBox="0 0 18 13" fill="#2D2440"><path d="M9 2.6c2.7 0 5.1 1 7 2.7l1.6-1.6A12.3 12.3 0 0 0 9 0 12.3 12.3 0 0 0 .4 3.7L2 5.3C3.9 3.6 6.3 2.6 9 2.6Zm0 4c1.6 0 3.1.6 4.3 1.6l1.6-1.6A8.5 8.5 0 0 0 9 4.6a8.5 8.5 0 0 0-5.9 2l1.6 1.6C5.9 7.2 7.4 6.6 9 6.6Zm0 4c.6 0 1.1.2 1.5.6L9 13l-1.5-1.8c.4-.4.9-.6 1.5-.6Z"/></svg>
<svg viewBox="0 0 30 14" fill="none"><rect x=".8" y=".8" width="25" height="12.4" rx="3.2" stroke="#2D2440" stroke-opacity=".5" stroke-width="1.4"/><rect x="2.6" y="2.6" width="21.4" height="8.8" rx="1.8" fill="#2D2440"/><path d="M27.5 4.5v5a2.6 2.6 0 0 0 0-5Z" fill="#2D2440" fill-opacity=".5"/></svg>
</span></div>
</div></div>
</body></html>
"""


def page(size_key, headline, sub, accent, img):
    W, H, pw_ratio, ptop, pad, h1, p, top = SIZES[size_key]
    PW = int(W * pw_ratio)
    BZ = max(10, int(PW * 0.016))
    PH = int((PW - 2 * BZ) * RAW_H / RAW_W) + 2 * BZ
    R = int(PW * 0.15)
    scale = (PW - 2 * BZ) / RAW_W
    return TEMPLATE.format(
        W=W, H=H, BLOB=int(W * 0.95), BLOB2=int(W * 0.8), ACCENT=accent,
        PAD=pad, TOP=top, H1=h1, GAP=int(h1 * 0.32), P=p, PMAX=int(W - 2 * pad),
        PTOP=ptop, PW=PW, PH=PH, R=R, RI=R - BZ, BZ=BZ,
        SB=int(186 * scale), SBP=int(100 * scale), SBF=int(50 * scale),
        SBI=int(38 * scale), SBG=int(22 * scale),
        HEADLINE=headline, SUB=sub, IMG=img,
    )


def render(html, png, W, H):
    profile = tempfile.mkdtemp(prefix="chrome-shot-")
    tmp = os.path.join(profile, "page.html")
    with open(tmp, "w") as f:
        f.write(html)
    subprocess.run([
        CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--no-first-run",
        f"--user-data-dir={profile}", "--force-device-scale-factor=1",
        "--allow-file-access-from-files", "--virtual-time-budget=10000",
        f"--window-size={W},{H}", f"--screenshot={png}", "file://" + tmp,
    ], check=True, capture_output=True, timeout=120)
    shutil.rmtree(profile, ignore_errors=True)


def main():
    sizes = ["iphone69"] + (["ipad13"] if "--ipad" in sys.argv else [])
    only = sys.argv[sys.argv.index("--only") + 1] if "--only" in sys.argv else None
    for size_key in sizes:
        out_dir = os.path.join(OUT, size_key)
        os.makedirs(out_dir, exist_ok=True)
        for i, (name, headline, sub, accent) in enumerate(SHOTS, 1):
            if only and name != only:
                continue
            raw = os.path.join(RAW, f"{name}.png")
            if not os.path.exists(raw):
                print(f"skip {name}: no raw capture")
                continue
            W, H = SIZES[size_key][:2]
            png = os.path.join(out_dir, f"{i:02d}_{name}.png")
            with open(raw, "rb") as fh:
                b64 = base64.b64encode(fh.read()).decode("ascii")
            render(page(size_key, headline, sub, accent, b64), png, W, H)
            print("wrote", os.path.relpath(png, HERE))


if __name__ == "__main__":
    main()
