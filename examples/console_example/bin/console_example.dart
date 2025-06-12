import 'app_preferences.dart';
import 'in_memory_adapter.dart';

// The generated file will create the _AppPreferences class and _load method.

Future<void> main(List<String> arguments) async {
  print('--- Preferences Console Example ---');

  // 1. Create the adapter and the preferences instance.
  final adapter = InMemoryAdapter();
  // The generated `_AppPreferences` is a concrete class we can instantiate.
  final prefs = AppPreferences(adapter);

  // 2. Manually load initial values (important step!)
  // In a real app, this would happen at startup.
  await prefs.reload();

  // 3. Print initial default values
  print('\n--- Initial State ---');
  print('Username: ${prefs.username}'); // Should be 'Guest'
  print('Launch Count: ${prefs.launchCount}'); // Should be 0
  print('Log Level: ${prefs.logLevel}'); // Should be LogLevel.info
  print('Last Login: ${prefs.lastLogin}'); // Should be null

  // 4. Set new values
  print('\n--- Setting New Values ---');
  await prefs.setUsername('Alice');
  await prefs.setLaunchCount(prefs.launchCount + 1);
  await prefs.setLogLevel(LogLevel.verbose);
  await prefs.setLastLogin(DateTime.now());

  // 5. Print the updated values
  print('\n--- Updated State ---');
  print('Username: ${prefs.username}');
  print('Launch Count: ${prefs.launchCount}');
  print('Log Level: ${prefs.logLevel}');
  print('Last Login: ${prefs.lastLogin?.toIso8601String()}');

  // 6. Demonstrate removing a value
  print('\n--- Removing a Value ---');
  await prefs.removeUsername();
  print('Username after remove: ${prefs.username}'); // Should revert to 'Guest'

  // 7. Demonstrate clearing all values
  print('\n--- Clearing All Values ---');
  await prefs.clear();
  print('Username after clear: ${prefs.username}'); // Should be 'Guest'
  print('Launch Count after clear: ${prefs.launchCount}'); // Should be 0

  print('\n--- Example Finished ---');
}
