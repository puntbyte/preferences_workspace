# Preferences Generator

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
- 🧱 **Storage Agnostic:** Use any key-value store by implementing a simple `PreferenceAdapter`.
- ⚙️ **Boilerplate Reduction:** Define your preferences once in an abstract class and let the
  generator do the rest.
- 🎯 **Rich Type Support:** Out-of-the-box support for `int`, `String`, `double`, `bool`, `DateTime`,
  `Duration`, `List`, `Set`, `Map`, `Enum`, and `Record`.
- 🚀 **Developer Friendly:** Fails at build-time with clear, helpful errors for misconfigurations.

## Getting Started

Follow these steps to integrate the Preferences Suite into your project.

### 1. Installation

Add the necessary dependencies to your `pubspec.yaml` file. You will need `preferences_annotation`
as a regular dependency, and this package (`preferences_generator`) along with `build_runner` as dev
dependencies.

**`pubspec.yaml`**

```yaml
dependencies:
  preferences_annotation: ^1.0.1

dev_dependencies:
  preferences_generator: ^1.1.0
  build_runner: ^2.4.11
```

### 2. Create Your Preference Module

Create an abstract class annotated with `@PreferenceModule`. This class defines a group of related
settings.

**`lib/settings.dart`**

```dart
import 'package:preferences_annotation/preferences_annotation.dart';
import 'in_memory_adapter.dart'; // We will create this in the next step

part 'settings.g.dart';

@PreferenceModule()
abstract class AppSettings with _$AppSettings {
  factory AppSettings(PreferenceAdapter adapter, {
    // A non-nullable enum with a required default value.
    @PreferenceEntry(defaultValue: AppTheme.system) 
    AppTheme theme,

    // A nullable Duration. No default value is needed.
    @PreferenceEntry() 
    Duration? sessionTimeout,
  }) = _AppSettings;

  // Optional async constructor for preloading preferences.
  static Future<AppSettings> create(PreferenceAdapter adapter) async {
    final instance = _AppSettings(adapter);
    await instance._load();
    return instance;
  }
}
```

### 3. Implement a Preference Adapter

You must provide an implementation of the `PreferenceAdapter` interface that connects to your
storage backend. Here is a lightweight, fully-functional example using a simple in-memory `Map`.
This is great for testing or simple use cases.

**`lib/im_memory_adapter.dart`**

```dart
import 'dart:convert';
import 'package:preferences_annotation/preferences_annotation.dart';

class InMemoryAdapter implements PreferenceAdapter {
  final Map<String, dynamic> _map = {};

  @override
  Future<void> clear() async => _map.clear();

  @override
  Future<bool> containsKey(String key) async => _map.containsKey(key);

  @override
  Future<void> remove(String key) async => _map.remove(key);

  @override
  Future<T?> get<T>(String key) async {
    final value = _map[key];
    if (value == null) return null;

    // The generator asks for the storable type (e.g., int for Duration).
    // The adapter must convert it back to the rich type.
    if (T == Duration && value is int) {
      return Duration(microseconds: value) as T?;
    }
    // The generator handles Enum/Record deserialization before this call.
    // For other types like List/Set/Map, they are stored as JSON strings.
    if (T == List || T == Set || T == Map) {
      try {
        final decoded = jsonDecode(value as String);
        if (T == Set && decoded is List) return decoded.toSet() as T?;
        return decoded as T?;
      } catch (_) {
        return null;
      }
    }
    // For primitives, the type should match directly.
    if (value is T) return value;

    return null;
  }

  @override
  Future<void> set<T>(String key, T value) async {
    if (value == null) {
      await remove(key);
      return;
    }

    // The generator provides the storable type. The adapter must handle it.
    // For enums (String) and records (Map), they fall into the final else block.
    if (value is int || value is double || value is bool || value is String) {
      _map[key] = value;
    } else if (value is DateTime) {
      // Not a storable type, so we must convert it.
      _map[key] = value.toIso8601String();
    } else if (value is List || value is Set || value is Map) {
      // Convert collections to a JSON string for storage.
      _map[key] = jsonEncode(value);
    } else {
      throw ArgumentError('InMemoryAdapter does not support type ${value.runtimeType}');
    }
  }
}
```

*(For `shared_preferences` and `flutter_secure_storage` implementation, see the examples 
in the [project repository][examples_link].)*

### 4. Run the Code Generator

Run `build_runner` in your terminal to generate the `settings.g.dart` part file.

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Use Your Preference Module

Instantiate and use your type-safe `AppSettings` class.

**`lib/main.dart`**

```dart

import 'settings.dart';
import 'in_memory_adapter.dart';

Future<void> main() async {
  final adapter = InMemoryAdapter();
  final appSettings = AppSettings.create(adapter);

  // Set a preference
  await appSettings.setTheme(AppTheme.dark);

  // Get a preference
  final theme = appSettings.theme;
  print('Current theme: ${theme.name}');

  // Set nullable value
  await appSettings.setSessionTimeout(Duration(minutes: 15));
  print('Session timeout: ${appSettings.sessionTimeout?.inMinutes} minutes');

  // Remove a preference
  await appSettings.removeSessionTimeout();
  print('Session timeout after removal: ${appSettings.sessionTimeout}');
}

```

## Reactive UI with `ChangeNotifier`

To build UIs that automatically react to preference changes, mix in Flutter's `ChangeNotifier`. The
generator detects this and calls `notifyListeners()` for you.

1. **Add the `ChangeNotifier` Mixin:**
   ```dart
   import 'package:flutter/foundation.dart';
   
   @PreferenceModule()
   abstract class AppSettings with _$AppSettings, ChangeNotifier { // Add mixin
      // ... same factory constructor as before
   }
   ```

2. **Listen to Changes in Your UI:**
   Use a `ListenableBuilder` to efficiently rebuild only the widgets that depend on a specific
   preference.

   ```dart
   // Get your settings instance (e.g., from a DI container)
   final appSettings = getIt<AppSettings>();

   ListenableBuilder(
     listenable: appSettings,
     builder: (context, child) {
       // This Text widget will rebuild whenever any setting changes.
       return Text('Current theme is: ${appSettings.theme.name}');
     },
   )
   ```

## License

This project is licensed under the [MIT License][license_link].

[pub_badge]: https://img.shields.io/pub/v/preferences_generator.svg

[pub_link]: https://pub.dev/packages/preferences_generator

[lint_badge]: https://img.shields.io/badge/style-lint-40c4ff.svg

[lint_link]: https://pub.dev/packages/lint

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg

[license_link]: https://opensource.org/licenses/MIT

[examples_link]: ../../examples