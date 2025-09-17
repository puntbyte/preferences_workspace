/// Defines the casing convention for generated storage keys.
enum KeyCase {
  /// No transformation is applied. The key will match the Dart field name.
  ///
  /// Example: `launchCount` -> `'launchCount'`
  asis,

  /// Keys are converted to `snake_case`.
  ///
  /// Example: `launchCount` -> `'launch_count'`
  snake,

  /// Keys are converted to `camelCase`.
  ///
  /// This is often the same as `asis` but ensures the first letter is lowercase.
  /// Example: `LaunchCount` -> `'launchCount'`
  camel,

  /// Keys are converted to `PascalCase`.
  ///
  /// Example: `launchCount` -> `'LaunchCount'`
  pascal,

  /// Keys are converted to `kebab-case`.
  ///
  /// Example: `launchCount` -> `'launch-count'`
  kebab,
}
