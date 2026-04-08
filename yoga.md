# Cycle Yoga — Mobile App Specification

A mobile-first yoga app that aligns yoga practice with the four phases of the menstrual cycle. Each phase includes recommended poses, breathwork, nutrition tips, YouTube practice videos, and things to avoid.

---

## Overview

The app helps users discover the right yoga practice based on where they are in their menstrual cycle. Users select their current cycle day (1–28) using a slider, and the app highlights their current phase with tailored recommendations.

---

## Tech Stack

- **Framework**: React (functional components with hooks)
- **Styling**: Inline styles / Tailwind CSS
- **Fonts**: `Cormorant Garamond` (display), `DM Sans` (body) — loaded from Google Fonts
- **Icons**: Inline SVGs (no icon library dependency)
- **External links**: YouTube search URLs open in new tabs
- **State management**: `useState` only (no external state library)
- **No backend required** — all data is hardcoded in a `phases` array

---

## App Structure

```
CycleYogaApp (root)
├── Header (title, tagline, animated emoji)
├── DaySelector (range slider, day number, phase labels)
├── TodayPhaseCard (highlighted current phase summary)
└── PhaseList
    └── PhaseSection (×4, accordion-style expandable)
        ├── Description
        ├── Hormone & Energy info cards (2-column grid)
        ├── PoseCard (×5 per phase, expandable)
        ├── VideoCard (×4 per phase, links to YouTube)
        ├── Breathwork card
        ├── "What to Avoid" card
        └── Nutrition card
```

---

## Data Model

Each phase object in the `phases` array has this shape:

```ts
interface Phase {
  id: string;             // "menstrual" | "follicular" | "ovulatory" | "luteal"
  name: string;           // Display name
  days: string;           // e.g. "Days 1–5"
  emoji: string;          // Phase emoji
  gradient: string;       // CSS gradient for active background
  accent: string;         // Hex accent color
  accentSoft: string;     // Accent with low opacity for backgrounds
  tagline: string;        // Short tagline e.g. "Rest & Release"
  hormone: string;        // Hormone description
  energy: string;         // Energy level description
  description: string;    // Full paragraph explanation
  poses: Pose[];          // 5 recommended poses
  breathwork: Breathwork; // 1 breathwork technique
  avoid: string[];        // List of things to avoid
  nutrition: string;      // Nutrition advice paragraph
  videos: Video[];        // 4 YouTube video links
}

interface Pose {
  name: string;     // Sanskrit name
  english: string;  // English name
  duration: string; // Hold time
  icon: string;     // Emoji
  benefit: string;  // Primary benefit
  how: string;      // Step-by-step instructions
}

interface Breathwork {
  name: string;
  description: string;
}

interface Video {
  title: string;     // Video title
  channel: string;   // YouTube channel name
  url: string;       // YouTube search URL
  duration: string;  // Approximate video length
  thumbnail: string; // Emoji thumbnail
}
```

---

## Phase Content (Complete Data)

### 1. Menstrual Phase — 🌙 "Rest & Release" (Days 1–5)

**Theme**: Inner winter. Lowest hormones. Prioritize rest, gentle movement, and introspection.

**Colors**: Purple gradient (`#1a0a2e` → `#4a2040`), accent `#c084fc`

**Hormones**: Estrogen & progesterone at their lowest. Uterine lining sheds.

**Energy**: Low — body is working hard internally.

**Poses**:

| # | Sanskrit | English | Duration | Benefit |
|---|----------|---------|----------|---------|
| 1 | Supta Baddha Konasana | Reclining Bound Angle Pose | 5–10 min | Opens hips/groin, relieves cramps, calms mind |
| 2 | Balasana | Supported Child's Pose | 3–5 min | Compresses abdomen to relieve cramps, calms nervous system |
| 3 | Supta Matsyendrasana | Supine Spinal Twist | 2–3 min/side | Relieves lower back tension, massages organs |
| 4 | Viparita Karani | Legs Up the Wall | 5–15 min | Reduces swelling, deeply calming, improves circulation |
| 5 | Savasana | Corpse Pose with Props | 10–15 min | Total nervous system reset |

