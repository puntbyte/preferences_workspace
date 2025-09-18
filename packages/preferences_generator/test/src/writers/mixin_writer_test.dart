import 'package:code_builder/code_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:preferences_generator/src/builders/module_methods_builder.dart';
import 'package:preferences_generator/src/models/entry.dart';
import 'package:preferences_generator/src/models/method_config.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:test/test.dart';

// Mock classes for the models the builder depends on.
class MockModule extends Mock implements Module {}
class MockEntry extends Mock implements Entry {}

void main() {
  group('ModuleMethodsBuilder', () {
    late Module mockModule;
    late DartEmitter emitter;

    setUp(() {
      mockModule = MockModule();
      emitter = DartEmitter(useNullSafetySyntax: true);

      // ✨ FIX: Establish a baseline "disabled" state for all mocks to prevent null errors.
      // Tests can override these stubs as needed.
      when(() => mockModule.refresh).thenReturn(const ResolvedMethodConfig(enabled: false));
      when(() => mockModule.removeAll).thenReturn(const ResolvedMethodConfig(enabled: false));
      when(() => mockModule.hasStreams).thenReturn(false);

      // Stubs needed for the `_load` method body, which is always generated.
      when(() => mockModule.isNotifiable).thenReturn(false);
      when(() => mockModule.usesChangeNotifier).thenReturn(false);
      when(() => mockModule.keysName).thenReturn('_TestKeys');
      when(() => mockModule.entries).thenReturn([]); // Default to no entries.
    });

    String normalize(String source) => source.replaceAll(RegExp(r'\s+'), '');

    test('should generate only the _load method when all public methods are disabled', () {
      // Arrange (no arrangement needed, the setUp block handles the "disabled" state)
      final builder = ModuleMethodsBuilder(mockModule);

      // Act
      final methods = builder.build();

      // Assert
      expect(methods, hasLength(1));
      expect(methods.first.name, '_load');
    });

    test('should generate all public methods when enabled', () {
      // Arrange: Override the default "disabled" stubs.
      when(() => mockModule.refresh).thenReturn(const ResolvedMethodConfig(enabled: true, name: 'refreshAll'));
      when(() => mockModule.removeAll).thenReturn(const ResolvedMethodConfig(enabled: true, name: 'clearAll'));
      when(() => mockModule.hasStreams).thenReturn(true);

      final mockEntry = MockEntry();
      when(() => mockEntry.resolvedStream).thenReturn(const ResolvedMethodConfig(enabled: true));
      when(() => mockEntry.name).thenReturn('myEntry');
      when(() => mockEntry.buildDeserializationExpression(any())).thenReturn('deserializedValue');
      // ✨ FIX: Stub the missing `storageType` getter.
      when(() => mockEntry.storageType).thenReturn(const Reference('String'));
      when(() => mockModule.entries).thenReturn([mockEntry]);

      final builder = ModuleMethodsBuilder(mockModule);

      // Act
      final methods = builder.build();

      // Assert
      expect(methods, hasLength(4));
      expect(methods.any((m) => m.name == 'refreshAll'), isTrue);
      expect(methods.any((m) => m.name == 'clearAll'), isTrue);
      expect(methods.any((m) => m.name == 'dispose'), isTrue);
      expect(methods.any((m) => m.name == '_load'), isTrue);
    });

    test('should generate a correct dispose method body', () {
      // Arrange
      final mockEntry1 = MockEntry();
      final mockEntry2 = MockEntry();
      when(() => mockModule.hasStreams).thenReturn(true);

      when(() => mockEntry1.resolvedStream).thenReturn(const ResolvedMethodConfig(enabled: true));
      when(() => mockEntry1.name).thenReturn('username');
      when(() => mockEntry1.buildDeserializationExpression(any())).thenReturn('deserializedUser');
      // ✨ FIX: Stub the missing `storageType` getter.
      when(() => mockEntry1.storageType).thenReturn(const Reference('String'));

      when(() => mockEntry2.resolvedStream).thenReturn(const ResolvedMethodConfig(enabled: true));
      when(() => mockEntry2.name).thenReturn('theme');
      when(() => mockEntry2.buildDeserializationExpression(any())).thenReturn('deserializedTheme');
      // ✨ FIX: Stub the missing `storageType` getter.
      when(() => mockEntry2.storageType).thenReturn(const Reference('String'));

      when(() => mockModule.entries).thenReturn([mockEntry1, mockEntry2]);

      final builder = ModuleMethodsBuilder(mockModule);

      // Act
      final disposeMethod = builder.build().firstWhere((m) => m.name == 'dispose');
      final generatedCode = disposeMethod.body!.accept(emitter).toString();

      // Assert
      const expectedBody = '''
        _usernameStreamController.close();
        _themeStreamController.close();
      ''';
      expect(normalize(generatedCode), normalize(expectedBody));
    });

    test('should generate correct refresh and removeAll method bodies', () {
      // Arrange: Override the default stubs for the methods under test.
      when(() => mockModule.refresh).thenReturn(const ResolvedMethodConfig(enabled: true, name: 'refresh'));
      when(() => mockModule.removeAll).thenReturn(const ResolvedMethodConfig(enabled: true, name: 'removeAll'));

      final builder = ModuleMethodsBuilder(mockModule);

      // Act
      final methods = builder.build();
      final refreshMethod = methods.firstWhere((m) => m.name == 'refresh');
      final removeAllMethod = methods.firstWhere((m) => m.name == 'removeAll');

      // Assert
      expect(
        normalize(refreshMethod.body!.accept(emitter).toString()),
        normalize('await _load();'),
      );
      expect(
        normalize(removeAllMethod.body!.accept(emitter).toString()),
        normalize('await _adapter.removeAll(); await _load();'),
      );
    });
  });
}
