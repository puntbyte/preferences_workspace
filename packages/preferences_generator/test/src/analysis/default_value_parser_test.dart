import 'package:build_test/build_test.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:preferences_generator/src/analysis/default_value_parser.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  group('DefaultValueParser', () {
    test('should add type arguments to untyped list literals', () async {
      final library = await resolveSource(
        '''
        library test;
        abstract class TestClass {
          TestClass._({List<String> p = const []});
        }
      ''',
        (resolver) => resolver.findLibraryByName('test'),
      );

      final param = library!.classes.first.constructors2.first.formalParameters.first;

      const parser = DefaultValueParser();
      final result = parser.parse(
        parameter: param,
        annotationReader: ConstantReader(null),
      );

      expect(result.constDefaultCode, 'const <String>[]');
    });

    test('should add type arguments to untyped map literals', () async {
      final library = await resolveSource(
        '''
        library test;
        abstract class TestClass {
          TestClass._({Map<String, int> p = const {}});
        }
      ''',
        (resolver) => resolver.findLibraryByName('test'),
      );

      final param = library!.classes.first.constructors2.first.formalParameters.first;

      const parser = DefaultValueParser();
      final result = parser.parse(
        parameter: param,
        annotationReader: ConstantReader(null),
      );

      expect(result.constDefaultCode, 'const <String, int>{}');
    });

    test('should throw an error for ambiguous default values', () async {
      final library = await resolveSource(
        '''
        library test;
        import 'package:preferences_annotation/preferences_annotation.dart';
        
        String myInitial() => '';

        @PrefsModule()
        abstract class TestClass {
          TestClass._({
            @PrefEntry(initial: myInitial)
            String p = 'default'
          });
        }
      ''',
        (resolver) => resolver.findLibraryByName('test'),
      );

      final element = library!.classes.first;
      final param = element.constructors2.first.formalParameters.first;
      final annotation = const TypeChecker.fromRuntime(PrefEntry).firstAnnotationOfExact(param)!;

      const parser = DefaultValueParser();

      expect(
        () => parser.parse(
          parameter: param,
          annotationReader: ConstantReader(annotation),
        ),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    });
  });
}
