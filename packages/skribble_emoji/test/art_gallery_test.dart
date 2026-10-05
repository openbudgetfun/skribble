import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';
import 'package:skribble_emoji_gen/emoji_art_compiler.dart';

/// Every art source, by key.
Map<String, String> _sources() => {
  for (final file in Directory(
    'art',
  ).listSync(recursive: true).whereType<File>())
    if (file.path.endsWith('.svg'))
      file.uri.pathSegments.last.replaceAll('.svg', ''): file
          .readAsStringSync(),
};

/// Converts compiled shapes into runtime art.
EmojiArt _art(List<CompiledShape> shapes) {
  EmojiPaint? paint(String? value) {
    if (value == null) return null;
    if (value.startsWith('#')) {
      return EmojiPaint(0xFF000000 | int.parse(value.substring(1), radix: 16));
    }
    return switch (EmojiToken.fromArtName(value)) {
      null => throw StateError('Unknown token $value'),
      final token => [
        for (final candidate in _paints)
          if (candidate.token == token) candidate,
      ].single,
    };
  }

  return EmojiArt([
    for (final shape in shapes)
      EmojiShape(
        shape.d,
        fill: paint(shape.fill),
        stroke: paint(shape.stroke),
        width: shape.width,
        part: shape.part,
        variant: switch (shape.variant) {
          null => null,
          final name => EmojiVariant.values.byName(name),
        },
        clip: shape.clip,
        evenOdd: shape.evenOdd,
      ),
  ]);
}

const List<EmojiPaint> _paints = [
  EmojiPaint.ink, EmojiPaint.paper, EmojiPaint.white, EmojiPaint.black, //
  EmojiPaint.yellow, EmojiPaint.yellowShade, EmojiPaint.orange, //
  EmojiPaint.orangeShade, EmojiPaint.red, EmojiPaint.redShade, //
  EmojiPaint.coral, EmojiPaint.pink, EmojiPaint.pinkShade, //
  EmojiPaint.magenta, EmojiPaint.purple, EmojiPaint.purpleShade, //
  EmojiPaint.lilac, EmojiPaint.blue, EmojiPaint.blueShade, EmojiPaint.sky, //
  EmojiPaint.teal, EmojiPaint.green, EmojiPaint.greenShade, EmojiPaint.leaf, //
  EmojiPaint.lime, EmojiPaint.mint, EmojiPaint.brown, EmojiPaint.brownShade, //
  EmojiPaint.tan, EmojiPaint.cream, EmojiPaint.grey, EmojiPaint.greyShade, //
  EmojiPaint.silver, EmojiPaint.cheek, EmojiPaint.skin, EmojiPaint.skinShade, //
  EmojiPaint.hair, EmojiPaint.skin2, EmojiPaint.skin2Shade, EmojiPaint.hair2,
];

