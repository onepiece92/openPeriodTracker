#!/usr/bin/env bash
# Adopt an icon candidate and the composed screenshots across the project.
#
#   design/apply.sh a      # a, b or c (see design/logo/out/)
#
# What it does:
#   1. copies the chosen icon, adaptive foreground/background into assets/icon/
#   2. points flutter_launcher_icons at them and regenerates every platform icon
#   3. copies the matching horizontal lockup and OG image for README and docs/
#   4. copies the eight composed store screenshots into docs/assets/screenshots/
# It does not upload anything to the stores.
set -euo pipefail
k="${1:-}"
case "$k" in a|b|c) ;; *) echo "usage: design/apply.sh a|b|c"; exit 1;; esac

root="$(cd "$(dirname "$0")/.." && pwd)"
out="$root/design/logo/out"
cd "$root"

for f in "icon-$k-icon.png" "icon-$k-fg.png" "icon-$k-bg.png" "logo-horizontal-$k.png" "og-$k.png"; do
  [ -f "$out/$f" ] || { echo "missing $out/$f (run design/logo/generate_logo.py and lockups.py)"; exit 1; }
done

# 1. icon sources
mkdir -p assets/icon
cp "$out/icon-$k-icon.png" assets/icon/logo.png
cp "$out/icon-$k-fg.png"   assets/icon/adaptive_foreground.png
cp "$out/icon-$k-bg.png"   assets/icon/adaptive_background.png

# 2. launcher icon config: use the image background so Android gets the gradient
python3 - <<'PY'
import re, pathlib
p = pathlib.Path("pubspec.yaml"); s = p.read_text()
s = re.sub(r'adaptive_icon_background: .*', 'adaptive_icon_background: "assets/icon/adaptive_background.png"', s)
s = re.sub(r'adaptive_icon_foreground: .*', 'adaptive_icon_foreground: "assets/icon/adaptive_foreground.png"', s)
p.write_text(s)
print("pubspec.yaml: adaptive icon paths updated")
PY
flutter pub get >/dev/null
dart run flutter_launcher_icons

# 3. lockup + OG
cp "$out/logo-horizontal-$k.png" design/logo/logo-horizontal.png
mkdir -p docs/assets
cp "$out/logo-horizontal-$k.png" docs/assets/logo-horizontal.png
cp "$out/og-$k.png" docs/assets/og.png
sips -Z 192 "$out/icon-$k-icon.png" --out docs/assets/favicon.png >/dev/null

# 4. screenshots for the landing page (half size; store uploads use design/screenshots/out/)
mkdir -p docs/assets/screenshots
i=0
for f in design/screenshots/out/iphone69/*.png; do
  i=$((i+1)); n=$(printf "%02d" "$i")
  sips -Z 1434 "$f" --out "docs/assets/screenshots/$n.png" >/dev/null
done

echo "applied candidate $k"
echo "store uploads: design/screenshots/out/iphone69/*.png (and ipad13/ if generated)"
