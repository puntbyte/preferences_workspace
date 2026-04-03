## [3.0.0]

### 💥 Breaking Changes

- **Requires:** `preferences_annotation ^3.0.0`.
- **Removed:** `ResolvedMethodConfig`, `UnresolvedMethodConfig`, and
  `MethodConfig` internal model classes. All resolved method configurations are
  now `String?` (null = disabled, non-null = final method name). Code that
  imported these internal classes will need to be updated.
- **Renamed:** The `.testing()` preset is now `.exhaustive()` in both the
  annotation and the generator. Any `@PrefsModule.testing()` usage will need
  updating.

### 🐛 Bug Fixes

- **Fixed:** Synchronous setters and removers now reference the generated keys
  class (e.g., `_AppSettingsKeys.username`) in all adapter calls instead of
  raw string literals. This was a critical inconsistency — `_load()` already
  used the keys class, but write methods did not.
- **Fixed:** Generated local variable names in `_load()` were using `ALLCAPS`
  suffixes (e.g., `rawValueForUSERNAME`). They now use proper camelCase
  (e.g., `rawUsername`, `newUsername`).
- **Fixed:** The internal change-tracking variable in `_load()` was named
  `P_changed`. It is now named `hasChanged`.
- **Fixed:** Double slash in `app_example/build.yaml`
  (`lib/generated/{{path}}//{{file}}.prefs.dart` →
  `lib/generated/{{path}}/{{file}}.prefs.dart`).

### 🚀 New Features

- **Added:** `_isLoaded` guard in the generated `_load()` method. The first
  call populates the in-memory cache from storage; subsequent calls are no-ops.
  `refresh()` resets the flag before re-reading. This prevents N full storage
  reads when N async getters are called in sequence and eliminates the
  possibility of inconsistent interim state.
- **Added:** Build-time template validation. Per-entry template overrides in
  `@PrefEntry` and module-level templates in `@PrefsModule` are now validated
  to contain at least one `{{name}}` or `{{Name}}` token. A clear
  `InvalidGenerationSourceError` is thrown if a bare literal name is provided
  where a template is required.
- **Added:** Error handling in fire-and-forget sync writes. All
  `Future(() async { ... })` write blocks now include a try/catch. If
  `@PrefsModule(onWriteError: ...)` is provided, the callback is invoked on
  failure; otherwise the error is silently discarded.
- **Added:** `ExceptionHandler.invalidEntryTemplate()` — clear build error for
  per-entry templates missing substitution tokens.
- **Added:** `ExceptionHandler.invalidModuleTemplate()` — clear build error for
  module-level templates missing substitution tokens.

### ⬆️ Dependency Updates

- **Updated:** `analyzer` from `^9.0.0` to `^10.0.0`.
- **Updated:** `preferences_annotation` from `^2.0.0` to `^3.0.0`.

### 🧪 Tests

- **Added:** Golden file test for the `.reactive()` preset — full pipeline
  output snapshot in `test/src/golden/reactive_preset_test.dart`.
- **Added:** Golden file test for the `.minimal()` preset — verifies no async,
  stream, or module-level methods are emitted.
- **Rewritten:** `method_namer_test.dart` — fully updated for the new
  `MethodNamer.resolve(template, entryName)` and `MethodNamer.hasToken(template)`
  API.
- **Updated:** `value_change_logic_builder_test.dart` — mocks updated for
  `String?` resolved method names; new assertions for keys class references
  and error handling.
- **Updated:** `mixin_writer_test.dart` — mocks updated for `String?` resolved
  method names; new assertion for `_isLoaded` reset in `refresh()` and
  `removeAll()`.

---

## [2.0.7]

### 🔧 Maintenance

- **Updated:** Minimum Dart SDK constraint raised from `^3.9.0` to `^3.10.0`.
- **Updated:** `analyzer` dependency upgraded from `^9.0.0` to `^10.0.0`.

## [2.0.6]

### ⬆️ Dependency Updates

- **Updated:** Bumped the `build` dependency to version `4.0.0`.

## [2.0.5]

### ⬆️ Dependency Updates

- **Updated:** Bumped the `source_gen` dependency to version `4.0.0`.

## [2.0.4]

### ⬆️ Dependency Updates

- **Updated:** Bumped the `analyzer` dependency to version `8.0.0`.

## [2.0.3]

### 🐛 Bug Fixes

- **Fixed:** Resolved a critical crash that occurred when a user customised
  `build_extensions` in their `build.yaml`.

## [2.0.2]

### 🔧 Improvements & Maintenance

- **Improved:** Simplified the builder configuration for end-users.
- **Refactored:** Internal builder factory renamed to `preferences`.

## [2.0.1]

