# Luna — Period Tracker App

## Technical Specification for Flutter Implementation

---

## Tech Stack

- **Framework:** Flutter (latest stable)
- **State Management:** Provider
- **Local Database:** sqflite
- **Target Platforms:** iOS & Android
- **Min SDK:** Android 21 / iOS 13
- **Dart version:** 3.x+

### Key Packages

```yaml
dependencies:
  provider: ^6.0.0
  sqflite: ^2.3.0
  path: ^1.8.0
  intl: ^0.18.0
  flutter_local_notifications: ^16.0.0  # optional, for reminders
  table_calendar: ^3.0.0  # optional, or build custom calendar

dev_dependencies:
  flutter_test:
  sqflite_common_ffi: ^2.3.0  # for testing sqflite on desktop
```

---

## App Overview

Luna is a minimal, pastel-themed period tracking app. Users onboard by entering their last period date, average cycle length, and period duration. The app then predicts future periods and fertile windows, learns from logged data over time, and provides phase-based wellness insights.

### Core Principles

1. **Privacy-first** — all data stored locally on-device via sqflite. No network calls, no analytics, no accounts.
2. **Minimal & calm UI** — soft pastel palette, clean white cards, generous whitespace, no visual clutter.
3. **Smart predictions** — cycle predictions recalculate based on actual logged period history (averaging previous cycles).
4. **Tap-first interaction** — tap any calendar date to log period days, mood, symptoms, flow, and notes.

---

## Database Schema (sqflite)

### Table: `settings`

| Column         | Type    | Description                        |
|----------------|---------|------------------------------------|
| id             | INTEGER | Primary key, always 1 (singleton)  |
| cycle_length   | INTEGER | User's initial avg cycle length    |
| period_length  | INTEGER | User's initial avg period length   |
| onboarded      | INTEGER | 0 or 1, whether onboarding is done |
| created_at     | TEXT    | ISO 8601 timestamp                 |

### Table: `periods`

| Column     | Type    | Description                           |
|------------|---------|---------------------------------------|
| id         | INTEGER | Primary key, auto-increment           |
| start_date | TEXT    | ISO 8601 date (YYYY-MM-DD)            |
| end_date   | TEXT    | ISO 8601 date (YYYY-MM-DD)            |
| created_at | TEXT    | ISO 8601 timestamp                    |
| updated_at | TEXT    | ISO 8601 timestamp                    |

Constraints: `start_date` must be <= `end_date`. No overlapping periods — enforce in the provider logic by merging adjacent/overlapping entries when a new period day is toggled.

### Table: `daily_logs`

| Column     | Type    | Description                                      |
|------------|---------|--------------------------------------------------|
| id         | INTEGER | Primary key, auto-increment                      |
| date       | TEXT    | ISO 8601 date (YYYY-MM-DD), UNIQUE               |
| flow       | TEXT    | Nullable. One of: `light`, `medium`, `heavy`      |
| mood       | TEXT    | Nullable. One of: `Happy`, `Tired`, `Sad`, `Irritable`, `Loving`, `Anxious` |
| symptoms   | TEXT    | Nullable. JSON array string, e.g. `["Cramps","Headache"]` |
| notes      | TEXT    | Nullable. Free text                               |
| created_at | TEXT    | ISO 8601 timestamp                                |
| updated_at | TEXT    | ISO 8601 timestamp                                |

---

## Provider Architecture

### Providers to Create

```
lib/
├── main.dart
├── app.dart
├── theme/
│   └── app_theme.dart
├── database/
│   └── database_helper.dart
├── models/
│   ├── settings_model.dart
│   ├── period_model.dart
│   └── daily_log_model.dart
├── providers/
│   ├── settings_provider.dart
│   ├── period_provider.dart
│   └── daily_log_provider.dart
├── screens/
│   ├── onboarding/
│   │   ├── onboarding_screen.dart
│   │   ├── step_last_period.dart
│   │   ├── step_cycle_length.dart
│   │   └── step_period_length.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── calendar/
│   │   └── calendar_view.dart
│   ├── history/
│   │   └── history_view.dart
│   ├── insights/
│   │   └── insights_view.dart
│   └── log_panel/
│       └── log_bottom_sheet.dart
└── widgets/
    ├── cycle_ring.dart
    ├── phase_card.dart
    ├── stat_card.dart
    ├── drop_icon.dart
    ├── mood_selector.dart
    ├── symptom_chips.dart
    └── flow_selector.dart
```

