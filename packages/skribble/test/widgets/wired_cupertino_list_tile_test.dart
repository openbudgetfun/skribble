import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> pumpSubject(
    WidgetTester tester, {
    Widget? leading,
    Widget? title = const Text('Title'),
    Widget? subtitle,
    Widget? trailing,
    String? additionalTrailingText,
    VoidCallback? onTap,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    String? semanticLabel,
  }) {
    return pumpApp(
      tester,
      Center(
        child: WiredCupertinoListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          additionalTrailingText: additionalTrailingText,
          onTap: onTap,
          backgroundColor: backgroundColor,
          padding: padding,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }

  group('WiredCupertinoListTile', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(WiredCupertinoListTile), findsOneWidget);
    });

    testWidgets('renders title content', (tester) async {
      await pumpSubject(tester, title: const Text('Page 1'));
      expect(find.text('Page 1'), findsOneWidget);
    });

    testWidgets('renders subtitle content', (tester) async {
      await pumpSubject(tester, subtitle: const Text('Description here'));
      expect(find.text('Description here'), findsOneWidget);
    });

    testWidgets('requires title or subtitle', (tester) async {
      expect(WiredCupertinoListTile.new, throwsAssertionError);
      expect(
        () => WiredCupertinoListTile(
          title: const Text('Both'),
          subtitle: const Text('Ok'),
        ),
        returnsNormally,
      );
    });

    testWidgets('renders leading widget', (tester) async {
      await pumpSubject(tester, leading: const Text('LEAD'));
      expect(find.text('LEAD'), findsOneWidget);
    });

    testWidgets('renders trailing widget', (tester) async {
      await pumpSubject(tester, trailing: const Text('>'));
      expect(find.text('>'), findsOneWidget);
    });

    testWidgets('renders additionalTrailingText', (tester) async {
      await pumpSubject(tester, additionalTrailingText: '12 KB');
      expect(find.text('12 KB'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var taps = 0;
      await pumpSubject(tester, onTap: () => taps++);
      await tester.tap(find.byType(WiredCupertinoListTile));
      expect(taps, 1);
    });

    testWidgets('registers tap callbacks for rapid interaction', (
      tester,
    ) async {
      var taps = 0;
      await pumpSubject(tester, onTap: () => taps++);
      await tester.tap(find.byType(WiredCupertinoListTile));
      await tester.tap(find.byType(WiredCupertinoListTile));
      await tester.tap(find.byType(WiredCupertinoListTile));
      expect(taps, 3);
    });

    testWidgets('exposes button semantics when tappable', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSubject(tester, onTap: () {}, semanticLabel: 'Open page');
      expect(find.bySemanticsLabel('Open page'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('paints a background when backgroundColor is set', (
      tester,
    ) async {
      await pumpSubject(tester, backgroundColor: Colors.blueGrey);
      final canvas = tester.widget<WiredCanvas>(
        find.byType(WiredCanvas),
      );
      expect(canvas.fillerType, RoughFilter.solidFiller);
      expect((canvas.painter as dynamic).fillColor, Colors.blueGrey);
    });

    testWidgets('does not paint a background by default', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(WiredCanvas), findsNothing);
    });

    testWidgets('applies custom padding', (tester) async {
      const padding = EdgeInsets.all(28);
      await pumpSubject(tester, padding: padding);
      final padded = tester.widget<Padding>(
        find
            .ancestor(
              of: find.text('Title'),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padded.padding, padding);
    });

    testWidgets('title uses the larger default text style', (tester) async {
      await pumpSubject(tester, subtitle: const Text('Sub'));
      final titleStyle = DefaultTextStyle.of(
        tester.element(find.text('Title')),
      ).style;
      final subtitleStyle = DefaultTextStyle.of(
        tester.element(find.text('Sub')),
      ).style;
      expect(titleStyle.fontSize, 17);
      expect(subtitleStyle.fontSize, 14);
      expect(subtitleStyle.color, Colors.grey); // disabled grey
    });
  });
}
