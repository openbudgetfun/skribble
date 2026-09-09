import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Extracts executable examples and their parameter ranges from Dart syntax.
/// Run from docs/site; --check fails when checked-in source metadata is stale.
Future<void> main(List<String> arguments) async {
  final inputs =
      Directory('lib/src/examples')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.examples.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final settingsUnit = parseString(
    content: File('lib/src/examples/example.dart').readAsStringSync(),
  ).unit;
  final settingsClass = settingsUnit.declarations
      .whereType<ClassDeclaration>()
      .singleWhere(
        (node) => node.namePart.typeName.lexeme == 'ExampleSettings',
      );
  final defaults = {
    for (final field
        in settingsClass.body.members.whereType<FieldDeclaration>())
      for (final variable in field.fields.variables)
        if (variable.initializer != null)
          variable.name.lexeme: variable.initializer!.toSource(),
  };
  final snippets = <String, String>{};
  final output = StringBuffer('''
// GENERATED CODE - DO NOT MODIFY BY HAND.
part of 'catalog.dart';

/// Executable examples, indexed by their stable Markdown IDs.
final Map<String, ExampleDefinition> examples = {
''');
  final ids = <String>{};

  for (final inputFile in inputs) {
    final input = inputFile.readAsStringSync();
    final unit = parseString(content: input).unit;
    for (final declaration
        in unit.declarations.whereType<FunctionDeclaration>()) {
      final id = RegExp('@docs-example ([a-z0-9-]+)')
          .firstMatch(
            declaration.documentationComment?.tokens
                    .map((token) => token.lexeme)
                    .join(' ') ??
                '',
          )
          ?.group(1);
      if (id == null) continue;
      if (!ids.add(id)) throw StateError('Duplicate example: $id');
      final body = declaration.functionExpression.body;
      if (body is! ExpressionFunctionBody) {
        throw StateError('$id must have an expression body.');
      }
      final expression = body.expression;
      final source = input.substring(expression.offset, expression.end);
      final references = _SettingsReferences();
      expression.accept(references);
      var snippet = source;
      for (final reference in references.references.reversed) {
        final value = defaults[reference.identifier.name];
        if (value == null) {
          throw StateError(
            'Unknown example parameter: ${reference.identifier.name}',
          );
        }
        snippet = snippet.replaceRange(
          reference.offset - expression.offset,
          reference.end - expression.offset,
          value,
        );
      }
      snippets[id] = snippet;
      output.writeln(
        "  '$id': ExampleDefinition(builder: ${declaration.name.lexeme}, source: ${_literal(source)}, edits: [",
      );
      for (final reference in references.references) {
        output.writeln(
          '    ExampleEdit(${reference.offset - expression.offset}, ${reference.end - expression.offset}, ExampleParameter.${reference.identifier.name}),',
        );
      }
      output.writeln('  ]),');
    }
  }
  output.writeln('};');
  final file = File('lib/src/examples/catalog.g.dart');
  final scratch = await Directory.systemTemp.createTemp('skribble-examples-');

  try {
    final generated = File('${scratch.path}/catalog.g.dart')
      ..writeAsStringSync(output.toString());
    final formatted = await Process.run(Platform.resolvedExecutable, [
      'format',
      generated.path,
    ]);
    if (formatted.exitCode != 0) throw StateError('${formatted.stderr}');
    final result = generated.readAsStringSync();
    if (arguments.contains('--check')) {
      if (!file.existsSync() || file.readAsStringSync() != result) {
        stderr.writeln(
          'Stale examples. Run dart run tool/generate_examples.dart in docs/site.',
        );
        exitCode = 1;
      }
    } else {
      file.writeAsStringSync(result);
    }
    stdout.writeln('${ids.length} compiled examples.');
    final referenced = <String>{};
    final content = Directory('content')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.md'));
    final templates = Directory('../../templates')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.t.md'));
    for (final markdown in [...content, ...templates]) {
      final current = markdown.readAsStringSync();
      final updated = current.replaceAllMapped(
        RegExp(r'```dart\n// Live example: ([a-z0-9-]+)\n[\s\S]*?```'),
        (match) {
          final id = match.group(1)!;
          final snippet = snippets[id];
          if (snippet == null) {
            throw StateError('Unknown example $id in ${markdown.path}');
          }
          referenced.add(id);
          return '```dart\n// Live example: $id\n$snippet\n```';
        },
      );
      if (current == updated) continue;
      if (arguments.contains('--check')) {
        stderr.writeln('Stale example source: ${markdown.path}');
        exitCode = 1;
      } else {
        markdown.writeAsStringSync(updated);
      }
    }
    final orphaned = ids.difference(referenced);
    if (orphaned.isNotEmpty) {
      throw StateError('Examples without documentation: $orphaned');
    }
  } finally {
    await scratch.delete(recursive: true);
  }
}

String _literal(String value) => jsonEncode(value).replaceAll(r'$', r'\$');

class _SettingsReferences extends RecursiveAstVisitor<void> {
  final references = <PrefixedIdentifier>[];

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node.prefix.name == 'settings') references.add(node);
    super.visitPrefixedIdentifier(node);
  }
}
