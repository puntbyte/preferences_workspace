import 'package:preferences_generator/src/models/method_config.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:source_gen/source_gen.dart';

/// A record type to hold the collection of all parsed configurations from the `@PrefsModule`
/// annotation.
typedef ModuleConfigs = ({
  bool notifiable,
  UnresolvedMethodConfig getter,
  UnresolvedMethodConfig setter,
  UnresolvedMethodConfig remover,
  UnresolvedMethodConfig asyncGetter,
  UnresolvedMethodConfig asyncSetter,
  UnresolvedMethodConfig asyncRemover,
  UnresolvedMethodConfig streamer,
  ResolvedMethodConfig removeAll,
  ResolvedMethodConfig refresh,
});

/// A specialized class to parse the `@PrefsModule` annotation from a [ConstantReader].
class ModuleConfigParser {
  const ModuleConfigParser();

  /// Parses all configuration objects from the `@PrefsModule` annotation reader.
  ModuleConfigs parse(ConstantReader reader) {
    final notifiable = reader.read(Names.field.notifiable).boolValue;
    final getter = UnresolvedMethodConfig.fromReader(reader.read(Names.field.getter));
    final setter = UnresolvedMethodConfig.fromReader(reader.read(Names.field.setter));
    final remover = UnresolvedMethodConfig.fromReader(reader.read(Names.field.remover));
    final asyncGetter = UnresolvedMethodConfig.fromReader(reader.read(Names.field.asyncGetter));
    final asyncSetter = UnresolvedMethodConfig.fromReader(reader.read(Names.field.asyncSetter));
    final asyncRemover = UnresolvedMethodConfig.fromReader(reader.read(Names.field.asyncRemover));
    final streamer = UnresolvedMethodConfig.fromReader(reader.read(Names.field.streamer));
    final rawRemoveAll = UnresolvedMethodConfig.fromReader(reader.read(Names.field.removeAll));
    final rawRefresh = UnresolvedMethodConfig.fromReader(reader.read(Names.field.refresh));

    final resolvedRemoveAll = ResolvedMethodConfig(
      enabled: rawRemoveAll.enabled ?? true,
      name: rawRemoveAll.name,
    );

    final resolvedRefresh = ResolvedMethodConfig(
      enabled: rawRefresh.enabled ?? true,
      name: rawRefresh.name,
    );

    return (
      notifiable: notifiable,
      getter: getter,
      setter: setter,
      remover: remover,
      asyncGetter: asyncGetter,
      asyncSetter: asyncSetter,
      asyncRemover: asyncRemover,
      streamer: streamer,
      removeAll: resolvedRemoveAll,
      refresh: resolvedRefresh,
    );
  }
}
