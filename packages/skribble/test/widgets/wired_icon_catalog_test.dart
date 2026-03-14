import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('materialRoughIconCodePoints', () {
    test('exposes generated rough icon codepoints', () {
      expect(materialRoughIconCodePoints, isNotEmpty);
      expect(materialRoughIconCodePoints, contains(Icons.search.codePoint));
    });
  });
}
