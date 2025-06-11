// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, no_leading_underscores_for_local_identifiers

part of 'secure_app_settings.dart';

// **************************************************************************
// PreferenceGenerator
// **************************************************************************

class _SecureAppSettingsKeys {
  static const authToken = 'user_auth_token';

  static const sessionExpiryDate = 'session_expiry';

  static const userRole = 'user_role';

  static const biometricPreference = 'biometric_preference';

  static const pinAttemptCount = 'failed_pin_attempts';

  static const accountLockoutUntil = 'account_lockout_until';

  static const paymentToken = 'payment_token';

  static const shippingAddress = 'shipping_address_json';
}

mixin _$SecureAppSettings {
  Future<void> reload();
  Future<void> clear();
  String? get authToken;
  Future<String?> authTokenAsync();
  Future<void> setAuthToken(String value);
  Future<void> removeAuthToken();
  DateTime? get sessionExpiryDate;
  Future<DateTime?> sessionExpiryDateAsync();
  Future<void> setSessionExpiryDate(DateTime value);
  Future<void> removeSessionExpiryDate();
  UserRole get userRole;
  Future<UserRole> userRoleAsync();
  Future<void> setUserRole(UserRole value);
  Future<void> removeUserRole();
  BiometricAuth get biometricPreference;
  Future<BiometricAuth> biometricPreferenceAsync();
  Future<void> setBiometricPreference(BiometricAuth value);
  Future<void> removeBiometricPreference();
  int get pinAttemptCount;
  Future<int> pinAttemptCountAsync();
  Future<void> setPinAttemptCount(int value);
  Future<void> removePinAttemptCount();
  DateTime? get accountLockoutUntil;
  Future<DateTime?> accountLockoutUntilAsync();
  Future<void> setAccountLockoutUntil(DateTime value);
  Future<void> removeAccountLockoutUntil();
  String? get paymentToken;
  Future<String?> paymentTokenAsync();
  Future<void> setPaymentToken(String value);
  Future<void> removePaymentToken();
  Map<String, dynamic>? get shippingAddress;
  Future<Map<String, dynamic>?> shippingAddressAsync();
  Future<void> setShippingAddress(Map<String, dynamic> value);
  Future<void> removeShippingAddress();
}

class _SecureAppSettings extends ChangeNotifier implements SecureAppSettings {
  _SecureAppSettings(
    PreferenceAdapter this._adapter, {
    String? authToken,
    DateTime? sessionExpiryDate,
    UserRole userRole = UserRole.guest,
    BiometricAuth biometricPreference = BiometricAuth.none,
    int pinAttemptCount = 0,
    DateTime? accountLockoutUntil,
    String? paymentToken,
    Map<String, dynamic>? shippingAddress,
  }) : _authToken = authToken,
       _sessionExpiryDate = sessionExpiryDate,
       _userRole = userRole,
       _biometricPreference = biometricPreference,
       _pinAttemptCount = pinAttemptCount,
       _accountLockoutUntil = accountLockoutUntil,
       _paymentToken = paymentToken,
       _shippingAddress = shippingAddress;

  final PreferenceAdapter _adapter;

  String? _authToken;

  DateTime? _sessionExpiryDate;

  UserRole _userRole;

  BiometricAuth _biometricPreference;

  int _pinAttemptCount;

  DateTime? _accountLockoutUntil;

  String? _paymentToken;

  Map<String, dynamic>? _shippingAddress;