### SettingsProvider (ChangeNotifier)

```dart
class SettingsProvider extends ChangeNotifier {
  SettingsModel? _settings;
  bool get isOnboarded => _settings?.onboarded == true;

  Future<void> loadSettings() async { ... }
  Future<void> completeOnboarding({
    required String lastPeriodStart,
    required int cycleLength,
    required int periodLength,
  }) async { ... }
  Future<void> resetApp() async { ... }  // clears all tables, back to onboarding
}
```

### PeriodProvider (ChangeNotifier)

```dart
class PeriodProvider extends ChangeNotifier {
  List<PeriodModel> _periods = [];

  List<PeriodModel> get periods => _periods;
  int get averageCycleLength => ...;  // calculated from period history
  PeriodModel? get lastPeriod => ...;
  int get currentCycleDay => ...;
  DateTime? get nextPeriodDate => ...;
  int? get daysUntilNextPeriod => ...;
  bool get isInFertileWindow => ...;
  CyclePhase get currentPhase => ...;  // enum: menstrual, follicular, ovulation, luteal

  Future<void> loadPeriods() async { ... }
  Future<void> togglePeriodDay(String dateStr) async { ... }
  // ^ This is the KEY method. Logic:
  //   1. Check if date falls within an existing period → remove/shrink/split that period
  //   2. If not in a period → create new period, then merge with adjacent periods
  //   3. Save to DB, reload, notifyListeners

  bool isDateInPeriod(String dateStr) => ...;
  String getDayStatus(String dateStr) => ...; // "period", "predicted-period", "fertile", "normal"
}
```

### DailyLogProvider (ChangeNotifier)

```dart
class DailyLogProvider extends ChangeNotifier {
  Map<String, DailyLogModel> _logs = {};

  Future<void> loadLogs() async { ... }
  Future<void> updateLog(String date, {String? flow, String? mood, List<String>? symptoms, String? notes}) async { ... }
  // ^ Upserts: if log exists for date, update non-null fields. If not, create.
  DailyLogModel? getLog(String date) => _logs[date];
  bool hasLog(String date) => _logs.containsKey(date);
}
```

