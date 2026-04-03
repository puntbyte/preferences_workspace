import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/builders/load_method_body_builder.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/syntax_builder.dart';

/// Generates the built-in module-level methods:
/// `refresh`, `removeAll`, `dispose`, and the private `_load`.
class ModuleMethodsBuilder {
  final Module module;

  const ModuleMethodsBuilder(this.module);

  List<Method> build() {
    final methods = <Method>[];

    // refresh() — resets the load cache so _load() re-reads all values.
    if (module.refresh != null) {
      methods.add(
        SyntaxBuilder.method(
          name: module.refresh!,
          returns: const Reference('Future<void>'),
          modifier: MethodModifier.async,
          body: const Code(
            '${Names.isLoadedVar} = false;'
            ' await ${Names.privateLoadMethod}();',
          ),
        ),
      );
    }

    // removeAll() — clears storage, resets cache, then reloads defaults.
    if (module.removeAll != null) {
      methods.add(
        SyntaxBuilder.method(
          name: module.removeAll!,
          returns: const Reference('Future<void>'),
          modifier: MethodModifier.async,
          body: const Code(
            'await ${Names.adapterFieldName}.removeAll();'
            ' ${Names.isLoadedVar} = false;'
            ' await ${Names.privateLoadMethod}();',
          ),
        ),
      );
    }

    // dispose() — closes all stream controllers.
    if (module.hasStreams) {
      final body = module.entries
          .where((e) => e.resolvedStream != null)
          .map((e) => '${Names.streamControllerField(e.name)}.close();')
          .join('\n');
      methods.add(
        SyntaxBuilder.method(
          name: Names.disposeMethod,
          body: Code(body),
        ),
      );
    }

    // Private _load() method.
    methods.add(_buildPrivateLoadMethod());

    return methods;
  }

  Method _buildPrivateLoadMethod() {
    return SyntaxBuilder.method(
      name: Names.privateLoadMethod,
      returns: const Reference('Future<void>'),
      modifier: MethodModifier.async,
      body: LoadMethodBodyBuilder(module).build(),
    );
  }
}
