import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/syntax_builder.dart';

/// Generates the `_MyModule` concrete class which extends the user's class, provides the state
/// (backing fields), and connects to the storage adapter.
class ImplementationWriter {
  final Module module;

  const ImplementationWriter(this.module);

  Class write() => SyntaxBuilder.class$(
    name: Names.implementationClass(module.name),
    extend: Reference(module.name),
    mixins: [Reference(Names.interfaceMixin(module.name))],
    fields: _buildFields(),
    constructors: [_buildConstructor()],
  );

  List<Field> _buildFields() {
    final fields = <Field>[
      SyntaxBuilder.field(
        name: Names.adapterFieldName,
        annotations: [const Reference('override')],
        modifier: FieldModifier.final$,
        type: Reference(Names.interface.adapter),
      ),
    ];

    for (final entry in module.entries) {
      fields.add(
        SyntaxBuilder.field(
          name: Names.cachedField(entry.name),
          annotations: [const Reference('override')],
          type: Reference(entry.type.getDisplayString()),
          isLate: !entry.isNullable,
        ),
      );
    }

    for (final entry in module.entries.where((e) => e.resolvedStream.enabled)) {
      final streamType = entry.type.getDisplayString();
      fields.add(
        SyntaxBuilder.field(
          name: Names.streamControllerField(entry.name),
          annotations: [const Reference('override')],
          modifier: FieldModifier.final$,
          type: Reference('StreamController<$streamType>'),
          assignment: Code('StreamController<$streamType>.broadcast()'),
        ),
      );
    }

    return fields;
  }

  Constructor _buildConstructor() {
    return SyntaxBuilder.constructor(
      requiredParameter: SyntaxBuilder.parameter(name: Names.adapterFieldName, toThis: true),
      initializer: Code('super._(${_buildSuperConstructorArgs()})'),
      body: Code(_buildInitLogic()),
    );
  }

  /// Helper to build the named arguments for the `super._()` call.
  /// It correctly passes the compile-time default values.
  String _buildSuperConstructorArgs() {
    return module.entries
        .where((entry) => !entry.hasInitialFunction)
        .map((entry) => '${entry.name}: ${entry.defaultValueCode ?? 'null'}')
        .join(', ');
  }

  /// Helper to build the body of the constructor for initialization.
  String _buildInitLogic() {
    final body = StringBuffer();

    // 1. Initialize all the backing fields with their correct default values.
    for (final entry in module.entries) {
      body.writeln('${Names.cachedField(entry.name)} = ${entry.defaultSourceExpression};');
    }

    // 2. Initialize streams with their default values.
    if (module.hasStreams) {
      for (final entry in module.entries.where((e) => e.resolvedStream.enabled)) {
        final cachedVar = Names.cachedField(entry.name);
        final controller = Names.streamControllerField(entry.name);
        if (!entry.isNullable) {
          body.writeln('$controller.add($cachedVar);');
        } else {
          body.writeln('if ($cachedVar != null) $controller.add($cachedVar!);');
        }
      }
    }

    // 3. Kick off the initial load from storage.
    body.writeln('${Names.privateLoadMethod}();');
    return body.toString();
  }
}
