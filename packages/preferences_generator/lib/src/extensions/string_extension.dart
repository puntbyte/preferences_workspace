/// Provides convenient case conversion methods on [String].
extension StringExtensions on String {
  /// Converts a string from any common case format to `camelCase`.
  String toCamelCase() {
    final parts = _autoSplit();
    if (parts.isEmpty) return '';
    final first = parts.first.toLowerCase();
    final rest = parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase());
    return [first, ...rest].join();
  }

  /// Converts a string from any common case format to `kebab-case`.
  String toKebabCase() => _toCase(separator: '-');

  /// Converts a string from any common case format to `PascalCase`.
  ///
  /// Examples:
  /// - `userName` -> `UserName`
  /// - `launch_count` -> `LaunchCount`
  /// - `last-login` -> `LastLogin`
  String toPascalCase() {
    if (isEmpty) return this;
    final parts = _autoSplit();
    if (parts.isEmpty) return '';

    return parts.map((word) {
      if (word.isEmpty) return '';
      // Capitalize the first letter and make the rest lowercase.
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join();
  }

  /// Converts a string from any common case format to `snake_case`.
  String toSnakeCase() => _toCase(separator: '_');

  /// Splits a string into words based on common separators and case changes.
  ///
  /// Handles `camelCase`, `PascalCase`, `snake_case`, and `kebab-case`.
  List<String> _autoSplit() {
    if (isEmpty) return [];
    // This regex splits on:
    // 1. Transitions from a lowercase letter to an uppercase letter.
    // 2. Underscores, hyphens, and spaces.
    final processed = replaceAllMapped(
      RegExp(r'(?<=[a-z])(?=[A-Z])|[_\-\s]+'),
      (match) => ' ',
    );

    return processed.trim().split(' ');
  }

  String _toCase({required String separator}) {
    return _autoSplit().map((word) => word.toLowerCase()).join(separator);
  }
}
