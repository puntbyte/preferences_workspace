import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:preferences_generator/src/extensions/dart_type_extensions.dart';
import 'package:preferences_generator/src/utils/exception_handler.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:source_gen/source_gen.dart';

/// A record to hold the results of the default value analysis.
typedef DefaultValueInfo = ({String? constDefaultCode, String? initialValueAccessor});

/// A specialized class to parse and validate the default value for a preference entry.
class DefaultValueParser {
  const DefaultValueParser();

  /// Analyzes a parameter to determine its default value source, performing all
  /// necessary validation for compile-time and field-based defaults.
  DefaultValueInfo parse({
    required FormalParameterElement parameter,
    required ConstantReader annotationReader,
  }) {
    final hasConstDefault = parameter.hasDefaultValue;
    var constDefaultCode = hasConstDefault ? parameter.defaultValueCode : null;

    if (constDefaultCode != null) {
      constDefaultCode = _fixUntypedCollection(constDefaultCode, parameter.type);
    }

    final initialReader = annotationReader.isNull
        ? annotationReader
        : annotationReader.read(Names.field.initial);
    final hasInitialFunc = !initialReader.isNull;
    final initialValueAccessor = hasInitialFunc ? initialReader.revive().accessor : null;

    if (hasConstDefault && hasInitialFunc) {
      throw ExceptionHandler.ambiguousDefault(parameter);
    }
    if (!parameter.type.isNullable && !hasConstDefault && !hasInitialFunc) {
      throw ExceptionHandler.missingDefaultValue(parameter, parameter.displayName);
    }

    return (
      constDefaultCode: constDefaultCode,
      initialValueAccessor: initialValueAccessor,
    );
  }

  /// If the default value is an untyped literal (`const []` or `const {}`),
  /// this method rewrites it to include the parameter's type arguments.
  String _fixUntypedCollection(String defaultValueCode, DartType type) {
    if (type is! InterfaceType) return defaultValueCode;

    final typeArgs = type.typeArguments;

    // Fix for Lists: const [] -> const <String>[]
    if (type.isDartCoreList && defaultValueCode == 'const []' && typeArgs.isNotEmpty) {
      return 'const <${typeArgs.first.getDisplayString()}>[]';
    }

    // Fix for Sets: const {} -> const <int>{}
    if (type.isDartCoreSet && defaultValueCode == 'const {}' && typeArgs.isNotEmpty) {
      return 'const <${typeArgs.first.getDisplayString()}>{}';
    }

    // Fix for Maps: const {} -> const <String, String>{}
    if (type.isDartCoreMap && defaultValueCode == 'const {}' && typeArgs.length == 2) {
      return 'const <${typeArgs[0].getDisplayString()}, ${typeArgs[1].getDisplayString()}>{}';
    }

    return defaultValueCode;
  }
}
