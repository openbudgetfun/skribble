import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('SkribbleLocalizations', () {
    test('is left-to-right for Latin locales', () {
      expect(
        const SkribbleLocalizations(Locale('en')).textDirection,
        TextDirection.ltr,
      );
      expect(
        const SkribbleLocalizations(Locale('fr', 'FR')).textDirection,
        TextDirection.ltr,
      );
    });

    test('is right-to-left for right-to-left languages', () {
      for (final languageCode in ['ar', 'he', 'fa', 'ur', 'ps', 'sd', 'yi']) {
        expect(
          SkribbleLocalizations(Locale(languageCode)).textDirection,
          TextDirection.rtl,
          reason: 'Expected $languageCode to be right-to-left',
        );
      }
    });

    test('is right-to-left when the script is right-to-left', () {
      expect(
        const SkribbleLocalizations(
          Locale.fromSubtags(
            languageCode: 'az',
            scriptCode: 'Arab',
          ),
        ).isRightToLeft,
        isTrue,
      );
    });

    test('provides the English widgets semantics labels', () {
      const localizations = SkribbleLocalizations(Locale('en'));

      expect(localizations.reorderItemToStart, 'Move to the start');
      expect(localizations.reorderItemToEnd, 'Move to the end');
      expect(localizations.copyButtonLabel, 'Copy');
      expect(localizations.noResultsFound, 'No results found');
    });

    test('delegate loads synchronously for every locale', () {
      const delegate = SkribbleLocalizationsDelegate();

      expect(delegate.isSupported(const Locale('ar')), isTrue);
      expect(delegate.shouldReload(delegate), isFalse);
      expect(
        delegate.load(const Locale('he')),
        completion(isA<WidgetsLocalizations>()),
      );
    });
  });
}
