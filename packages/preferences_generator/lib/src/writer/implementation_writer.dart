import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:preferences_generator/src/model/module_definition.dart';
import 'package:preferences_generator/src/model/entry_definition.dart';
import 'package:preferences_generator/src/utils/name_registry.dart';
import 'package:preferences_generator/src/utils/type_analyzer.dart';
import 'package:preferences_generator/src/writer/syntax_writer.dart';

class ImplementationWriter {
  final ModuleDefinition module;

  const ImplementationWriter(this.module);

  Class write() {
    return SyntaxWriter.class$(
      name: module.implementationName,
      extend: module.usesChangeNotifier
          ? const Reference('ChangeNotifier')
          : null,
      //mixins: [Reference(module.name)],
      implements: [Reference(module.name)],
      fields: _buildFields(),
      constructors: [_buildConstructor()],
      methods: [
        ..._buildLifecycleMethods(),
        ...module.entries.expand(_buildEntryMethods),
      ],
    );
  }

  List<Field> _buildFields() {
    return [
      SyntaxWriter.field(
        name: NameRegistry.adapterFieldName,
        type: const Reference(NameRegistry.adapterInterface),
        modifier: FieldModifier.final$,
      ),

      ...module.entries.map(
        (entry) => SyntaxWriter.field(
          name: NameRegistry.cachedField(entry.name),
          type: Reference(entry.type.getDisplayString(withNullability: true)),
        ),
      ),
    ];
  }

  Constructor _buildConstructor() {
    return SyntaxWriter.constructor(
      requiredParameters: [
        SyntaxWriter.parameter(
          name: NameRegistry.adapterFieldName,
          type: const Reference(NameRegistry.adapterInterface),
          toThis: true,
        ),
      ],

      optionalParameters: module.entries
          .map(
            (entry) => SyntaxWriter.parameter(
              name: entry.name,
              type: Reference(
                entry.type.getDisplayString(withNullability: entry.isNullable),
              ),
              isNamed: true,
              defaultTo: entry.defaultValueCode != null
                  ? Code(entry.defaultValueCode!)
                  : null,
              isRequired: entry.defaultValueCode == null && !entry.isNullable,
            ),
          )
          .toList(),

      initializers: module.entries.map((entry) {
        return Code('${NameRegistry.cachedField(entry.name)} = ${entry.name}');
      }).toList(),
    );
  }

  List<Method> _buildLifecycleMethods() {
    final loadBody = StringBuffer(
      'bool ${NameRegistry.changeMarkerVar} = false;\n',
    );

    for (final entry in module.entries) {
      final keyConst = '${module.keysName}.${entry.name}';
      final cachedVar = NameRegistry.cachedField(entry.name);
      final storageType = TypeAnalyzer.getStorageType(entry.type);
      final rawValueVar = NameRegistry.rawValueVar(entry.name);
      final newValueVar = NameRegistry.newValueVar(entry.name);

      loadBody.writeln(
        'final $rawValueVar = await ${NameRegistry.adapterFieldName}.get<$storageType>($keyConst);',
      );
      final deserializationExpr = TypeAnalyzer.buildDeserializationExpression(
        rawValueVar,
        entry.type,
      );
      final finalDefault = entry.defaultValueCode ?? 'null';
      loadBody.writeln(
        'final $newValueVar = $deserializationExpr ?? $finalDefault;',
      );
      loadBody.writeln(
        'if ($cachedVar != $newValueVar) { $cachedVar = $newValueVar; ${NameRegistry.changeMarkerVar} = true; }',
      );
    }

    if (module.usesChangeNotifier) {
      loadBody.writeln(
        'if (${NameRegistry.changeMarkerVar}) { notifyListeners(); }',
      );
    }

    return [
      SyntaxWriter.method(
        name: NameRegistry.privateLoadMethod,
        returns: const Reference('Future<void>'),
        modifier: MethodModifier.async,
        body: Code(loadBody.toString()),
      ),

      SyntaxWriter.method(
        name: NameRegistry.publicReloadMethod,
        annotations: [const Reference('override')],
        returns: const Reference('Future<void>'),
        modifier: MethodModifier.async,
        body: Code('await ${NameRegistry.privateLoadMethod}();'),
      ),

      SyntaxWriter.method(
        name: NameRegistry.publicClearMethod,
        annotations: [const Reference('override')],
        returns: const Reference('Future<void>'),
        modifier: MethodModifier.async,
        body: Code(
          'await ${NameRegistry.adapterFieldName}.clear(); await ${NameRegistry.privateLoadMethod}();',
        ),
      ),
    ];
  }