**Breathwork**: Chandra Bhedana (Moon Breath) — Inhale left nostril, exhale right. 5–10 minutes. Cooling and calming.

**Avoid**: Intense core work, deep closed twists, prolonged inversions, hot yoga, power poses.

**Nutrition**: Warming iron-rich foods (soups, stews, dark leafy greens, beets, dark chocolate). Herbal teas (ginger, chamomile).

**Videos**:
- "Yoga for Cramps & PMS — Restorative" — Yoga With Adriene (20 min)
- "Gentle Yoga for Your Period" — Sarah Beth Yoga (15 min)
- "Restorative Yoga for Menstruation" — Yoga With Bird (25 min)
- "Legs Up the Wall — Guided Relaxation" — Yoga With Kassandra (10 min)

---

### 2. Follicular Phase — 🌱 "Build & Bloom" (Days 6–13)

**Theme**: Inner spring. Rising estrogen. Time to challenge yourself, try new poses, build strength.

**Colors**: Green gradient (`#0a2e1a` → `#204a3a`), accent `#34d399`

**Hormones**: Estrogen rises steadily. FSH stimulates follicle growth.

**Energy**: Rising — creative, social, physically capable.

**Poses**:

| # | Sanskrit | English | Duration | Benefit |
|---|----------|---------|----------|---------|
| 1 | Surya Namaskar | Sun Salutations (A & B) | 5–10 rounds | Full-body warm-up, builds heat and cardio endurance |
| 2 | Virabhadrasana III | Warrior III | 30–60 sec/side | Balance, core strength, focus |
| 3 | Bakasana | Crow Pose | 15–30 sec | Arm/core strength, builds confidence |
| 4 | Natarajasana | Dancer's Pose | 30 sec/side | Deep backbend, balance, opens chest/shoulders |
| 5 | Ustrasana | Camel Pose | 30–60 sec | Opens entire front body, energizing heart opener |

**Breathwork**: Kapalabhati (Skull-Shining Breath) — Short powerful exhales, passive inhales. 30 pumps × 3 rounds. Energizing.

**Avoid**: Being overly cautious, skipping warm-ups, ignoring alignment.

**Nutrition**: Light fresh foods (salads, fermented foods, lean proteins, sprouted grains, fresh fruits, cruciferous vegetables).

**Videos**:
- "Sun Salutation A & B — Full Tutorial" — Yoga With Adriene (15 min)
- "Power Vinyasa Flow — Build Strength" — Boho Beautiful (30 min)
- "Crow Pose Tutorial for Beginners" — Yoga With Kassandra (12 min)
- "Energizing Morning Yoga Flow" — Breathe and Flow (25 min)

---

### 3. Ovulatory Phase — 🔥 "Peak & Power" (Days 14–16)

**Theme**: Inner summer. Peak estrogen + testosterone spike. Maximum strength, confidence, social energy. Go all out.

**Colors**: Amber gradient (`#2e1a0a` → `#4a3520`), accent `#fb923c`

**Hormones**: Estrogen peaks. LH surge triggers ovulation.

**Energy**: Highest — magnetic, strong, communicative, confident.

**Poses**:

| # | Sanskrit | English | Duration | Benefit |
|---|----------|---------|----------|---------|
| 1 | Ashtanga Primary Series | Power Vinyasa Flow | 60–90 min | Full-body strength, endurance, mental discipline |
| 2 | Adho Mukha Vrksasana | Handstand | Practice attempts | Ultimate upper body/core strength, fearlessness |
| 3 | Eka Pada Koundinyasana II | Flying Splits | 15–30 sec/side | Arm balance combining strength, flexibility, courage |
| 4 | Urdhva Dhanurasana | Full Wheel Pose | 30 sec × 3 | Deep backbend, opens entire front body |
| 5 | Hanumanasana | Full Splits | 1–2 min/side | Deep hip flexor/hamstring opening |

**Breathwork**: Bhastrika (Bellows Breath) — Rapid forceful inhales AND exhales. 20 breaths × 3 rounds. Extremely energizing.

**Avoid**: Holding back, practicing in isolation, ignoring overexertion signs.

**Nutrition**: Lighter meals (raw vegetables, fruits, whole grains, anti-inflammatory foods, fiber-rich foods). Stay hydrated.

**Videos**:
- "Advanced Power Vinyasa Flow — 45 Min" — Travis Eliot (45 min)
- "Handstand Tutorial — Wall to Freestanding" — Dylan Werner Yoga (20 min)
- "Full Wheel Pose — Step by Step" — Yoga With Adriene (15 min)
- "Ashtanga Primary Series — Full Led Class" — Kino Yoga (75 min)

---

### 4. Luteal Phase — 🍂 "Slow & Soften" (Days 17–28)

**Theme**: Inner autumn. Progesterone dominates. Energy declines. PMS symptoms emerge. Slow down progressively.

**Colors**: Rose gradient (`#2e0a1a` → `#3a2040`), accent `#f472b6`

**Hormones**: Progesterone rises. If no implantation, both hormones drop sharply before menstruation.

**Energy**: Declining — early luteal still moderate, late luteal significantly lower. PMS symptoms appear.

**Poses**:

| # | Sanskrit | English | Duration | Benefit |
|---|----------|---------|----------|---------|
| 1 | Eka Pada Rajakapotasana | Pigeon Pose | 3–5 min/side | Deep hip opener, releases emotional tension |
| 2 | Paschimottanasana | Seated Forward Fold | 3–5 min | Calms nervous system, massages organs, reduces anxiety |
| 3 | Baddha Konasana | Bound Angle / Butterfly | 3–5 min | Opens inner thighs/groin, eases bloating |
| 4 | Utthan Pristhasana | Lizard Pose | 2–3 min/side | Deep hip flexor stretch, releases lower body tension |
| 5 | Setu Bandhasana | Supported Bridge | 5 min | Gentle backbend, opens chest, calms brain, reduces fatigue |

**Breathwork**: Nadi Shodhana (Alternate Nostril Breathing) — Inhale left, exhale right, inhale right, exhale left = 1 round. 10–15 rounds. Balances nervous system.

**Avoid**: Pushing for personal bests, hot yoga (body temp already elevated), ignoring cravings, comparing energy to other phases, intense core work if bloated.

**Nutrition**: Complex carbs (sweet potatoes, brown rice, oats). Magnesium-rich foods (dark chocolate, nuts, bananas). Calcium and B6. Reduce salt.

**Videos**:
- "Yin Yoga for PMS & Luteal Phase" — Yoga With Kassandra (30 min)
- "Deep Hip Opener — Pigeon Pose Flow" — Yoga With Adriene (20 min)
- "Yoga for Anxiety & Stress Relief" — Boho Beautiful (20 min)
- "Alternate Nostril Breathing — Guided" — Yoga With Adriene (8 min)

---

## UI/UX Specifications

### Layout
- **Max width**: 420px, centered
- **Background**: `#0c0a14` (near-black with slight purple)
- **Mobile-first**: Designed for phone screens

### Color System
Each phase has its own color palette:

| Phase | Gradient | Accent | Accent Soft |
|-------|----------|--------|-------------|
| Menstrual | `#1a0a2e → #4a2040` | `#c084fc` | `rgba(192,132,252,0.12)` |
| Follicular | `#0a2e1a → #204a3a` | `#34d399` | `rgba(52,211,153,0.12)` |
| Ovulatory | `#2e1a0a → #4a3520` | `#fb923c` | `rgba(251,146,60,0.12)` |
| Luteal | `#2e0a1a → #3a2040` | `#f472b6` | `rgba(244,114,182,0.12)` |

### Typography
- **Display**: Cormorant Garamond (700, serif) — headings, phase names, day number
- **Body**: DM Sans (400/500/600/700, sans-serif) — all other text
- **Section labels**: 10–11px, uppercase, letter-spacing 0.1–0.15em, accent colored

### Components

#### Day Selector
- Range input (1–28)
- Shows current day number in accent color
- Four phase labels below the slider, active phase highlighted
- Determines which phase is active via: days 1–5 = menstrual, 6–13 = follicular, 14–16 = ovulatory, 17–28 = luteal

#### Today's Phase Card
- Uses the active phase's gradient background
- Shows phase name, tagline, and energy description

#### Phase Accordion
- Collapsed: shows emoji, phase name, days badge, tagline, chevron
- Expanded: shows full content (description, hormones, energy, poses, videos, breathwork, avoid, nutrition)
- Only one phase open at a time

#### Pose Card (expandable)
- Collapsed: emoji icon, English name, Sanskrit name (italic, accent), duration with clock icon, chevron
- Expanded: benefit highlighted in accent-soft background, how-to instructions

#### Video Card (tappable link)
- Opens YouTube search URL in new tab
- Shows: emoji thumbnail with red play badge, title, channel name, duration, external link icon
- Hover/tap: background shifts to accent-soft, border highlights

#### Breathwork Card
- Accent-soft background, accent border
- Shows technique name and full description

#### Avoid Card
- Red-tinted background (`rgba(239,68,68,0.06)`)
- Each item prefixed with red ✕

#### Nutrition Card
- Subtle glass background (`rgba(255,255,255,0.04)`)
- Paragraph format

### Animations
- `fadeIn`: opacity 0→1 (0.3s)
- `slideDown`: opacity 0→1, translateY -10→0 (0.4s)
- `float`: translateY 0→-6→0 (3s infinite, ease-in-out) — header emoji only
- Transitions on accordion open/close: 0.4s cubic-bezier(0.4, 0, 0.2, 1)

### Inline SVG Icons Used
- ChevronDown / ChevronUp (accordion toggles)
- Clock (duration indicators)
- Play (YouTube badge — tiny white triangle)
- ExternalLink (YouTube card arrow)
- YouTube logo (red rounded rect with white play triangle)

---

## Video URL Pattern

Videos use YouTube search URLs so they always find the most relevant/current result:

```
https://www.youtube.com/results?search_query={encoded+search+terms}
```

Example: `https://www.youtube.com/results?search_query=yoga+with+adriene+cramps+pms+restorative`

---

## Key Implementation Notes

1. **No external dependencies** beyond React and Google Fonts
2. **All styling is inline** — no CSS files or Tailwind build needed
3. **Accordion is exclusive** — setting `activePhase` to a phase ID opens it, setting to `null` closes all
4. **Day slider controls phase detection** — `getCurrentPhase(day)` returns the phase ID
5. **Hover states on VideoCard** use `useState` for `hovered` boolean
6. **All data is static** — no API calls, no backend
7. **Responsive by constraint** — max-width 420px handles mobile sizing
8. **Accessibility**: buttons used for all interactive elements, semantic structure

---

## File Structure (if building as a standalone project)

```
cycle-yoga-app/
├── src/
│   ├── App.jsx          # Root CycleYogaApp component
│   ├── data/
│   │   └── phases.js    # Phases array (extract from component)
│   ├── components/
│   │   ├── Header.jsx
│   │   ├── DaySelector.jsx
│   │   ├── TodayCard.jsx
│   │   ├── PhaseSection.jsx
│   │   ├── PoseCard.jsx
│   │   ├── VideoCard.jsx
│   │   └── icons/       # SVG icon components
│   └── index.js
├── public/
│   └── index.html
├── package.json
└── README.md
```

---

## Optional Enhancements

- [ ] Persist selected cycle day in localStorage
- [ ] Add cycle tracking (start date input, auto-calculate current day)
- [ ] Embed YouTube videos inline with iframe instead of search links
- [ ] Add timer functionality for pose hold durations
- [ ] Push notifications for daily practice reminders
- [ ] Dark/light theme toggle
- [ ] Multi-language support
- [ ] Add illustrations or pose diagrams (SVG)
- [ ] Progress tracking (mark completed poses/sessions)
- [ ] Integrate with period tracking apps (Clue, Flo) via API
