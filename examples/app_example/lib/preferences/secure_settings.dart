import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:preferences_annotation/preferences_annotation.dart';

part '../generated/preferences/secure_settings.prefs.dart';

class ApiSession {
  final String token;
  final DateTime expiry;
  ApiSession({required this.token, required this.expiry});
  Map<String, dynamic> toJson() => {'token': token, 'expiry': expiry.toIso8601String()};
  factory ApiSession.fromJson(Map<String, dynamic> json) => ApiSession(
    token: json['token'] as String,
    expiry: DateTime.parse(json['expiry'] as String),
  );
}

@PrefsModule(keyCase: KeyCase.snake)
abstract class SecureSettings with _$SecureSettings, ChangeNotifier {
  factory SecureSettings(PrefsAdapter adapter) = _SecureSettings;

  SecureSettings._({
    // A nullable String for sensitive data.
    @PrefEntry(
      streamer: CustomConfig(enabled: true, prefix: 'watch', suffix: 'Stream'),
    )
    String? authToken,

    // A custom object using to/fromStorage functions for JSON serialization.
    @PrefEntry(toStorage: _sessionToStorage, fromStorage: _sessionFromStorage)
    ApiSession? apiSession,

    // A boolean flag with streaming enabled.
    @PrefEntry(streamer: CustomConfig(enabled: true)) bool areBiometricsEnabled = false,
  });

  static Map<String, dynamic> _sessionToStorage(ApiSession session) => session.toJson();
  static ApiSession _sessionFromStorage(Map<String, dynamic> map) => ApiSession.fromJson(map);
}
