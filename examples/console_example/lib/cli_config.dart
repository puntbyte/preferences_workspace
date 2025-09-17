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
  CliConfig._({
    // --- 1. Basic Supported Types ---
    String username = 'guest',
    double themeOpacity = 0.95,
    bool isAutoSaveEnabled = true,

    // --- 2. Nullable Primitives ---
    int? selectedItemId,

    // --- 3. Collections (must have defaults) ---
    List<String> recentSearches = const [],
    Set<int> favoriteItemIds = const {},
    Map<String, String> userMetadata = const {},

    // --- 4. Dart Core Types ---
    Duration timeoutDuration = const Duration(seconds: 30),
    DateTime? lastSessionEnd,
    @PrefEntry(initial: _getCreationDate) DateTime? creationDate,

    // --- 5. Enums & Records ---
    LogLevel logLevel = LogLevel.info,
    (int x, int y)? cursorPosition,
    // A more complex, non-nullable record with a default
    ({String id, bool isPrimary}) primaryAccount = (id: '0', isPrimary: false),

    // --- 6. Custom Serialization ---
    @PrefEntry(converter: UriConverter(), initial: _$apiEndpoint) Uri? apiEndpoint,
    @PrefEntry(toStorage: _userToStorage, fromStorage: _userFromStorage) User? currentUser,

    // --- 7. @PrefEntry Feature Showcase ---
    // a) Custom storage key
    @PrefEntry(key: 'launch_counter') int launchCount = 0,

    // b) Read-only entry (disables setters/removers)
    @PrefEntry(
      setter: CustomConfig(enabled: false),
      asyncSetter: CustomConfig(enabled: false),
      remover: CustomConfig(enabled: false),
      asyncRemover: CustomConfig(enabled: false),
    )
    String buildId = 'd4f1a2b',

    // c) Method name overrides for specific methods
    @PrefEntry(
      setter: CustomConfig(name: 'toggleSplashScreen'),
      remover: CustomConfig(name: 'resetSplashScreen'),
      asyncSetter: CustomConfig(name: 'toggleSplashScreenAsync'),
      streamer: CustomConfig(name: 'splashScreenStateChanges'),
    )
    bool showSplashScreen = true,

    // d) Per-entry `notifiable` override (module default is true)
    @PrefEntry(notifiable: false) String temporarySessionId = '',
  });

  // Static function for a non-constant default value.
  static Uri _$apiEndpoint() => Uri.parse('https://api.example.com');

  // Static function for a non-constant default value, required for a non-nullable field.
  static DateTime _getCreationDate() => DateTime.now();

  // Static functions for custom serialization of the `User` model.
  static Map<String, dynamic> _userToStorage(User user) => user.toJson();
  static User _userFromStorage(Map<String, dynamic> value) => User.fromJson(value);
}
