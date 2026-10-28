# Releasing 1.1.0 (the rename release)

Everything below is prepared in the repo. Two things need a store login:
uploading the binaries and saving the listing changes.

## 1. Build artifacts

```
flutter build ipa --release --export-method app-store   # build/ios/ipa/*.ipa
flutter build appbundle --release                       # build/app/outputs/bundle/release/app-release.aab
```

Version is `1.1.0+13` in pubspec.yaml: version name 1.1.0, iOS build 13,
Android versionCode 13. If Play rejects the bundle because an earlier upload
used a higher versionCode, raise the number after the `+` and rebuild.

## 2. iOS: App Store Connect

**Upload the build** (pick one):
- Open `build/ios/archive/Runner.xcarchive` in Xcode (double-click), then
  Organizer → Distribute App → App Store Connect → Upload.
- Or drag `build/ios/ipa/*.ipa` into the Transporter app.

**Listing** (App Store Connect → My Apps → Open Period & Cycle Tracker):

| Field | Value | Source file |
|---|---|---|
| Name | Open Period & Cycle Tracker | fastlane/metadata/en-US/name.txt |
| Subtitle | Private, Offline, Open Source | subtitle.txt |
| Keywords | ovulation,fertility,menstrual,calendar,pms,symptom,mood,flow,pcos,bbt,diet,free,ai,women,health | keywords.txt |
| Promotional text | No account. No ads. No subscription. Works offline. Source code on GitHub. | promotional_text.txt |
| Description | paste whole file | description.txt |
| What's New | paste whole file | release_notes.txt |
| Primary category | Health & Fitness | App Information |
| Secondary category | Medical | App Information |
| Age rating | re-answer the questionnaire; target 12+ (no unrestricted web access, infrequent medical info) | App Information |
| Support URL | https://github.com/onepiece92/openPeriodTracker/issues | support_url.txt |
| Marketing URL | https://onepiece92.github.io/openPeriodTracker/ | marketing_url.txt |
| Privacy policy | https://onepiece92.github.io/openPeriodTracker/privacy-policy.html (or keep the brandbuilder.com.np page once its Luna alias is removed) | privacy_url.txt |

**Screenshots** (Version → iPhone 6.9" and iPad 13"): drag in order from
`design/screenshots/out/iphone69/` and `design/screenshots/out/ipad13/`.
Delete the three old captures.

Then select the new build, keep "Data Not Collected", and submit for review.

## 3. Android: Play Console

**Upload** `build/app/outputs/bundle/release/app-release.aab` under
Production → Create new release. Release notes: paste
`fastlane/metadata/android/en-US/changelogs/10.txt`.

Signing note: `android/app/build.gradle.kts` signs release builds with the
debug keystore. Play accepts the bundle only if that is the upload key Play
already has on file for this app. If the upload is rejected for a signing
mismatch, point `signingConfigs.release` at the real upload keystore and
rebuild.

**Listing** (Main store listing): title unchanged; short description from
`fastlane/metadata/android/en-US/short_description.txt`; full description
from `full_description.txt`; replace the phone screenshots with the
`iphone69` set (Play accepts any 16:9 to 9:16 image); add
`docs/assets/og.png` as the feature graphic source if you want one
(resize to 1024x500).

## 4. One-command route (optional)

Install fastlane (`brew install fastlane`), then:

- iOS: create an App Store Connect API key (Users and Access → Integrations),
  save the `.p8` outside the repo, and run
  `fastlane ios metadata key_id:XXX issuer_id:YYY key_path:/path/AuthKey.p8`
  to push the listing text and screenshots. `fastlane ios upload` uploads the IPA.
- Android: create a service account with "Release manager" on the Play
  Console, save its JSON outside the repo, and run
  `fastlane android metadata json_key:/path/key.json` or
  `fastlane android upload json_key:/path/key.json`.

The lanes are in `fastlane/Fastfile`; they never read credentials from the repo.
