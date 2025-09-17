import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:source_gen/source_gen.dart';

/// A centralized handler for creating consistent, user-friendly build-time errors.
class ExceptionHandler {
  const ExceptionHandler._();

  /// Error for when a parameter has both a compile-time default and an `initial` function.
  static InvalidGenerationSourceError ambiguousDefault(FormalParameterElement element) {
    return InvalidGenerationSourceError(
      'Parameter `${element.displayName}` has both a compile-time default value in the signature '
      'and a non-constant default via the `@PrefEntry(initial: ...)` property. You must provide '
      'only one.',
      element: element,
    );
  }

  /// A generic fallback error for when parsing fails unexpectedly.
  static InvalidGenerationSourceError couldNotParse(Element2 element) {
    return InvalidGenerationSourceError(
      'Failed to parse the `${Names.annotation.module}` class. Please check its structure '
      'and annotations.',
      element: element,
    );
  }

  /// Error for when two or more generated methods resolve to the same name.
  static InvalidGenerationSourceError duplicateMethodName(
    ClassElement2 element,
    String conflictingName,
    String description1,
    String description2,
  ) {
    return InvalidGenerationSourceError(
      'Duplicate method name generated: `$conflictingName`.\n\n'
      'This name is created by both the "$description1" and the "$description2".\n\n'
      'To fix this, use the `name` or `prefix`/`suffix` properties in `@PrefEntry` or '
      '`@PrefsModule` to specify a unique name for one of them.',
      element: element,
    );
  }

  /// Error for when the factory constructor does not have a valid `PrefsAdapter` parameter.
  static InvalidGenerationSourceError missingAdapterParameter(ConstructorElement2 element) {
    return InvalidGenerationSourceError(
      'The factory constructor must have a single, positional parameter of type '
      '`${Names.interface.adapter}`.',
      element: element.enclosingElement2,
    );
  }

  /// Error for a non-nullable parameter that has no default value source.
  static InvalidGenerationSourceError missingDefaultValue(
    FormalParameterElement element,
    String paramName,
  ) {
    return InvalidGenerationSourceError(
      'Non-nullable parameter `$paramName` must have a default value.\n'
      'Provide a compile-time default in the signature (e.g., `String $paramName = "value"`) or a '
      'non-constant default via `@PrefEntry(initial: yourFunction)`.',
      element: element,
    );
  }

  /// Error for when the required public factory constructor is missing.
  static InvalidGenerationSourceError missingFactoryConstructor(ClassElement2 element) {
    return InvalidGenerationSourceError(
      'Classes annotated with `${Names.annotation.module}` must have exactly one public '
      'factory constructor.',
      element: element,
    );
  }

  /// Error for when the required private schema constructor is missing.
  static InvalidGenerationSourceError missingPrivateConstructor(ClassElement2 element) {
    return InvalidGenerationSourceError(
      'Classes using this API pattern must have a private, generative constructor (e.g., '
      '`${element.displayName}._({...});`) to define the preference schema.',
      element: element,
    );
  }

  /// Error for when streamers are enabled but `dart:async` is not available.
  static InvalidGenerationSourceError missingStreamImport(ClassElement2 element) {
    return InvalidGenerationSourceError(
      'You have enabled streamers, which requires `Stream` and `StreamController`.\n'
      'Please add the following import to your file:\n\n'
      "import 'dart:async';",
      element: element,
    );
  }

  /// Error for when @PrefsModule is used on a non-abstract class.
  static InvalidGenerationSourceError moduleMustBeAbstract(ClassElement2 element) {
    return InvalidGenerationSourceError(
      'Classes annotated with `${Names.annotation.module}` must be abstract.',
      element: element,
    );
  }

  /// Error for when @PrefsModule is used on a non-class element.
  static InvalidGenerationSourceError notAClass(Element2 element) {
    return InvalidGenerationSourceError(
      '`${Names.annotation.module}` can only be used on classes.',
      element: element,
    );
  }

  /// A catch-all for unexpected crashes during the code writing phase.
  static InvalidGenerationSourceError unexpectedError(
    Element2 element,
    Object error,
    StackTrace stackTrace,
  ) {
    return InvalidGenerationSourceError(
      'An unexpected error occurred while generating the code for `${element.displayName}`.\n'
      'This is likely a bug in the generator. Please report it.\n\n'
      'ERROR: $error\n\n'
      'STACK TRACE:\n$stackTrace',
      element: element,
    );
  }

  /// Thrown when the analyzer unexpectedly fails to find the library for a given element. This
  /// indicates a potential issue with the build system or analyzer.
  static StateError unexpectedMissingLibrary(FormalParameterElement element) {
    return StateError(
      'Internal generator error: Could not find the library for parameter '
      '`${element.displayName}`. This might be a bug in the generator or the build system. Please '
      'try rebuilding or report the issue.',
    );
  }

  /// Error for when a parameter has an unsupported type and no custom converter is provided.
  static InvalidGenerationSourceError unsupportedType(
    FormalParameterElement element,
    String paramName,
    DartType type,
  ) {
    return InvalidGenerationSourceError(
      'Parameter `$paramName` has an unsupported preference type: `${type.getDisplayString()}`.\n'
      'You must provide a `PrefConverter` or `toStorage`/`fromStorage` functions for this type in '
      'the `${Names.annotation.entry}` annotation.',
      element: element,
    );
  }
}
