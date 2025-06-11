# preferences_generator

A powerful, type-safe code generator for creating preference and settings classes in Dart & Flutter.

This package is the core build-time tool of the **[Preferences Workspace](https://github.com/your-repo/preferences_workspace)**. It processes classes annotated with `@PreferenceModule` and generates fully implemented, boilerplate-free preference management code.

## Features

- ✅ **Type-Safe:** No more magic strings. Get compile-time safety for all your preference keys and types.
- 🧱 **Storage Agnostic:** Use `shared_preferences`, `flutter_secure_storage`, or any other key-value store by implementing a simple `PreferenceAdapter`.
- ⚙️ **Boilerplate Reduction:** Define your preferences once in an abstract class and let the generator do the rest.
- 🎨 **Rich Type Support:** Out-of-the-box support for `int`, `String`, `double`, `bool`, `DateTime`, `Color`, `List`, `Map`, `Enum`, and `Record`.
- 🚀 **Developer Friendly:** Fails at build-time with clear, helpful errors for misconfigurations.

## Getting Started

Follow these steps to integrate the Preferences Suite into your project.

### 1. Installation

Add `preferences_annotation` as a regular dependency, and this package (`preferences_generator`) along with `build_runner` as dev dependencies.

```yaml
# In your app's pubspec.yaml
dependencies:
  preferences_annotation: ^0.1.0

dev_dependencies:
  preferences_generator: ^0.1.0
  build_runner: ^2.4.11
```

### 2. Create Your Preference Module

Create an abstract class annotated with `@PreferenceModule`. This file will be the single source of truth for a related group of preferences.

**`lib/settings.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'my_preference_adapter.dart'; // Your implementation of PreferenceAdapter

part 'settings.g.dart';

@PreferenceModule()
abstract class AppSettings {
  factory AppSettings(
    PreferenceAdapter adapter, {
    // A non-nullable enum with a required default value.
    @PreferenceEntry(defaultValue: ThemeMode.system)
    final ThemeMode themeMode,

    // A nullable Color. No default value is needed.
    @PreferenceEntry()
    final Color? accentColor,

    // A non-nullable record with a default value.
    @PreferenceEntry(defaultValue: (x: 0, y: 0))
    final ({int x, int y}) windowPosition,
    
  }) = _AppSettings;
}
```

### 3. Implement a Preference Adapter

This library is backend-agnostic. You must provide an implementation of the `PreferenceAdapter` interface from `preferences_annotation` that connects to your desired storage solution.

Here is a minimal example for `shared_preferences`:

**`lib/my_preference_adapter.dart`**
```dart
import 'dart:convert';
import 'dart:ui';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPreferenceAdapter implements PreferenceAdapter {
  final SharedPreferences _prefs;
  MyPreferenceAdapter(this._prefs);

  static Future<MyPreferenceAdapter> getInstance() async {
    return MyPreferenceAdapter(await SharedPreferences.getInstance());
  }

  @override
  Future<T?> get<T>(String key) async {
    // ... implementation ...
  }

  @override
  Future<void> set<T>(String key, T value) async {
    // ... implementation ...
  }
  
  // ... other methods
}
```
*A complete, robust implementation can be found in the [example application](https://github.com/your-repo/preferences_workspace/blob/main/packages/app_example/lib/data/adapters/shared_preferences_adapter.dart) in our GitHub repository.*

### 4. Run the Code Generator

Run the `build_runner` command in your terminal to generate the `settings.g.dart` part file.

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Use Your Preference Module

Instantiate and use your type-safe `AppSettings` class.

```dart
// Initialization
final adapter = await MyPreferenceAdapter.getInstance();
final appSettings = AppSettings(adapter);

// Usage
await appSettings.setThemeMode(ThemeMode.dark);
final currentTheme = appSettings.themeMode; // Access value synchronously
print('Current theme is $currentTheme');
```