import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:preferences_generator/src/extensions/dart_type_extensions.dart';

/// A static utility class that analyzes Dart types to support preference
/// generation.
class TypeAnalyzer {
  const TypeAnalyzer._();

  /// Checks if a [DartType] is one of the explicitly supported preference
  /// types.
  static bool isSupported(DartType type) {
    if (type.isRecord) {
      final record = type as RecordType;

      return record.positionalFields.every((field) => isSupported(field.type)) &&
          record.namedFields.every((field) => isSupported(field.type));
    }

    return type.isDartCoreInt ||
        type.isDartCoreString ||
        type.isDartCoreDouble ||
        type.isDartCoreBool ||
        type.isDartCoreList ||
        type.isDartCoreSet ||
        type.isDartCoreMap ||
        type.isEnum ||
        type.isDateTime ||
        type.isDuration;
  }

  /// Determines the underlying type that will be used in the storage adapter.
  static DartType getStorageType(DartType type, TypeProvider typeProvider) {
    if (type.isDateTime) return typeProvider.stringType;
    if (type.isDuration) return typeProvider.intType;
    if (type.isEnum) return typeProvider.stringType;
    if (type.isRecord) {
      return typeProvider.mapType(typeProvider.stringType, typeProvider.dynamicType);
    }

    return type;
  }

  /// Generates a code expression to serialize a value before passing it to storage.
  static String buildSerializationExpression(String value, DartType type) {
    if (type.isDuration) return '$value.inMicroseconds';
    if (type.isDateTime) return '$value.toIso8601String()';
    if (type.isEnum) return '$value.name';
    if (type.isRecord) return _recordToMapExpression(type as RecordType, value);

    return value;
  }

  /// Generates a code expression to deserialize a value after getting it from
  /// storage.
  static String buildDeserializationExpression(
    String rawValue,
    DartType type,
    TypeSystem typeSystem,
  ) {
    final nonNullableType = typeSystem.promoteToNonNull(type);
    final nonNullableTypeName = nonNullableType.getDisplayString();

    if (nonNullableType.isDateTime) return 'DateTime.parse($rawValue)';
    if (nonNullableType.isDuration) return 'Duration(microseconds: $rawValue)';
    if (nonNullableType.isEnum) return '$nonNullableTypeName.values.byName($rawValue)';
    if (nonNullableType.isRecord) {
      return _mapToRecordExpression(type as RecordType, rawValue, typeSystem);
    }

    return rawValue;
  }

  // --- Private Static Helpers ---
  static String _recordToMapExpression(RecordType type, String access) {
    final entries = <String>[];

    for (var index = 0; index < type.positionalFields.length; index++) {
      entries.add("'f$index': $access.\$${index + 1}");
    }

    for (final field in type.namedFields) {
      entries.add("'${field.name}': $access.${field.name}");
    }

    return '{${entries.join(', ')}}';
  }

  static String _mapToRecordExpression(RecordType type, String mapAccess, TypeSystem typeSystem) {
    final positionalArgs = <String>[];

    for (var i = 0; i < type.positionalFields.length; i++) {
      final field = type.positionalFields[i];
      final fieldAccess = "$mapAccess['f$i']";
      positionalArgs.add(_buildFieldDeserialization(fieldAccess, field.type, typeSystem));
    }

    final positionalPart = positionalArgs.join(', ');

    final namedArgs = <String>[];
    for (final field in type.namedFields) {
      final fieldAccess = "$mapAccess['${field.name}']";
      final deserializedField = _buildFieldDeserialization(fieldAccess, field.type, typeSystem);
      namedArgs.add('${field.name}: $deserializedField');
    }
    final namedPart = namedArgs.join(', ');

    if (namedArgs.isEmpty) return '($positionalPart,)';
    if (positionalArgs.isEmpty) return '($namedPart)';

    return '($positionalPart, $namedPart)';
  }

  /// A powerful helper that generates a type-safe deserialization expression for a given field
  /// type. It handles casting, defaults for non-nullable primitives, and recursion for nested
  /// records.
  static String _buildFieldDeserialization(String access, DartType type, TypeSystem typeSystem) {
    // Recursive step for nested records.
    if (type.isRecord) return _mapToRecordExpression(type as RecordType, access, typeSystem);

    final nonNullableTypeName = typeSystem.promoteToNonNull(type).getDisplayString();

    // If the record's field is nullable, a simple cast is sufficient and safe.
    if (type.isNullable) return '$access as $nonNullableTypeName?';

    // --- For Non-Nullable fields, we must provide a safe fallback ---
    if (type.isDartCoreInt) return '($access as int?) ?? 0';
    if (type.isDartCoreDouble) return '($access as double?) ?? 0.0';
    if (type.isDartCoreBool) return '($access as bool?) ?? false';
    if (type.isDartCoreString) return "($access as String?) ?? ''";
    if (type.isDartCoreList) return '($access as List?) ?? const []';
    if (type.isDartCoreSet) return '($access as Set?) ?? const {}';
    if (type.isDartCoreMap) return '($access as Map?) ?? const {}';
    if (type.isEnum) return '$nonNullableTypeName.values.byName($access as String)';
    if (type.isDateTime) return 'DateTime.parse($access as String)';
    if (type.isDuration) return 'Duration(microseconds: $access as int)';

    // Fallback for other complex, non-nullable types where we can't invent a
    // default. This assumes data integrity from the storage.
    return '$access as $nonNullableTypeName';
  }
}
