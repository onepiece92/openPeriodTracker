import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Host-side driver for integration_test/screenshots_test.dart.
///
/// Run with:
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/screenshots_test.dart -d `<simulator-udid>`
///
/// The test writes its captures itself (see SHOT_DIR in the test file); the
/// onScreenshot hook below is kept only as a fallback for binding.takeScreenshot.
/// Raw captures are then composed into store images by design/screenshots/compose.py.
Future<void> main() async {
  final dir = Directory('design/screenshots/raw')..createSync(recursive: true);
  await integrationDriver(
    onScreenshot:
        (String name, List<int> bytes, [Map<String, Object?>? args]) async {
          final file = File('${dir.path}/$name.png');
          await file.writeAsBytes(bytes);
          stdout.writeln('saved ${file.path} (${bytes.length} bytes)');
          return true;
        },
  );
}
