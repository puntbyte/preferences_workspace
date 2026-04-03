# Migrating from v2 to v3

This guide covers every breaking change introduced in v3.0.0 of
`preferences_annotation` and `preferences_generator`.

---

## 1. Update `pubspec.yaml`

```yaml
dependencies:
  preferences_annotation: ^3.0.0   # was ^2.0.x

dev_dependencies:
  preferences_generator: ^3.0.0    # was ^2.0.x
```

---

## 2. Replace config objects with template strings

The most significant change in v3 is the removal of `AffixConfig`,
`CustomConfig`, and `NamedConfig`. All method naming is now done with a
`String?` template using `{{name}}` and `{{Name}}` tokens.

### Token reference

| Token | Meaning | `isFirstLaunch` → |
|---|---|---|
| `{{name}}` | Raw camelCase field name | `isFirstLaunch` |
| `{{Name}}` | First letter capitalised | `IsFirstLaunch` |

### `@PrefEntry` migration

| v2 | v3 |
|---|---|
| `setter: CustomConfig(enabled: false)` | `setter: PrefEntry.disabled` |
| `setter: CustomConfig(enabled: true)` | *(omit — inherits module default)* |
| `setter: CustomConfig(prefix: 'put')` | `setter: 'put{{Name}}'` |
| `setter: CustomConfig(name: 'toggle')` | `setter: 'toggle{{Name}}'` |
| `setter: CustomConfig(prefix: 'set', suffix: 'Value')` | `setter: 'set{{Name}}Value'` |
| `streamer: CustomConfig(enabled: true, prefix: 'watch', suffix: 'Stream')` | `streamer: 'watch{{Name}}Stream'` |
| `streamer: CustomConfig(enabled: true)` | `streamer: '{{name}}Stream'` *(or preset default)* |
| `setter: CustomConfig(enabled: false), remover: CustomConfig(enabled: false)` | `readOnly: true` |

### `@PrefsModule` migration

| v2 | v3 |
|---|---|
| `getter: AffixConfig()` | `getter: '{{name}}'` |
| `getter: AffixConfig(prefix: 'get')` | `getter: 'get{{Name}}'` |
| `setter: AffixConfig(prefix: 'set', suffix: 'Async')` | `asyncSetter: 'set{{Name}}Async'` |
| `removeAll: NamedConfig(name: 'clear')` | `removeAll: 'clear'` |
| `refresh: NamedConfig(enabled: false)` | `refresh: null` |

---

## 3. Rename `.testing()` to `.exhaustive()`

```dart
// v2
@PrefsModule.testing()

// v3
@PrefsModule.exhaustive()
```

The generated output is identical. Only the preset name changed.

---

## 4. Use `.minimal()` for CLI tools instead of `.testing()`

The console example previously used `.testing()` as a stand-in for "give me
everything". With v3 you have a proper choice:

- `.exhaustive()` — every method variant, consistent naming, good for demos.
- `.minimal()` — sync getters/setters/removers only, no async, no streams,
  no module-level methods. The right choice for actual CLI tools.

```dart
// Before (console example)
@PrefsModule.testing(keyCase: KeyCase.snake)

// After (appropriate choice for a production CLI)
@PrefsModule.minimal(keyCase: KeyCase.snake)

// After (if you genuinely want all variants for a demo)
@PrefsModule.exhaustive(keyCase: KeyCase.snake)
```

---

## 5. Remove `config.dart` imports

`AffixConfig`, `CustomConfig`, and `NamedConfig` are deleted. Any import of
`package:preferences_annotation/src/config/config.dart` will break. Remove it
— the barrel export no longer includes it.

---

## 6. Generated code changes (no action required)

The generated `.prefs.dart` files will change when you re-run `build_runner`.
These changes are improvements — your code does not need to reference any of
them directly, but they are listed here for awareness:

- Variable names in `_load()` changed from `rawValueForUSERNAME` to `rawUsername`.
- The change-tracking variable in `_load()` changed from `P_changed` to `hasChanged`.
- All adapter calls now use the generated keys class (`_AppSettingsKeys.username`)
  instead of raw string literals in setters and removers.
- All sync write methods now wrap their adapter call in a try/catch.
- A new `bool _isLoaded = false` field prevents `_load()` from re-reading
  storage on every async getter call. `refresh()` resets this flag.

---

## 7. Update `build.yaml` (app_example only)

Fix the double slash in the `build_extensions` path if you had copied it from
the example:

```yaml
# Before (bug — double slash)
'lib/generated/{{path}}//{{file}}.prefs.dart'

# After
'lib/generated/{{path}}/{{file}}.prefs.dart'
```

---

## Quick find-and-replace cheatsheet

Run these across your project to catch the most common patterns:

```
AffixConfig(prefix: 'set')         →  'set{{Name}}'
AffixConfig(prefix: 'get')         →  'get{{Name}}'
AffixConfig(prefix: 'remove')      →  'remove{{Name}}'
AffixConfig(suffix: 'Async')       →  '{{name}}Async'  (or '{{Name}}Async')
AffixConfig(suffix: 'Stream')      →  '{{name}}Stream'
AffixConfig(enabled: false)        →  null  (on @PrefsModule)
CustomConfig(enabled: false)       →  PrefEntry.disabled  (on @PrefEntry)
CustomConfig(enabled: true)        →  (delete — inherits module default)
NamedConfig(name: '             →  '  (keep just the string)
NamedConfig(enabled: false)        →  null
@PrefsModule.testing(              →  @PrefsModule.exhaustive(
```
