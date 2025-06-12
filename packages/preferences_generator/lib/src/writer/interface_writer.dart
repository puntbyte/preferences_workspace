import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/model/entry_definition.dart';
import 'package:preferences_generator/src/model/module_definition.dart';
import 'package:preferences_generator/src/utils/extensions/string_extension.dart';
import 'package:preferences_generator/src/utils/name_registry.dart';
import 'package:preferences_generator/src/writer/syntax_writer.dart';

class InterfaceWriter {
  final ModuleDefinition module;

  const InterfaceWriter(this.module);

  Mixin write() {
    final methods = <Method>[
      ..._buildLifecycleMethods(),
      ...module.entries.expand(_buildEntryMethods),
    ];

    return SyntaxWriter.mixin(
      name: module.interfaceName,
      //implements: [Reference(module.name)],
      methods: methods,
    );
  }

  List<Method> _buildLifecycleMethods() {
    return [
      SyntaxWriter.method(
        name: NameRegistry.publicReloadMethod,
        returns: const Reference('Future<void>'),
      ),

      SyntaxWriter.method(
        name: NameRegistry.publicClearMethod,
        returns: const Reference('Future<void>'),
      ),
    ];
  }

  List<Method> _buildEntryMethods(EntryDefinition entry) {
    final pascalName = entry.name.toPascalCase();
    final typeName = entry.type.getDisplayString(
      withNullability: entry.isNullable,
    );
    final nonNullableTypeName = entry.type.getDisplayString(
      withNullability: false,
    );

    return [
      // Getter (from the abstract class)
      SyntaxWriter.method(
        name: entry.name,
        type: MethodType.getter,
        returns: Reference(typeName),
      ),

      // Async Getter
      SyntaxWriter.method(
        name: NameRegistry.asyncGetter(entry.name),
        returns: Reference('Future<$typeName>'),
      ),

      // Setter
      SyntaxWriter.method(
        name: 'set$pascalName',
        returns: const Reference('Future<void>'),
        requiredParameters: [
          SyntaxWriter.parameter(
            name: NameRegistry.valueParameter,
            type: Reference(nonNullableTypeName),
          ),
        ],
      ),

      // Remover
      SyntaxWriter.method(
        name: NameRegistry.removerMethod(entry.name),
        returns: const Reference('Future<void>'),
      ),
    ];
  }
}
