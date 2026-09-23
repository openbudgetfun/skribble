import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/code_view.dart';
import 'package:skribble_docs_site/src/docs_keys.dart';
import 'package:skribble_docs_site/src/docs_surface.dart';

/// The typed parameters supported by executable documentation examples.
enum ExampleParameter {
  label,
  enabled,
  radius,
  amount,
  interaction,
  fill,
  color,
  iconFill,
}

/// Values shared by an example's compiled builder and generated source.
class ExampleSettings {
  /// Starts with the documentation's marker palette and a small corner radius.
  ExampleSettings();

  /// Editable text, safely escaped when copied as Dart source.
  String label = 'Make something lovely';

  /// Whether callbacks are enabled.
  bool enabled = true;

  /// Circular corner radius in logical pixels.
  double radius = 8;

  /// Normalized progress or slider value.
  double amount = .6;

  /// Standard Flutter-compatible ink feedback.
  WiredInkInteraction interaction = WiredInkInteraction.pressure;

  /// Pattern for the rough canvas examples.
  RoughFilter fill = RoughFilter.hachureFiller;

  /// Opaque marker colour, edited as a six-digit RGB value.
  Color color = const Color(0xffe8957d);

  /// Fill strategy used by runtime rough icons.
  WiredIconFillStyle iconFill = WiredIconFillStyle.solid;

  /// Dart literal corresponding to the current typed parameter.
  String literal(ExampleParameter parameter) => switch (parameter) {
    ExampleParameter.label => jsonEncode(label).replaceAll(r'$', r'\$'),
    ExampleParameter.enabled => '$enabled',
    ExampleParameter.radius => '$radius',
    ExampleParameter.amount => '$amount',
    ExampleParameter.interaction => 'WiredInkInteraction.${interaction.name}',
    ExampleParameter.fill => 'RoughFilter.${fill.name}',
    ExampleParameter.color =>
      'Color(0x${color.toARGB32().toRadixString(16).padLeft(8, '0')})',
    ExampleParameter.iconFill => 'WiredIconFillStyle.${iconFill.name}',
  };
}

/// A source range referring to one editable setting in the compiled builder.
class ExampleEdit {
  /// Records offsets generated from the Dart syntax tree.
  const ExampleEdit(this.start, this.end, this.parameter);

  /// Inclusive start of the setting expression.
  final int start;

  /// Exclusive end of the setting expression.
  final int end;

  /// Typed value substituted into this source range.
  final ExampleParameter parameter;
}

/// One compiled widget expression and source extracted from that expression.
class ExampleDefinition {
  /// Used by the generated catalog; edit the builders instead of this data.
  const ExampleDefinition({
    required this.builder,
    required this.source,
    required this.edits,
  });

  /// Actual Flutter code used to render the example.
  final Widget Function(ExampleSettings) builder;

  /// Original builder expression, preserved by the source generator.
  final String source;

  /// Ordered setting references found by the Dart parser.
  final List<ExampleEdit> edits;

  /// Parameters actually used by this example, in source order.
  Set<ExampleParameter> get parameters =>
      edits.map((edit) => edit.parameter).toSet();

  /// Replaces only parsed setting references, preserving strings and comments.
  String sourceFor(ExampleSettings settings) {
    var code = source;
    for (final edit in edits.reversed) {
      code = code.replaceRange(
        edit.start,
        edit.end,
        settings.literal(edit.parameter),
      );
    }
    return code;
  }
}

/// A working widget with editable parameters and matching selectable source.
class LiveExample extends HookWidget {
  /// Creates an isolated example; [id] identifies it across content revisions.
  const LiveExample({required this.id, required this.definition, super.key});

  /// Stable Markdown reference and test target.
  final String id;

  /// Compiled expression and generated source metadata.
  final ExampleDefinition definition;

