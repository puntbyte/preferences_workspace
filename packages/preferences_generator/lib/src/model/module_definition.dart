import 'package:analyzer/dart/element/element.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:preferences_generator/src/model/entry_definition.dart';
import 'package:source_gen/source_gen.dart';

import '../utils/exception_handler.dart';
import '../utils/name_registry.dart';

class ModuleDefinition {
  final String name;
  final String implementationName;
  final String interfaceName;
  final String keysName;
  final List<EntryDefinition> entries;
  final bool usesChangeNotifier;

  const ModuleDefinition({
    required this.name,
    required this.implementationName,
    required this.interfaceName,
    required this.keysName,
    required this.entries,
    required this.usesChangeNotifier,
  });

  factory ModuleDefinition.fromElement(ClassElement element) {
    if (!element.isAbstract)
      throw ExceptionHandler.moduleMustBeAbstract(element);

    final name = element.name;
    final factoryConstructor = element.constructors.firstWhere(
      (constructor) => constructor.isFactory,
      orElse: () => throw ExceptionHandler.missingFactoryConstructor(element),
    );

    /*final redirectedConstructorName = factoryConstructor.redirectedConstructor?.name;
    if (redirectedConstructorName != NameRegistry.implementationClass(name)) {
      throw ExceptionHandler.incorrectFactoryRedirect(factoryConstructor);
    }*/

    factoryConstructor.parameters.firstWhere(
      (parameter) =>
          const TypeChecker.fromRuntime(
            PreferenceAdapter,
          ).isAssignableFromType(parameter.type) &&
          parameter.isPositional,
      orElse: () =>
          throw ExceptionHandler.missingAdapterParameter(factoryConstructor),
    );

    final entries = factoryConstructor.parameters
        .where((parameter) => parameter.isNamed)
        .map((parameter) => EntryDefinition.fromElement(parameter))
        .toList();

    // Check for other class properties.
    final usesChangeNotifier = element.allSupertypes.any(
      (interfaceType) => interfaceType.element.name == 'ChangeNotifier',
    );

    return ModuleDefinition(
      name: name,
      implementationName: NameRegistry.implementationClass(name),
      interfaceName: NameRegistry.interfaceMixin(name),
      keysName: NameRegistry.keysClass(name),
      entries: entries,
      usesChangeNotifier: usesChangeNotifier,
    );
  }
}
