import 'package:meta/meta.dart';
import 'package:preferences_annotation/preferences_annotation.dart' show PrefsModule;
import 'package:preferences_annotation/src/annotations/prefs_module.dart' show PrefsModule;
import 'package:preferences_annotation/src/interfaces/pref_converter.dart';

/// A sentinel value that can be assigned to any method template parameter on
/// [PrefEntry] to explicitly disable that method for this specific entry,
/// regardless of what the module-level [PrefsModule] preset enables.
///
/// Unlike `null`, which means "inherit from the module default", this value
/// means "force this method off for this entry only".
///
/// ### Example
///
/// ```dart
/// // This field is read-only: no setter or remover will be generated for it,
/// // even if the module preset would normally include them.
/// @PrefEntry(
///   setter: PrefEntry.disabled,
///   asyncSetter: PrefEntry.disabled,
///   remover: PrefEntry.disabled,
///   asyncRemover: PrefEntry.disabled,
/// )
/// final String installId = 'uuid-1234-abcd',
/// ```
///
/// For a shorter equivalent, use [PrefEntry.readOnly].
const _kPrefEntryDisabled = '\x00__pref_disabled__\x00';

@immutable
class PrefEntry<TypeEntry, TypeStorage> {
  /// A sentinel constant. Assign to any method template parameter to force
  /// that method to be disabled for this entry only.
  ///
  /// See the class-level documentation for usage examples.
  static const String disabled = _kPrefEntryDisabled;

  // ---------------------------------------------------------------------------
  // Core
  // ---------------------------------------------------------------------------

  /// Overrides the storage key for this entry.
  ///
  /// Takes precedence over any [PrefsModule.keyCase] convention.
  ///
  /// ```dart
  /// @PrefEntry(key: 'launch_counter')
  /// int launchCount = 0,
  /// ```
  final String? key;

  /// Overrides whether this entry participates in `notifyListeners()` calls.
  ///
  /// When `null` (the default), the value from [PrefsModule.notifiable] is
  /// inherited. Set to `false` to suppress notifications for a specific field
  /// even when the rest of the module is notifiable.
  final bool? notifiable;

  /// A shorthand that disables all write methods (setter, asyncSetter, remover,
  /// asyncRemover) for this entry, making it effectively read-only.
  ///
  /// Equivalent to passing [PrefEntry.disabled] to all four write-method
  /// parameters individually.
  ///
  /// ```dart
  /// @PrefEntry(readOnly: true)
  /// final String installId = 'uuid-1234-abcd',
  /// ```
  final bool readOnly;

  /// A factory function used when the default value cannot be expressed as a
  /// Dart compile-time constant (e.g., it depends on runtime state like
  /// `DateTime.now()`).
  ///
  /// ```dart
  /// @PrefEntry(initial: _getCreationDate)
  /// DateTime? creationDate,
  ///
  /// static DateTime _getCreationDate() => DateTime.now();
  /// ```
  final TypeEntry Function()? initial;

  // ---------------------------------------------------------------------------
  // Method name templates
  //
  // Each parameter accepts a template string using the following tokens:
  //   {{name}}  — the camelCase field name (e.g., `isFirstLaunch`)
  //   {{Name}}  — the field name with the first letter capitalised
  //               (e.g., `IsFirstLaunch`)
  //
  // Pass `null` (default) to inherit from the module-level [PrefsModule]
  // configuration.
  //
  // Pass [PrefEntry.disabled] to explicitly disable the method for this entry.
  // ---------------------------------------------------------------------------

  /// Template for the synchronous getter.
  ///
  /// Example: `'{{name}}'` generates `isFirstLaunch`.
  final String? getter;

  /// Template for the synchronous setter.
  ///
  /// Example: `'set{{Name}}'` generates `setIsFirstLaunch(bool value)`.
  final String? setter;

  /// Template for the synchronous remover.
  ///
  /// Example: `'remove{{Name}}'` generates `removeIsFirstLaunch()`.
  final String? remover;

  /// Template for the asynchronous getter.
  ///
  /// Example: `'{{name}}Async'` generates `Future<bool> isFirstLaunchAsync()`.
  final String? asyncGetter;

  /// Template for the asynchronous setter.
  ///
  /// Example: `'set{{Name}}Async'` generates
  /// `Future<void> setIsFirstLaunchAsync(bool value)`.
  final String? asyncSetter;

  /// Template for the asynchronous remover.
  ///
  /// Example: `'remove{{Name}}Async'` generates
  /// `Future<void> removeIsFirstLaunchAsync()`.
  final String? asyncRemover;

  /// Template for the stream getter.
  ///
  /// Example: `'{{name}}Stream'` generates
  /// `Stream<bool> get isFirstLaunchStream`.
  ///
  /// Example: `'watch{{Name}}Changes'` generates
  /// `Stream<bool> get watchIsFirstLaunchChanges`.
  final String? streamer;

  // ---------------------------------------------------------------------------
  // Custom serialization
  // ---------------------------------------------------------------------------

  /// A reusable [PrefConverter] instance for serializing this entry's type to
  /// and from a primitive storage type.
  ///
  /// Cannot be used together with [toStorage]/[fromStorage].
  ///
  /// ```dart
  /// @PrefEntry(converter: ColorConverter())
  /// Color? accentColor,
  /// ```
  final PrefConverter<dynamic, dynamic>? converter;

  /// A reference to a static function that serializes this entry's value into
  /// a storable primitive.
  ///
  /// Must be used together with [fromStorage]. Cannot be combined with
  /// [converter].
  ///
  /// ```dart
  /// @PrefEntry(toStorage: _sessionToJson, fromStorage: _sessionFromJson)
  /// ApiSession? session,
  ///
  /// static Map<String, dynamic> _sessionToJson(ApiSession s) => s.toJson();
  /// ```
  final TypeStorage Function(TypeEntry value)? toStorage;

  /// A reference to a static function that deserializes a storable primitive
  /// back into this entry's type.
  ///
  /// Must be used together with [toStorage].
  final TypeEntry Function(TypeStorage value)? fromStorage;

  const PrefEntry({
    this.key,
    this.notifiable,
    this.readOnly = false,
    this.initial,
    this.getter,
    this.setter,
    this.remover,
    this.asyncGetter,
    this.asyncSetter,
    this.asyncRemover,
    this.streamer,
    this.converter,
    this.toStorage,
    this.fromStorage,
  }) : assert(
         converter == null || (toStorage == null && fromStorage == null),
         'You can provide `converter` OR `toStorage`/`fromStorage`, but not both.',
       ),
       assert(
         (toStorage == null) == (fromStorage == null),
         'You must provide both `toStorage` and `fromStorage` together, or neither.',
       );
}
