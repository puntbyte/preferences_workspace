import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:build_test/build_test.dart';
import 'package:preferences_generator/src/utils/type_analyzer.dart';
import 'package:test/test.dart';

void main() {
  group('TypeAnalyzer', () {
    // These late variables will be initialized once for all tests.
    late LibraryElement library;
    late TypeSystem typeSystem;
    late TypeProvider typeProvider;

    // A helper to get a specific DartType from our test source code.
    DartType getType(String fieldName) {
      final typeContainer = library.classes.firstWhere((class$) => class$.displayName == '_Types');
      return typeContainer.getField(fieldName)!.type;
    }

    setUpAll(() async {
      // Parse a single, comprehensive library of types once. This is efficient.
      library = await resolveSource(
        '''
        library test;

        class User {}
        enum LogLevel { info, error }

        // A container class to hold fields of every type we want to test.
        class _Types {
          int intField = 0;
          String? nullableStringField;
          double doubleField = 0.0;
          bool boolField = false;
          List<String> listField = [];
          Set<int> setField = {};
          Map<String, bool> mapField = {};
          LogLevel logLevelField = LogLevel.info;
          DateTime? nullableDateTimeField;
          Duration durationField = Duration.zero;
          ({int x, String y}) recordField = (x: 0, y: '');
          User userField = User();
        }
      ''',
        (resolver) async => (await resolver.findLibraryByName('test'))!,
      );
      typeSystem = library.typeSystem;
      typeProvider = library.typeProvider;
    });

    group('isSupported', () {
      test('should return true for supported primitive types', () {
        expect(TypeAnalyzer.isSupported(getType('intField')), isTrue);
        expect(TypeAnalyzer.isSupported(getType('nullableStringField')), isTrue);
        expect(TypeAnalyzer.isSupported(getType('doubleField')), isTrue);
        expect(TypeAnalyzer.isSupported(getType('boolField')), isTrue);
      });

      test('should return true for supported collection types', () {
        expect(TypeAnalyzer.isSupported(getType('listField')), isTrue);
        expect(TypeAnalyzer.isSupported(getType('setField')), isTrue);
        expect(TypeAnalyzer.isSupported(getType('mapField')), isTrue);
      });

      test('should return true for supported core and enum types', () {
        expect(TypeAnalyzer.isSupported(getType('logLevelField')), isTrue);
        expect(TypeAnalyzer.isSupported(getType('nullableDateTimeField')), isTrue);
        expect(TypeAnalyzer.isSupported(getType('durationField')), isTrue);
        expect(TypeAnalyzer.isSupported(getType('recordField')), isTrue);
      });

      test('should return false for unsupported types', () {
        expect(TypeAnalyzer.isSupported(getType('userField')), isFalse);
      });
    });

    group('getStorageType', () {
      test('should return String for Enum', () {
        final storageType = TypeAnalyzer.getStorageType(getType('logLevelField'), typeProvider);
        expect(storageType, typeProvider.stringType);
      });

      test('should return String for DateTime', () {
        final storageType = TypeAnalyzer.getStorageType(
          getType('nullableDateTimeField'),
          typeProvider,
        );
        expect(storageType, typeProvider.stringType);
      });

      test('should return int for Duration', () {
        final storageType = TypeAnalyzer.getStorageType(getType('durationField'), typeProvider);
        expect(storageType, typeProvider.intType);
      });

      test('should return Map<String, dynamic> for Record', () {
        final storageType = TypeAnalyzer.getStorageType(getType('recordField'), typeProvider);
        expect(storageType.isDartCoreMap, isTrue);

        final typeArgs = (storageType as InterfaceType).typeArguments;
        expect(typeArgs.first, typeProvider.stringType);
        expect(typeArgs.last is DynamicType, isTrue);
      });

      test('should return the original type for primitives and collections', () {
        final intType = getType('intField');
        final listType = getType('listField');
        expect(TypeAnalyzer.getStorageType(intType, typeProvider), intType);
        expect(TypeAnalyzer.getStorageType(listType, typeProvider), listType);
      });
    });

    group('buildSerializationExpression', () {
      test('should generate `.name` for enums', () {
        final expression = TypeAnalyzer.buildSerializationExpression(
          'myVar',
          getType('logLevelField'),
        );
        expect(expression, 'myVar.name');
      });

      test('should generate `.toIso8601String()` for DateTimes', () {
        final expression = TypeAnalyzer.buildSerializationExpression(
          'myVar',
          getType('nullableDateTimeField'),
        );
        expect(expression, 'myVar.toIso8601String()');
      });

      test('should generate `.inMicroseconds` for Durations', () {
        final expression = TypeAnalyzer.buildSerializationExpression(
          'myVar',
          getType('durationField'),
        );
        expect(expression, 'myVar.inMicroseconds');
      });

      test('should generate a map literal for records', () {
        final expression = TypeAnalyzer.buildSerializationExpression(
          'myVar',
          getType('recordField'),
        );
        expect(expression, "{'x': myVar.x, 'y': myVar.y}");
      });

      test('should return the variable name for primitives', () {
        final expression = TypeAnalyzer.buildSerializationExpression('myVar', getType('intField'));
        expect(expression, 'myVar');
      });
    });

    group('buildDeserializationExpression', () {
      test('should generate `Enum.values.byName` for enums', () {
        final expression = TypeAnalyzer.buildDeserializationExpression(
          'myVar',
          getType('logLevelField'),
          typeSystem,
        );
        expect(expression, 'LogLevel.values.byName(myVar)');
      });

      test('should generate `DateTime.parse` for DateTimes', () {
        final expression = TypeAnalyzer.buildDeserializationExpression(
          'myVar',
          getType('nullableDateTimeField'),
          typeSystem,
        );
        expect(expression, 'DateTime.parse(myVar)');
      });

      test('should generate `Duration(microseconds: ...)` for Durations', () {
        final expression = TypeAnalyzer.buildDeserializationExpression(
          'myVar',
          getType('durationField'),
          typeSystem,
        );
        expect(expression, 'Duration(microseconds: myVar)');
      });

      test('should generate a record literal for records', () {
        final expression = TypeAnalyzer.buildDeserializationExpression(
          r'$map',
          getType('recordField'),
          typeSystem,
        );
        expect(expression, r"(x: ($map['x'] as int?) ?? 0, y: ($map['y'] as String?) ?? '')");
      });

      test('should return the variable name for primitives', () {
        final expression = TypeAnalyzer.buildDeserializationExpression(
          'myVar',
          getType('intField'),
          typeSystem,
        );
        expect(expression, 'myVar');
      });
    });
  });
}
