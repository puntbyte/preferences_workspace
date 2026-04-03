import 'package:preferences_generator/src/utils/method_namer.dart';
import 'package:preferences_generator/src/utils/names.dart';

/// Holds the raw (unresolved) per-entry overrides read directly from a
/// `@PrefEntry` annotation. All fields are nullable; `null` means "inherit
/// from the module default". The sentinel [Names.prefEntryDisabledSentinel]
/// means "force disabled for this entry".
typedef EntryOverrides = ({
  String? getter,
  String? setter,
  String? remover,
  String? asyncGetter,
  String? asyncSetter,
  String? asyncRemover,
  String? streamer,
  bool? notifiable,
  bool readOnly,
});

/// Resolves the final method names for a single preference entry by layering
/// per-entry [EntryOverrides] on top of the module-level template strings.
///
/// Resolution order (highest → lowest priority):
/// 1. `@PrefEntry(readOnly: true)` — forces all write methods to `null`.
/// 2. `@PrefEntry(setter: PrefEntry.disabled)` — force-disables this method.
/// 3. `@PrefEntry(setter: 'my{{Name}}')` — overrides with a custom template.
/// 4. Module-level template (e.g., `@PrefsModule(setter: 'set{{Name}}')`).
/// 5. `null` (no module template) — method is disabled.
class ConfigResolver {
  final bool moduleNotifiable;
  final String? moduleGetter;
  final String? moduleSetter;
  final String? moduleRemover;
  final String? moduleAsyncGetter;
  final String? moduleAsyncSetter;
  final String? moduleAsyncRemover;
  final String? moduleStreamer;

  const ConfigResolver({
    required this.moduleNotifiable,
    required this.moduleGetter,
    required this.moduleSetter,
    required this.moduleRemover,
    required this.moduleAsyncGetter,
    required this.moduleAsyncSetter,
    required this.moduleAsyncRemover,
    required this.moduleStreamer,
  });

  /// Produces a complete set of resolved method names for one entry.
  ///
  /// Returns a record where each field is either:
  /// - `null` → the method is disabled for this entry.
  /// - a non-null `String` → the final, literal method name to emit.
  ({
    bool notifiable,
    String? getter,
    String? setter,
    String? remover,
    String? asyncGetter,
    String? asyncSetter,
    String? asyncRemover,
    String? streamer,
  })
  resolve(String entryName, EntryOverrides overrides) {
    final readOnly = overrides.readOnly;

    return (
      notifiable: overrides.notifiable ?? moduleNotifiable,
      getter: _resolveMethod(
        entryName: entryName,
        moduleTemplate: moduleGetter,
        entryOverride: overrides.getter,
        isWriteMethod: false,
        readOnly: readOnly,
      ),
      setter: _resolveMethod(
        entryName: entryName,
        moduleTemplate: moduleSetter,
        entryOverride: overrides.setter,
        isWriteMethod: true,
        readOnly: readOnly,
      ),
      remover: _resolveMethod(
        entryName: entryName,
        moduleTemplate: moduleRemover,
        entryOverride: overrides.remover,
        isWriteMethod: true,
        readOnly: readOnly,
      ),
      asyncGetter: _resolveMethod(
        entryName: entryName,
        moduleTemplate: moduleAsyncGetter,
        entryOverride: overrides.asyncGetter,
        isWriteMethod: false,
        readOnly: readOnly,
      ),
      asyncSetter: _resolveMethod(
        entryName: entryName,
        moduleTemplate: moduleAsyncSetter,
        entryOverride: overrides.asyncSetter,
        isWriteMethod: true,
        readOnly: readOnly,
      ),
      asyncRemover: _resolveMethod(
        entryName: entryName,
        moduleTemplate: moduleAsyncRemover,
        entryOverride: overrides.asyncRemover,
        isWriteMethod: true,
        readOnly: readOnly,
      ),
      streamer: _resolveMethod(
        entryName: entryName,
        moduleTemplate: moduleStreamer,
        entryOverride: overrides.streamer,
        isWriteMethod: false,
        readOnly: readOnly,
      ),
    );
  }

  /// Core resolution logic for a single method type.
  String? _resolveMethod({
    required String entryName,
    required String? moduleTemplate,
    required String? entryOverride,
    required bool isWriteMethod,
    required bool readOnly,
  }) {
    // readOnly suppresses all write methods unconditionally.
    if (readOnly && isWriteMethod) return null;

    // Entry explicitly disabled this method.
    if (entryOverride == Names.prefEntryDisabledSentinel) return null;

    // Entry has a custom template override — resolve and return it.
    if (entryOverride != null) {
      return MethodNamer.resolve(entryOverride, entryName);
    }

    // Fall back to the module-level template.
    if (moduleTemplate != null) {
      return MethodNamer.resolve(moduleTemplate, entryName);
    }

    // No template at any level — method is disabled.
    return null;
  }
}