  Future<void> _load() async {
    bool P_changed = false;
    final rawValueForAuthToken = await _adapter.get<String?>(
      _SecureAppSettingsKeys.authToken,
    );
    final newValueForAuthToken = rawValueForAuthToken ?? null;
    if (_authToken != newValueForAuthToken) {
      _authToken = newValueForAuthToken;
      P_changed = true;
    }
    final rawValueForSessionExpiryDate = await _adapter.get<DateTime?>(
      _SecureAppSettingsKeys.sessionExpiryDate,
    );
    final newValueForSessionExpiryDate = rawValueForSessionExpiryDate ?? null;
    if (_sessionExpiryDate != newValueForSessionExpiryDate) {
      _sessionExpiryDate = newValueForSessionExpiryDate;
      P_changed = true;
    }
    final rawValueForUserRole = await _adapter.get<String?>(
      _SecureAppSettingsKeys.userRole,
    );
    final newValueForUserRole =
        UserRole.values.asNameMap()[rawValueForUserRole] ?? UserRole.guest;
    if (_userRole != newValueForUserRole) {
      _userRole = newValueForUserRole;
      P_changed = true;
    }
    final rawValueForBiometricPreference = await _adapter.get<String?>(
      _SecureAppSettingsKeys.biometricPreference,
    );
    final newValueForBiometricPreference =
        BiometricAuth.values.asNameMap()[rawValueForBiometricPreference] ??
        BiometricAuth.none;
    if (_biometricPreference != newValueForBiometricPreference) {
      _biometricPreference = newValueForBiometricPreference;
      P_changed = true;
    }
    final rawValueForPinAttemptCount = await _adapter.get<int>(
      _SecureAppSettingsKeys.pinAttemptCount,
    );
    final newValueForPinAttemptCount = rawValueForPinAttemptCount ?? 0;
    if (_pinAttemptCount != newValueForPinAttemptCount) {
      _pinAttemptCount = newValueForPinAttemptCount;
      P_changed = true;
    }
    final rawValueForAccountLockoutUntil = await _adapter.get<DateTime?>(
      _SecureAppSettingsKeys.accountLockoutUntil,
    );
    final newValueForAccountLockoutUntil =
        rawValueForAccountLockoutUntil ?? null;
    if (_accountLockoutUntil != newValueForAccountLockoutUntil) {
      _accountLockoutUntil = newValueForAccountLockoutUntil;
      P_changed = true;
    }
    final rawValueForPaymentToken = await _adapter.get<String?>(
      _SecureAppSettingsKeys.paymentToken,
    );
    final newValueForPaymentToken = rawValueForPaymentToken ?? null;
    if (_paymentToken != newValueForPaymentToken) {
      _paymentToken = newValueForPaymentToken;
      P_changed = true;
    }
    final rawValueForShippingAddress = await _adapter
        .get<Map<String, dynamic>?>(_SecureAppSettingsKeys.shippingAddress);
    final newValueForShippingAddress = rawValueForShippingAddress ?? null;
    if (_shippingAddress != newValueForShippingAddress) {
      _shippingAddress = newValueForShippingAddress;
      P_changed = true;
    }
    if (P_changed) {
      notifyListeners();
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
  String? get authToken => _authToken;

  @override
  Future<String?> authTokenAsync() async {
    await reload();
    return _authToken;
  }

  @override
  Future<void> setAuthToken(String value) async {
    if (_authToken != value) {
      _authToken = value;
      final toStore = value;
      await _adapter.set<String>(_SecureAppSettingsKeys.authToken, toStore);
      notifyListeners();
    }
  }

  @override
  Future<void> removeAuthToken() async {
    final defaultValue = null;
    if (_authToken != defaultValue) {
      _authToken = defaultValue;
      await _adapter.remove(_SecureAppSettingsKeys.authToken);
      notifyListeners();
    }
  }

  @override
  DateTime? get sessionExpiryDate => _sessionExpiryDate;

  @override
  Future<DateTime?> sessionExpiryDateAsync() async {
    await reload();
    return _sessionExpiryDate;
  }

  @override
  Future<void> setSessionExpiryDate(DateTime value) async {
    if (_sessionExpiryDate != value) {
      _sessionExpiryDate = value;
      final toStore = value;
      await _adapter.set<DateTime>(
        _SecureAppSettingsKeys.sessionExpiryDate,
        toStore,
      );
      notifyListeners();
    }
  }

  @override
  Future<void> removeSessionExpiryDate() async {
    final defaultValue = null;
    if (_sessionExpiryDate != defaultValue) {
      _sessionExpiryDate = defaultValue;
      await _adapter.remove(_SecureAppSettingsKeys.sessionExpiryDate);
      notifyListeners();
    }
  }

  @override
  UserRole get userRole => _userRole;

  @override
  Future<UserRole> userRoleAsync() async {
    await reload();
    return _userRole;
  }

  @override
  Future<void> setUserRole(UserRole value) async {
    if (_userRole != value) {
      _userRole = value;
      final toStore = value.name;
      await _adapter.set<String>(_SecureAppSettingsKeys.userRole, toStore);
      notifyListeners();
    }
  }

  @override
  Future<void> removeUserRole() async {
    final defaultValue = UserRole.guest;
    if (_userRole != defaultValue) {
      _userRole = defaultValue;
      await _adapter.remove(_SecureAppSettingsKeys.userRole);
      notifyListeners();
    }
  }

  @override
  BiometricAuth get biometricPreference => _biometricPreference;

  @override
  Future<BiometricAuth> biometricPreferenceAsync() async {
    await reload();
    return _biometricPreference;
  }

  @override
  Future<void> setBiometricPreference(BiometricAuth value) async {
    if (_biometricPreference != value) {
      _biometricPreference = value;
      final toStore = value.name;
      await _adapter.set<String>(
        _SecureAppSettingsKeys.biometricPreference,
        toStore,
      );
      notifyListeners();
    }
  }

  @override
  Future<void> removeBiometricPreference() async {
    final defaultValue = BiometricAuth.none;
    if (_biometricPreference != defaultValue) {
      _biometricPreference = defaultValue;
      await _adapter.remove(_SecureAppSettingsKeys.biometricPreference);
      notifyListeners();
    }
  }

  @override
  int get pinAttemptCount => _pinAttemptCount;

  @override
  Future<int> pinAttemptCountAsync() async {
    await reload();
    return _pinAttemptCount;
  }

  @override
  Future<void> setPinAttemptCount(int value) async {
    if (_pinAttemptCount != value) {
      _pinAttemptCount = value;
      final toStore = value;
      await _adapter.set<int>(_SecureAppSettingsKeys.pinAttemptCount, toStore);
      notifyListeners();
    }
  }

  @override
  Future<void> removePinAttemptCount() async {
    final defaultValue = 0;
    if (_pinAttemptCount != defaultValue) {
      _pinAttemptCount = defaultValue;
      await _adapter.remove(_SecureAppSettingsKeys.pinAttemptCount);
      notifyListeners();
    }
  }

  @override
  DateTime? get accountLockoutUntil => _accountLockoutUntil;

  @override
  Future<DateTime?> accountLockoutUntilAsync() async {
    await reload();
    return _accountLockoutUntil;
  }

  @override
  Future<void> setAccountLockoutUntil(DateTime value) async {
    if (_accountLockoutUntil != value) {
      _accountLockoutUntil = value;
      final toStore = value;
      await _adapter.set<DateTime>(
        _SecureAppSettingsKeys.accountLockoutUntil,
        toStore,
      );
      notifyListeners();
    }
  }

  @override
  Future<void> removeAccountLockoutUntil() async {
    final defaultValue = null;
    if (_accountLockoutUntil != defaultValue) {
      _accountLockoutUntil = defaultValue;
      await _adapter.remove(_SecureAppSettingsKeys.accountLockoutUntil);
      notifyListeners();
    }
  }

  @override
  String? get paymentToken => _paymentToken;

  @override
  Future<String?> paymentTokenAsync() async {
    await reload();
    return _paymentToken;
  }

  @override
  Future<void> setPaymentToken(String value) async {
    if (_paymentToken != value) {
      _paymentToken = value;
      final toStore = value;
      await _adapter.set<String>(_SecureAppSettingsKeys.paymentToken, toStore);
      notifyListeners();
    }
  }

  @override
  Future<void> removePaymentToken() async {
    final defaultValue = null;
    if (_paymentToken != defaultValue) {
      _paymentToken = defaultValue;
      await _adapter.remove(_SecureAppSettingsKeys.paymentToken);
      notifyListeners();
    }
  }

  @override
  Map<String, dynamic>? get shippingAddress => _shippingAddress;

  @override
  Future<Map<String, dynamic>?> shippingAddressAsync() async {
    await reload();
    return _shippingAddress;
  }

  @override
  Future<void> setShippingAddress(Map<String, dynamic> value) async {
    if (_shippingAddress != value) {
      _shippingAddress = value;
      final toStore = value;
      await _adapter.set<Map<String, dynamic>>(
        _SecureAppSettingsKeys.shippingAddress,
        toStore,
      );
      notifyListeners();
    }
  }

  @override
  Future<void> removeShippingAddress() async {
    final defaultValue = null;
    if (_shippingAddress != defaultValue) {
      _shippingAddress = defaultValue;
      await _adapter.remove(_SecureAppSettingsKeys.shippingAddress);
      notifyListeners();
    }
  }
}
