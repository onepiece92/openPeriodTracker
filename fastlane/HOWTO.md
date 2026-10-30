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

Credentials come from the git-ignored `.key/` folder (`AuthKey.p8` plus
`KEY_ID` and `ISSUER_ID` in `apple.env`), or from `key_id:`, `issuer_id:` and
`key_path:` lane arguments.

```bash
brew install fastlane
cd <repo root>
fastlane ios metadata              # listing text, categories, copyright, age rating, screenshots
fastlane ios upload                # IPA from `flutter build ipa --release --export-method app-store`
fastlane ios builds                # processing state of recent builds
fastlane ios attach_build build:13 # attach a VALID build to the editable version
fastlane ios submit                # age rating + submit for review, release after approval
```

`metadata/age_rating.json` holds the age-rating questionnaire answers; both
`metadata` and `submit` apply it. Apple rejects builds silently when a
purpose string is missing (ITMS-90683): watch for the email, since
`altool --validate-app` does not catch it.

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
