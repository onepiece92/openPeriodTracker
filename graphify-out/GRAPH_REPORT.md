# Graph Report - pTrack  (2026-10-28)

## Corpus Check
- 107 files · ~280,785 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1287 nodes · 1906 edges · 77 communities (67 shown, 10 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 168 edges (avg confidence: 0.88)
- Token cost: 230,341 input · 0 output

## Community Hubs (Navigation)
- AI Diagnosis Screen
- Windows Runner & Plugins
- Diet Data & Log Widgets
- Data Providers & Models
- Store Listing Metadata
- Insights View
- macOS App Delegate
- Profile & Backup Screen
- Home Screen & Overlay
- Doctor Checklist Widget
- Settings Provider
- App Providers & State
- Analytics Screen
- Onboarding Flow
- Doctor View Analysis
- Repo Docs & Templates
- Linux Runner & Plugins
- Diagnosis Cards
- Yoga Screen
- Privacy Policy Content
- App Spec & Architecture
- Calendar View
- Diet Tab & Phases
- Logo Generator Script
- Screenshot Integration Test
- Settings Model
- Ollama Service
- Linux CMake Build
- Four-Phase Cycle Model
- Router Feature Imports
- Period Length Step
- Database Helper
- Core Screen Widgets
- Birthday Overlay
- Changelog 1.0.0 Features
- App Root & Router
- Screenshot Pipeline Docs
- Design Asset Pipeline
- Backup Service
- Windows Runner Main
- Cycle Ring Painter
- Review Service
- Web Manifest
- GitHub Repo Settings
- LSTM Service
- App Entry & Notifications
- History View
- Demo Data Service
- Notification Service
- App Theme
- Shell Navigation
- Privacy Compliance Page
- Flow Selector
- LSTM Training Script
- Integration Test Driver
- Share Service
- Mood Selector
- Phase Card
- Symptom Chips
- Stat Card
- Daily Log Model
- Screenshot Composer
- Period Model
- Android MainActivity
- Logo Lockups Script
- Widget Test
- God Nodes Hook Script
- Icon Apply Script
- AI Prompt Card
- Ollama Diagnosis Card
- Ollama Enhanced Section
- Nullable Bool Type
- Nullable String Type

## God Nodes (most connected - your core abstractions)
1. `PeriodProvider` - 36 edges
2. `SettingsProvider` - 34 edges
3. `Win32Window` - 24 edges
4. `Open Period Tracker (app)` - 22 edges
5. `open_period_tracker Flutter package (version 1.1.0+13, SDK ^3.11.3)` - 22 edges
6. `Release 1.1.0 (2026-10-27) - the rename release` - 19 edges
7. `Privacy Policy (Open Period & Cycle Tracker, 2026-03-27)` - 17 edges
8. `Cycle Yoga mobile app spec (React)` - 15 edges
9. `App Store description (TRACK / PREDICT / UNDERSTAND / PRIVATE BY DESIGN / OPEN SOURCE)` - 15 edges
10. `Google Play full description` - 15 edges

## Surprising Connections (you probably didn't know these)
- `Zero-trust, privacy-first architecture` --semantically_similar_to--> `Privacy-first, offline, local-only architecture`  [INFERRED] [semantically similar]
  SECURITY.md → README.md
- `CSV export and import (1.0.0)` --semantically_similar_to--> `JSON backup and restore`  [INFERRED] [semantically similar]
  CHANGELOG.md → README.md
- `Location data (on-device region detection for diet)` --semantically_similar_to--> `Regional food suggestions by GPS (8 regions)`  [INFERRED] [semantically similar]
  PRIVACY_POLICY.md → CHANGELOG.md
- `Features section (Track, Predict, Understand, Eat and move, Ask an AI, Keep control)` --semantically_similar_to--> `Open Period Tracker (app)`  [INFERRED] [semantically similar]
  docs/index.html → README.md
- `Privacy commitment for contributions` --semantically_similar_to--> `Privacy-first, offline, local-only architecture`  [INFERRED] [semantically similar]
  CONTRIBUTING.md → README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Privacy-first / offline-only principle stated across project documents** — readme_privacy_first_architecture, contributing_privacy_commitment, security_zero_trust_privacy_first, open_period_tracker_spec_core_principles, privacy_policy_local_sqlite_storage, docs_index_why_section [INFERRED 0.95]
- **The only opt-in network touchpoints and the packages behind them** — readme_optional_network_uses, security_ollama_llm, security_geolocator, privacy_policy_ollama_integration, privacy_policy_location_data, yoga_youtube_search_url_pattern, pubspec_http, pubspec_url_launcher, pubspec_geolocator, pubspec_geocoding [INFERRED 0.85]
- **Four-phase menstrual cycle model shared by the app spec, the yoga content and the logo mark** — open_period_tracker_spec_cyclephase_enum, open_period_tracker_spec_phase_determination, open_period_tracker_spec_cycle_progress_ring, yoga_menstrual_phase, yoga_follicular_phase, yoga_ovulatory_phase, yoga_luteal_phase, yoga_day_selector, design_readme_open_cycle_ring_mark [INFERRED 0.85]
- **App Store listing text uploaded by fastlane deliver** — fastlane_howto_deliver, fastlane_metadata_en_us_name_open_period_cycle_tracker, fastlane_metadata_en_us_subtitle_private_offline_open_source, fastlane_metadata_en_us_keywords_app_store_keywords, fastlane_metadata_en_us_promotional_text_no_account_no_ads, fastlane_metadata_en_us_description_app_store_description, fastlane_metadata_en_us_release_notes_app_store_release_notes, fastlane_metadata_en_us_marketing_url_github_pages_site, fastlane_metadata_en_us_privacy_url_brandbuilder_privacy_policy, fastlane_metadata_en_us_support_url_github_issues, fastlane_metadata_copyright_2026_brand_builder [EXTRACTED 1.00]
- **Google Play / F-Droid listing text uploaded by fastlane supply** — fastlane_howto_supply, fastlane_metadata_android_en_us_title_open_period_cycle_tracker, fastlane_metadata_android_en_us_short_description_play_short_description, fastlane_metadata_android_en_us_full_description_play_full_description, fastlane_metadata_android_en_us_changelogs_13_play_changelog_13, fastlane_metadata_android_en_us_changelogs_5_play_changelog_5 [EXTRACTED 1.00]
- **Flutter desktop CMake pipeline: flutter_assemble -> runner executable -> install step (Linux and Windows)** — linux_flutter_cmakelists_flutter_assemble, linux_runner_cmakelists_runner_executable, linux_cmakelists_install_bundle, windows_flutter_cmakelists_flutter_assemble, windows_runner_cmakelists_runner_executable, windows_cmakelists_install_in_place [INFERRED 0.85]

## Communities (77 total, 10 thin omitted)

### Community 0 - "AI Diagnosis Screen"
Cohesion: 0.02
Nodes (105): AiStatus, CyclePrediction?, diet_tab.dart, _activeTab, _ageAdvice, _ageEmoji, aiProvider, body (+97 more)

### Community 1 - "Windows Runner & Plugins"
Cohesion: 0.05
Nodes (57): PluginRegistry, RECT, unique_ptr, RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT (+49 more)

### Community 2 - "Diet Data & Log Widgets"
Cohesion: 0.05
Nodes (43): ../../core/widgets/flow_selector.dart, ../../core/widgets/mood_selector.dart, ../../core/widgets/symptom_chips.dart, doctor_checklist.dart, classifyFood, dairyKeywords, excl, exclusionsFor (+35 more)

### Community 3 - "Data Providers & Models"
Cohesion: 0.05
Nodes (40): ../core/models/daily_log_model.dart, ../core/models/period_model.dart, ../database/database_helper.dart, DailyLogProvider, hasLog, addInitialPeriod, _addPeriodDay, addPeriodRange (+32 more)

### Community 4 - "Store Listing Metadata"
Cohesion: 0.09
Nodes (43): App identifier com.brandbuilder.periodtracker, Store listing character limits, fastlane deliver (App Store listing upload), Hand-set App Store Connect fields, docs/assets/screenshots shared screenshot folder, Store Metadata Guide (fastlane HOWTO), fastlane supply (Google Play listing upload), Google Play changelog 13 (Luna is now Open Period Tracker) (+35 more)

### Community 5 - "Insights View"
Cohesion: 0.05
Nodes (39): avgCycle, body, _chip, count, currentDay, cycleDay, cycleDayMoods, cycleDaySymptoms (+31 more)

### Community 6 - "macOS App Delegate"
Cohesion: 0.07
Nodes (23): Any, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS, FlutterSceneDelegate (+15 more)

### Community 7 - "Profile & Backup Screen"
Cohesion: 0.06
Nodes (35): domain/services/backup_service.dart, ../history/history_view.dart, color, createState, BackupService, Container, DemoDataService, Divider (+27 more)

### Community 8 - "Home Screen & Overlay"
Cohesion: 0.06
Nodes (34): birthday_overlay.dart, ../../core/services/review_service.dart, ../../core/services/share_service.dart, ../../core/widgets/phase_card.dart, int?, _birthdayShown, child, color (+26 more)

### Community 9 - "Doctor Checklist Widget"
Cohesion: 0.06
Nodes (31): ../../core/theme/app_theme.dart, build, Column, DoctorChecklist, GestureDetector, _isWarningOption, Padding, _Question (+23 more)

### Community 10 - "Settings Provider"
Cohesion: 0.06
Nodes (30): bool get, int get, allergies, completeOnboarding, cycleLength, _db, defaultFlow, defaultMoods (+22 more)

### Community 11 - "App Providers & State"
Cohesion: 0.14
Nodes (30): AiDiagnosisProvider, ChangeNotifier, DailyLogProvider, main, PeriodProvider, SettingsProvider, build, _CalendarViewState (+22 more)

### Community 12 - "Analytics Screen"
Cohesion: 0.07
Nodes (29): _ageEmoji, _ageInsight, AnalyticsScreen, build, _cell, Column, Container, _DataTable (+21 more)

### Community 13 - "Onboarding Flow"
Cohesion: 0.07
Nodes (28): ../../core/services/demo_data_service.dart, build, _buildStep, createState, _currentStep, _cycleLength, DemoDataService, FadeTransition (+20 more)

### Community 14 - "Doctor View Analysis"
Cohesion: 0.07
Nodes (28): allMedical, _analyzeFindings, body, _buildEmptyState, _buildPrompt, _copied, createState, Column (+20 more)

### Community 15 - "Repo Docs & Templates"
Cohesion: 0.13
Nodes (28): Bug report issue template (label: bug), Feature request issue template (label: enhancement), Release 1.1.0 (2026-10-27) - the rename release, Areas where help is needed (tests, a11y, l10n, regional food data), Contributing guide, Privacy commitment for contributions, Landing page FAQ (details/summary), FAQPage JSON-LD structured data (+20 more)

### Community 16 - "Linux Runner & Plugins"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 17 - "Diagnosis Cards"
Cohesion: 0.08
Nodes (26): _DiagnosisCard, _FlowAnalysisCard, _FlowBar, _HealthScoreCard, _LstmPredictionCard, _MoodAnalysisCard, _OnDeviceSummaryCard, _PredictionTile (+18 more)

### Community 18 - "Yoga Screen"
Cohesion: 0.08
Nodes (24): AnimatedContainer, build, _buildAccordionContent, _buildDaySelector, _buildInfoCard, _buildPhaseAccordion, _buildPoseCard, _buildTodayPhaseCard (+16 more)

### Community 19 - "Privacy Policy Content"
Cohesion: 0.15
Nodes (24): Local notifications (late period alert), All data stored locally in SQLite, Location data (on-device region detection for diet), Third-party package table (all on-device), assets/models/ (bundled TFLite model asset), flutter_local_notifications ^17.1.2, geocoding ^3.0.0, geolocator ^13.0.2 (+16 more)

### Community 20 - "App Spec & Architecture"
Cohesion: 0.14
Nodes (23): SQLite database with 4 migration versions, Code style (Dart style guide, feature-first, Provider, on-device data), Open Period Tracker App Spec (historical, March 2026), Calendar view, Cycle calculation logic (avgCycleLength, currentCycleDay, nextPeriodDate), daily_logs table (date UNIQUE; flow, mood, symptoms JSON, notes), DailyLogProvider (spec: upsert updateLog, getLog, hasLog), sqflite database schema (settings, periods, daily_logs) (+15 more)

### Community 21 - "Calendar View"
Cohesion: 0.09
Nodes (22): Color, DateTime, color, createState, Container, Expanded, Row, SizedBox (+14 more)

### Community 22 - "Diet Tab & Phases"
Cohesion: 0.09
Nodes (21): CyclePhase, diet_data.dart, Hydration, benefit, _buildPrompt, _copied, createState, emoji (+13 more)

### Community 23 - "Logo Generator Script"
Cohesion: 0.22
Nodes (19): arc(), candidate_a(), candidate_b(), candidate_c(), drop(), grad(), main(), pt() (+11 more)

### Community 24 - "Screenshot Integration Test"
Cohesion: 0.11
Nodes (17): dart:ui, Directory, binding, go, outDir, routerContext, shot, shotKey (+9 more)

### Community 25 - "Settings Model"
Cohesion: 0.11
Nodes (17): allergies, copyWith, createdAt, cycleLength, defaultFlow, defaultMoods, dietType, fromMap (+9 more)

### Community 26 - "Ollama Service"
Cohesion: 0.12
Nodes (16): _buildDiagnosisPrompt, configure, _defaultHost, _defaultModel, generateDiagnosis, getModels, _host, isAvailable (+8 more)

### Community 27 - "Linux CMake Build"
Cohesion: 0.26
Nodes (17): APPLY_STANDARD_SETTINGS (Linux), BINARY_NAME = open_period_cycle_tracker (Linux), Linux relocatable bundle install, flutter INTERFACE library (Linux GTK), flutter_assemble custom target (Linux), Flutter artifact paths published to parent scope (Linux: FLUTTER_LIBRARY, FLUTTER_ICU_DATA_FILE, AOT_LIBRARY, PROJECT_BUILD_DIR), list_prepend, Linux runner executable (main.cc, my_application.cc, generated_plugin_registrant.cc) (+9 more)

### Community 28 - "Four-Phase Cycle Model"
Cohesion: 0.21
Nodes (17): CyclePhase enum (menstrual, follicular, ovulation, luteal), Insights view (phase, movement, nourishment cards), Phase determination thresholds (periodLength, 0.46, 0.57 of cycle), Insights and Analytics, Breathwork data model (name, description), Cycle Yoga mobile app spec (React), Day selector / getCurrentPhase(day) (1-5, 6-13, 14-16, 17-28), Follicular phase - Build & Bloom (days 6-13, Kapalabhati) (+9 more)

### Community 29 - "Router Feature Imports"
Cohesion: 0.13
Nodes (14): ../../features/analytics/analytics_screen.dart, ../../features/calendar/calendar_view.dart, ../../features/diagnosis/diagnosis_screen.dart, ../../features/home/doctor_view.dart, ../../features/home/home_screen.dart, ../../features/insights/insights_view.dart, ../../features/onboarding/onboarding_screen.dart, ../../features/profile/profile_screen.dart (+6 more)

### Community 30 - "Period Length Step"
Cohesion: 0.13
Nodes (14): IconData, build, GestureDetector, Padding, SizedBox, Spacer, icon, onChanged (+6 more)

### Community 31 - "Database Helper"
Cohesion: 0.13
Nodes (14): clearAllTables, daily_logs, openDatabase, periods, settings, _database, DatabaseHelper, _initDatabase (+6 more)

### Community 32 - "Core Screen Widgets"
Cohesion: 0.18
Nodes (15): CalendarView, DiagnosisScreen, _DiagnosisScreenState, _AiPromptCard, _AiPromptCardState, HomeScreen, _HomeScreenState, LogBottomSheet (+7 more)

### Community 33 - "Birthday Overlay"
Cohesion: 0.13
Nodes (14): BirthdayOverlay, _BirthdayOverlayState, build, Color, _ConfettiPainter, _ConfettiPiece, CustomPaint, dispose (+6 more)

### Community 34 - "Changelog 1.0.0 Features"
Cohesion: 0.14
Nodes (14): Birthday celebration overlay with confetti, CSV export and import (1.0.0), Ollama LLM integration (optional), On-device rule-based AI health summary, Regional food suggestions by GPS (8 regions), Release 1.0.0 (2026-03-27) - initial release, Ollama integration (opt-in, local LLM server), On-device rule-based health analysis (+6 more)

### Community 35 - "App Root & Router"
Cohesion: 0.17
Nodes (12): core/providers/settings_provider.dart, core/router/app_router.dart, GoRouter?, build, createState, LunaApp, _LunaAppState, MaterialApp (+4 more)

### Community 36 - "Screenshot Pipeline Docs"
Cohesion: 0.24
Nodes (13): design/screenshots/compose.py (SHOTS list, iPhone 6.9in and iPad 13in sets), Layer-tree rendering for raw captures, integration_test/screenshots_test.dart (seeds demo data, visits every screen), Store screenshot pipeline (simulator prep, flutter drive, compose), Demo data generator (one year of realistic data), App Store Connect listing fields (name, subtitle, keywords, URLs, screenshots), Build artifacts (flutter build ipa / appbundle), Release builds signed with the debug keystore (+5 more)

### Community 37 - "Design Asset Pipeline"
Cohesion: 0.21
Nodes (12): Social preview image docs/assets/og.png (1280x640), Design asset pipeline (scripted logo, icon and store screenshots), Logo generation scripts (design/logo/generate_logo.py, lockups.py), Open cycle ring mark (app icon / logo), iOS launch screen assets (boilerplate README), Cycle progress ring (custom painter), Design system (pastel phase palette, Playfair Display + Outfit), Home screen (phase card, stats row, ring, tab switcher) (+4 more)

### Community 38 - "Backup Service"
Cohesion: 0.17
Nodes (11): ../../../../core/database/database_helper.dart, BackupService, Exception, FormatException, exportDataToJSON, importDataFromJSON, _instance, _validatedRows (+3 more)

### Community 39 - "Windows Runner Main"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 40 - "Cycle Ring Painter"
Cohesion: 0.17
Nodes (11): AnimatedBuilder, build, CycleRing, _CycleRingPainter, _CycleRingState, didUpdateWidget, dispose, initState (+3 more)

### Community 41 - "Review Service"
Cohesion: 0.18
Nodes (10): cooldownDays, _kLastAsk, _kLastOpen, _kOpenDays, maybeRequest, minCycles, minOpenDays, ReviewService (+2 more)

### Community 42 - "Web Manifest"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 43 - "GitHub Repo Settings"
Cohesion: 0.18
Nodes (10): FUNDING.yml (github username placeholder, unset), GitHub repository settings (description, topics, Pages, releases), GitHub Pages setup (deploy from main, /docs), 20 GitHub topics (period-tracker, privacy-first, offline-first, femtech, ...), Naming policy: Open Period Tracker; Luna retired, Releases policy (tag per store version), Analyzer config including package:flutter_lints/flutter.yaml, Fork, branch, flutter analyze, flutter test, PR workflow (+2 more)

### Community 44 - "LSTM Service"
Cohesion: 0.20
Nodes (9): CyclePrediction, dispose, _loadModel, _loadNormParams, LstmService, _predictStatistical, _weightedMovingAverage, package:flutter/services.dart (+1 more)

### Community 45 - "App Entry & Notifications"
Cohesion: 0.25
Nodes (7): app.dart, core/providers/daily_log_provider.dart, core/services/notification_service.dart, buildApp, NotificationService, main, services/ai_diagnosis_provider.dart

### Community 46 - "History View"
Cohesion: 0.25
Nodes (7): core/providers/period_provider.dart, build, Column, Container, HistoryView, SizedBox, package:provider/provider.dart

### Community 47 - "Demo Data Service"
Cohesion: 0.25
Nodes (7): dart:math, DemoDataService, _fmt, package:sqflite/sqflite.dart, ../providers/daily_log_provider.dart, ../providers/period_provider.dart, ../providers/settings_provider.dart

### Community 48 - "Notification Service"
Cohesion: 0.25
Nodes (7): initialize, NotificationDetails, NotificationService, package:flutter_local_notifications/flutter_local_notifications.dart, package:shared_preferences/shared_preferences.dart, package:timezone/data/latest_all.dart, package:timezone/timezone.dart

### Community 49 - "App Theme"
Cohesion: 0.25
Nodes (7): AppColors, AppDecorations, AppTextStyles, phaseBgColor, phaseColor, phaseName, package:google_fonts/google_fonts.dart

### Community 50 - "Shell Navigation"
Cohesion: 0.25
Nodes (7): build, Expanded, _NavItem, Scaffold, ShellScreen, SizedBox, package:go_router/go_router.dart

### Community 51 - "Privacy Compliance Page"
Cohesion: 0.38
Nodes (7): Privacy policy HTML page (docs/ copy served by GitHub Pages), AI prompt builder (manual copy to external AI), Bundle ID com.brandbuilder.periodtracker, Compliance (GDPR, CCPA, HIPAA, App Store, Google Play), Privacy Policy (Open Period & Cycle Tracker, 2026-03-27), Privacy policy HTML page (repo root), AI prompt builder (anonymised summary for ChatGPT/Claude/Gemini)

### Community 52 - "Flow Selector"
Cohesion: 0.29
Nodes (6): build, Expanded, _FlowOption, FlowSelector, Row, SizedBox

### Community 53 - "LSTM Training Script"
Cohesion: 0.33
Nodes (6): build_and_train_model(), generate_dummy_model(), generate_synthetic_data(), Generate a minimal valid TFLite model without TensorFlow. This creates a tiny…, Generate synthetic cycle data for training., Build and train the LSTM model.

### Community 54 - "Integration Test Driver"
Cohesion: 0.33
Nodes (5): dart:io, package:integration_test/integration_test_driver_extended.dart, dir, integrationDriver, main

### Community 55 - "Share Service"
Cohesion: 0.33
Nodes (5): _getPhaseName, ShareService, shareStatus, package:intl/intl.dart, package:share_plus/share_plus.dart

### Community 56 - "Mood Selector"
Cohesion: 0.33
Nodes (5): build, GestureDetector, MoodSelector, SizedBox, Wrap

### Community 57 - "Phase Card"
Cohesion: 0.33
Nodes (5): build, Container, PhaseCard, SizedBox, package:flutter/material.dart

### Community 58 - "Symptom Chips"
Cohesion: 0.33
Nodes (5): build, GestureDetector, SymptomChips, Wrap, ../theme/app_theme.dart

### Community 59 - "Stat Card"
Cohesion: 0.40
Nodes (4): build, Container, SizedBox, StatCard

### Community 60 - "Daily Log Model"
Cohesion: 0.50
Nodes (3): dart:convert, copyWith, DailyLogModel

### Community 61 - "Screenshot Composer"
Cohesion: 0.83
Nodes (3): main(), page(), render()

### Community 62 - "Period Model"
Cohesion: 0.50
Nodes (3): containsDate, copyWith, PeriodModel

## Knowledge Gaps
- **681 isolated node(s):** `NotificationService`, `LunaApp`, `_LunaAppState`, `MaterialApp`, `openDatabase` (+676 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SettingsProvider` connect `App Providers & State` to `AI Diagnosis Screen`, `Core Screen Widgets`, `Diet Data & Log Widgets`, `App Root & Router`, `Profile & Backup Screen`, `Home Screen & Overlay`, `Settings Provider`, `Onboarding Flow`, `Doctor View Analysis`, `Diagnosis Cards`, `Diet Tab & Phases`, `Screenshot Integration Test`?**
  _High betweenness centrality (0.059) - this node is a cross-community bridge._
- **Why does `PeriodProvider` connect `App Providers & State` to `AI Diagnosis Screen`, `Core Screen Widgets`, `Diet Data & Log Widgets`, `Data Providers & Models`, `Insights View`, `Profile & Backup Screen`, `Home Screen & Overlay`, `Onboarding Flow`, `Doctor View Analysis`, `Calendar View`, `Diet Tab & Phases`, `Screenshot Integration Test`?**
  _High betweenness centrality (0.053) - this node is a cross-community bridge._
- **Why does `DatabaseHelper` connect `Database Helper` to `Settings Provider`, `Data Providers & Models`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **What connects `NotificationService`, `LunaApp`, `_LunaAppState` to the rest of the system?**
  _681 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `AI Diagnosis Screen` be split into smaller, more focused modules?**
  _Cohesion score 0.018867924528301886 - nodes in this community are weakly interconnected._
- **Should `Windows Runner & Plugins` be split into smaller, more focused modules?**
  _Cohesion score 0.05311676909569798 - nodes in this community are weakly interconnected._
- **Should `Diet Data & Log Widgets` be split into smaller, more focused modules?**
  _Cohesion score 0.045454545454545456 - nodes in this community are weakly interconnected._