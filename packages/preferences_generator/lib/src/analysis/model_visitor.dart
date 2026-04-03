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

/// Visits the user's abstract class and orchestrates the analysis and
/// validation pipeline to produce a fully resolved [Module] model.
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

    final annotationReader = ConstantReader(moduleAnnotation);

    // 1. Resolve the storage key casing convention.
    final finalKeyCase = _resolveKeyCase(annotationReader);

    // 2. Structural validation — must happen before any parsing.
    final constructors = _validator.findConstructors(element);

    // 3. Parse module-level configuration from the annotation.
    final configs = _configParser.parse(annotationReader);

    // 4. Validate module-level template strings.
    _validator.validateModuleTemplates(
      element,
      getter: configs.getter,
      setter: configs.setter,
      remover: configs.remover,
      asyncGetter: configs.asyncGetter,
      asyncSetter: configs.asyncSetter,
      asyncRemover: configs.asyncRemover,
      streamer: configs.streamer,
    );

    final usesChangeNotifier = element.allSupertypes.any(
      (supertype) => supertype.element.name == 'ChangeNotifier',
    );

    // 5. Build the config resolver and run the entry parser.
    final configResolver = ConfigResolver(
      moduleNotifiable: configs.notifiable,
      moduleGetter: configs.getter,
      moduleSetter: configs.setter,
      moduleRemover: configs.remover,
      moduleAsyncGetter: configs.asyncGetter,
      moduleAsyncSetter: configs.asyncSetter,
      moduleAsyncRemover: configs.asyncRemover,
      moduleStreamer: configs.streamer,
    );

    final entries = EntryParser(
      schemaConstructor: constructors.schema,
      configResolver: configResolver,
      finalKeyCase: finalKeyCase,
    ).parse();

    // 6. Assemble the final module model.
    final finalModule = Module(
      name: element.displayName,
      notifiable: configs.notifiable,
      usesChangeNotifier: usesChangeNotifier,
      onWriteErrorExpression: configs.onWriteErrorExpression,
      removeAll: configs.removeAll,
      refresh: configs.refresh,
      entries: entries,
    );

    // 7. Post-parse validation.
    _validator
      ..checkForDuplicateMethodNames(element, finalModule)
      ..validateStreamImport(element, finalModule);

    module = finalModule;
  }

  KeyCase _resolveKeyCase(ConstantReader moduleAnnotation) {
    // 1. Check for @PrefsModule(keyCase: ...)
    final moduleKeyCaseReader = moduleAnnotation.read('keyCase');
    if (!moduleKeyCaseReader.isNull) {
      final keyCaseName = moduleKeyCaseReader.objectValue.getField('name')?.toStringValue();
      return KeyCase.values.firstWhere(
        (e) => e.name == keyCaseName,
        orElse: () => KeyCase.asis,
      );
    }

    // 2. Check for `key_case` in build.yaml.
    final globalKeyCase = buildOptions.config['key_case'] as String?;
    if (globalKeyCase != null) {
      return KeyCase.values.firstWhere(
        (e) => e.name == globalKeyCase,
        orElse: () => KeyCase.asis,
      );
    }

    // 3. Default: no transformation.
    return KeyCase.asis;
  }
}
