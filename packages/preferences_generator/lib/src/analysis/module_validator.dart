import 'package:analyzer/dart/element/element2.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/exception_handler.dart';
import 'package:preferences_generator/src/utils/method_namer.dart';
import 'package:preferences_generator/src/utils/names.dart';

/// A record type to hold the collection of both required constructors.
typedef Constructors = ({ConstructorElement2 factory, ConstructorElement2 schema});

/// A specialized class to handle all validation logic for a preference module.
class ModuleValidator {
  const ModuleValidator();

  /// Finds and validates the required factory and private schema constructors.
  Constructors findConstructors(ClassElement2 element) {
    if (!element.isAbstract) throw ExceptionHandler.moduleMustBeAbstract(element);

    final factoryConstructor = element.constructors2.firstWhere(
      (constructor) => constructor.isFactory && constructor.isPublic,
      orElse: () => throw ExceptionHandler.missingFactoryConstructor(element),
    );

    factoryConstructor.formalParameters.firstWhere(
      (parameter) => parameter.isPositional,
      orElse: () => throw ExceptionHandler.missingAdapterParameter(factoryConstructor),
    );

    final schemaConstructor = element.constructors2.firstWhere(
      (constructor) => !constructor.isFactory && constructor.isPrivate,
      orElse: () => throw ExceptionHandler.missingPrivateConstructor(element),
    );

    return (factory: factoryConstructor, schema: schemaConstructor);
  }

  /// Iterates through all enabled methods and throws an error if a name collision is found.
  void checkForDuplicateMethodNames(ClassElement2 element, Module module) {
    final nameMap = <String, String>{};
    final refreshConfig = module.refresh;
    final removeAllConfig = module.removeAll;
    final entries = module.entries;

    void checkAndAdd(String name, String description) {
      if (nameMap.containsKey(name)) {
        throw ExceptionHandler.duplicateMethodName(element, name, nameMap[name]!, description);
      }
      nameMap[name] = description;
    }

    if (refreshConfig.enabled) {
      final name = MethodNamer.getName(refreshConfig.name!, refreshConfig);
      checkAndAdd(name, 'module refresh method');
    }

    if (removeAllConfig.enabled) {
      final name = MethodNamer.getName(removeAllConfig.name!, removeAllConfig);
      checkAndAdd(name, 'module removeAll method');
    }

    for (final entry in entries) {
      final methodsToCheck = [
        (entry.resolvedGetter, 'getter'),
        (entry.resolvedSetter, 'setter'),
        (entry.resolvedRemover, 'remover'),
        (entry.resolvedAsyncGetter, 'async getter'),
        (entry.resolvedAsyncSetter, 'async setter'),
        (entry.resolvedAsyncRemover, 'async remover'),
        (entry.resolvedStream, 'stream'),
      ];

      for (final (config, typeDescription) in methodsToCheck) {
        if (config.enabled) {
          final name = MethodNamer.getName(entry.name, config);
          checkAndAdd(name, "$typeDescription for '${entry.name}'");
        }
      }
    }
  }

  /// Validates that if any streamers are enabled, `dart:async` is available.
  void validateStreamImport(ClassElement2 element, Module module) {
    if (!module.hasStreams) return;

    final library = element.firstFragment.libraryFragment;
    final hasDirectAsyncImport = library.libraryImports2.any(
      (imported) => imported.importedLibrary2?.uri.toString() == Names.library.dartAsyncUrl,
    );

    var hasExportedAsyncImport = false;
    for (final exported in library.libraryExports2) {
      if (exported.exportedLibrary2?.uri.toString() == Names.library.dartAsyncUrl) {
        hasExportedAsyncImport = true;
        break;
      }
    }

    if (!hasDirectAsyncImport && !hasExportedAsyncImport) {
      throw ExceptionHandler.missingStreamImport(element);
    }
  }
}
