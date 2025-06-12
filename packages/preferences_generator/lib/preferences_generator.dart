import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:preferences_generator/src/model/module_definition.dart';
import 'package:preferences_generator/src/utils/exception_handler.dart';
import 'package:preferences_generator/src/writer/implementation_writer.dart';
import 'package:preferences_generator/src/writer/interface_writer.dart';
import 'package:preferences_generator/src/writer/keys_writer.dart';
import 'package:preferences_generator/src/writer/syntax_writer.dart';
import 'package:source_gen/source_gen.dart';

class PreferenceGenerator extends GeneratorForAnnotation<PreferenceModule> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) throw ExceptionHandler.notAClass(element);

    final module = ModuleDefinition.fromElement(element);

    final keysClass = KeysWriter(module).write();
    final interfaceMixin = InterfaceWriter(module).write();
    final implementationClass = ImplementationWriter(module).write();

    final library = SyntaxWriter.library(
      elements: [keysClass, interfaceMixin, implementationClass],
    );

    final emitter = DartEmitter(
      allocator: Allocator.simplePrefixing(),
      orderDirectives: true,
      useNullSafetySyntax: true,
    );

    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(library.accept(emitter).toString());
  }
}

/// The builder factory that creates an instance of the preference generator.
///
/// This function is referenced by `build.yaml` and is the entry point
/// for the `build_runner` process.
Builder preferencesBuilder(BuilderOptions options) {
  return PartBuilder(
    [PreferenceGenerator()],
    '.g.dart',
    header: '''
// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, no_leading_underscores_for_local_identifiers
''',
    // This setting tells the builder to format the generated code.
    options: options,
  );
}