### Wrap in main.dart

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
    ChangeNotifierProvider(create: (_) => PeriodProvider()..loadPeriods()),
    ChangeNotifierProvider(create: (_) => DailyLogProvider()..loadLogs()),
  ],
  child: const LunaApp(),
)
```

---

## Screens & User Flows

### 1. Onboarding (3 steps)

**Entry condition:** `SettingsProvider.isOnboarded == false`

#### Step 1 — Last Period Start Date

- Show the Luna logo (🌙 emoji or custom icon) and "Luna — Your cycle companion" tagline
- "Get Started" button → transitions to date picker
- Calendar widget for selecting the date (navigate months, disable future dates)
- Display selected date below the calendar in human-readable format
- "Next" button

#### Step 2 — Average Cycle Length

- Stepper with − and + buttons
- Large number display (Playfair Display font style)
- Range: 20–45 days, default: 28
- Subtitle: "From the first day of one period to the first day of the next"
- "Next" button

#### Step 3 — Period Length

- Same stepper UI
- Range: 2–10 days, default: 5
- Subtitle: "An estimate is fine — Luna will learn from your logs"
- "Start Tracking ✨" button → calls `SettingsProvider.completeOnboarding()` which also creates the first period entry in `PeriodProvider`

**On complete:** settings saved to DB, first period record created (start = selected date, end = start + periodLength - 1), navigate to Home.

---

### 2. Home Screen

The main screen has a **scrollable column** layout with a **bottom tab-like section** switching between Calendar, History, and Insights views.

#### Header Section (always visible at top)

- "Luna" title + "your cycle companion" subtitle (left-aligned)
- "Reset" button (top-right, small, outlined) — triggers confirmation dialog → `SettingsProvider.resetApp()`

#### Phase Card

- Colored background matching current phase (see Design section for colors)
- Phase dot (small circle) + phase name in bold (e.g., "Follicular Phase")
- Right side: "Day X of Y" where Y = average cycle length

#### Stats Row (4 items, horizontal scroll or evenly spaced)

| Stat              | Value                                | Notes                               |
|-------------------|--------------------------------------|--------------------------------------|
| Next period       | `{days} days`                        | Days until next predicted period     |
| Fertile           | "Yes" / "No"                         | Green if yes                         |
| Avg cycle         | `{n} d`                              | Computed from period history         |
| Logged            | `{n}`                                | Count of period entries              |

#### Cycle Progress Ring

- Circular progress indicator (custom painter)
- Background track: light pastel (#f0e8f5)
- Period arc segment: soft red, 20% opacity
- Fertile arc segment: soft green, 20% opacity
- Progress arc: current phase color, animated
- Dot indicator at current position on the ring
- Center text: large cycle day number + "CYCLE DAY" label below

#### Tab Switcher

Three pill-shaped buttons: 📅 Calendar | 📊 History | ✨ Insights. Active tab gets white background with shadow, inactive is semi-transparent.

---

### 3. Calendar View (tab content)

- White card with rounded corners
- Month/year header with ‹ › navigation arrows
- 7-column day label row: Su Mo Tu We Th Fr Sa
- Calendar grid with day buttons, each showing:
  - **Period day (logged):** solid soft-red background (#e07088), white text
  - **Predicted period:** light red tint background + small red dot at bottom
  - **Fertile window:** light green tint background
  - **Today:** outlined with current phase color
  - **Selected:** phase-colored background with subtle shadow
  - **Has log data:** small purple dot at bottom
- Legend below: Period • Predicted • Fertile • Logged (with colored dots)
- Tapping any date opens the **Log Bottom Sheet**

---

### 4. Log Bottom Sheet

A modal bottom sheet that slides up, covering ~85% of screen height. Dismissible by tapping the overlay or the ✕ button.

#### Header

- Drag handle bar at top (small rounded rectangle)
- Full date display (e.g., "Wednesday, March 15") + close button

#### Period Day Toggle (most prominent element)

- Full-width button at top of the sheet
- Two states:
  - **Not a period day:** white background, red-outlined, red text: "🩸 Mark as Period Day"
  - **Is a period day:** solid red background, white text: "🩸 Remove Period Day"
- Tapping calls `PeriodProvider.togglePeriodDay(date)`

#### Flow Selector

- Section label: "FLOW" (uppercase, small, muted)
- 3 buttons in a row: Light (1 drop), Medium (2 drops), Heavy (3 drops)
- Each is a rounded card with drop icons + label
- Active state: light red background with red border
- Tappable to toggle (tap again to deselect)

#### Mood Selector

- Section label: "MOOD"
- 6 emoji buttons in a flex wrap row: 😊 Happy, 😴 Tired, 😢 Sad, 😤 Irritable, 🥰 Loving, 😰 Anxious
- Each shows emoji + label below
- Active: purple tint background with purple border
- Single-select (tap again to deselect)

#### Symptom Chips

- Section label: "SYMPTOMS"
- 8 pill-shaped chips in a flex wrap: Cramps, Headache, Bloating, Back pain, Breast tenderness, Acne, Nausea, Fatigue
- Active: teal tint background with teal border
- Multi-select (tap to toggle each independently)

#### Notes

- Section label: "NOTES"
- Multi-line text field, 3 rows
- Placeholder: "How are you feeling today?"

**All changes save immediately** (on each tap/toggle) — no "Save" button needed. The provider upserts the daily_log record.

---

### 5. History View (tab content)

- Title: "Period History" (Playfair Display)
- If no periods logged: centered message in a card — "No periods logged yet. Tap a date on the calendar and mark it as a period day."
- Otherwise: list of period cards, reverse chronological, each showing:
  - Date range (e.g., "Mar 3 — Mar 7")
  - Duration (e.g., "5 days")
  - Cycle length to the next period (if applicable, e.g., "28 day cycle" on the right side)
- Summary card at bottom with pastel phase-colored background:
  - "Average cycle: X days • Periods logged: N"

---

### 6. Insights View (tab content)

- Title: "Cycle Insights" (Playfair Display)
- 3 white cards with emoji icon + title + description text:

| Card        | Icon | Content varies by current phase                                                                 |
|-------------|------|-------------------------------------------------------------------------------------------------|
| Current Phase | 🌸  | **Menstrual:** "Rest and be gentle with yourself. Iron-rich foods and warm drinks help."        |
|             |      | **Follicular:** "Energy is building! Great time for new projects and creative work."             |
|             |      | **Ovulation:** "You're at your most vibrant — communication and creativity peak."                |
|             |      | **Luteal:** "Time to slow down. Nourish yourself and set healthy boundaries."                    |
| Movement    | 🧘‍♀️ | **Menstrual:** "Gentle yoga, walks, and stretching feel best right now."                         |
|             |      | **Follicular:** "Try running, dance classes, or strength training."                              |
|             |      | **Ovulation:** "High-intensity workouts and group fitness are perfect."                          |
|             |      | **Luteal:** "Pilates, swimming, or gentle hiking suit this phase."                               |
| Nourishment | 🍵  | **Menstrual:** "Warm soups, leafy greens, and herbal teas support recovery."                     |
|             |      | **Follicular:** "Fresh salads, fermented foods, and lean proteins fuel growth."                   |
|             |      | **Ovulation:** "Light meals, raw veggies, and antioxidant-rich fruits."                          |
|             |      | **Luteal:** "Complex carbs, root vegetables, and magnesium-rich chocolate."                      |

---

## Cycle Calculation Logic

This is the most critical business logic. Implement carefully.

### Definitions

```
cycleLength (initial) = from settings table
avgCycleLength (computed) = if periods.length >= 2:
    sum of (periods[i].start - periods[i-1].start) for i in 1..n
    divided by (periods.length - 1)
  else:
    cycleLength from settings

