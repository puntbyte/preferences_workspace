// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, prefer_const_constructors
// ignore_for_file: unused_import, prefer_relative_imports

part of 'secure_settings.dart';

// **************************************************************************
// PreferenceGenerator
// **************************************************************************

class _SecureSettingsKeys {
  static const authToken = 'authToken';

  static const apiSession = 'apiSession';

  static const areBiometricsEnabled = 'areBiometricsEnabled';
}

mixin _$SecureSettings {
  PrefsAdapter get _adapter;
  String? get _authToken;
  set _authToken(String? value);
  StreamController<String?> get _authTokenStreamController;
  ApiSession? get _apiSession;
  set _apiSession(ApiSession? value);
  bool get _areBiometricsEnabled;
  set _areBiometricsEnabled(bool value);
  StreamController<bool> get _areBiometricsEnabledStreamController;
  String? get authToken => _authToken;
  ApiSession? get apiSession => _apiSession;
  bool get areBiometricsEnabled => _areBiometricsEnabled;
  Future<void> refresh() async {
    await _load();
  }

  Future<void> removeAll() async {
    await _adapter.removeAll();
    await _load();
  }

  dispose() {
    _authTokenStreamController.close();
    _areBiometricsEnabledStreamController.close();
  }

  Future<void> _load() async {
    bool P_changed = false;
    final rawValueForAUTHTOKEN = await _adapter.get<String?>(
      _SecureSettingsKeys.authToken,
    );
    final newValueForAUTHTOKEN = rawValueForAUTHTOKEN == null
        ? null
        : rawValueForAUTHTOKEN;
    if (_authToken != newValueForAUTHTOKEN) {
      _authToken = newValueForAUTHTOKEN;
      P_changed = true;
    }
    final rawValueForAPISESSION = await _adapter.get<Map<String, dynamic>>(
      _SecureSettingsKeys.apiSession,
    );
    final newValueForAPISESSION = rawValueForAPISESSION == null
        ? null
        : SecureSettings._sessionFromStorage(rawValueForAPISESSION);
    if (_apiSession != newValueForAPISESSION) {
      _apiSession = newValueForAPISESSION;
      P_changed = true;
    }
    final rawValueForAREBIOMETRICSENABLED = await _adapter.get<bool>(
      _SecureSettingsKeys.areBiometricsEnabled,
    );
    final newValueForAREBIOMETRICSENABLED =
        rawValueForAREBIOMETRICSENABLED == null
        ? false
        : rawValueForAREBIOMETRICSENABLED;
    if (_areBiometricsEnabled != newValueForAREBIOMETRICSENABLED) {
      _areBiometricsEnabled = newValueForAREBIOMETRICSENABLED;
      P_changed = true;
    }
  }

  Future<String?> authTokenAsync() async {
    await _load();
    return _authToken;
  }

  void setAuthToken(String value) {
    if (_authToken != value) {
      _authToken = value;
      Future(() async {
        final toStore = value;
        await _adapter.set<String?>('authToken', toStore);
      });
      _authTokenStreamController.add(value);
    }
  }

  Future<void> setAuthTokenAsync(String value) async {
    if (_authToken != value) {
      _authToken = value;
      final toStore = value;
      await _adapter.set<String?>('authToken', toStore);
      _authTokenStreamController.add(value);
    }
  }

  void removeAuthToken() {
    if (_authToken != null) {
      _authToken = null;
      Future(() async {
        await _adapter.remove('authToken');
      });
      _authTokenStreamController.add(null);
    }
  }

  Future<void> removeAuthTokenAsync() async {
    if (_authToken != null) {
      _authToken = null;
      await _adapter.remove('authToken');
      _authTokenStreamController.add(null);
    }
  }

  Stream<String?> get authTokenStream => _authTokenStreamController.stream;
  Future<ApiSession?> apiSessionAsync() async {
    await _load();
    return _apiSession;
  }

  void setApiSession(ApiSession value) {
    if (_apiSession != value) {
      _apiSession = value;
      Future(() async {
        final toStore = SecureSettings._sessionToStorage(value);
        await _adapter.set<Map<String, dynamic>>('apiSession', toStore);
      });
    }
  }

  Future<void> setApiSessionAsync(ApiSession value) async {
    if (_apiSession != value) {
      _apiSession = value;
      final toStore = SecureSettings._sessionToStorage(value);
      await _adapter.set<Map<String, dynamic>>('apiSession', toStore);
    }
  }

  void removeApiSession() {
    if (_apiSession != null) {
      _apiSession = null;
      Future(() async {
        await _adapter.remove('apiSession');
      });
    }
  }

  Future<void> removeApiSessionAsync() async {
    if (_apiSession != null) {
      _apiSession = null;
      await _adapter.remove('apiSession');
    }
  }

  Future<bool> areBiometricsEnabledAsync() async {
    await _load();
    return _areBiometricsEnabled;
  }

  void setAreBiometricsEnabled(bool value) {
    if (_areBiometricsEnabled != value) {
      _areBiometricsEnabled = value;
      Future(() async {
        final toStore = value;
        await _adapter.set<bool>('areBiometricsEnabled', toStore);
      });
      _areBiometricsEnabledStreamController.add(value);
    }
  }

  Future<void> setAreBiometricsEnabledAsync(bool value) async {
    if (_areBiometricsEnabled != value) {
      _areBiometricsEnabled = value;
      final toStore = value;
      await _adapter.set<bool>('areBiometricsEnabled', toStore);
      _areBiometricsEnabledStreamController.add(value);
    }
  }

  void removeAreBiometricsEnabled() {
    if (_areBiometricsEnabled != false) {
      _areBiometricsEnabled = false;
      Future(() async {
        await _adapter.remove('areBiometricsEnabled');
      });
      _areBiometricsEnabledStreamController.add(false);
    }
  }

  Future<void> removeAreBiometricsEnabledAsync() async {
    if (_areBiometricsEnabled != false) {
      _areBiometricsEnabled = false;
      await _adapter.remove('areBiometricsEnabled');
      _areBiometricsEnabledStreamController.add(false);
    }
  }

  Stream<bool> get areBiometricsEnabledStream =>
      _areBiometricsEnabledStreamController.stream;
}

class _SecureSettings extends SecureSettings with _$SecureSettings {
  _SecureSettings(this._adapter)
    : super._(authToken: null, apiSession: null, areBiometricsEnabled: false) {
    _authToken = null;
    _apiSession = null;
    _areBiometricsEnabled = false;
    if (_authToken != null) _authTokenStreamController.add(_authToken!);
    _areBiometricsEnabledStreamController.add(_areBiometricsEnabled);
    _load();
  }

  @override
  final PrefsAdapter _adapter;

  @override
  String? _authToken;

  @override
  ApiSession? _apiSession;

  @override
  late bool _areBiometricsEnabled;

  @override
  final StreamController<String?> _authTokenStreamController =
      StreamController<String?>.broadcast();

  @override
  final StreamController<bool> _areBiometricsEnabledStreamController =
      StreamController<bool>.broadcast();
}
