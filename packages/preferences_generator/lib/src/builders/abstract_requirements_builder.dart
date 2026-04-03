import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/syntax_builder.dart';

/// Generates the abstract members that the mixin requires the concrete
/// implementation class to supply (i.e., the backing state fields).
class AbstractRequirementsBuilder {
  final Module module;

  const AbstractRequirementsBuilder(this.module);

  List<Method> build() {
    final requirements = <Method>[
      SyntaxBuilder.abstractMethod(
        name: Names.adapterFieldName,
        type: MethodType.getter,
        returns: Reference(Names.interface.adapter),
        docs: [' '],
      ),

      // The load-guard flag. Declared abstract here so the mixin body can
      // reference it in _load(), refresh(), and removeAll(); the concrete
      // implementation class provides the actual field.
      SyntaxBuilder.abstractMethod(
        name: Names.isLoadedVar,
        type: MethodType.getter,
        returns: const Reference('bool'),
      ),
      SyntaxBuilder.abstractSetter(
        name: Names.isLoadedVar,
        type: const Reference('bool'),
      ),
    ];

    for (final entry in module.entries) {
      final cachedFieldName = Names.cachedField(entry.name);
      final type = Reference(entry.type.getDisplayString());

      requirements.addAll([
        SyntaxBuilder.abstractMethod(
          name: cachedFieldName,
          type: MethodType.getter,
          returns: type,
        ),
        SyntaxBuilder.abstractSetter(name: cachedFieldName, type: type),
      ]);

      if (entry.resolvedStream != null) {
        requirements.add(
          SyntaxBuilder.abstractMethod(
            name: Names.streamControllerField(entry.name),
            type: MethodType.getter,
            returns: Reference(
              'StreamController<${entry.type.getDisplayString()}>',
            ),
          ),
        );
      }
    }

    return requirements;
  }
}
