import 'dart:async';

import 'package:console_example/cli_config.dart';
import 'package:console_example/in_memory_adapter.dart';
import 'package:console_example/models/user.dart';

Future<void> main() async {
  print('--- Preferences Comprehensive Showcase ---');

  // 1. Setup
  final adapter = InMemoryAdapter();
  final config = CliConfig(adapter);
  final subscriptions = <StreamSubscription>[];

  // 2. Initial State (Defaults from Schema)
  print('\n--- 1. Initial State (Defaults) ---');
  print('Username: ${config.getUsernameSync}');
  print('Recent Searches: ${config.getRecentSearchesSync}');
  print('Timeout: ${config.getTimeoutDurationSync}');
  print('Creation Date (from initial fn): ${config.getCreationDateSync}');
  print('Primary Account: ${config.getPrimaryAccountSync}');

  // 3. Testing All Supported Types
  print('\n--- 2. Testing All Supported Types ---');
  await config.setThemeOpacityAsync(0.5);
  config.setSelectedItemIdSync(101);
  await config.setRecentSearchesAsync(['flutter', 'dart']);
  config.setFavoriteItemIdsSync({1, 2, 3});
  await config.setUserMetadataAsync({'tier': 'pro'});
  config.setTimeoutDurationSync(const Duration(minutes: 5));
  await config.setPrimaryAccountAsync((id: 'user-123', isPrimary: true));

  print('New Opacity: ${config.getThemeOpacitySync}');
  print('New Selected ID: ${config.getSelectedItemIdSync}');
  print('New Searches: ${await config.getRecentSearchesAsync()}');
  print('New Favorites: ${config.getFavoriteItemIdsSync}');
  print('New Metadata: ${await config.getUserMetadataAsync()}');
  print('New Timeout: ${config.getTimeoutDurationSync}');
  print('New Primary Account: ${config.getPrimaryAccountSync}');

  // 4. Testing Custom Serialization
  print('\n--- 3. Testing Custom Serialization ---');
  final devApi = Uri.parse('https://api.dev.example.com');
  final testUser = const User(id: 42, name: 'Test', email: 'test@example.com');
  await config.setApiEndpointAsync(devApi);
  config.setCurrentUserSync(testUser);

  print('API Endpoint (from converter): ${await config.getApiEndpointAsync()}');
  print('Current User (from to/fromStorage): ${config.getCurrentUserSync}');

  // 5. Testing @PrefEntry Features
  print('\n--- 4. Testing @PrefEntry Features ---');

  // a) Custom method name override
  print('Splash Screen Before: ${config.getShowSplashScreenSync}');
  config.toggleSplashScreen(false); // Using custom name
  print('Splash Screen After: ${config.getShowSplashScreenSync}');
  await config.resetSplashScreen; // Using custom remover name
  print('Splash Screen After Reset: ${config.getShowSplashScreenSync}');

  // b) Read-only field
  print('Build ID is: ${config.getBuildIdSync} (this field is read-only)');
  // The following would cause a compile-time error:
  // config.setBuildIdSync('new-id');

  // c) Custom stream name
  print('\n--- 5. Testing Custom Stream Name ---');
  final streamSub = config.splashScreenStateChanges.listen((state) {
    print('[STREAM UPDATE] Splash screen state is now: $state');
  });
  subscriptions.add(streamSub);
  await config.toggleSplashScreenAsync(false);
  await config.toggleSplashScreenAsync(true);

  // d) Notifiable override
  // This is a build-time feature. In a Flutter app, changes to `temporarySessionId`
  // would NOT call `notifyListeners()`, whereas changes to other fields would.

  // 6. Testing Module-Level Methods
  print('\n--- 6. Testing Module-Level Methods ---');
  await config.setLaunchCountAsync(99);
  print('Launch Count before clear: ${config.getLaunchCountSync}');
  await config.removeAll();
  print('Launch Count after clear: ${config.getLaunchCountSync} (reverted to default)');
  print('User after clear: ${config.getCurrentUserSync} (reverted to default)');

  // 7. Cleanup
  await Future.delayed(const Duration(milliseconds: 10)); // Allow streams to fire
  for (final sub in subscriptions) {
    sub.cancel();
  }
  config.dispose();
  print('\nDisposed stream controllers.');

  print('\n--- Showcase Finished ---');
}
