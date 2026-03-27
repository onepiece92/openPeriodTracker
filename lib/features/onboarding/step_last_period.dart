import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

class StepLastPeriod extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback? onNext;

  const StepLastPeriod({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onNext,
  });

  @override
  State<StepLastPeriod> createState() => _StepLastPeriodState();
}

class _StepLastPeriodState extends State<StepLastPeriod> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'When did your last\nperiod start?',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the first day of your most recent period',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildCalendar()),
          if (widget.selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Center(
                child: Text(
                  DateFormat('MMMM d, yyyy').format(widget.selectedDate!),
                  style: AppTextStyles.button.copyWith(color: AppColors.luteal),
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.onNext != null ? AppColors.luteal : AppColors.cardBorder,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text('Next', style: AppTextStyles.button.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final today = DateTime.now();
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7; // 0=Sun

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_displayedMonth),
                style: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onPressed: () {
                  final nextMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
                  if (!nextMonth.isAfter(DateTime(today.year, today.month))) {
                    setState(() => _displayedMonth = nextMonth);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Day labels
          Row(
            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d, style: AppTextStyles.label),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Day grid
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                final dayNum = index - startWeekday + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const SizedBox.shrink();
                }
                final date = DateTime(_displayedMonth.year, _displayedMonth.month, dayNum);
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
                final isFuture = date.isAfter(today);
                final isSelected = widget.selectedDate != null &&
                    date.year == widget.selectedDate!.year &&
                    date.month == widget.selectedDate!.month &&
                    date.day == widget.selectedDate!.day;

                return GestureDetector(
                  onTap: isFuture ? null : () => widget.onDateSelected(date),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.luteal : null,
                      borderRadius: BorderRadius.circular(11),
                      border: isToday && !isSelected
                          ? Border.all(color: AppColors.luteal, width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: AppTextStyles.body.copyWith(
                          color: isFuture
                              ? AppColors.textMuted.withValues(alpha: 0.4)
                              : isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                          fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
