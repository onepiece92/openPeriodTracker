import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/daily_log_provider.dart';
import '../providers/period_provider.dart';
import '../theme/app_theme.dart';

class ShareService {
  /// Generates and shares a status message containing pertinent cycle information.
  static Future<void> shareStatus(
    PeriodProvider periodProvider,
    DailyLogProvider dailyLogProvider,
  ) async {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final currentLog = dailyLogProvider.getLog(todayStr);

    final String phaseName = _getPhaseName(periodProvider.currentPhase);
    final int cycleDay = periodProvider.currentCycleDay;
    final int? daysUntil = periodProvider.daysUntilNextPeriod;

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('🌸 Luna Update');
    buffer.writeln('Currently on Day $cycleDay ($phaseName Phase).');

    // Add period prediction
    if (daysUntil != null) {
      if (daysUntil < 0) {
        buffer.writeln('Periods are late by ${daysUntil.abs()} days.');
      } else if (daysUntil == 0) {
        buffer.writeln('My period is expected today.');
      } else {
        buffer.writeln('My next period is expected in $daysUntil days.');
      }
    }

    // Add symptoms if logged today
    if (currentLog != null) {
      final List<String> notableSymptoms = [];
      
      // Combine moods and physical symptoms
      if (currentLog.moods.isNotEmpty) {
        notableSymptoms.addAll(currentLog.moods);
      }
      if (currentLog.symptoms.isNotEmpty) {
        notableSymptoms.addAll(currentLog.symptoms);
      }

      if (notableSymptoms.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('Currently experiencing: ${notableSymptoms.join(', ')}.');
      }
      
      if (currentLog.notes != null && currentLog.notes!.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('Additional Notes: ${currentLog.notes}');
      }
    }

    buffer.writeln();
    buffer.writeln('- Shared via Luna App 🌙');

    await Share.share(buffer.toString());
  }

  static String _getPhaseName(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return 'Menstrual';
      case CyclePhase.follicular:
        return 'Follicular';
      case CyclePhase.ovulation:
        return 'Ovulation';
      case CyclePhase.luteal:
        return 'Luteal';
    }
  }
}
