# skribble_font_roughen

A Dart CLI tool for roughening fonts with hand-drawn jitter effects. Part of the [Skribble](https://github.com/openbudgetfun/skribble) hand-drawn Flutter design system.

## Overview

This tool replaces the previous Python-based font roughening script (`roughen_font.py`) with a pure Dart implementation. It takes a source font file (TTF or OTF), applies deterministic jitter to on-curve glyph points, and outputs a roughened font with a hand-drawn character.

## Features

- **Pure Dart implementation** - No Python or FontForge dependencies
- **Deterministic jitter** - Same input always produces the same output
- **Configurable roughness** - Adjustable jitter amount (default: 12 font units)
- **Multiple variants** - Support for Regular, Bold, Italic, and BoldItalic
- **CLI interface** - Easy to use from command line or scripts

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  skribble_font_roughen:
    path: ../packages/skribble_font_roughen
```

## Usage

### Command Line

```bash
# Basic usage
dart run skribble_font_roughen input.ttf output.ttf

# With custom jitter amount
dart run skribble_font_roughen input.ttf output.ttf --jitter 15

# With specific variant
dart run skribble_font_roughen input.ttf output.ttf --variant bold

# Show help
dart run skribble_font_roughen --help
```

### Programmatic Usage

```dart
import 'package:skribble_font_roughen/skribble_font_roughen.dart';

final roughener = FontRoughener(
  inputPath: 'input.ttf',
  outputPath: 'output.ttf',
  jitterAmount: 12.0,
  variant: FontVariant.regular,
);

final result = await roughener.roughen();
print('Processed ${result.glyphCount} glyphs');
```

## How It Works

1. **Read font** - Parses the input TTF/OTF file using `opentype_dart`
2. **Extract glyphs** - Gets all glyph outlines from the font
3. **Apply jitter** - Adds deterministic random displacement to on-curve points
4. **Update metadata** - Sets font family to "Skribble" with variant suffix
5. **Write output** - Saves the roughened font to the output path

## Jitter Algorithm

The jitter algorithm uses a hash-based approach to generate deterministic pseudo-random values:

```dart
double jitterValue(int seed, int index, {int offset = 0}) {
  const hashA = 2654435761;
  const hashB = 40503;
  final h = ((seed * hashA + (index + offset) * hashB) & 0xFFFFFFFF);
  return ((h % 1000) / 500.0 - 1.0) * jitterAmount;
}
```

This ensures:

- Same glyph always gets the same jitter
- Different glyphs get different jitter patterns
- Off-curve control points are preserved
- The font remains readable

## Replacing Python Script

This tool replaces the previous Python script (`packages/skribble/tool/font/roughen_font.py`). The Dart implementation:

- ✅ No Python dependency
- ✅ No FontForge dependency
- ✅ Cross-platform (works on Windows, macOS, Linux)
- ✅ Integrated with Dart tooling
- ✅ Easier to test and maintain

## Testing

```bash
# Run all tests
dart test

# Run specific test file
dart test test/jitter_algorithm_test.dart

# Run with coverage
dart test --coverage=coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

## Contributing

See the main [Skribble contributing guide](../../CONTRIBUTING.md) for details.

## License

MIT - See [LICENSE](LICENSE) for details.

## Publishing status

`skribble_font_roughen` is marked `publish_to: none` (internal tool). Its
upstream dependency `opentype_dart` 0.0.1 ships **no license** (all rights
reserved) and carries a stray Flutter SDK dependency, so the package
cannot be published to pub.dev until the dependency is replaced with a
licensed font library or an in-repo OpenType reader/writer.