  List<Method> _buildEntryMethods(EntryDefinition entry) {
    final keyConst = '${module.keysName}.${entry.name}';
    final cachedVar = NameRegistry.cachedField(entry.name);
    final typeName = entry.type.getDisplayString(
      withNullability: entry.isNullable,
    );
    final nonNullableTypeName = entry.type.getDisplayString(
      withNullability: false,
    );

    final getter = SyntaxWriter.method(
      name: entry.name,
      annotations: [const Reference('override')],
      type: MethodType.getter,
      returns: Reference(typeName),
      body: Code(cachedVar),
      isLambda: true,
    );

    final asyncGetter = SyntaxWriter.method(
      name: NameRegistry.asyncGetter(entry.name),
      annotations: [const Reference('override')],
      returns: Reference('Future<$typeName>'),
      modifier: MethodModifier.async,
      body: Code('''
        await ${NameRegistry.publicReloadMethod}(); 
        return $cachedVar;
      '''),
    );

    // Pre-calculate the necessary code strings at BUILD TIME.
    final serializationExpr = TypeAnalyzer.buildSerializationExpression(
      NameRegistry.valueParameter,
      entry.type,
    );

    final storageTypeForSet = TypeAnalyzer.getStorageType(
      entry.type,
    ).replaceAll('?', '');

    final setter = SyntaxWriter.method(
      name: NameRegistry.setter(entry.name),
      annotations: [const Reference('override')],
      returns: const Reference('Future<void>'),
      modifier: MethodModifier.async,
      requiredParameters: [
        SyntaxWriter.parameter(
          name: NameRegistry.valueParameter,
          type: Reference(nonNullableTypeName),
        ),
      ],
      body: Code('''
        if ($cachedVar != ${NameRegistry.valueParameter}) {
          $cachedVar = ${NameRegistry.valueParameter}; 
          final ${NameRegistry.toStoreParameter} = $serializationExpr;
          await ${NameRegistry.adapterFieldName}.set<$storageTypeForSet>($keyConst, ${NameRegistry.toStoreParameter});    
          ${module.usesChangeNotifier ? 'notifyListeners();' : ''}
        }
      '''),
    );

    String defaultValueInitializationCode;
    final defaultValueExpr = entry.defaultValueCode ?? 'null';

    if (entry.type is InterfaceType &&
        (entry.type as InterfaceType).typeArguments.isNotEmpty) {
      final type = entry.type as InterfaceType;
      if (type.isDartCoreList && defaultValueExpr == 'const []') {
        // e.g., List<String> -> <String>
        final typeArg = type.typeArguments.first.getDisplayString(
          withNullability: true,
        );
        defaultValueInitializationCode = 'const <$typeArg>[]';
      } else if (type.isDartCoreMap && defaultValueExpr == 'const {}') {
        // e.g., Map<String, int> -> <String, int>
        final keyArg = type.typeArguments[0].getDisplayString(
          withNullability: true,
        );
        final valueArg = type.typeArguments[1].getDisplayString(
          withNullability: true,
        );
        defaultValueInitializationCode = 'const <$keyArg, $valueArg>{}';
      } else {
        // For all other cases, the existing code is correct.
        defaultValueInitializationCode = defaultValueExpr;
      }
    } else {
      defaultValueInitializationCode = defaultValueExpr;
    }

    final remover = SyntaxWriter.method(
      name: NameRegistry.removerMethod(entry.name),
      annotations: [const Reference('override')],
      returns: const Reference('Future<void>'),
      modifier: MethodModifier.async,
      body: Code('''
        final defaultValue = $defaultValueInitializationCode;
        if ($cachedVar != defaultValue) {
            $cachedVar = defaultValue;
            await ${NameRegistry.adapterFieldName}.remove($keyConst);
            ${module.usesChangeNotifier ? 'notifyListeners();' : ''}
        }
      '''),
    );

    return [getter, asyncGetter, setter, remover];
  }
}
