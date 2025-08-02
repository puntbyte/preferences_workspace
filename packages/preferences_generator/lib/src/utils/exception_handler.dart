import 'package:analyzer/dart/element/element2.dart';
import 'package:source_gen/source_gen.dart';
import 'name_registry.dart';

/// A centralized handler for creating consistent build-time errors.
class ExceptionHandler {
  const ExceptionHandler._();

  /// Error for when @PreferenceModule is used on a non-class element.
  static InvalidGenerationSourceError notAClass(Element2 element) {
    return InvalidGenerationSourceError(
      '`${NameRegistry.moduleAnnotation}` can only be used on classes.',
      element: element,
    );
  }

  /// Error for when a @PreferenceModule class is not abstract.
  static InvalidGenerationSourceError moduleMustBeAbstract(
    ClassElement2 element,
  ) {
    return InvalidGenerationSourceError(
      'Classes annotated with `${NameRegistry.moduleAnnotation}` must be abstract.',
      element: element,
    );
  }

  /// Error for when a factory constructor is missing.
  static InvalidGenerationSourceError missingFactoryConstructor(
    ClassElement2 element,
  ) {
    return InvalidGenerationSourceError(
      'The class `${element.name3}` must have a factory constructor that redirects to '
      '`${NameRegistry.implementationClass(element.displayName)}`.',
      element: element,
    );
  }

  /// Error for when the factory redirects to the wrong class.
  static InvalidGenerationSourceError incorrectFactoryRedirect(
    ConstructorElement2 element,
  ) {
    return InvalidGenerationSourceError(
      'The factory constructor must redirect to '
      '`${NameRegistry.implementationClass(element.enclosingElement2.displayName)}`.',
      element: element,
    );
  }

  /// Error for when the adapter parameter is missing or incorrect.
  static InvalidGenerationSourceError missingAdapterParameter(
    ConstructorElement2 element,
  ) {
    return InvalidGenerationSourceError(
      'The factory constructor for `${element.enclosingElement2.name3}` must have a single '
      'positional parameter of type `${NameRegistry.adapterInterface}`.',
      element: element,
    );
  }

  /// Error for when a parameter is missing the @PreferenceEntry annotation.
  static InvalidGenerationSourceError missingEntryAnnotation(
      FormalParameterElement element,
  ) {
    return InvalidGenerationSourceError(
      'Constructor parameters for preferences must be annotated with `${NameRegistry.entryAnnotation}`.',
      element: element,
    );
  }

  /// Error for when a parameter has an unsupported type.
  static InvalidGenerationSourceError unsupportedType(
      FormalParameterElement element,
  ) {
    return InvalidGenerationSourceError(
      "Parameter '${element.name3}' has an unsupported preference type: "
      "'${element.type.getDisplayString(withNullability: true)}'.\n"
      "Supported types are: int, String, double, bool, List, Set, Map, Enum, Record, DateTime, and "
      "Duration.",
      element: element,
    );
  }

  /// Error for when a non-nullable parameter has no default value.
  static InvalidGenerationSourceError missingDefaultValue(
      FormalParameterElement element,
  ) {
    return InvalidGenerationSourceError(
      "Non-nullable parameter '${element.name3}' must have a default value provided in the "
      "`${NameRegistry.entryAnnotation}` annotation.",
      element: element,
    );
  }

  /// Error for when a class with methods is missing a private generative constructor.
  static InvalidGenerationSourceError privateConstructorNeeded(
    ClassElement2 element,
  ) {
    return InvalidGenerationSourceError(
      "To define custom methods or fields, add a private generative constructor: "
      "`${element.name3}._();`",
      element: element,
    );
  }
}
