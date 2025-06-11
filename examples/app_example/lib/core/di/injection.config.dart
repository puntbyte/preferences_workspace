// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:app_example/core/di/injection_module.dart' as _i106;
import 'package:app_example/data/preferences/regular_app_settings.dart'
    as _i725;
import 'package:app_example/data/preferences/secure_app_settings.dart'
    as _i1031;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:preferences_annotation/preferences_annotation.dart' as _i747;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final injectionModule = _$InjectionModule();
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => injectionModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => injectionModule.secureStorage,
    );
    gh.lazySingleton<_i747.PreferenceAdapter>(
      () => injectionModule.sharedAdapter(gh<_i460.SharedPreferences>()),
      instanceName: 'shared',
    );
    await gh.lazySingletonAsync<_i725.RegularAppSettings>(
      () => injectionModule.regularSettings(
        gh<_i747.PreferenceAdapter>(instanceName: 'shared'),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i747.PreferenceAdapter>(
      () => injectionModule.secureAdapter(gh<_i558.FlutterSecureStorage>()),
      instanceName: 'secure',
    );
    await gh.lazySingletonAsync<_i1031.SecureAppSettings>(
      () => injectionModule.secureSettings(
        gh<_i747.PreferenceAdapter>(instanceName: 'secure'),
      ),
      preResolve: true,
    );
    return this;
  }
}

class _$InjectionModule extends _i106.InjectionModule {}
