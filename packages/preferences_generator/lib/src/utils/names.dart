import 'package:preferences_annotation/preferences_annotation.dart';

class Names {
  const Names._();

  // --- Library URIs ---
  static const ({String dartAsyncUrl}) library = (
    dartAsyncUrl: 'dart:async',
  );

  // --- Annotation names ---
  static const ({String entry, String module}) annotation = (
    module: '@PrefsModule',
    entry: '@PrefEntry',
  );

  static const ({String adapter}) interface = (adapter: 'PrefsAdapter');

  // --- Annotation field keys (for ConstantReader) ---
  static const ({
    String asyncGetter,
    String asyncRemover,
    String asyncSetter,
    String converter,
    String fromStorage,
    String getter,
    String initial,
    String key,
    String notifiable,
    String onWriteError,
    String readOnly,
    String refresh,
    String removeAll,
    String remover,
    String setter,
    String streamer,
    String toStorage,
  })
  field = (
    key: 'key',
    notifiable: 'notifiable',
    readOnly: 'readOnly',
    initial: 'initial',
    onWriteError: 'onWriteError',
    getter: 'getter',
    setter: 'setter',
    remover: 'remover',
    asyncGetter: 'asyncGetter',
    asyncSetter: 'asyncSetter',
    asyncRemover: 'asyncRemover',
    streamer: 'streamer',
    removeAll: 'removeAll',
    refresh: 'refresh',
    converter: 'converter',
    toStorage: 'toStorage',
    fromStorage: 'fromStorage',
  );

  // --- Generated class & mixin names ---
  static String implementationClass(String moduleName) => '_$moduleName';

  static String interfaceMixin(String moduleName) => '_\$$moduleName';

  static String keysClass(String moduleName) => '_${moduleName}Keys';

  // --- Generated field & variable names ---
  static const adapterFieldName = '_adapter';

  /// The boolean variable used inside `_load()` to track whether any value
  /// changed and a `notifyListeners()` call is needed.
  static const changeMarkerVar = 'hasChanged';

  /// The boolean field on the implementation class that guards `_load()` from
  /// running more than once before an explicit [refresh].
  static const isLoadedVar = '_isLoaded';

  /// The sentinel string value written into [PrefEntry.disabled].
  /// The generator checks for this exact string to force-disable a method.
  static const prefEntryDisabledSentinel = '\x00__pref_disabled__\x00';

  static String cachedField(String entryName) => '_$entryName';

  static String streamControllerField(String entryName) => '_${entryName}StreamController';

  // --- Generated method parameter names ---
  static const valueParameter = 'value';

  // --- Generated method names ---
  static const privateLoadMethod = '_load';
  static const disposeMethod = 'dispose';
}
