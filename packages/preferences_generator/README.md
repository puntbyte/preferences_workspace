# Preferences Generator

[![pub version][pub_badge]][pub_link]
[![style: lint][lint_badge]][lint_link]
[![License: MIT][license_badge]][license_link]

A powerful, type-safe code generation suite for managing user settings and application state in 
Dart and Flutter.

This package provides a clean, annotation-based API to eliminate boilerplate for managing user 
settings, allowing you to interact with `shared_preferences`, Hive, or any key-value store in a 
fully type-safe and conventional way.

## ✨ Key Features

- ✅ **Type-Safe:** No more magic strings. Get compile-time safety for all your preference keys, 
types, and method calls.
- 🧱 **Storage Agnostic:** The adapter interface is incredibly simple and only deals with primitive 
types. The generator handles the rest.
- ⚙️ **Automatic Serialization:** Forget manual data conversions. The generator automatically 
handles `DateTime`, `Duration`, `Enum`, `Record`, and even your custom classes.
- 🚀 **Powerful Configuration:** Start with presets like `.dictionary()` or `.reactive()`, then 
fine-tune every method name, key casing, and behavior.
- 🌊 **Reactive Ready:** Automatically generate `Stream`s for any preference and integrate 
seamlessly with `ChangeNotifier` to build reactive UIs.
- 🔧 **Project-Wide Conventions:** Define global settings, like `snake_case` keys, in your 
project's `build.yaml`.
- 🎯 **Rich Type Support:** Out-of-the-box support for `int`, `String`, `double`, `bool`, `List`, 
`Set`, `Map`, `Enum`, `DateTime`, `Duration`, and `Record`.

## 🚀 Getting Started

### 1. Installation

Add the necessary dependencies to your `pubspec.yaml`.

```yaml
dependencies:
  # The annotation package
  preferences_annotation: ^2.0.0

dev_dependencies:
  # The generator
  preferences_generator: ^2.0.0
  # The build tool
  build_runner: ^2.6.0
```

### 2. Define Your Preference Schema

Create an abstract class that defines your preferences. The schema is now defined in a simple, 
private constructor.

**`lib/settings.dart`**
```dart
import 'package:preferences_annotation/preferences_annotation.dart';

part 'settings.prefs.dart'; // Note the new .prefs.dart extension

enum AppTheme { light, dark, system }

// Use a preset to define the generated API.
// .dictionary() is great for key-value stores like shared_preferences.
@PrefsModule.dictionary()
abstract class AppSettings with _$AppSettings {
  // A public factory connects to the generated implementation.
  factory AppSettings(PrefsAdapter adapter) = _AppSettings;

  // The private constructor defines the preference schema.
  AppSettings._({
    String username = 'guest',
    DateTime? lastLogin,
    AppTheme theme = AppTheme.system,
    
    @PrefEntry(key: 'launch_counter')
    int launchCount = 0,
  });
}
```

### 3. Implement the `PrefsAdapter`

The v2.0 adapter is much simpler. It only needs to handle primitive types. The generator handles 
all complex conversions for you.

**`lib/in_memory_adapter.dart`**
```dart
import 'package:preferences_annotation/preferences_annotation.dart';

/// A simple adapter that holds values in a map.
class InMemoryAdapter implements PrefsAdapter {
  final Map<String, dynamic> _storage = {};

  @override
  Future<T?> get<T>(String key) async => _storage[key] as T?;

  @override
  Future<void> set<T>(String key, T value) async => _storage[key] = value;

  @override
  Future<void> remove(String key) async => _storage.remove(key);

  @override
  Future<void> removeAll() async => _storage.clear();
}
```

### 4. Run the Code Generator

Run `build_runner` to generate the `settings.prefs.dart` part file.

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Use Your Preference Module

Instantiate and use your fully type-safe `AppSettings` class.

