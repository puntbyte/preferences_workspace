import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:code_builder/code_builder.dart' hide FunctionType;
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/type_analyzer.dart';
import 'package:source_gen/source_gen.dart';

/// A record holding all details related to how a preference is serialized.
typedef SerializationDetails = ({
  String? converterExpression,
  String? toStorageExpression,
  String? fromStorageExpression,
  Reference storageType,
});

/// A specialized class to determine the serialization strategy and final storage type for an entry.
class SerializationParser {
  static const _converterChecker = TypeChecker.typeNamed(PrefConverter);

  const SerializationParser();

  /// Determines the serialization strategy for a parameter.
  SerializationDetails parse({
    required DartType parameterType,
    required TypeProvider typeProvider,
    required ConstantReader annotationReader,
  }) {
    final toStorageReader = annotationReader.isNull
        ? annotationReader
        : annotationReader.read(Names.field.toStorage);
    final toStorage = toStorageReader.isNull ? null : toStorageReader.revive().accessor;
    final fromStorageReader = annotationReader.isNull
        ? annotationReader
        : annotationReader.read(Names.field.fromStorage);
    final fromStorage = fromStorageReader.isNull ? null : fromStorageReader.revive().accessor;
    final converter = _parseConverter(
      annotationReader.isNull ? annotationReader : annotationReader.read(Names.field.converter),
    );
    final customStorageType =
        converter?.storageType ?? _inferStorageTypeFromFunctions(toStorageReader);
    final storageType =
        customStorageType ?? TypeAnalyzer.getStorageType(parameterType, typeProvider);

    return (
      converterExpression: converter?.expression,
      toStorageExpression: toStorage,
      fromStorageExpression: fromStorage,
      storageType: refer(storageType.getDisplayString()),
    );
  }

  /// Checks if a `@PrefEntry` has a custom serialization method defined.
  bool hasCustomSerialization(ConstantReader reader) {
    if (reader.isNull) return false;
    return !reader.read('converter').isNull || !reader.read('toStorage').isNull;
  }

  ({String expression, DartType storageType})? _parseConverter(ConstantReader reader) {
    if (reader.isNull) return null;

    final converterType = reader.objectValue.type;
    if (converterType is! InterfaceType) return null;

    // ✨ FIX 1: Use the correct `element3` API.
    final supertype = converterType.allSupertypes.firstWhere(
      (type) => _converterChecker.isExactly(type.element),
      orElse: () => throw StateError(
        'Could not find PrefConverter supertype for ${converterType.getDisplayString()}.',
      ),
    );

    return (
      // ✨ FIX 2: Add the missing '()' to create a const instance.
      expression: 'const ${converterType.getDisplayString()}()',
      storageType: supertype.typeArguments[1],
    );
  }

  DartType? _inferStorageTypeFromFunctions(ConstantReader reader) {
    if (reader.isNull) return null;
    final type = reader.objectValue.type;
    if (type is! FunctionType) return null;
    return type.returnType;
  }
}
