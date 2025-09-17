import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/builders/abstract_requirements_builder.dart';
import 'package:preferences_generator/src/builders/entry_methods_builder.dart';
import 'package:preferences_generator/src/builders/module_methods_builder.dart';
import 'package:preferences_generator/src/builders/public_getters_builder.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/syntax_writer.dart';

/// Generates the `_$MyModule` mixin by orchestrating specialized builders.
class MixinWriter {
  final Module module;

  const MixinWriter(this.module);

  Mixin write() {
    final methods = <Method>[
      // 1. Abstract state requirements for the concrete class to implement.
      ...AbstractRequirementsBuilder(module).build(),

      // 2. Simple public getters that return the cached state.
      ...PublicGettersBuilder(module).build(),

      // 3. Built-in module-level methods (`refresh`, `removeAll`, `_load`, etc.).
      ...ModuleMethodsBuilder(module).build(),
    ];

    // 4. All public methods for each individual preference entry.
    for (final entry in module.entries) {
      methods.addAll(EntryMethodsBuilder(module: module, entry: entry).build());
    }

    return SyntaxWriter.mixin(
      name: Names.interfaceMixin(module.name),
      methods: methods,
    );
  }
}
