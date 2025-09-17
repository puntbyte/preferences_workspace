import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/method_namer.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/syntax_writer.dart';

/// Generates the concrete public getters that fulfill the user's API by
/// simply returning the cached state.
class PublicGettersBuilder {
  final Module module;

  const PublicGettersBuilder(this.module);

  List<Method> build() {
    return module.entries
        .where((entry) => entry.resolvedGetter.enabled)
        .map(
          (entry) => SyntaxWriter.method(
            name: MethodNamer.getName(entry.name, entry.resolvedGetter),
            type: MethodType.getter,
            returns: Reference(entry.type.getDisplayString()),
            isLambda: true,
            body: Code(Names.cachedField(entry.name)),
          ),
        )
        .toList();
  }
}
