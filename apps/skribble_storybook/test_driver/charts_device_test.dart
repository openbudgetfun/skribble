import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Saves native screenshots and the device's measured Flutter frame timings.
Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [arguments]) async {
    final file = File('../../.screenshots/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
    return bytes.isNotEmpty;
  },
  writeResponseOnFailure: true,
  responseDataCallback: (data) async {
    final label = Platform.environment['SKRIBBLE_DEVICE_LABEL'] ?? 'device';
    final file = File('../../.screenshots/charts/$label-performance.json');
    final report = <String, Object?>{...?data}..remove('screenshots');
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(report),
    );
  },
);
