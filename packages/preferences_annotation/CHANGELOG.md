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