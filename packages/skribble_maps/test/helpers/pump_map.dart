import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

Widget buildTestMapView(BuildContext context) {
  return const ColoredBox(color: Color(0xFFF3F0E8));
}

Future<void> pumpMapApp(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(400, 400),
  WiredThemeData? theme,
}) {
  return tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: WiredTheme(
          data: theme ?? WiredThemeData(),
          child: Center(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}
