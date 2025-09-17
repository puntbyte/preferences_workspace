import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/models/entry.dart';
import 'package:preferences_generator/src/models/module.dart';
import 'package:preferences_generator/src/utils/names.dart';

/// A specialized class to generate the body for any method that changes a value (setters/removers).
class ValueChangeLogicBuilder {
  final Module module;
  final Entry entry;

  const ValueChangeLogicBuilder({required this.module, required this.entry});

  /// Generates the full `Code` block for the method body.
  Code build({
    required String newValueExpression,
    required bool isRemove,
    required bool isAsync,
  }) {
    final cachedVar = Names.cachedField(entry.name);
    final controller = Names.streamControllerField(entry.name);

    final notifyLogic = (module.usesChangeNotifier && module.notifiable && entry.resolvedNotifiable)
        ? '(this as ChangeNotifier).notifyListeners();'
        : '';

    final streamLogic = entry.resolvedStream.enabled ? '$controller.add($newValueExpression);' : '';

    final saveAction = isRemove
        ? "await ${Names.adapterFieldName}.remove('${entry.storageKey}');"
        : 'final toStore = ${entry.buildSerializationExpression(newValueExpression)}; await '
              "${Names.adapterFieldName}.set<${entry.storageType.symbol}>('${entry.storageKey}', "
              'toStore);';

    final fullSaveLogic = isAsync ? saveAction : 'Future(() async { $saveAction });';

    return Code(
      'if ($cachedVar != $newValueExpression) { $cachedVar = $newValueExpression; $fullSaveLogic '
      '$streamLogic $notifyLogic }',
    );
  }
}
