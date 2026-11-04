import 'package:skribble_jaspr/src/ink.dart';
import 'package:test/test.dart';

void main() {
  group('customProperty', () {
    test('declares a custom property', () {
      expect(
        customProperty('--skribble-fill', 'rgb(1 2 3 / 50%)', 'fill'),
        '--skribble-fill: rgb(1 2 3 / 50%)',
      );
    });

    test('rejects values that end the declaration or open a block', () {
      for (final value in ['red;', 'red; color: blue', '{', '}']) {
        expect(
          () => customProperty('--skribble-fill', value, 'fill'),
          throwsA(
            isA<ArgumentError>().having((error) => error.name, 'name', 'fill'),
          ),
          reason: value,
        );
      }
    });
  });

  group('joinStyles', () {
    test('joins declarations once, skipping empty ones', () {
      expect(
        joinStyles(['--a: 1', null, '  ', ' b: 2; ', 'c: 3;']),
        '--a: 1; b: 2; c: 3',
      );
    });
  });

  group('mergeAttributes', () {
    test('appends a class and style entry instead of replacing them', () {
      final merged = mergeAttributes(
        classes: ['skribble-box', null],
        styles: ['--skribble-fill: pink'],
        defaults: {'type': 'button'},
        attributes: {
          'class': 'mine',
          'style': 'margin: 0',
          'type': 'submit',
          'id': 'go',
        },
      );

      expect(merged.classes, 'skribble-box mine');
      expect(merged.attributes, {
        'style': '--skribble-fill: pink; margin: 0',
        'type': 'submit',
        'id': 'go',
      });
    });

    test('adds no style attribute when there is nothing to declare', () {
      final merged = mergeAttributes(classes: ['skribble-box']);

      expect(merged.attributes, isEmpty);
    });
  });
}
