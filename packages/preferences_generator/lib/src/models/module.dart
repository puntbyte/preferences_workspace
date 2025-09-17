import 'package:preferences_generator/src/models/entry.dart';
import 'package:preferences_generator/src/models/method_config.dart';
import 'package:preferences_generator/src/utils/names.dart';

class Module {
  final String name;
  final bool notifiable;
  final bool usesChangeNotifier;

  // Per-entity method configs
  final UnresolvedMethodConfig getter;
  final UnresolvedMethodConfig setter;
  final UnresolvedMethodConfig remover;
  final UnresolvedMethodConfig asyncGetter;
  final UnresolvedMethodConfig asyncSetter;
  final UnresolvedMethodConfig asyncRemover;
  final UnresolvedMethodConfig streamer;

  // Built-in module method configs
  final ResolvedMethodConfig removeAll;
  final ResolvedMethodConfig refresh;

  final List<Entry> entries;

  // --- Calculated Properties for Convenience in Writers ---

  /// The name of the generated concrete implementation class (e.g.,
  /// `_AppSettings`).
  late final String implementationName = Names.implementationClass(name);

  /// The name of the generated mixin (e.g., `_$AppSettings`).
  late final String interfaceName = Names.interfaceMixin(name);

  /// The name of the generated keys class (e.g., `_AppSettingsKeys`).
  late final String keysName = Names.keysClass(name);

  /// A convenience flag to check if any entry has streaming enabled.
  late final bool hasStreams = entries.any((entry) => entry.resolvedStream.enabled);

  /// A convenience flag to check if the module or any entry is notifiable.
  late final bool isNotifiable = notifiable || entries.any((entry) => entry.resolvedNotifiable);

  Module({
    required this.name,
    required this.notifiable,
    required this.usesChangeNotifier,
    required this.getter,
    required this.setter,
    required this.remover,
    required this.asyncGetter,
    required this.asyncSetter,
    required this.asyncRemover,
    required this.streamer,
    required this.removeAll,
    required this.refresh,
    required this.entries,
  });
}
