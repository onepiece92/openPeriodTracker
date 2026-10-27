# Changelog

All notable changes to Open Period Tracker will be documented in this file.

## [Unreleased]

### Changed
- App renamed. The product is now **Open Period Tracker**; the installed app shows as **Open Period**; the store title stays *Open Period & Cycle Tracker*. The earlier name (Luna) is retired and must not be reintroduced.
- Display name updated in the iOS Info.plist and Xcode project, the Android manifest, the macOS app config, and the web title and manifest.
- README rewritten to describe the app accurately (provider for state management, JSON backup, no database encryption, the three optional network uses), with store links and a short FAQ.
- CONTRIBUTING, SECURITY and issue templates updated to the new name.

### Added
- `fastlane/metadata/` with App Store and Google Play listing text: subtitle, keywords, promotional text, description, release notes, URLs.
- `docs/` GitHub Pages landing page with FAQ, SoftwareApplication and FAQPage structured data, and a copy of the privacy policy.
- `.github/repository-settings.md` with the repository description, 20 topics, a `gh repo edit` command and the GitHub Pages steps.
- `store/submissions.md` with ready-to-paste texts for AlternativeTo, Product Hunt, an F-Droid packaging request, a Reddit maker post, and an App Store Connect field checklist.

## [1.0.0] - 2026-03-27

### Added
- Period tracking with calendar view (mark/unmark days, edit mode)
- Flow logging (light/medium/heavy) with visual dots on calendar
- Multi-select mood tracking (20 moods)
- Symptom tracking (8 symptoms)
- Doctor's medical checklist (pain, discharge, skin, hair, sleep, libido, digestion, breast, energy, weight)
- LSTM AI model for cycle length and period duration prediction
- On-device AI health summary (rule-based, no network required)
- Ollama LLM integration for enhanced AI diagnosis (optional)
- Diet & Nutrition tab with phase-specific recommendations
- Regional food suggestions based on GPS location (South Asian, East Asian, Western, Middle Eastern, African, Latin American, Southeast Asian, European)
- Nutrient deficiency analysis from logged symptoms
- Macro balance and hydration guides per cycle phase
- Supplement recommendations per phase
- AI prompt builder (copy to ChatGPT/Gemini/Claude) for diagnosis and diet
- Analytics dashboard with cycle trends, mood/symptom frequency, phase correlations
- Medical checklist data integrated into all analytics and AI prompts
- 7-day phase forecast in Insights
- Best & worst cycle days analysis
- Symptom forecast based on historical patterns
- Fertile window and peak day indicators on calendar
- Cycle comparison (current vs average)
- Weekly logging score
- Personalized phase-based tips from actual user data
- Phase timeline strip on home screen
- Birthday celebration overlay with confetti animation
- Personal info (name, nickname, birthday) with age-aware analytics
- Default flow and mood settings (auto-applied when marking period days)
- Editable cycle and period length in profile
- Period history page
- CSV export and import for data backup
- Demo data generator for testing (1 year of realistic data)
- 3-step onboarding with skip option
- Log Today floating action button
- Pastel theme with Playfair Display + Outfit fonts
- Feature-first architecture for scalability
- SQLite database with 4 migration versions
- 100% offline, privacy-first design
