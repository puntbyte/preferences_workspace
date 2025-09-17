import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/syntax_writer.dart';

class KeysWriter {
  final Module module;

  const KeysWriter(this.module);

  Class write() {
    final fields = module.entries
        .map(
          (entry) => SyntaxWriter.field(
            name: entry.name,
            isStatic: true,
            modifier: FieldModifier.constant,
            assignment: Code("'${entry.storageKey}'"),
          ),
        )
        .toList();

    return SyntaxWriter.class$(name: module.keysName, fields: fields);
  }
}
