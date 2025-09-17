import 'package:preferences_generator/src/models/method_config.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:source_gen/source_gen.dart';

/// A record holding the collection of all parsed, entry-level method configs.
typedef _EntryConfigs = ({
  UnresolvedMethodConfig getter,
  UnresolvedMethodConfig setter,
  UnresolvedMethodConfig remover,
  UnresolvedMethodConfig asyncGetter,
  UnresolvedMethodConfig asyncSetter,
  UnresolvedMethodConfig asyncRemover,
  UnresolvedMethodConfig streamer,
});

/// A record holding the final, resolved configurations for an entry.
typedef ResolvedEntryConfigs = ({
  bool notifiable,
  ResolvedMethodConfig getter,
  ResolvedMethodConfig setter,
  ResolvedMethodConfig remover,
  ResolvedMethodConfig asyncGetter,
  ResolvedMethodConfig asyncSetter,
  ResolvedMethodConfig asyncRemover,
  ResolvedMethodConfig streamer,
});

/// Resolves the final method configurations by layering the entry-level settings
/// over the module-level defaults.
class ConfigResolver {
  final bool _moduleNotifiable;
  final UnresolvedMethodConfig _moduleGetterConfig;
  final UnresolvedMethodConfig _moduleSetterConfig;
  final UnresolvedMethodConfig _moduleRemoverConfig;
  final UnresolvedMethodConfig _moduleAsyncGetterConfig;
  final UnresolvedMethodConfig _moduleAsyncSetterConfig;
  final UnresolvedMethodConfig _moduleAsyncRemoverConfig;
  final UnresolvedMethodConfig _moduleStreamerConfig;

  const ConfigResolver({
    required bool moduleNotifiable,
    required UnresolvedMethodConfig moduleGetterConfig,
    required UnresolvedMethodConfig moduleSetterConfig,
    required UnresolvedMethodConfig moduleRemoverConfig,
    required UnresolvedMethodConfig moduleAsyncGetterConfig,
    required UnresolvedMethodConfig moduleAsyncSetterConfig,
    required UnresolvedMethodConfig moduleAsyncRemoverConfig,
    required UnresolvedMethodConfig moduleStreamerConfig,
  }) : _moduleNotifiable = moduleNotifiable,
       _moduleGetterConfig = moduleGetterConfig,
       _moduleSetterConfig = moduleSetterConfig,
       _moduleRemoverConfig = moduleRemoverConfig,
       _moduleAsyncGetterConfig = moduleAsyncGetterConfig,
       _moduleAsyncSetterConfig = moduleAsyncSetterConfig,
       _moduleAsyncRemoverConfig = moduleAsyncRemoverConfig,
       _moduleStreamerConfig = moduleStreamerConfig;

  /// Resolves all method configurations for a single entry.
  ResolvedEntryConfigs resolve(ConstantReader annotationReader) {
    final entryConfigs = _parseEntryConfigs(annotationReader);
    final notifiable = annotationReader.isNull
        ? _moduleNotifiable
        : (annotationReader.read(Names.field.notifiable).isNull
              ? _moduleNotifiable
              : annotationReader.read(Names.field.notifiable).boolValue);

    return (
      notifiable: notifiable,
      getter: _resolveSingle(entryConfigs.getter, _moduleGetterConfig, enabled: true),
      setter: _resolveSingle(entryConfigs.setter, _moduleSetterConfig, enabled: true),
      remover: _resolveSingle(entryConfigs.remover, _moduleRemoverConfig, enabled: true),
      asyncGetter: _resolveSingle(
        entryConfigs.asyncGetter,
        _moduleAsyncGetterConfig,
        enabled: true,
      ),
      asyncSetter: _resolveSingle(
        entryConfigs.asyncSetter,
        _moduleAsyncSetterConfig,
        enabled: true,
      ),
      asyncRemover: _resolveSingle(
        entryConfigs.asyncRemover,
        _moduleAsyncRemoverConfig,
        enabled: true,
      ),
      streamer: _resolveSingle(entryConfigs.streamer, _moduleStreamerConfig, enabled: false),
    );
  }

  /// Parses the raw, entry-level method configs from the `@PrefEntry` annotation.
  _EntryConfigs _parseEntryConfigs(ConstantReader annotationReader) {
    if (annotationReader.isNull) {
      return (
        getter: const UnresolvedMethodConfig(),
        setter: const UnresolvedMethodConfig(),
        remover: const UnresolvedMethodConfig(),
        asyncGetter: const UnresolvedMethodConfig(),
        asyncSetter: const UnresolvedMethodConfig(),
        asyncRemover: const UnresolvedMethodConfig(),
        streamer: const UnresolvedMethodConfig(),
      );
    }

    return (
      getter: UnresolvedMethodConfig.fromReader(annotationReader.read(Names.field.getter)),
      setter: UnresolvedMethodConfig.fromReader(annotationReader.read(Names.field.setter)),
      remover: UnresolvedMethodConfig.fromReader(annotationReader.read(Names.field.remover)),
      asyncGetter: UnresolvedMethodConfig.fromReader(
        annotationReader.read(Names.field.asyncGetter),
      ),
      asyncSetter: UnresolvedMethodConfig.fromReader(
        annotationReader.read(Names.field.asyncSetter),
      ),
      asyncRemover: UnresolvedMethodConfig.fromReader(
        annotationReader.read(Names.field.asyncRemover),
      ),
      streamer: UnresolvedMethodConfig.fromReader(annotationReader.read(Names.field.streamer)),
    );
  }

  /// Helper to layer an entry-level config over a module-level one.
  ResolvedMethodConfig _resolveSingle(
    UnresolvedMethodConfig entry,
    UnresolvedMethodConfig module, {
    required bool enabled,
  }) => ResolvedMethodConfig(
    enabled: entry.enabled ?? module.enabled ?? enabled,
    prefix: entry.prefix ?? module.prefix,
    suffix: entry.suffix ?? module.suffix,
    name: entry.name ?? module.name,
  );
}
