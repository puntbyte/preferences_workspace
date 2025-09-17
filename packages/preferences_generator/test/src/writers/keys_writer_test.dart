import 'package:code_builder/code_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:preferences_generator/src/models/entry.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/writers/keys_writer.dart';
import 'package:test/test.dart';

// 1. Create mock classes for the models the writer depends on.
class MockModule extends Mock implements Module {}
class MockEntry extends Mock implements Entry {}

void main() {
  group('KeysWriter', () {
    late Module mockModule;
    late DartEmitter emitter;

    setUp(() {
      mockModule = MockModule();
      // The emitter is needed to convert the final `Class` object into a string.
      emitter = DartEmitter(useNullSafetySyntax: true);
    });

    // Helper function to compare generated code while ignoring whitespace.
    // This makes tests more robust against formatting changes.
    String format(String source) => source.replaceAll(RegExp(r'\s+'), '');

    test('should generate a class with constant fields for each entry', () {
      // Arrange
      final mockEntry1 = MockEntry();
      final mockEntry2 = MockEntry();

      // Define the behavior of the mock module.
      when(() => mockModule.keysName).thenReturn('_TestAppSettingsKeys');

      // Define the behavior of the first mock entry.
      when(() => mockEntry1.name).thenReturn('username');
      when(() => mockEntry1.storageKey).thenReturn('user_name_key'); // Custom key

      // Define the behavior of the second mock entry.
      when(() => mockEntry2.name).thenReturn('launchCount');
      when(() => mockEntry2.storageKey).thenReturn('launchCount'); // Key matches name

      // Set the entries list on the mock module.
      when(() => mockModule.entries).thenReturn([mockEntry1, mockEntry2]);

      final writer = KeysWriter(mockModule);

      // Act
      final resultClass = writer.write();
      final generatedCode = resultClass.accept(emitter).toString();

      // Assert
      const expectedCode = '''
        class _TestAppSettingsKeys {
          static const username = 'user_name_key';
          static const launchCount = 'launchCount';
        }
      ''';

      expect(format(generatedCode), format(expectedCode));
    });

    test('should generate an empty class when there are no entries', () {
      // Arrange
      when(() => mockModule.keysName).thenReturn('_EmptyKeys');
      // Return an empty list for the entries.
      when(() => mockModule.entries).thenReturn([]);

      final writer = KeysWriter(mockModule);

      // Act
      final resultClass = writer.write();
      final generatedCode = resultClass.accept(emitter).toString();

      // Assert
      const expectedCode = '''
        class _EmptyKeys {}
      ''';

      expect(format(generatedCode), format(expectedCode));
    });

    test('should correctly handle a single entry', () {
      // Arrange
      final mockEntry = MockEntry();
      when(() => mockModule.keysName).thenReturn('_SingleEntryKeys');
      when(() => mockEntry.name).thenReturn('apiToken');
      when(() => mockEntry.storageKey).thenReturn('X-API-TOKEN');
      when(() => mockModule.entries).thenReturn([mockEntry]);

      final writer = KeysWriter(mockModule);

      // Act
      final resultClass = writer.write();
      final generatedCode = resultClass.accept(emitter).toString();

      // Assert
      const expectedCode = '''
        class _SingleEntryKeys {
          static const apiToken = 'X-API-TOKEN';
        }
      ''';

      expect(format(generatedCode), format(expectedCode));
    });
  });
}
