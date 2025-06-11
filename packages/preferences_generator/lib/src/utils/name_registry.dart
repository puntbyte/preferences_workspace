import 'package:preferences_generator/src/utils/extensions/string_extension.dart';

/// A centralized class for all naming conventions used in the generator.
///
/// This ensures consistency and makes future refactoring of generated code
/// possible from a single location.
class NameRegistry {
  const NameRegistry._();

  // --- Public API Names (for error messages) ---
  static const moduleAnnotation = '@PreferenceModule';
  static const entryAnnotation = '@PreferenceEntry';
  static const adapterInterface = 'PreferenceAdapter';

  // --- Generated Class Names ---
  static String implementationClass(String moduleName) => '_$moduleName';
  static String interfaceMixin(String moduleName) => '_\$$moduleName';
  static String keysClass(String moduleName) => '_${moduleName}Keys';

  // --- Generated Field & Variable Names ---
  static const adapterFieldName = '_adapter';
  static String cachedField(String entryName) => '_$entryName';
  static String rawValueVar(String entryName) => 'rawValueFor${entryName.toPascalCase()}';
  static String newValueVar(String entryName) => 'newValueFor${entryName.toPascalCase()}';

  static const changeMarkerVar = 'P_changed';

  static const valueParameter = 'value';
  static const toStoreParameter = 'toStore';

  // --- Generated Method Names ---
  static const privateLoadMethod = '_load';
  static const publicReloadMethod = 'reload';
  static const publicClearMethod = 'clear';

  static String setter(String entryName) => 'set${entryName.toPascalCase()}';
  static String removerMethod(String entryName) => 'remove${entryName.toPascalCase()}';
  static String asyncGetter(String entryName) => '${entryName}Async';

  static const ignoreWords = <String>[
    "dispose",
    "addListener",
    "removeListener",
    "hasListeners",
    "notifyListeners",
    "load",
    "loading"
  ];
}