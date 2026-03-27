import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FlowSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const FlowSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FlowOption(
          label: 'Light',
          drops: 1,
          isSelected: selected == 'light',
          onTap: () => onChanged(selected == 'light' ? null : 'light'),
        ),
        const SizedBox(width: 10),
        _FlowOption(
          label: 'Medium',
          drops: 2,
          isSelected: selected == 'medium',
          onTap: () => onChanged(selected == 'medium' ? null : 'medium'),
        ),
        const SizedBox(width: 10),
        _FlowOption(
          label: 'Heavy',
          drops: 3,
          isSelected: selected == 'heavy',
          onTap: () => onChanged(selected == 'heavy' ? null : 'heavy'),
        ),
      ],
    );
  }
}

class _FlowOption extends StatelessWidget {
  final String label;
  final int drops;
  final bool isSelected;
  final VoidCallback onTap;

  const _FlowOption({
    required this.label,
    required this.drops,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.menstrualBg : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.menstrual : AppColors.cardBorder,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  drops,
                  (_) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Icon(
                      Icons.water_drop,
                      size: 16,
                      color: isSelected ? AppColors.menstrual : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.small.copyWith(
                  color: isSelected ? AppColors.menstrual : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
