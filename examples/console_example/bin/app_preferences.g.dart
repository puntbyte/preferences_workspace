// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, no_leading_underscores_for_local_identifiers

part of 'app_preferences.dart';

// **************************************************************************
// PreferenceGenerator
// **************************************************************************

class _AppPreferencesKeys {
  static const username = 'user_name';

  static const launchCount = 'launchCount';

  static const lastLogin = 'lastLogin';

  static const logLevel = 'logLevel';
}

mixin _$AppPreferences {
  Future<void> reload();
  Future<void> clear();
  String get username;
  Future<String> usernameAsync();
  Future<void> setUsername(String value);
  Future<void> removeUsername();
  int get launchCount;
  Future<int> launchCountAsync();
  Future<void> setLaunchCount(int value);
  Future<void> removeLaunchCount();
  DateTime? get lastLogin;
  Future<DateTime?> lastLoginAsync();
  Future<void> setLastLogin(DateTime value);
  Future<void> removeLastLogin();
  LogLevel get logLevel;
  Future<LogLevel> logLevelAsync();
  Future<void> setLogLevel(LogLevel value);
  Future<void> removeLogLevel();
}

class _AppPreferences implements AppPreferences {
  _AppPreferences(
    PreferenceAdapter this._adapter, {
    String username = 'Guest',
    int launchCount = 0,
    DateTime? lastLogin,
    LogLevel logLevel = LogLevel.info,
  }) : _username = username,
       _launchCount = launchCount,
       _lastLogin = lastLogin,
       _logLevel = logLevel;

  final PreferenceAdapter _adapter;

  String _username;

  int _launchCount;

  DateTime? _lastLogin;

  LogLevel _logLevel;

  Future<void> _load() async {
    bool P_changed = false;
    final rawValueForUsername = await _adapter.get<String>(
      _AppPreferencesKeys.username,
    );
    final newValueForUsername = rawValueForUsername ?? 'Guest';
    if (_username != newValueForUsername) {
      _username = newValueForUsername;
      P_changed = true;
    }
    final rawValueForLaunchCount = await _adapter.get<int>(
      _AppPreferencesKeys.launchCount,
    );
    final newValueForLaunchCount = rawValueForLaunchCount ?? 0;
    if (_launchCount != newValueForLaunchCount) {
      _launchCount = newValueForLaunchCount;
      P_changed = true;
    }
    final rawValueForLastLogin = await _adapter.get<DateTime?>(
      _AppPreferencesKeys.lastLogin,
    );
    final newValueForLastLogin = rawValueForLastLogin ?? null;
    if (_lastLogin != newValueForLastLogin) {
      _lastLogin = newValueForLastLogin;
      P_changed = true;
    }
    final rawValueForLogLevel = await _adapter.get<String?>(
      _AppPreferencesKeys.logLevel,
    );
    final newValueForLogLevel =
        LogLevel.values.asNameMap()[rawValueForLogLevel] ?? LogLevel.info;
    if (_logLevel != newValueForLogLevel) {
      _logLevel = newValueForLogLevel;
      P_changed = true;
    }
  }

  @override
  Future<void> reload() async {
    await _load();
  }

  @override
  Future<void> clear() async {
    await _adapter.clear();
    await _load();
  }

  @override
  String get username => _username;

  @override
  Future<String> usernameAsync() async {
    await reload();
    return _username;
  }

  @override
  Future<void> setUsername(String value) async {
    if (_username != value) {
      _username = value;
      final toStore = value;
      await _adapter.set<String>(_AppPreferencesKeys.username, toStore);
    }
  }

  @override
  Future<void> removeUsername() async {
    final defaultValue = 'Guest';
    if (_username != defaultValue) {
      _username = defaultValue;
      await _adapter.remove(_AppPreferencesKeys.username);
    }
  }

  @override
  int get launchCount => _launchCount;

  @override
  Future<int> launchCountAsync() async {
    await reload();
    return _launchCount;
  }

  @override
  Future<void> setLaunchCount(int value) async {
    if (_launchCount != value) {
      _launchCount = value;
      final toStore = value;
      await _adapter.set<int>(_AppPreferencesKeys.launchCount, toStore);
    }
  }

  @override
  Future<void> removeLaunchCount() async {
    final defaultValue = 0;
    if (_launchCount != defaultValue) {
      _launchCount = defaultValue;
      await _adapter.remove(_AppPreferencesKeys.launchCount);
    }
  }

  @override
  DateTime? get lastLogin => _lastLogin;

  @override
  Future<DateTime?> lastLoginAsync() async {
    await reload();
    return _lastLogin;
  }

  @override
  Future<void> setLastLogin(DateTime value) async {
    if (_lastLogin != value) {
      _lastLogin = value;
      final toStore = value;
      await _adapter.set<DateTime>(_AppPreferencesKeys.lastLogin, toStore);
    }
  }

  @override
  Future<void> removeLastLogin() async {
    final defaultValue = null;
    if (_lastLogin != defaultValue) {
      _lastLogin = defaultValue;
      await _adapter.remove(_AppPreferencesKeys.lastLogin);
    }
  }

  @override
  LogLevel get logLevel => _logLevel;

  @override
  Future<LogLevel> logLevelAsync() async {
    await reload();
    return _logLevel;
  }

  @override
  Future<void> setLogLevel(LogLevel value) async {
    if (_logLevel != value) {
      _logLevel = value;
      final toStore = value.name;
      await _adapter.set<String>(_AppPreferencesKeys.logLevel, toStore);
    }
  }

  @override
  Future<void> removeLogLevel() async {
    final defaultValue = LogLevel.info;
    if (_logLevel != defaultValue) {
      _logLevel = defaultValue;
      await _adapter.remove(_AppPreferencesKeys.logLevel);
    }
  }
}
