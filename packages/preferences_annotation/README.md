# Preferences Annotation

[![pub version][pub_badge]][pub_link]

Public API for the Preferences Suite — the annotations, interfaces, and types
consumed by [`preferences_generator`][generator_link].

> **This is a runtime dependency.** Add `preferences_generator` as a dev
> dependency. See [preferences_generator][generator_link] for the full guide.

---

## Table of Contents

1. [Installation](#installation)
2. [@PrefsModule — complete reference](#prefsmodule)
3. [@PrefEntry — complete reference](#prefentry)
4. [PrefsAdapter — implementing storage](#prefsadapter)
5. [PrefConverter — custom type serialization](#prefconverter)
6. [KeyCase — storage key casing](#keycase)
7. [PrefEntry.disabled — per-entry method suppression](#prefentrydisabled)
8. [Convenience constants](#convenience-constants)
9. [AI Agents & LLM Compatibility](#ai-agents--llm-compatibility)

---

## Installation

```yaml
dependencies:
  preferences_annotation: ^3.0.0   # runtime

dev_dependencies:
  preferences_generator: ^3.0.0    # code generation
  build_runner: ^2.6.0
```

---

## `@PrefsModule`

Class-level annotation. Marks an abstract class as a preference module and
configures the generated API shape.

### Constructors (presets)

```dart
// ── Presets ──────────────────────────────────────────────────────────────
@PrefsModule.dictionary()    // shared_preferences — sync gets, async sets
@PrefsModule.reactive()      // streams + ChangeNotifier
@PrefsModule.syncOnly()      // Hive / GetStorage — all sync
@PrefsModule.syncFirst()     // sync primary, async available
@PrefsModule.minimal()       // sync get/set/remove — nothing else
@PrefsModule.exhaustive()    // every variant with predictable names
@PrefsModule.readOnly()      // getters only, no writes
@PrefsModule.disabled()      // nothing — custom starting point

// ── Fully custom ─────────────────────────────────────────────────────────
@PrefsModule(
  notifiable:   true,
  keyCase:      KeyCase.snake,
  onWriteError: MyClass._errorHandler,
  getter:       '{{name}}',
  setter:       'set{{Name}}',
  remover:      'remove{{Name}}',
  asyncGetter:  '{{name}}Async',
  asyncSetter:  'set{{Name}}Async',
  asyncRemover: 'remove{{Name}}Async',
  streamer:     '{{name}}Stream',
  removeAll:    'removeAll',
  refresh:      'refresh',
)
```

### Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `notifiable` | `bool` | `false` | Call `notifyListeners()` on any change. Requires `ChangeNotifier` in the class. |
| `keyCase` | `KeyCase?` | `null` | Storage key casing convention. Overrides `build.yaml`. |
| `onWriteError` | `void Function(Object, StackTrace)?` | `null` | Called when a sync (fire-and-forget) write fails. `null` = silent discard. |
| `getter` | `String?` | preset-specific | Template for sync getter names. `null` = disabled. |
| `setter` | `String?` | preset-specific | Template for sync setter names. `null` = disabled. |
| `remover` | `String?` | preset-specific | Template for sync remover names. `null` = disabled. |
| `asyncGetter` | `String?` | preset-specific | Template for async getter names. `null` = disabled. |
| `asyncSetter` | `String?` | preset-specific | Template for async setter names. `null` = disabled. |
| `asyncRemover` | `String?` | preset-specific | Template for async remover names. `null` = disabled. |
| `streamer` | `String?` | preset-specific | Template for stream getter names. `null` = disabled. |
| `removeAll` | `String?` | preset-specific | Literal name for the `removeAll()` method. `null` = disabled. |
| `refresh` | `String?` | preset-specific | Literal name for the `refresh()` method. `null` = disabled. |

### Template tokens

All `getter`, `setter`, `remover`, `asyncGetter`, `asyncSetter`,
`asyncRemover`, and `streamer` values use template substitution:

| Token | `username` | `isDarkMode` | `launchCount` |
|---|---|---|---|
| `{{name}}` | `username` | `isDarkMode` | `launchCount` |
| `{{Name}}` | `Username` | `IsDarkMode` | `LaunchCount` |

Templates **must** contain `{{name}}` or `{{Name}}`. A bare string like
`'save'` will cause a build-time error because every entry would generate
a method called `save`.

`removeAll` and `refresh` are module-wide literals — no token substitution.

### Preset default templates

| | `.dictionary()` | `.reactive()` | `.syncOnly()` | `.minimal()` | `.exhaustive()` |
|---|---|---|---|---|---|
| `getter` | `'get{{Name}}'` | `'{{name}}'` | `'get{{Name}}'` | `'{{name}}'` | `'get{{Name}}Sync'` |
| `setter` | *(none)* | `'set{{Name}}'` | `'put{{Name}}'` | `'set{{Name}}'` | `'set{{Name}}Sync'` |
| `remover` | *(none)* | `'remove{{Name}}'` | `'delete{{Name}}'` | `'remove{{Name}}'` | `'remove{{Name}}Sync'` |
| `asyncGetter` | *(none)* | *(none)* | *(none)* | *(none)* | `'get{{Name}}Async'` |
| `asyncSetter` | `'set{{Name}}'` | *(none)* | *(none)* | *(none)* | `'set{{Name}}Async'` |
| `asyncRemover` | `'remove{{Name}}'` | *(none)* | *(none)* | *(none)* | `'remove{{Name}}Async'` |
| `streamer` | *(none)* | `'{{name}}Stream'` | *(none)* | *(none)* | `'watch{{Name}}Stream'` |
| `removeAll` | `'clear'` | `'removeAll'` | `'clear'` | *(none)* | `'removeAll'` |
| `refresh` | *(none)* | `'refresh'` | *(none)* | *(none)* | `'refresh'` |

*(none) = `null` = disabled for the whole module*

### Preset customisation

Every preset parameter can be overridden:

```dart
// reactive() but with custom stream name template and no module-level refresh
@PrefsModule.reactive(
  streamer:  'watch{{Name}}Changes',  // override stream names
  refresh:   null,                    // disable refresh() method
  removeAll: 'wipeAll',               // rename removeAll()
)
abstract class AppSettings with _$AppSettings, ChangeNotifier { ... }
```

---

## `@PrefEntry`

Parameter-level annotation. Placed on individual parameters of the private
schema constructor to customise a single preference entry.

### All parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `key` | `String?` | `null` | Storage key override. Bypasses `keyCase`. |
| `readOnly` | `bool` | `false` | Disables all write methods (setter, asyncSetter, remover, asyncRemover). Streams are unaffected. |
| `notifiable` | `bool?` | `null` | Per-entry `notifyListeners()` override. `null` inherits module setting. |
| `initial` | `T Function()?` | `null` | Factory for a non-constant default value. |
| `getter` | `String?` | `null` | Template override for this entry's sync getter. |
| `setter` | `String?` | `null` | Template override for this entry's sync setter. |
| `remover` | `String?` | `null` | Template override for this entry's sync remover. |
| `asyncGetter` | `String?` | `null` | Template override for this entry's async getter. |
| `asyncSetter` | `String?` | `null` | Template override for this entry's async setter. |
| `asyncRemover` | `String?` | `null` | Template override for this entry's async remover. |
| `streamer` | `String?` | `null` | Template override for this entry's stream getter. |
| `converter` | `PrefConverter?` | `null` | Const converter instance. Cannot combine with `toStorage`/`fromStorage`. |
| `toStorage` | `S Function(T)?` | `null` | Inline serializer. Must pair with `fromStorage`. |
| `fromStorage` | `T Function(S)?` | `null` | Inline deserializer. Must pair with `toStorage`. |

### `null` vs `PrefEntry.disabled`

```dart
// null on a @PrefEntry template → inherit the module default
@PrefEntry(asyncSetter: null)       // same as no annotation
String field = 'value',

// PrefEntry.disabled → force this method OFF for this entry only,
//                      even if the module preset enables it
@PrefEntry(asyncSetter: PrefEntry.disabled)
String field = 'value',
```

### Complete example

```dart
@PrefsModule.reactive()
abstract class AppSettings with _$AppSettings, ChangeNotifier {
  factory AppSettings(PrefsAdapter adapter) = _AppSettings;

  AppSettings._({
    // ── No annotation — uses module preset defaults ──────────────────────
    String username = 'guest',
    bool isDarkMode = false,

    // ── Custom storage key ───────────────────────────────────────────────
    @PrefEntry(key: 'launch_counter')
    int launchCount = 0,

    // ── Custom stream name ───────────────────────────────────────────────
    @PrefEntry(streamer: 'on{{Name}}Updated')
    int sessionCount = 0,

    // ── Custom setter name (boolean toggle pattern) ──────────────────────
    @PrefEntry(
      setter:      'toggle{{Name}}',
      asyncSetter: 'toggle{{Name}}Async',
    )
    bool notificationsEnabled = true,

    // ── Disable one method for this entry only ───────────────────────────
    @PrefEntry(asyncSetter: PrefEntry.disabled)
    int frequentlyRead = 0,

    // ── Read-only: no setter, asyncSetter, remover, asyncRemover ─────────
    @PrefEntry(readOnly: true)
    String installId = 'uuid-1234',

    // ── Suppress ChangeNotifier for a noisy field ─────────────────────────
    @PrefEntry(notifiable: false)
    double scrollOffset = 0.0,

    // ── Non-constant default ─────────────────────────────────────────────
    @PrefEntry(initial: AppSettings._now)
    DateTime? createdAt,

    // ── Custom type via PrefConverter ─────────────────────────────────────
    @PrefEntry(converter: ColorConverter())
    Color? accentColor,

    // ── Nullable int — no annotation needed ─────────────────────────────
    int? lastNotificationId,

    // ── Collections — all serialized automatically ───────────────────────
    List<String> bookmarks = const <String>[],
    Set<int> favoriteIds = const <int>{},
    Map<String, String> flags = const <String, String>{},

    // ── Built-in Dart types — serialized automatically ───────────────────
    Duration sessionTimeout = const Duration(minutes: 30),
    ThemeMode themeMode = ThemeMode.system,  // Enum

    // ── Records — serialized automatically ──────────────────────────────
    ({int w, int h})? windowSize,            // named record
    (int, int)? cursorPosition,              // positional record

    // ── Custom type via inline functions ─────────────────────────────────
    @PrefEntry(
      toStorage:   AppSettings._sessionToJson,
      fromStorage: AppSettings._sessionFromJson,
    )
    ApiSession? session,
  });

  static DateTime _now() => DateTime.now();

  static Map<String, dynamic> _sessionToJson(ApiSession s) => s.toJson();
  static ApiSession _sessionFromJson(Map<String, dynamic> m) =>
      ApiSession.fromJson(m);
}
```

---

## `PrefsAdapter`

Interface to implement for your storage backend. Handles **primitive types
only** — all serialization for complex types is performed by the generator.

```dart
abstract interface class PrefsAdapter {
  /// Retrieve a value. Returns null if the key does not exist.
  Future<T?> get<T>(String key);

  /// Store a value. T is always a primitive (see table below).
  Future<void> set<T>(String key, T value);

  /// Delete a single key.
  Future<void> remove(String key);

  /// Delete all keys managed by this adapter.
  Future<void> removeAll();
}
```

### Primitive types the adapter receives

| Dart field type | `T` in `get<T>` / `set<T>` |
|---|---|
| `int` | `int` |
| `double` | `double` |
| `bool` | `bool` |
| `String` | `String` |
| `List<String>` | `List<String>` |
| `Enum` | `String` (`.name`) |
| `DateTime` | `String` (ISO 8601) |
| `Duration` | `int` (microseconds) |
| Named/positional record | `Map<String, dynamic>` |
| `Set<T>`, `Map<K,V>` | `Map<String, dynamic>` |
| `PrefConverter` custom type | whatever `TypeStorage` is |
| `toStorage`/`fromStorage` custom | return type of `toStorage` |

---

## `PrefConverter`

Abstract class for reusable, type-safe serializers.

```dart
abstract class PrefConverter<TypeEntry, TypeStorage> {
  const PrefConverter();              // ← must be const

  TypeStorage toStorage(TypeEntry value);
  TypeEntry   fromStorage(TypeStorage value);
}
```

### Type parameter guide

```
PrefConverter<TypeEntry,  TypeStorage>
              ──────────  ────────────
              Dart type   Stored as
              Color       int         (ARGB integer)
              Uri         String      (toString())
              MyModel     String      (JSON string)
              MyModel     Map<String, dynamic>
```

`TypeStorage` must be one of the types the adapter can receive (see table
above).

### Examples

```dart
// Color ↔ int
class ColorConverter extends PrefConverter<Color, int> {
  const ColorConverter();
  @override Color fromStorage(int v)   => Color(v);
  @override int   toStorage(Color v)  => v.toARGB32();
}

// Uri ↔ String
class UriConverter extends PrefConverter<Uri, String> {
  const UriConverter();
  @override Uri    fromStorage(String v) => Uri.parse(v);
  @override String toStorage(Uri v)     => v.toString();
}

// Custom model ↔ Map
class UserConverter extends PrefConverter<User, Map<String, dynamic>> {
  const UserConverter();
  @override User fromStorage(Map<String, dynamic> v) => User.fromJson(v);
  @override Map<String, dynamic> toStorage(User v)   => v.toJson();
}
```

---

## `KeyCase`

Enum that controls how field names are transformed into storage keys.

```dart
enum KeyCase { asis, snake, camel, pascal, kebab }
```

| Value | `launchCount` | `isDarkMode` | `myAPIKey` |
|---|---|---|---|
| `asis` | `'launchCount'` | `'isDarkMode'` | `'myAPIKey'` |
| `snake` | `'launch_count'` | `'is_dark_mode'` | `'my_a_p_i_key'` |
| `camel` | `'launchCount'` | `'isDarkMode'` | `'myApiKey'` |
| `pascal` | `'LaunchCount'` | `'IsDarkMode'` | `'MyApiKey'` |
| `kebab` | `'launch-count'` | `'is-dark-mode'` | `'my-a-p-i-key'` |

Key casing precedence (highest first):

```
@PrefEntry(key: 'explicit_key')         ← always wins
@PrefsModule(keyCase: KeyCase.snake)    ← per module
build.yaml: options: key_case: snake    ← project-wide
KeyCase.asis                            ← fallback (no transform)
```

---

## `PrefEntry.disabled`

A sentinel constant (`String`) that, when assigned to any method template
parameter on `@PrefEntry`, force-disables that method for the annotated
entry only — regardless of what the module preset enables.

```dart
// Module generates async setters for everyone.
@PrefsModule.reactive(asyncSetter: 'set{{Name}}Async')
abstract class AppSettings with _$AppSettings, ChangeNotifier {
  AppSettings._({
    String username = 'guest',      // gets setUsernameAsync()

    // This entry opts out of the async setter specifically.
    @PrefEntry(asyncSetter: PrefEntry.disabled)
    int launchCount = 0,            // NO setLaunchCountAsync()
  });
}
```

**`null` vs `PrefEntry.disabled`**

```dart
@PrefEntry(asyncSetter: null)              // → inherit module default (has async setter)
@PrefEntry(asyncSetter: PrefEntry.disabled)// → force OFF for this entry only
```

---

## Convenience Constants

Pre-built annotation instances for common patterns:

```dart
// lib/src/constants.dart
const prefsModule         = PrefsModule();             // base module
const prefsKeyValueModule = PrefsModule.dictionary();  // shared_prefs
const prefsReactiveModule = PrefsModule.reactive();    // reactive UI
const prefsMinimalModule  = PrefsModule.minimal();     // CLI / minimal
const prefEntry           = PrefEntry<dynamic, dynamic>(); // no overrides
```

Usage:

```dart
@prefsReactiveModule
abstract class AppSettings with _$AppSettings, ChangeNotifier { ... }
```

---

## AI Agents & LLM Compatibility

### Package structure at a glance

```
preferences_annotation
├── @PrefsModule     — class annotation (preset or custom)
│   ├── .dictionary()  .reactive()  .syncOnly()
│   ├── .syncFirst()   .minimal()   .exhaustive()
│   ├── .readOnly()    .disabled()
│   └── main constructor (fully custom)
│
├── @PrefEntry       — parameter annotation (per-entry overrides)
│   ├── key, readOnly, notifiable, initial
│   ├── getter, setter, remover
│   ├── asyncGetter, asyncSetter, asyncRemover
│   ├── streamer
│   ├── converter (PrefConverter)
│   └── toStorage / fromStorage
│
├── PrefConverter<TypeEntry, TypeStorage>  — custom type serializer
├── PrefsAdapter                           — storage backend interface
├── KeyCase                                — key casing enum
└── PrefEntry.disabled                     — sentinel to force-disable a method
```

### Invariant rules for code generation

```
1. Class must be abstract
2. Class must have: with _$ClassName  (mixin)
3. Class must have: factory ClassName(PrefsAdapter adapter) = _ClassName
4. Class must have: ClassName._({ /* parameters */ })  (private constructor)
5. Part directive must be: part 'filename.prefs.dart'  (NOT .g.dart)
6. ChangeNotifier mixin is optional — required only for notifiable: true
7. dart:async import required when any streamer is enabled
8. All @PrefEntry(initial:) functions must be static methods on the class
9. All @PrefEntry(toStorage:/fromStorage:) functions must be static methods
10. @PrefEntry(converter:) instance must be const
```

### How method names are resolved

```
Final method name = resolve(template, entryName)

where:
  template   = @PrefEntry override  OR  @PrefsModule template  OR  null (disabled)
  resolve()  = template
                 .replace('{{name}}', entryName)
                 .replace('{{Name}}', entryName[0].toUpper() + entryName.substring(1))

Examples:
  resolve('set{{Name}}',   'username')      → 'setUsername'
  resolve('{{name}}Stream','isDarkMode')    → 'isDarkModeStream'
  resolve('watch{{Name}}Stream', 'theme')  → 'watchThemeStream'
  resolve('toggle{{Name}}', 'flag')        → 'toggleFlag'
```

### Generated code structure (what to expect)

```dart
// Part file: MySettings.prefs.dart

class _MySettingsKeys {
  static const fieldName = 'storage_key';   // one per entry
}

mixin _$MySettings {
  // Abstract requirements (the concrete class must provide):
  PrefsAdapter get _adapter;
  bool get _isLoaded; set _isLoaded(bool v);
  String get _fieldName; set _fieldName(String v);
  StreamController<String> get _fieldNameStreamController; // if streamer enabled

  // Public getters (if getter template set):
  String get fieldName => _fieldName;

  // Module methods (if enabled):
  Future<void> refresh() async { _isLoaded = false; await _load(); }
  Future<void> removeAll() async { await _adapter.removeAll(); _isLoaded = false; await _load(); }
  void dispose() { /* closes all StreamControllers */ }

  // Private load:
  Future<void> _load() async {
    if (_isLoaded) return;                    // guard — no double reads
    // reads each key, pushes to streams on change
    _isLoaded = true;
    if (hasChanged) (this as ChangeNotifier).notifyListeners();
  }

  // Per-entry methods (names from templates):
  void setFieldName(String value) { /* optimistic update + fire-and-forget write */ }
  Future<void> setFieldNameAsync(String value) async { /* await write */ }
  void removeFieldName() { /* reset to default */ }
  Stream<String> get fieldNameStream => _fieldNameStreamController.stream;
}

class _MySettings extends MySettings with _$MySettings {
  @override final PrefsAdapter _adapter;
  bool _isLoaded = false;                   // load guard field
  @override late String _fieldName;
  @override final StreamController<String> _fieldNameStreamController =
      StreamController<String>.broadcast();

  _MySettings(this._adapter) : super._(...) {
    _fieldName = 'default';               // initialise from schema default
    _fieldNameStreamController.add(_fieldName);  // seed stream
    _load();                              // kick off background load
  }
}
```

### Stream behaviour — when do streams fire?

| Event | Streams fire? |
|---|---|
| Sync setter called | ✅ Immediately (optimistic) |
| Async setter called | ✅ After `await` |
| `_load()` reads a changed value from storage | ✅ Yes (fixed in v3.0.0) |
| `refresh()` called and storage differs | ✅ Yes |
| `removeAll()` called | ✅ All streams receive default values |
| Setter called but value is unchanged | ❌ No (equality guard) |

[pub_badge]: https://img.shields.io/pub/v/preferences_annotation.svg
[pub_link]: https://pub.dev/packages/preferences_annotation
[generator_link]: https://pub.dev/packages/preferences_generator