```dart
final settings = AppSettings(InMemoryAdapter());

// Getters are synchronous in the .dictionary() preset
print('Current theme: ${settings.getTheme().name}');
  
// Setters are asynchronous
await settings.setUsername('Alice');
print('New username: ${settings.getUsername()}');
```

## 🛠️ Configuration in Depth

While presets cover most use cases, you have full control over the generated code.

### 1. `@PrefsModule` Presets

Presets are the fastest way to configure your module's API. Choose one that best matches your 
storage backend.

| Preset          | 💡 Use Case                                          | Generated Methods Example (`username`)                                    |
|-----------------|------------------------------------------------------|---------------------------------------------------------------------------|
| `.dictionary()` | **Recommended Default.** For `shared_preferences`.   | `getUsername()`, `setUsername(value)` (async), `removeUsername()` (async) |
| `.reactive()`   | For building reactive UIs with `Stream`s.            | `username` (getter), `setUsername(value)`, `usernameStream` (getter)      |
| `.syncOnly()`   | For fully synchronous backends like Hive.            | `getUsername()`, `putUsername(value)`, `deleteUsername()`                 |
| `.syncFirst()`  | A flexible default with both sync and async methods. | `username` (getter), `setUsername(value)`, `usernameAsync` (getter)       |

### 2. Customizing the Entire Module

#### Storage Key Casing (`keyCase`)

Define a consistent naming convention for your storage keys. The precedence is: 
`@PrefEntry(key:...)` > `@PrefsModule(keyCase:...)` > `build.yaml`.

> **Globally (in `build.yaml`):**
>
> ```yaml
> # your_project/build.yaml
> targets:
>   $default:
>     builders:
>       preferences_generator|preferences:
>         options:
>           key_case: snake # All keys will be snake_case
> ```

> **Per-Module (in your Dart file):**
>
> ```dart
> // Overrides the global setting for just this module.
> @PrefsModule(keyCase: KeyCase.kebab)
> abstract class ApiSettings with _$ApiSettings {
>   ApiSettings._({
>     // Generates storage key: 'api-url'
>     String apiUrl = '',
>   });
> }
> ```

#### Customizing Generated Methods

You can configure the generation of seven different types of methods on a per-module basis. The 
`AffixConfig` class allows you to set a `prefix`, `suffix`, or `enabled` status.

| Method Type   | `@PrefsModule` Property | Default Behavior (`username`)              |
|---------------|-------------------------|--------------------------------------------|
| Sync Getter   | `getter`                | Enabled. `username` (direct getter access) |
| Sync Setter   | `setter`                | Enabled. `setUsername(value)`              |
| Sync Remover  | `remover`               | Enabled. `removeUsername()`                |
| Async Getter  | `asyncGetter`           | Enabled. `usernameAsync`                   |
| Async Setter  | `asyncSetter`           | Enabled. `setUsernameAsync(value)`         |
| Async Remover | `asyncRemover`          | Enabled. `removeUsernameAsync()`           |
| Stream Getter | `streamer`              | Disabled. `usernameStream`                 |

**Example:**

```dart
@PrefsModule(
  // Change sync setters to use a 'put' prefix
  setter: AffixConfig(prefix: 'put'),
  // Change removers to use a 'delete' prefix
  remover: AffixConfig(prefix: 'delete'),
  // Disable all async getters module-wide
  asyncGetter: AffixConfig(enabled: false),
)
abstract class MySettings with _$MySettings {
  MySettings._({String username = ''});
// Generates: username (getter), putUsername(), deleteUsername()
}
```

### 3. Customizing a Single Preference (`@PrefEntry`)

For ultimate control, every module-level setting can be overridden for a single preference.

#### Overriding Method Names and Behavior

Use `CustomConfig` to change a method's name, its affixes, or disable it entirely.

