import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PhaseCard extends StatelessWidget {
  final CyclePhase phase;
  final int currentDay;
  final int cycleLength;

  const PhaseCard({
    super.key,
    required this.phase,
    required this.currentDay,
    required this.cycleLength,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.phaseBgColor(phase),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.phaseColor(phase).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.phaseColor(phase),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppColors.phaseName(phase),
              style: AppTextStyles.button.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            'Day $currentDay of $cycleLength',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
