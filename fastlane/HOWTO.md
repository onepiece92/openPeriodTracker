# Store metadata

This folder holds the text for both store listings in the layout that
[fastlane](https://docs.fastlane.tools) expects, so a listing update is a
single command instead of a copy-paste session in two web consoles.

```
fastlane/metadata/en-US/            App Store (deliver)
fastlane/metadata/android/en-US/    Google Play (supply) and F-Droid
docs/assets/screenshots/            screenshots used by both stores and the website
```

## Upload to the App Store

```bash
gem install fastlane
cd <repo root>
fastlane deliver --app_identifier com.brandbuilder.periodtracker \
  --metadata_path fastlane/metadata \
  --skip_binary_upload --skip_screenshots
```

Add `--skip_metadata false --screenshots_path <folder>` once the screenshots
are arranged per device size (deliver wants
`fastlane/screenshots/en-US/` with device-size names in the file names).

Fields that `deliver` cannot change and that must be set by hand in
App Store Connect: primary category (Health & Fitness), secondary category
(Medical), and the age-rating questionnaire (target 12+).

## Upload to Google Play

```bash
fastlane supply --package_name com.brandbuilder.periodtracker \
  --metadata_path fastlane/metadata/android \
  --skip_upload_apk --skip_upload_aab --skip_upload_images --skip_upload_screenshots
```

`supply` needs a service-account JSON from the Play Console; pass it with
`--json_key`.

## Character limits

| File | Limit |
|---|---|
| en-US/name.txt | 30 |
| en-US/subtitle.txt | 30 |
| en-US/keywords.txt | 100 bytes |
| en-US/promotional_text.txt | 170 |
| en-US/description.txt | 4000 |
| android/en-US/title.txt | 30 |
| android/en-US/short_description.txt | 80 |
| android/en-US/full_description.txt | 4000 |
