import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/syntax_builder.dart';

/// Generates the concrete `_<ModuleName>` class that:
/// - extends the user's abstract class,
/// - mixes in the generated `_$<ModuleName>` mixin,
/// - provides all backing state fields, and
/// - wires up the adapter and runs the initial load.
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
      // The storage adapter.
      SyntaxBuilder.field(
        name: Names.adapterFieldName,
        annotations: [const Reference('override')],
        modifier: FieldModifier.final$,
        type: Reference(Names.interface.adapter),
      ),

      // The _isLoaded guard: prevents redundant storage reads.
      SyntaxBuilder.field(
        name: Names.isLoadedVar,
        type: const Reference('bool'),
        assignment: const Code('false'),
      ),
    ];

    // Backing cache field for each preference entry.
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

    // StreamController for each streaming entry.
    for (final entry in module.entries.where((e) => e.resolvedStream != null)) {
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
      requiredParameter: SyntaxBuilder.parameter(
        name: Names.adapterFieldName,
        toThis: true,
      ),
      initializer: Code('super._(${_buildSuperConstructorArgs()})'),
      body: Code(_buildInitLogic()),
    );
  }

  /// Passes compile-time default values to the super `_()` constructor.
  String _buildSuperConstructorArgs() {
    return module.entries
        .where((e) => !e.hasInitialFunction)
        .map((e) => '${e.name}: ${e.defaultValueCode ?? 'null'}')
        .join(', ');
  }

  /// Builds the constructor body that initialises backing fields and kicks
  /// off the first background load from storage.
  String _buildInitLogic() {
    final body = StringBuffer();

    // Initialise all backing cache fields with their defaults.
    for (final entry in module.entries) {
      body.writeln(
        '${Names.cachedField(entry.name)} = ${entry.defaultSourceExpression};',
      );
    }

    // Seed streams with the initial default value so subscribers
    // immediately receive a value on listen.
    if (module.hasStreams) {
      for (final entry in module.entries.where((e) => e.resolvedStream != null)) {
        final cachedVar = Names.cachedField(entry.name);
        final controller = Names.streamControllerField(entry.name);
        if (!entry.isNullable) {
          body.writeln('$controller.add($cachedVar);');
        } else {
          body.writeln('if ($cachedVar != null) $controller.add($cachedVar!);');
        }
      }
    }

    // Kick off the initial background load.
    body.writeln('${Names.privateLoadMethod}();');

    return body.toString();
  }
}
