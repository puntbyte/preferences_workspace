# Preferences Generator

[![pub version][pub_badge]][pub_link]
[![style: lint][lint_badge]][lint_link]
[![License: MIT][license_badge]][license_link]

A powerful, type-safe code generation solution for creating preference and settings classes in Dart 
& Flutter.

This package provides a clean, annotation-based API to eliminate boilerplate code for managing user 
settings, allowing you to interact with `shared_preferences`, `flutter_secure_storage`, Hive, or 
any other key-value store in a fully type-safe and conventional way.

## Features

- ✅ **Type-Safe:** No more magic strings. Get compile-time safety for all your preference keys, 
types, and method calls.
- 🧱 **Storage Agnostic:** The adapter interface is incredibly simple and only deals with primitive 
types. The generator handles the rest.
- ⚙️ **Automatic Serialization:** No more manual `jsonEncode` or type conversions in your adapter. 
The generator automatically handles `DateTime`, `Duration`, `Enum`, `Record`, and even your custom 
classes.
- 🚀 **Highly Configurable:** Use presets like `.dictionary()`, `.syncOnly()`, or `.reactive()` to 
match your storage backend's API, or fine-tune every method name.
- 🌊 **Reactive Ready:** Automatically generate `Stream`s for any preference to easily build 
reactive UIs.
- 🔧 **Global Configuration:** Use `build.yaml` to define project-wide conventions, like 
`snake_case` keys, for all your modules.
- 🎯 **Rich Type Support:** Out-of-the-box support for `int`, `String`, `double`, `bool`, `List`, 
`Set`, `Map`, `Enum`, `DateTime`, `Duration`, and `Record`.

## Getting Started

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
  build_runner: ^2.4.0
```

### 2. Define Your Preference Schema

Create an abstract class that defines your preferences. The schema is now defined in a simple, 
private constructor.

**`lib/settings.dart`**

```dart
import 'package:preferences_annotation/preferences_annotation.dart';
import 'in_memory_adapter.dart'; // We will create this next

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
    // Dart defaults provide the preference's default value.
    String username = 'guest',
    
    // Nullable types don't need a default.
    DateTime? lastLogin,
    
    // All supported types just work.
    AppTheme theme = AppTheme.system,
    
    // Use @PrefEntry for fine-grained control.
    @PrefEntry(key: 'launch_counter')
    int launchCount = 0,
  });
}
```

### 3. Implement the `PrefsAdapter`

The v2.0 `PrefsAdapter` is much simpler. It only needs to handle primitive types (`String`, `int`, 
`double`, `bool`, `List<String>`). The generator takes care of converting complex types like 
`DateTime` or `Enum` for you.

**`lib/in_memory_adapter.dart`**

```dart
import 'package:preferences_annotation/preferences_annotation.dart';

/// A simple, synchronous adapter that holds values in a map.
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

Instantiate and use your fully type-safe `AppSettings` class. The method names are generated based 
on the `@PrefsModule` preset you chose.

**`lib/main.dart`**

```dart
import 'settings.dart';
import 'in_memory_adapter.dart';

Future<void> main() async {
  final adapter = InMemoryAdapter();
  final settings = AppSettings(adapter);

  // Getters are synchronous by default in the .dictionary() preset
  print('Current theme: ${settings.getTheme().name}');
  
  // Setters are asynchronous
  await settings.setUsername('Alice');
  print('New username: ${settings.getUsername()}');

  await settings.setLastLogin(DateTime.now());
  print('Last login: ${settings.getLastLogin()}');

  // Removers are also asynchronous
  await settings.removeLastLogin();
  print('Last login after removal: ${settings.getLastLogin()}');
}
```

## Advanced Configuration

### `build.yaml` Options

You can define global settings in your project's `build.yaml` file.

```yaml
# your_project/build.yaml
targets:
  $default:
    builders:
      preferences_generator:preferences:
        enabled: true
        options:
          # Sets the project-wide default key case.
          # Options: asis, snake, camel, pascal, kebab
          key_case: snake

          # Optional: Override the default file extension.
          build_extensions: .g.dart
```

### `@PrefsModule` Configuration

You can override global settings on a per-module basis.

```dart
// This module will use kebab-case, overriding the snake_case from build.yaml.
@PrefsModule.dictionary(keyCase: KeyCase.kebab)
abstract class ApiSettings with _$ApiSettings {
  // ...
}
```

## Migration Guide v1.x -> v2.0.0

Version 2.0.0 is a major release with significant API improvements. Follow these steps to migrate.

### 1. Update Dependencies

In your `pubspec.yaml`, update the package versions:

```yaml
dependencies:
  preferences_annotation: ^2.0.0 # or latest

dev_dependencies:
  preferences_generator: ^2.0.0 # or latest
```

### 2. Refactor `PreferenceAdapter` to `PrefsAdapter`

The adapter interface has been simplified.
- Rename your class from `implements PreferenceAdapter` to `implements PrefsAdapter`.
- The `get` and `set` methods now only need to handle primitives. **Remove all manual serialization 
logic** (like `jsonEncode`, `DateTime.toIso8601String`, etc.) from your adapter.
- The `clear()` method is now `removeAll()`.
- The `containsKey()` method has been removed from the interface.

**Before (v1.x):**

```dart
class OldAdapter implements PreferenceAdapter {
  // ... contained complex logic for DateTime, JSON, etc.
}
```

**After (v2.0):**

```dart
class NewAdapter implements PrefsAdapter {
  // ... only deals with primitives. No type checking needed!
}
```

### 3. Refactor Your Schema Class

The schema is now defined in a private generative constructor.

**Before (v1.x):**

```dart
@PreferenceModule()
abstract class AppSettings with _$AppSettings {
  factory AppSettings(PreferenceAdapter adapter, {
    @PreferenceEntry(defaultValue: AppTheme.system) 
    AppTheme theme,
  }) = _AppSettings;
}
```

**After (v2.0):**

1.  Rename `@PreferenceModule` to `@PrefsModule` and choose a preset (e.g., `@PrefsModule.dictionary()`).
2.  Define a **private generative constructor** (`AppSettings._({...})`) for the schema.
3.  Move parameters from the factory to this new constructor.
4.  Replace `@PreferenceEntry(defaultValue: ...)` with standard Dart default values (`AppTheme theme = AppTheme.system`).

```dart
@PrefsModule.dictionary() 
abstract class AppSettings with _$AppSettings {
  factory AppSettings(PrefsAdapter adapter) = _AppSettings;

  AppSettings._({
    AppTheme theme = AppTheme.system,
  });
}
```

### 4. Update Usage & `part` Directives

- The default generated file extension has changed from `.g.dart` to **`.prefs.dart`**. You must 
update all `part` directives in your schema files.
    - **Before:** `part 'settings.g.dart';`
    - **After:** `part 'settings.prefs.dart';`
- Generated method names have changed to be more explicit (e.g., `theme` -> `getTheme()`, 
`setTheme()`). Review your generated `.prefs.dart` file for the new method names corresponding to 
your chosen preset.

## License

This project is licensed under the [MIT License][license_link].

[pub_badge]: https://img.shields.io/pub/v/preferences_generator.svg
[pub_link]: https://pub.dev/packages/preferences_generator
[lint_badge]: https://img.shields.io/badge/style-lint-40c4ff.svg
[lint_link]: https://pub.dev/packages/lint
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT