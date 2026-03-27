import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/period_provider.dart';
import '../../core/providers/daily_log_provider.dart';

class InsightsView extends StatelessWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<PeriodProvider>();
    final lp = context.watch<DailyLogProvider>();
    final phase = pp.currentPhase;
    final cycleDay = pp.currentCycleDay;
    final avgCycle = pp.averageCycleLength;
    final logs = lp.allLogs;

    // Build cycle day → mood/symptom maps from logged data
    final cycleDayMoods = <int, Map<String, int>>{};
    final cycleDaySymptoms = <int, Map<String, int>>{};
    final cycleDayEnergy = <int, List<String>>{};

    for (final log in logs.values) {
      final cd = pp.getCycleDayForDate(log.date);
      // Moods
      for (final m in log.moods) {
        cycleDayMoods.putIfAbsent(cd, () => {});
        cycleDayMoods[cd]![m] = (cycleDayMoods[cd]![m] ?? 0) + 1;
      }
      // Symptoms
      for (final s in log.symptoms) {
        cycleDaySymptoms.putIfAbsent(cd, () => {});
        cycleDaySymptoms[cd]![s] = (cycleDaySymptoms[cd]![s] ?? 0) + 1;
      }
      // Medical energy
      if (log.medicalLog.containsKey('energy')) {
        cycleDayEnergy.putIfAbsent(cd, () => []);
        cycleDayEnergy[cd]!.add(log.medicalLog['energy']!);
      }
    }

    // Phase mood/symptom aggregation
    final phaseMoods = <CyclePhase, Map<String, int>>{};
    final phaseSymptoms = <CyclePhase, Map<String, int>>{};
    for (final p in CyclePhase.values) {
      phaseMoods[p] = {};
      phaseSymptoms[p] = {};
    }
    for (final log in logs.values) {
      final p = pp.getPhaseForDate(log.date);
      for (final m in log.moods) {
        phaseMoods[p]![m] = (phaseMoods[p]![m] ?? 0) + 1;
      }
      for (final s in log.symptoms) {
        phaseSymptoms[p]![s] = (phaseSymptoms[p]![s] ?? 0) + 1;
      }
    }

    // Weekly log score
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday % 7));
    int weekLogged = 0;
    for (int i = 0; i < 7; i++) {
      final d = weekStart.add(Duration(days: i));
      final ds = _fmt(d);
      if (lp.hasLog(ds)) weekLogged++;
    }
    final weekPct = (weekLogged / 7 * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cycle Insights', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 12),

        // 1. Phase Forecast (7-day)
        _PhaseForecast(periodProvider: pp),
        const SizedBox(height: 16),

        // 2. Cycle Comparison
        _CycleComparison(cycleDay: cycleDay, avgCycle: avgCycle, phase: phase),
        const SizedBox(height: 16),

        // 3. Fertile Intelligence
        _FertileIntel(periodProvider: pp),
        const SizedBox(height: 16),

        // 4. Weekly Score
        _WeeklyScore(weekPct: weekPct, weekLogged: weekLogged),
        const SizedBox(height: 16),

        // 5. Your Pattern Map
        if (_hasPhaseData(phaseMoods, phaseSymptoms)) ...[
          Text('YOUR PATTERN MAP', style: AppTextStyles.label),
          const SizedBox(height: 8),
          _PatternMap(phaseMoods: phaseMoods, phaseSymptoms: phaseSymptoms),
          const SizedBox(height: 16),
        ],

        // 6. Best & Worst Days
        if (cycleDayMoods.isNotEmpty) ...[
          Text('BEST & WORST CYCLE DAYS', style: AppTextStyles.label),
          const SizedBox(height: 8),
          _BestWorstDays(cycleDayMoods: cycleDayMoods, avgCycle: avgCycle),
          const SizedBox(height: 16),
        ],

        // 7. Symptom Forecast
        if (cycleDaySymptoms.isNotEmpty) ...[
          Text('SYMPTOM FORECAST', style: AppTextStyles.label),
          const SizedBox(height: 8),
          _SymptomForecast(
            cycleDaySymptoms: cycleDaySymptoms,
            currentDay: cycleDay,
            avgCycle: avgCycle,
          ),
          const SizedBox(height: 16),
        ],

        // 8. Personalized Tips
        Text('FOR YOU TODAY', style: AppTextStyles.label),
        const SizedBox(height: 8),
        _PersonalizedTips(
          phase: phase,
          cycleDay: cycleDay,
          phaseMoods: phaseMoods,
          phaseSymptoms: phaseSymptoms,
        ),
      ],
    );
  }

  bool _hasPhaseData(Map<CyclePhase, Map<String, int>> moods, Map<CyclePhase, Map<String, int>> symptoms) {
    return moods.values.any((m) => m.isNotEmpty) || symptoms.values.any((s) => s.isNotEmpty);
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// ─── 1. Phase Forecast ───

class _PhaseForecast extends StatelessWidget {
  final PeriodProvider periodProvider;
  const _PhaseForecast({required this.periodProvider});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.add(Duration(days: i)));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('7-Day Forecast', style: AppTextStyles.button.copyWith(color: AppColors.textPrimary, fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            children: days.map((d) {
              final ds = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
              final status = periodProvider.getDayStatus(ds);
              final phase = periodProvider.getPhaseForDate(ds);
              final isToday = d.day == today.day && d.month == today.month;

              return Expanded(
                child: Column(
                  children: [
                    Text(
                      DateFormat('E').format(d).substring(0, 2),
                      style: AppTextStyles.small.copyWith(
                        fontSize: 9,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                        color: isToday ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: status == 'period' || status == 'predicted-period'
                            ? AppColors.menstrual.withValues(alpha: status == 'period' ? 1 : 0.3)
                            : status == 'peak'
                                ? const Color(0xFFD4F5DC)
                                : status == 'fertile'
                                    ? AppColors.ovulationBg
                                    : AppColors.phaseBgColor(phase),
                        borderRadius: BorderRadius.circular(8),
                        border: isToday ? Border.all(color: AppColors.textPrimary, width: 1.5) : null,
                      ),
                      child: Center(
                        child: Text(
                          '${d.day}',
                          style: AppTextStyles.small.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: status == 'period' ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _phaseEmoji(phase, status),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _phaseEmoji(CyclePhase phase, String status) {
    if (status == 'period' || status == 'predicted-period') return '🩸';
    if (status == 'peak') return '⭐';
    if (status == 'fertile') return '🌿';
    switch (phase) {
      case CyclePhase.menstrual: return '🩸';
      case CyclePhase.follicular: return '🌱';
      case CyclePhase.ovulation: return '⭐';
      case CyclePhase.luteal: return '🌙';
    }
  }
}

// ─── 2. Cycle Comparison ───

class _CycleComparison extends StatelessWidget {
  final int cycleDay;
  final int avgCycle;
  final CyclePhase phase;

  const _CycleComparison({required this.cycleDay, required this.avgCycle, required this.phase});

  @override
  Widget build(BuildContext context) {
    final pct = (cycleDay / avgCycle * 100).round().clamp(0, 200);
    final isOverdue = cycleDay > avgCycle;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('📊', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Cycle Progress', style: AppTextStyles.button.copyWith(color: AppColors.textPrimary, fontSize: 13)),
              const Spacer(),
              Text(
                'Day $cycleDay / $avgCycle',
                style: AppTextStyles.small.copyWith(
                  color: isOverdue ? AppColors.menstrual : AppColors.phaseColor(phase),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: (cycleDay / avgCycle).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation(
                isOverdue ? AppColors.menstrual : AppColors.phaseColor(phase),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isOverdue
                ? '${cycleDay - avgCycle} days past your average. Period may arrive soon or cycle is longer this time.'
                : '${avgCycle - cycleDay} days remaining in this cycle. $pct% through.',
            style: AppTextStyles.small.copyWith(color: AppColors.textSecondary, height: 1.3),
          ),
        ],
      ),
    );
  }
}

// ─── 3. Fertile Intelligence ───

class _FertileIntel extends StatelessWidget {
  final PeriodProvider periodProvider;
  const _FertileIntel({required this.periodProvider});

  @override
  Widget build(BuildContext context) {
    final avg = periodProvider.averageCycleLength;
    final cycleDay = periodProvider.currentCycleDay;
    final ovDay = avg - 14;
    final fertileStart = avg - 18;
    final fertileEnd = avg - 12;
    final inWindow = periodProvider.isInFertileWindow;
    final daysToFertile = fertileStart - cycleDay;
    final daysToPeak = ovDay - cycleDay;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: inWindow ? const Color(0xFFF0FBF3) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: inWindow ? AppColors.ovulation.withValues(alpha: 0.3) : AppColors.cardBorder,
        ),
        boxShadow: const [BoxShadow(color: Color(0x0FA08CB0), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(inWindow ? '🔥' : '💚', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inWindow ? 'Fertile Window — Active' : 'Fertility Status',
                      style: AppTextStyles.button.copyWith(
                        color: inWindow ? AppColors.ovulation : AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Window: Days $fertileStart–$fertileEnd · Peak: Day $ovDay',
                      style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (inWindow)
            _intelRow('⭐', daysToPeak <= 0
                ? 'Today is around peak fertility — highest conception chance.'
                : 'Peak in $daysToPeak day${daysToPeak == 1 ? '' : 's'}. The day before ovulation has the highest conception rate (~30%).')
          else if (daysToFertile > 0)
            _intelRow('📅', 'Fertile window opens in $daysToFertile day${daysToFertile == 1 ? '' : 's'}. Sperm can survive 5 days — plan accordingly.')
          else
            _intelRow('🌙', 'Fertile window has passed for this cycle. Next window estimated in ${avg - cycleDay + fertileStart} days.'),
        ],
      ),
    );
  }

  Widget _intelRow(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyles.body.copyWith(fontSize: 11, height: 1.4))),
      ],
    );
  }
}

// ─── 4. Weekly Score ───

class _WeeklyScore extends StatelessWidget {
  final int weekPct;
  final int weekLogged;

  const _WeeklyScore({required this.weekPct, required this.weekLogged});

  @override
  Widget build(BuildContext context) {
    final color = weekPct >= 70 ? AppColors.ovulation : weekPct >= 40 ? const Color(0xFFD4A340) : AppColors.menstrual;
    final label = weekPct >= 70 ? 'Great' : weekPct >= 40 ? 'Fair' : 'Low';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: weekPct / 100,
                  strokeWidth: 4,
                  backgroundColor: AppColors.cardBorder,
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeCap: StrokeCap.round,
                ),
                Text('$weekPct', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800, fontSize: 13, color: color)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Weekly Log Score', style: AppTextStyles.button.copyWith(fontSize: 13, color: AppColors.textPrimary)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text(label, style: AppTextStyles.small.copyWith(fontSize: 8, color: color, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                Text('$weekLogged of 7 days logged this week', style: AppTextStyles.small.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 5. Pattern Map ───

class _PatternMap extends StatelessWidget {
  final Map<CyclePhase, Map<String, int>> phaseMoods;
  final Map<CyclePhase, Map<String, int>> phaseSymptoms;

  const _PatternMap({required this.phaseMoods, required this.phaseSymptoms});

  static const _moodEmoji = {
    'Happy': '😊', 'Sad': '😢', 'Tired': '😴', 'Irritable': '😤', 'Loving': '🥰',
    'Anxious': '😰', 'Calm': '😌', 'Energetic': '🤩', 'Stressed': '😖', 'Sleepy': '🥱',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(
        children: CyclePhase.values.map((phase) {
          final moods = (phaseMoods[phase]!.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(3);
          final symptoms = (phaseSymptoms[phase]!.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(3);
          if (moods.isEmpty && symptoms.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(color: AppColors.phaseColor(phase), shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 62,
                  child: Text(
                    AppColors.phaseName(phase).replaceAll(' Phase', ''),
                    style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w700, fontSize: 10),
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      ...moods.map((e) => _chip('${_moodEmoji[e.key] ?? ''}${e.key}', AppColors.phaseColor(phase))),
                      ...symptoms.map((e) => _chip(e.key, const Color(0xFF5BA4A4))),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: AppTextStyles.small.copyWith(fontSize: 8, color: color.withValues(alpha: 0.8))),
    );
  }
}

// ─── 6. Best & Worst Days ───

class _BestWorstDays extends StatelessWidget {
  final Map<int, Map<String, int>> cycleDayMoods;
  final int avgCycle;

  const _BestWorstDays({required this.cycleDayMoods, required this.avgCycle});

  static const _positive = {'Happy', 'Loving', 'Calm', 'Energetic', 'Confident', 'Grateful', 'Peaceful'};
  static const _negative = {'Sad', 'Tired', 'Irritable', 'Anxious', 'Stressed', 'Lonely', 'Overwhelmed', 'Numb', 'Sleepy'};

  @override
  Widget build(BuildContext context) {
    // Score each cycle day: positive moods - negative moods
    final dayScores = <int, int>{};
    for (final entry in cycleDayMoods.entries) {
      int score = 0;
      for (final m in entry.value.entries) {
        if (_positive.contains(m.key)) score += m.value;
        if (_negative.contains(m.key)) score -= m.value;
      }
      dayScores[entry.key] = score;
    }

    if (dayScores.isEmpty) return const SizedBox.shrink();

    final sorted = dayScores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final best = sorted.take(3).where((e) => e.value > 0).toList();
    final worst = sorted.reversed.take(3).where((e) => e.value < 0).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Best days
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('😊 Best days', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.ovulation)),
                const SizedBox(height: 6),
                if (best.isEmpty)
                  Text('Not enough data', style: AppTextStyles.small.copyWith(color: AppColors.textMuted))
                else
                  ...best.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(color: AppColors.ovulationBg, borderRadius: BorderRadius.circular(6)),
                          child: Center(child: Text('${e.key}', style: AppTextStyles.small.copyWith(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.ovulation))),
                        ),
                        const SizedBox(width: 6),
                        Text('Day ${e.key}', style: AppTextStyles.small.copyWith(fontSize: 10)),
                      ],
                    ),
                  )),
              ],
            ),
          ),
          Container(width: 1, height: 60, color: AppColors.cardBorder),
          const SizedBox(width: 12),
          // Worst days
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('😔 Tough days', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.menstrual)),
                const SizedBox(height: 6),
                if (worst.isEmpty)
                  Text('Not enough data', style: AppTextStyles.small.copyWith(color: AppColors.textMuted))
                else
                  ...worst.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(color: AppColors.menstrualBg, borderRadius: BorderRadius.circular(6)),
                          child: Center(child: Text('${e.key}', style: AppTextStyles.small.copyWith(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.menstrual))),
                        ),
                        const SizedBox(width: 6),
                        Text('Day ${e.key}', style: AppTextStyles.small.copyWith(fontSize: 10)),
                      ],
                    ),
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 7. Symptom Forecast ───

class _SymptomForecast extends StatelessWidget {
  final Map<int, Map<String, int>> cycleDaySymptoms;
  final int currentDay;
  final int avgCycle;

  const _SymptomForecast({required this.cycleDaySymptoms, required this.currentDay, required this.avgCycle});

  @override
  Widget build(BuildContext context) {
    // Find top symptom for upcoming 5 days
    final forecasts = <_ForecastItem>[];
    for (int d = currentDay; d < currentDay + 5 && d <= avgCycle; d++) {
      final syms = cycleDaySymptoms[d];
      if (syms != null && syms.isNotEmpty) {
        final top = (syms.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first;
        forecasts.add(_ForecastItem(day: d, symptom: top.key, count: top.value));
      }
    }

    if (forecasts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: AppDecorations.card,
        child: Text(
          'No symptom patterns found for the next few days. Keep logging to build predictions.',
          style: AppTextStyles.body.copyWith(fontSize: 11),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Based on your history, watch for:', style: AppTextStyles.small.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          ...forecasts.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 40,
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: f.day == currentDay ? AppColors.menstrualBg : AppColors.surfaceBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      f.day == currentDay ? 'Today' : 'Day ${f.day}',
                      style: AppTextStyles.small.copyWith(fontSize: 8, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${f.symptom} (seen ${f.count}x on this day)',
                    style: AppTextStyles.body.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _ForecastItem {
  final int day;
  final String symptom;
  final int count;
  const _ForecastItem({required this.day, required this.symptom, required this.count});
}

// ─── 8. Personalized Tips ───

class _PersonalizedTips extends StatelessWidget {
  final CyclePhase phase;
  final int cycleDay;
  final Map<CyclePhase, Map<String, int>> phaseMoods;
  final Map<CyclePhase, Map<String, int>> phaseSymptoms;

  const _PersonalizedTips({
    required this.phase,
    required this.cycleDay,
    required this.phaseMoods,
    required this.phaseSymptoms,
  });

  @override
  Widget build(BuildContext context) {
    final tips = _generateTips();

    return Column(
      children: tips.map((t) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: AppDecorations.card,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title, style: AppTextStyles.button.copyWith(color: AppColors.textPrimary, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(t.body, style: AppTextStyles.body.copyWith(fontSize: 11, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  List<_Tip> _generateTips() {
    final tips = <_Tip>[];
    final mySymptoms = phaseSymptoms[phase] ?? {};
    final myMoods = phaseMoods[phase] ?? {};
    final topSymptom = mySymptoms.isNotEmpty
        ? (mySymptoms.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key
        : null;
    final topMood = myMoods.isNotEmpty
        ? (myMoods.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key
        : null;

    // Phase tip
    tips.add(_phaseTip(phase));

    // Symptom-specific tip
    if (topSymptom != null) {
      tips.add(_symptomTip(topSymptom, phase));
    }

    // Mood-specific tip
    if (topMood != null) {
      tips.add(_moodTip(topMood, phase));
    }

    // Movement tip
    tips.add(_movementTip(phase));

    return tips;
  }

  _Tip _phaseTip(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return const _Tip(emoji: '🩸', title: 'Menstrual Phase', body: 'Rest is productive right now. Your body is doing important work. Honor the slowdown — it fuels the energy burst coming in your follicular phase.');
      case CyclePhase.follicular:
        return const _Tip(emoji: '🌱', title: 'Follicular Phase', body: 'Your brain is sharpest for learning and planning. Start that project, schedule important meetings, try something new. Estrogen is your superpower right now.');
      case CyclePhase.ovulation:
        return const _Tip(emoji: '⭐', title: 'Ovulation Phase', body: 'Peak communication and confidence. Great for presentations, difficult conversations, and social events. Your verbal fluency is literally higher right now.');
      case CyclePhase.luteal:
        return const _Tip(emoji: '🌙', title: 'Luteal Phase', body: 'Detail-oriented tasks suit this phase. Finish projects, organize, nest. Cravings are your body asking for serotonin — complex carbs deliver it naturally.');
    }
  }

  _Tip _symptomTip(String symptom, CyclePhase phase) {
    final phaseLabel = AppColors.phaseName(phase).replaceAll(' Phase', '').toLowerCase();
    switch (symptom) {
      case 'Cramps':
        return _Tip(emoji: '🫙', title: 'Your cramps pattern', body: 'You tend to get cramps during your $phaseLabel phase. Pre-load with magnesium 2-3 days before. A heating pad at 104°F for 20 min is as effective as ibuprofen.');
      case 'Headache':
        return _Tip(emoji: '💧', title: 'Headache alert', body: 'Headaches are common for you in the $phaseLabel phase. Start hydrating extra today — dehydration + hormone shifts are the #1 combo trigger.');
      case 'Fatigue':
        return _Tip(emoji: '🔋', title: 'Energy management', body: 'Fatigue peaks for you during $phaseLabel. Schedule lighter workloads if possible. Iron-rich snacks (pumpkin seeds, dark chocolate) help more than caffeine.');
      case 'Bloating':
        return _Tip(emoji: '🫧', title: 'Bloating season', body: 'Your $phaseLabel bloating pattern suggests fluid retention. Cut sodium today, add potassium (banana, avocado), and try warm lemon water in the morning.');
      default:
        return _Tip(emoji: '📋', title: 'Track it', body: '$symptom is your most common symptom in the $phaseLabel phase. Consistent logging helps identify what triggers it and what relieves it.');
    }
  }

  _Tip _moodTip(String mood, CyclePhase phase) {
    switch (mood) {
      case 'Tired': case 'Sleepy':
        return const _Tip(emoji: '😴', title: 'Rest is data', body: 'You frequently feel tired in this phase. That\'s not laziness — it\'s progesterone. Go to bed 30 min earlier tonight. Your body will thank you tomorrow.');
      case 'Anxious': case 'Stressed':
        return const _Tip(emoji: '🧘', title: 'Calm your nervous system', body: 'Anxiety tends to spike for you right now. Try box breathing (4-4-4-4) for 2 minutes. Magnesium glycinate before bed helps. Reduce caffeine by 50% this phase.');
      case 'Sad': case 'Lonely':
        return const _Tip(emoji: '💛', title: 'Be gentle with yourself', body: 'Lower mood is common in this phase for you. It\'s hormonal, not personal. Reach out to someone you trust. Omega-3 and sunlight are natural mood lifters.');
      case 'Happy': case 'Energetic': case 'Confident':
        return const _Tip(emoji: '✨', title: 'Ride the wave', body: 'You feel great in this phase! Use this energy wisely — schedule important decisions, social events, and challenging workouts now.');
      default:
        return _Tip(emoji: '🧠', title: 'Mood insight', body: 'Your dominant mood in this phase is $mood. Tracking this pattern helps you plan your week around your cycle\'s natural rhythm.');
    }
  }

  _Tip _movementTip(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return const _Tip(emoji: '🚶‍♀️', title: 'Movement', body: 'Gentle walks, yin yoga, or light stretching. Even 10 minutes improves cramp pain by increasing blood flow. Don\'t push — listen to your body.');
      case CyclePhase.follicular:
        return const _Tip(emoji: '🏃‍♀️', title: 'Movement', body: 'Energy is climbing — try HIIT, strength training, or a new fitness class. Your muscles recover faster and you build strength more efficiently in this phase.');
      case CyclePhase.ovulation:
        return const _Tip(emoji: '💪', title: 'Movement', body: 'Peak performance window. Go for PRs, group classes, or competitive sports. Your pain tolerance is highest and reaction times are fastest.');
      case CyclePhase.luteal:
        return const _Tip(emoji: '🧘‍♀️', title: 'Movement', body: 'Moderate intensity — Pilates, swimming, steady cycling. High cortisol + intense exercise = worse PMS. Gentle consistency beats hard sessions this week.');
    }
  }
}

class _Tip {
  final String emoji;
  final String title;
  final String body;
  const _Tip({required this.emoji, required this.title, required this.body});
}
