import 'package:flutter/foundation.dart';
import 'package:preferences_annotation/preferences_annotation.dart';

import '../../domain/enums.dart';

part 'secure_app_settings.g.dart';

@PreferenceModule()
abstract class SecureAppSettings with _$SecureAppSettings, ChangeNotifier {
  factory SecureAppSettings(
    PreferenceAdapter adapter, {

    // --- Authentication ---
    @PreferenceEntry(key: 'user_auth_token')
    final String? authToken,

    @PreferenceEntry(key: 'session_expiry')
    final DateTime? sessionExpiryDate,

    @PreferenceEntry(key: 'user_role', defaultValue: UserRole.guest)
    final UserRole userRole,

    // --- Security Settings ---
    @PreferenceEntry(key: 'biometric_preference', defaultValue: BiometricAuth.none)
    final BiometricAuth biometricPreference,

    @PreferenceEntry(key: 'failed_pin_attempts', defaultValue: 0)
    final int pinAttemptCount,

    @PreferenceEntry(key: 'account_lockout_until')
    final DateTime? accountLockoutUntil,

    // --- Sensitive Data ---
    @PreferenceEntry(key: 'payment_token')
    final String? paymentToken,

    @PreferenceEntry(key: 'shipping_address_json')
    final Map<String, dynamic>? shippingAddress,
  }) = _SecureAppSettings;

  static Future<SecureAppSettings> create(PreferenceAdapter adapter) async {
    final instance = _SecureAppSettings(adapter);
    await instance._load();
    return instance;
  }
}