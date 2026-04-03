import 'package:analyzer/dart/element/element.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:preferences_generator/src/analysis/config_resolver.dart';
import 'package:preferences_generator/src/analysis/default_value_parser.dart';
import 'package:preferences_generator/src/analysis/serialization_parser.dart';
import 'package:preferences_generator/src/extensions/string_extension.dart';
import 'package:preferences_generator/src/models/entry.dart';
import 'package:preferences_generator/src/utils/exception_handler.dart';
import 'package:preferences_generator/src/utils/method_namer.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/type_analyzer.dart';
import 'package:source_gen/source_gen.dart';

/// Parses the private schema constructor's parameters into a list of [Entry]
/// models by delegating to specialised sub-parsers.
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

  List<Entry> parse() {
    return _schemaConstructor.formalParameters
        .where((p) => p.isNamed)
        .map(_parseParameter)
        .toList();
  }

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

    // Parse the @PrefEntry overrides.
    final overrides = _readEntryOverrides(annotationReader, parameter);

    // Validate any per-entry template strings before resolving.
    _validateEntryTemplates(parameter, overrides);

    // Resolve final method names.
    final resolved = _configResolver.resolve(parameter.displayName, overrides);

    // Parse serialization and defaults.
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
      resolvedNotifiable: resolved.notifiable,
      resolvedGetter: resolved.getter,
      resolvedSetter: resolved.setter,
      resolvedRemover: resolved.remover,
      resolvedAsyncGetter: resolved.asyncGetter,
      resolvedAsyncSetter: resolved.asyncSetter,
      resolvedAsyncRemover: resolved.asyncRemover,
      resolvedStream: resolved.streamer,
      converterExpression: serialization.converterExpression,
      toStorageExpression: serialization.toStorageExpression,
      fromStorageExpression: serialization.fromStorageExpression,
      storageType: serialization.storageType,
    );
  }

  /// Reads a [EntryOverrides] record from the raw `@PrefEntry` annotation.
  EntryOverrides _readEntryOverrides(
    ConstantReader reader,
    FormalParameterElement parameter,
  ) {
    if (reader.isNull) {
      return (
        getter: null,
        setter: null,
        remover: null,
        asyncGetter: null,
        asyncSetter: null,
        asyncRemover: null,
        streamer: null,
        notifiable: null,
        readOnly: false,
      );
    }

    final readOnly = reader.read(Names.field.readOnly).boolValue;

    return (
      getter: _readNullableString(reader, Names.field.getter),
      setter: _readNullableString(reader, Names.field.setter),
      remover: _readNullableString(reader, Names.field.remover),
      asyncGetter: _readNullableString(reader, Names.field.asyncGetter),
      asyncSetter: _readNullableString(reader, Names.field.asyncSetter),
      asyncRemover: _readNullableString(reader, Names.field.asyncRemover),
      streamer: _readNullableString(reader, Names.field.streamer),
      notifiable: _readNullableBool(reader, Names.field.notifiable),
      readOnly: readOnly,
    );
  }

  /// Validates that any per-entry template overrides contain at least one
  /// `{{name}}` or `{{Name}}` token, preventing accidental bare literal names
  /// that would produce duplicate method names across entries.
  void _validateEntryTemplates(
    FormalParameterElement parameter,
    EntryOverrides overrides,
  ) {
    void check(String? template, String methodType) {
      if (template == null) return;
      if (template == Names.prefEntryDisabledSentinel) return;
      if (!MethodNamer.hasToken(template)) {
        throw ExceptionHandler.invalidEntryTemplate(
          parameter,
          template,
          methodType,
        );
      }
    }

    check(overrides.getter, 'getter');
    check(overrides.setter, 'setter');
    check(overrides.remover, 'remover');
    check(overrides.asyncGetter, 'asyncGetter');
    check(overrides.asyncSetter, 'asyncSetter');
    check(overrides.asyncRemover, 'asyncRemover');
    check(overrides.streamer, 'streamer');
  }

  /// Determines the final storage key for an entry.
  String _resolveStorageKey({
    required String parameterName,
    required ConstantReader annotationReader,
  }) {
    if (!annotationReader.isNull) {
      final keyReader = annotationReader.read(Names.field.key);
      if (!keyReader.isNull) return keyReader.stringValue;
    }

    return switch (_finalKeyCase) {
      KeyCase.snake => parameterName.toSnakeCase(),
      KeyCase.camel => parameterName.toCamelCase(),
      KeyCase.pascal => parameterName.toPascalCase(),
      KeyCase.kebab => parameterName.toKebabCase(),
      KeyCase.asis => parameterName,
    };
  }

  String? _readNullableString(ConstantReader reader, String fieldName) {
    final fieldReader = reader.read(fieldName);
    return fieldReader.isNull ? null : fieldReader.stringValue;
  }

  bool? _readNullableBool(ConstantReader reader, String fieldName) {
    final fieldReader = reader.read(fieldName);
    return fieldReader.isNull ? null : fieldReader.boolValue;
  }
}
