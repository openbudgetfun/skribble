import 'dart:io';

import 'package:args/args.dart';
import 'package:skribble_font_roughen/skribble_font_roughen.dart';

/// CLI entry point for the Skribble font roughening tool.
///
/// Usage:
///   dart run skribble_font_roughen <input.ttf> <output.ttf> [options]
///
/// Options:
///   --jitter, -j    Maximum jitter amount in font units (default: 12)
///   --variant, -v   Font variant: regular, bold, italic, boldItalic (default: regular)
///   --help, -h      Show help message
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'jitter',
      abbr: 'j',
      help: 'Maximum jitter amount in font units',
      defaultsTo: '12',
    )
    ..addOption(
      'variant',
      abbr: 'v',
      help: 'Font variant: regular, bold, italic, boldItalic',
      defaultsTo: 'regular',
      allowed: ['regular', 'bold', 'italic', 'boldItalic'],
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show help message',
    );

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool || results.rest.length < 2) {
      _printUsage(parser);
      exit(results['help'] as bool ? 0 : 1);
    }

    final inputPath = results.rest[0];
    final outputPath = results.rest[1];
    final jitter = double.parse(results['jitter'] as String);
    final variantName = results['variant'] as String;

    final variant = FontVariant.values.firstWhere(
      (v) => v.name == variantName,
      orElse: () => FontVariant.regular,
    );

    print('Skribble Font Roughener');
    print('=====================');
    print('');

    final roughener = FontRoughener(
      inputPath: inputPath,
      outputPath: outputPath,
      jitterAmount: jitter,
      variant: variant,
    );

    final result = await roughener.roughen();

    print('');
    print('Roughening complete!');
    print('  Input: ${result.inputPath}');
    print('  Output: ${result.outputPath}');
    print('  Variant: ${result.variant.name}');
    print('  Jitter: ${result.jitterAmount}');
    print('  Glyphs processed: ${result.glyphCount}');
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('Skribble Font Roughener');
  print('=====================');
  print('');
  print('A Dart CLI tool for roughening fonts with hand-drawn jitter effects.');
  print('');
  print('Usage:');
  print('  dart run skribble_font_roughen <input.ttf> <output.ttf> [options]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('  dart run skribble_font_roughen input.ttf output.ttf');
  print('  dart run skribble_font_roughen input.ttf output.ttf --jitter 15');
  print('  dart run skribble_font_roughen input.ttf output.ttf --variant bold');
}
