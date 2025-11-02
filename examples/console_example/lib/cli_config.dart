import 'dart:async';

import 'package:console_example/converters/uri_converter.dart';
import 'package:console_example/models/user.dart';
import 'package:preferences_annotation/preferences_annotation.dart';

part 'cli_config.prefs.dart';

enum LogLevel { none, error, info, verbose }

/// A comprehensive showcase of all features of the preferences_generator.
///
/// It uses the `.testing()` preset to generate all method types (sync/async/stream)
/// with predictable names for easy demonstration.
@PrefsModule.testing()
abstract class CliConfig with _$CliConfig {
  factory CliConfig(PrefsAdapter adapter) = _CliConfig;

  // The private schema constructor defines all the preference entries.
  CliConfig._();

  // Static function for a non-constant default value.
  static Uri _$apiEndpoint() => Uri.parse('https://api.example.com');

  // Static function for a non-constant default value, required for a non-nullable field.
  static DateTime _getCreationDate() => DateTime.now();

  // Static functions for custom serialization of the `User` model.
  static Map<String, dynamic> _userToStorage(User user) => user.toJson();
  static User _userFromStorage(Map<String, dynamic> value) => User.fromJson(value);
}
