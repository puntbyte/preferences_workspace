import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/syntax_builder.dart';

/// Generates the concrete public synchronous getters that return the cached
/// in-memory value.
class PublicGettersBuilder {
  final Module module;

  const PublicGettersBuilder(this.module);

  List<Method> build() {
    return [
      for (final entry in module.entries)
        if (entry.resolvedGetter != null)
          SyntaxBuilder.method(
            name: entry.resolvedGetter!,
            type: MethodType.getter,
            returns: Reference(entry.type.getDisplayString()),
            isLambda: true,
            body: Code(Names.cachedField(entry.name)),
          ),
    ];
  }
}
