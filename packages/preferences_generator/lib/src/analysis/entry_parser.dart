import 'package:analyzer/dart/element/element.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:preferences_generator/src/analysis/config_resolver.dart';
import 'package:preferences_generator/src/analysis/default_value_parser.dart';
import 'package:preferences_generator/src/analysis/serialization_parser.dart';
import 'package:preferences_generator/src/extensions/string_extension.dart';
import 'package:preferences_generator/src/models/entry.dart';
import 'package:preferences_generator/src/utils/exception_handler.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/type_analyzer.dart';
import 'package:source_gen/source_gen.dart';

/// An orchestrator class that parses a factory constructor's parameters and converts them into a
/// list of [Entry] models by delegating to specialized parsers.
class EntryParser {
  final ConstructorElement _schemaConstructor;
  final ConfigResolver _configResolver;
  final SerializationParser _serializationParser;
  final DefaultValueParser _defaultValueParser;
  final KeyCase _finalKeyCase;

  static const _entryChecker = TypeChecker.typeNamed(PrefEntry);

  EntryParser({
    required ConstructorElement schemaConstructor,
    required ConfigResolver configResolver,
    required KeyCase finalKeyCase,
  }) : _schemaConstructor = schemaConstructor,
       _configResolver = configResolver,
       _serializationParser = const SerializationParser(),
       _defaultValueParser = const DefaultValueParser(),
       _finalKeyCase = finalKeyCase;

  /// Executes the parsing logic by mapping each named parameter to an [Entry].
  List<Entry> parse() {
    return _schemaConstructor.formalParameters
        .where((parameter) => parameter.isNamed)
        .map(_parseParameter)
        .toList();
  }

  /// The main parsing pipeline for a single parameter.
  Entry _parseParameter(FormalParameterElement parameter) {
    final library = parameter.library;
    if (library == null) throw ExceptionHandler.unexpectedMissingLibrary(parameter);

    final annotation = _entryChecker.firstAnnotationOfExact(parameter);
    final annotationReader = ConstantReader(annotation);

    if (!TypeAnalyzer.isSupported(parameter.type) &&
        !_serializationParser.hasCustomSerialization(annotationReader)) {
      throw ExceptionHandler.unsupportedType(
        parameter,
        parameter.displayName,
        parameter.type,
      );
    }

    final resolvedConfigs = _configResolver.resolve(annotationReader);
    final serialization = _serializationParser.parse(
      parameterType: parameter.type,
      typeProvider: library.typeProvider,
      annotationReader: annotationReader,
    );

    final defaultValueInfo = _defaultValueParser.parse(
      parameter: parameter,
      annotationReader: annotationReader,
    );

    final finalStorageKey = _resolveStorageKey(
      parameterName: parameter.displayName,
      annotationReader: annotationReader,
    );

    return Entry(
      name: parameter.displayName,
      type: parameter.type,
      typeSystem: library.typeSystem,
      storageKey: finalStorageKey,
      defaultValueCode: defaultValueInfo.constDefaultCode,
      initialValueAccessor: defaultValueInfo.initialValueAccessor,
      resolvedNotifiable: resolvedConfigs.notifiable,
      resolvedGetter: resolvedConfigs.getter,
      resolvedSetter: resolvedConfigs.setter,
      resolvedRemover: resolvedConfigs.remover,
      resolvedAsyncGetter: resolvedConfigs.asyncGetter,
      resolvedAsyncSetter: resolvedConfigs.asyncSetter,
      resolvedAsyncRemover: resolvedConfigs.asyncRemover,
      resolvedStream: resolvedConfigs.streamer,
      converterExpression: serialization.converterExpression,
      toStorageExpression: serialization.toStorageExpression,
      fromStorageExpression: serialization.fromStorageExpression,
      storageType: serialization.storageType,
    );
  }

  /// Determines the final storage key for an entry, respecting the precedence of an explicit key
  /// over the module's casing convention.
  String _resolveStorageKey({
    required String parameterName,
    required ConstantReader annotationReader,
  }) {
    final keyReader = annotationReader.isNull
        ? annotationReader
        : annotationReader.read(Names.field.key);
    final explicitKey = keyReader.isNull ? null : keyReader.stringValue;

    if (explicitKey != null) return explicitKey;

    return switch (_finalKeyCase) {
      KeyCase.snake => parameterName.toSnakeCase(),
      KeyCase.camel => parameterName.toCamelCase(),
      KeyCase.pascal => parameterName.toPascalCase(),
      KeyCase.kebab => parameterName.toKebabCase(),
      KeyCase.asis => parameterName,
    };
  }
}
