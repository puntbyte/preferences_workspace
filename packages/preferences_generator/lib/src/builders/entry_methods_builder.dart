import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/builders/value_change_logic_builder.dart';
import 'package:preferences_generator/src/models/entry.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/syntax_builder.dart';

/// Generates all public methods for a single preference entry:
/// async getter, sync/async setters, sync/async removers, and the stream getter.
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
    final name = entry.resolvedAsyncGetter;
    if (name == null) return null;

    return SyntaxBuilder.method(
      name: name,
      returns: Reference('Future<${entry.type.getDisplayString()}>'),
      modifier: MethodModifier.async,
      // Calls _load() which is guarded by _isLoaded, so only reads storage once.
      body: Code(
        'await ${Names.privateLoadMethod}();'
        ' return ${Names.cachedField(entry.name)};',
      ),
    );
  }

  Method? _buildSetter() {
    final name = entry.resolvedSetter;
    if (name == null) return null;

    final body = ValueChangeLogicBuilder(module: module, entry: entry).build(
      newValueExpression: Names.valueParameter,
      isRemove: false,
      isAsync: false,
    );

    return SyntaxBuilder.method(
      name: name,
      returns: const Reference('void'),
      requiredParameter: SyntaxBuilder.parameter(
        name: Names.valueParameter,
        type: Reference(entry.nonNullableTypeName),
      ),
      body: body,
    );
  }

  Method? _buildAsyncSetter() {
    final name = entry.resolvedAsyncSetter;
    if (name == null) return null;

    final body = ValueChangeLogicBuilder(module: module, entry: entry).build(
      newValueExpression: Names.valueParameter,
      isRemove: false,
      isAsync: true,
    );

    return SyntaxBuilder.method(
      name: name,
      returns: const Reference('Future<void>'),
      modifier: MethodModifier.async,
      requiredParameter: SyntaxBuilder.parameter(
        name: Names.valueParameter,
        type: Reference(entry.nonNullableTypeName),
      ),
      body: body,
    );
  }

  Method? _buildRemover() {
    final name = entry.resolvedRemover;
    if (name == null) return null;

    final body = ValueChangeLogicBuilder(module: module, entry: entry).build(
      newValueExpression: entry.defaultSourceExpression,
      isRemove: true,
      isAsync: false,
    );

    return SyntaxBuilder.method(
      name: name,
      returns: const Reference('void'),
      body: body,
    );
  }

  Method? _buildAsyncRemover() {
    final name = entry.resolvedAsyncRemover;
    if (name == null) return null;

    final body = ValueChangeLogicBuilder(module: module, entry: entry).build(
      newValueExpression: entry.defaultSourceExpression,
      isRemove: true,
      isAsync: true,
    );

    return SyntaxBuilder.method(
      name: name,
      returns: const Reference('Future<void>'),
      modifier: MethodModifier.async,
      body: body,
    );
  }

  Method? _buildStreamer() {
    final name = entry.resolvedStream;
    if (name == null) return null;

    return SyntaxBuilder.method(
      name: name,
      type: MethodType.getter,
      returns: Reference('Stream<${entry.type.getDisplayString()}>'),
      body: Code('${Names.streamControllerField(entry.name)}.stream'),
      isLambda: true,
    );
  }
}
