import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/syntax_builder.dart';

/// Generates the private `_<ModuleName>Keys` class that holds all storage
/// key constants.
///
/// Using a generated keys class (rather than raw string literals scattered
/// throughout the mixin) is what makes this package's "no typos" guarantee
/// work. Every adapter call — in both `_load()` and all mutating methods —
/// references one of these constants.
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
