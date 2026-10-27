// ignore_for_file: use_build_context_synchronously
// Drives the real app on a simulator, seeds a year of demo data, visits every
// screen and writes raw screenshots for the store listing.
//
// Captures are rendered from the Flutter layer tree through a RepaintBoundary
// (the native window snapshot on iOS returns blank frames for Metal-backed
// views). Pass --dart-define=SHOT_DIR=<absolute path> to write them straight
// into the project from the simulator; on a device they land in the app's
// Documents/screenshots folder instead.
//
// Run: see test_driver/integration_test.dart.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:open_period_tracker/core/providers/daily_log_provider.dart';
import 'package:open_period_tracker/core/providers/period_provider.dart';
import 'package:open_period_tracker/core/providers/settings_provider.dart';
import 'package:open_period_tracker/core/services/demo_data_service.dart';
import 'package:open_period_tracker/features/logging/log_bottom_sheet.dart';
import 'package:open_period_tracker/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Render continuously like a real app so animations and async fonts finish.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  final shotKey = GlobalKey();
  late Directory outDir;

  Future<void> wait(WidgetTester t, [int ms = 1500]) async {
    final end = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(end)) {
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  BuildContext routerContext(WidgetTester t) =>
      t.element(find.byType(Scaffold).last);

  Future<void> go(WidgetTester t, String path) async {
    GoRouter.of(routerContext(t)).go(path);
    await wait(t);
  }

  Future<void> shot(WidgetTester t, String name) async {
    await wait(t, 800);
    final ctx = shotKey.currentContext!;
    final boundary = ctx.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(
      pixelRatio: View.of(ctx).devicePixelRatio,
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = data!.buffer.asUint8List();
    await File('${outDir.path}/$name.png').writeAsBytes(bytes);
    debugPrint(
      'SHOT $name ${image.width}x${image.height} ${bytes.length} bytes',
    );
    image.dispose();
  }

  testWidgets('capture store screenshots', (tester) async {
    // Prefer writing straight into the project (simulator processes can write
    // host paths); fall back to the app's Documents folder on a real device.
    const hostDir = String.fromEnvironment('SHOT_DIR');
    Directory? host;
    if (hostDir.isNotEmpty) {
      try {
        host = Directory(hostDir)..createSync(recursive: true);
        File('${host.path}/.probe').writeAsStringSync('ok');
      } catch (_) {
        host = null;
      }
    }
    if (host != null) {
      outDir = host;
    } else {
      final docs = await getApplicationDocumentsDirectory();
      outDir = Directory('${docs.path}/screenshots');
      if (outDir.existsSync()) outDir.deleteSync(recursive: true);
      outDir.createSync(recursive: true);
    }
    debugPrint('SHOT_DIR ${outDir.path}');

    runApp(RepaintBoundary(key: shotKey, child: app.buildApp()));
    await wait(tester, 3000); // settings load + Google Fonts download

    final appCtx = tester.element(find.byType(MaterialApp).first);
    final settings = appCtx.read<SettingsProvider>();
    await DemoDataService().generate(
      settingsProv: settings,
      periodProv: appCtx.read<PeriodProvider>(),
      logProv: appCtx.read<DailyLogProvider>(),
    );
    await settings.updateUserInfo(
      name: 'Maya',
      nickname: 'Maya',
      birthday: '1996-04-18',
    );
    await wait(tester, 2500); // router rebuilds to /home once onboarded

    await go(tester, '/home');
    await shot(tester, '01_home');

    await go(tester, '/home/insights');
    await shot(tester, '02_insights');

    await go(tester, '/home/doctor');
    await shot(tester, '03_doctor');

    await go(tester, '/analytics');
    await shot(tester, '04_analytics');

    await go(tester, '/diagnosis');
    // Several offsets: the location chip resolves after a few seconds and we
    // want the earliest fully settled frame.
    await wait(tester, 1200);
    await shot(tester, '05_diagnosis_2s');
    await wait(tester, 1200);
    await shot(tester, '05_diagnosis_4s');
    await wait(tester, 1200);
    await shot(tester, '05_diagnosis_6s');
    await wait(tester, 2200);
    await shot(tester, '05_diagnosis_9s');

    final diet = find.textContaining('Diet');
    if (diet.evaluate().isNotEmpty) {
      await tester.tap(diet.first);
      await wait(tester, 2500);
      await shot(tester, '06_diet');
    }

    await go(tester, '/yoga');
    await shot(tester, '07_yoga');

    await go(tester, '/profile');
    await shot(tester, '08_profile');

    // Logging sheet for today, opened the same way the calendar opens it.
    await go(tester, '/home');
    final now = DateTime.now();
    final today =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final homeCtx = routerContext(tester);
    // ignore: unawaited_futures
    showModalBottomSheet<void>(
      context: homeCtx,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogBottomSheet(date: today),
    );
    await wait(tester, 1500);
    await shot(tester, '09_log_sheet');
  });
}
