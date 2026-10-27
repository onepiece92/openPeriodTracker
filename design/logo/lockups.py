#!/usr/bin/env python3
"""Horizontal logo lockups and Open Graph images for each icon candidate.

  python3 design/logo/lockups.py          # all candidates
  python3 design/logo/lockups.py b        # one candidate

Outputs into design/logo/out/:
  logo-horizontal-<k>.png   1600x480, transparent  (README, docs)
  og-<k>.png                1200x630                (link previews)
"""
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out")
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

HEAD = """<!doctype html><html><head><meta charset="utf-8">
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600&family=Outfit:wght@400;500;600&display=block" rel="stylesheet">
<style>html,body{margin:0;overflow:hidden}body{font-family:Outfit,sans-serif;color:#2D2440}%s</style></head><body>%s</body></html>"""

LOCKUP_CSS = """
body{width:1600px;height:480px;display:flex;align-items:center;gap:56px;padding:0 64px;box-sizing:border-box;background:transparent}
img{width:340px;height:340px;border-radius:76px;display:block}
.name{font:600 150px/1 'Playfair Display',serif;letter-spacing:-.015em;margin:0 0 18px}
.sub{font:600 52px/1 Outfit,sans-serif;letter-spacing:.36em;color:#6B5F7D;padding-left:6px}
"""
LOCKUP_BODY = """<img src="file://%s"><div><div class="name">Open Period</div><div class="sub">TRACKER</div></div>"""

OG_CSS = """
body{width:1200px;height:630px;position:relative;background:linear-gradient(160deg,#FDF2F6,#EDE4F5 45%%,#E4EDF8 80%%,#EEF6F2)}
.blob{position:absolute;width:700px;height:700px;border-radius:50%%;background:%s;opacity:.16;filter:blur(110px);right:-18%%;top:-30%%}
.wrap{position:absolute;inset:0;display:flex;align-items:center;gap:64px;padding:0 96px}
img{width:300px;height:300px;border-radius:68px;box-shadow:0 30px 60px rgba(45,36,64,.18)}
h1{font:600 92px/1.02 'Playfair Display',serif;margin:0 0 22px;letter-spacing:-.012em}
p{font:400 38px/1.3 Outfit,sans-serif;margin:0;color:#6B5F7D}
.tags{margin-top:30px;display:flex;gap:14px}
.tags span{font:500 26px/1 Outfit,sans-serif;padding:14px 22px;border-radius:999px;background:rgba(255,255,255,.75);border:1px solid #F0E8F5}
"""
OG_BODY = """<div class="blob"></div><div class="wrap"><img src="file://%s"><div>
<h1>Open Period Tracker</h1><p>Period and cycle tracking that stays on your phone.</p>
<div class="tags"><span>Offline</span><span>Open source</span><span>No account</span><span>Free</span></div></div></div>"""

ACCENT = {"a": "#E07088", "b": "#A386BF", "c": "#E07088"}


def render(html, png, W, H, transparent):
    profile = tempfile.mkdtemp(prefix="chrome-lockup-")
    tmp = os.path.join(profile, "page.html")
    with open(tmp, "w") as f:
        f.write(html)
    args = [CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--no-first-run",
            f"--user-data-dir={profile}", "--force-device-scale-factor=1",
            "--allow-file-access-from-files", "--virtual-time-budget=10000",
            f"--window-size={W},{H}", f"--screenshot={png}"]
    if transparent:
        args.append("--default-background-color=00000000")
    subprocess.run(args + ["file://" + tmp], check=True, capture_output=True, timeout=120)
    shutil.rmtree(profile, ignore_errors=True)


def main():
    keys = [a for a in sys.argv[1:] if a in ACCENT] or list(ACCENT)
    for k in keys:
        icon = os.path.join(OUT, f"icon-{k}-icon.png")
        if not os.path.exists(icon):
            print(f"missing {icon}; run generate_logo.py first")
            continue
        render(HEAD % (LOCKUP_CSS, LOCKUP_BODY % icon), os.path.join(OUT, f"logo-horizontal-{k}.png"), 1600, 480, True)
        render(HEAD % (OG_CSS % ACCENT[k], OG_BODY % icon), os.path.join(OUT, f"og-{k}.png"), 1200, 630, False)
        print(f"candidate {k}: lockup + og written")


if __name__ == "__main__":
    main()
