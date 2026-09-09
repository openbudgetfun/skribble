import 'package:flutter_test/flutter_test.dart';

import '../tool/generate_examples.dart';

void main() {
  test('standalone widgets and class lessons require explicit coverage', () {
    for (final source in [
      'WiredButton(child: Text("Hello"))',
      'const WiredCombo<String>(items: [])',
      '// A sample\nContainer(child: Text("Hello"))',
      "import 'package:flutter/widgets.dart';\nclass Sample extends StatelessWidget {}",
    ]) {
      expect(exampleCoverageProblem(source), isNotNull, reason: source);
    }
  });

  test('live widgets and classified references satisfy coverage', () {
    expect(
      exampleCoverageProblem('// Live example: button\nWiredButton()'),
      isNull,
    );
    for (final reason in [
      'setup',
      'configuration',
      'api',
      'type',
      'test',
      'custom-class',
      'external-asset',
      'pseudocode',
    ]) {
      expect(
        exampleCoverageProblem('// Static example: $reason\nWiredButton()'),
        isNull,
      );
    }
    expect(
      exampleCoverageProblem('// Static example: skip\nWiredButton()'),
      contains('Unknown static example reason'),
    );
    expect(
      exampleCoverageProblem('// Live example: \nWiredButton()'),
      isNotNull,
    );
  });

  test('reference snippets require an explicit classification too', () {
    expect(exampleCoverageProblem('final seed = 42;'), isNotNull);
    expect(exampleCoverageProblem('RoughBoxDecoration()'), isNotNull);
    expect(exampleCoverageProblem('enum Mode { gentle, playful }'), isNotNull);
  });
}
