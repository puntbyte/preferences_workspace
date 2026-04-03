# Preferences Generator

[![pub version][pub_badge]][pub_link]
[![style: lint][lint_badge]][lint_link]
[![License: MIT][license_badge]][license_link]

A `build_runner` code generator that turns a single annotated class into a
fully type-safe, storage-agnostic preferences API — with automatic
serialization, reactive streams, and `ChangeNotifier` integration.

```
┌─ Your schema (1 file) ─────────────────────────────────────────┐
│  @PrefsModule.reactive()                                       │
│  abstract class AppSettings with _$AppSettings, ChangeNotifier │
│    AppSettings._({ String username = 'guest', ... });          │
└───────────────────────────────────────────────────────────────-┘
                          ↓  build_runner
┌─ Generated (1 part file) ──────────────────────────────────────┐
│  • _AppSettingsKeys   — compile-time storage key constants     │
│  • mixin _$AppSettings — all methods, streams, load/refresh    │
│  • class _AppSettings  — concrete implementation + state       │
└────────────────────────────────────────────────────────────────┘
```

---

## Table of Contents

1. [Installation](#installation)
2. [Quick Start](#quick-start)
3. [Presets — choosing the right API shape](#presets)
4. [Method Name Templates](#method-name-templates)
5. [All `@PrefsModule` Parameters](#all-prefsmodule-parameters)
6. [All `@PrefEntry` Parameters](#all-prefentry-parameters)
7. [All Supported Types](#all-supported-types)
8. [Custom Serialization](#custom-serialization)
9. [Key Casing](#key-casing)
10. [Reactive UI — Streams and ChangeNotifier](#reactive-ui)
11. [Error Handling for Sync Writes](#error-handling)
12. [Lifecycle — `_load`, `refresh`, `removeAll`](#lifecycle)
13. [Implementing `PrefsAdapter`](#implementing-prefsadapter)
14. [Global `build.yaml` Options](#global-buildyaml-options)
15. [Known Limitations](#known-limitations)
16. [AI Agents & LLM Compatibility](#ai-agents--llm-compatibility)

---

## Installation

```yaml
# pubspec.yaml
dependencies:
  preferences_annotation: ^3.0.0

dev_dependencies:
  preferences_generator: ^3.0.0
  build_runner: ^2.6.0
```

---

## Quick Start

### 1. Define your schema

```dart
// lib/settings.dart
import 'package:preferences_annotation/preferences_annotation.dart';

part 'settings.prefs.dart';   // ← the generated file

enum AppTheme { light, dark, system }

@PrefsModule.dictionary()
abstract class AppSettings with _$AppSettings {
  factory AppSettings(PrefsAdapter adapter) = _AppSettings;

  // Every named parameter = one preference.
  // The default value is both the in-memory initial state and the
  // value restored when remove() is called.
  AppSettings._({
    String username = 'guest',
    bool isDarkMode = false,
    AppTheme theme = AppTheme.system,
    @PrefEntry(key: 'launch_counter')
    int launchCount = 0,
  });
}
```

### 2. Implement `PrefsAdapter` (once per storage backend)

```dart
class SharedPreferencesAdapter implements PrefsAdapter {
  final SharedPreferences _prefs;
  SharedPreferencesAdapter(this._prefs);

  @override Future<T?> get<T>(String key) async => _prefs.get(key) as T?;
  @override Future<void> remove(String key) => _prefs.remove(key);
  @override Future<void> removeAll() => _prefs.clear();

  @override
  Future<void> set<T>(String key, T value) async {
    if (value is String)       await _prefs.setString(key, value);
    else if (value is bool)    await _prefs.setBool(key, value);
    else if (value is int)     await _prefs.setInt(key, value);
    else if (value is double)  await _prefs.setDouble(key, value);
    else if (value is List<String>) await _prefs.setStringList(key, value);
  }
}
```

### 3. Generate

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Use

```dart
final prefs = await SharedPreferences.getInstance();
final settings = AppSettings(SharedPreferencesAdapter(prefs));

// .dictionary() generates: sync getter, async setter, async remover
print(settings.getUsername());          // 'guest'
await settings.setUsername('Alice');
print(settings.getUsername());          // 'Alice'
await settings.removeUsername();
print(settings.getUsername());          // 'guest'  (default restored)
```

---

## Presets

A preset is a named constructor on `@PrefsModule` that pre-fills all method
name templates for a common storage pattern. Every preset parameter can be
overridden individually.

### Preset comparison

| Preset | Primary use case | Generated methods for `username` |
|---|---|---|
| `.dictionary()` | `shared_preferences` *(recommended default)* | `getUsername()` sync • `setUsername(v)` async • `removeUsername()` async |
| `.reactive()` | Flutter reactive UIs with `ChangeNotifier` | `username` getter • `setUsername(v)` sync • `usernameStream` stream |
| `.syncOnly()` | Hive, GetStorage, in-memory maps | `getUsername()` • `putUsername(v)` • `deleteUsername()` — all sync |
| `.syncFirst()` | Mixed-latency — prefer sync, async available | `username` • `setUsername(v)` • `usernameAsync()` • `setUsernameAsync(v)` |
| `.minimal()` | CLI tools, scripts | `username` • `setUsername(v)` • `removeUsername()` — nothing else |
| `.exhaustive()` | Every variant — useful for demos and testing | `getUsernameSync` • `setUsernameSync(v)` • `getUsernameAsync()` • `setUsernameAsync(v)` • `watchUsernameStream` |
| `.readOnly()` | Config loaded externally, no writes | `username` getter • `usernameAsync()` |
| `.disabled()` | Custom starting point — everything off | *(nothing — add only what you need)* |

### Preset examples

```dart
// Flutter app with shared_preferences
@PrefsModule.dictionary()
abstract class AppSettings with _$AppSettings { ... }

// Flutter reactive UI — streams + ChangeNotifier
@PrefsModule.reactive()
abstract class AppSettings with _$AppSettings, ChangeNotifier { ... }

// CLI tool — minimal surface
@PrefsModule.minimal()
abstract class CliConfig with _$CliConfig { ... }

// Secure storage with snake_case keys
@PrefsModule(keyCase: KeyCase.snake)
abstract class SecureSettings with _$SecureSettings, ChangeNotifier { ... }

// Custom — disabled base, opt-in only what you want
@PrefsModule.disabled(
  getter:    '{{name}}',
  setter:    'update{{Name}}',
  removeAll: 'wipeAll',
)
abstract class MySettings with _$MySettings { ... }
```

---

## Method Name Templates

All per-entry method configuration parameters accept a `String?` template
with two substitution tokens.

### Token reference

| Token | Substitution | `isFirstLaunch` example |
|---|---|---|
| `{{name}}` | Raw camelCase field name | `isFirstLaunch` |
| `{{Name}}` | Field name, first letter capitalised | `IsFirstLaunch` |

### Token examples

| Template | Field: `username` | Field: `isDarkMode` |
|---|---|---|
| `'{{name}}'` | `username` | `isDarkMode` |
| `'get{{Name}}'` | `getUsername` | `getIsDarkMode` |
| `'set{{Name}}'` | `setUsername` | `setIsDarkMode` |
| `'remove{{Name}}'` | `removeUsername` | `removeIsDarkMode` |
| `'{{name}}Async'` | `usernameAsync` | `isDarkModeAsync` |
| `'set{{Name}}Async'` | `setUsernameAsync` | `setIsDarkModeAsync` |
| `'{{name}}Stream'` | `usernameStream` | `isDarkModeStream` |
| `'watch{{Name}}Stream'` | `watchUsernameStream` | `watchIsDarkModeStream` |
| `'on{{Name}}Changed'` | `onUsernameChanged` | `onIsDarkModeChanged` |
| `'toggle{{Name}}'` | `toggleUsername` | `toggleIsDarkMode` |

### Null vs disabled

- **`null`** on `@PrefsModule` — disables that method type for the entire module.
- **`null`** on `@PrefEntry` — inherits from the module template (default behaviour).
- **`PrefEntry.disabled`** on `@PrefEntry` — force-disables for this entry only.

---

## All `@PrefsModule` Parameters

```dart
@PrefsModule(
  // ── Behaviour ───────────────────────────────────────────────────────────
  notifiable: true,         // call notifyListeners() on any change
                            // only meaningful when mixing in ChangeNotifier
  keyCase: KeyCase.snake,   // storage key casing (see Key Casing section)

  onWriteError: MyClass._handleError,
  // Optional: void Function(Object error, StackTrace st)
  // Called when a sync (fire-and-forget) write fails.
  // Without this, write failures are silently discarded.

  // ── Per-entry method templates (null = disabled for whole module) ────────
  getter:      '{{name}}',           // sync getter
  setter:      'set{{Name}}',        // sync setter
  remover:     'remove{{Name}}',     // sync remover
  asyncGetter: '{{name}}Async',      // async getter
  asyncSetter: 'set{{Name}}Async',   // async setter
  asyncRemover:'remove{{Name}}Async',// async remover
  streamer:    '{{name}}Stream',     // stream getter (null by default in base)

  // ── Module-level method names (literal strings, no token substitution) ──
  removeAll: 'removeAll',  // clears all storage, reloads defaults
  refresh:   'refresh',    // re-reads all values from storage
)
```

---

## All `@PrefEntry` Parameters

```dart
@PrefEntry(
  // ── Storage ─────────────────────────────────────────────────────────────
  key: 'my_custom_key',
  // Overrides the storage key for this field only.
  // Precedence: @PrefEntry(key:) > @PrefsModule(keyCase:) > build.yaml

  // ── Method name templates (null = inherit module, PrefEntry.disabled = off)
  getter:      '{{name}}',
  setter:      'set{{Name}}',
  remover:     'remove{{Name}}',
  asyncGetter: '{{name}}Async',
  asyncSetter: 'set{{Name}}Async',
  asyncRemover:'remove{{Name}}Async',
  streamer:    '{{name}}Stream',

  // ── Shortcuts ────────────────────────────────────────────────────────────
  readOnly: true,
  // Disables setter, asyncSetter, remover, asyncRemover for this field.
  // Streams are NOT affected — the field still gets a stream if enabled.

  notifiable: false,
  // Overrides whether changes to this field call notifyListeners().
  // null → inherits the module-level setting.

  // ── Non-constant default ─────────────────────────────────────────────────
  initial: MyClass._getInitialValue,
  // Use when the default cannot be a compile-time constant.
  // Signature: TypeEntry Function()
  // Example: DateTime? creationDate needs initial: () => DateTime.now()

  // ── Custom serialization (choose one approach) ───────────────────────────
  converter: const MyConverter(),
  // A const PrefConverter<TypeEntry, TypeStorage> instance.

  toStorage: MyClass._toStorage,
  fromStorage: MyClass._fromStorage,
  // Inline static functions. Must be used together.
  // toStorage:   TypeStorage Function(TypeEntry value)
  // fromStorage: TypeEntry  Function(TypeStorage value)
)
```

### `@PrefEntry` usage patterns

```dart
AppSettings._({
  // 1. Custom storage key
  @PrefEntry(key: 'launch_counter')
  int launchCount = 0,

  // 2. Custom stream name
  @PrefEntry(streamer: 'watch{{Name}}Changes')
  String? authToken,

  // 3. Custom setter name (common for booleans)
  @PrefEntry(setter: 'toggle{{Name}}', asyncSetter: 'toggle{{Name}}Async')
  bool isDarkMode = false,

  // 4. Disable one specific method for this entry only
  @PrefEntry(asyncSetter: PrefEntry.disabled)
  int readFrequentlyWriteRarely = 0,

  // 5. Make a field read-only (no setter or remover generated)
  @PrefEntry(readOnly: true)
  String installId = 'uuid-1234-abcd',

  // 6. Suppress ChangeNotifier for a frequently-changing field
  @PrefEntry(notifiable: false)
  String temporarySessionId = '',

  // 7. Non-constant default value
  @PrefEntry(initial: AppSettings._getCreationDate)
  DateTime? creationDate,

  // 8. Custom type via PrefConverter
  @PrefEntry(converter: ColorConverter())
  Color? accentColor,

  // 9. Custom type via inline functions
  @PrefEntry(toStorage: AppSettings._sessionToJson,
             fromStorage: AppSettings._sessionFromJson)
  ApiSession? session,
});
```

---

## All Supported Types

The generator automatically serializes these types to and from the adapter's
primitive contract — no manual conversion needed.

### Natively supported (no annotation required)

| Dart type | Storage type | Notes |
|---|---|---|
| `int` | `int` | |
| `double` | `double` | |
| `bool` | `bool` | |
| `String` | `String` | |
| `List<String>` | `List<String>` | Direct storage |
| `List<int>` | `String` | JSON-encoded |
| `Set<int>` | `String` | JSON-encoded |
| `Set<String>` | `String` | JSON-encoded |
| `Map<String, String>` | `Map<String, dynamic>` | |
| `Map<String, dynamic>` | `Map<String, dynamic>` | |
| `Enum` | `String` | Stored as `.name`, restored with `.values.byName()` |
| `DateTime` | `String` | Stored as ISO 8601 via `.toIso8601String()` |
| `Duration` | `int` | Stored as `.inMicroseconds` |
| Named record `({int w, int h})` | `Map<String, dynamic>` | Field names preserved |
| Positional record `(int, String)` | `Map<String, dynamic>` | Keys: `f0`, `f1`, … |
| Nullable variants `T?` | same as `T` | `null` returned when key absent |

### Custom types (annotation required)

```dart
// Option A: PrefConverter — reusable, recommended
class UriConverter extends PrefConverter<Uri, String> {
  const UriConverter();
  @override Uri    fromStorage(String v) => Uri.parse(v);
  @override String toStorage(Uri v)     => v.toString();
}

@PrefEntry(converter: UriConverter())
Uri? apiEndpoint,

// Option B: Inline static functions — one-off types
@PrefEntry(
  toStorage:   AppSettings._userToMap,
  fromStorage: AppSettings._userFromMap,
)
User? currentUser,

static Map<String, dynamic> _userToMap(User u) => u.toJson();
static User _userFromMap(Map<String, dynamic> m) => User.fromJson(m);
```

---

## Custom Serialization

### Complete `PrefConverter` example

```dart
import 'package:preferences_annotation/preferences_annotation.dart';

/// Serializes a [Color] to/from its ARGB integer representation.
class ColorConverter extends PrefConverter<Color, int> {
  const ColorConverter();            // must be const

  @override
  Color fromStorage(int value) => Color(value);

  @override
  int toStorage(Color value) => value.toARGB32();
}

// Usage in schema:
@PrefEntry(converter: ColorConverter())
Color? accentColor,
```

### `PrefConverter` type parameter guide

```
PrefConverter<TypeEntry, TypeStorage>
              ─────────  ────────────
              Your type  What the adapter stores
              e.g. Color e.g. int
```

`TypeStorage` must be one of the natively supported types above.

---

## Key Casing

Storage key casing is resolved in this priority order (highest first):

```
@PrefEntry(key: 'my_key')           ← always wins
  ↓
@PrefsModule(keyCase: KeyCase.snake) ← overrides build.yaml
  ↓
build.yaml: options: key_case: snake ← project-wide default
  ↓
KeyCase.asis                         ← field name unchanged (fallback)
```

### Available `KeyCase` values

| Value | `launchCount` → | `isDarkMode` → |
|---|---|---|
| `asis` | `'launchCount'` | `'isDarkMode'` |
| `snake` | `'launch_count'` | `'is_dark_mode'` |
| `camel` | `'launchCount'` | `'isDarkMode'` |
| `pascal` | `'LaunchCount'` | `'IsDarkMode'` |
| `kebab` | `'launch-count'` | `'is-dark-mode'` |

### `build.yaml` global key casing

```yaml
# <project>/build.yaml
targets:
  $default:
    builders:
      preferences_generator|preferences:
        options:
          key_case: snake   # applies to every module in this package
```

---

## Reactive UI

### Streams

Enable streams with the `streamer` template parameter. Any entry can have
its own stream regardless of whether the module uses `ChangeNotifier`.

```dart
// Module-wide streams (reactive preset)
@PrefsModule.reactive()            // streamer: '{{name}}Stream' by default
abstract class AppSettings with _$AppSettings, ChangeNotifier { ... }
// Generates: usernameStream, themeModeStream, etc.

// Per-entry stream opt-in (base module, no streams by default)
@PrefsModule(keyCase: KeyCase.snake)
abstract class SecureSettings with _$SecureSettings, ChangeNotifier {
  SecureSettings._({
    @PrefEntry(streamer: 'watch{{Name}}Stream')
    String? authToken,                    // generates: watchAuthTokenStream

    @PrefEntry(streamer: '{{name}}Stream')
    bool areBiometricsEnabled = false,    // generates: areBiometricsEnabledStream

    ApiSession? apiSession,               // no stream — ChangeNotifier only
  });
}
```

### `StreamBuilder` in Flutter

```dart
// Stream fires when:
//   1. A setter is called (immediate, optimistic update)
//   2. _load() reads a changed value from storage (on startup + refresh())
//   3. removeAll() restores all fields to defaults

StreamBuilder<String>(
  stream: settings.usernameStream,
  builder: (context, snap) {
    return Text(snap.data ?? 'loading...');
  },
)
```

### `ChangeNotifier` + `ListenableBuilder`

```dart
@PrefsModule.reactive()
abstract class AppSettings with _$AppSettings, ChangeNotifier {
  factory AppSettings(PrefsAdapter adapter) = _AppSettings;
  AppSettings._({ ThemeMode themeMode = ThemeMode.system });
}

// In your widget tree — rebuilds whenever any setting changes:
ListenableBuilder(
  listenable: appSettings,
  builder: (context, _) => MaterialApp(
    themeMode: appSettings.themeMode,
  ),
)
```

### Suppressing `notifyListeners` for specific fields

```dart
// This field changes frequently (e.g., scroll position).
// Suppress notifications to avoid unnecessary rebuilds.
@PrefEntry(notifiable: false)
double scrollOffset = 0.0,
```

---

## Error Handling

Synchronous setters use a fire-and-forget `Future(() async { ... })` write.
Without `onWriteError`, storage failures are silently discarded — the
in-memory value is always updated immediately (optimistic update).

```dart
@PrefsModule.reactive(onWriteError: AppSettings._onWriteError)
abstract class AppSettings with _$AppSettings, ChangeNotifier {
  factory AppSettings(PrefsAdapter adapter) = _AppSettings;

  AppSettings._({ String username = 'guest' });

  static void _onWriteError(Object error, StackTrace st) {
    // Log, report to Sentry, show a snackbar, etc.
    debugPrint('[Prefs] Write failed: $error\n$st');
  }
}
```

Async setters (`await settings.setUsernameAsync('Alice')`) propagate
exceptions normally — wrap them in try/catch at the call site.

---

## Lifecycle

### How `_load()` works

`_load()` is the private method the generator produces. It is:

- Called once automatically in the constructor (fire-and-forget).
- Guarded by `_isLoaded = false` — once loaded, subsequent calls are no-ops.
- Re-armed by `refresh()` and `removeAll()`, which reset `_isLoaded = false`.
- **Pushes changed values to stream controllers** when a value read from
  storage differs from the in-memory cache.

```dart
// Calling multiple async getters in sequence is safe — only one storage
// read cycle occurs regardless of how many getters are called.
final name = await settings.getUsernameAsync();
final mode = await settings.getThemeModeAsync();  // no second storage read
```

### `refresh()`

Re-reads all values from storage. Any changed values are pushed to their
stream controllers and `notifyListeners()` is called if values changed.

```dart
// Call after the app returns to foreground, or after an external write.
await settings.refresh();
```

### `removeAll()`

Clears all storage keys, then re-reads (restoring defaults). All stream
controllers receive the default values. `notifyListeners()` is called.

```dart
await settings.removeAll();  // equivalent to a factory reset
```

---

## Implementing `PrefsAdapter`

The adapter contract is intentionally minimal — only primitive types.
The generator handles all serialization for complex types.

```dart
abstract interface class PrefsAdapter {
  Future<T?> get<T>(String key);          // T is always a primitive
  Future<void> set<T>(String key, T value);
  Future<void> remove(String key);
  Future<void> removeAll();
}
```

### Which primitives does the adapter receive?

| Dart field type | Adapter `T` |
|---|---|
| `int`, `bool`, `double`, `String` | Same type |
| `List<String>` | `List<String>` |
| `Set<*>`, `Map<*>`, `Record`, `DateTime` (when stored as JSON), custom | `String` or `Map<String, dynamic>` |
| `Enum` | `String` |
| `DateTime` | `String` |
| `Duration` | `int` |

### Complete `shared_preferences` adapter

```dart
class SharedPreferencesAdapter implements PrefsAdapter {
  final SharedPreferences _prefs;
  SharedPreferencesAdapter(this._prefs);

  @override
  Future<T?> get<T>(String key) async => _prefs.get(key) as T?;

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> removeAll() => _prefs.clear();

  @override
  Future<void> set<T>(String key, T value) async {
    switch (value) {
      case final String v:       await _prefs.setString(key, v);
      case final bool v:         await _prefs.setBool(key, v);
      case final int v:          await _prefs.setInt(key, v);
      case final double v:       await _prefs.setDouble(key, v);
      case final List<String> v: await _prefs.setStringList(key, v);
      default:
        // Map<String, dynamic> — store as JSON string
        if (value is Map) await _prefs.setString(key, jsonEncode(value));
    }
  }
}
```

### Minimal in-memory adapter (for testing / console apps)

```dart
class InMemoryAdapter implements PrefsAdapter {
  final _store = <String, dynamic>{};

  @override Future<T?> get<T>(String key) async => _store[key] as T?;
  @override Future<void> set<T>(String key, T value) async => _store[key] = value;
  @override Future<void> remove(String key) async => _store.remove(key);
  @override Future<void> removeAll() async => _store.clear();
}
```

---

## Global `build.yaml` Options

```yaml
targets:
  $default:
    builders:
      preferences_generator|preferences:
        options:
          # Project-wide default key casing.
          # Overridden by @PrefsModule(keyCase:) and @PrefEntry(key:).
          # Values: asis | snake | camel | pascal | kebab
          key_case: snake

          # Override the generated file extension (default: .prefs.dart)
          # build_extensions:
          #   '.dart': '.g.dart'
```

---

## Known Limitations

**Null distinction.** With `containsKey` removed from the adapter contract,
there is no way to distinguish a nullable field that was *never written* from
one *explicitly set to `null`*. Both return `null` from `get()`. If the
distinction matters, store a non-null sentinel value instead.

---

## AI Agents & LLM Compatibility

This section is written for AI coding assistants (Claude, Copilot, Cursor,
Gemini, etc.) to use as a reference when generating code with this package.

### Decision tree: which preset?

```
Does the app use Flutter?
├── Yes
│   ├── Needs reactive UI (streams or ChangeNotifier)?
│   │   ├── Yes → @PrefsModule.reactive()     [add ChangeNotifier to class]
│   │   └── No  → @PrefsModule.dictionary()   [async writes, sync reads]
│   └── Backend is fully synchronous (Hive)?
│       └── Yes → @PrefsModule.syncOnly()
└── No (Dart CLI / server)
    ├── Needs full API surface?
    │   └── Yes → @PrefsModule.exhaustive()
    └── No → @PrefsModule.minimal()
```

### Required class structure (invariant)

Every `@PrefsModule` class **must** have exactly:

```dart
@PrefsModule.<preset>()
abstract class MySettings with _$MySettings {    // ← 'with _$MySettings' required
  factory MySettings(PrefsAdapter adapter) = _MySettings; // ← factory required
  MySettings._({ /* schema */ });                          // ← private ctor required
}

// When using ChangeNotifier:
abstract class MySettings with _$MySettings, ChangeNotifier { ... }
```

### Schema constructor rules

```dart
MySettings._({
  // ✅ Compile-time constant default
  String username = 'guest',
  bool flag = false,
  int count = 0,
  MyEnum value = MyEnum.first,

  // ✅ Nullable — no default needed (null is the default)
  String? optionalValue,

  // ✅ Non-constant default — use @PrefEntry(initial:)
  @PrefEntry(initial: MySettings._now)
  DateTime? createdAt,

  // ✅ Custom type — must provide converter or toStorage/fromStorage
  @PrefEntry(converter: MyConverter())
  MyType? customValue,

  // ❌ WRONG — non-const default without @PrefEntry(initial:)
  // DateTime createdAt = DateTime.now(),  // will not compile
});
```

### Correct `part` directive

```dart
part 'my_settings.prefs.dart';   // ← always .prefs.dart, not .g.dart
```

### Complete reactive example (copy-paste ready)

```dart
// lib/app_settings.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:preferences_annotation/preferences_annotation.dart';

part 'app_settings.prefs.dart';

enum AppTheme { light, dark, system }

@PrefsModule.reactive(onWriteError: AppSettings._onWriteError)
abstract class AppSettings with _$AppSettings, ChangeNotifier {
  factory AppSettings(PrefsAdapter adapter) = _AppSettings;

  AppSettings._({
    String username = 'guest',
    bool isDarkMode = false,
    AppTheme theme = AppTheme.system,
    int? lastNotificationId,
    List<String> recentSearches = const <String>[],
    Duration sessionTimeout = const Duration(minutes: 30),

    @PrefEntry(converter: ColorConverter())
    Color? accentColor,

    @PrefEntry(key: 'launch_counter', streamer: 'on{{Name}}Updated')
    int launchCount = 0,

    @PrefEntry(readOnly: true)
    String installId = 'uuid-1234-abcd',

    @PrefEntry(notifiable: false, initial: AppSettings._now)
    DateTime? lastActiveAt,
  });

  static void _onWriteError(Object e, StackTrace st) =>
      debugPrint('[AppSettings] write error: $e');

  static DateTime _now() => DateTime.now();
}
```

```dart
// lib/adapters/shared_preferences_adapter.dart
// (see Implementing PrefsAdapter section above)
```

```dart
// lib/main.dart
late final AppSettings appSettings;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  appSettings = AppSettings(SharedPreferencesAdapter(prefs));
  await appSettings.refresh(); // loads storage → fires streams
  runApp(const App());
}
```

```dart
// lib/app.dart
ListenableBuilder(
  listenable: appSettings,
  builder: (context, _) => MaterialApp(
    themeMode: appSettings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
  ),
)

// Stream-driven widget:
StreamBuilder<int>(
  stream: appSettings.onLaunchCountUpdated,  // custom stream name
  builder: (context, snap) => Text('Launches: ${snap.data ?? 0}'),
)
```

### Common mistakes AI agents make

| Mistake | Correct |
|---|---|
| `part 'settings.g.dart'` | `part 'settings.prefs.dart'` |
| `class MySettings` (non-abstract) | `abstract class MySettings` |
| Missing `with _$MySettings` | `abstract class MySettings with _$MySettings` |
| Missing `factory` constructor | `factory MySettings(PrefsAdapter adapter) = _MySettings;` |
| `DateTime now = DateTime.now()` | `@PrefEntry(initial: MySettings._now) DateTime? now,` |
| `settings.usernameStream` when using `.dictionary()` | streams are not generated by `.dictionary()` — use `.reactive()` |
| `settings.setUsername('x')` when using `.dictionary()` | `.dictionary()` setters are async: `await settings.setUsername('x')` |
| Referencing `settings.username` when using `.dictionary()` | getter name is `getUsername()` in `.dictionary()` preset |
| `AffixConfig`, `CustomConfig`, `NamedConfig` (v2 API) | Use template strings: `setter: 'set{{Name}}'` |

### Generated method name reference (by preset, field `username`)

```
Preset          getter          setter              remover             stream
──────────────────────────────────────────────────────────────────────────────────
dictionary()    getUsername()   setUsername() async removeUsername() async  —
reactive()      username        setUsername()       removeUsername()    usernameStream
syncOnly()      getUsername()   putUsername()       deleteUsername()    —
syncFirst()     username        setUsername()       removeUsername()    —
                usernameAsync() setUsernameAsync()  removeUsernameAsync()
minimal()       username        setUsername()       removeUsername()    —
exhaustive()    getUsernameSync setUsernameSync     removeUsernameSync  watchUsernameStream
                getUsernameAsync setUsernameAsync   removeUsernameAsync
```

---

## Packages

| Package | Role |
|---|---|
| [`preferences_generator`][pub_link] | `build_runner` generator — dev dependency |
| [`preferences_annotation`][annotation_link] | Annotations & interfaces — runtime dependency |

[pub_badge]: https://img.shields.io/pub/v/preferences_generator.svg
[pub_link]: https://pub.dev/packages/preferences_generator
[annotation_link]: https://pub.dev/packages/preferences_annotation
[lint_badge]: https://img.shields.io/badge/style-lint-40c4ff.svg
[lint_link]: https://pub.dev/packages/lint
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT