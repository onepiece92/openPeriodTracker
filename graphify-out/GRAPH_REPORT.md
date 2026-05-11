# Graph Report - lib  (2026-05-11)

## Corpus Check
- Corpus is ~42,522 words - fits in a single context window. You may not need a graph.

## Summary
- 533 nodes · 620 edges · 21 communities detected
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_AI Diagnosis Screen|AI Diagnosis Screen]]
- [[_COMMUNITY_Theme & UI Widgets|Theme & UI Widgets]]
- [[_COMMUNITY_Data Providers|Data Providers]]
- [[_COMMUNITY_Profile Screen|Profile Screen]]
- [[_COMMUNITY_App Shell & Logging|App Shell & Logging]]
- [[_COMMUNITY_Analytics Screen|Analytics Screen]]
- [[_COMMUNITY_Database & Demo Data|Database & Demo Data]]
- [[_COMMUNITY_Insights View|Insights View]]
- [[_COMMUNITY_Calendar & Sharing|Calendar & Sharing]]
- [[_COMMUNITY_Yoga Screen|Yoga Screen]]
- [[_COMMUNITY_App Router|App Router]]
- [[_COMMUNITY_Models & LSTM Service|Models & LSTM Service]]
- [[_COMMUNITY_Onboarding Steppers|Onboarding Steppers]]
- [[_COMMUNITY_Onboarding Screen|Onboarding Screen]]
- [[_COMMUNITY_Doctor View|Doctor View]]
- [[_COMMUNITY_Home Screen|Home Screen]]
- [[_COMMUNITY_Notifications & Backup|Notifications & Backup]]
- [[_COMMUNITY_Cycle Ring Painter|Cycle Ring Painter]]
- [[_COMMUNITY_Doctor Checklist|Doctor Checklist]]
- [[_COMMUNITY_Last Period Step|Last Period Step]]
- [[_COMMUNITY_Period Model|Period Model]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 27 edges
2. `../../core/theme/app_theme.dart` - 19 edges
3. `package:provider/provider.dart` - 13 edges
4. `../../core/providers/period_provider.dart` - 12 edges
5. `../../core/providers/daily_log_provider.dart` - 10 edges
6. `../../core/providers/settings_provider.dart` - 9 edges
7. `dart:convert` - 8 edges
8. `package:intl/intl.dart` - 8 edges
9. `../theme/app_theme.dart` - 7 edges
10. `package:go_router/go_router.dart` - 5 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities

### Community 0 - "AI Diagnosis Screen"
Cohesion: 0.03
Nodes (71): _ageAdvice, _ageEmoji, _AiDiagnosisPromptCard, _AiDiagnosisPromptCardState, _AiPromptCard, _AiPromptCardState, _AiSection, build (+63 more)

### Community 1 - "Theme & UI Widgets"
Cohesion: 0.06
Nodes (32): AppColors, AppDecorations, AppTextStyles, phaseBgColor, phaseColor, phaseName, build, Expanded (+24 more)

### Community 2 - "Data Providers"
Cohesion: 0.06
Nodes (33): ../core/models/daily_log_model.dart, ../core/models/period_model.dart, ../database/database_helper.dart, DailyLogProvider, hasLog, _addPeriodDay, _findNearestPeriod, _formatDate (+25 more)

### Community 3 - "Profile Screen"
Cohesion: 0.06
Nodes (33): domain/services/backup_service.dart, ../history/history_view.dart, _ActionTile, BackupService, build, Container, _DefaultsSection, DemoDataService (+25 more)

### Community 4 - "App Shell & Logging"
Cohesion: 0.07
Nodes (30): app.dart, ../../core/providers/daily_log_provider.dart, ../../core/providers/settings_provider.dart, core/router/app_router.dart, ../../core/services/notification_service.dart, ../../core/widgets/flow_selector.dart, ../../core/widgets/mood_selector.dart, ../../core/widgets/symptom_chips.dart (+22 more)

### Community 5 - "Analytics Screen"
Cohesion: 0.07
Nodes (29): _ageEmoji, _ageInsight, AnalyticsScreen, build, _cell, Column, Container, _DataTable (+21 more)

### Community 6 - "Database & Demo Data"
Cohesion: 0.07
Nodes (26): dart:math, daily_logs, DatabaseHelper, openDatabase, periods, settings, DemoDataService, _fmt (+18 more)

### Community 7 - "Insights View"
Cohesion: 0.07
Nodes (28): _BestWorstDays, build, _chip, Column, Container, _CycleComparison, Expanded, _FertileIntel (+20 more)

### Community 8 - "Calendar & Sharing"
Cohesion: 0.07
Nodes (25): ../../core/providers/period_provider.dart, _getPhaseName, ShareService, build, CalendarView, _CalendarViewState, Container, _dot (+17 more)

### Community 9 - "Yoga Screen"
Cohesion: 0.08
Nodes (24): AnimatedContainer, build, _buildAccordionContent, _buildDaySelector, _buildInfoCard, _buildPhaseAccordion, _buildPoseCard, _buildTodayPhaseCard (+16 more)

### Community 10 - "App Router"
Cohesion: 0.09
Nodes (21): ../../features/analytics/analytics_screen.dart, ../../features/calendar/calendar_view.dart, ../../features/diagnosis/diagnosis_screen.dart, ../../features/home/doctor_view.dart, ../../features/home/home_screen.dart, ../../features/insights/insights_view.dart, ../../features/onboarding/onboarding_screen.dart, ../../features/profile/profile_screen.dart (+13 more)

### Community 11 - "Models & LSTM Service"
Cohesion: 0.09
Nodes (18): dart:convert, copyWith, DailyLogModel, copyWith, SettingsModel, CyclePrediction, dispose, _loadModel (+10 more)

### Community 12 - "Onboarding Steppers"
Cohesion: 0.09
Nodes (19): ../../core/theme/app_theme.dart, build, GestureDetector, Padding, SizedBox, Spacer, StepCycleLength, _StepperButton (+11 more)

### Community 13 - "Onboarding Screen"
Cohesion: 0.1
Nodes (20): ../../core/services/demo_data_service.dart, build, _buildStep, DemoDataService, FadeTransition, _next, OnboardingScreen, _OnboardingScreenState (+12 more)

### Community 14 - "Doctor View"
Cohesion: 0.11
Nodes (17): build, _buildEmptyState, _buildPrompt, Column, Container, DATA, _DoctorPromptCard, _DoctorPromptCardState (+9 more)

### Community 15 - "Home Screen"
Cohesion: 0.11
Nodes (17): birthday_overlay.dart, ../../core/services/share_service.dart, ../../core/widgets/phase_card.dart, build, Container, Expanded, HomeScreen, _HomeScreenState (+9 more)

### Community 16 - "Notifications & Backup"
Cohesion: 0.12
Nodes (15): ../../../../core/database/database_helper.dart, dart:io, initialize, NotificationDetails, NotificationService, BackupService, Exception, FormatException (+7 more)

### Community 17 - "Cycle Ring Painter"
Cohesion: 0.17
Nodes (11): AnimatedBuilder, build, CycleRing, _CycleRingPainter, _CycleRingState, didUpdateWidget, dispose, initState (+3 more)

### Community 18 - "Doctor Checklist"
Cohesion: 0.18
Nodes (10): build, Column, DoctorChecklist, GestureDetector, _isWarningOption, Padding, _Question, _QuestionRow (+2 more)

### Community 19 - "Last Period Step"
Cohesion: 0.2
Nodes (9): build, _buildCalendar, Container, GestureDetector, initState, Padding, SizedBox, StepLastPeriod (+1 more)

### Community 20 - "Period Model"
Cohesion: 0.5
Nodes (3): containsDate, copyWith, PeriodModel

## Knowledge Gaps
- **468 isolated node(s):** `main`, `NotificationService`, `app.dart`, `LunaApp`, `_LunaAppState` (+463 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Theme & UI Widgets` to `AI Diagnosis Screen`, `Profile Screen`, `App Shell & Logging`, `Analytics Screen`, `Database & Demo Data`, `Insights View`, `Calendar & Sharing`, `Yoga Screen`, `App Router`, `Onboarding Steppers`, `Onboarding Screen`, `Doctor View`, `Home Screen`, `Cycle Ring Painter`, `Doctor Checklist`, `Last Period Step`?**
  _High betweenness centrality (0.420) - this node is a cross-community bridge._
- **Why does `../../core/theme/app_theme.dart` connect `Onboarding Steppers` to `AI Diagnosis Screen`, `Profile Screen`, `App Shell & Logging`, `Analytics Screen`, `Database & Demo Data`, `Insights View`, `Calendar & Sharing`, `Yoga Screen`, `App Router`, `Onboarding Screen`, `Doctor View`, `Home Screen`, `Cycle Ring Painter`, `Doctor Checklist`, `Last Period Step`?**
  _High betweenness centrality (0.171) - this node is a cross-community bridge._
- **Why does `../theme/app_theme.dart` connect `Theme & UI Widgets` to `Calendar & Sharing`, `Data Providers`?**
  _High betweenness centrality (0.120) - this node is a cross-community bridge._
- **What connects `main`, `NotificationService`, `app.dart` to the rest of the system?**
  _468 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `AI Diagnosis Screen` be split into smaller, more focused modules?**
  _Cohesion score 0.03 - nodes in this community are weakly interconnected._
- **Should `Theme & UI Widgets` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._
- **Should `Data Providers` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._