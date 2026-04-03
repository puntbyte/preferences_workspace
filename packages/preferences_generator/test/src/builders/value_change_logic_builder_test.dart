import 'package:code_builder/code_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:preferences_generator/src/builders/value_change_logic_builder.dart';
import 'package:preferences_generator/src/models/entry.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:test/test.dart';

class MockModule extends Mock implements Module {}

class MockEntry extends Mock implements Entry {}

void main() {
  late Module mockModule;
  late Entry mockEntry;
  late DartEmitter emitter;

  setUp(() {
    mockModule = MockModule();
    mockEntry = MockEntry();
    emitter = DartEmitter(useNullSafetySyntax: true);

    // Module baseline: non-notifiable, no onWriteError, keys class named '_TestKeys'.
    when(() => mockModule.usesChangeNotifier).thenReturn(false);
    when(() => mockModule.notifiable).thenReturn(false);
    when(() => mockModule.onWriteErrorExpression).thenReturn(null);
    when(() => mockModule.keysName).thenReturn('_TestKeys');

    // Entry baseline: no stream, notifiable, storage type String.
    when(() => mockEntry.resolvedStream).thenReturn(null);
    when(() => mockEntry.resolvedNotifiable).thenReturn(false);
    when(() => mockEntry.storageType).thenReturn(const Reference('String'));
    when(() => mockEntry.name).thenReturn('username');
    when(
          () => mockEntry.buildSerializationExpression(any()),
    ).thenReturn('value');
  });

  String normalize(String source) => source.replaceAll(RegExp(r'\s+'), ' ').trim();

  group('sync (fire-and-forget) setter', () {
    test('uses keys class reference, not a raw string literal', () {
      final builder = ValueChangeLogicBuilder(module: mockModule, entry: mockEntry);
      final code = builder
          .build(newValueExpression: 'value', isRemove: false, isAsync: false)
          .accept(emitter)
          .toString();

      expect(code, contains('_TestKeys.username'));
      expect(code, isNot(contains("'username'")));
    });

    test('wraps write in fire-and-forget Future with silent catch when no onWriteError', () {
      final builder = ValueChangeLogicBuilder(module: mockModule, entry: mockEntry);
      final code = normalize(
        builder
            .build(newValueExpression: 'value', isRemove: false, isAsync: false)
            .accept(emitter)
            .toString(),
      );

      expect(code, contains('Future(() async {'));
      expect(code, contains('try {'));
      expect(code, contains('catch (e, st)'));
    });

    test('calls onWriteError callback when provided', () {
      when(() => mockModule.onWriteErrorExpression).thenReturn('AppSettings._onError');

      final builder = ValueChangeLogicBuilder(module: mockModule, entry: mockEntry);
      final code = builder
          .build(newValueExpression: 'value', isRemove: false, isAsync: false)
          .accept(emitter)
          .toString();

      expect(code, contains('AppSettings._onError(e, st)'));
    });
  });

  group('async setter', () {
    test('awaits the adapter call directly (no Future wrapper)', () {
      final builder = ValueChangeLogicBuilder(module: mockModule, entry: mockEntry);
      final code = builder
          .build(newValueExpression: 'value', isRemove: false, isAsync: true)
          .accept(emitter)
          .toString();

      expect(code, isNot(contains('Future(() async')));
      expect(code, contains('await _adapter'));
    });

    test('uses keys class reference for async setter', () {
      final builder = ValueChangeLogicBuilder(module: mockModule, entry: mockEntry);
      final code = builder
          .build(newValueExpression: 'value', isRemove: false, isAsync: true)
          .accept(emitter)
          .toString();

      expect(code, contains('_TestKeys.username'));
    });
  });

  group('remover', () {
    test('uses keys class reference in remove call', () {
      final builder = ValueChangeLogicBuilder(module: mockModule, entry: mockEntry);
      final code = builder
          .build(newValueExpression: "'guest'", isRemove: true, isAsync: false)
          .accept(emitter)
          .toString();

      expect(code, contains('_adapter.remove(_TestKeys.username)'));
    });
  });

  group('stream logic', () {
    test('adds to stream controller when entry has a resolved stream', () {
      when(() => mockEntry.resolvedStream).thenReturn('usernameStream');

      final builder = ValueChangeLogicBuilder(module: mockModule, entry: mockEntry);
      final code = builder
          .build(newValueExpression: 'value', isRemove: false, isAsync: false)
          .accept(emitter)
          .toString();

      expect(code, contains('_usernameStreamController.add(value)'));
    });

    test('omits stream controller call when stream is disabled', () {
      // resolvedStream is already null in setUp.
      final builder = ValueChangeLogicBuilder(module: mockModule, entry: mockEntry);
      final code = builder
          .build(newValueExpression: 'value', isRemove: false, isAsync: false)
          .accept(emitter)
          .toString();

      expect(code, isNot(contains('StreamController')));
    });
  });

  group('notifyListeners logic', () {
    test('emits notifyListeners when module is notifiable and uses ChangeNotifier', () {
      when(() => mockModule.usesChangeNotifier).thenReturn(true);
      when(() => mockModule.notifiable).thenReturn(true);
      when(() => mockEntry.resolvedNotifiable).thenReturn(true);

      final builder = ValueChangeLogicBuilder(module: mockModule, entry: mockEntry);
      final code = builder
          .build(newValueExpression: 'value', isRemove: false, isAsync: false)
          .accept(emitter)
          .toString();

      expect(code, contains('notifyListeners'));
    });

    test('omits notifyListeners when entry overrides notifiable to false', () {
      when(() => mockModule.usesChangeNotifier).thenReturn(true);
      when(() => mockModule.notifiable).thenReturn(true);
      when(() => mockEntry.resolvedNotifiable).thenReturn(false);

      final builder = ValueChangeLogicBuilder(module: mockModule, entry: mockEntry);
      final code = builder
          .build(newValueExpression: 'value', isRemove: false, isAsync: false)
          .accept(emitter)
          .toString();

      expect(code, isNot(contains('notifyListeners')));
    });
  });
}
