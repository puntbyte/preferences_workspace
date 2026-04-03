import 'package:preferences_generator/src/models/entry.dart';
import 'package:preferences_generator/src/utils/names.dart';

/// The fully resolved data model for a single `@PrefsModule`-annotated class.
///
/// This is the central model produced by the analysis phase and consumed by
/// all writer classes. It holds the resolved state for the module as a whole
/// and a list of [Entry] models for each preference field.
class Module {
  final String name;

  /// Whether changes to any entry should trigger `notifyListeners()`.
  final bool notifiable;

  /// Whether the user's class mixes in `ChangeNotifier`.
  final bool usesChangeNotifier;

  /// The code expression for the optional write-error callback function, e.g.
  /// `'AppSettings._onWriteError'`. `null` means no error handling was provided.
  final String? onWriteErrorExpression;

  // --- Module-level method names (null = disabled) ---

  /// The literal name of the generated `removeAll` method, or `null` if disabled.
  final String? removeAll;

  /// The literal name of the generated `refresh` method, or `null` if disabled.
  final String? refresh;

  final List<Entry> entries;

  // --- Calculated convenience properties ---

  /// The name of the generated concrete implementation class (e.g., `_AppSettings`).
  late final String implementationName = Names.implementationClass(name);

  /// The name of the generated mixin (e.g., `_$AppSettings`).
  late final String interfaceName = Names.interfaceMixin(name);

  /// The name of the generated keys class (e.g., `_AppSettingsKeys`).
  late final String keysName = Names.keysClass(name);

  /// `true` if any entry has streaming enabled.
  late final bool hasStreams = entries.any((e) => e.resolvedStream != null);

  /// `true` if the module or any entry participates in `notifyListeners()`.
  late final bool isNotifiable = notifiable || entries.any((e) => e.resolvedNotifiable);

  Module({
    required this.name,
    required this.notifiable,
    required this.usesChangeNotifier,
    required this.onWriteErrorExpression,
    required this.removeAll,
    required this.refresh,
    required this.entries,
  });
}
