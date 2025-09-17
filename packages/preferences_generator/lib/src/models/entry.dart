import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/extensions/dart_type_extensions.dart';
import 'package:preferences_generator/src/models/method_config.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/type_analyzer.dart';

/// Represents a single, fully parsed and resolved preference entry.
///
/// This is an immutable model that holds all the information needed by the writer classes to
/// generate the code for one preference.
class Entry {
  final String name;
  final DartType type;
  final TypeSystem typeSystem;
  final String storageKey;
  final String? defaultValueCode;
  final String? initialValueAccessor;

  // --- Resolved Configurations ---
  final bool resolvedNotifiable;
  final ResolvedMethodConfig resolvedGetter;
  final ResolvedMethodConfig resolvedSetter;
  final ResolvedMethodConfig resolvedRemover;
  final ResolvedMethodConfig resolvedAsyncGetter;
  final ResolvedMethodConfig resolvedAsyncSetter;
  final ResolvedMethodConfig resolvedAsyncRemover;
  final ResolvedMethodConfig resolvedStream;

  // --- Custom Serialization ---
  final String? converterExpression;
  final String? toStorageExpression;
  final String? fromStorageExpression;
  final Reference storageType;

  // --- Calculated Properties for Convenience ---
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

  /// A convenience getter that returns the correct source code expression for the entry's default
  /// value, regardless of whether it's compile-time or field-based.
  String get defaultSourceExpression {
    if (initialValueAccessor != null) return '$initialValueAccessor()';

    return defaultValueCode ?? 'null';
  }

  /// A flag to check if this entry has a non-constant, field-based default.
  bool get hasInitialFunction => initialValueAccessor != null;

  /// Returns true if this entry uses a `PrefConverter` or `toStorage`/`fromStorage` functions.
  bool get needsCustomSerialization => converterExpression != null || toStorageExpression != null;

  /// Builds the source code expression for serializing a value.
  String buildSerializationExpression(String value) {
    if (converterExpression != null) return '$converterExpression.${Names.field.toStorage}($value)';
    if (toStorageExpression != null) return '$toStorageExpression($value)';

    return TypeAnalyzer.buildSerializationExpression(value, type);
  }

  /// Builds the source code expression for deserializing a value.
  String buildDeserializationExpression(String rawValue) {
    if (converterExpression != null) {
      return '$converterExpression.${Names.field.fromStorage}($rawValue)';
    }
    if (fromStorageExpression != null) return '$fromStorageExpression($rawValue)';

    return TypeAnalyzer.buildDeserializationExpression(rawValue, type, typeSystem);
  }
}
