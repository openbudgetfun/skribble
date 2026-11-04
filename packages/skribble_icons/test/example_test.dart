import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../example/example.dart';

void main() {
  testWidgets('the package example resolves every icon it names', (
    tester,
  ) async {
    await tester.pumpWidget(
      SkribbleApp(wiredTheme: WiredThemeData(), home: const IconsExample()),
    );

    expect(find.byType(WiredSvgIcon), findsNWidgets(3));
    expect(tester.getSize(find.byType(WiredSvgIcon).first).width, 40);
    expect(tester.takeException(), isNull);
  });
}
