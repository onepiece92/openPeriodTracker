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
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(create: (_) => PeriodProvider()..loadPeriods()),
        ChangeNotifierProvider(create: (_) => DailyLogProvider()..loadLogs()),
        ChangeNotifierProvider(
          create: (_) => AiDiagnosisProvider()..initialize(),
        ),
      ],
      child: const LunaApp(),
    ),
  );
}
