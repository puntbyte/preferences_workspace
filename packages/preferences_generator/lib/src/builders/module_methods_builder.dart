import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/builders/load_method_body_builder.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/method_namer.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/syntax_builder.dart';

/// Generates the built-in, module-level methods like `refresh`, `removeAll`,
/// `dispose`, and the private `_load` method.
class ModuleMethodsBuilder {
  final Module module;

  const ModuleMethodsBuilder(this.module);

  List<Method> build() {
    final methods = <Method>[];

    // Public module methods
    if (module.refresh.enabled) {
      final name = MethodNamer.getName(module.refresh.name!, module.refresh);
      methods.add(
        SyntaxBuilder.method(
          name: name,
          returns: const Reference('Future<void>'),
          modifier: MethodModifier.async,
          body: const Code('await _load();'),
        ),
      );
    }

    if (module.removeAll.enabled) {
      final name = MethodNamer.getName(module.removeAll.name!, module.removeAll);
      methods.add(
        SyntaxBuilder.method(
          name: name,
          returns: const Reference('Future<void>'),
          modifier: MethodModifier.async,
          body: const Code('await ${Names.adapterFieldName}.removeAll(); await _load();'),
        ),
      );
    }

    if (module.hasStreams) {
      final body = module.entries
          .where((entry) => entry.resolvedStream.enabled)
          .map((entry) => '${Names.streamControllerField(entry.name)}.close();')
          .join('\n');
      methods.add(SyntaxBuilder.method(name: Names.disposeMethod, body: Code(body)));
    }

    // Private module methods
    methods.add(_buildPrivateLoadMethod());

    return methods;
  }

  Method _buildPrivateLoadMethod() {
    final body = LoadMethodBodyBuilder(module).build();
    return SyntaxBuilder.method(
      name: Names.privateLoadMethod,
      returns: const Reference('Future<void>'),
      modifier: MethodModifier.async,
      body: body,
    );
  }
}
