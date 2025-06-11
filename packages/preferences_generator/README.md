# preferences_generator

[![pub version][pub_badge]][pub_link]
[![style: lint][lint_badge]][lint_link]
[![License: MIT][license_badge]][license_link]

A powerful, type-safe code generation solution for creating preference and settings classes in
Dart & Flutter.

This package provides a clean, annotation-based API to eliminate boilerplate code for managing user
settings, allowing you to interact with `shared_preferences`, `flutter_secure_storage`, or any other
key-value store in a fully type-safe manner.

## Features

- ✅ **Type-Safe:** No more magic strings. Get compile-time safety for all your preference keys and
  types.
- 🧱 **Storage Agnostic:** Use `shared_preferences`, `flutter_secure_storage`, or a custom backend by
  implementing a simple `PreferenceAdapter`.
- ⚙️ **Boilerplate Reduction:** Define your preferences once in an abstract class and let the
  generator do the rest.
- 🎨 **Rich Type Support:** Out-of-the-box support for `int`, `String`, `double`, `bool`, `DateTime`,
  `Color`, `List`, `Map`, `Enum`, and `Record`.
- 🚀 **Developer Friendly:** Fails at build-time with clear, helpful errors for misconfigurations.

## Getting Started

Follow these steps to integrate the Preferences Suite into your project.

### 1. Installation

Add the necessary dependencies to your `pubspec.yaml` file. You will need the
`preferences_annotation` package as a regular dependency, and this package (`preferences_generator`)
along with `build_runner` as dev dependencies.

```yaml
dependencies:
  preferences_annotation: ^1.0.0

dev_dependencies:
  preferences_generator: ^1.0.0
  build_runner: ^2.4.15
```

### 2. Create Your Preference Module

Create an abstract class annotated with `@PreferenceModule`. This class must mix in the generated
`_$YourClassName` interface to inherit the generated method signatures.

**`lib/settings.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'my_preference_adapter.dart'; // We will create this in the next step

part 'settings.g.dart';

@PreferenceModule()
abstract class AppSettings with _$AppSettings {
  factory AppSettings(PreferenceAdapter adapter, {
    @PreferenceEntry(defaultValue: ThemeMode.system) 
    final ThemeMode themeMode,

    @PreferenceEntry() 
    final Color? accentColor,
  }) = _AppSettings;
  
  static Future<AppSettings> create(PreferenceAdapter adapter) async {
    final instance = _AppSettings(adapter);
    await instance._load();
    return instance;
  }
}
```

### 3. Implement a Preference Adapter

This library is backend-agnostic. You must provide an implementation of the `PreferenceAdapter`
interface that connects to your desired storage solution. Here is a starter example for
`shared_preferences`:

**`lib/my_preference_adapter.dart`**

```dart
import 'dart:convert';
import 'dart:ui';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPreferenceAdapter implements PreferenceAdapter {
  final SharedPreferences _prefs;

  const MyPreferenceAdapter(this._prefs);
  
  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
  
  @override
  Future<T> get<T>(String key) async {
    // ... (implementation of get)
  }

  // ... (full implementation of set, remove, etc.)
}
```

*(A complete implementation can be found in the example package of the project repository.)*

### 4. Run the Code Generator

Run the `build_runner` command in your terminal to generate the `settings.g.dart` part file.

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Use Your Preference Module

Instantiate and use your type-safe `AppSettings` class.

```dart
// Initialization
final adapter = MyPreferenceAdapter();

final appSettings = AppSettings(adapter);

// Usage
await appSettings.setThemeMode(ThemeMode.dark);
final currentTheme = appSettings.themeMode; // Access value synchronously
```

---

## Advanced Usage

### Building a Reactive UI with `ChangeNotifier`

For building UIs that react automatically to preference changes, you can mix in Flutter's
`ChangeNotifier`. The generator will detect this and automatically call `notifyListeners()` after a
preference is updated.

1. **Add the `ChangeNotifier` Mixin:**
   ```dart
   import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
   
   // ... other imports

   @PreferenceModule()
   abstract class AppSettings with _$AppSettings, ChangeNotifier { // Add ChangeNotifier
      // ... same factory constructor as before
   }
   ```

2. **Listen to Changes in Your UI:**
   You can now use a `ListenableBuilder` (or other state management solutions that work with
   `Listenable`) to rebuild only the widgets that depend on a specific preference. This is highly
   efficient.

   ```dart
   // In your UI widget
   
   // Get your settings instance (e.g., via a DI framework like get_it)
   final appSettings = getIt<AppSettings>();

   ListenableBuilder(
     listenable: appSettings,
     builder: (context, child) {
       // This Text widget will rebuild whenever any setting changes.
       return Text('Current theme is: ${appSettings.themeMode.name}');
     },
   )
   ```

## License

This project is licensed under the MIT License.

[pub_badge]: https://img.shields.io/pub/v/preferences_generator.svg

[pub_link]: https://pub.dev/packages/preferences_generator

[lint_badge]: https://img.shields.io/badge/style-lint-40c4ff.svg

[lint_link]: https://pub.dev/packages/lint

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg

[license_link]: https://opensource.org/licenses/MIT