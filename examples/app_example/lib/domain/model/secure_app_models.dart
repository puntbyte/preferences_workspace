// lib/domain/models/secure_app_models.dart
import 'package:flutter/foundation.dart'; // For listEquals

class ApiSession {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final List<String> scopes;

  ApiSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.scopes = const [],
  });

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toIso8601String(),
    'scopes': scopes,
  };

  factory ApiSession.fromJson(Map<String, dynamic> json) => ApiSession(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    scopes: (json['scopes'] as List<dynamic>?)?.cast<String>() ?? [],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiSession &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          expiresAt == other.expiresAt &&
          listEquals(scopes, other.scopes);

  @override
  int get hashCode =>
      accessToken.hashCode ^
      refreshToken.hashCode ^
      expiresAt.hashCode ^
      scopes.hashCode;

  @override
  String toString() =>
      'ApiSession(accessToken: $accessToken, expiresAt: $expiresAt, scopes: $scopes)';
}
