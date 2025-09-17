import 'dart:async';

import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:preferences_generator/src/analysis/model_visitor.dart';
import 'package:preferences_generator/src/utils/exception_handler.dart';
import 'package:preferences_generator/src/utils/syntax_builder.dart';
import 'package:preferences_generator/src/writers/implementation_writer.dart';
import 'package:preferences_generator/src/writers/keys_writer.dart';
import 'package:preferences_generator/src/writers/mixin_writer.dart';
import 'package:source_gen/source_gen.dart';

/// The main entry point for the code generation process.
///
/// This class is responsible for finding classes annotated with `@PrefsModule`, orchestrating the
/// analysis and validation via the `ModelVisitor`, and then coordinating the `writer` classes to
/// generate the final output code.
class PreferenceGenerator extends GeneratorForAnnotation<PrefsModule> {
  /// The build options passed from `build.yaml`.
  final BuilderOptions options;

  /// Creates a new instance of the generator, accepting build options.
  const PreferenceGenerator(this.options);

  @override
  FutureOr<String> generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    try {
      if (element is! ClassElement2) throw ExceptionHandler.notAClass(element);

      // Instantiate the visitor, passing in the build options so it can read project-wide
      // configurations from `build.yaml`.
      final visitor = ModelVisitor(options);

      // Run the analysis phase by having the visitor traverse the element.
      element.accept2(visitor);

      // Retrieve the fully analyzed and validated data model.
      final module = visitor.module;
      if (module == null) throw ExceptionHandler.couldNotParse(element);

      // Instantiate the writer classes with the data model.
      final keysClass = KeysWriter(module).write();
      final mixin = MixinWriter(module).write();
      final implementationClass = ImplementationWriter(module).write();

      // Assemble the generated parts into a single library.
      final library = SyntaxBuilder.library(elements: [keysClass, mixin, implementationClass]);

      // Emit the library to a string.
      final emitter = DartEmitter(
        allocator: Allocator.simplePrefixing(),
        orderDirectives: true,
        useNullSafetySyntax: true,
      );

      // Format the final output for clean, readable code.
      return DartFormatter(
        languageVersion: DartFormatter.latestLanguageVersion,
      ).format(library.accept(emitter).toString());
    } catch (error, stackTrace) {
      // Catch any unexpected errors during generation and wrap them in a standardized,
      // user-friendly error message.
      throw ExceptionHandler.unexpectedError(element, error, stackTrace);
      /*if (error is InvalidGenerationSourceError) {
        rethrow;
      } else {
        throw ExceptionHandler.unexpectedError(element, error, stackTrace);
      }*/
    }
  }
}
