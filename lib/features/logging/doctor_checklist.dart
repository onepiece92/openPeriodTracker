import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DoctorChecklist extends StatelessWidget {
  final Map<String, String> values; // key → selected option
  final ValueChanged<Map<String, String>> onChanged;

  const DoctorChecklist({
    super.key,
    required this.values,
    required this.onChanged,
  });

  static const questions = [
    _Question(
      key: 'pain_level',
      icon: '😣',
      label: 'Pain Level',
      options: ['None', 'Mild', 'Moderate', 'Severe', 'Unbearable'],
    ),
    _Question(
      key: 'discharge_color',
      icon: '🔬',
      label: 'Discharge Color',
      options: ['Clear', 'White', 'Yellow', 'Brown', 'Pink', 'Red', 'Green'],
    ),
    _Question(
      key: 'discharge_consistency',
      icon: '💧',
      label: 'Discharge Type',
      options: ['Watery', 'Egg-white', 'Creamy', 'Sticky', 'Dry', 'Clumpy'],
    ),
    _Question(
      key: 'weight',
      icon: '⚖️',
      label: 'Weight Change',
      options: ['Stable', 'Gained', 'Lost', 'Bloated'],
    ),
    _Question(
      key: 'skin',
      icon: '✨',
      label: 'Skin Condition',
      options: ['Clear', 'Acne', 'Oily', 'Dry', 'Rash', 'Glow'],
    ),
    _Question(
      key: 'hair',
      icon: '💇‍♀️',
      label: 'Hair Changes',
      options: ['Normal', 'Thinning', 'Oily', 'Dry', 'Excess body hair'],
    ),
    _Question(
      key: 'sleep',
      icon: '😴',
      label: 'Sleep Quality',
      options: ['Great', 'Good', 'Poor', 'Insomnia', 'Oversleeping'],
    ),
    _Question(
      key: 'libido',
      icon: '💕',
      label: 'Libido',
      options: ['High', 'Normal', 'Low', 'None'],
    ),
    _Question(
      key: 'digestion',
      icon: '🫃',
      label: 'Digestion',
      options: [
        'Normal',
        'Constipated',
        'Diarrhea',
        'Nausea',
        'Appetite loss',
        'Cravings',
      ],
    ),
    _Question(
      key: 'breast',
      icon: '🩱',
      label: 'Breast Changes',
      options: ['Normal', 'Tender', 'Swollen', 'Lumpy'],
    ),
    _Question(
      key: 'energy',
      icon: '⚡',
      label: 'Energy Level',
      options: ['High', 'Normal', 'Low', 'Exhausted'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final answeredCount = values.length;
    final totalCount = questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress
        Row(
          children: [
            Text(
              '$answeredCount / $totalCount answered',
              style: AppTextStyles.small.copyWith(
                color: answeredCount > 0
                    ? AppColors.ovulation
                    : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: totalCount > 0 ? answeredCount / totalCount : 0,
                  minHeight: 4,
                  backgroundColor: AppColors.cardBorder,
                  valueColor: AlwaysStoppedAnimation(
                    answeredCount > 0
                        ? AppColors.ovulation
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Questions
        ...questions.map((q) {
          final selected = values[q.key];
          return _QuestionRow(
            question: q,
            selected: selected,
            onSelected: (value) {
              final updated = Map<String, String>.from(values);
              if (value == selected) {
                updated.remove(q.key); // toggle off
              } else {
                updated[q.key] = value;
              }
              onChanged(updated);
            },
          );
        }),
      ],
    );
  }
}

class _Question {
  final String key;
  final String icon;
  final String label;
  final List<String> options;

  const _Question({
    required this.key,
    required this.icon,
    required this.label,
    required this.options,
  });
}

class _QuestionRow extends StatelessWidget {
  final _Question question;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _QuestionRow({
    required this.question,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(question.icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                question.label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              if (selected != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ovulation.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    selected!,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.ovulation,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: question.options.map((opt) {
              final isSelected = selected == opt;
              final isWarning = _isWarningOption(question.key, opt);
              return GestureDetector(
                onTap: () => onSelected(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isWarning
                              ? AppColors.menstrualBg
                              : AppColors.ovulationBg)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? (isWarning
                                ? AppColors.menstrual
                                : AppColors.ovulation)
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Text(
                    opt,
                    style: AppTextStyles.small.copyWith(
                      fontSize: 10,
                      color: isSelected
                          ? (isWarning
                                ? AppColors.menstrual
                                : AppColors.ovulation)
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool _isWarningOption(String key, String opt) {
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
