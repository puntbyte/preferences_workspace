import 'package:preferences_generator/src/extensions/string_extension.dart';
import 'package:preferences_generator/src/models/method_config.dart';

/// A pure utility class for resolving the final name of a generated method
/// based on its base name and final, resolved configuration.
class MethodNamer {
  const MethodNamer._();

  /// Calculates the final method name based on the resolved configuration.
  ///
  /// The logic correctly combines prefixes and suffixes.
  static String getName(String baseName, ResolvedMethodConfig config) {
    // A direct name override always has the highest priority.
    if (config.name != null) return config.name!;

    String result;

    // Start with the base name, applying a prefix if it exists.
    if (config.prefix != null) {
      result = '${config.prefix}${baseName.toPascalCase()}';
    } else {
      // If no prefix, the starting point is the camelCase base name.
      result = baseName;
    }

    // Append the suffix if it exists.
    if (config.suffix != null) result = '$result${config.suffix}';

    return result;
  }
}
