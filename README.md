# Luna - Period Tracker & Cycle Health App

> Privacy-first menstrual cycle tracker with AI-powered health insights, built with Flutter.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey)]()

## What is Luna?

Luna is a **free, open-source period tracking app** that keeps all your data on your device. No accounts, no cloud, no tracking. It combines smart cycle predictions with AI-powered health analysis to help you understand your body better.

### Key Features

- **Period Tracking** - Mark period days, log flow intensity (light/medium/heavy), track cycle patterns
- **AI Cycle Predictions** - LSTM neural network predicts your next cycle length and period duration
- **Doctor's Checklist** - Track pain levels, discharge, skin, sleep, energy, libido, digestion, breast changes, hair growth, weight
- **Smart Diagnosis** - On-device health analysis with flagging for irregular cycles, hormonal patterns, nutrient deficiencies
- **Diet & Nutrition** - Phase-specific meal recommendations, vitamins, supplements, regional food suggestions based on your location
- **Fertile Window & Peak Days** - Ovulation tracking with peak fertility indicators for family planning
- **Analytics Dashboard** - Cycle length trends, mood/symptom frequency, phase correlations, period start day patterns
- **AI Prompt Builder** - Copy your cycle data as a prompt for ChatGPT, Gemini, or Claude for deeper health analysis
- **Mood Tracking** - 20 mood options with multi-select support
- **Symptom Logging** - 8 common symptoms tracked across cycle phases
- **Export/Import** - CSV backup and restore of all your data
- **Birthday Celebrations** - Confetti animation on your birthday with personalized wellness tips
- **100% Offline** - All data stored locally via SQLite. Zero network calls required.

## Screenshots

_Coming soon_

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart 3.x) |
| State Management | Provider |
| Local Database | sqflite (SQLite) |
| AI/ML | TFLite (LSTM model) + Ollama (optional LLM) |
| Routing | go_router |
| Location | Geolocator + Geocoding |
| Fonts | Google Fonts (Playfair Display + Outfit) |

## Architecture

Feature-first architecture for scalability:

```
lib/
├── main.dart
├── app.dart
├── core/           # Shared infrastructure
│   ├── theme/      # Colors, typography, decorations
│   ├── database/   # SQLite helper with migrations
│   ├── models/     # Settings, Period, DailyLog models
│   ├── providers/  # Settings, Period, DailyLog state
│   ├── router/     # go_router configuration
│   └── widgets/    # Shared UI components
├── features/       # Feature modules
│   ├── onboarding/ # Welcome + 3-step setup wizard
│   ├── home/       # Dashboard, phase timeline, birthday overlay
│   ├── calendar/   # Month view with period/fertile/peak markers
│   ├── logging/    # Bottom sheet (flow, mood, symptoms, doctor checklist)
│   ├── analytics/  # Charts, trends, raw data tables
│   ├── diagnosis/  # AI health summary, diet & nutrition
│   ├── insights/   # 7-day forecast, pattern map, symptom predictions
│   ├── profile/    # Personal info, settings, export/import
│   ├── history/    # Period history list
│   └── shell/      # Bottom navigation shell
└── services/       # AI services (Ollama, LSTM, AI provider)
```

## Getting Started

### Prerequisites

- Flutter SDK 3.x+
- Dart 3.x+
- Xcode (for iOS) or Android Studio (for Android)

### Installation

```bash
git clone https://github.com/YOUR_USERNAME/luna-period-tracker.git
cd luna-period-tracker
flutter pub get
flutter run
```

### Optional: AI Features

**LSTM Model** (on-device predictions):
```bash
pip install tensorflow numpy
python scripts/train_lstm_model.py
```

**Ollama** (enhanced AI summaries):
```bash
brew install ollama
brew services start ollama
ollama pull llama3.2
```

## Privacy

Luna is designed with privacy as the core principle:

- **Zero network calls** - The app works entirely offline
- **No analytics** - No tracking, no telemetry, no crash reporting
- **No accounts** - No login, no registration, no cloud sync
- **Local storage only** - All data stored in on-device SQLite database
- **Open source** - Full source code available for audit
- **Export control** - You own your data. Export anytime as CSV.

## Database Schema

### Tables
- `settings` - User preferences, cycle defaults, personal info
- `periods` - Period date ranges (start/end)
- `daily_logs` - Per-day flow, moods, symptoms, notes, medical checklist

### Migrations
- v1: Initial schema
- v2: Default flow & moods
- v3: User personal info (name, nickname, birthday)
- v4: Medical checklist (doctor's questions)

## Cycle Calculation

Luna uses mathematical cycle analysis without artificial constraints:

- **Predictions work bidirectionally** - Past and future dates are predicted from the nearest logged period
- **No hardcoded limits** - Cycle lengths and durations are unconstrained
- **Computed averages** - All calculations use actual logged data, falling back to user settings only when < 2 periods are logged
- **LSTM predictions** - Neural network trained on cycle patterns, with weighted moving average fallback

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Keywords

period tracker, menstrual cycle app, fertility tracker, ovulation calculator, women's health app, cycle prediction, period calendar, flow tracker, mood tracker, symptom logger, PCOS tracker, endometriosis tracker, reproductive health, fertility awareness, cycle analytics, period diary, menstruation app, hormone tracking, luteal phase, follicular phase, ovulation tracker, fertile window calculator, period reminder, cycle length calculator, menstrual health, women's wellness, pregnancy planning, birth control tracking, natural family planning, basal body temperature, cervical mucus tracking, period pain tracker, PMS tracker, PMDD tracker, menopause tracker, perimenopause, cycle syncing, seed cycling, moon cycle, red tent, feminine health, gynecology app, doctor checklist, medical symptom tracker, AI health analysis, machine learning health, LSTM prediction, on-device AI, privacy-first health app, offline period tracker, open source health app, Flutter health app, mobile health, mHealth, femtech, digital health

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Flutter](https://flutter.dev)
- AI powered by [TFLite](https://www.tensorflow.org/lite) and [Ollama](https://ollama.ai)
- Fonts by [Google Fonts](https://fonts.google.com)
