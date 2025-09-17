class Names {
  const Names._();

  // --- Library URIs ---
  static const library = (dartAsyncUrl: 'dart:async');

  // --- Annotations Names ---
  static const annotation = (module: '@PrefsModule', entry: '@PrefEntry');
  static const interface = (adapter: 'PrefsAdapter');

  // --- Annotation Field Keys (for ConstantReader) ---
  static const field = (
    key: 'key',
    notifiable: 'notifiable',
    initial: 'initial',

    enabled: 'enabled',
    name: 'name',
    prefix: 'prefix',
    suffix: 'suffix',

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

  // --- Generated Class & Mixin Names ---
  static String implementationClass(String moduleName) => '_$moduleName';
  static String interfaceMixin(String moduleName) => '_\$$moduleName';
  static String keysClass(String moduleName) => '_${moduleName}Keys';

  // --- Generated Field & Variable Names ---
  static const adapterFieldName = '_adapter';
  static const changeMarkerVar = 'P_changed';
  static String cachedField(String entryName) => '_$entryName';
  static String streamControllerField(String entryName) => '_${entryName}StreamController';

  // --- Generated Method Parameter Names ---
  static const valueParameter = 'value';

  // --- Generated Method Names ---
  static const privateLoadMethod = '_load';
  static const disposeMethod = 'dispose';
}
