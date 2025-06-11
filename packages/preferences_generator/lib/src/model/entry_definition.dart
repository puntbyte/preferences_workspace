import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:preferences_generator/src/utils/extensions/dart_type_extensions.dart';
import 'package:source_gen/source_gen.dart';

import '../utils/exception_handler.dart';
import '../utils/type_analyzer.dart';

class EntryDefinition {
  final String name;
  final DartType type;
  final String storageKey;
  final String? defaultValueCode;
  final bool isNullable;

  const EntryDefinition({
    required this.name,
    required this.type,
    required this.storageKey,
    required this.defaultValueCode,
    required this.isNullable,
  });

  factory EntryDefinition.fromElement(ParameterElement element) {
    // --- TYPE VALIDATION ---
    if (!TypeAnalyzer.isSupported(element.type)) throw ExceptionHandler.unsupportedType(element);

    const checker = TypeChecker.fromRuntime(PreferenceEntry);
    final annotation = checker.firstAnnotationOfExact(element);

    if (annotation == null) throw ExceptionHandler.missingEntryAnnotation(element);

    final reader = ConstantReader(annotation);
    final name = element.name;
    final storageKey = reader.read('key').literalValue as String? ?? name;

    String? defaultValueCode;
    final defaultFromAnnotation = reader.read('defaultValue');

    if (!defaultFromAnnotation.isNull) {
      defaultValueCode = _buildLiteralCode(defaultFromAnnotation);
    }

    if (!element.type.isNullable && defaultValueCode == null) {
      throw ExceptionHandler.missingDefaultValue(element);
    }

    return EntryDefinition(
      name: name,
      type: element.type,
      storageKey: storageKey,
      defaultValueCode: defaultValueCode,
      isNullable: element.type.isNullable,
    );
  }

  /// Recursively builds a valid source code representation of a literal constant.
  /// It takes a [ConstantReader] wrapping the object.
  static String _buildLiteralCode(ConstantReader reader) {
    // --- THIS IS THE FIX ---
    // We check `isLiteral` on the ConstantReader first.
    if (reader.isLiteral) {
      // If it's a literal, we work with its raw value.
      final value = reader.literalValue;

      // Use a standard switch on the runtime type of the literal value.
      switch (value) {
        case null:
          return 'null';
        case String():
        // Correctly escape quotes and wrap in single quotes.
          return "'${value.replaceAll("'", "\\'")}'";
        case int():
        case double():
        case bool():
          return value.toString();
        case List():
        // Recursively build the code for each item in the list.
          final listItems = value.map((item) {
            // Wrap each item in a new ConstantReader to continue recursively.
            final itemObject = ConstantReader(item);
            return _buildLiteralCode(itemObject);
          }).join(', ');
          return 'const [$listItems]';
        case Map():
          final mapItems = value.entries.map((entry) {
            // Recursively build for key and value.
            final keyReader = ConstantReader(entry.key);
            final valueReader = ConstantReader(entry.value);
            final key = _buildLiteralCode(keyReader);
            final value = _buildLiteralCode(valueReader);
            return '$key: $value';
          }).join(', ');
          return 'const {$mapItems}';
        case Set():
          final setItems = value.map((item) {
            final itemReader = ConstantReader(item);
            return _buildLiteralCode(itemReader);
          }).join(', ');
          return 'const {$setItems}';
      }
    }

    // If it's NOT a literal (e.g., an enum, a const object), then `revive()`
    // is the correct tool to use.
    return reader.revive().accessor;
  }
}
