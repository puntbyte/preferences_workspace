/// A pure utility class for resolving a method name from a template string and
/// an entry's base name.
///
/// Templates may contain two substitution tokens:
///
/// | Token      | Meaning                                       | `isFirstLaunch` → |
/// |------------|-----------------------------------------------|-------------------|
/// | `{{name}}` | The raw camelCase field name                  | `isFirstLaunch`   |
/// | `{{Name}}` | Field name with the first letter capitalised  | `IsFirstLaunch`   |
///
/// ### Examples
///
/// ```dart
/// MethodNamer.resolve('set{{Name}}', 'isFirstLaunch'); // → 'setIsFirstLaunch'
/// MethodNamer.resolve('{{name}}Stream', 'theme');       // → 'themeStream'
/// MethodNamer.resolve('watch{{Name}}Changes', 'theme'); // → 'watchThemeChanges'
/// ```
class MethodNamer {
  const MethodNamer._();

  /// Returns `true` if [template] contains at least one valid substitution
  /// token (`{{name}}` or `{{Name}}`).
  ///
  /// Used during validation to ensure per-entry template overrides are not
  /// accidentally written as bare literal method names (which would cause every
  /// entry in the module to share the same name and trigger a duplicate-name
  /// error at generation time).
  static bool hasToken(String template) =>
      template.contains('{{name}}') || template.contains('{{Name}}');

  /// Resolves [template] by substituting `{{name}}` and `{{Name}}` tokens with
  /// the appropriate form of [entryName].
  ///
  /// [entryName] is assumed to already be in camelCase (as it comes directly
  /// from the Dart field name in the schema constructor).
  static String resolve(String template, String entryName) {
    final capitalisedName = entryName.isEmpty
        ? entryName
        : entryName[0].toUpperCase() + entryName.substring(1);

    return template.replaceAll('{{name}}', entryName).replaceAll('{{Name}}', capitalisedName);
  }
}
