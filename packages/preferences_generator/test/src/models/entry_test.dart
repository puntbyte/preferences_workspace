import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:build_test/build_test.dart';
import 'package:code_builder/code_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:preferences_generator/src/models/entry.dart';
import 'package:preferences_generator/src/models/method_config.dart';
import 'package:test/test.dart';

// Fake and Mock classes remain at the top level.
class FakeDartType extends Fake implements DartType {}
class MockDartType extends Mock implements DartType {}
class MockTypeSystem extends Mock implements TypeSystem {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDartType());
  });

  late LibraryElement2 library;
  // ✨ FIX: Removed the unused `realStringType` variable.
  late DartType realEnumType;

  setUpAll(() async {
    library = await resolveSource(
      '''
      library test;
      enum MyEnum { one }
      class _Types {
        String stringField;
        MyEnum enumField;
      }
      ''',
          (resolver) async => (await resolver.findLibraryByName('test'))!,
    );

    final typeContainer = library.classes.first;
    // ✨ FIX: Removed the assignment to the unused variable.
    realEnumType = typeContainer.getField2('enumField')!.type;
  });

  group('Entry', () {
    late DartType mockType;
    late TypeSystem mockTypeSystem;

    Entry createEntry({
      DartType? type,
      TypeSystem? typeSystem,
      String? defaultValueCode,
      String? initialValueAccessor,
      String? converterExpression,
      String? toStorageExpression,
      String? fromStorageExpression,
    }) {
      return Entry(
        name: 'testEntry',
        type: type ?? mockType,
        typeSystem: typeSystem ?? mockTypeSystem,
        storageKey: 'test_entry',
        defaultValueCode: defaultValueCode,
        initialValueAccessor: initialValueAccessor,
        converterExpression: converterExpression,
        toStorageExpression: toStorageExpression,
        fromStorageExpression: fromStorageExpression,
        resolvedNotifiable: false,
        resolvedGetter: const ResolvedMethodConfig(enabled: true),
        resolvedSetter: const ResolvedMethodConfig(enabled: true),
        resolvedRemover: const ResolvedMethodConfig(enabled: true),
        resolvedAsyncGetter: const ResolvedMethodConfig(enabled: true),
        resolvedAsyncSetter: const ResolvedMethodConfig(enabled: true),
        resolvedAsyncRemover: const ResolvedMethodConfig(enabled: true),
        resolvedStream: const ResolvedMethodConfig(enabled: true),
        storageType: const Reference('String'),
      );
    }

    setUp(() {
      mockType = MockDartType();
      mockTypeSystem = MockTypeSystem();

      when(() => mockTypeSystem.promoteToNonNull(any())).thenReturn(mockType);
      when(() => mockType.getDisplayString()).thenReturn('String');
    });

    // ... The rest of the test groups are unchanged and correct ...
    group('Convenience Getters', () {
      test('`defaultSourceExpression` should prioritize initialValueAccessor', () {
        final entry = createEntry(
          defaultValueCode: "'compileTimeDefault'",
          initialValueAccessor: '_getRunTimeDefault',
        );
        expect(entry.defaultSourceExpression, '_getRunTimeDefault()');
      });

      test('`defaultSourceExpression` should use defaultValueCode if accessor is null', () {
        final entry = createEntry(defaultValueCode: "'compileTimeDefault'");
        expect(entry.defaultSourceExpression, "'compileTimeDefault'");
      });

      test('`defaultSourceExpression` should return "null" if both are null', () {
        final entry = createEntry();
        expect(entry.defaultSourceExpression, 'null');
      });

      test('`hasInitialFunction` should be true if accessor is not null', () {
        final entry = createEntry(initialValueAccessor: '_getRunTimeDefault');
        expect(entry.hasInitialFunction, isTrue);
      });

      test('`hasInitialFunction` should be false if accessor is null', () {
        final entry = createEntry();
        expect(entry.hasInitialFunction, isFalse);
      });

      test('`needsCustomSerialization` should be true if converter is present', () {
        final entry = createEntry(converterExpression: 'const MyConverter()');
        expect(entry.needsCustomSerialization, isTrue);
      });

      test('`needsCustomSerialization` should be true if toStorage is present', () {
        final entry = createEntry(toStorageExpression: '_toStorage');
        expect(entry.needsCustomSerialization, isTrue);
      });

      test('`needsCustomSerialization` should be false if no custom serialization is present', () {
        final entry = createEntry();
        expect(entry.needsCustomSerialization, isFalse);
      });
    });

    group('buildSerializationExpression', () {
      test('should prioritize `converterExpression`', () {
        final entry = createEntry(
          converterExpression: 'const MyConverter()',
          toStorageExpression: '_toStorage', // Should be ignored
        );
        expect(entry.buildSerializationExpression('myValue'),
            'const MyConverter().toStorage(myValue)');
      });

      test('should use `toStorageExpression` if converter is null', () {
        final entry = createEntry(toStorageExpression: '_toStorage');
        expect(entry.buildSerializationExpression('myValue'), '_toStorage(myValue)');
      });

      test('should fall back to TypeAnalyzer for default serialization', () {
        final entry = createEntry(type: realEnumType, typeSystem: library.typeSystem);
        expect(entry.buildSerializationExpression('myValue'), 'myValue.name');
      });
    });

    group('buildDeserializationExpression', () {
      test('should prioritize `converterExpression`', () {
        final entry = createEntry(
          converterExpression: 'const MyConverter()',
          fromStorageExpression: '_fromStorage', // Should be ignored
        );
        expect(entry.buildDeserializationExpression('rawValue'),
            'const MyConverter().fromStorage(rawValue)');
      });

      test('should use `fromStorageExpression` if converter is null', () {
        final entry = createEntry(fromStorageExpression: '_fromStorage');
        expect(entry.buildDeserializationExpression('rawValue'), '_fromStorage(rawValue)');
      });

      test('should fall back to TypeAnalyzer for default deserialization', () {
        final entry = createEntry(type: realEnumType, typeSystem: library.typeSystem);
        expect(entry.buildDeserializationExpression('rawValue'),
            'MyEnum.values.byName(rawValue)');
      });
    });
  });
}
