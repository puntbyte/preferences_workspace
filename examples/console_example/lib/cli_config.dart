import 'dart:async';

import 'package:console_example/converters/uri_converter.dart';
import 'package:console_example/models/user.dart';
import 'package:preferences_annotation/preferences_annotation.dart';

part 'cli_config.prefs.dart';

enum LogLevel { debug, info, warning, error }

// Using .exhaustive() (formerly .testing()) because this example is designed
// to demonstrate every possible method variant with predictable names. In a
// real CLI app, .minimal() would be the better choice.
@PrefsModule.exhaustive(keyCase: KeyCase.snake)
abstract class CliConfig with _$CliConfig {
  factory CliConfig(PrefsAdapter adapter) = _CliConfig;

  CliConfig._();

  static Map<String, dynamic> _userToStorage(User user) => user.toJson();
  static User _userFromStorage(Map<String, dynamic> map) => User.fromJson(map);
  static DateTime _getCreationDate() => DateTime.now();
}
