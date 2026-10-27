# Ready-to-paste submissions

Copy these as they are. Edit only the bracketed parts.

---

## A. AlternativeTo

Submit at https://alternativeto.net/manage-item/ as an alternative to **Flo**, **Clue** and **drip**.

**Name:** Open Period Tracker

**Tagline (max 100):** Free, open-source period tracker. Offline, no account, no ads.

**Description:**

Open Period Tracker is a free, open-source period and cycle tracker for iOS and Android. It works entirely offline, needs no account, shows no ads, and keeps your data in a local database on your device.

It logs periods, flow, moods, symptoms, notes and a doctor's checklist; predicts your next period, fertile window and peak day with an on-device model; and turns your history into insights, analytics, phase-aware diet guidance and cycle-matched yoga. Backup and restore is a JSON file you control. The code is on GitHub under the MIT license.

**Platforms:** iPhone, Android
**License:** Free, Open Source (MIT)
**Tags:** period-tracker, menstrual-cycle, privacy, offline, open-source
**Links:** https://onepiece92.github.io/openPeriodTracker/ · https://github.com/onepiece92/openPeriodTracker · App Store · Google Play

---

## B. Product Hunt

**Tagline (≤60):** Open-source period tracker. Offline, no account, no ads.

**Description:**

Most period trackers want an account, a subscription, or your data. Open Period Tracker wants none of those.

It is a free, open-source app for iOS and Android that runs entirely on your phone. Log periods, flow, moods, symptoms and a doctor's checklist. Get predictions for your next period and fertile window from an on-device model trained on your own history. See insights and analytics, phase-aware diet suggestions and cycle-matched yoga. Back up to a JSON file whenever you like.

No server. No analytics SDK. No ads. MIT licensed, so you can read every line.

**First comment (maker):**

Hi, maker here. I built this because I could not find a period tracker I would recommend to someone who cares about where their health data goes. Everything is on the device, the code is public, and the only network calls are ones you opt into (YouTube links for yoga videos, the OS geocoder for regional food picks if you grant location, or your own Ollama server). Happy to answer anything about the prediction model or the privacy choices.

**Topics:** Health & Fitness, Open Source, Privacy, iOS, Android

---

## C. F-Droid: Request for Packaging

Open an issue at https://gitlab.com/fdroid/rfp/-/issues/new with this body.

**Title:** Open Period Tracker (com.brandbuilder.periodtracker)

```
### Link to the source code
https://github.com/onepiece92/openPeriodTracker

### License
MIT

### Category
Sports & Health

### Summary
Free, open-source period and cycle tracker. Offline, no account, no ads.

### Description
Period, flow, mood and symptom logging with on-device cycle prediction,
insights, analytics, phase-aware diet guidance and cycle-matched yoga.
No server, no account, no analytics or advertising SDK. JSON backup.

### Notes for packagers
- Flutter app (Dart 3). Build with `flutter build apk --release`.
- Fastlane metadata is already in the repository under
  fastlane/metadata/android/en-US/ (title, short and full description,
  changelogs).
- The app depends on `tflite_flutter`, which ships a prebuilt TensorFlow
  Lite native library. F-Droid may need this built from source or the
  dependency excluded; the app falls back to a rule-based predictor when
  the model cannot be loaded. I am happy to add a build flavor that
  removes tflite_flutter if that is required.
- Other dependencies: sqflite, provider, go_router, google_fonts (fonts
  can be bundled instead of fetched), geolocator/geocoding (optional,
  permission-gated), flutter_local_notifications, share_plus, file_picker,
  url_launcher, http (used only for an optional user-configured Ollama
  server).
- Permissions: INTERNET (optional features only), location (optional),
  POST_NOTIFICATIONS, SCHEDULE_EXACT_ALARM, RECEIVE_BOOT_COMPLETED
  (reminders).
- Already published on Google Play under the same application id.

### Already available on
Google Play: https://play.google.com/store/apps/details?id=com.brandbuilder.periodtracker
App Store: https://apps.apple.com/us/app/open-period-cycle-tracker/id6761253443
```

Before filing, confirm the Google Fonts fetch and the TFLite binary are acceptable or patched, and tag a release (`v1.0.4`) so the packager has a fixed commit.

---

## D. Reddit maker post

Post to r/fossdroid (Android focus) or r/privacy (read the rules first; r/privacy allows self-promotion only in the weekly thread in some periods).

**Title:** I made an open-source period tracker that works offline with no account. Looking for feedback.

**Body:**

I have spent the last few months building a period tracker after failing to find one I would hand to a friend who cares about where their health data ends up. It is now on Google Play and the App Store, and the code is on GitHub under MIT.

What it does: period and flow logging on a calendar, moods and symptoms, a doctor's checklist you can take to an appointment, next-period and fertile-window prediction from a small on-device model, insights and analytics, phase-aware diet suggestions, and yoga matched to each phase. Backup is a JSON file.

What it does not do: no account, no server, no analytics or ad SDKs, no subscription. The database is local SQLite. The only network calls are optional and obvious: YouTube links in the yoga tab, the OS geocoder for regional food picks if you grant location, and an Ollama server you can point it at yourself.

Things I know are missing: F-Droid (RFP filed), translations, and an encrypted database option. I would rather hear what else is wrong than what is right.

Source: https://github.com/onepiece92/openPeriodTracker
Play: https://play.google.com/store/apps/details?id=com.brandbuilder.periodtracker
App Store: https://apps.apple.com/us/app/open-period-cycle-tracker/id6761253443

---

## E. App Store Connect checklist

Open https://appstoreconnect.apple.com → My Apps → Open Period & Cycle Tracker → the current version.

| Field | Set to | Where |
|---|---|---|
| Name | `Open Period & Cycle Tracker` (unchanged) | App Information |
| Subtitle | `Private, Offline, Open Source` | App Information |
| Primary category | Health & Fitness | App Information |
| Secondary category | Medical | App Information |
| Age rating | Re-answer the questionnaire. Medical/Treatment Information: Infrequent/Mild. No unrestricted web access (YouTube opens in the external browser). Target 12+ | App Information → Age Rating |
| Keywords | `ovulation,fertility,menstrual,calendar,pms,symptom,mood,flow,pcos,bbt,diet,free,ai,women,health` | Version → App Store tab |
| Promotional text | `No account. No ads. No subscription. Works offline. Source code on GitHub.` | Version → App Store tab |
| Description | contents of `fastlane/metadata/en-US/description.txt` | Version → App Store tab |
| What's New | contents of `fastlane/metadata/en-US/release_notes.txt` | Version → App Store tab |
| Support URL | `https://github.com/onepiece92/openPeriodTracker/issues` | Version → App Store tab |
| Marketing URL | `https://onepiece92.github.io/openPeriodTracker/` | Version → App Store tab |
| Privacy Policy URL | `https://brandbuilder.com.np/privacy-policy-for-open-period-cycle-tracker/` (unchanged) | App Privacy |
| Screenshots | 8 × 6.9" (1320×2868) from `docs/assets/screenshots/`; iPad set optional | Version → App Store tab |
| App icon | ships with the next build (assets/icon) | Build |
| Copyright | `2026 Brand Builder` | Version → App Store tab |

Google Play Console equivalents: Store presence → Main store listing (title unchanged, short description `Open-source, offline period & ovulation tracker. No account, no ads, free`, full description from `fastlane/metadata/android/en-US/full_description.txt`, new screenshots and icon), and Store settings → App category: Health & Fitness.

After publishing: add an in-app review prompt (parent track), then post the Reddit and Product Hunt pieces a week apart so each gets its own attention.
