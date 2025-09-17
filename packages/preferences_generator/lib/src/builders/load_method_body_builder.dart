import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/names.dart';

/// A specialized class to generate the body of the private `_load` method.
class LoadMethodBodyBuilder {
  final Module module;

  const LoadMethodBodyBuilder(this.module);

  /// Generates the full `Code` block for the method body.
  Code build() {
    final body = StringBuffer('bool ${Names.changeMarkerVar} = false;\n');

    for (final entry in module.entries) {
      final keyConst = '${module.keysName}.${entry.name}';
      final cachedVar = Names.cachedField(entry.name);
      final rawValueVar = 'rawValueFor${entry.name.toUpperCase()}';
      final newValueVar = 'newValueFor${entry.name.toUpperCase()}';
      final deserialization = entry.buildDeserializationExpression(rawValueVar);

      body
        ..writeln(
          'final $rawValueVar = await ${Names.adapterFieldName}.get<'
          '${entry.storageType.symbol}>($keyConst);',
        )
        ..writeln(
          'final $newValueVar = $rawValueVar == null ? '
          '${entry.defaultSourceExpression} : $deserialization;',
        )
        ..writeln(
          'if ($cachedVar != $newValueVar) { $cachedVar = $newValueVar; '
          '${Names.changeMarkerVar} = true; }',
        );
    }

    if (module.usesChangeNotifier && module.isNotifiable) {
      body.writeln(
        'if (${Names.changeMarkerVar}) { (this as '
        'ChangeNotifier).notifyListeners(); }',
      );
    }

    return Code(body.toString());
  }
}
