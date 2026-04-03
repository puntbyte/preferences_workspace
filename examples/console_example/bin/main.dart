import 'dart:async';

import 'package:console_example/cli_config.dart';
import 'package:console_example/in_memory_adapter.dart';
import 'package:console_example/models/user.dart';

Future<void> main() async {
  print('=== Preferences Generator — Comprehensive Showcase ===\n');

  final adapter = InMemoryAdapter();
  final config = CliConfig(adapter);

  // -------------------------------------------------------------------------
  // 1. STREAMS — subscribe before any setter so we can see them fire.
  //
  //    The .exhaustive() preset uses 'watch{{Name}}Stream' for all streamers.
  //    Each subscription proves the stream is live — events arrive both when:
  //      a) a setter is called (immediate), and
  //      b) _load() finds a changed value from storage (on refresh()).
  // -------------------------------------------------------------------------
  print('--- 1. Stream Subscriptions ---');
  print('Subscribing to streams before any setter calls...\n');

  final subs = <StreamSubscription>[];

  subs.add(
    config.watchUsernameStream.listen(
          (v) => print('[STREAM] watchUsernameStream         → "$v"'),
    ),
  );
  subs.add(
    config.showSplashScreenStateChanges.listen(
      // Note: 'show_splash_screen' is the storage key (KeyCase.snake).
      // Stream name is showSplashScreenStateChanges from @PrefEntry(streamer:)
          (v) => print('[STREAM] showSplashScreenStateChanges → $v'),
    ),
  );
  subs.add(
    config.watchLaunchCountStream.listen(
          (v) => print('[STREAM] watchLaunchCountStream       → $v'),
    ),
  );

  // -------------------------------------------------------------------------
  // 2. INITIAL STATE — defaults from schema constructor.
  // -------------------------------------------------------------------------
  print('\n--- 2. Initial State (Defaults) ---');
  print('username:        ${config.getUsernameSync}');
  print('themeOpacity:    ${config.getThemeOpacitySync}');
  print('recentSearches:  ${config.getRecentSearchesSync}');
  print('timeoutDuration: ${config.getTimeoutDurationSync}');
  print('logLevel:        ${config.getLogLevelSync}');
  print('primaryAccount:  ${config.getPrimaryAccountSync}');
  print('creationDate:    ${config.getCreationDateSync}');
  print('showSplashScreen:${config.getShowSplashScreenSync}');
  print('buildId:         ${config.getBuildIdSync}  (read-only)');

  // -------------------------------------------------------------------------
  // 3. SETTERS — sync and async variants.
  //    Streams fire immediately on each setter call.
  // -------------------------------------------------------------------------
  print('\n--- 3. Setters (sync and async) ---');

  // Sync setter — fires watchUsernameStream immediately.
  config.setUsernameSync('alice');
  print('setUsernameSync("alice")');

  // Async setter.
  await config.setThemeOpacityAsync(0.75);
  print('setThemeOpacityAsync(0.75)');

  // Custom setter name via @PrefEntry(setter: 'toggle{{Name}}').
  config.toggleShowSplashScreen(false);
  print('toggleShowSplashScreen(false)  [custom setter name via template]');

  // Async variant of the custom setter.
  await config.toggleShowSplashScreenAsync(true);
  print('toggleShowSplashScreenAsync(true)');

  // Allow fire-and-forget writes to complete.
  await Future.delayed(const Duration(milliseconds: 20));

  // -------------------------------------------------------------------------
  // 4. ALL SUPPORTED TYPES
  // -------------------------------------------------------------------------
  print('\n--- 4. All Supported Types ---');

  config.setSelectedItemIdSync(42);
  await config.setRecentSearchesAsync(['flutter', 'dart', 'preferences']);
  config.setFavoriteItemIdsSync({10, 20, 30});
  await config.setUserMetadataAsync({'plan': 'pro', 'region': 'sg'});
  config.setTimeoutDurationSync(const Duration(minutes: 10));
  await config.setPrimaryAccountAsync((id: 'usr-999', isPrimary: true));
  config.setCursorPositionSync((42, 100));
  await config.setLogLevelAsync(LogLevel.debug);

  print('selectedItemId:  ${config.getSelectedItemIdSync}');
  print('recentSearches:  ${await config.getRecentSearchesAsync()}');
  print('favoriteItemIds: ${config.getFavoriteItemIdsSync}');
  print('userMetadata:    ${await config.getUserMetadataAsync()}');
  print('timeoutDuration: ${config.getTimeoutDurationSync}');
  print('primaryAccount:  ${config.getPrimaryAccountSync}');
  print('cursorPosition:  ${config.getCursorPositionSync}');
  print('logLevel:        ${config.getLogLevelSync}');

  // -------------------------------------------------------------------------
  // 5. CUSTOM SERIALIZATION
  // -------------------------------------------------------------------------
  print('\n--- 5. Custom Serialization ---');

  // PrefConverter (UriConverter).
  final devApi = Uri.parse('https://api.dev.example.com/v3');
  await config.setApiEndpointAsync(devApi);
  print('apiEndpoint (PrefConverter): ${await config.getApiEndpointAsync()}');

  // Inline toStorage / fromStorage functions.
  const testUser = User(id: 7, name: 'Bob', email: 'bob@example.com');
  config.setCurrentUserSync(testUser);
  print('currentUser (toStorage/fromStorage): ${config.getCurrentUserSync}');

  // Non-constant default via @PrefEntry(initial: _getCreationDate).
  print('creationDate (initial fn): ${config.getCreationDateSync}');

  // -------------------------------------------------------------------------
  // 6. @PrefEntry FEATURE SHOWCASE
  // -------------------------------------------------------------------------
  print('\n--- 6. @PrefEntry Features ---');

  // a) Custom setter name template: @PrefEntry(setter: 'toggle{{Name}}')
  print('showSplashScreen before toggle: ${config.getShowSplashScreenSync}');
  config.toggleShowSplashScreen(false);
  print('after toggleShowSplashScreen(false): ${config.getShowSplashScreenSync}');

  // b) Custom remover name: @PrefEntry(remover: 'reset{{Name}}') — not in
  //    the current schema so use the generated removeShowSplashScreenSync.
  config.removeShowSplashScreenSync();
  print('after removeShowSplashScreenSync(): ${config.getShowSplashScreenSync}');

  // c) Read-only field — no setter or remover generated.
  //    Attempting config.setBuildIdSync('x') would be a compile error.
  print('buildId (readOnly): ${config.getBuildIdSync}');

  // d) notifiable: false override.
  //    temporarySessionId changes never call notifyListeners()
  //    (irrelevant in console context but demonstrated for correctness).
  config.setTemporarySessionIdSync('sess_tmp_abc');
  print('temporarySessionId (notifiable:false): ${config.getTemporarySessionIdSync}');

  // e) Custom key: @PrefEntry(key: 'total_launches')
  await config.setLaunchCountAsync(5);
  print('launchCount (key="total_launches"): ${config.getLaunchCountSync}');

  // -------------------------------------------------------------------------
  // 7. STREAMS — demonstrate refresh() fires streams from storage
  // -------------------------------------------------------------------------
  print('\n--- 7. Streams: refresh() fires streams from storage ---');

  // Write directly to storage (simulating another isolate or cold start).
  await adapter.set('username', 'charlie');
  await adapter.set('total_launches', 99);

  print('Wrote "charlie" and 99 to storage directly.');
  print('Calling refresh()...');

  // refresh() resets _isLoaded, re-reads storage, and pushes changed values
  // to stream controllers — streams fire without any explicit setter call.
  await config.refresh();

  await Future.delayed(const Duration(milliseconds: 10));
  print('username after refresh: ${config.getUsernameSync}  (updated from storage)');
  print('launchCount after refresh: ${config.getLaunchCountSync}  (updated from storage)');

  // -------------------------------------------------------------------------
  // 8. MODULE-LEVEL METHODS
  // -------------------------------------------------------------------------
  print('\n--- 8. Module-Level Methods ---');

  print('launchCount before removeAll: ${config.getLaunchCountSync}');
  await config.removeAll();
  // removeAll() clears storage, resets _isLoaded, re-reads → streams fire with defaults.
  await Future.delayed(const Duration(milliseconds: 10));
  print('launchCount after removeAll:  ${config.getLaunchCountSync}  (default)');
  print('username after removeAll:     ${config.getUsernameSync}  (default)');

  // -------------------------------------------------------------------------
  // 9. CLEANUP
  // -------------------------------------------------------------------------
  print('\n--- 9. Cleanup ---');
  await Future.delayed(const Duration(milliseconds: 10));
  for (final sub in subs) {
    await sub.cancel();
  }
  config.dispose();
  print('Stream controllers disposed.');

  print('\n=== Showcase Complete ===');
}