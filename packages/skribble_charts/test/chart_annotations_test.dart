import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_charts/src/chart_annotations.dart';
import 'package:skribble_charts/src/chart_data.dart';

void main() {
  final start = WiredChartAnchor(
    time: DateTime.utc(2026, 9, 10, 12, 30, 1, 234, 567),
    price: WiredChartDecimal.parse('0.000000000000000000123456789'),
  );
  final end = WiredChartAnchor(
    time: DateTime.utc(2026, 9, 11),
    price: WiredChartDecimal.parse('999999999999999999999999.987654321'),
  );
  final replacement = WiredChartAnchor(
    time: DateTime.utc(2026, 9, 12),
    price: WiredChartDecimal.parse('-13.456'),
  );
  final drawings = <WiredChartAnnotation>[
    WiredChartTrendLine(id: 'trend', start: start, end: end, label: 'Trend'),
    WiredChartHorizontalLine(id: 'level', anchor: start, label: 'Support'),
    WiredChartRectangle(id: 'range', start: start, end: end, label: 'Range'),
    WiredChartText(id: 'text', anchor: start, label: 'Hello <world> 📈'),
    WiredChartFibonacci(
      id: 'fib',
      start: start,
      end: end,
      label: 'Retracement',
    ),
  ];

  group('market anchors', () {
    test('preserves exact prices and microseconds through actual JSON', () {
      final encoded = jsonEncode(start.toJson());
      final restored = WiredChartAnchor.fromJson(jsonDecode(encoded));

      expect(encoded, contains('"price":"0.000000000000000000123456789"'));
      expect(encoded, contains('2026-09-10T12:30:01.234567Z'));
      expect(restored, start);
      expect(restored.hashCode, start.hashCode);
      expect(restored.time.isUtc, isTrue);
    });

    test('round trips prices at the supported decimal precision limits', () {
      for (final price in ['1e999', '-1e999', '1e-1000', '-1e-1000']) {
        final anchor = WiredChartAnchor(
          time: start.time,
          price: WiredChartDecimal.parse(price),
        );
        final restored = WiredChartAnchor.fromJson(
          jsonDecode(jsonEncode(anchor.toJson())),
        );

        expect(restored, anchor, reason: price);
      }
    });

    test('normalizes a local DateTime to its UTC instant', () {
      final localTime = DateTime(2026, 9, 10, 15);
      final anchor = WiredChartAnchor(time: localTime, price: start.price);

      expect(anchor.time, localTime.toUtc());
      expect(anchor.time.isUtc, isTrue);
    });

    test('compares both exact price and absolute timestamp', () {
      expect(start, WiredChartAnchor(time: start.time, price: start.price));
      expect(start, isNot(end));
      expect(
        start,
        isNot(WiredChartAnchor(time: end.time, price: start.price)),
      );
      expect(
        start,
        isNot(WiredChartAnchor(time: start.time, price: end.price)),
      );
      expect(start == Object(), isFalse);
    });

    test(
      'rejects malformed dates without Dart date overflow normalization',
      () {
        for (final timestamp in [
          '',
          'not-a-date',
          '2026-02-30T00:00:00.000Z',
          '2026-13-01T00:00:00.000Z',
          '2026-09-10T25:00:00.000Z',
          '2026-09-10T00:00:00.000',
          '2026-09-10T00:00:00.000+01:00',
        ]) {
          expect(
            () => WiredChartAnchor.fromJson({
              ...start.toJson(),
              'time': timestamp,
            }),
            throwsFormatException,
            reason: timestamp,
          );
        }
      },
    );

    test('rejects non-string prices and invalid exact decimal strings', () {
      for (final price in <Object?>[
        null,
        0.1,
        2,
        true,
        'NaN',
        'Infinity',
        'x',
      ]) {
        expect(
          () => WiredChartAnchor.fromJson({...start.toJson(), 'price': price}),
          throwsFormatException,
          reason: '$price',
        );
      }
    });

    test('rejects non-object and missing fields', () {
      for (final value in <Object?>[
        null,
        [],
        1,
        'anchor',
        {},
        {'price': '1'},
      ]) {
        expect(() => WiredChartAnchor.fromJson(value), throwsFormatException);
      }
    });
  });

  group('annotation models', () {
    for (final drawing in drawings) {
      test('${drawing.tool.name} round trips without loss', () {
        final restored = WiredChartAnnotation.fromJson(
          jsonDecode(jsonEncode(drawing.toJson())),
        );

        expect(restored.runtimeType, drawing.runtimeType);
        expect(restored.id, drawing.id);
        expect(restored.label, drawing.label);
        expect(restored.tool, drawing.tool);
        expect(restored.anchors, drawing.anchors);
        expect(restored.toJson(), drawing.toJson());
      });

      test(
        '${drawing.tool.name} edits each handle without mutating source',
        () {
          for (var index = 0; index < drawing.anchors.length; index++) {
            final edited = drawing.withAnchor(index, replacement);

            expect(edited.runtimeType, drawing.runtimeType);
            expect(edited.id, drawing.id);
            expect(edited.label, drawing.label);
            expect(edited.anchors[index], replacement);
            expect(drawing.anchors[index], isNot(replacement));

            for (var other = 0; other < drawing.anchors.length; other++) {
              if (other != index) {
                expect(edited.anchors[other], drawing.anchors[other]);
              }
            }
          }
        },
      );

      test('${drawing.tool.name} rejects out-of-range handles', () {
        expect(() => drawing.withAnchor(-1, replacement), throwsRangeError);
        expect(
          () => drawing.withAnchor(drawing.anchors.length, replacement),
          throwsRangeError,
        );
      });

      test('${drawing.tool.name} exposes immutable anchors', () {
        expect(() => drawing.anchors.add(replacement), throwsUnsupportedError);
        expect(() => drawing.anchors[0] = replacement, throwsUnsupportedError);
      });

      test('${drawing.tool.name} rejects missing and extra anchors', () {
        for (final anchors in [
          <Object?>[],
          [...drawing.anchors.map((item) => item.toJson()), start.toJson()],
        ]) {
          expect(
            () => WiredChartAnnotation.fromJson({
              ...drawing.toJson(),
              'anchors': anchors,
            }),
            throwsFormatException,
          );
        }
      });
    }

    test('has deterministic version-independent candle annotation JSON', () {
      expect(drawings.first.toJson(), {
        'id': 'trend',
        'type': 'trendLine',
        'label': 'Trend',
        'anchors': [
          {
            'time': '2026-09-10T12:30:01.234567Z',
            'price': '0.000000000000000000123456789',
          },
          {
            'time': '2026-09-11T00:00:00.000Z',
            'price': '999999999999999999999999.987654321',
          },
        ],
      });
    });

    test('rejects empty IDs on construction', () {
      for (final id in ['', '  ', '\n']) {
        expect(
          () => WiredChartText(id: id, anchor: start, label: ''),
          throwsArgumentError,
        );
      }
    });

    test(
      'accepts reversed and coincident rectangle and retracement anchors',
      () {
        expect(
          WiredChartRectangle(id: 'reverse', start: end, end: start).anchors,
          [end, start],
        );
        expect(
          WiredChartFibonacci(id: 'flat', start: start, end: start).anchors,
          [start, start],
        );
        expect(WiredChartFibonacci.levels, [
          0,
          0.236,
          0.382,
          0.5,
          0.618,
          0.786,
          1,
        ]);
        expect(() => WiredChartFibonacci.levels.add(2), throwsUnsupportedError);
      },
    );

    test('rejects unknown tools and incorrect field types', () {
      final valid = drawings.first.toJson();
      final invalid = <Object?>[
        null,
        [],
        {},
        {...valid, 'type': 'none'},
        {...valid, 'type': 'futureTool'},
        {...valid, 'type': 3},
        {...valid, 'id': ''},
        {...valid, 'id': null},
        {...valid, 'label': 42},
        {...valid, 'anchors': 'bad'},
        {
          ...valid,
          'anchors': [null, start.toJson()],
        },
      ];

      for (final value in invalid) {
        expect(
          () => WiredChartAnnotation.fromJson(value),
          throwsFormatException,
        );
      }
    });
  });

  group('annotation editing', () {
    late WiredChartAnnotations editor;
    late int notifications;

    setUp(() {
      notifications = 0;
      editor = WiredChartAnnotations()..addListener(() => notifications++);
    });

    tearDown(() => editor.dispose());

    test('starts empty with no selection or history', () {
      expect(editor.annotations, isEmpty);
      expect(editor.selectedId, isNull);
      expect(editor.canUndo, isFalse);
      expect(editor.canRedo, isFalse);
      editor
        ..undo()
        ..redo()
        ..select(null);
      expect(notifications, 0);
    });

    test('each completed edit notifies once and is independently undoable', () {
      editor
        ..add(drawings[0])
        ..add(drawings[1]);
      expect(editor.annotations, drawings.take(2));
      expect(notifications, 2);
      editor.undo();
      expect(editor.annotations, [drawings[0]]);
      editor.undo();
      expect(editor.annotations, isEmpty);
      expect(editor.canUndo, isFalse);
      editor
        ..redo()
        ..redo();
      expect(editor.annotations, drawings.take(2));
      expect(editor.canRedo, isFalse);
      expect(notifications, 6);
    });

    test(
      'update preserves order, ID, and selection and undo restores source',
      () {
        editor
          ..replaceAll(drawings, selectedId: 'trend')
          ..update(drawings[0].withAnchor(0, replacement));
        expect(
          editor.annotations.map((item) => item.id),
          drawings.map((e) => e.id),
        );
        expect(editor.annotations[0].anchors[0], replacement);
        expect(editor.selectedId, 'trend');
        editor.undo();
        expect(editor.annotations, drawings);
        expect(editor.selectedId, 'trend');
        editor.redo();
        expect(editor.annotations[0].anchors[0], replacement);
      },
    );

    test(
      'undo removal restores selected drawing and redo clears selection',
      () {
        editor
          ..replaceAll(drawings, selectedId: 'text')
          ..remove('text');
        expect(editor.selectedId, isNull);
        expect(editor.annotations.length, drawings.length - 1);
        editor.undo();
        expect(editor.selectedId, 'text');
        expect(editor.annotations, drawings);
        editor.redo();
        expect(editor.selectedId, isNull);
      },
    );

    test('selection changes do not create edits or clear redo history', () {
      editor
        ..replaceAll(drawings)
        ..remove('text')
        ..undo()
        ..select('trend');
      expect(editor.canRedo, isTrue);
      expect(editor.canUndo, isFalse);
      editor
        ..select('trend')
        ..select(null);
      expect(notifications, 5);
      expect(editor.canUndo, isFalse);
    });

    test('an edit after undo discards the abandoned redo branch', () {
      editor
        ..add(drawings[0])
        ..add(drawings[1])
        ..undo()
        ..add(drawings[2]);
      expect(editor.annotations, [drawings[0], drawings[2]]);
      expect(editor.canRedo, isFalse);
      editor
        ..undo()
        ..undo();
      expect(editor.annotations, isEmpty);
    });

    test('updating with identical object is a no-op that preserves redo', () {
      editor
        ..add(drawings[0])
        ..add(drawings[1])
        ..undo()
        ..update(drawings[0]);
      expect(notifications, 3);
      expect(editor.canRedo, isTrue);
    });

    test(
      'invalid mutations preserve drawings, selection, history and listeners',
      () {
        editor
          ..replaceAll(drawings, selectedId: 'trend')
          ..remove('text')
          ..undo();
        final document = editor.exportDocument();
        final invalidOperations = <void Function()>[
          () => editor.add(drawings[0]),
          () => editor.update(
            WiredChartText(id: 'missing', anchor: start, label: ''),
          ),
          () => editor.remove('missing'),
          () => editor.select('missing'),
          () => editor.replaceAll([drawings[0], drawings[0]]),
          () => editor.replaceAll(drawings, selectedId: 'missing'),
        ];

        for (final operation in invalidOperations) {
          expect(operation, throwsArgumentError);
          expect(editor.exportDocument(), document);
          expect(editor.canRedo, isTrue);
          expect(editor.canUndo, isFalse);
          expect(notifications, 3);
        }
      },
    );

    test('replaceAll copies input and resets both undo and redo', () {
      editor
        ..add(drawings[0])
        ..add(drawings[1])
        ..undo();
      final input = [...drawings];
      editor.replaceAll(input, selectedId: 'fib');
      input.clear();
      expect(editor.annotations, drawings);
      expect(editor.selectedId, 'fib');
      expect(editor.canUndo, isFalse);
      expect(editor.canRedo, isFalse);
    });

    test('current and previous list snapshots cannot be mutated', () {
      editor.add(drawings[0]);
      final previous = editor.annotations;
      editor.add(drawings[1]);
      expect(previous, [drawings[0]]);
      expect(previous.clear, throwsUnsupportedError);
      expect(() => editor.annotations.clear(), throwsUnsupportedError);
      expect(() => editor.annotations[0] = drawings[2], throwsUnsupportedError);
    });

    test(
      'bounded history evicts the oldest edit and survives repeated redo',
      () {
        final limited = WiredChartAnnotations(historyLimit: 2);
        addTearDown(limited.dispose);
        limited
          ..add(drawings[0])
          ..add(drawings[1])
          ..add(drawings[2])
          ..undo()
          ..undo()
          ..undo();
        expect(limited.annotations, [drawings[0]]);
        expect(limited.canUndo, isFalse);
        limited
          ..redo()
          ..redo()
          ..undo()
          ..undo();
        expect(limited.annotations, [drawings[0]]);
        expect(limited.canUndo, isFalse);
      },
    );

    test(
      'zero history retains drawings without undo and rejects negative limit',
      () {
        final disabled = WiredChartAnnotations(historyLimit: 0);
        addTearDown(disabled.dispose);
        disabled
          ..add(drawings[0])
          ..remove('trend');
        expect(disabled.annotations, isEmpty);
        expect(disabled.canUndo, isFalse);
        expect(disabled.canRedo, isFalse);
        expect(
          () => WiredChartAnnotations(historyLimit: -1),
          throwsArgumentError,
        );
      },
    );

    test(
      'disposed editors reject mutations even when the operation is a no-op',
      () {
        final disposed = WiredChartAnnotations()..add(drawings[0]);
        final document = disposed.exportDocument();
        disposed.dispose();
        final operations = <void Function()>[
          () => disposed.add(drawings[1]),
          () => disposed.update(drawings[0]),
          () => disposed.remove(drawings[0].id),
          () => disposed.select(null),
          disposed.undo,
          disposed.redo,
          () => disposed.replaceAll(drawings),
          () => disposed.restore(document),
          disposed.dispose,
        ];

        expect(disposed.isDisposed, isTrue);

        for (final operation in operations) {
          expect(operation, throwsStateError);
        }

        expect(disposed.exportDocument(), document);
      },
    );

    test('restores JSON selection and resets session history', () {
      editor.replaceAll(drawings, selectedId: 'text');
      final stored = jsonEncode(editor.exportDocument());
      editor
        ..remove('text')
        ..restore(jsonDecode(stored));
      expect(editor.exportDocument(), jsonDecode(stored));
      expect(editor.selectedId, 'text');
      expect(editor.canUndo, isFalse);
      expect(editor.canRedo, isFalse);
      expect(notifications, 3);
    });

    test('exports detached maps and an explicit schema version', () {
      editor.replaceAll(drawings);
      final exported = editor.exportDocument();
      expect(exported['version'], 1);
      expect(exported['selectedId'], isNull);
      exported
        ..clear()
        ..['version'] = 5;
      expect(editor.exportDocument()['version'], 1);
      expect(editor.annotations, drawings);
    });

    test(
      'malformed restore is atomic even after a valid earlier annotation',
      () {
        editor
          ..replaceAll(drawings, selectedId: 'trend')
          ..remove('text')
          ..undo();
        final original = editor.exportDocument();
        final first = drawings.first.toJson();
        final invalidDocuments = <Object?>[
          null,
          [],
          'document',
          {},
          {...original, 'version': 2},
          {...original, 'version': 1.0},
          {...original, 'version': '1'},
          {...original, 'annotations': <String, Object?>{}},
          {
            ...original,
            'annotations': [first, first],
          },
          {
            ...original,
            'annotations': [first, null],
          },
          {
            ...original,
            'annotations': [
              first,
              {...first, 'id': 'second', 'type': 'unknown'},
            ],
          },
          {...original, 'selectedId': 'missing'},
          {...original, 'selectedId': 3},
          {'version': 1, 'annotations': <Object?>[]},
        ];

        for (final document in invalidDocuments) {
          expect(() => editor.restore(document), throwsFormatException);
          expect(editor.exportDocument(), original);
          expect(editor.canUndo, isFalse);
          expect(editor.canRedo, isTrue);
          expect(notifications, 3);
        }
      },
    );

    test('restores an empty document and clears selection', () {
      editor
        ..replaceAll(drawings, selectedId: 'text')
        ..restore({
          'version': 1,
          'annotations': <Object?>[],
          'selectedId': null,
        });
      expect(editor.annotations, isEmpty);
      expect(editor.selectedId, isNull);
      expect(editor.canUndo, isFalse);
      expect(editor.canRedo, isFalse);
    });
  });
}
