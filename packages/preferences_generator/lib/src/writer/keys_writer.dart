import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/model/module_definition.dart';
import 'package:preferences_generator/src/writer/syntax_writer.dart';

class KeysWriter {
  final ModuleDefinition classMeta;
  const KeysWriter(this.classMeta);

  Class write() {
    final fields = classMeta.entries.map((entry) {
      return SyntaxWriter.field(
        name: entry.name,
        isStatic: true,
        modifier: FieldModifier.constant,
        assignment: Code("'${entry.storageKey}'"),
      );
    }).toList();

    return SyntaxWriter.class$(
      name: classMeta.keysName,
      fields: fields,
    );
  }
}
