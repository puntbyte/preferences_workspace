import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/builders/value_change_logic_builder.dart';
import 'package:preferences_generator/src/models/entry.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/method_namer.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/syntax_writer.dart';

/// Generates all public methods for a single preference entry (e.g., getters,
/// setters, removers, streamers).
class EntryMethodsBuilder {
  final Module module;
  final Entry entry;

  const EntryMethodsBuilder({required this.module, required this.entry});

  List<Method> build() => [
    ?_buildAsyncGetter(),
    ?_buildSetter(),
    ?_buildAsyncSetter(),
    ?_buildRemover(),
    ?_buildAsyncRemover(),
    ?_buildStreamer(),
  ];

  Method? _buildAsyncGetter() {
    if (!entry.resolvedAsyncGetter.enabled) return null;
    final name = MethodNamer.getName(entry.name, entry.resolvedAsyncGetter);

    return SyntaxWriter.method(
      name: name,
      returns: Reference('Future<${entry.type.getDisplayString()}>'),
      modifier: MethodModifier.async,
      body: Code('await _load(); return ${Names.cachedField(entry.name)};'),
    );
  }

  Method? _buildSetter() {
    if (!entry.resolvedSetter.enabled) return null;
    final name = MethodNamer.getName(entry.name, entry.resolvedSetter);
    final body = ValueChangeLogicBuilder(module: module, entry: entry).build(
      newValueExpression: Names.valueParameter,
      isRemove: false,
      isAsync: false,
    );

    return SyntaxWriter.method(
      name: name,
      returns: const Reference('void'),
      requiredParameter: SyntaxWriter.parameter(
        name: Names.valueParameter,
        type: Reference(entry.nonNullableTypeName),
      ),
      body: body,
    );
  }

  Method? _buildAsyncSetter() {
    if (!entry.resolvedAsyncSetter.enabled) return null;
    final name = MethodNamer.getName(entry.name, entry.resolvedAsyncSetter);
    final body = ValueChangeLogicBuilder(module: module, entry: entry).build(
      newValueExpression: Names.valueParameter,
      isRemove: false,
      isAsync: true,
    );
    return SyntaxWriter.method(
      name: name,
      returns: const Reference('Future<void>'),
      modifier: MethodModifier.async,
      requiredParameter: SyntaxWriter.parameter(
        name: Names.valueParameter,
        type: Reference(entry.nonNullableTypeName),
      ),
      body: body,
    );
  }

  Method? _buildRemover() {
    if (!entry.resolvedRemover.enabled) return null;
    final name = MethodNamer.getName(entry.name, entry.resolvedRemover);
    final body = ValueChangeLogicBuilder(module: module, entry: entry).build(
      newValueExpression: entry.defaultSourceExpression,
      isRemove: true,
      isAsync: false,
    );

    return SyntaxWriter.method(
      name: name,
      returns: const Reference('void'),
      body: body,
    );
  }

  Method? _buildAsyncRemover() {
    if (!entry.resolvedAsyncRemover.enabled) return null;
    final name = MethodNamer.getName(entry.name, entry.resolvedAsyncRemover);
    final body = ValueChangeLogicBuilder(module: module, entry: entry).build(
      newValueExpression: entry.defaultSourceExpression,
      isRemove: true,
      isAsync: true,
    );

    return SyntaxWriter.method(
      name: name,
      returns: const Reference('Future<void>'),
      modifier: MethodModifier.async,
      body: body,
    );
  }

  Method? _buildStreamer() {
    if (!entry.resolvedStream.enabled) return null;
    final name = MethodNamer.getName(entry.name, entry.resolvedStream);
    final streamType = entry.type.getDisplayString();

    return SyntaxWriter.method(
      name: name,
      type: MethodType.getter,
      returns: Reference('Stream<$streamType>'),
      body: Code('${Names.streamControllerField(entry.name)}.stream'),
      isLambda: true,
    );
  }
}
