import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:build_test/build_test.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:preferences_generator/src/analysis/serialization_parser.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

// A record to hold the necessary context for parsing a single parameter.
typedef _ParameterContext = ({FormalParameterElement parameter, ConstantReader annotationReader});

(TopLevelVariableElement variable, ConstantReader reader) _getTopLevelContext(
  LibraryElement library,
  String name,
) {
  final variable = library.getTopLevelVariable(name)!;
  final annotation = const TypeChecker.typeNamed(PrefEntry).firstAnnotationOfExact(variable);
  return (variable, ConstantReader(annotation));
}

void main() {
  group('SerializationParser', () {
    late LibraryElement library;
    late TypeProvider typeProvider;
    late SerializationParser parser;

    // Helper to get the context for a specific parameter from our test source.
    _ParameterContext getContext(String parameterName) {
      final constructor = library.classes
          .firstWhere((constructor) => constructor.displayName == '_TestConfig')
          .constructors
          .first;
      final parameter = constructor.formalParameters.firstWhere((p) => p.name == parameterName);
      final annotation = const TypeChecker.typeNamed(PrefEntry).firstAnnotationOfExact(parameter);

      return (
        parameter: parameter,
        annotationReader: ConstantReader(annotation),
      );
    }

    setUpAll(() async {
      parser = const SerializationParser();
      // Parse a single library containing all our test cases.

      library = await resolveSource(
        '''
        library test;
        import 'package:preferences_annotation/preferences_annotation.dart';

        // --- Custom Types and Converters for Testing ---
        class User {
          final String name;
          User(this.name);
          Map<String, dynamic> toJson() => {'name': name};
          factory User.fromJson(Map<String, dynamic> json) => User(json['name']);
        }

        class UriConverter extends PrefConverter<Uri, String> {
          const UriConverter();
          @override Uri fromStorage(String value) => Uri.parse(value);
          @override String toStorage(Uri value) => value.toString();
        }

        Map<String, dynamic> _userToStorage(User user) => user.toJson();
        User _userFromStorage(Map<String, dynamic> value) => User.fromJson(value);
        
        enum LogLevel { info, error }

        // --- The Schema containing all test cases ---
        abstract class _TestConfig {
          _TestConfig._({
            // Case 1: Uses a PrefConverter
            @PrefEntry(converter: UriConverter())
            Uri? siteUrl,

            // Case 2: Uses toStorage/fromStorage functions
            @PrefEntry(toStorage: _userToStorage, fromStorage: _userFromStorage)
            User? currentUser,

            // Case 3: No custom serialization (uses TypeAnalyzer fallback)
            @PrefEntry()
            LogLevel logLevel = LogLevel.info,

            // Case 4: No @PrefEntry annotation at all
            int simpleValue = 0,
          });
        }
      ''',
        (resolver) async => (await resolver.findLibraryByName('test'))!,
      );
      typeProvider = library.typeProvider;
    });

    group('parse', () {
      test('should correctly parse a PrefConverter', () {
        // Arrange
        final context = getContext('siteUrl');

        // Act
        final details = parser.parse(
          parameterType: context.parameter.type,
          typeProvider: typeProvider,
          annotationReader: context.annotationReader,
        );

        // Assert
        expect(details.converterExpression, 'const UriConverter()');
        expect(details.toStorageExpression, isNull);
        expect(details.fromStorageExpression, isNull);
        expect(details.storageType.symbol, 'String');
      });

      test('should correctly parse toStorage/fromStorage functions', () {
        // Arrange
        final context = getContext('currentUser');

        // Act
        final details = parser.parse(
          parameterType: context.parameter.type,
          typeProvider: typeProvider,
          annotationReader: context.annotationReader,
        );

        // Assert
        expect(details.converterExpression, isNull);
        expect(details.toStorageExpression, '_userToStorage');
        expect(details.fromStorageExpression, '_userFromStorage');
        expect(details.storageType.symbol, 'Map<String, dynamic>');
      });

      test('should fall back to TypeAnalyzer for types without custom serialization', () {
        // Arrange
        final context = getContext('logLevel');

        // Act
        final details = parser.parse(
          parameterType: context.parameter.type,
          typeProvider: typeProvider,
          annotationReader: context.annotationReader,
        );

        // Assert
        expect(details.converterExpression, isNull);
        expect(details.toStorageExpression, isNull);
        expect(details.fromStorageExpression, isNull);
        // TypeAnalyzer correctly determines that Enums are stored as Strings.
        expect(details.storageType.symbol, 'String');
      });
    });

    group('hasCustomSerialization', () {
      test('should return true when a converter is provided', () {
        final reader = getContext('siteUrl').annotationReader;
        expect(parser.hasCustomSerialization(reader), isTrue);
      });

      test('should return true when toStorage/fromStorage are provided', () {
        final reader = getContext('currentUser').annotationReader;
        expect(parser.hasCustomSerialization(reader), isTrue);
      });

      test('should return false when no custom serialization is provided', () {
        final reader = getContext('logLevel').annotationReader;
        expect(parser.hasCustomSerialization(reader), isFalse);
      });

      test('should return false for a null annotation reader', () {
        final reader = ConstantReader(null); // Simulates no @PrefEntry
        expect(parser.hasCustomSerialization(reader), isFalse);
      });
    });
  });
}
