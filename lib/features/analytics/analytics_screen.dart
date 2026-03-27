import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/period_provider.dart';
import '../../core/providers/daily_log_provider.dart';
import '../../core/providers/settings_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<PeriodProvider>();
    final lp = context.watch<DailyLogProvider>();
    final sp = context.watch<SettingsProvider>();
    final userAge = sp.userAge;
    final periods = pp.periods;
    final cycleLengths = pp.cycleLengths;
    final periodDurations = pp.periodDurations;
    final avgCycle = pp.averageCycleLength;
    final avgPeriod = pp.averagePeriodLength;
    final logs = lp.allLogs;

    // Stats
    final shortestCycle = cycleLengths.isNotEmpty ? cycleLengths.reduce(min) : null;
    final longestCycle = cycleLengths.isNotEmpty ? cycleLengths.reduce(max) : null;
    final shortestPeriod = periodDurations.isNotEmpty ? periodDurations.reduce(min) : null;
    final longestPeriod = periodDurations.isNotEmpty ? periodDurations.reduce(max) : null;
    final stdDev = _stdDev(cycleLengths);

    // Tracking stats
    final totalLogDays = logs.values.where((l) => l.hasData).length;
    final firstPeriod = periods.isNotEmpty ? DateTime.parse(periods.first.startDate) : null;
    final trackingDays = firstPeriod != null
        ? DateTime.now().difference(firstPeriod).inDays + 1
        : 0;
    final logRate = trackingDays > 0 ? (totalLogDays / trackingDays * 100).round() : 0;

    // Flow stats
    int lightCount = 0, mediumCount = 0, heavyCount = 0;
    for (final log in logs.values) {
      if (log.flow == 'light') {
        lightCount++;
      } else if (log.flow == 'medium') {
        mediumCount++;
      } else if (log.flow == 'heavy') {
        heavyCount++;
      }
    }
    final totalFlow = lightCount + mediumCount + heavyCount;

    // Mood stats
    final moodCounts = <String, int>{};
    for (final log in logs.values) {
      for (final m in log.moods) {
        moodCounts[m] = (moodCounts[m] ?? 0) + 1;
      }
    }
    final sortedMoods = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Symptom stats
    final symptomCounts = <String, int>{};
    for (final log in logs.values) {
      for (final s in log.symptoms) {
        symptomCounts[s] = (symptomCounts[s] ?? 0) + 1;
      }
    }
    final sortedSymptoms = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Phase distribution of moods (which moods in which phase)
    final phaseMoodMap = <CyclePhase, Map<String, int>>{};
    for (final phase in CyclePhase.values) {
      phaseMoodMap[phase] = {};
    }
    for (final log in logs.values) {
      if (log.moods.isEmpty) continue;
      final phase = pp.getPhaseForDate(log.date);
      for (final m in log.moods) {
        phaseMoodMap[phase]![m] = (phaseMoodMap[phase]![m] ?? 0) + 1;
      }
    }

    // Phase distribution of symptoms
    final phaseSymptomMap = <CyclePhase, Map<String, int>>{};
    for (final phase in CyclePhase.values) {
      phaseSymptomMap[phase] = {};
    }
    for (final log in logs.values) {
      if (log.symptoms.isEmpty) continue;
      final phase = pp.getPhaseForDate(log.date);
      for (final s in log.symptoms) {
        phaseSymptomMap[phase]![s] = (phaseSymptomMap[phase]![s] ?? 0) + 1;
      }
    }

    // Medical checklist aggregation
    final medicalAgg = <String, Map<String, int>>{};
    int medicalDays = 0;
    for (final log in logs.values) {
      if (log.medicalLog.isEmpty) continue;
      medicalDays++;
      for (final entry in log.medicalLog.entries) {
        medicalAgg.putIfAbsent(entry.key, () => {});
        medicalAgg[entry.key]![entry.value] = (medicalAgg[entry.key]![entry.value] ?? 0) + 1;
      }
    }

    // Day of week distribution (which day do periods start)
    final dayOfWeekCounts = List.filled(7, 0);
    for (final p in periods) {
      final dow = DateTime.parse(p.startDate).weekday % 7; // 0=Sun
      dayOfWeekCounts[dow]++;
    }

    // Month distribution
    final monthCounts = List.filled(12, 0);
    for (final p in periods) {
      monthCounts[DateTime.parse(p.startDate).month - 1]++;
    }

    // Cycle length trend (per cycle)
    final cycleTrendData = <_TrendPoint>[];
    for (int i = 0; i < cycleLengths.length; i++) {
      cycleTrendData.add(_TrendPoint(index: i, value: cycleLengths[i].toDouble()));
    }

    // Period duration trend
    final periodTrendData = <_TrendPoint>[];
    for (int i = 0; i < periodDurations.length; i++) {
      periodTrendData.add(_TrendPoint(index: i, value: periodDurations[i].toDouble()));
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Analytics', style: AppTextStyles.appTitle),
            const SizedBox(height: 4),
            Text(
              'Deep dive into your data',
              style: AppTextStyles.body.copyWith(color: AppColors.textLight),
            ),
            const SizedBox(height: 20),

            // ─── OVERVIEW ───
            Text('OVERVIEW', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Row(
              children: [
                _Stat(label: 'Tracking', value: '$trackingDays', unit: 'days'),
                _Stat(label: 'Periods', value: '${periods.length}', unit: 'logged'),
                _Stat(label: 'Log rate', value: '$logRate', unit: '%'),
                if (userAge != null)
                  _Stat(label: 'Age', value: '$userAge', unit: 'y/o', color: AppColors.luteal)
                else
                  _Stat(label: 'Log days', value: '$totalLogDays', unit: 'total'),
              ],
            ),

            // Age-based insight
            if (userAge != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.lutealBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.luteal.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_ageEmoji(userAge), style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _ageInsight(userAge, avgCycle),
                        style: AppTextStyles.body.copyWith(fontSize: 11, height: 1.4, color: AppColors.luteal),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // ─── CYCLE LENGTH ───
            Text('CYCLE LENGTH', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Row(
              children: [
                _Stat(label: 'Average', value: '$avgCycle', unit: 'd', color: AppColors.follicular),
                _Stat(label: 'Shortest', value: '${shortestCycle ?? '—'}', unit: 'd', color: AppColors.ovulation),
                _Stat(label: 'Longest', value: '${longestCycle ?? '—'}', unit: 'd', color: AppColors.luteal),
                _Stat(label: 'Std Dev', value: stdDev != null ? stdDev.toStringAsFixed(1) : '—', unit: 'd', color: AppColors.menstrual),
              ],
            ),
            if (cycleTrendData.length >= 2) ...[
              const SizedBox(height: 8),
              _TrendChart(
                data: cycleTrendData,
                average: avgCycle.toDouble(),
                color: AppColors.follicular,
                height: 100,
                label: 'Cycle length over time',
              ),
            ],
            const SizedBox(height: 20),

            // ─── PERIOD DURATION ───
            Text('PERIOD DURATION', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Row(
              children: [
                _Stat(label: 'Average', value: '$avgPeriod', unit: 'd', color: AppColors.menstrual),
                _Stat(label: 'Shortest', value: '${shortestPeriod ?? '—'}', unit: 'd'),
                _Stat(label: 'Longest', value: '${longestPeriod ?? '—'}', unit: 'd'),
                _Stat(label: 'Range', value: shortestPeriod != null ? '${longestPeriod! - shortestPeriod}' : '—', unit: 'd'),
              ],
            ),
            if (periodTrendData.length >= 2) ...[
              const SizedBox(height: 8),
              _TrendChart(
                data: periodTrendData,
                average: avgPeriod.toDouble(),
                color: AppColors.menstrual,
                height: 80,
                label: 'Period duration over time',
              ),
            ],
            const SizedBox(height: 20),

            // ─── FLOW DISTRIBUTION ───
            if (totalFlow > 0) ...[
              Text('FLOW DISTRIBUTION', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _FlowDistribution(light: lightCount, medium: mediumCount, heavy: heavyCount),
              const SizedBox(height: 20),
            ],

            // ─── MOOD HEATMAP ───
            if (sortedMoods.isNotEmpty) ...[
              Text('MOOD FREQUENCY', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _RankedList(
                items: sortedMoods.take(10).toList(),
                color: AppColors.luteal,
                emojis: _moodEmojis,
              ),
              const SizedBox(height: 12),
              // Mood by phase
              Text('MOOD × PHASE', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _PhaseCorrelation(phaseMap: phaseMoodMap, emojis: _moodEmojis),
              const SizedBox(height: 20),
            ],

            // ─── SYMPTOM FREQUENCY ───
            if (sortedSymptoms.isNotEmpty) ...[
              Text('SYMPTOM FREQUENCY', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _RankedList(
                items: sortedSymptoms.take(8).toList(),
                color: const Color(0xFF5BA4A4),
              ),
              const SizedBox(height: 12),
              // Symptom by phase
              Text('SYMPTOM × PHASE', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _PhaseCorrelation(phaseMap: phaseSymptomMap),
              const SizedBox(height: 20),
            ],

            // ─── DAY OF WEEK ───
            if (periods.length >= 3) ...[
              Text('PERIOD START DAY', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _DayOfWeekChart(counts: dayOfWeekCounts),
              const SizedBox(height: 20),
            ],

            // ─── MONTH DISTRIBUTION ───
            if (periods.length >= 3) ...[
              Text('PERIODS BY MONTH', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _MonthChart(counts: monthCounts),
              const SizedBox(height: 20),
            ],

            // ─── MEDICAL CHECKLIST ───
            if (medicalAgg.isNotEmpty) ...[
              Text('MEDICAL CHECKLIST ($medicalDays days)', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _MedicalGrid(data: medicalAgg),
              const SizedBox(height: 20),
            ],

            // ─── RAW DATA TABLE ───
            if (cycleLengths.isNotEmpty) ...[
              Text('CYCLE DATA TABLE', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _DataTable(periods: periods, cycleLengths: cycleLengths),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  double? _stdDev(List<int> values) {
    if (values.length < 2) return null;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final sumSqDiff = values.fold<double>(0, (sum, v) => sum + (v - mean) * (v - mean));
    return sqrt(sumSqDiff / (values.length - 1));
  }

  String _ageEmoji(int age) {
    if (age < 18) return '🌱';
    if (age < 25) return '🌸';
    if (age < 35) return '💐';
    if (age < 45) return '🌻';
    return '🍂';
  }

  String _ageInsight(int age, int avgCycle) {
    if (age < 18) {
      return 'At $age, cycles are often irregular as your body is still maturing. Variation of 7+ days between cycles is normal during adolescence.';
    } else if (age < 25) {
      return 'At $age, your cycles are typically stabilizing. An average of $avgCycle days is ${avgCycle >= 24 && avgCycle <= 32 ? 'right on track' : 'worth monitoring'}. This is when patterns become most predictable.';
    } else if (age < 35) {
      return 'At $age, cycles are usually at their most regular. Your $avgCycle-day average ${avgCycle >= 24 && avgCycle <= 35 ? 'is healthy' : 'may be worth discussing with your doctor'}. Peak fertility years — iron and folate are extra important.';
    } else if (age < 45) {
      return 'At $age, subtle hormonal shifts are normal. Cycles may start to shorten or become less predictable. A $avgCycle-day cycle is ${avgCycle >= 21 ? 'within range' : 'on the shorter side — track closely'}.';
    } else {
      return 'At $age, perimenopause may be affecting your cycles. Longer, shorter, or skipped cycles are common. Track patterns to share with your healthcare provider.';
    }
  }

  static const _moodEmojis = {
    'Happy': '😊', 'Sad': '😢', 'Tired': '😴', 'Irritable': '😤',
    'Loving': '🥰', 'Anxious': '😰', 'Calm': '😌', 'Grateful': '🤗',
    'Lonely': '😔', 'Sick': '🤒', 'Angry': '😤', 'Sensitive': '🥺',
    'Energetic': '🤩', 'Numb': '😶', 'Stressed': '😖', 'Sleepy': '🥱',
    'Meh': '🫠', 'Confident': '💪', 'Peaceful': '😇', 'Overwhelmed': '🤯',
  };
}

// ─── Compact stat chip ───
class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color? color;

  const _Stat({required this.label, required this.value, required this.unit, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: AppDecorations.card,
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.mediumNumber.copyWith(
                fontSize: 18,
                color: color ?? AppColors.textPrimary,
              ),
            ),
            Text(unit, style: AppTextStyles.small.copyWith(fontSize: 8, color: AppColors.textMuted)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.small.copyWith(fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

// ─── Trend line chart ───
class _TrendPoint {
  final int index;
  final double value;
  const _TrendPoint({required this.index, required this.value});
}

class _TrendChart extends StatelessWidget {
  final List<_TrendPoint> data;
  final double average;
  final Color color;
  final double height;
  final String label;

  const _TrendChart({
    required this.data,
    required this.average,
    required this.color,
    required this.height,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppTextStyles.small.copyWith(color: AppColors.textSecondary))),
              Text('avg ${average.round()}', style: AppTextStyles.small.copyWith(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: height,
            child: CustomPaint(
              size: Size.infinite,
              painter: _TrendPainter(data: data, average: average, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<_TrendPoint> data;
  final double average;
  final Color color;

  _TrendPainter({required this.data, required this.average, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final minVal = data.map((d) => d.value).reduce(min) - 2;
    final maxVal = data.map((d) => d.value).reduce(max) + 2;
    final range = maxVal - minVal;

    double toY(double v) => size.height - ((v - minVal) / range * size.height);
    double toX(int i) => data.length == 1 ? size.width / 2 : i / (data.length - 1) * size.width;

    // Average line
    final avgPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final dashPath = Path()
      ..moveTo(0, toY(average))
      ..lineTo(size.width, toY(average));
    canvas.drawPath(dashPath, avgPaint);

    // Fill area
    final fillPath = Path()..moveTo(toX(0), size.height);
    for (int i = 0; i < data.length; i++) {
      fillPath.lineTo(toX(i), toY(data[i].value));
    }
    fillPath.lineTo(toX(data.length - 1), size.height);
    fillPath.close();
    final fillPaint = Paint()..color = color.withValues(alpha: 0.08);
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = toX(i);
      final y = toY(data[i].value);
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Dots
    final dotPaint = Paint()..color = color;
    final dotBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 0; i < data.length; i++) {
      final c = Offset(toX(i), toY(data[i].value));
      canvas.drawCircle(c, 4, dotPaint);
      canvas.drawCircle(c, 4, dotBorder);
    }

  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) => old.data != data;
}

// ─── Flow distribution bar ───
class _FlowDistribution extends StatelessWidget {
  final int light, medium, heavy;
  const _FlowDistribution({required this.light, required this.medium, required this.heavy});

  @override
  Widget build(BuildContext context) {
    final total = light + medium + heavy;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 20,
              child: Row(
                children: [
                  if (light > 0)
                    Expanded(
                      flex: light,
                      child: Container(color: AppColors.menstrual.withValues(alpha: 0.3)),
                    ),
                  if (medium > 0)
                    Expanded(
                      flex: medium,
                      child: Container(color: AppColors.menstrual.withValues(alpha: 0.55)),
                    ),
                  if (heavy > 0)
                    Expanded(
                      flex: heavy,
                      child: Container(color: AppColors.menstrual.withValues(alpha: 0.85)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _flowLabel('💧 Light', light, total),
              _flowLabel('💧💧 Medium', medium, total),
              _flowLabel('💧💧💧 Heavy', heavy, total),
            ],
          ),
        ],
      ),
    );
  }

  Widget _flowLabel(String label, int count, int total) {
    final pct = total > 0 ? (count / total * 100).round() : 0;
    return Column(
      children: [
        Text('$pct%', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.menstrual, fontSize: 13)),
        Text(label, style: AppTextStyles.small.copyWith(fontSize: 9)),
        Text('$count days', style: AppTextStyles.small.copyWith(fontSize: 8, color: AppColors.textMuted)),
      ],
    );
  }
}

// ─── Ranked list (moods/symptoms) ───
class _RankedList extends StatelessWidget {
  final List<MapEntry<String, int>> items;
  final Color color;
  final Map<String, String>? emojis;

  const _RankedList({required this.items, required this.color, this.emojis});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final maxCount = items.first.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final rank = entry.key;
          final item = entry.value;
          final pct = item.value / maxCount;
          final emoji = emojis?[item.key];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  child: Text(
                    '${rank + 1}',
                    style: AppTextStyles.small.copyWith(
                      fontWeight: FontWeight.w700,
                      color: rank == 0 ? color : AppColors.textMuted,
                    ),
                  ),
                ),
                if (emoji != null) ...[
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                ],
                SizedBox(
                  width: 85,
                  child: Text(
                    item.key,
                    style: AppTextStyles.body.copyWith(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: AppColors.cardBorder,
                      valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.3 + pct * 0.7)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 22,
                  child: Text(
                    '${item.value}',
                    style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Phase correlation matrix ───
class _PhaseCorrelation extends StatelessWidget {
  final Map<CyclePhase, Map<String, int>> phaseMap;
  final Map<String, String>? emojis;

  const _PhaseCorrelation({required this.phaseMap, this.emojis});

  @override
  Widget build(BuildContext context) {
    // Get top item per phase
    final phaseTop = <CyclePhase, List<MapEntry<String, int>>>{};
    for (final phase in CyclePhase.values) {
      final sorted = phaseMap[phase]!.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      phaseTop[phase] = sorted.take(3).toList();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(
        children: CyclePhase.values.map((phase) {
          final items = phaseTop[phase]!;
          if (items.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: AppColors.phaseColor(phase),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: Text(
                    AppColors.phaseName(phase).replaceAll(' Phase', ''),
                    style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: items.map((e) {
                      final emoji = emojis?[e.key] ?? '';
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.phaseColor(phase).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$emoji${e.key} ×${e.value}',
                          style: AppTextStyles.small.copyWith(fontSize: 9, color: AppColors.textSecondary),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Day of week chart ───
class _DayOfWeekChart extends StatelessWidget {
  final List<int> counts;
  const _DayOfWeekChart({required this.counts});

  @override
  Widget build(BuildContext context) {
    final maxCount = counts.reduce(max).clamp(1, 999);
    const days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final h = counts[i] / maxCount * 60;
          final isMax = counts[i] == maxCount && counts[i] > 0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${counts[i]}',
                    style: AppTextStyles.small.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isMax ? AppColors.luteal : AppColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: h.clamp(2.0, 60.0),
                    decoration: BoxDecoration(
                      color: isMax ? AppColors.luteal : AppColors.luteal.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(days[i], style: AppTextStyles.small.copyWith(fontSize: 9)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Month chart ───
class _MonthChart extends StatelessWidget {
  final List<int> counts;
  const _MonthChart({required this.counts});

  @override
  Widget build(BuildContext context) {
    final maxCount = counts.reduce(max).clamp(1, 999);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: SizedBox(
        height: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(12, (i) {
            final h = counts[i] / maxCount * 55;
            final isMax = counts[i] == maxCount && counts[i] > 0;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (counts[i] > 0)
                      Text(
                        '${counts[i]}',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                          color: isMax ? AppColors.follicular : AppColors.textMuted,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Container(
                      height: h.clamp(2.0, 55.0),
                      decoration: BoxDecoration(
                        color: isMax ? AppColors.follicular : AppColors.follicular.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(months[i], style: const TextStyle(fontSize: 7, color: AppColors.textMuted)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Raw data table ───
class _MedicalGrid extends StatelessWidget {
  final Map<String, Map<String, int>> data;
  const _MedicalGrid({required this.data});

  static const _labels = {
    'pain_level': '😣 Pain', 'discharge_color': '🔬 Discharge', 'discharge_consistency': '💧 Type',
    'weight': '⚖️ Weight', 'skin': '✨ Skin', 'hair': '💇‍♀️ Hair', 'sleep': '😴 Sleep',
    'libido': '💕 Libido', 'digestion': '🫃 Digestion', 'breast': '🩱 Breast', 'energy': '⚡ Energy',
  };

  static const _warnings = {
    'pain_level': {'Severe', 'Unbearable'}, 'discharge_color': {'Green', 'Yellow'},
    'hair': {'Thinning', 'Excess body hair'}, 'sleep': {'Insomnia'},
    'breast': {'Lumpy'}, 'energy': {'Exhausted'},
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(
        children: data.entries.map((entry) {
          final label = _labels[entry.key] ?? entry.key;
          final counts = entry.value;
          final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
          final total = sorted.fold<int>(0, (s, e) => s + e.value);
          if (total == 0) return const SizedBox.shrink();

          // Dominant answer
          final dominant = sorted.first;
          final pct = (dominant.value / total * 100).round();
          final isWarn = _warnings[entry.key]?.contains(dominant.key) ?? false;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(label, style: AppTextStyles.small.copyWith(fontSize: 9, fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        children: sorted.map((opt) {
                          final w = _warnings[entry.key]?.contains(opt.key) ?? false;
                          return Expanded(
                            flex: opt.value,
                            child: Container(
                              color: w
                                  ? AppColors.menstrual.withValues(alpha: 0.5)
                                  : AppColors.follicular.withValues(alpha: 0.15 + (opt.value / total) * 0.5),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 62,
                  child: Text(
                    '${dominant.key} $pct%',
                    style: AppTextStyles.small.copyWith(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: isWarn ? AppColors.menstrual : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DataTable extends StatelessWidget {
  final List periods;
  final List<int> cycleLengths;

  const _DataTable({required this.periods, required this.cycleLengths});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          // Header
          Row(
            children: [
              _cell('#', isHeader: true, width: 24),
              _cell('Start', isHeader: true, flex: 1),
              _cell('End', isHeader: true, flex: 1),
              _cell('Dur', isHeader: true, width: 32),
              _cell('Cycle', isHeader: true, width: 38),
            ],
          ),
          const Divider(height: 8, color: AppColors.cardBorder),
          ...List.generate(periods.length, (i) {
            final p = periods[periods.length - 1 - i]; // reverse chronological
            final idx = periods.length - i;
            final cycleIdx = periods.length - 1 - i - 1;
            final cycleLen = cycleIdx >= 0 && cycleIdx < cycleLengths.length
                ? '${cycleLengths[cycleIdx]}'
                : '—';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  _cell('$idx', width: 24, color: AppColors.textMuted),
                  _cell(DateFormat('MMM d').format(DateTime.parse(p.startDate)), flex: 1),
                  _cell(DateFormat('MMM d').format(DateTime.parse(p.endDate)), flex: 1),
                  _cell('${p.durationDays}d', width: 32, color: AppColors.menstrual),
                  _cell(cycleLen, width: 38, color: AppColors.follicular),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _cell(String text, {bool isHeader = false, int? width, int? flex, Color? color}) {
    final widget = Text(
      text,
      style: isHeader
          ? AppTextStyles.label.copyWith(fontSize: 9)
          : AppTextStyles.small.copyWith(
              fontSize: 10,
              color: color ?? AppColors.textSecondary,
              fontWeight: color != null ? FontWeight.w700 : FontWeight.w500,
            ),
      textAlign: TextAlign.center,
    );
    if (flex != null) return Expanded(flex: flex, child: widget);
    return SizedBox(width: width?.toDouble(), child: widget);
  }
}
