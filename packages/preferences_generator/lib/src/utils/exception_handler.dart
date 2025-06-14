import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'name_registry.dart';

/// A centralized handler for creating consistent build-time errors.
class ExceptionHandler {
  const ExceptionHandler._();

  /// Error for when @PreferenceModule is used on a non-class element.
  static InvalidGenerationSourceError notAClass(Element element) {
    return InvalidGenerationSourceError(
      '`${NameRegistry.moduleAnnotation}` can only be used on classes.',
      element: element,
    );
  }

  /// Error for when a @PreferenceModule class is not abstract.
  static InvalidGenerationSourceError moduleMustBeAbstract(
    ClassElement element,
  ) {
    return InvalidGenerationSourceError(
      'Classes annotated with `${NameRegistry.moduleAnnotation}` must be abstract.',
      element: element,
    );
  }

  /// Error for when a factory constructor is missing.
  static InvalidGenerationSourceError missingFactoryConstructor(
    ClassElement element,
  ) {
    return InvalidGenerationSourceError(
      'The class `${element.name}` must have a factory constructor that redirects to '
      '`${NameRegistry.implementationClass(element.name)}`.',
      element: element,
    );
  }

  /// Error for when the factory redirects to the wrong class.
  static InvalidGenerationSourceError incorrectFactoryRedirect(
    ConstructorElement element,
  ) {
    return InvalidGenerationSourceError(
      'The factory constructor must redirect to '
      '`${NameRegistry.implementationClass(element.enclosingElement3.name)}`.',
      element: element,
    );
  }

  /// Error for when the adapter parameter is missing or incorrect.
  static InvalidGenerationSourceError missingAdapterParameter(
    ConstructorElement element,
  ) {
    return InvalidGenerationSourceError(
      'The factory constructor for `${element.enclosingElement3.name}` must have a single '
      'positional parameter of type `${NameRegistry.adapterInterface}`.',
      element: element,
    );
  }

  /// Error for when a parameter is missing the @PreferenceEntry annotation.
  static InvalidGenerationSourceError missingEntryAnnotation(
    ParameterElement element,
  ) {
    return InvalidGenerationSourceError(
      'Constructor parameters for preferences must be annotated with `${NameRegistry.entryAnnotation}`.',
      element: element,
    );
  }

  /// Error for when a parameter has an unsupported type.
  static InvalidGenerationSourceError unsupportedType(
    ParameterElement element,
  ) {
    return InvalidGenerationSourceError(
      "Parameter '${element.name}' has an unsupported preference type: "
      "'${element.type.getDisplayString(withNullability: true)}'.\n"
      "Supported types are: int, String, double, bool, List, Set, Map, Enum, Record, DateTime, and "
      "Duration.",
      element: element,
    );
  }

  /// Error for when a non-nullable parameter has no default value.
  static InvalidGenerationSourceError missingDefaultValue(
    ParameterElement element,
  ) {
    return InvalidGenerationSourceError(
      "Non-nullable parameter '${element.name}' must have a default value provided in the "
      "`${NameRegistry.entryAnnotation}` annotation.",
      element: element,
    );
  }

  /// Error for when a class with methods is missing a private generative constructor.
  static InvalidGenerationSourceError privateConstructorNeeded(
    ClassElement element,
  ) {
    return InvalidGenerationSourceError(
      "To define custom methods or fields, add a private generative constructor: "
      "`${element.name}._();`",
      element: element,
    );
  }
}
