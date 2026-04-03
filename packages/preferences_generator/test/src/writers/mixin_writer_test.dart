import 'package:code_builder/code_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:preferences_generator/src/builders/module_methods_builder.dart';
import 'package:preferences_generator/src/models/entry.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:test/test.dart';

class MockModule extends Mock implements Module {}

class MockEntry extends Mock implements Entry {}

void main() {
  group('ModuleMethodsBuilder', () {
    late Module mockModule;
    late DartEmitter emitter;

    setUp(() {
      mockModule = MockModule();
      emitter = DartEmitter(useNullSafetySyntax: true);

      // Baseline: all module-level methods disabled, no streams.
      when(() => mockModule.refresh).thenReturn(null);
      when(() => mockModule.removeAll).thenReturn(null);
      when(() => mockModule.hasStreams).thenReturn(false);
      when(() => mockModule.isNotifiable).thenReturn(false);
      when(() => mockModule.usesChangeNotifier).thenReturn(false);
      when(() => mockModule.keysName).thenReturn('_TestKeys');
      when(() => mockModule.entries).thenReturn([]);
    });

    String normalize(String source) =>
        source.replaceAll(RegExp(r'\s+'), '');

    test('generates only _load when all public methods are disabled', () {
      final builder = ModuleMethodsBuilder(mockModule);
      final methods = builder.build();

      expect(methods, hasLength(1));
      expect(methods.first.name, '_load');
    });

    test('generates refresh method when name is non-null', () {
      when(() => mockModule.refresh).thenReturn('refresh');

      final methods = ModuleMethodsBuilder(mockModule).build();

      expect(methods.any((m) => m.name == 'refresh'), isTrue);
    });

    test('refresh resets _isLoaded before calling _load', () {
      when(() => mockModule.refresh).thenReturn('refresh');

      final refreshMethod = ModuleMethodsBuilder(mockModule)
          .build()
          .firstWhere((m) => m.name == 'refresh');

      final code = normalize(
        refreshMethod.body!.accept(emitter).toString(),
      );

      expect(code, contains('_isLoaded=false'));
      expect(code, contains('await_load()'));
    });

    test('generates removeAll method when name is non-null', () {
      when(() => mockModule.removeAll).thenReturn('clearAll');

      final methods = ModuleMethodsBuilder(mockModule).build();

      expect(methods.any((m) => m.name == 'clearAll'), isTrue);
    });

    test('removeAll resets _isLoaded after clearing storage', () {
      when(() => mockModule.removeAll).thenReturn('removeAll');

      final removeAllMethod = ModuleMethodsBuilder(mockModule)
          .build()
          .firstWhere((m) => m.name == 'removeAll');

      final code = normalize(
        removeAllMethod.body!.accept(emitter).toString(),
      );

      expect(code, contains('removeAll()'));
      expect(code, contains('_isLoaded=false'));
      expect(code, contains('await_load()'));
    });

    test('generates dispose when any entry has a resolved stream', () {
      final mockEntry1 = MockEntry();
      final mockEntry2 = MockEntry();

      when(() => mockModule.hasStreams).thenReturn(true);
      when(() => mockEntry1.resolvedStream).thenReturn('usernameStream');
      when(() => mockEntry1.name).thenReturn('username');
      when(() => mockEntry1.buildDeserializationExpression(any()))
          .thenReturn('deserializedUser');
      when(() => mockEntry1.storageType).thenReturn(const Reference('String'));

      when(() => mockEntry2.resolvedStream).thenReturn('themeStream');
      when(() => mockEntry2.name).thenReturn('theme');
      when(() => mockEntry2.buildDeserializationExpression(any()))
          .thenReturn('deserializedTheme');
      when(() => mockEntry2.storageType).thenReturn(const Reference('String'));

      when(() => mockModule.entries).thenReturn([mockEntry1, mockEntry2]);

      final disposeMethod = ModuleMethodsBuilder(mockModule)
          .build()
          .firstWhere((m) => m.name == 'dispose');

      final code = normalize(
        disposeMethod.body!.accept(emitter).toString(),
      );

      expect(code, contains('_usernameStreamController.close()'));
      expect(code, contains('_themeStreamController.close()'));
    });

    test('generates all public methods when fully enabled', () {
      when(() => mockModule.refresh).thenReturn('refresh');
      when(() => mockModule.removeAll).thenReturn('removeAll');
      when(() => mockModule.hasStreams).thenReturn(true);

      final mockEntry = MockEntry();
      when(() => mockEntry.resolvedStream).thenReturn('myEntryStream');
      when(() => mockEntry.name).thenReturn('myEntry');
      when(() => mockEntry.buildDeserializationExpression(any()))
          .thenReturn('deserializedValue');
      when(() => mockEntry.storageType).thenReturn(const Reference('String'));
      when(() => mockModule.entries).thenReturn([mockEntry]);

      final methods = ModuleMethodsBuilder(mockModule).build();

      expect(methods.any((m) => m.name == 'refresh'), isTrue);
      expect(methods.any((m) => m.name == 'removeAll'), isTrue);
      expect(methods.any((m) => m.name == 'dispose'), isTrue);
      expect(methods.any((m) => m.name == '_load'), isTrue);
    });
  });
}
