import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

/// Saves the device tour's captures and findings on the host, in
/// `SKRIBBLE_TOUR_DIR` (default `../../.screenshots/devices`).
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    final dir = Directory(
      Platform.environment['SKRIBBLE_TOUR_DIR'] ?? '../../.screenshots/devices',
    )..createSync(recursive: true);
    final shots = (data?['shots'] as Map<String, Object?>?) ?? const {};
    for (final MapEntry(:key, :value) in shots.entries) {
      File('${dir.path}/$key.png').writeAsBytesSync(base64Decode('$value'));
    }
    final findings = (data?['findings'] as List<Object?>?) ?? const [];
    File('${dir.path}/findings.txt').writeAsStringSync(findings.join('\n'));
  },
  writeResponseOnFailure: true,
);
