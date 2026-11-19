import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

const _label = 'Notifications';
const _style = TextStyle(fontSize: 20);

/// The scale [text] is painted at: its painted width over its laid-out one.
double _scaleOf(WidgetTester tester, Finder text) =>
    tester.getRect(text).width / tester.getSize(text).width;

/// The width [data] needs on one line at full size in [style], measured
/// under the same host the tests pump into.
Future<double> _natural(
  WidgetTester tester,
  String data, [
  TextStyle style = _style,
]) async {
  await pumpWired(
    tester,
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [Text(data, style: style, maxLines: 1, softWrap: false)],
    ),
  );
  return tester.getSize(find.text(data)).width;
}

RenderParagraph _paragraph(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text));

/// Loads the bundled Noto Sketch font, the default skribble typeface, from
/// its package next to this one.
Future<void> _loadNotoSketch() async {
  const root = '../skribble_font_noto_sketch';
  final loader = FontLoader(
    'packages/${WiredFont.notoSketch.package}/'
    '${WiredFont.notoSketch.familyFor(WiredRoughness.playful)}',
  );
  final bytes = File(
    '$root/assets/fonts/SkribbleNotoSketch-Regular.ttf',
  ).readAsBytesSync();
  loader.addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}

Widget _inWidth(double width, Widget child) => SizedBox(
  width: width,
  child: Align(alignment: Alignment.centerLeft, child: child),
);