  @override
  Widget build(BuildContext context) {
    final settings = useMemoized(ExampleSettings.new, [id]);
    final revision = useState(0);
    void changed() => revision.value++;

    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 24),
      // Frame inset, stroke, and stage padding stay within the previous
      // 20-pixel preview inset, so narrow previews keep their full width.
      padding: const EdgeInsets.all(6),
      decoration: docsFrame(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectionContainer.disabled(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Stage(
                  child: Container(
                    key: DocsKeys.preview(id),
                    constraints: const BoxConstraints(minHeight: 120),
                    padding: const EdgeInsets.fromLTRB(12, 36, 12, 28),
                    alignment: Alignment.center,
                    child: definition.builder(settings),
                  ),
                ),
                if (definition.parameters.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        for (final parameter in definition.parameters)
                          SizedBox(
                            width:
                                parameter == ExampleParameter.interaction ||
                                    parameter == ExampleParameter.fill
                                ? 280
                                : 220,
                            child: _ParameterEditor(
                              key: DocsKeys.parameter(id, parameter.name),
                              id: id,
                              parameter: parameter,
                              settings: settings,
                              onChanged: changed,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          CodeView(
            key: DocsKeys.exampleCode(id),
            code: definition.sourceFor(settings),
            margin: const EdgeInsets.only(top: 6),
          ),
        ],
      ),
    );
  }
}

/// Dotted drafting paper behind a live preview, labelled as interactive.
class _Stage extends StatelessWidget {
  const _Stage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: docsSurface(context, color: const Color(0xfffdf3e4)),
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _PaperDotsPainter()),
          ),
          child,
          const Positioned(
            left: 14,
            top: 10,
            child: ExcludeSemantics(
              child: Text(
                'Live · try it',
                style: TextStyle(fontSize: 11, color: docsQuietInk),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaperDotsPainter extends CustomPainter {
  const _PaperDotsPainter();

  static const double _spacing = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x2e34283f);
    for (var y = _spacing / 2; y < size.height; y += _spacing) {
      for (var x = _spacing / 2; x < size.width; x += _spacing) {
        canvas.drawCircle(Offset(x, y), .9, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PaperDotsPainter oldDelegate) => false;
}

class _ParameterEditor extends HookWidget {
  const _ParameterEditor({
    required this.id,
    required this.parameter,
    required this.settings,
    required this.onChanged,
    super.key,
  });
  final String id;
  final ExampleParameter parameter;
  final ExampleSettings settings;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(
      text: switch (parameter) {
        ExampleParameter.label => settings.label,
        ExampleParameter.color =>
          '#${(settings.color.toARGB32() & 0xffffff).toRadixString(16).padLeft(6, '0')}',
        _ => settings.literal(parameter),
      },
    );
    final error = useState<String?>(null);

    if (parameter == ExampleParameter.enabled) {
      return DocsAction(
        dense: true,
        selected: settings.enabled,
        onPressed: () {
          settings.enabled = !settings.enabled;
          onChanged();
        },
        child: Text('enabled: ${settings.enabled}'),
      );
    }

    if (parameter == ExampleParameter.interaction ||
        parameter == ExampleParameter.fill ||
        parameter == ExampleParameter.iconFill) {
      final values = switch (parameter) {
        ExampleParameter.interaction => WiredInkInteraction.values,
        ExampleParameter.iconFill => WiredIconFillStyle.values,
        _ => RoughFilter.values,
      };
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parameter.name,
            style: const TextStyle(fontSize: 13, color: docsQuietInk),
          ),
          Wrap(
            children: [
              for (final value in values)
                DocsAction(
                  key: DocsKeys.choice(id, parameter.name, value.name),
                  dense: true,
                  selected:
                      value == settings.interaction ||
                      value == settings.fill ||
                      value == settings.iconFill,
                  onPressed: () {
                    switch (value) {
                      case final WiredInkInteraction interaction:
                        settings.interaction = interaction;
                      case final RoughFilter fill:
                        settings.fill = fill;
                      case final WiredIconFillStyle fill:
                        settings.iconFill = fill;
                    }
                    onChanged();
                  },
                  child: Text(value.name, style: const TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WiredInput(
          controller: controller,
          labelText: parameter.name,
          semanticLabel: 'Edit ${parameter.name}',
          onChanged: (value) {
            if (parameter == ExampleParameter.label) {
              settings.label = value;
            } else if (parameter == ExampleParameter.color) {
              if (!RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value)) {
                error.value = 'Use a colour such as #e8957d.';
                return;
              }
              settings.color = Color(
                0xff000000 | int.parse(value.substring(1), radix: 16),
              );
            } else {
              final number = double.tryParse(value);
              final max = parameter == ExampleParameter.radius ? 48 : 1;
              if (number == null ||
                  !number.isFinite ||
                  number < 0 ||
                  number > max) {
                error.value = 'Enter a number from 0 to $max.';
                return;
              }
              if (parameter == ExampleParameter.radius) {
                settings.radius = number;
              }
              if (parameter == ExampleParameter.amount) {
                settings.amount = number;
              }
            }
            error.value = null;
            onChanged();
          },
        ),
        if (error.value case final String message)
          Text(
            message,
            style: const TextStyle(color: Color(0xff95372c), fontSize: 12),
          ),
      ],
    );
  }
}
