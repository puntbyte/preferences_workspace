import 'package:preferences_annotation/preferences_annotation.dart';

part 'app_preferences.g.dart';

enum LogLevel { none, error, info, verbose }

@PreferenceModule()
abstract class AppPreferences with _$AppPreferences {
  factory AppPreferences(
    PreferenceAdapter adapter, {
    // A simple String preference with a default value
    @PreferenceEntry(key: 'user_name', defaultValue: 'Guest')
    final String username,

    // An int preference
    @PreferenceEntry(defaultValue: 0) final int launchCount,

    // A nullable DateTime
    @PreferenceEntry() final DateTime? lastLogin,

    // An enum preference
    @PreferenceEntry(defaultValue: LogLevel.info) final LogLevel logLevel,
  }) = _AppPreferences;
}
