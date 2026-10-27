# GitHub Repository Settings

These are applied on GitHub, not in the code. Run the command or follow the manual steps after each change here.

## Naming

The product is **Open Period Tracker** (store title: *Open Period & Cycle Tracker*, installed name: *Open Period*).
The earlier name **Luna is retired**. Do not reintroduce it in copy, metadata, screenshots or code comments. There are at least nine other period trackers called Luna on the App Store, so the name cannot be owned and splits our search presence.

## Description

Free, open-source period and cycle tracker for iOS and Android. Works offline, no account, data stays on your device.

## Website

https://onepiece92.github.io/openPeriodTracker/

## Topics (20, GitHub's maximum)

```
period-tracker
menstrual-cycle
fertility-tracker
ovulation-calculator
womens-health
flutter
health-app
cycle-prediction
privacy-first
offline-first
open-source
femtech
reproductive-health
period-calendar
mood-tracker
symptom-tracker
pcos
endometriosis
fertility-awareness
natural-family-planning
```

## Apply with the GitHub CLI

```bash
gh repo edit onepiece92/openPeriodTracker \
  --description "Free, open-source period and cycle tracker for iOS and Android. Works offline, no account, data stays on your device." \
  --homepage "https://onepiece92.github.io/openPeriodTracker/" \
  --add-topic period-tracker --add-topic menstrual-cycle --add-topic fertility-tracker \
  --add-topic ovulation-calculator --add-topic womens-health --add-topic flutter \
  --add-topic health-app --add-topic cycle-prediction --add-topic privacy-first \
  --add-topic offline-first --add-topic open-source --add-topic femtech \
  --add-topic reproductive-health --add-topic period-calendar --add-topic mood-tracker \
  --add-topic symptom-tracker --add-topic pcos --add-topic endometriosis \
  --add-topic fertility-awareness --add-topic natural-family-planning
```

Install the CLI with `brew install gh` and run `gh auth login` first.

## Enable GitHub Pages (manual)

1. Repository → **Settings** → **Pages**.
2. Source: **Deploy from a branch**.
3. Branch: **main**, folder: **/docs**. Save.
4. Wait a minute, then open https://onepiece92.github.io/openPeriodTracker/ and check the logo, screenshots and privacy policy load.
5. Back in **Settings** → **General**, tick **Use your GitHub Pages website** under the description so the link shows in the sidebar.

## Social preview image

Settings → General → Social preview. Upload `docs/assets/og.png` (1280×640).

## Releases

Create a release for each store version (tag `v1.0.4` and so on). Put the store links and the release notes from `fastlane/metadata/en-US/release_notes.txt` in the body. Releases are what directories and AI assistants cite when they decide whether a project is maintained.
