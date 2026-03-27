import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SymptomChips extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const SymptomChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const symptoms = [
    'Cramps',
    'Headache',
    'Bloating',
    'Back pain',
    'Breast tenderness',
    'Acne',
    'Nausea',
    'Fatigue',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: symptoms.map((s) {
        final isSelected = selected.contains(s);
        return GestureDetector(
          onTap: () {
            final updated = List<String>.from(selected);
            if (isSelected) {
              updated.remove(s);
            } else {
              updated.add(s);
            }
            onChanged(updated);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE0F0F0) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF5BA4A4) : AppColors.cardBorder,
              ),
            ),
            child: Text(
              s,
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: isSelected ? const Color(0xFF5BA4A4) : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
