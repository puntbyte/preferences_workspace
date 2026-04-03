import 'package:app_example/preferences/app_settings.dart';
import 'package:app_example/preferences/secure_settings.dart';
import 'package:app_example/services/secure_storage_adapter.dart';
import 'package:app_example/services/shared_prefs_adapter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds and initialises both settings singletons.
/// Call [init] once at startup before [runApp].
class AppSettingsService {
  late final AppSettings regular;
  late final SecureSettings secure;

  Future<void> init() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    regular = AppSettings(SharedPreferencesAdapter(sharedPrefs));

    const secureStorage = FlutterSecureStorage();
    secure = SecureSettings(SecureStorageAdapter(secureStorage));

    // refresh() forces a storage read and pushes loaded values to streams —
    // this is what makes StreamBuilders show the persisted data on first render.
    await regular.refresh();
    await secure.refresh();
  }
}

/// Global singleton.
final appSettings = AppSettingsService();