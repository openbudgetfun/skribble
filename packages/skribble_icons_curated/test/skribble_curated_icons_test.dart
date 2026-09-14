import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons_curated/skribble_icons_curated.dart';

/// Looking the entry up at runtime keeps it out of a `const` expression, which
/// a null assertion cannot be part of.
final WiredSvgIconData _homeIcon = kSkribbleCuratedIcons[0xf001]!;

void main() {
  group('kSkribbleCuratedIcons', () {
    test('ships the curated set', () {
      expect(kSkribbleCuratedIcons, hasLength(30));
      expect(kSkribbleCuratedIconCodePoints, hasLength(30));
    });

    test('geometry and identifier maps agree', () {
      expect(
        kSkribbleCuratedIconCodePoints.values.toSet(),
        kSkribbleCuratedIcons.keys.toSet(),
        reason: 'Every identifier must resolve to a generated codepoint.',
      );
    });

    test('every entry has primitives and positive dimensions', () {
      for (final entry in kSkribbleCuratedIcons.entries) {
        final label = '0x${entry.key.toRadixString(16)}';
        expect(entry.value.primitives, isNotEmpty, reason: '$label empty');
        expect(entry.value.width, greaterThan(0), reason: '$label width');
        expect(entry.value.height, greaterThan(0), reason: '$label height');
      }
    });

    test('codepoints stay inside the reserved simple band', () {
      for (final codePoint in kSkribbleCuratedIcons.keys) {
        expect(codePoint, inInclusiveRange(0xf001, 0xf0ff));
      }
    });
  });

  group('lookupSkribbleCuratedIconByIdentifier', () {
    test('resolves known identifiers', () {
      expect(lookupSkribbleCuratedIconByIdentifier('home'), isNotNull);
      expect(lookupSkribbleCuratedIconByIdentifier('search'), isNotNull);
      expect(lookupSkribbleCuratedIconByIdentifier('notification'), isNotNull);
    });

    test('returns null for unknown identifiers', () {
      expect(lookupSkribbleCuratedIconByIdentifier('does_not_exist'), isNull);
      expect(lookupSkribbleCuratedIconByIdentifier(''), isNull);
    });

    test('counts match the generated maps', () {
      expect(skribbleCuratedIconCount, 30);
      expect(skribbleCuratedIconIdentifiers, hasLength(30));
      expect(skribbleCuratedIconCodePoints, hasLength(30));
    });
  });

  group('SkribbleIcon', () {
    Widget wrap(Widget child) => MaterialApp(
      home: WiredTheme(data: WiredThemeData(), child: child),
    );

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(wrap(SkribbleIcon(data: _homeIcon)));
      expect(find.byType(SkribbleIcon), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(wrap(SkribbleIcon(data: _homeIcon, size: 48)));

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 48);
      expect(sizedBox.height, 48);
    });

    testWidgets('adds semantics label when provided', (tester) async {
      await tester.pumpWidget(
        wrap(SkribbleIcon(data: _homeIcon, semanticLabel: 'Test icon')),
      );

      expect(find.bySemanticsLabel('Test icon'), findsOneWidget);
    });
  });
}
