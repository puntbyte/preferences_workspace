import 'package:analyzer/dart/element/type.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:preferences_generator/src/utils/extensions/dart_type_extensions.dart';

/// A static utility class that analyzes Dart types to support preference generation.
class TypeAnalyzer {
  const TypeAnalyzer._();

  /// Checks if a [DartType] is one of the explicitly supported preference types.
  static bool isSupported(DartType type) {
    if (type.isRecord) {
      // Recursively check that all fields within the record are also supported.
      return (type as RecordType).positionalFields.every((field) {
        return isSupported(field.type);
      }) && (type).namedFields.every((field) => isSupported(field.type));
    }

    return type.isDartCoreInt ||
        type.isDartCoreString ||
        type.isDartCoreDouble ||
        type.isDartCoreBool ||
        type.isDartCoreList ||
        type.isDartCoreMap ||
        type.isEnum ||
        type.isDateTime ||
        type.isColor;
  }

  /// Gets the type that the generator will ask the [PreferenceAdapter] to handle.
  static String getStorageType(DartType type) {
    if (type.isEnum) return 'String?';
    if (type.isRecord) return 'Map<String, dynamic>?';
    return type.getDisplayString(withNullability: true);
  }

  /// Generates a code expression to serialize a value before passing it to storage.
  static String buildSerializationExpression(String value, DartType type) {
    if (type.isEnum) return '$value${type.isNullable ? '?' : ''}.name';
    if (type.isRecord) return _recordToMapExpression(type as RecordType, value);
    return value;
  }

  /// Generates a code expression to deserialize a value after getting it from storage.
  static String buildDeserializationExpression(String rawValue, DartType type) {
    final typeName = type.getDisplayString(withNullability: false);
    if (type.isEnum) {
      return '$typeName.values.asNameMap()[$rawValue]';
    }

    if (type.isRecord) {
      return '$rawValue == null ? null : ${_mapToRecordExpression(type as RecordType, rawValue)}';
    }

    return rawValue;
  }

  // --- Private Static Helpers ---

  static String _recordToMapExpression(RecordType type, String access) {
    final entries = <String>[];

    // Handle positional fields
    int positionalIndex = 1;
    for (final field in type.positionalFields) {
      // Use keys like 'f1', 'f2', etc. for positional fields.
      entries.add("'f$positionalIndex': $access.\$$positionalIndex");
      positionalIndex++;
    }

    // Handle named fields
    for (final field in type.namedFields) {
      // Use the field's name as the key.
      entries.add("'${field.name}': $access.${field.name}");
    }

    return '{${entries.join(', ')}}';
  }

  /// Generates the code expression to deserialize a Map back into a Record.
  static String _mapToRecordExpression(RecordType type, String access) {
    // Positional arguments
    final positionalArgs = <String>[];
    int positionalIndex = 1;
    for (final field in type.positionalFields) {
      final fieldKey = 'f$positionalIndex';
      // Use the new safe cast helper
      positionalArgs.add(_getSafeCastExpression("$access['$fieldKey']", field.type));
      positionalIndex++;
    }
    final positionalPart = positionalArgs.join(', ');

    // Named arguments
    final namedArgs = <String>[];
    for (final field in type.namedFields) {
      final fieldKey = field.name;
      // Use the new safe cast helper
      namedArgs.add("${field.name}: ${_getSafeCastExpression("$access['$fieldKey']", field.type)}");
    }
    final namedPart = namedArgs.join(', ');

    // Combine them correctly
    if (namedArgs.isEmpty) {
      return '($positionalPart,)';
    } else {
      if (positionalArgs.isEmpty) {
        return '($namedPart)';
      } else {
        return '($positionalPart, {$namedPart})';
      }
    }
  }

  // --- THIS IS THE NEW, ROBUST HELPER FUNCTION ---
  /// Generates a safe casting expression for a value from a map.
  ///
  /// For a nullable field like `int?`, it generates `map['key'] as int?`.
  /// For a non-nullable field like `int`, it generates `(map['key'] as int?) ?? 0`,
  /// providing a safe fallback to prevent runtime errors.
  static String _getSafeCastExpression(String mapAccess, DartType fieldType) {
    final typeName = fieldType.getDisplayString(withNullability: false);

    // If the record's field is itself nullable, a simple nullable cast is safe.
    if (fieldType.isNullable) {
      return "$mapAccess as $typeName?";
    }

    // If the record's field is NOT nullable, we must provide a default.
    if (fieldType.isDartCoreInt) {
      return "($mapAccess as int?) ?? 0";
    }
    if (fieldType.isDartCoreDouble) {
      return "($mapAccess as double?) ?? 0.0";
    }
    if (fieldType.isDartCoreBool) {
      return "($mapAccess as bool?) ?? false";
    }
    if (fieldType.isDartCoreString) {
      return "($mapAccess as String?) ?? ''";
    }
    if (fieldType.isDartCoreList) {
      return "($mapAccess as List?) ?? const []";
    }
    if (fieldType.isDartCoreMap) {
      return "($mapAccess as Map?) ?? const {}";
    }

    // For other complex non-nullable types like Enums or nested Records,
    // a hard cast is the only option, as we can't invent a default.
    // This assumes the data is well-formed.
    return "$mapAccess as $typeName";
  }
}
