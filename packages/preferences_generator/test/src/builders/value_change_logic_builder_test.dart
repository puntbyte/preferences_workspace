import 'package:code_builder/code_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:preferences_generator/src/builders/value_change_logic_builder.dart';
import 'package:preferences_generator/src/models/entry.dart';
import 'package:preferences_generator/src/models/method_config.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:test/test.dart';

// Create mock classes for your models.
class MockModule extends Mock implements Module {}

class MockEntry extends Mock implements Entry {}

void main() {
  group('ValueChangeLogicBuilder', () {
    late Module mockModule;
    late Entry mockEntry;
    late DartEmitter emitter;

    setUp(() {
      mockModule = MockModule();
      mockEntry = MockEntry();
      emitter = DartEmitter(useNullSafetySyntax: true);

      // Common stubs for all tests to reduce boilerplate.
      when(() => mockEntry.name).thenReturn('theme');
      when(() => mockModule.usesChangeNotifier).thenReturn(false);
      when(() => mockEntry.resolvedStream).thenReturn(
        const ResolvedMethodConfig(enabled: false),
      );
    });

    // Helper to compare generated code while ignoring whitespace.
    String format(String source) => source.replaceAll(RegExp(r'\s+'), '');

    test('should generate simple async set logic', () {
      // Arrange
      when(() => mockEntry.storageKey).thenReturn('app_theme');
      when(() => mockEntry.storageType).thenReturn(const Reference('String'));
      when(() => mockEntry.buildSerializationExpression('newTheme')).thenReturn("'dark'");

      final builder = ValueChangeLogicBuilder(module: mockModule, entry: mockEntry);

      // Act
      final code = builder.build(
        newValueExpression: 'newTheme',
        isRemove: false,
        isAsync: true,
      );

      // Assert
      const expected = '''
        if (_theme != newTheme) {
          _theme = newTheme;
          final toStore = 'dark';
          await _adapter.set<String>('app_theme', toStore);
        }
      ''';
      expect(format(code.accept(emitter).toString()), format(expected));
    });

    test('should generate sync remove logic with streaming and notifications', () {
      // Arrange
      when(() => mockEntry.storageKey).thenReturn('app_theme');
      when(() => mockModule.usesChangeNotifier).thenReturn(true);
      when(() => mockModule.notifiable).thenReturn(true);
      when(() => mockEntry.resolvedNotifiable).thenReturn(true);
      when(() => mockEntry.resolvedStream).thenReturn(const ResolvedMethodConfig(enabled: true));

      final builder = ValueChangeLogicBuilder(module: mockModule, entry: mockEntry);

      // Act
      final code = builder.build(
        newValueExpression: "'light'", // The default value.
        isRemove: true,
        isAsync: false,
      );

      // Assert
      const expected = '''
        if (_theme != 'light') {
          _theme = 'light';
          Future(() async {
            await _adapter.remove('app_theme');
          });
          _themeStreamController.add('light');
          (this as ChangeNotifier).notifyListeners();
        }
      ''';
      expect(format(code.accept(emitter).toString()), format(expected));
    });
  });
}
