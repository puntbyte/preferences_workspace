import 'package:build/build.dart';
import 'package:preferences_generator/src/preferences_generator.dart';
import 'package:source_gen/source_gen.dart';

/// The builder factory that creates an instance of the preference generator.
Builder preferences(BuilderOptions options) {
  const defaultBuildExtensions = '.prefs.dart';

  return PartBuilder(
    [PreferenceGenerator(options)],
    defaultBuildExtensions,
    header: [
      '// GENERATED CODE - DO NOT MODIFY BY HAND\n',
      '// ignore_for_file: type=lint, prefer_const_constructors',
      '// ignore_for_file: unused_import, prefer_relative_imports',
    ].join('\n'),
    options: options,
  );
}
