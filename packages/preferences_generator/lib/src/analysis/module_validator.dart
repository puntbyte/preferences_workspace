import 'package:analyzer/dart/element/element.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/exception_handler.dart';
import 'package:preferences_generator/src/utils/method_namer.dart';
import 'package:preferences_generator/src/utils/names.dart';

/// A record type to hold both required constructors found on the schema class.
typedef Constructors = ({
  ConstructorElement factory,
  ConstructorElement schema,
});

/// Handles all validation logic for a preference module, both before and after
/// the entry-parsing phase.
class ModuleValidator {
  const ModuleValidator();

  // ---------------------------------------------------------------------------
  // Pre-parse: structural checks on the class element
  // ---------------------------------------------------------------------------

  /// Finds and validates the required factory and private schema constructors.
  Constructors findConstructors(ClassElement element) {
    if (!element.isAbstract) {
      throw ExceptionHandler.moduleMustBeAbstract(element);
    }

    final factoryConstructor = element.constructors.firstWhere(
      (c) => c.isFactory && c.isPublic,
      orElse: () => throw ExceptionHandler.missingFactoryConstructor(element),
    );

    factoryConstructor.formalParameters.firstWhere(
      (p) => p.isPositional,
      orElse: () => throw ExceptionHandler.missingAdapterParameter(factoryConstructor),
    );

    final schemaConstructor = element.constructors.firstWhere(
      (c) => !c.isFactory && c.isPrivate,
      orElse: () => throw ExceptionHandler.missingPrivateConstructor(element),
    );

    return (factory: factoryConstructor, schema: schemaConstructor);
  }

  // ---------------------------------------------------------------------------
  // Post-parse: checks on the fully assembled Module model
  // ---------------------------------------------------------------------------

  /// Validates that all module-level template strings contain at least one
  /// `{{name}}` or `{{Name}}` token.
  ///
  /// Module-level templates must be parameterised, otherwise every entry would
  /// generate a method with the same literal name.
  void validateModuleTemplates(
    ClassElement element, {
    required String? getter,
    required String? setter,
    required String? remover,
    required String? asyncGetter,
    required String? asyncSetter,
    required String? asyncRemover,
    required String? streamer,
  }) {
    void check(String? template, String methodType) {
      if (template == null) return;
      if (!MethodNamer.hasToken(template)) {
        throw ExceptionHandler.invalidModuleTemplate(
          element,
          template,
          methodType,
        );
      }
    }

    check(getter, Names.field.getter);
    check(setter, Names.field.setter);
    check(remover, Names.field.remover);
    check(asyncGetter, Names.field.asyncGetter);
    check(asyncSetter, Names.field.asyncSetter);
    check(asyncRemover, Names.field.asyncRemover);
    check(streamer, Names.field.streamer);
  }

  /// Iterates through all enabled methods and throws if any two methods resolve
  /// to the same name.
  void checkForDuplicateMethodNames(ClassElement element, Module module) {
    final nameMap = <String, String>{};

    void checkAndAdd(String? name, String description) {
      if (name == null) return;
      if (nameMap.containsKey(name)) {
        throw ExceptionHandler.duplicateMethodName(
          element,
          name,
          nameMap[name]!,
          description,
        );
      }
      nameMap[name] = description;
    }

    // Module-level methods.
    checkAndAdd(module.refresh, 'module refresh method');
    checkAndAdd(module.removeAll, 'module removeAll method');

    // Per-entry methods.
    for (final entry in module.entries) {
      checkAndAdd(entry.resolvedGetter, "getter for '${entry.name}'");
      checkAndAdd(entry.resolvedSetter, "setter for '${entry.name}'");
      checkAndAdd(entry.resolvedRemover, "remover for '${entry.name}'");
      checkAndAdd(entry.resolvedAsyncGetter, "async getter for '${entry.name}'");
      checkAndAdd(entry.resolvedAsyncSetter, "async setter for '${entry.name}'");
      checkAndAdd(entry.resolvedAsyncRemover, "async remover for '${entry.name}'");
      checkAndAdd(entry.resolvedStream, "streamer for '${entry.name}'");
    }
  }

  /// Validates that `dart:async` is imported when any streamer is enabled.
  void validateStreamImport(ClassElement element, Module module) {
    if (!module.hasStreams) return;

    final library = element.firstFragment.libraryFragment;
    final hasDirectAsyncImport = library.libraryImports.any(
      (i) => i.importedLibrary?.uri.toString() == Names.library.dartAsyncUrl,
    );
    var hasExportedAsyncImport = false;
    for (final exported in library.libraryExports) {
      if (exported.exportedLibrary?.uri.toString() == Names.library.dartAsyncUrl) {
        hasExportedAsyncImport = true;
        break;
      }
    }

    if (!hasDirectAsyncImport && !hasExportedAsyncImport) {
      throw ExceptionHandler.missingStreamImport(element);
    }
  }
}
