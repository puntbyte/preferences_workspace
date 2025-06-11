import 'package:build/build.dart';
import 'package:preferences_generator/preferences_generator.dart';
import 'package:source_gen/source_gen.dart';

/// The builder factory that creates an instance of the preference generator.
///
/// This function is referenced by `build.yaml` and is the entry point
/// for the `build_runner` process.
Builder preferencesBuilderFactory(BuilderOptions options) {
  // A PartBuilder is used because our generator creates a single `.g.dart`
  // file that will be included as a 'part' of the user's source file.
  return PartBuilder(
    [PreferenceGenerator()],
    '.g.dart',
    // This header is automatically added to the top of every generated file.
    header: '''
// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, no_leading_underscores_for_local_identifiers
''',
    // This setting tells the builder to format the generated code.
    options: options,
  );
}
