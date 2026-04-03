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

  CliConfig._({
    // --- Primitives ---
    String username = 'anonymous',
    double themeOpacity = 1.0,
    int selectedItemId = 0,

    // --- Collections ---
    List<String> recentSearches = const <String>[],
    Set<int> favoriteItemIds = const <int>{},
    Map<String, String> userMetadata = const <String, String>{},

    // --- Dart types ---
    Duration timeoutDuration = const Duration(seconds: 30),

    // --- Records ---
    ({String id, bool isPrimary}) primaryAccount = (id: '0', isPrimary: false),
    (int, int)? cursorPosition,

    // --- Enum ---
    LogLevel logLevel = LogLevel.info,

    // --- Custom serialization via PrefConverter ---
    @PrefEntry(converter: UriConverter())
    Uri? apiEndpoint,

    // --- Custom serialization via static functions ---
    @PrefEntry(toStorage: _userToStorage, fromStorage: _userFromStorage)
    User? currentUser,

    // --- Non-constant default (factory function) ---
    @PrefEntry(initial: _getCreationDate)
    DateTime? creationDate,

    // --- @PrefEntry feature showcase ---

    // 1. Custom method names using templates.
    //    Previously: setter: CustomConfig(name: 'toggleSplashScreen'),
    //                streamer: CustomConfig(prefix: 'splashScreen', suffix: 'StateChanges')
    @PrefEntry(
      setter: 'toggle{{Name}}',
      asyncSetter: 'toggle{{Name}}Async',
      streamer: '{{name}}StateChanges',
    )
    bool showSplashScreen = true,

    // 2. Read-only field — compile-time enforced, no setter or remover.
    //    Previously: setter: CustomConfig(enabled: false), remover: CustomConfig(enabled: false)
    @PrefEntry(readOnly: true)
    String buildId = 'build-001',

    // 3. Notifiable override: changes to this field will NOT call notifyListeners().
    @PrefEntry(notifiable: false)
    String temporarySessionId = '',

    // 4. Launch count with explicit storage key.
    @PrefEntry(key: 'total_launches')
    int launchCount = 0,
  });

  static Map<String, dynamic> _userToStorage(User user) => user.toJson();
  static User _userFromStorage(Map<String, dynamic> map) => User.fromJson(map);
  static DateTime _getCreationDate() => DateTime.now();
}
