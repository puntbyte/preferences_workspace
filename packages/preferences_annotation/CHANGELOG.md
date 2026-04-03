## [3.0.0]

### 💥 Breaking Changes

- **Removed:** `AffixConfig`, `CustomConfig`, and `NamedConfig` configuration
  classes have been deleted entirely. `config.dart` is no longer exported.
- **Changed:** All per-entry method configuration parameters on `@PrefEntry`
  (`getter`, `setter`, `remover`, `asyncGetter`, `asyncSetter`, `asyncRemover`,
  `streamer`) now accept a `String?` template instead of a `CustomConfig`
  object. Templates use `{{name}}` and `{{Name}}` tokens for substitution.
- **Changed:** All per-entry method configuration parameters on `@PrefsModule`
  (`getter`, `setter`, `remover`, `asyncGetter`, `asyncSetter`, `asyncRemover`,
  `streamer`) now accept a `String?` template. `null` means disabled across
  the module.
- **Changed:** Module-level method parameters (`removeAll`, `refresh`) on
  `@PrefsModule` now accept a plain `String?` (the literal method name).
  `null` means disabled.
- **Renamed:** `@PrefsModule.testing()` is now `@PrefsModule.exhaustive()`.
  The `.exhaustive()` preset generates all method variants with consistent,
  predictable naming.
- **Changed:** All preset constructors now accept `void Function(Object,
  StackTrace)? onWriteError` instead of typed config objects.

### 🚀 New Features

- **Added:** `@PrefEntry(readOnly: true)` — a first-class shorthand that
  disables all write methods (setter, asyncSetter, remover, asyncRemover) for
  a single entry. Equivalent to passing `PrefEntry.disabled` to all four
  write-method parameters.
- **Added:** `PrefEntry.disabled` — a sentinel constant (`String`) that can be
  passed to any method template parameter on `@PrefEntry` to force-disable that
  method for this entry only, overriding the module default.
- **Added:** `@PrefsModule.minimal()` preset — generates only synchronous
  getters, setters, and removers with no async variants, no streams, and no
  module-level methods. Ideal for CLI tools and scripts.
- **Added:** `@PrefsModule(onWriteError: myHandler)` — an optional callback
  `void Function(Object, StackTrace)` invoked when a synchronous
  (fire-and-forget) write fails. Defaults to `null` (silent discard).
- **Added:** `prefsMinimalModule` convenience constant in `constants.dart`.

### 📚 Documentation

- Added prominent documentation for the "no null distinction" limitation:
  with `containsKey` removed from the adapter contract there is no way to
  distinguish a nullable field that was never written from one explicitly set
  to `null`.
- All annotation parameters are fully documented with token descriptions and
  code examples.

### 🔧 Maintenance

- Minimum Dart SDK constraint remains `^3.10.0`.

---

## [2.0.2]

### 🔧 Maintenance

- **Updated:** Minimum Dart SDK constraint raised from `^3.9.0` to `^3.10.0`.

## [2.0.1]

### 📚 Documentation

- **Improved:** Updated the `README.md` to clearly list and describe all new
  API components introduced in the v2.0.0 release, including `PrefConverter`,
  `KeyCase`, and the configuration classes.

## [2.0.0]

### 🚀 Features

- **Added:** **`@PrefsModule` Presets**. The module annotation now includes powerful presets like 
`.dictionary()`, `.syncOnly()`, and `.reactive()` to quickly configure the generated API.
- **Added:** **`KeyCase` Enum & Configuration**. Introduced the `KeyCase` enum and a `keyCase` 
property on `@PrefsModule` to allow for conventional, automatic naming of storage keys (e.g., 
`snake_case`).
- **Added:** **`PrefConverter` Interface**. A new interface for creating reusable, type-safe 
serializers for custom classes.
- **Added:** **Configuration Classes**. Introduced `CustomConfig`, `AffixConfig`, and `NamedConfig` 
to provide fine-grained control over generated method names and behavior directly within the 
`@PrefEntry` annotation.

### 💥 Breaking Changes

- **Renamed:** The `@PreferenceModule` annotation has been renamed to **`@PrefsModule`** for better 
consistency.
- **Renamed:** The `PreferenceAdapter` interface has been renamed to **`PrefsAdapter`**.
- **Changed:** The `PrefsAdapter` interface contract has been significantly simplified. It is now 
only responsible for handling primitive types (`String`, `int`, `double`, `bool`, `List<String>`). 
All serialization logic for complex types is now handled by the generator.
- **Removed:** The `containsKey()` method has been removed from the `PrefsAdapter` interface.
- **Renamed:** The `clear()` method in the adapter interface has been renamed to **`removeAll()`**.
- **Changed:** The schema definition API is completely new, moving from a `factory` constructor to 
a **private generative constructor**.
- **Removed:** The `@PreferenceEntry(defaultValue: ...)` property has been removed. Default values
must now be defined using standard Dart syntax within the new private schema constructor (e.g., 
`String username = 'guest'`).
- **Removed:** The `@PreferenceIgnore` annotation is now obsolete and has been removed. The new 
"opt-in" schema (where only parameters in the private constructor are included) makes it redundant.

### 🐛 Bug Fixes & Improvements

- **Improved:** All annotations are now immutable, with `const` constructors for better performance.
- **Docs:** Comprehensive documentation has been added for every new class, enum, and property.
- **Refactored:** The package has been streamlined to contain only the essential public API, with 
all implementation details residing in the generator.

## [1.1.0]

- **Added:** Added `@PreferenceIgnore` annotation to exclude fields from preference processing.
- **Added:** Added convenience constants for all annotations (`prefModule`, `prefEntry`, and 
`prefIgnore`).
- **Docs:** Enhanced documentation for all classes and interfaces.
- **Maintained:** Improved `pubspec.yaml` with additional package information.
- **Refactored:** Removed Flutter-specific references for pure Dart compatibility.

## [1.0.3]

- **Maintained:** Updated dependencies to their latest releases.

## [1.0.2]

- **Maintained:** Updated dependencies to their latest releases.

## [1.0.1]

- **Docs:** Enhanced description clarity.

## [1.0.0]

- **Added:** Initial release of `preferences_annotation`.
- **Added:** `@PreferenceModule` annotation for defining settings modules.
- **Added:** `@PreferenceEntry` annotation for defining persistent preference values.
- **Added:** `PreferenceAdapter` abstract interface for storage backend integration.