```dart
@PrefsModule.dictionary()
abstract class GameSettings with _$GameSettings {
  GameSettings._({
    @PrefEntry(
      // Override the default 'setShowSplashScreen' with a better name.
      setter: CustomConfig(name: 'toggleSplashScreen'),
      // Disable the async remover for just this entry.
      asyncRemover: CustomConfig(enabled: false),
    )
    bool showSplashScreen = true,
  });
  // Generates: getShowSplashScreen(), toggleSplashScreen(value)
}
```

#### Default vs. Initial Values

- **Compile-Time Default (Recommended):** Use a standard Dart default value for `const` values.
    ```dart
    AppSettings._({
      String username = 'guest', // `guest` is a compile-time constant.
    });
    ```

- **Runtime Initial Value:** Use the `initial` property for defaults that can't be `const`, like 
`DateTime.now()`.
    ```dart
    abstract class UserProfile with _$UserProfile {
      UserProfile._({
        @PrefEntry(initial: _getCreationDate)
        DateTime creationDate,
      });
      static DateTime _getCreationDate() => DateTime.now();
    }
    ```

### 4. Reactive Features

#### Generating Streams

To listen to changes for a specific preference, enable its stream. The `.reactive()` preset does 
this for all entries, but you can also do it manually.

```dart
@PrefsModule.dictionary(
  // Enable streams for all entries in this module.
  streamer: AffixConfig(suffix: 'Stream'),
)
abstract class AppSettings with _$AppSettings {
  AppSettings._({String username = ''});
  // Generates a `usernameStream` getter that returns a Stream<String>.
}
```

#### ChangeNotifier Integration

If your class mixes in `ChangeNotifier`, the generator will automatically call `notifyListeners()` 
for you. You can control this behavior with the `notifiable` flag.

```dart
import 'package:flutter/foundation.dart';

@PrefsModule.reactive(notifiable: true) // All changes will notify listeners by default
abstract class AppSettings with _$AppSettings, ChangeNotifier {
  AppSettings._({
    String username = '', // Changes to this WILL call notifyListeners().

    @PrefEntry(notifiable: false) // Override for this specific preference
    String sessionId = '', // Changes to this WILL NOT call notifyListeners().
  });
}
```

## 📜 Migration Guide: v1.x -> v2.0.0

Version 2.0.0 is a major release. Follow these steps to migrate.

#### 1. Update Dependencies
In `pubspec.yaml`, update the package versions to `^2.0.0`.

#### 2. Refactor `PreferenceAdapter` to `PrefsAdapter`
- Rename the interface from `PreferenceAdapter` to `PrefsAdapter`.
- **Remove all manual serialization logic** (like `jsonEncode`, `DateTime.toIso8601String`, etc.) 
from your adapter. The generator now does this automatically.
- Rename the `clear()` method to `removeAll()`.
- Remove the `containsKey()` method.

#### 3. Refactor Your Schema Class
- Rename `@PreferenceModule` to `@PrefsModule` and choose a preset (e.g., 
`@PrefsModule.dictionary()`).
- Define a **private generative constructor** (`AppSettings._({...})`) for the schema.
- Move parameters from the old factory to this new constructor.
- Replace `@PreferenceEntry(defaultValue: ...)` with standard Dart default values 
(`AppTheme theme = AppTheme.system`).

#### 4. Update Usage & `part` Directives
- The default generated file extension has changed to **`.prefs.dart`**. You must update all `part` 
directives.
  - **Before:** `part 'settings.g.dart';`
  - **After:** `part 'settings.prefs.dart';`
- Generated method names are now more explicit (e.g., `theme` -> `getTheme()`, `setTheme()`). Review
your generated `.prefs.dart` file for the new names.

## License

This project is licensed under the [MIT License][license_link].

[pub_badge]: https://img.shields.io/pub/v/preferences_generator.svg
[pub_link]: https://pub.dev/packages/preferences_generator
[lint_badge]: https://img.shields.io/badge/style-lint-40c4ff.svg
[lint_link]: https://pub.dev/packages/lint
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT