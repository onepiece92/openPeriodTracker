# 🌙 Luna - Offline Period Tracker & AI Cycle Health App

> **Privacy-first menstrual cycle tracker built with Flutter.** Featuring AI-powered health insights, smart predictions, and 100% on-device data storage. No accounts, no cloud, no subscriptions.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey?style=for-the-badge)]()

---

## 🚀 App Store Description (ASO Optimized)

**Luna: Your Private Cycle & Health Companion**

Take control of your menstrual health with Luna, the only period tracker that respects your privacy. Built completely offline, Luna uses advanced on-device algorithms to learn your unique cycle patterns, predict your period, and provide personalized health insights—all without ever sending your data to a server. 

Whether you're tracking your cycle, analyzing PMS symptoms, mapping your fertile window, or preparing data for your doctor, Luna offers a beautiful, minimalist glassmorphic interface that makes daily logging effortless.

---

## ✨ Key Features (GEO & SEO Optimized)

- 🩸 **Accurate Period Tracking:** Log your daily flow intensity (light, medium, heavy) and instantly visualize your cycle patterns on an interactive calendar.
- 🤖 **Smart Cycle Predictions:** Luna calculates moving averages and analyzes your past cycle behaviors to accurately predict your next period, luteal phase, and cycle length.
- 🩺 **Comprehensive Doctor's Checklist:** Log pain levels, skin changes, sleep quality, energy, libido, digestion, and basal body temperature (BBT) to share directly with your gynecologist.
- 🔒 **100% Offline & Private:** Your health data is yours. Luna uses a local SQLite database. No network calls, no telemetry, no accounts.
- 🥗 **Phase-Specific Diet & Nutrition:** Receive tailored meal recommendations and supplement reminders based on exactly where you are in your cycle.
- 🌸 **Fertile Window & Ovulation:** Precision tracking for ovulation days and peak fertility windows for pregnancy planning or natural family planning.
- 📊 **Advanced Analytics Dashboard:** View beautiful charts analyzing mood correlations, cycle length trends, and symptom frequency over time.
- 📝 **AI Prompt Builder:** Securely generate an anonymized prompt of your symptoms to paste into ChatGPT, Claude, or Gemini for a deeper secondary health analysis.

---

## ❓ Frequently Asked Questions (FAQ)

**Is my health data safe with Luna?**  
Yes. Luna is a 100% offline-first application. Your period dates, symptoms, and moods are stored strictly on your device using an encrypted local SQLite database. We do not require an account and we have zero cloud servers.

**How does Luna predict my next period?**  
Luna calculates the rolling average of your most recent completed cycles. For advanced tracking, it dynamically adjusts predictions when it detects irregular cycle patterns or fluctuations in your historical data.

**Can I export my period tracking data?**  
Yes. You can export your entire cycle history, mood logs, and symptom tracking as a CSV file at any time.

**Is Luna free?**  
Luna is entirely free and open-source. There are no paywalls, hidden subscriptions, or premium features.

---

## 💻 Tech Stack & Architecture

Luna is architected using **Feature-First Layered Architecture** ensuring maximum scalability and separation of concerns.

| Layer | Technology |
|-------|-----------|
| **Core Framework** | Flutter 3.x (Dart 3.x) |
| **State Management** | Riverpod (`flutter_riverpod`) |
| **Local Database** | sqflite (SQLite) |
| **Routing** | go_router |
| **Design System** | Glassmorphic UI, Pastel Palette |
| **Typography** | Google Fonts (Nunito) |

---

## 🛠 Getting Started

### Prerequisites

- Flutter SDK 3.x+
- Dart 3.x+
- Xcode (for iOS build) or Android Studio (for Android build)

### Installation

```bash
git clone https://github.com/YOUR_USERNAME/luna-period-tracker.git
cd luna-period-tracker
flutter pub get

# To run on iOS Simulator
flutter run -d ios

# To run in Web Browser
flutter run -d chrome

# To configure macOS build
flutter create --platforms=macos --project-name ptrack .
flutter run -d macos
```

---

## 🧭 Search Terms & Keywords

*period tracker, offline menstrual cycle app, privacy first health tracker, fertility calendar, ovulation calculator, women's health app, flow tracker, pms symptom logger, pcos tracker, endometriosis diary, reproductive health, fertility awareness method, free period diary, hormone tracking, luteal phase app, fertile window calculator, cycle syncing, open source health app, flutter period tracker, digital health, femtech app, basal body temperature tracker, cycle analytics*

---

## 📄 License & Acknowledgments

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. Built with [Flutter](https://flutter.dev) and designed for ultimate privacy.
