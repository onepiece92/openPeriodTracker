import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/period_provider.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final periodProvider = context.watch<PeriodProvider>();
    final periods = periodProvider.periods.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Period History', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 12),

        if (periods.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: AppDecorations.card,
            child: Text(
              'No periods logged yet. Tap a date on the calendar and mark it as a period day.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          )
        else ...[
          ...List.generate(periods.length, (i) {
            final period = periods[i];
            final startDate = DateTime.parse(period.startDate);
            final endDate = DateTime.parse(period.endDate);
            final dateRange =
                '${DateFormat('MMM d').format(startDate)} — ${DateFormat('MMM d').format(endDate)}';
            final duration = '${period.durationDays} days';

            // Calculate cycle length to next period
            String? cycleInfo;
            if (i > 0) {
              final nextPeriod = periods[i - 1];
              final nextStart = DateTime.parse(nextPeriod.startDate);
              final cycleDays = nextStart.difference(startDate).inDays;
              cycleInfo = '$cycleDays day cycle';
            }

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.card,
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.menstrual,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateRange,
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(duration, style: AppTextStyles.small),
                      ],
                    ),
                  ),
                  if (cycleInfo != null)
                    Text(
                      cycleInfo,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            );
          }),

          // Summary card
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.follicularBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.follicular.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                'Average cycle: ${periodProvider.averageCycleLength} days  •  Periods logged: ${periods.length}',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.follicular,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