periodLength (initial) = from settings table

lastPeriod = most recent entry in periods table (sorted by start_date DESC)

currentCycleDay = (today - lastPeriod.start_date) % avgCycleLength + 1

nextPeriodDate = lastPeriod.start_date + avgCycleLength
  (if nextPeriodDate <= today, keep adding avgCycleLength until it's in the future)

daysUntilNextPeriod = nextPeriodDate - today

fertileWindowStart = avgCycleLength - 18
fertileWindowEnd = avgCycleLength - 12
isInFertileWindow = currentCycleDay >= fertileWindowStart && currentCycleDay <= fertileWindowEnd
```

### Phase Determination

```
if currentCycleDay <= periodLength → Menstrual
else if currentCycleDay <= avgCycleLength * 0.46 → Follicular
else if currentCycleDay <= avgCycleLength * 0.57 → Ovulation
else → Luteal
```

### Day Status for Calendar (for any given date)

```
1. Check if date falls within any logged period → "period"
2. If not, calculate predicted status:
   a. diff = daysBetween(lastPeriod.start, date)
   b. if diff < 0 → "normal"
   c. cycleDayForDate = (diff % avgCycleLength) + 1
   d. if cycleDayForDate <= periodLength → "predicted-period"
   e. if cycleDayForDate in fertile window → "fertile"
   f. else → "normal"
```

### Toggle Period Day Logic

When user taps "Mark as Period Day" for a given date:

**Adding a period day:**
1. Check if the previous day (date - 1) is the end of an existing period → extend that period's end_date
2. Check if the next day (date + 1) is the start of an existing period → extend that period's start_date
3. If both adjacent periods exist → merge them into one (delete one, extend the other)
4. If neither → create a new single-day period (start = end = date)

**Removing a period day:**
1. If the period is a single day (start == end) → delete the record
2. If the date is the start → set start = date + 1
3. If the date is the end → set end = date - 1
4. If the date is in the middle → split into two periods: (original.start → date-1) and (date+1 → original.end)

Always re-sort periods by start_date after any mutation.

---

## Design System

### Color Palette

```dart
// Phase colors
static const Color menstrual = Color(0xFFE07088);
static const Color menstrualBg = Color(0xFFFCE8ED);
static const Color follicular = Color(0xFF5BA4B5);
static const Color follicularBg = Color(0xFFE0F0F5);
static const Color ovulation = Color(0xFF6AB88A);
static const Color ovulationBg = Color(0xFFE2F3E8);
static const Color luteal = Color(0xFFA386BF);
static const Color lutealBg = Color(0xFFEEE4F5);

// UI colors
static const Color textPrimary = Color(0xFF2D2440);     // headings, important text
static const Color textSecondary = Color(0xFF6B5F7D);   // body text
static const Color textMuted = Color(0xFF9B8FAD);       // labels, hints
static const Color textLight = Color(0xFF8A7D9C);       // subtitles
static const Color cardBackground = Color(0xFFFFFFFF);
static const Color cardBorder = Color(0xFFF0E8F5);
static const Color surfaceBackground = Color(0xFFFAF6FD);  // bottom sheet bg
static const Color inputBorder = Color(0xFFEEE4F0);

// Gradient background (main scaffold)
// LinearGradient from top-left to bottom-right:
//   #FDF2F6 → #EDE4F5 → #E4EDF8 → #EEF6F2
```

### Typography

```dart
// Display/Headings — use a serif font (Google Fonts: Playfair Display)
//   App title: 28px, weight 600
//   Section titles: 18px, weight 600
//   Large numbers (cycle day, stats): 30px / 20-22px, weight 600

// Body/UI — use a clean sans-serif (Google Fonts: Outfit)
//   Body text: 13px, weight 400
//   Labels: 11px, weight 600, uppercase, letter-spacing 0.8
//   Small text: 10px, weight 500
//   Buttons: 14-15px, weight 600

// Font package: google_fonts
```

### Component Styles

```
Cards:
  - border-radius: 18-20
  - background: white
  - border: 1px solid #F0E8F5
  - shadow: BoxShadow(color: Color(0x0FA08CB0), blurRadius: 12, offset: Offset(0, 2))

Buttons (pill/chip):
  - border-radius: 14-20
  - active: phase-tinted background + colored border
  - inactive: white or very light background + light border

Calendar day cells:
  - border-radius: 11
  - size: equal width/height (square)
  - active day press animation: scale down to 0.88

Bottom sheet:
  - border-radius: 24 (top only)
  - background: #FAF6FD
  - top border: 1px solid #EFE8F5
  - drag handle: 36x4, border-radius 2, color #D8CCE5

Tab buttons:
  - border-radius: 14
  - active: white bg, subtle shadow
  - inactive: transparent with 30% white
  - smooth transition (250ms)
```

### Animations

- **Page transitions:** fade + slide up (300ms ease)
- **Calendar day tap:** scale to 0.88 (150ms)
- **Chip/button tap:** scale to 0.95 (150ms)
- **Bottom sheet:** slide up from bottom (300ms ease)
- **Cycle ring progress:** animated stroke dasharray (600ms ease)
- **Background blobs (optional):** slow floating animation, purely decorative radial gradient circles with very low opacity

---

## Edge Cases to Handle

1. **No periods logged:** stats show "—" for "days until next period", predictions don't render on calendar
2. **Period in the future:** allow marking future dates as period days (user may want to pre-log)
3. **Very long period:** if user marks 15+ consecutive days, don't break — just store it. No hard limit on period length.
4. **Cycle length drift:** if the computed average is wildly different from initial setting (e.g., user set 28 but actual average is 35), always use the computed average once 2+ periods exist
5. **Same-day toggle:** tapping "Mark as Period Day" then immediately "Remove Period Day" should cleanly round-trip without leaving orphan records
6. **Month navigation:** calendar should handle Dec→Jan and Jan→Dec year transitions
7. **First open after install:** should show onboarding, not a blank or loading screen
8. **Reset app:** clears all 3 database tables and navigates back to onboarding

---

## Testing Checklist

- [ ] Onboarding flow completes and saves settings + first period to DB
- [ ] Calendar correctly highlights logged period days, predicted period days, and fertile window
- [ ] Tapping a date opens the log sheet with correct existing data pre-filled
- [ ] "Mark as Period Day" creates a period entry; adjacent days merge correctly
- [ ] "Remove Period Day" shrinks, splits, or deletes period entries correctly
- [ ] Flow, mood, symptoms, and notes save immediately on interaction
- [ ] History view shows all periods in reverse chronological order with correct cycle lengths
- [ ] Average cycle length updates when a new period is logged
- [ ] Predictions shift accordingly when average cycle changes
- [ ] Insights content changes based on current phase
- [ ] Reset button clears all data and returns to onboarding
- [ ] App survives a force-quit and restores all data on reopen
- [ ] Calendar handles month/year transitions without bugs
- [ ] No crashes on first launch with empty database
