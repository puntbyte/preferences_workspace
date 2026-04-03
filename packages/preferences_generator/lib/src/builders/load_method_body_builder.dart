import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/names.dart';

/// Generates the body of the private `_load()` method.
///
/// The generated method:
/// 1. Returns immediately if the in-memory cache is already populated
///    (`_isLoaded` guard), preventing redundant storage reads when multiple
///    async getters are called in sequence.
/// 2. Reads every preference from the adapter in one pass.
/// 3. When a value differs from the cached copy, updates the cache AND
///    pushes the new value to that entry's stream controller (if streaming
///    is enabled). This ensures streams stay live when storage is read on
///    startup or after a `refresh()` call.
/// 4. Sets `_isLoaded = true` before returning.
/// 5. Calls `notifyListeners()` if the module uses [ChangeNotifier] and any
///    value changed during the load.
class LoadMethodBodyBuilder {
  final Module module;

  const LoadMethodBodyBuilder(this.module);

  Code build() {
    final body = StringBuffer()

    // Guard: skip the full storage read if already loaded.
    ..writeln('if (${Names.isLoadedVar}) return;')
    ..writeln('bool ${Names.changeMarkerVar} = false;');

    for (final entry in module.entries) {
      // Reference the generated keys class rather than a raw string literal.
      final keyRef = '${module.keysName}.${entry.name}';
      final cachedVar = Names.cachedField(entry.name);

      // Proper camelCase variable names: `rawUsername`, `newUsername`.
      final pascalName = _toPascal(entry.name);
      final rawVar = 'raw$pascalName';
      final newVar = 'new$pascalName';

      final deserialization = entry.buildDeserializationExpression(rawVar);

      // Push to the stream controller when the value changes during load,
      // so streams stay live on startup and after refresh().
      final streamPush = entry.resolvedStream != null
          ? ' ${Names.streamControllerField(entry.name)}.add($newVar);'
          : '';

      body
        ..writeln(
          'final $rawVar = await ${Names.adapterFieldName}'
          '.get<${entry.storageType.symbol}>($keyRef);',
        )
        ..writeln(
          'final $newVar = $rawVar == null'
          ' ? ${entry.defaultSourceExpression}'
          ' : $deserialization;',
        )
        ..writeln(
          'if ($cachedVar != $newVar) {'
          ' $cachedVar = $newVar;'
          '$streamPush'
          ' ${Names.changeMarkerVar} = true;'
          ' }',
        );
    }

    // Mark the cache as populated.
    body.writeln('${Names.isLoadedVar} = true;');

    if (module.usesChangeNotifier && module.isNotifiable) {
      body.writeln(
        'if (${Names.changeMarkerVar})'
        ' { (this as ChangeNotifier).notifyListeners(); }',
      );
    }

    return Code(body.toString());
  }

  /// Capitalises the first character of [name] to form a PascalCase fragment
  /// suitable for embedding in a local variable name (e.g., `username` →
  /// `Username`, `isFirstLaunch` → `IsFirstLaunch`).
  String _toPascal(String name) => name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
}
