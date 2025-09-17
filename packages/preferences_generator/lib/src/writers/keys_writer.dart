import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/syntax_builder.dart';

class KeysWriter {
  final Module module;

  const KeysWriter(this.module);

  Class write() {
    final fields = module.entries
        .map(
          (entry) => SyntaxBuilder.field(
            name: entry.name,
            isStatic: true,
            modifier: FieldModifier.constant,
            assignment: Code("'${entry.storageKey}'"),
          ),
        )
        .toList();

    return SyntaxBuilder.class$(name: module.keysName, fields: fields);
  }
}
