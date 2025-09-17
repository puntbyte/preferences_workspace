import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/syntax_writer.dart';

/// Generates the abstract members that the mixin requires the concrete class
/// to implement (i.e., the state).
class AbstractRequirementsBuilder {
  final Module module;

  const AbstractRequirementsBuilder(this.module);

  List<Method> build() {
    final requirements = <Method>[
      SyntaxWriter.abstractMethod(
        name: Names.adapterFieldName,
        type: MethodType.getter,
        returns: Reference(Names.interface.adapter),
        docs: [' '],
      ),
    ];

    for (final entry in module.entries) {
      final cachedFieldName = Names.cachedField(entry.name);
      final type = Reference(entry.type.getDisplayString());

      requirements.addAll([
        SyntaxWriter.abstractMethod(name: cachedFieldName, type: MethodType.getter, returns: type),
        SyntaxWriter.abstractSetter(name: cachedFieldName, type: type),
      ]);

      if (entry.resolvedStream.enabled) {
        requirements.add(
          SyntaxWriter.abstractMethod(
            name: Names.streamControllerField(entry.name),
            type: MethodType.getter,
            returns: Reference('StreamController<${entry.type.getDisplayString()}>'),
          ),
        );
      }
    }

    return requirements;
  }
}
