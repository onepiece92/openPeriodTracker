import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MoodSelector extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const MoodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const moods = [
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😴', 'label': 'Tired'},
    {'emoji': '😤', 'label': 'Irritable'},
    {'emoji': '🥰', 'label': 'Loving'},
    {'emoji': '😰', 'label': 'Anxious'},
    {'emoji': '😌', 'label': 'Calm'},
    {'emoji': '🤗', 'label': 'Grateful'},
    {'emoji': '😔', 'label': 'Lonely'},
    {'emoji': '🤒', 'label': 'Sick'},
    {'emoji': '😤', 'label': 'Angry'},
    {'emoji': '🥺', 'label': 'Sensitive'},
    {'emoji': '🤩', 'label': 'Energetic'},
    {'emoji': '😶', 'label': 'Numb'},
    {'emoji': '😖', 'label': 'Stressed'},
    {'emoji': '🥱', 'label': 'Sleepy'},
    {'emoji': '🫠', 'label': 'Meh'},
    {'emoji': '💪', 'label': 'Confident'},
    {'emoji': '😇', 'label': 'Peaceful'},
    {'emoji': '🤯', 'label': 'Overwhelmed'},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: moods.map((m) {
        final isSelected = selected.contains(m['label']);
        return GestureDetector(
          onTap: () {
            final updated = List<String>.from(selected);
            if (isSelected) {
              updated.remove(m['label']);
            } else {
              updated.add(m['label']!);
            }
            onChanged(updated);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.lutealBg : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.luteal : AppColors.cardBorder,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(m['emoji']!, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 1),
                Text(
                  m['label']!,
                  style: AppTextStyles.small.copyWith(
                    fontSize: 9,
                    color: isSelected ? AppColors.luteal : AppColors.textMuted,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
