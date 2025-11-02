import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor2.dart';
import 'package:build/build.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:preferences_generator/src/analysis/config_resolver.dart';
import 'package:preferences_generator/src/analysis/entry_parser.dart';
import 'package:preferences_generator/src/analysis/module_config_parser.dart';
import 'package:preferences_generator/src/analysis/module_validator.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:source_gen/source_gen.dart';

/// Visits the user's abstract class and orchestrates the parsing and validation
/// process to build a complete [Module] model.
class ModelVisitor extends SimpleElementVisitor2<void> {
  final BuilderOptions buildOptions;
  Module? module;

  ModelVisitor(this.buildOptions);

  static const _moduleChecker = TypeChecker.typeNamed(PrefsModule);
  static const _validator = ModuleValidator();
  static const _configParser = ModuleConfigParser();

  @override
  void visitClassElement(ClassElement element) {
    final moduleAnnotation = _moduleChecker.firstAnnotationOf(element);
    if (moduleAnnotation == null) return;

    final finalKeyCase = _resolveKeyCase(ConstantReader(moduleAnnotation));

    // 1. Perform initial validation.
    final constructors = _validator.findConstructors(element);

    // 2. Parse module-level configurations.
    final configs = _configParser.parse(ConstantReader(moduleAnnotation));
    final usesChangeNotifier = element.allSupertypes.any(
      (supertype) => supertype.element.name == 'ChangeNotifier',
    );

    // 3. Prepare and run the entry parser.
    final configResolver = ConfigResolver(
      moduleNotifiable: configs.notifiable,
      moduleGetterConfig: configs.getter,
      moduleSetterConfig: configs.setter,
      moduleRemoverConfig: configs.remover,
      moduleAsyncGetterConfig: configs.asyncGetter,
      moduleAsyncSetterConfig: configs.asyncSetter,
      moduleAsyncRemoverConfig: configs.asyncRemover,
      moduleStreamerConfig: configs.streamer,
    );

    final entryParser = EntryParser(
      schemaConstructor: constructors.schema,
      configResolver: configResolver,
      finalKeyCase: finalKeyCase,
    );
    final entries = entryParser.parse();

    // 4. Assemble the final module model.
    final finalModule = Module(
      name: element.displayName,
      notifiable: configs.notifiable,
      usesChangeNotifier: usesChangeNotifier,
      getter: configs.getter,
      setter: configs.setter,
      remover: configs.remover,
      asyncGetter: configs.asyncGetter,
      asyncSetter: configs.asyncSetter,
      asyncRemover: configs.asyncRemover,
      streamer: configs.streamer,
      removeAll: configs.removeAll,
      refresh: configs.refresh,
      entries: entries,
    );

    // 5. Perform post-parsing validation.
    _validator
      ..checkForDuplicateMethodNames(element, finalModule)
      ..validateStreamImport(element, finalModule);

    // 6. Set the final result.
    module = finalModule;
  }

  KeyCase _resolveKeyCase(ConstantReader moduleAnnotation) {
    // 1. Check for @PrefsModule(keyCase: ...)
    final moduleKeyCaseReader = moduleAnnotation.read('keyCase');
    if (!moduleKeyCaseReader.isNull) {
      final keyCaseName = moduleKeyCaseReader.objectValue.getField('name')?.toStringValue();
      return KeyCase.values.firstWhere((e) => e.name == keyCaseName, orElse: () => KeyCase.asis);
    }

    // 2. Check for `key_case` in build.yaml
    final globalKeyCase = buildOptions.config['key_case'] as String?;
    if (globalKeyCase != null) {
      return KeyCase.values.firstWhere((e) => e.name == globalKeyCase, orElse: () => KeyCase.asis);
    }

    // 3. Default
    return KeyCase.asis;
  }
}
