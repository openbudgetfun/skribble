import 'package:skribble_emoji_gen/emoji_art_compiler.dart';
import 'package:test/test.dart';

String svg(String body, {String root = ''}) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 36 36" $root>'
    '$body</svg>';

void main() {
  List<CompiledShape> compile(Map<String, String> sources, String key) =>
      EmojiArtCompiler(sources).compile(key);

  Matcher fails(String message) => throwsA(
    isA<EmojiArtException>().having(
      (error) => error.message,
      'message',
      contains(message),
    ),
  );

  test('turns elements into path data with inherited paint', () {
    final shapes = compile({
      'dot': svg(
        '<g fill="yellow" stroke="ink" stroke-width="1.5">'
        '<circle cx="18" cy="18" r="10"/>'
        '<rect x="2" y="2" width="4" height="4" fill="red"/>'
        '<line x1="0" y1="0" x2="4" y2="4" fill="none"/>'
        '</g>',
      ),
    }, 'dot');
    expect(shapes, hasLength(3));
    expect(shapes[0].fill, 'yellow');
    expect(shapes[0].stroke, 'ink');
    expect(shapes[0].width, 1.5);
    expect(shapes[0].d, startsWith('M28 18C'));
    expect(shapes[1].fill, 'red');
    expect(shapes[1].d, 'M2 2L6 2L6 6L2 6Z');
    expect(shapes[2].fill, isNull);
  });

  test('names parts from group ids and data-part', () {
    final shapes = compile({
      'face': svg(
        '<circle cx="18" cy="18" r="15" fill="yellow"/>'
        '<g id="eyes"><circle cx="12" cy="14" r="2" fill="ink"/></g>'
        '<path data-part="mouth" d="M12 24Q18 28 24 24" stroke="ink"/>',
      ),
    }, 'face');
    expect([for (final shape in shapes) shape.part], [null, 'eyes', 'mouth']);
  });

  test('applies transforms to geometry and stroke width', () {
    final shapes = compile({
      'line': svg(
        '<path d="M0 0L10 0" stroke="ink" transform="translate(2 3) scale(0.5)"/>',
      ),
    }, 'line');
    expect(shapes.single.d, 'M2 3L7 3');
    expect(shapes.single.width, 1);
  });

  test('includes other art with variants, remapped tokens, and data-as', () {
    final sources = {
      'head': svg(
        '<circle cx="18" cy="14" r="7" fill="skin" stroke="ink"/>'
        '<path data-variant="man" d="M11 10L25 10" stroke="hair"/>'
        '<path data-variant="woman" d="M11 10L25 20" stroke="hair"/>',
      ),
      'pair': svg(
        '<g data-include="head"/>'
        '<g data-include="head" data-as="woman" '
        'data-tokens="skin:skin2,hair:hair2" transform="translate(4 0)"/>',
      ),
    };
    final shapes = compile(sources, 'pair');
    // The first include keeps both variants; the second draws only the woman.
    expect(shapes, hasLength(5));
    expect(shapes[1].variant, 'man');
    expect(shapes[2].variant, 'woman');
    expect(shapes[3].fill, 'skin2');
    expect(shapes[4].stroke, 'hair2');
    expect(shapes[4].variant, isNull);
    expect(shapes[3].d, startsWith('M29 14C'));
  });

  test('clips to clip paths in the clipped element coordinates', () {
    final shapes = compile({
      'clipped': svg(
        '<defs><clipPath id="c"><rect x="0" y="0" width="10" height="10"/>'
        '</clipPath></defs>'
        '<g clip-path="url(#c)" transform="translate(5 5)">'
        '<circle cx="5" cy="5" r="8" fill="blue"/></g>',
      ),
    }, 'clipped');
    expect(shapes.single.clip, 'M5 5L15 5L15 15L5 15Z');
  });

  test('waves flags, clips the design to the cloth, and outlines it', () {
    final shapes = compile({
      'flag-xx': svg(
        '<rect x="2" y="8" width="32" height="20" fill="#FFFFFF"/>'
        '<circle cx="18" cy="18" r="6" fill="#bc002d"/>',
        root: 'data-warp="flag"',
      ),
    }, 'flag-xx');
    expect(shapes, hasLength(3));
    expect(shapes[0].fill, '#ffffff');
    expect(shapes.take(2).every((shape) => shape.clip != null), isTrue);
    expect(shapes.last.stroke, 'ink');
    expect(shapes.last.d, shapes.first.clip);
    expect(shapes.every((shape) => shape.part == 'flag'), isTrue);
  });

  group('rejects art that breaks the authoring rules:', () {
    test('wrong viewBox', () {
      expect(
        () => compile({
          'a': '<svg viewBox="0 0 24 24"><path d="M0 0" fill="ink"/></svg>',
        }, 'a'),
        fails('viewBox'),
      );
    });

    test('hex colours outside flags are still checked for form', () {
      expect(
        () => compile({'a': svg('<path d="M0 0L1 1" stroke="tomato"/>')}, 'a'),
        fails('unknown paint "tomato"'),
      );
    });

    test('hairline strokes', () {
      expect(
        () => compile({
          'a': svg('<path d="M0 0L1 1" stroke="ink" stroke-width="0.5"/>'),
        }, 'a'),
        fails('thinner than 0.75'),
      );
    });

    test('unknown variants', () {
      expect(
        () => compile({
          'a': svg('<path data-variant="robot" d="M0 0L1 1" stroke="ink"/>'),
        }, 'a'),
        fails('unknown variant'),
      );
    });

    test('missing and recursive includes', () {
      expect(
        () => compile({'a': svg('<g data-include="b"/>')}, 'a'),
        fails('no such art'),
      );
      expect(
        () => compile({'a': svg('<g data-include="a"/>')}, 'a'),
        fails('includes itself'),
      );
    });

    test('empty drawings and unknown warps', () {
      expect(() => compile({'a': svg('')}, 'a'), fails('draws nothing'));
      expect(
        () => compile({
          'a': svg('<path d="M0 0L1 1" stroke="ink"/>', root: 'data-warp="x"'),
        }, 'a'),
        fails('unknown warp'),
      );
    });
  });

  test('the token list matches the palette tokens art may use', () {
    expect(kEmojiTokens, containsAll(['ink', 'paper', 'skin', 'skin2-shade']));
    expect(kEmojiTokens.toSet(), hasLength(kEmojiTokens.length));
  });
}
