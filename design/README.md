# Design assets and how to regenerate them

Everything here is generated from scripts, so the icon and the store
screenshots can be rebuilt after any UI change.

## Logo and app icon

```
python3 design/logo/generate_logo.py   # SVG + PNG for candidates a, b, c
python3 design/logo/lockups.py         # horizontal lockups + Open Graph images
```

Output lands in `design/logo/out/`:

| File | Use |
|---|---|
| `icon-<k>-icon.png` | 1024x1024 app icon, full bleed (iOS, legacy Android, web) |
| `icon-<k>-fg.png` | Android adaptive foreground, transparent, mark inside the 66% safe zone |
| `icon-<k>-bg.png` | Android adaptive background |
| `logo-horizontal-<k>.png` | README and landing page lockup |
| `og-<k>.png` | 1200x630 link preview |

The mark is an open cycle ring. The four arcs are the phase colours from
`lib/core/theme/app_theme.dart`, sized to a 28-day cycle (5 / 8 / 3 / 12
days), with the opening at the top and a drop in the centre.

To adopt a candidate: copy its `icon.png` to `assets/icon/logo.png`, its `fg`
and `bg` files next to it, point the `flutter_launcher_icons` block in
`pubspec.yaml` at them, then run `dart run flutter_launcher_icons`.

## Store screenshots

1. Boot a 6.9-inch simulator (iPhone 17 Pro Max) and prepare it:

   ```
   xcrun simctl privacy <udid> grant location com.brandbuilder.periodtracker
   xcrun simctl location <udid> set 27.7172,85.3240
   ```

2. Capture raw screens. The integration test seeds a year of demo data,
   sets a profile name and visits every screen:

   ```
   flutter drive --driver=test_driver/integration_test.dart \
     --target=integration_test/screenshots_test.dart -d <udid> \
     --dart-define=SHOT_DIR=$PWD/design/screenshots/raw
   ```

   Raw 1320x2868 captures are rendered from the Flutter layer tree (the
   native iOS window snapshot returns blank frames) and written straight
   into `design/screenshots/raw/`. On a physical device omit `SHOT_DIR`;
   they land in the app's Documents/screenshots folder instead.

3. Compose captioned store images:

   ```
   python3 design/screenshots/compose.py          # iPhone 6.9" set
   python3 design/screenshots/compose.py --ipad   # add the iPad 13" set
   ```

   Captions, order and accent colours are the `SHOTS` list at the top of
   `compose.py`. Output lands in `design/screenshots/out/<size>/`.

Rendering uses headless Google Chrome, so no Python imaging libraries are
needed. Fonts load from Google Fonts at render time.
