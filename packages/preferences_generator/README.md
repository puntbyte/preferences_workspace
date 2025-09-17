this is my old read me for preferences_generator, give me an updated and migration guide. the new is version 2.0.0, the old one is version 1.x.x

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

- ✅ **Type-Safe:** No more magic strings. Get compile-time safety for all your preference keys and 
types.
- 🧱 **Storage Agnostic:** The adapter interface is incredibly simple and only deals with primitive 
types. The generator handles the rest.
- ⚙️ **Automatic Serialization:** No more manual `jsonEncode` or type conversions in your adapter. 
The generator automatically handles `DateTime`, `Duration`, `Enum`, `Record`, and even your custom classes.
- 🚀 **Highly Configurable:** Use presets like `.dictionary()`, `.syncOnly()`, or `.reactive()` to match your storage backend's API, or fine-tune every method name.
- 🌊 **Reactive Ready:** Automatically generate `Stream`s for any preference to easily build reactive UIs.
- 🔧 **Global Configuration:** Use `build.yaml` to define project-wide conventions, like `snake_case` keys, for all your modules.
- 🎯 **Rich Type Support:** Out-of-the-box support for `int`, `String`, `double`, `bool`, `List`, `Set`, `Map`, `Enum`, `DateTime`, `Duration`, and `Record`.

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
  build_runner: ^2.0.0
```

### 2. Define Your Preference Schema

Create an abstract class that defines your preferences. The schema is defined in a private, generative constructor.

**`lib/settings.dart`**
```dart
import 'package:preferences_annotation/preferences_annotation.dart';
import 'in_memory_adapter.dart'; // We will create this next

part 'settings.g.dart';

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

### 2. Define Your Preference Schema

Create an abstract class that defines your preferences. The schema is defined in a private, generative constructor.

**`lib/settings.dart`**
```dart
import 'package:preferences_annotation/preferences_annotation.dart';
import 'in_memory_adapter.dart'; // We will create this next

part 'settings.g.dart';

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

## License

This project is licensed under the [MIT License][license_link].

[pub_badge]: https://img.shields.io/pub/v/preferences_generator.svg

[pub_link]: https://pub.dev/packages/preferences_generator

[lint_badge]: https://img.shields.io/badge/style-lint-40c4ff.svg

[lint_link]: https://pub.dev/packages/lint

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg

[license_link]: https://opensource.org/licenses/MIT

[examples_link]: ../../examples
