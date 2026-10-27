import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/router/app_router.dart';

class OpenPeriodApp extends StatefulWidget {
  const OpenPeriodApp({super.key});

  @override
  State<OpenPeriodApp> createState() => _OpenPeriodAppState();
}

class _OpenPeriodAppState extends State<OpenPeriodApp> {
  GoRouter? _router;
  bool? _lastOnboarded;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        if (settings.isLoading) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Recreate router when onboarded state changes (e.g. after reset)
        if (_router == null || _lastOnboarded != settings.isOnboarded) {
          _lastOnboarded = settings.isOnboarded;
          _router = createRouter(isOnboarded: settings.isOnboarded);
        }

        return MaterialApp.router(
          title: 'Open Period Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.transparent,
          ),
          routerConfig: _router,
          builder: (context, child) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: child,
            );
          },
        );
      },
    );
  }
}
