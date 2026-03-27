# Contributing to Luna

Thank you for your interest in contributing to Luna! This guide will help you get started.

## How to Contribute

### Reporting Bugs
- Open an issue with the "bug" label
- Include steps to reproduce, expected vs actual behavior
- Mention your Flutter version and device/OS

### Suggesting Features
- Open an issue with the "enhancement" label
- Describe the use case and why it would help users
- Include mockups or examples if possible

### Code Contributions

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Run `flutter analyze` to ensure no issues
5. Run `flutter test` to ensure tests pass
6. Commit with a descriptive message
7. Push and open a Pull Request

### Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use feature-first architecture (add new features in `lib/features/`)
- Keep shared code in `lib/core/`
- Use Provider for state management
- All data must stay on-device (no network calls for core features)

### Areas Where Help is Needed

- Unit and widget tests
- Accessibility improvements (screen reader support, contrast)
- Localization (multi-language support)
- Additional regional food data for the diet tab
- iOS/Android platform-specific optimizations
- UI polish and animations

## Development Setup

```bash
flutter pub get
flutter analyze
flutter run
```

### Training the LSTM model (optional)
```bash
pip install tensorflow numpy
python scripts/train_lstm_model.py
```

## Privacy Commitment

Luna is a privacy-first app. All contributions must maintain this principle:
- No analytics or tracking code
- No network calls for core functionality
- No third-party data collection
- All data stored locally only
