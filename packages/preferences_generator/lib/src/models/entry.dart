import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:code_builder/code_builder.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:preferences_generator/src/analysis/config_resolver.dart';
import 'package:preferences_generator/src/extensions/dart_type_extensions.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/type_analyzer.dart';

/// Represents a single, fully parsed and resolved preference entry.
///
/// This is an immutable model that holds all information needed by the writer
/// classes to generate code for one preference.
///
/// ### Resolved method names
///
/// Each `resolved*` field is a `String?` where:
/// - `null` — the method is disabled for this entry.
/// - non-null — the final, literal method name to emit (all template tokens
///   have already been substituted by [ConfigResolver]).
class Entry {
  final String name;
  final DartType type;
  final TypeSystem typeSystem;
  final String storageKey;
  final String? defaultValueCode;
  final String? initialValueAccessor;
  final bool resolvedNotifiable;

  // --- Resolved method names (null = disabled) ---
  final String? resolvedGetter;
  final String? resolvedSetter;
  final String? resolvedRemover;
  final String? resolvedAsyncGetter;
  final String? resolvedAsyncSetter;
  final String? resolvedAsyncRemover;
  final String? resolvedStream;

  // --- Custom serialization ---
  final String? converterExpression;
  final String? toStorageExpression;
  final String? fromStorageExpression;
  final Reference storageType;

  // --- Calculated convenience properties ---
  late final bool isNullable = type.isNullable;
  late final String nonNullableTypeName = typeSystem.promoteToNonNull(type).getDisplayString();

  Entry({
    required this.name,
    required this.type,
    required this.typeSystem,
    required this.storageKey,
    required this.defaultValueCode,
    required this.resolvedNotifiable,
    required this.resolvedGetter,
    required this.resolvedSetter,
    required this.resolvedRemover,
    required this.resolvedAsyncGetter,
    required this.resolvedAsyncSetter,
    required this.resolvedAsyncRemover,
    required this.resolvedStream,
    required this.converterExpression,
    required this.toStorageExpression,
    required this.fromStorageExpression,
    required this.storageType,
    this.initialValueAccessor,
  });

  /// Returns the correct source-code expression for this entry's default value,
  /// regardless of whether it is a compile-time constant or a factory-function call.
  String get defaultSourceExpression {
    if (initialValueAccessor != null) return '$initialValueAccessor()';
    return defaultValueCode ?? 'null';
  }

  /// `true` if this entry's default value is produced by a factory function
  /// rather than a compile-time constant.
  bool get hasInitialFunction => initialValueAccessor != null;

  /// `true` if this entry uses a [PrefConverter] or explicit
  /// `toStorage`/`fromStorage` functions.
  bool get needsCustomSerialization => converterExpression != null || toStorageExpression != null;

  /// Builds the source-code expression for serializing [value] before storage.
  String buildSerializationExpression(String value) {
    if (converterExpression != null) {
      return '$converterExpression.${Names.field.toStorage}($value)';
    }
    if (toStorageExpression != null) return '$toStorageExpression($value)';
    return TypeAnalyzer.buildSerializationExpression(value, type);
  }

  /// Builds the source-code expression for deserializing [rawValue] from storage.
  String buildDeserializationExpression(String rawValue) {
    if (converterExpression != null) {
      return '$converterExpression.${Names.field.fromStorage}($rawValue)';
    }
    if (fromStorageExpression != null) return '$fromStorageExpression($rawValue)';
    return TypeAnalyzer.buildDeserializationExpression(rawValue, type, typeSystem);
  }
}
