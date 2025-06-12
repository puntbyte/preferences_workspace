extension StringExtensions on String {
  /// Trims the characters given by [text] from before and after [String].
  String trimString(String text) {
    final pattern = text.isNotEmpty
        ? RegExp("^[$text]+|[$text]+\$")
        : RegExp(r"^\s+|\s+$");
    return replaceAll(pattern, '');
  }

  /// Automatically splits the string into parts based on case transitions and common separators.
  List<String> autoSplitCase() {
    // Use a regular expression to split the string at word boundaries
    final processedString = replaceAllMapped(
      RegExp(r'(?<=[a-z])(?=[A-Z])|[_\-\s]+'),
      (_) {
        return ' ';
      },
    );
    return processedString.trim().split(' ');
  }

  /// Converts a string to camelCase.
  String toCamelCase() {
    if (isEmpty) return this;
    final parts = autoSplitCase();
    if (parts.isEmpty) return '';

    final firstWord = parts.first.toLowerCase();
    final otherWords = parts
        .skip(1)
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join('');

    return firstWord + otherWords;
  }

  /// Converts a string to PascalCase.
  String toPascalCase() {
    if (isEmpty) return this;
    final parts = autoSplitCase();
    return parts
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join('');
  }
}
