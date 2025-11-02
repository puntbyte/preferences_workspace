import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build_test/build_test.dart';
import 'package:preferences_generator/src/extensions/dart_type_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('DartTypeExtensions', () {
    // This late variable will be initialized once for all tests, which is efficient.
    late LibraryElement library;

    // A helper function to easily get a specific DartType from our test source code.
    DartType getType(String fieldName) {
      final typeContainer = library.classes.firstWhere((c) => c.displayName == '_Types');
      return typeContainer.getField(fieldName)!.type;
    }

    setUpAll(() async {
      library = await resolveSource(
        '''
        // ✨ FIX: Removed the legacy language version comment to ensure the
        // test runs in a modern, sound null-safety context.
        library test;

        enum MyEnum { one, two }
        
        class _Types {
          MyEnum enumField;
          ({int x, int y}) recordField;
          DateTime dateTimeField;
          Duration durationField;
          String nonNullableField;
          String? nullableField; // Standard modern nullable type
          int intField;
        }
      ''',
            (resolver) async => (await resolver.findLibraryByName('test'))!,
      );
    });

    group('isEnum', () {
      test('should return true for an enum type', () {
        final type = getType('enumField');
        expect(type.isEnum, isTrue);
      });

      test('should return false for a non-enum type (int)', () {
        final type = getType('intField');
        expect(type.isEnum, isFalse);
      });
    });

    group('isRecord', () {
      test('should return true for a record type', () {
        final type = getType('recordField');
        expect(type.isRecord, isTrue);
      });

      test('should return false for a non-record type (int)', () {
        final type = getType('intField');
        expect(type.isRecord, isFalse);
      });
    });

    group('isDateTime', () {
      test('should return true for a DateTime type', () {
        final type = getType('dateTimeField');
        expect(type.isDateTime, isTrue);
      });

      test('should return false for a non-DateTime type (Duration)', () {
        final type = getType('durationField');
        expect(type.isDateTime, isFalse);
      });
    });

    group('isDuration', () {
      test('should return true for a Duration type', () {
        final type = getType('durationField');
        expect(type.isDuration, isTrue);
      });

      test('should return false for a non-Duration type (DateTime)', () {
        final type = getType('dateTimeField');
        expect(type.isDuration, isFalse);
      });
    });

    group('isNullable', () {
      test('should return true for a modern nullable type (?)', () {
        final type = getType('nullableField');
        expect(type.isNullable, isTrue);
      });

      test('should return false for a non-nullable type', () {
        final type = getType('nonNullableField');
        expect(type.isNullable, isFalse);
      });
    });
  });
}
