import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/period_provider.dart';
import '../../core/providers/daily_log_provider.dart';
import '../logging/log_bottom_sheet.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _displayedMonth;
  String? _selectedDate;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _openLogSheet(String dateStr) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogBottomSheet(date: dateStr),
    ).then((_) {
      // Clear selection when sheet closes so calendar shows true status
      setState(() => _selectedDate = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final periodProvider = context.watch<PeriodProvider>();
    final logProvider = context.watch<DailyLogProvider>();
    final today = DateTime.now();
    final todayStr = _formatDate(today);

    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;
    final startWeekday = firstDayOfMonth.weekday % 7;
    final totalCells = startWeekday + daysInMonth;
    final rows = ((totalCells) / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month header
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month - 1,
                    );
                  });
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    DateFormat('MMMM yyyy').format(_displayedMonth),
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month + 1,
                    );
                  });
                },
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => setState(() => _editMode = !_editMode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _editMode ? AppColors.menstrualBg : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _editMode
                          ? AppColors.menstrual
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 14,
                        color: _editMode
                            ? AppColors.menstrual
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _editMode ? 'Done' : 'Edit',
                        style: AppTextStyles.small.copyWith(
                          color: _editMode
                              ? AppColors.menstrual
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Edit mode hint
          if (_editMode)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Tap days to mark or unmark period',
                style: AppTextStyles.small.copyWith(color: AppColors.menstrual),
              ),
            ),
          const SizedBox(height: 8),

          // Day labels
          Row(
            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                .map(
                  (d) => Expanded(
                    child: Center(child: Text(d, style: AppTextStyles.label)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 4),

          // Calendar grid
          ...List.generate(rows, (row) {
            return Row(
              children: List.generate(7, (col) {
                final index = row * 7 + col;
                final dayNum = index - startWeekday + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 44));
                }

                final date = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month,
                  dayNum,
                );
                final dateStr = _formatDate(date);
                final status = periodProvider.getDayStatus(dateStr);
                final isToday = dateStr == todayStr;
                final isSelected = dateStr == _selectedDate;
                final log = logProvider.getLog(dateStr);
                final hasLog = log != null && log.hasData;
                final hasMedical = log != null && log.medicalLog.isNotEmpty;
                final phase = periodProvider.currentPhase;
                final cycleDay = periodProvider.getCycleDayForDate(dateStr);

                // Flow dot count: light=1, medium=2, heavy=3
                int flowDots = 0;
                if (status == 'period' && log?.flow != null) {
                  switch (log!.flow) {
                    case 'light':
                      flowDots = 1;
                    case 'medium':
                      flowDots = 2;
                    case 'heavy':
                      flowDots = 3;
                  }
                }

                Color? bgColor;
                Color textColor = AppColors.textPrimary;
                bool showPredictedDot = false;
                bool isPeak = status == 'peak';

                if (status == 'period') {
                  bgColor = const Color(0xFFE07088);
                  textColor = Colors.white;
                } else if (status == 'predicted-period') {
                  bgColor = AppColors.menstrualBg;
                  showPredictedDot = true;
                } else if (isPeak) {
                  bgColor = const Color(0xFFD4F5DC);
                  textColor = const Color(0xFF2D7A4A);
                } else if (status == 'fertile') {
                  bgColor = AppColors.ovulationBg;
                }

                if (isSelected) {
                  bgColor = AppColors.phaseColor(phase);
                  textColor = Colors.white;
                }

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_editMode) {
                        periodProvider.togglePeriodDay(dateStr);
                      } else {
                        setState(() => _selectedDate = dateStr);
                        _openLogSheet(dateStr);
                      }
                    },
                    child: Container(
                      height: 44,
                      margin: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(11),
                        border: _editMode
                            ? Border.all(
                                color: status == 'period'
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : AppColors.menstrual.withValues(
                                        alpha: 0.15,
                                      ),
                                width: 1.5,
                              )
                            : isToday && !isSelected
                            ? Border.all(
                                color: AppColors.phaseColor(phase),
                                width: 1.5,
                              )
                            : null,
                        boxShadow: isSelected && !_editMode
                            ? [
                                BoxShadow(
                                  color: AppColors.phaseColor(
                                    phase,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Cycle day label (top-left)
                          Positioned(
                            top: 2,
                            left: 4,
                            child: Text(
                              'D$cycleDay',
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w600,
                                color: (status == 'period' || isSelected)
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : AppColors.textMuted.withValues(
                                        alpha: 0.5,
                                      ),
                              ),
                            ),
                          ),
                          // Peak day star
                          if (isPeak && !isSelected)
                            Positioned(
                              top: 2,
                              right: 3,
                              child: Text('⭐', style: TextStyle(fontSize: 8)),
                            ),
                          Text(
                            '$dayNum',
                            style: AppTextStyles.body.copyWith(
                              color: textColor,
                              fontWeight: isToday || isSelected || isPeak
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          if (flowDots > 0 ||
                              showPredictedDot ||
                              hasLog ||
                              hasMedical)
                            Positioned(
                              bottom: 4,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Flow dots (1/2/3 for light/medium/heavy)
                                  if (flowDots > 0)
                                    ...List.generate(
                                      flowDots,
                                      (_) => Container(
                                        width: 4,
                                        height: 4,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 0.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  // Predicted period dot
                                  else if (showPredictedDot)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 0.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.menstrual,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  // Log data dot (mood/symptoms/notes)
                                  if (hasLog && flowDots == 0)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 0.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.luteal,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  // Medical checklist dot
                                  if (hasMedical)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 0.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF5BA4A4),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }),

          const SizedBox(height: 12),

          // Legend
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              _LegendItem(color: AppColors.menstrual, label: 'Period'),
              _FlowLegend(),
              _LegendItem(
                color: AppColors.menstrualBg,
                label: 'Predicted',
                outlined: true,
                dotColor: AppColors.menstrual,
              ),
              _LegendItem(
                color: AppColors.ovulationBg,
                label: 'Fertile',
                outlined: true,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 8)),
                  const SizedBox(width: 3),
                  Text('Peak', style: AppTextStyles.small),
                ],
              ),
              _LegendItem(color: const Color(0xFF5BA4A4), label: 'Medical'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlowLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1 dot
        _dot(),
        const SizedBox(width: 2),
        Text('L ', style: AppTextStyles.small),
        // 2 dots
        _dot(), _dot(),
        const SizedBox(width: 2),
        Text('M ', style: AppTextStyles.small),
        // 3 dots
        _dot(), _dot(), _dot(),
        const SizedBox(width: 2),
        Text('H', style: AppTextStyles.small),
      ],
    );
  }

  Widget _dot() {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 0.5),
      decoration: const BoxDecoration(
        color: AppColors.menstrual,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool outlined;
  final Color? dotColor;

  const _LegendItem({
    required this.color,
    required this.label,
    this.outlined = false,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.small),
      ],
    );
  }
}
