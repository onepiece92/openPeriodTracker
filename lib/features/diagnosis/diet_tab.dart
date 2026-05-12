import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/period_provider.dart';
import '../../core/providers/daily_log_provider.dart';
import '../../core/providers/settings_provider.dart';
import 'diet_data.dart';

class DietTab extends StatelessWidget {
  final CyclePhase phase;
  final String region;
  final String location;
  final PeriodProvider periodProvider;
  final DailyLogProvider logProvider;

  const DietTab({
    super.key,
    required this.phase,
    required this.region,
    required this.location,
    required this.periodProvider,
    required this.logProvider,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final exclusions = exclusionsFor(settings.dietType, settings.allergies);

    final diet = _getDietData(phase, region);
    final logs = logProvider.allLogs;
    final deficiencyRisks = _getDeficiencyRisks(logs);
    final macros = macrosByPhase[phase]!;
    final hydration = hydrationByPhase[phase]!;
    final supplements = supplementsByPhase[phase]!;

    // Apply dietary-preference filters to the food lists. Vitamins / avoid /
    // supplements are unfiltered — they're descriptions, not specific foods
    // the user would eat directly.
    final filteredFoods = (diet['foods'] as List<Map<String, String>>)
        .where((f) => !foodIsExcluded(f['name']!, exclusions))
        .toList();
    final filteredLocal = (diet['local'] as List<Map<String, String>>)
        .where((l) => !foodIsExcluded(l['name']!, exclusions))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phase context
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.phaseBgColor(phase),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.phaseColor(phase).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Text('🍽️', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diet for ${AppColors.phaseName(phase)}',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        diet['summary'] as String,
                        style: AppTextStyles.body.copyWith(height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Nutrient deficiency risks (from symptoms)
          if (deficiencyRisks.isNotEmpty) ...[
            Text(
              'NUTRIENT GAPS (FROM YOUR SYMPTOMS)',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFD4A340).withValues(alpha: 0.2),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0FA08CB0),
                    blurRadius: 12,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: deficiencyRisks
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r['emoji']!,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        r['nutrient']!,
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFD4A340,
                                          ).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          'from: ${r['symptom']}',
                                          style: AppTextStyles.small.copyWith(
                                            fontSize: 8,
                                            color: const Color(0xFFD4A340),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    r['fix']!,
                                    style: AppTextStyles.small.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Macro balance
          Text('MACRO BALANCE', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.card,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 18,
                    child: Row(
                      children: [
                        Expanded(
                          flex: macros['carb']!,
                          child: Container(
                            color: AppColors.follicular.withValues(alpha: 0.5),
                          ),
                        ),
                        Expanded(
                          flex: macros['protein']!,
                          child: Container(
                            color: AppColors.menstrual.withValues(alpha: 0.5),
                          ),
                        ),
                        Expanded(
                          flex: macros['fat']!,
                          child: Container(
                            color: AppColors.luteal.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _macroLabel(
                      '🍞 Carbs',
                      macros['carb']!,
                      AppColors.follicular,
                    ),
                    _macroLabel(
                      '🥩 Protein',
                      macros['protein']!,
                      AppColors.menstrual,
                    ),
                    _macroLabel('🥑 Fat', macros['fat']!, AppColors.luteal),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Hydration
          Text('HYDRATION', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.card,
            child: Row(
              children: [
                const Text('💧', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hydration['amount']!,
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.follicular,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hydration['tip']!,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Supplements
          Text('SUPPLEMENT GUIDE', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: AppDecorations.card,
            child: Column(
              children: supplements
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(
                            s['emoji']!,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s['name']!,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            s['dose']!,
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.follicular,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Key Vitamins & Minerals
          Text('KEY VITAMINS & MINERALS', style: AppTextStyles.label),
          const SizedBox(height: 8),
          ...(diet['vitamins'] as List<Map<String, String>>).map(
            (v) => _NutrientCard(
              emoji: v['emoji']!,
              name: v['name']!,
              benefit: v['benefit']!,
              sources: v['sources']!,
            ),
          ),
          const SizedBox(height: 16),

          // Recommended Foods
          Text('RECOMMENDED FOODS', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.card,
            child: filteredFoods.isEmpty
                ? Text(
                    'All defaults excluded by your dietary preferences. '
                    'Adjust them in Profile → Dietary Preferences.',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textMuted,
                    ),
                  )
                : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredFoods
                  .map(
                    (f) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.phaseBgColor(phase),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            f['emoji']!,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            f['name']!,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Local/Regional foods
          if (region.isNotEmpty && region != 'global' && filteredLocal.isNotEmpty) ...[
            Text(
              'LOCAL PICKS${location.isNotEmpty ? ' — $location' : ''}',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.ovulation.withValues(alpha: 0.2),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0FA08CB0),
                    blurRadius: 12,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🌍', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        'Regional recommendations',
                        style: AppTextStyles.button.copyWith(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...filteredLocal.map(
                    (l) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l['emoji']!,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l['name']!,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  l['why']!,
                                  style: AppTextStyles.small.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Foods to limit
          Text('FOODS TO LIMIT', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.menstrualBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.menstrual.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: (diet['avoid'] as List<Map<String, String>>)
                  .map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text(
                            a['emoji']!,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${a['name']} — ${a['reason']}',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 12,
                                color: AppColors.menstrual,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),

          // AI Prompt card
          Text('ASK AI FOR MORE', style: AppTextStyles.label),
          const SizedBox(height: 8),
          _AiPromptCard(
            phase: phase,
            region: region,
            location: location,
            periodProvider: periodProvider,
            logProvider: logProvider,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _macroLabel(String label, int pct, Color color) {
    return Column(
      children: [
        Text(
          '$pct%',
          style: AppTextStyles.mediumNumber.copyWith(
            fontSize: 16,
            color: color,
          ),
        ),
        Text(label, style: AppTextStyles.small.copyWith(fontSize: 9)),
      ],
    );
  }

  List<Map<String, String>> _getDeficiencyRisks(Map logs) {
    final symptomCounts = <String, int>{};
    for (final log in logs.values) {
      final dl = log as dynamic;
      for (final s in dl.symptoms) {
        symptomCounts[s as String] = (symptomCounts[s] ?? 0) + 1;
      }
    }

    final risks = <Map<String, String>>[];
    final mapping = {
      'Cramps': {
        'emoji': '🟤',
        'nutrient': 'Magnesium',
        'fix': 'Dark chocolate, pumpkin seeds, spinach, almonds',
      },
      'Fatigue': {
        'emoji': '🔴',
        'nutrient': 'Iron + B12',
        'fix': 'Red meat, lentils, eggs, fortified cereals',
      },
      'Headache': {
        'emoji': '💧',
        'nutrient': 'Hydration + Magnesium',
        'fix': 'Water, coconut water, bananas, nuts',
      },
      'Bloating': {
        'emoji': '🟢',
        'nutrient': 'Potassium + Probiotics',
        'fix': 'Bananas, yogurt, ginger tea, fermented foods',
      },
      'Acne': {
        'emoji': '🟡',
        'nutrient': 'Zinc + Omega-3',
        'fix': 'Pumpkin seeds, salmon, walnuts, zinc supplements',
      },
      'Nausea': {
        'emoji': '🫚',
        'nutrient': 'B6 + Ginger',
        'fix': 'Ginger tea, chickpeas, potatoes, small frequent meals',
      },
      'Back pain': {
        'emoji': '🟠',
        'nutrient': 'Calcium + Vitamin D',
        'fix': 'Dairy, sardines, sunlight, leafy greens',
      },
      'Breast tenderness': {
        'emoji': '🔵',
        'nutrient': 'Vitamin E + B6',
        'fix': 'Sunflower seeds, avocado, sweet potatoes',
      },
    };

    for (final entry in symptomCounts.entries) {
      if (mapping.containsKey(entry.key) && entry.value >= 2) {
        final m = mapping[entry.key]!;
        risks.add({...m, 'symptom': '${entry.key} (${entry.value}x)'});
      }
    }

    return risks;
  }


  Map<String, dynamic> _getDietData(CyclePhase phase, String region) {
    // Phase-specific base recommendations
    final phaseData = phaseNutrition[phase]!;

    // Region-specific local foods
    final localFoods =
        regionalFoods[region]?[phase] ?? regionalFoods['global']![phase]!;

    return {
      'summary': phaseData['summary'],
      'vitamins': phaseData['vitamins'],
      'foods': phaseData['foods'],
      'avoid': phaseData['avoid'],
      'local': localFoods,
    };
  }

}

class _AiPromptCard extends StatefulWidget {
  final CyclePhase phase;
  final String region;
  final String location;
  final PeriodProvider periodProvider;
  final DailyLogProvider logProvider;

  const _AiPromptCard({
    required this.phase,
    required this.region,
    required this.location,
    required this.periodProvider,
    required this.logProvider,
  });

  @override
  State<_AiPromptCard> createState() => _AiPromptCardState();
}

class _AiPromptCardState extends State<_AiPromptCard> {
  bool _expanded = false;
  bool _copied = false;

  String _buildPrompt() {
    final pp = widget.periodProvider;
    final logs = widget.logProvider.allLogs;
    final cl = pp.cycleLengths;
    final avgCycle = pp.averageCycleLength;
    final avgPeriod = pp.averagePeriodLength;

    // Symptom counts
    final symptomCounts = <String, int>{};
    for (final log in logs.values) {
      for (final s in log.symptoms) {
        symptomCounts[s] = (symptomCounts[s] ?? 0) + 1;
      }
    }
    final topSymptoms =
        (symptomCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .take(5)
            .map((e) => '${e.key} (${e.value}x)')
            .join(', ');

    // Mood counts
    final moodCounts = <String, int>{};
    for (final log in logs.values) {
      for (final m in log.moods) {
        moodCounts[m] = (moodCounts[m] ?? 0) + 1;
      }
    }
    final topMoods =
        (moodCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .take(5)
            .map((e) => '${e.key} (${e.value}x)')
            .join(', ');

    // Flow
    int light = 0, medium = 0, heavy = 0;
    for (final log in logs.values) {
      if (log.flow == 'light') light++;
      if (log.flow == 'medium') medium++;
      if (log.flow == 'heavy') heavy++;
    }
    final totalFlow = light + medium + heavy;

    // Cycle stats
    final shortest = cl.isNotEmpty ? cl.reduce((a, b) => a < b ? a : b) : null;
    final longest = cl.isNotEmpty ? cl.reduce((a, b) => a > b ? a : b) : null;

    // Medical checklist
    final medAgg = <String, Map<String, int>>{};
    int medDays = 0;
    for (final log in logs.values) {
      if (log.medicalLog.isEmpty) continue;
      medDays++;
      for (final e in log.medicalLog.entries) {
        medAgg.putIfAbsent(e.key, () => {});
        medAgg[e.key]![e.value] = (medAgg[e.key]![e.value] ?? 0) + 1;
      }
    }
    final medLines = StringBuffer();
    const medLabels = {
      'pain_level': 'Pain',
      'discharge_color': 'Discharge',
      'skin': 'Skin',
      'hair': 'Hair',
      'sleep': 'Sleep',
      'energy': 'Energy',
      'weight': 'Weight',
      'digestion': 'Digestion',
    };
    for (final entry in medAgg.entries) {
      final sorted = entry.value.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final total = sorted.fold<int>(0, (s, e) => s + e.value);
      final line = sorted
          .map((e) => '${e.key}: ${(e.value / total * 100).round()}%')
          .join(', ');
      medLines.writeln('- ${medLabels[entry.key] ?? entry.key}: $line');
    }

    final String intro =
        widget.location.isNotEmpty &&
            widget.location != 'Location unavailable' &&
            widget.location != 'Location denied'
        ? "I live in ${widget.location}. I'm tracking my menstrual cycle and need personalized diet and nutrition advice using locally available, seasonal ingredients from my region. Here is my data:"
        : "I'm tracking my menstrual cycle and need personalized diet and nutrition advice. Here is my data:";

    return '''$intro

CYCLE DATA:
- Current phase: ${AppColors.phaseName(widget.phase)}
- Average cycle length: $avgCycle days
- Average period duration: $avgPeriod days
- Cycle range: ${shortest ?? '?'}–${longest ?? '?'} days
- Periods tracked: ${pp.periods.length}
- Cycle day today: ${pp.currentCycleDay}

SYMPTOMS (frequency over tracked period):
${topSymptoms.isNotEmpty ? topSymptoms : 'None logged yet'}

MOODS (frequency):
${topMoods.isNotEmpty ? topMoods : 'None logged yet'}

FLOW PATTERN:
${totalFlow > 0 ? 'Light ${(light / totalFlow * 100).round()}%, Medium ${(medium / totalFlow * 100).round()}%, Heavy ${(heavy / totalFlow * 100).round()}%' : 'Not logged yet'}

MEDICAL CHECKLIST ($medDays days):
${medLines.toString().trimRight().isNotEmpty ? medLines.toString().trimRight() : 'Not logged yet'}
(Key data: sleep quality, pain levels, skin condition, digestion, energy — all affect nutritional needs)

Please provide:
1. A detailed 7-day meal plan tailored to my current cycle phase, using foods native and readily available in my location.
2. Specific vitamins and supplements I should take based on my symptom patterns
3. Foods to avoid right now and why
4. Hydration recommendations
5. Any nutrient deficiencies my symptoms suggest
6. Snack ideas that address my most common symptoms
7. Herbal teas or drinks that would help

Keep recommendations practical. Use specific local food names from my region, quantities where possible, and explain the "why" behind each suggestion.''';
  }

  @override
  Widget build(BuildContext context) {
    final prompt = _buildPrompt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.luteal.withValues(alpha: 0.08),
            AppColors.follicular.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.luteal.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get AI Diet Advice',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Copy this prompt to Gemini, ChatGPT, or Claude',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: prompt));
                  setState(() => _copied = true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _copied = false);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _copied ? AppColors.ovulation : AppColors.luteal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _copied ? Icons.check : Icons.copy,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _copied ? 'Copied!' : 'Copy',
                        style: AppTextStyles.small.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  _expanded ? 'Hide prompt preview' : 'Preview prompt',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                prompt,
                style: AppTextStyles.body.copyWith(
                  fontSize: 10,
                  height: 1.4,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NutrientCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String benefit;
  final String sources;

  const _NutrientCard({
    required this.emoji,
    required this.name,
    required this.benefit,
    required this.sources,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  benefit,
                  style: AppTextStyles.body.copyWith(fontSize: 11, height: 1.3),
                ),
                const SizedBox(height: 3),
                Text(
                  'Sources: $sources',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