void main() {
  group('WiredFitText', () {
    group('rendering', () {
      testWidgets('draws a label that fits at its full size', (tester) async {
        await pumpWired(
          tester,
          _inWidth(400, const WiredFitText(_label, style: _style)),
        );

        expect(find.text(_label), findsOneWidget);
        expect(_scaleOf(tester, find.text(_label)), closeTo(1, 0.001));
        expect(_paragraph(tester, _label).didExceedMaxLines, isFalse);
      });

      testWidgets('shrinks a label that is too wide to fit on one line', (
        tester,
      ) async {
        final natural = await _natural(tester, _label);
        final width = natural * 0.9;
        await pumpWired(
          tester,
          _inWidth(width, const WiredFitText(_label, style: _style)),
        );

        final text = find.text(_label);
        expect(_scaleOf(tester, text), closeTo(0.9, 0.001));
        expect(tester.getRect(text).width, closeTo(width, 0.01));
        // The whole label is drawn: no ellipsis, no second line.
        expect(_paragraph(tester, _label).didExceedMaxLines, isFalse);
        expect(tester.takeException(), isNull);
      });

      testWidgets('stops at minScale and adds an ellipsis past it', (
        tester,
      ) async {
        final natural = await _natural(tester, _label);
        final width = natural * 0.5;
        await pumpWired(
          tester,
          _inWidth(width, const WiredFitText(_label, style: _style)),
        );

        final text = find.text(_label);
        expect(_scaleOf(tester, text), closeTo(kWiredFitTextMinScale, 0.001));
        expect(tester.getRect(text).width, lessThanOrEqualTo(width + 0.01));
        expect(_paragraph(tester, _label).didExceedMaxLines, isTrue);
      });

      testWidgets('fits a long label in the default Noto Sketch font', (
        tester,
      ) async {
        await _loadNotoSketch();
        final noto = TextStyle(
          fontFamily: WiredFont.notoSketch.familyFor(WiredRoughness.playful),
          package: WiredFont.notoSketch.package,
          fontSize: 14,
        );
        final natural = await _natural(tester, _label, noto);
        // The real font, not the square test glyphs, set the width.
        final testGlyphs = await _natural(
          tester,
          _label,
          const TextStyle(fontSize: 14, fontFamily: 'FlutterTest'),
        );
        expect(natural, lessThan(testGlyphs * 0.8));

        await pumpWired(
          tester,
          _inWidth(natural * 0.85, WiredFitText(_label, style: noto)),
        );

        final text = find.text(_label);
        expect(_scaleOf(tester, text), closeTo(0.85, 0.001));
        expect(_paragraph(tester, _label).didExceedMaxLines, isFalse);
      });
    });

    group('dimensions', () {
      testWidgets('takes its full natural size when the width is unbounded', (
        tester,
      ) async {
        await pumpWired(
          tester,
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [WiredFitText(_label, style: _style)],
          ),
        );

        final size = tester.getSize(find.byType(WiredFitText));
        expect(size.width, closeTo(await _natural(tester, _label), 0.01));
        expect(size.height, greaterThan(0));
      });

      testWidgets('shrinks its height with its width', (tester) async {
        await pumpWired(
          tester,
          _inWidth(1000, const WiredFitText(_label, style: _style)),
        );
        final fullHeight = tester.getSize(find.byType(WiredFitText)).height;

        await pumpWired(
          tester,
          _inWidth(
            await _natural(tester, _label) * 0.8,
            const WiredFitText(_label, style: _style),
          ),
        );

        expect(
          tester.getSize(find.byType(WiredFitText)).height,
          closeTo(fullHeight * 0.8, 0.01),
        );
      });

      testWidgets('reports its natural width to IntrinsicWidth', (
        tester,
      ) async {
        await pumpWired(
          tester,
          const IntrinsicWidth(child: WiredFitText(_label, style: _style)),
        );

        expect(
          tester.getSize(find.byType(WiredFitText)).width,
          closeTo(await _natural(tester, _label), 0.01),
        );
      });

      testWidgets('keeps its baseline in step with the scale', (tester) async {
        final natural = await _natural(tester, _label);
        final reference = await _natural(tester, 'Ref');
        await pumpWired(
          tester,
          _inWidth(
            reference + natural * 0.8,
            const Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('Ref', style: _style),
                Flexible(child: WiredFitText(_label, style: _style)),
              ],
            ),
          ),
        );

        // Both labels share one style, so one baseline distance serves both.
        final painter = TextPainter(
          text: _paragraph(tester, _label).text,
          textDirection: TextDirection.ltr,
        )..layout();
        final baseline = painter.computeDistanceToActualBaseline(
          TextBaseline.alphabetic,
        );
        painter.dispose();

        final scale = _scaleOf(tester, find.text(_label));
        expect(scale, closeTo(0.8, 0.01));
        expect(
          tester.getRect(find.text(_label)).top + baseline * scale,
          closeTo(tester.getRect(find.text('Ref')).top + baseline, 0.01),
        );
      });
    });

    group('layout protocol', () {
      testWidgets('reports a scaled height to IntrinsicHeight', (
        tester,
      ) async {
        final natural = await _natural(tester, _label);
        await pumpWired(
          tester,
          _inWidth(1000, const WiredFitText(_label, style: _style)),
        );
        final fullHeight = tester.getSize(find.byType(WiredFitText)).height;

        await pumpWired(
          tester,
          _inWidth(
            natural * 0.8,
            const IntrinsicHeight(child: WiredFitText(_label, style: _style)),
          ),
        );

        final box = tester.renderObject<RenderBox>(find.byType(WiredFitText));
        expect(box.getMinIntrinsicWidth(100), closeTo(natural * 0.75, 0.01));
        expect(
          box.getMaxIntrinsicHeight(natural * 0.8),
          closeTo(fullHeight * 0.8, 0.01),
        );
        expect(
          box.getMinIntrinsicHeight(natural * 0.5),
          closeTo(fullHeight * 0.75, 0.01),
        );
        expect(
          tester.getSize(find.byType(WiredFitText)).height,
          closeTo(fullHeight * 0.8, 0.01),
        );
      });

      testWidgets('dry layout and dry baseline match the real layout', (
        tester,
      ) async {
        final natural = await _natural(tester, _label);
        final width = natural * 0.8;
        await pumpWired(
          tester,
          _inWidth(width, const WiredFitText(_label, style: _style)),
        );

        final box = tester.renderObject<RenderBox>(find.byType(WiredFitText));
        final constraints = BoxConstraints(maxWidth: width);
        expect(box.getDryLayout(constraints), box.size);

        final dryBaseline = box.getDryBaseline(
          constraints,
          TextBaseline.alphabetic,
        );
        final painter = TextPainter(
          text: _paragraph(tester, _label).text,
          textDirection: TextDirection.ltr,
        )..layout();
        final baseline = painter.computeDistanceToActualBaseline(
          TextBaseline.alphabetic,
        );
        painter.dispose();
        expect(dryBaseline, closeTo(baseline * 0.8, 0.01));

        // A tight width wider than the label centres it vertically and
        // starts it at the left.
        final tight = BoxConstraints.tight(Size(natural + 40, 100));
        expect(box.getDryLayout(tight), Size(natural + 40, 100));
        final tightBaseline = box.getDryBaseline(
          tight,
          TextBaseline.alphabetic,
        )!;
        expect(tightBaseline, greaterThan(baseline));
      });

      testWidgets('describes its scale and floor for debugging', (
        tester,
      ) async {
        await pumpWired(
          tester,
          _inWidth(
            await _natural(tester, _label) * 0.9,
            const WiredFitText(_label, style: _style),
          ),
        );

        final description = tester
            .renderObject(find.byType(WiredFitText))
            .toStringShallow();
        expect(description, contains('minScale: 0.8'));
        expect(description, contains('scale: 0.9'));
        expect(description, contains('alignment: AlignmentDirectional'));
        expect(description, contains('textDirection: ltr'));
      });
    });

    group('interaction', () {
      testWidgets('a shrunk label still takes taps across its painted area', (
        tester,
      ) async {
        var taps = 0;
        await pumpWired(
          tester,
          _inWidth(
            await _natural(tester, _label) * 0.8,
            GestureDetector(
              onTap: () => taps++,
              child: const WiredFitText(_label, style: _style),
            ),
          ),
        );

        await tester.tap(find.text(_label));
        expect(taps, 1);
      });

      testWidgets('fits a button label and the button still presses', (
        tester,
      ) async {
        var pressed = 0;
        await pumpWired(
          tester,
          SizedBox(
            width: 120,
            child: WiredFilledButton(
              onPressed: () => pressed++,
              child: const WiredFitText('Save and continue'),
            ),
          ),
        );

        final text = find.text('Save and continue');
        expect(_scaleOf(tester, text), lessThan(1));
        expect(
          tester.getRect(text).right,
          lessThanOrEqualTo(
            tester.getRect(find.byType(WiredFilledButton)).right,
          ),
        );
        await tester.tap(find.byType(WiredFilledButton));
        expect(pressed, 1);
      });
    });

    group('state', () {
      testWidgets('rescales when the label grows', (tester) async {
        final width = await _natural(tester, 'Inbox') + 4;
        await pumpWired(
          tester,
          _inWidth(width, const WiredFitText('Inbox', style: _style)),
        );
        expect(_scaleOf(tester, find.text('Inbox')), closeTo(1, 0.001));

        await pumpWired(
          tester,
          _inWidth(width, const WiredFitText('Inboxes', style: _style)),
        );
        expect(_scaleOf(tester, find.text('Inboxes')), lessThan(1));
        expect(
          tester.getRect(find.text('Inboxes')).width,
          lessThanOrEqualTo(width + 0.01),
        );
      });

      testWidgets('follows a new alignment and text direction', (
        tester,
      ) async {
        Widget host(TextDirection direction, AlignmentGeometry alignment) =>
            Directionality(
              textDirection: direction,
              child: SizedBox(
                width: 400,
                child: WiredFitText(
                  'Hi',
                  style: _style,
                  alignment: alignment,
                ),
              ),
            );

        await pumpWired(
          tester,
          host(TextDirection.ltr, AlignmentDirectional.centerStart),
        );
        final box = tester.getRect(find.byType(WiredFitText));
        expect(tester.getRect(find.text('Hi')).left, closeTo(box.left, 0.01));

        await pumpWired(
          tester,
          host(TextDirection.rtl, AlignmentDirectional.centerStart),
        );
        expect(
          tester.getRect(find.text('Hi')).right,
          closeTo(box.right, 0.01),
        );

        await pumpWired(tester, host(TextDirection.rtl, Alignment.center));
        expect(
          tester.getRect(find.text('Hi')).center.dx,
          closeTo(box.center.dx, 0.01),
        );
      });

      testWidgets('follows a new minScale', (tester) async {
        final width = await _natural(tester, _label) * 0.5;
        await pumpWired(
          tester,
          _inWidth(width, const WiredFitText(_label, style: _style)),
        );
        expect(_scaleOf(tester, find.text(_label)), closeTo(0.75, 0.001));

        await pumpWired(
          tester,
          _inWidth(
            width,
            const WiredFitText(_label, style: _style, minScale: 0.5),
          ),
        );
        expect(_scaleOf(tester, find.text(_label)), closeTo(0.5, 0.001));
        expect(_paragraph(tester, _label).didExceedMaxLines, isFalse);
      });
    });

    group('edge cases', () {
      testWidgets('minFontSize wins when it is the higher floor', (
        tester,
      ) async {
        const small = TextStyle(fontSize: 10);
        await pumpWired(
          tester,
          _inWidth(
            await _natural(tester, _label, small) * 0.5,
            const WiredFitText(_label, style: small, minScale: 0.5),
          ),
        );

        // 9 px is 0.9 of 10 px, a higher floor than 0.5.
        expect(_scaleOf(tester, find.text(_label)), closeTo(0.9, 0.001));
      });

      testWidgets('a minScale of 1 never shrinks, only ellipsizes', (
        tester,
      ) async {
        await pumpWired(
          tester,
          _inWidth(
            await _natural(tester, _label) * 0.6,
            const WiredFitText(_label, style: _style, minScale: 1),
          ),
        );

        expect(_scaleOf(tester, find.text(_label)), closeTo(1, 0.001));
        expect(_paragraph(tester, _label).didExceedMaxLines, isTrue);
      });

      testWidgets('handles an empty label and a zero width', (tester) async {
        await pumpWired(tester, _inWidth(0, const WiredFitText(_label)));
        expect(tester.takeException(), isNull);
        expect(tester.getSize(find.byType(WiredFitText)).width, 0);

        await pumpWired(tester, _inWidth(100, const WiredFitText('')));
        expect(tester.takeException(), isNull);
        expect(tester.getSize(find.byType(WiredFitText)).width, 0);
      });

      testWidgets('keeps a label with a line break on one line', (
        tester,
      ) async {
        await pumpWired(
          tester,
          _inWidth(400, const WiredFitText('Two\nlines', style: _style)),
        );

        final paragraph = _paragraph(tester, 'Two\nlines');
        expect(paragraph.didExceedMaxLines, isTrue);
        expect(
          tester.getSize(find.byType(WiredFitText)).height,
          lessThan(_style.fontSize! * 2),
        );
      });

      testWidgets('wrap merges its style and fits any child', (tester) async {
        await pumpWired(
          tester,
          _inWidth(
            await _natural(tester, _label) * 0.9,
            const WiredFitText.wrap(style: _style, child: Text(_label)),
          ),
        );

        final text = find.text(_label);
        expect(
          tester.widget<RichText>(find.byType(RichText)).text.style?.fontSize,
          20,
        );
        expect(_scaleOf(tester, text), closeTo(0.9, 0.001));
        expect(_paragraph(tester, _label).maxLines, 1);
      });

      testWidgets('rejects a minScale outside (0, 1]', (tester) async {
        expect(() => WiredFitText(_label, minScale: 0), throwsAssertionError);
        expect(
          () => WiredFitText(_label, minScale: 1.5),
          throwsAssertionError,
        );
      });
    });

    group('accessibility and direction', () {
      testWidgets('reads its full label even when ellipsized', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpWired(
          tester,
          _inWidth(
            await _natural(tester, _label) * 0.3,
            const WiredFitText(_label, style: _style),
          ),
        );

        expect(find.bySemanticsLabel(_label), findsOneWidget);
        handle.dispose();
      });

      testWidgets('reads semanticsLabel in place of the text', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpWired(
          tester,
          const WiredFitText('3 new', semanticsLabel: 'Three new messages'),
        );

        expect(find.bySemanticsLabel('Three new messages'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('sits at the end of a tight width in right-to-left text', (
        tester,
      ) async {
        await pumpWiredRtl(
          tester,
          const SizedBox(
            width: 400,
            child: WiredFitText('Hi', style: _style),
          ),
        );

        final box = tester.getRect(find.byType(WiredFitText));
        final text = tester.getRect(find.text('Hi'));
        expect(text.right, closeTo(box.right, 0.01));
        expect(text.left, greaterThan(box.left));
      });

      testWidgets('keeps the reader text scale and its floor scales too', (
        tester,
      ) async {
        await pumpWiredScaled(
          tester,
          _inWidth(
            await _natural(tester, _label) * 0.5,
            const WiredFitText(_label, style: _style),
          ),
        );

        // At 2x text the label is 40 px; three quarters of that is 30 px,
        // still larger than the unscaled 20 px label.
        final text = find.text(_label);
        expect(_scaleOf(tester, text), closeTo(0.75, 0.001));
        expect(
          tester.getRect(text).height,
          greaterThan(tester.getSize(text).height * 0.74),
        );
        expect(_paragraph(tester, _label).textScaler, TextScaler.linear(2));
      });
    });
  });
}
