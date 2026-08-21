// This is a CLI driver, so prints are part of the user interface.
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';

import 'package:integration_test/integration_test_driver.dart';

/// Host-side driver for the screenshot integration test.
///
/// The test captures screenshots and stores their raw bytes in
/// `IntegrationTestWidgetsFlutterBinding.reportData`. This callback writes them
/// to the project's `.screenshots/` directory so they can be committed or
/// reviewed.
Future<void> main() async {
  await integrationDriver(
    responseDataCallback: writeScreenshots,
  );
}

Future<void> writeScreenshots(Map<String, dynamic>? data) async {
  if (data == null) {
    return;
  }

  final screenshots = data['screenshots'] as List<dynamic>?;
  if (screenshots == null || screenshots.isEmpty) {
    print('No screenshots found in reportData.');
    return;
  }

  final rootDir = Directory('.screenshots');
  await rootDir.create(recursive: true);

  for (final item in screenshots) {
    final map = item as Map<String, dynamic>;
    final name = map['screenshotName'] as String;
    final bytesList = (map['bytes'] as List<dynamic>).cast<int>();
    final file = File('${rootDir.path}/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(Uint8List.fromList(bytesList));
  }

  print('Wrote ${screenshots.length} screenshots to ${rootDir.path}');
}