void main() {
  test('every emoji token is known to the art compiler', () {
    expect(
      [for (final token in EmojiToken.values) token.artName],
      kEmojiTokens,
    );
    expect(_paints.map((paint) => paint.token), EmojiToken.values);
  });

  test('every art source compiles under the authoring rules', () {
    final sources = _sources();
    final compiler = EmojiArtCompiler(sources);
    final failures = <String>[];
    for (final key in sources.keys) {
      try {
        compiler.compile(key);
      } on Object catch (error) {
        failures.add('$error');
      }
    }
    expect(failures, isEmpty);
  });

  // Contact sheets for reviewing art. A no-op unless EMOJI_GALLERY is set to
  // `all`, an art folder (`animals`), or comma-separated art keys. Sheets go
  // to ../../.screenshots/emoji.
  test('render emoji art contact sheets', () async {
    final filter = Platform.environment['EMOJI_GALLERY'];
    if (filter == null) return;
    final font = FontLoader('Gallery')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File(
              '../skribble_font_recursive/assets/fonts/SkribbleGentle-Regular.ttf',
            ).readAsBytesSync(),
          ),
        ),
      );
    await font.load();

    final sources = _sources();
    final compiler = EmojiArtCompiler(sources);
    final folders = {
      for (final file in Directory(
        'art',
      ).listSync(recursive: true).whereType<File>())
        if (file.path.endsWith('.svg'))
          file.uri.pathSegments.last.replaceAll('.svg', ''):
              file.uri.pathSegments[file.uri.pathSegments.length - 2],
    };
    final wanted = filter.split(',').map((value) => value.trim()).toSet();
    final keys = [
      for (final key in sources.keys)
        if (filter == 'all' ||
            wanted.contains(key) ||
            wanted.contains(folders[key]))
          key,
    ]..sort();
    final name = filter.length > 40
        ? 'selection-${filter.hashCode.abs()}'
        : filter.replaceAll(',', '+');
    final theme = WiredThemeData();

    const columns = 8;
    const cell = 132.0;
    final scale = double.parse(
      Platform.environment['EMOJI_GALLERY_SCALE'] ?? '2',
    );
    for (var page = 0; page * 48 < keys.length; page++) {
      final pageKeys = keys.skip(page * 48).take(48).toList();
      final rows = (pageKeys.length / columns).ceil();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)
        ..drawColor(const Color(0xFFFFFAF0), BlendMode.src)
        ..scale(scale);
      for (final (index, key) in pageKeys.indexed) {
        final art = _art(compiler.compile(key));
        final x = (index % columns) * cell;
        final y = (index ~/ columns) * cell;
        canvas
          ..save()
          ..translate(x + 10, y + 6);
        EmojiDrawing.art(
          art,
          size: 72,
          config: emojiDrawConfig(theme, 72),
          seed: key.hashCode,
        ).paint(canvas);
        canvas
          ..translate(80, 0)
          ..save();
        EmojiDrawing.art(
          art,
          size: 24,
          config: emojiDrawConfig(theme, 24),
          seed: key.hashCode,
        ).paint(canvas);
        canvas.restore();
        final variants = art.shapes.any((shape) => shape.variant != null);
        final toned = art.shapes.any(
          (shape) =>
              shape.fill?.token == EmojiToken.skin ||
              shape.stroke?.token == EmojiToken.skin,
        );
        if (variants) {
          for (final (row, variant) in EmojiVariant.values.indexed) {
            canvas
              ..save()
              ..translate(0, 28 + row * 22);
            EmojiDrawing.art(
              art,
              size: 20,
              config: emojiDrawConfig(theme, 20),
              variant: variant,
              seed: key.hashCode,
            ).paint(canvas);
            canvas.restore();
          }
        } else if (toned) {
          for (final (row, tone) in [
            EmojiSkinTone.light,
            EmojiSkinTone.medium,
            EmojiSkinTone.dark,
          ].indexed) {
            canvas
              ..save()
              ..translate(0, 28 + row * 22);
            EmojiDrawing.art(
              art,
              size: 20,
              config: emojiDrawConfig(theme, 20),
              tone: tone,
              tone2: tone,
              seed: key.hashCode,
            ).paint(canvas);
            canvas.restore();
          }
        }
        canvas.restore();
        final paragraph =
            (ui.ParagraphBuilder(
                    ui.ParagraphStyle(fontSize: 11, fontFamily: 'Gallery'),
                  )
                  ..pushStyle(ui.TextStyle(color: const Color(0xFF34283F)))
                  ..addText(key))
                .build()
              ..layout(const ui.ParagraphConstraints(width: cell - 8));
        canvas.drawParagraph(paragraph, Offset(x + 6, y + 96));
        paragraph.dispose();
      }
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        (columns * cell * scale).toInt(),
        (rows * cell * scale).toInt(),
      );
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      File('../../.screenshots/emoji/$name-${page + 1}.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(png!.buffer.asUint8List());
      image.dispose();
      picture.dispose();
    }
  });
}
