import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

Widget _host(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  testWidgets('of falls back to the default theme without a scope', (
    tester,
  ) async {
    late WiredThemeData? maybe;
    late WiredThemeData resolved;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) {
            maybe = WiredThemeScope.maybeOf(context);
            resolved = WiredThemeScope.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(maybe, isNull);
    expect(resolved, WiredThemeData.defaultTheme);
  });

  testWidgets('renders its child and exposes the installed theme', (
    tester,
  ) async {
    final data = WiredThemeData(textColor: const Color(0xFF123456));
    late WiredThemeData found;
    await tester.pumpWidget(
      _host(
        WiredThemeScope(
          data: data,
          child: Builder(
            builder: (context) {
              found = WiredTheme.of(context);
              return const Text('ink');
            },
          ),
        ),
      ),
    );

    expect(find.text('ink'), findsOneWidget);
    expect(found, data);
  });

  testWidgets('text inherits the qualified family, fallbacks, and color', (
    tester,
  ) async {
    final data = WiredThemeData(
      font: WiredFont.notoSketch,
      fontFamilyFallback: const ['SkribbleNotoSketchJP'],
      textColor: const Color(0xFF123456),
    );
    late TextStyle style;
    await tester.pumpWidget(
      _host(
        WiredThemeScope(
          data: data,
          child: Builder(
            builder: (context) {
              style = DefaultTextStyle.of(context).style;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(
      style.fontFamily,
      'packages/skribble_font_noto_sketch/SkribbleNotoSketch',
    );
    expect(style.fontFamilyFallback, ['SkribbleNotoSketchJP']);
    expect(style.color, const Color(0xFF123456));
  });

  testWidgets('custom app fonts stay unqualified', (tester) async {
    late TextStyle style;
    await tester.pumpWidget(
      _host(
        WiredThemeScope(
          data: WiredThemeData(fontFamily: 'MyInk'),
          child: Builder(
            builder: (context) {
              style = DefaultTextStyle.of(context).style;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(style.fontFamily, 'MyInk');
    expect(style.fontFamilyFallback, isNull);
  });

  testWidgets('a nested scope overrides the outer theme for its subtree', (
    tester,
  ) async {
    final outer = WiredThemeData(font: WiredFont.noto);
    final inner = WiredThemeData(font: WiredFont.notoLively);
    late WiredThemeData outerFound;
    late WiredThemeData innerFound;
    await tester.pumpWidget(
      _host(
        WiredThemeScope(
          data: outer,
          child: Column(
            children: [
              Builder(
                builder: (context) {
                  outerFound = WiredThemeScope.of(context);
                  return const SizedBox();
                },
              ),
              WiredThemeScope(
                data: inner,
                child: Builder(
                  builder: (context) {
                    innerFound = WiredThemeScope.of(context);
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(outerFound, outer);
    expect(innerFound, inner);
  });

  testWidgets('rebuilds dependents when the theme changes', (tester) async {
    var builds = 0;
    late WiredThemeData found;
    final child = Builder(
      builder: (context) {
        builds++;
        found = WiredThemeScope.of(context);
        return const SizedBox();
      },
    );

    await tester.pumpWidget(
      _host(WiredThemeScope(data: WiredThemeData(), child: child)),
    );
    await tester.pumpWidget(
      _host(WiredThemeScope(data: WiredThemeData(), child: child)),
    );
    expect(builds, 1, reason: 'an equal theme does not notify');

    final changed = WiredThemeData(font: WiredFont.noto);
    await tester.pumpWidget(
      _host(WiredThemeScope(data: changed, child: child)),
    );
    expect(builds, 2);
    expect(found, changed);
  });

  testWidgets('passes the motion policy to its subtree', (tester) async {
    late bool enabled;
    await tester.pumpWidget(
      _host(
        WiredThemeScope(
          data: WiredThemeData(motionEnabled: false),
          child: Builder(
            builder: (context) {
              enabled = WiredMotion.enabledOf(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(enabled, isFalse);
  });
}
