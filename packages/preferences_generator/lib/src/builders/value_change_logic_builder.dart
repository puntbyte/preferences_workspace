import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/models/entry.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/names.dart';

/// Generates the body for any method that mutates a value (setters and
/// removers).
///
/// ### Key behaviours
///
/// - **Optimistic update:** the in-memory field is updated synchronously
///   before storage is written. This ensures the UI or stream subscribers
///   see the new value immediately.
/// - **Keys class references:** all adapter calls use the generated
///   `_<Module>Keys.<fieldName>` constant rather than a raw string literal,
///   preserving the type-safety guarantee of the package.
/// - **Error handling:** synchronous (fire-and-forget) writes wrap the
///   adapter call in a try/catch and invoke the module's optional
///   [Module.onWriteErrorExpression] callback on failure. Without a callback,
///   failures are still caught and discarded silently to avoid crashing the
///   isolate.
class ValueChangeLogicBuilder {
  final Module module;
  final Entry entry;

  const ValueChangeLogicBuilder({required this.module, required this.entry});

  Code build({
    required String newValueExpression,
    required bool isRemove,
    required bool isAsync,
  }) {
    final cachedVar = Names.cachedField(entry.name);
    final controller = Names.streamControllerField(entry.name);

    // Use the generated keys class, not a raw string literal.
    final keyRef = '${module.keysName}.${entry.name}';

    final notifyLogic =
    (module.usesChangeNotifier && module.notifiable && entry.resolvedNotifiable)
        ? '(this as ChangeNotifier).notifyListeners();'
        : '';

    final streamLogic = entry.resolvedStream != null
        ? '$controller.add($newValueExpression);'
        : '';

    final adapterCall = isRemove
        ? 'await ${Names.adapterFieldName}.remove($keyRef);'
        : 'final toStore = ${entry.buildSerializationExpression(newValueExpression)};'
        ' await ${Names.adapterFieldName}'
        '.set<${entry.storageType.symbol}>($keyRef, toStore);';

    final saveLogic = isAsync
        ? adapterCall
        : _buildFireAndForget(adapterCall);

    return Code(
      'if ($cachedVar != $newValueExpression) {'
          ' $cachedVar = $newValueExpression;'
          ' $saveLogic'
          ' $streamLogic'
          ' $notifyLogic'
          ' }',
    );
  }

  /// Wraps [adapterCall] in a fire-and-forget `Future(() async { ... })` block
  /// with a try/catch. If the module provided an [onWriteError] callback, it
  /// is called on failure; otherwise the error is swallowed silently with an
  /// empty catch body.
  ///
  /// Note: never embed a `//` comment inside a single-line generated string —
  /// it would comment out the closing braces that follow it on the same line.
  String _buildFireAndForget(String adapterCall) {
    final catchBody = module.onWriteErrorExpression != null
        ? '${module.onWriteErrorExpression}(e, st);'
        : '';

    return 'Future(() async {'
        ' try { $adapterCall }'
        ' catch (e, st) { $catchBody }'
        ' });';
  }
}
