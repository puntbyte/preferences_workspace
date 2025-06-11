import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/adapters/secure_storage_adapter.dart';
import '../../data/adapters/shared_preferences_adapter.dart';
import '../../data/preferences/regular_app_settings.dart';
import '../../data/preferences/secure_app_settings.dart';

@module
abstract class InjectionModule {
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @Named('shared')
  @lazySingleton
  PreferenceAdapter sharedAdapter(SharedPreferences prefs) => SharedPreferencesAdapter(prefs);

  @Named('secure')
  @lazySingleton
  PreferenceAdapter secureAdapter(FlutterSecureStorage storage) => SecureStorageAdapter(storage);

  @preResolve
  @lazySingleton
  Future<RegularAppSettings> regularSettings(
    @Named('shared')
    PreferenceAdapter adapter,
  ) => RegularAppSettings.create(adapter);

  @preResolve
  @lazySingleton
  Future<SecureAppSettings> secureSettings(
    @Named('secure')
    PreferenceAdapter adapter,
  ) => SecureAppSettings.create(adapter);
}
