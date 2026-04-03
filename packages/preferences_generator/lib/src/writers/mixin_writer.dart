import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/builders/abstract_requirements_builder.dart';
import 'package:preferences_generator/src/builders/entry_methods_builder.dart';
import 'package:preferences_generator/src/builders/module_methods_builder.dart';
import 'package:preferences_generator/src/builders/public_getters_builder.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/names.dart';
import 'package:preferences_generator/src/utils/syntax_builder.dart';

/// Generates the `_$<ModuleName>` mixin by orchestrating all specialised
/// builder classes.
///
/// The mixin contains:
/// 1. Abstract state requirements (backing fields and stream controllers that
///    the concrete implementation class must provide).
/// 2. Concrete public synchronous getters returning cached state.
/// 3. Built-in module-level methods (`refresh`, `removeAll`, `dispose`, `_load`).
/// 4. All public methods for each individual preference entry.
class MixinWriter {
  final Module module;

  const MixinWriter(this.module);

  Mixin write() {
    final methods = <Method>[
      // 1. Abstract state requirements.
      ...AbstractRequirementsBuilder(module).build(),

      // 2. Synchronous public getters.
      ...PublicGettersBuilder(module).build(),

      // 3. Module-level methods.
      ...ModuleMethodsBuilder(module).build(),
    ];

    // 4. Per-entry methods.
    for (final entry in module.entries) {
      methods.addAll(EntryMethodsBuilder(module: module, entry: entry).build());
    }

    return SyntaxBuilder.mixin(
      name: Names.interfaceMixin(module.name),
      methods: methods,
    );
  }
}
