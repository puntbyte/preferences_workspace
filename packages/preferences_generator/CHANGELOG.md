## [2.0.0]

This is a major architectural overhaul of the Preferences Suite, introducing a more powerful, 
flexible, and intuitive API. The core focus of this release is to simplify the `PrefsAdapter`, 
automate serialization, and provide extensive configuration options for the generated code.

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