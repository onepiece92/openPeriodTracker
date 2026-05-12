import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/period_provider.dart';
import '../../core/providers/daily_log_provider.dart';
import '../../core/providers/settings_provider.dart';

class DoctorView extends StatelessWidget {
  const DoctorView({super.key});

  @override
  Widget build(BuildContext context) {
    final logProvider = context.watch<DailyLogProvider>();
    final periodProvider = context.watch<PeriodProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final logs = logProvider.allLogs;

    // Aggregate medical checklist data across all logs
    final allMedical =
        <String, Map<String, int>>{}; // question key → {option → count}
    int daysWithMedical = 0;

    for (final log in logs.values) {
      if (log.medicalLog.isEmpty) continue;
      daysWithMedical++;
      for (final entry in log.medicalLog.entries) {
        allMedical.putIfAbsent(entry.key, () => {});
        allMedical[entry.key]![entry.value] =
            (allMedical[entry.key]![entry.value] ?? 0) + 1;
      }
    }

    // Generate findings
    final findings = _analyzeFindings(allMedical, daysWithMedical);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (daysWithMedical == 0)
          _buildEmptyState()
        else ...[
          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.follicularBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.follicular.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Text('🩺', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doctor\'s Analysis',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$daysWithMedical days of medical data logged',
                        style: AppTextStyles.body.copyWith(height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Findings
          if (findings.isNotEmpty) ...[
            Text('FINDINGS', style: AppTextStyles.label),
            const SizedBox(height: 8),
            ...findings.map(
              (f) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: f.severity == 'warning'
                        ? AppColors.menstrual.withValues(alpha: 0.2)
                        : f.severity == 'note'
                        ? const Color(0xFFD4A340).withValues(alpha: 0.2)
                        : AppColors.ovulation.withValues(alpha: 0.2),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0FA08CB0),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  f.title,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: f.severity == 'warning'
                                      ? AppColors.menstrual.withValues(
                                          alpha: 0.1,
                                        )
                                      : f.severity == 'note'
                                      ? const Color(
                                          0xFFD4A340,
                                        ).withValues(alpha: 0.1)
                                      : AppColors.ovulation.withValues(
                                          alpha: 0.1,
                                        ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  f.severity == 'warning'
                                      ? 'Flag'
                                      : f.severity == 'note'
                                      ? 'Note'
                                      : 'Good',
                                  style: AppTextStyles.small.copyWith(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: f.severity == 'warning'
                                        ? AppColors.menstrual
                                        : f.severity == 'note'
                                        ? const Color(0xFFD4A340)
                                        : AppColors.ovulation,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            f.body,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Checklist data table
          Text('CHECKLIST DATA', style: AppTextStyles.label),
          const SizedBox(height: 8),
          ...allMedical.entries.map((entry) {
            final key = entry.key;
            final counts = entry.value;
            final sorted = counts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final total = sorted.fold<int>(0, (s, e) => s + e.value);

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: AppDecorations.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _questionEmoji(key),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _questionLabel(key),
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...sorted.map((opt) {
                    final pct = (opt.value / total * 100).round();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              opt.key,
                              style: AppTextStyles.small.copyWith(fontSize: 10),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: opt.value / total,
                                minHeight: 6,
                                backgroundColor: AppColors.cardBorder,
                                valueColor: AlwaysStoppedAnimation(
                                  _isWarning(key, opt.key)
                                      ? AppColors.menstrual.withValues(
                                          alpha: 0.6,
                                        )
                                      : AppColors.follicular.withValues(
                                          alpha: 0.5,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 32,
                            child: Text(
                              '$pct%',
                              style: AppTextStyles.small.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                                color: _isWarning(key, opt.key)
                                    ? AppColors.menstrual
                                    : AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // Copy prompt card
          Text('ASK AI FOR MORE', style: AppTextStyles.label),
          const SizedBox(height: 8),
          _DoctorPromptCard(
            allMedical: allMedical,
            daysWithMedical: daysWithMedical,
            periodProvider: periodProvider,
            settingsProvider: settingsProvider,
            logProvider: logProvider,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          const Text('🩺', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('No medical data yet', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Text(
            'Tap any day on the calendar, scroll down to the Doctor\'s Checklist, and log pain levels, discharge, skin, sleep, and more.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<_Finding> _analyzeFindings(
    Map<String, Map<String, int>> data,
    int totalDays,
  ) {
    final findings = <_Finding>[];
    if (totalDays < 2) return findings;

    // Pain analysis
    final pain = data['pain_level'];
    if (pain != null) {
      final severe = (pain['Severe'] ?? 0) + (pain['Unbearable'] ?? 0);
      final total = pain.values.fold<int>(0, (s, v) => s + v);
      if (severe > 0 && severe / total > 0.3) {
        findings.add(
          _Finding(
            emoji: '😣',
            title: 'Frequent severe pain (${(severe / total * 100).round()}%)',
            body:
                'Severe/unbearable pain logged $severe out of $total times. This level of pain is not something you should just endure. Discuss with your doctor — could indicate endometriosis, fibroids, or adenomyosis.',
            severity: 'warning',
          ),
        );
      } else if (pain.containsKey('None') && pain['None']! > total * 0.7) {
        findings.add(
          _Finding(
            emoji: '✅',
            title: 'Low pain levels',
            body: 'Mostly pain-free — great sign. No pain management concerns.',
            severity: 'good',
          ),
        );
      }
    }

    // Discharge analysis
    final discharge = data['discharge_color'];
    if (discharge != null) {
      final concerning = (discharge['Green'] ?? 0) + (discharge['Yellow'] ?? 0);
      if (concerning > 0) {
        findings.add(
          _Finding(
            emoji: '🔬',
            title: 'Unusual discharge color noted',
            body:
                'Green or yellow discharge logged $concerning time(s). This can indicate an infection (bacterial vaginosis, STI, yeast). Worth a provider visit if accompanied by odor or itching.',
            severity: 'warning',
          ),
        );
      }
    }

    // Sleep analysis
    final sleep = data['sleep'];
    if (sleep != null) {
      final poor = (sleep['Poor'] ?? 0) + (sleep['Insomnia'] ?? 0);
      final total = sleep.values.fold<int>(0, (s, v) => s + v);
      if (poor > 0 && poor / total > 0.4) {
        findings.add(
          _Finding(
            emoji: '😴',
            title:
                'Sleep issues (${(poor / total * 100).round()}% of logged days)',
            body:
                'Poor sleep or insomnia is common in the luteal phase due to progesterone shifts. Try magnesium glycinate before bed, limit screens, and maintain a cool room temperature.',
            severity: 'note',
          ),
        );
      }
    }

    // Skin analysis
    final skin = data['skin'];
    if (skin != null) {
      final acne = skin['Acne'] ?? 0;
      final total = skin.values.fold<int>(0, (s, v) => s + v);
      if (acne > 0 && acne / total > 0.4) {
        findings.add(
          _Finding(
            emoji: '✨',
            title: 'Hormonal acne pattern (${(acne / total * 100).round()}%)',
            body:
                'Acne logged frequently — likely hormonal, peaking in the luteal phase when androgens rise. Zinc supplements, reducing dairy, and topical retinoids may help. Persistent cystic acne warrants a dermatology referral.',
            severity: 'note',
          ),
        );
      }
    }

    // Hair analysis
    final hair = data['hair'];
    if (hair != null) {
      if ((hair['Thinning'] ?? 0) > 0) {
        findings.add(
          _Finding(
            emoji: '💇‍♀️',
            title: 'Hair thinning reported',
            body:
                'Hair thinning can signal thyroid issues, iron deficiency, or PCOS. Request a thyroid panel (TSH, T3, T4) and ferritin check at your next visit.',
            severity: 'warning',
          ),
        );
      }
      if ((hair['Excess body hair'] ?? 0) > 0) {
        findings.add(
          _Finding(
            emoji: '💇‍♀️',
            title: 'Excess body hair reported',
            body:
                'Excess hair growth (hirsutism) may indicate elevated androgens, common in PCOS. Mention this to your provider — a hormonal panel can clarify.',
            severity: 'warning',
          ),
        );
      }
    }

    // Weight analysis
    final weight = data['weight'];
    if (weight != null) {
      final bloated = weight['Bloated'] ?? 0;
      final total = weight.values.fold<int>(0, (s, v) => s + v);
      if (bloated > 0 && bloated / total > 0.5) {
        findings.add(
          _Finding(
            emoji: '⚖️',
            title: 'Frequent bloating (${(bloated / total * 100).round()}%)',
            body:
                'Bloating more than half the time suggests fluid retention or digestive sensitivity. Reduce sodium, increase potassium, and consider a food diary to identify triggers.',
            severity: 'note',
          ),
        );
      }
    }

    // Breast analysis
    final breast = data['breast'];
    if (breast != null) {
      if ((breast['Lumpy'] ?? 0) > 0) {
        findings.add(
          _Finding(
            emoji: '🩱',
            title: 'Breast lumps reported',
            body:
                'Any breast lump should be evaluated by a healthcare provider. Most are benign fibrocystic changes, but clinical examination is important to rule out other causes.',
            severity: 'warning',
          ),
        );
      }
    }

    // Energy analysis
    final energy = data['energy'];
    if (energy != null) {
      final low = (energy['Low'] ?? 0) + (energy['Exhausted'] ?? 0);
      final total = energy.values.fold<int>(0, (s, v) => s + v);
      if (low > 0 && low / total > 0.5) {
        findings.add(
          _Finding(
            emoji: '⚡',
            title: 'Persistent low energy (${(low / total * 100).round()}%)',
            body:
                'Low energy over half your logged days may point to iron deficiency, thyroid dysfunction, or vitamin D insufficiency. A basic blood panel can identify the cause.',
            severity: 'note',
          ),
        );
      }
    }

    // Libido analysis
    final libido = data['libido'];
    if (libido != null) {
      if ((libido['None'] ?? 0) > 0) {
        final total = libido.values.fold<int>(0, (s, v) => s + v);
        final nonePct = ((libido['None']! / total) * 100).round();
        if (nonePct > 30) {
          findings.add(
            _Finding(
              emoji: '💕',
              title: 'Low/absent libido ($nonePct%)',
              body:
                  'Persistently low libido can relate to hormonal imbalance, stress, medication side effects, or mental health. It\'s a valid health concern — discuss openly with your provider.',
              severity: 'note',
            ),
          );
        }
      }
    }

    if (findings.isEmpty) {
      findings.add(
        _Finding(
          emoji: '🎉',
          title: 'No red flags detected',
          body:
              'Your medical checklist data looks reassuring. Keep logging to build a more complete picture over time.',
          severity: 'good',
        ),
      );
    }

    return findings;
  }

  String _questionEmoji(String key) {
    const map = {
      'pain_level': '😣',
      'discharge_color': '🔬',
      'discharge_consistency': '💧',
      'weight': '⚖️',
      'skin': '✨',
      'hair': '💇‍♀️',
      'sleep': '😴',
      'libido': '💕',
      'digestion': '🫃',
      'breast': '🩱',
      'energy': '⚡',
    };
    return map[key] ?? '📋';
  }

  String _questionLabel(String key) {
    const map = {
      'pain_level': 'Pain Level',
      'discharge_color': 'Discharge Color',
      'discharge_consistency': 'Discharge Type',
      'weight': 'Weight Change',
      'skin': 'Skin Condition',
      'hair': 'Hair Changes',
      'sleep': 'Sleep Quality',
      'libido': 'Libido',
      'digestion': 'Digestion',
      'breast': 'Breast Changes',
      'energy': 'Energy Level',
    };
    return map[key] ?? key;
  }

  bool _isWarning(String key, String opt) {
    const warnings = {
      'pain_level': {'Severe', 'Unbearable'},
      'discharge_color': {'Green', 'Yellow'},
      'weight': {'Gained', 'Lost'},
      'skin': {'Rash'},
      'hair': {'Thinning', 'Excess body hair'},
      'sleep': {'Insomnia'},
      'libido': {'None'},
      'digestion': {'Diarrhea', 'Nausea'},
      'breast': {'Lumpy'},
      'energy': {'Exhausted'},
    };
    return warnings[key]?.contains(opt) ?? false;
  }
}

class _Finding {
  final String emoji;
  final String title;
  final String body;
  final String severity; // 'warning', 'note', 'good'

  const _Finding({
    required this.emoji,
    required this.title,
    required this.body,
    required this.severity,
  });
}

// --- Copy prompt card ---

class _DoctorPromptCard extends StatefulWidget {
  final Map<String, Map<String, int>> allMedical;
  final int daysWithMedical;
  final PeriodProvider periodProvider;
  final SettingsProvider settingsProvider;
  final DailyLogProvider logProvider;

  const _DoctorPromptCard({
    required this.allMedical,
    required this.daysWithMedical,
    required this.periodProvider,
    required this.settingsProvider,
    required this.logProvider,
  });

  @override
  State<_DoctorPromptCard> createState() => _DoctorPromptCardState();
}

class _DoctorPromptCardState extends State<_DoctorPromptCard> {
  bool _expanded = false;
  bool _copied = false;

  String _buildPrompt() {
    final pp = widget.periodProvider;
    final sp = widget.settingsProvider;
    final logs = widget.logProvider.allLogs;
    final age = sp.userAge;
    final phase = pp.currentPhase;
    final avgCycle = pp.averageCycleLength;
    final avgPeriod = pp.averagePeriodLength;
    final cl = pp.cycleLengths;

    // Medical checklist summary
    final medicalSummary = StringBuffer();
    for (final entry in widget.allMedical.entries) {
      final key = entry.key;
      final counts = entry.value;
      final sorted = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final total = sorted.fold<int>(0, (s, e) => s + e.value);
      final line = sorted
          .map((e) => '${e.key}: ${(e.value / total * 100).round()}%')
          .join(', ');
      medicalSummary.writeln('- ${_label(key)}: $line ($total responses)');
    }

    // Symptoms
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

    // Flow
    int light = 0, medium = 0, heavy = 0;
    for (final log in logs.values) {
      if (log.flow == 'light') light++;
      if (log.flow == 'medium') medium++;
      if (log.flow == 'heavy') heavy++;
    }
    final totalFlow = light + medium + heavy;

    return '''I'm sharing my menstrual health tracking data with you for a thorough analysis. Please act as a knowledgeable women's health advisor.

PERSONAL:
${age != null ? '- Age: $age years old' : '- Age: not provided'}
- Current phase: ${AppColors.phaseName(phase)}
- Cycle day: ${pp.currentCycleDay}

CYCLE DATA (${pp.periods.length} periods):
- Average cycle: $avgCycle days
- Average period: $avgPeriod days
- Cycle lengths: ${cl.isNotEmpty ? cl.join(', ') : 'N/A'}

SYMPTOMS: ${topSymptoms.isNotEmpty ? topSymptoms : 'None logged'}

FLOW: ${totalFlow > 0 ? 'Light ${(light / totalFlow * 100).round()}%, Medium ${(medium / totalFlow * 100).round()}%, Heavy ${(heavy / totalFlow * 100).round()}%' : 'Not logged'}

MEDICAL CHECKLIST DATA (${widget.daysWithMedical} days logged):
${medicalSummary.toString().trimRight()}

Based on this data, please provide:

1. **Clinical Assessment**: What patterns do you see? Are there any red flags a doctor would want to investigate?

2. **Pain Analysis**: Given my pain level distribution, is my pain normal or should I seek treatment? What conditions could explain this pattern?

3. **Discharge Assessment**: Is my discharge pattern normal across my cycle? Any signs of infection or hormonal issues?

4. **Skin & Hair**: What do my skin and hair patterns suggest about my hormonal balance? Any PCOS indicators?

5. **Sleep & Energy**: Are my sleep/energy patterns cycle-related or could they indicate an underlying issue (thyroid, anemia, etc.)?

6. **Lab Tests to Request**: Based on ALL this data, what specific blood tests should I ask my doctor to run? (Be specific — TSH, ferritin, vitamin D, hormonal panel, etc.)

7. **Questions for My Doctor**: Give me a list of specific questions I should ask at my next gynecologist appointment, based on what you see in this data.

8. **Lifestyle Recommendations**: What specific, actionable changes would help address the patterns you see?

Be thorough, reference my actual data points, and explain WHY each recommendation matters. Don't be generic — tailor everything to MY numbers.''';
  }

  String _label(String key) {
    const map = {
      'pain_level': 'Pain Level',
      'discharge_color': 'Discharge Color',
      'discharge_consistency': 'Discharge Type',
      'weight': 'Weight',
      'skin': 'Skin',
      'hair': 'Hair',
      'sleep': 'Sleep',
      'libido': 'Libido',
      'digestion': 'Digestion',
      'breast': 'Breast',
      'energy': 'Energy',
    };
    return map[key] ?? key;
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
            AppColors.follicular.withValues(alpha: 0.06),
            AppColors.ovulation.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.follicular.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🩺', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get AI Doctor Analysis',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Copy to Gemini, ChatGPT, or Claude',
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
                    color: _copied ? AppColors.ovulation : AppColors.follicular,
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
                  _expanded ? 'Hide prompt' : 'Preview prompt',
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