### 📚 Documentation

- **Improved:** Overhauled the `README.md` with comprehensive configuration
  documentation.

## [2.0.0]

- Initial major release with schema-in-constructor API, presets, automatic
  serialization, stream generation, and global `build.yaml` configuration.


### 🚀 Features

- **Added:** **Schema-in-Constructor API**. Preference schemas are now defined in a private, 
generative constructor (e.g., `MySettings._({...})`) instead of a factory. This enables the use of 
standard Dart default values.
- **Added:** **`@PrefsModule` Presets**. Introduced powerful presets like `.dictionary()`, 
`.syncOnly()`, and `.reactive()` to quickly configure the generated API to match common storage 
backend patterns.
- **Added:** **Automatic Serialization**. The generator now automatically handles the serialization 
of complex types (`DateTime`, `Duration`, `Enum`, `Record`, and custom types via `PrefConverter`). 
The `PrefsAdapter` is now only responsible for handling primitive types.
- **Added:** **`Stream` Generation**. Added the ability to generate reactive `Stream`s for any 
preference entry via the `.reactive()` preset or a custom `streamer` configuration.
- **Added:** **Global `build.yaml` Configuration**. You can now define project-wide settings, such 
as `key_case: snake`, to enforce conventions across all preference modules.
- **Added:** **`KeyCase` Convention**. Introduced the `keyCase` property in `@PrefsModule` and 
`build.yaml` to automatically transform generated storage keys to `snake_case`, `kebab-case`, etc.
- **Added:** **Custom `PrefConverter` Support**. Added the `converter` property to `@PrefEntry` to 
allow users to provide a reusable class for serializing and deserializing complex custom types.
- **Added:** **Fine-Grained Method Configuration**. Introduced `CustomConfig`, `AffixConfig`, and 
`NamedConfig` objects to allow precise control over every generated method's name and behavior, 
including enabling/disabling individual methods.

### 💥 Breaking Changes

- **Refactored:** The schema definition has moved from a `factory` constructor to a 
**private generative constructor**. The old factory-based schema is no longer supported.
- **Changed:** The default generated file extension has changed from `.g.dart` to 
**`.prefs.dart`**. All `part` directives must be updated.
- **Renamed:** The `PreferenceAdapter` interface has been renamed to **`PrefsAdapter`**.
- **Simplified:** The contract for `PrefsAdapter` has been radically simplified. It is now only 
required to handle primitives (`String`, `int`, `double`, `bool`, `List<String>`). All manual 
serialization logic for complex types must be removed from adapter implementations.
- **Removed:** The `containsKey()` method has been removed from the adapter interface.
- **Renamed:** The `clear()` method in the adapter interface has been renamed to **`removeAll()`**.
- **Changed:** The `@PreferenceEntry(defaultValue: ...)` property has been **removed**. Default 
values must now be provided using standard Dart syntax in the schema constructor (e.g., 
`String username = 'guest'`).
- **Changed:** Generated method names are now more explicit and configurable. A field named `theme` 
will now generate methods like `getTheme()` and `setTheme(...)` instead of a top-level `theme` 
- getter/setter pair.

### 🐛 Bug Fixes & Improvements

- **Improved:** Code generation for collection literals (`const []`, `const {}`) now automatically 
infers and adds the correct type arguments to prevent type errors in the generated code.
- **Improved:** The entire generator codebase has been refactored into a more robust and testable 
architecture, separating analysis, model-building, and code generation into distinct, decoupled 
phases.
- **Improved:** Error messages are now more consistent and are all centralized in a dedicated 
`ExceptionHandler` class.
- **Fixed:** Resolved several bugs related to nullable type handling in setters and deserialization 
logic.

## [1.1.4]

- **Maintained:** Downgraded `source_gen` to be compatible with other packages.

## [1.1.3]

- **Maintained:** Downgraded `build` to be compatible with other packages.

## [1.1.2]

- **Updated:** Updated dependencies to their latest releases.
- **Refactored:** Removed deprecated code.

## [1.1.1]

- **Docs:** Enhanced documentation clarity.

## [1.1.0]

- **Docs:** Enhanced description clarity.
- **Refactored:** Removed support for non `dart:core` data type `Color`.
- **Added:** Added support for `Set` and `Duration`.
- **Style:** Refined code formatting.

## [1.0.0]

- **Added:** Initial release of `preferences_generator`.
- **Added:** Implemented code generation for classes annotated with `@PreferenceModule`.
- **Added:** Added support for `int`, `String`, `double`, `bool`, `DateTime`, `Color`, `List`, 
`Map`, `Enum`, and `Record` types.
- **Added:** Implemented robust error handling for common misconfigurations.