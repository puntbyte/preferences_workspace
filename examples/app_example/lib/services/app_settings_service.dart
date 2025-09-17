import 'package:app_example/preferences/app_settings.dart';
import 'package:app_example/preferences/secure_settings.dart';
import 'package:app_example/services/secure_storage_adapter.dart';
import 'package:app_example/services/shared_prefs_adapter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A simple service locator to hold and initialize our settings singletons.
class AppSettingsService {
  late final AppSettings regular;
  late final SecureSettings secure;

  /// Initializes both settings modules. Must be called once at startup.
  Future<void> init() async {
    // Create the adapter for regular SharedPreferences.
    final sharedPrefs = await SharedPreferences.getInstance();
    final sharedAdapter = SharedPreferencesAdapter(sharedPrefs);

    // Create the adapter for secure, encrypted storage.
    const secureStorage = FlutterSecureStorage();
    final secureAdapter = SecureStorageAdapter(secureStorage);

    // Instantiate and load our settings modules.
    regular = AppSettings(sharedAdapter);
    secure = SecureSettings(secureAdapter);

    // It's good practice to load the initial values from storage.
    await regular.refresh();
    await secure.refresh();
  }
}

/// Global singleton instance of our settings service.
final appSettings = AppSettingsService();
