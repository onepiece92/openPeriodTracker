import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/period_provider.dart';
import 'core/providers/daily_log_provider.dart';
import 'core/services/notification_service.dart';
import 'services/ai_diagnosis_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(buildApp());
}

/// The provider tree and root widget. Shared with integration tests so they
/// can wrap the real app without re-declaring providers.
Widget buildApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
      ChangeNotifierProxyProvider<SettingsProvider, PeriodProvider>(
        create: (_) => PeriodProvider()..loadPeriods(),
        update: (_, settings, period) {
          period ??= PeriodProvider()..loadPeriods();
          period.updateSettings(settings.cycleLength, settings.periodLength);
          return period;
        },
      ),
      ChangeNotifierProvider(create: (_) => DailyLogProvider()..loadLogs()),
      ChangeNotifierProvider(
        create: (_) => AiDiagnosisProvider()..initialize(),
      ),
    ],
    child: const OpenPeriodApp(),
  );
}
