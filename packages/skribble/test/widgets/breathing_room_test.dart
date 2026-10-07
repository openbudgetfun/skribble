import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

/// The space between [text]'s glyphs and the edges of [control].
EdgeInsets _gaps(WidgetTester tester, Finder control, String text) {
  final box = tester.getRect(control);
  final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
  final glyphs = paragraph
      .getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: text.length),
      )
      .map((line) => line.toRect())
      .reduce((a, b) => a.expandToInclude(b))
      .shift(paragraph.localToGlobal(Offset.zero));
  return EdgeInsets.fromLTRB(
    glyphs.left - box.left,
    glyphs.top - box.top,
    box.right - glyphs.right,
    box.bottom - glyphs.bottom,
  );
}

/// Pumps [child] with the platform text scale set to [scale].
Future<void> _pumpScaled(
  WidgetTester tester,
  Widget child, {
  double scale = 1,
}) => pumpApp(
  tester,
  Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: Center(child: child),
    ),
  ),
);

void main() {
  group('controls keep the ink padding around their content', () {
    for (final scale in const [1.0, 1.5, 2.0]) {
      testWidgets('a button at ${scale}x text', (tester) async {
        await _pumpScaled(
          tester,
          WiredButton(onPressed: () {}, child: const Text('Let’s go')),
          scale: scale,
        );
        final button = find.byType(WiredButton);
        expect(
          tester.getSize(button).height,
          greaterThanOrEqualTo(kWiredButtonHeight),
        );
        final gaps = _gaps(tester, button, 'Let’s go');
        expect(gaps.top, greaterThanOrEqualTo(kWiredInkPadding.top));
        expect(gaps.bottom, greaterThanOrEqualTo(kWiredInkPadding.bottom));
        expect(gaps.left, greaterThanOrEqualTo(kWiredButtonPadding.left));
        expect(gaps.right, greaterThanOrEqualTo(kWiredButtonPadding.right));
      });

      testWidgets('a chip at ${scale}x text', (tester) async {
        await _pumpScaled(
          tester,
          WiredChoiceChip(label: const Text('Playful'), selected: true),
          scale: scale,
        );
        final chip = find.byType(WiredChoiceChip);
        expect(
          tester.getSize(chip).height,
          greaterThanOrEqualTo(kWiredChipHeight),
        );
        final gaps = _gaps(tester, chip, 'Playful');
        expect(gaps.top, greaterThanOrEqualTo(kWiredInkPadding.top));
        expect(gaps.bottom, greaterThanOrEqualTo(kWiredInkPadding.bottom));
      });
    }

    testWidgets('a large label grows the button instead of crowding it', (
      tester,
    ) async {
      await _pumpScaled(
        tester,
        WiredButton(
          onPressed: () {},
          child: const Text('Let’s go', style: TextStyle(fontSize: 28)),
        ),
      );
      final button = find.byType(WiredButton);
      expect(tester.getSize(button).height, greaterThan(kWiredButtonHeight));
      final gaps = _gaps(tester, button, 'Let’s go');
      expect(gaps.top, greaterThanOrEqualTo(kWiredInkPadding.top));
      expect(gaps.bottom, greaterThanOrEqualTo(kWiredInkPadding.bottom));
    });
  });

  testWidgets('a date and time picker fits a phone without failing', (
    tester,
  ) async {
    await _pumpScaled(
      tester,
      SizedBox(
        width: 296,
        child: WiredCupertinoDatePicker(
          initialDateTime: DateTime(2026, 10, 7, 9, 30),
          onDateTimeChanged: (_) {},
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(WiredCupertinoDatePicker)).width, 296);
  });

  group('a banner', () {
    Widget banner() => WiredMaterialBanner(
      content: const Text('Your account is about to expire.'),
      actions: [
        WiredTextButton(onPressed: () {}, child: const Text('Dismiss')),
        WiredTextButton(onPressed: () {}, child: const Text('Renew')),
      ],
    );

    testWidgets('keeps actions beside the message when there is room', (
      tester,
    ) async {
      await _pumpScaled(tester, SizedBox(width: 700, child: banner()));
      final message = tester.getRect(
        find.text('Your account is about to expire.'),
      );
      final renew = tester.getRect(find.text('Renew'));
      expect(renew.left, greaterThan(message.right));
      expect(renew.top, lessThan(message.bottom));
    });

    testWidgets('moves actions below the message on a phone', (tester) async {
      await _pumpScaled(tester, SizedBox(width: 340, child: banner()));
      final message = tester.getRect(
        find.text('Your account is about to expire.'),
      );
      expect(
        tester.getRect(find.text('Renew')).top,
        greaterThan(message.bottom),
      );
    });
  });

  testWidgets('a Cupertino form section keeps its rows off the ink', (
    tester,
  ) async {
    await _pumpScaled(
      tester,
      const SizedBox(
        width: 320,
        child: WiredCupertinoFormSection(children: [Text('Name')]),
      ),
    );
    final section = find.byType(WiredCupertinoFormSection);
    final gaps = _gaps(tester, section, 'Name');
    // The section's own margin sits outside the ink; measure inside it.
    expect(gaps.left, greaterThanOrEqualTo(kWiredInkPadding.left));
    expect(gaps.top, greaterThanOrEqualTo(kWiredInkPadding.top));
  });
}
