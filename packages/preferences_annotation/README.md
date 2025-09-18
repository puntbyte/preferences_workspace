# Preferences Annotation

[![pub version][pub_badge]][pub_link]

This package provides the public API for the Preferences Suite, including the annotations and 
interfaces required by the `preferences_generator` package.

For full documentation, usage guides, and advanced examples, please see the main 
**[`preferences_generator`][generator_link]** package documentation.

## API Components

This package defines the core building blocks for your preference schemas:

- **`@PrefsModule`**: A class-level annotation that marks an abstract class as a module. It 
includes powerful presets (`.dictionary()`, `.syncOnly()`, etc.) and configuration options like 
`keyCase`.
- **`@PrefEntry`**: A parameter-level annotation used to provide fine-grained control over a single 
preference, such as setting a custom `key`, overriding method names, or providing custom 
serialization functions.
- **`PrefsAdapter`**: An abstract interface that you must implement to connect the generated module 
to a storage backend. It has a simple, **primitive-only contract**, meaning you only need to handle 
types like `String`, `int`, `bool`, etc.
- **`PrefConverter`**: An interface for creating reusable serialization logic for your custom 
classes (e.g., `Color`, `Uri`, or your own models).
- **`KeyCase`**: An enum used with `@PrefsModule` or `build.yaml` to define a global key casing 
strategy (e.g., `snake_case`).
- **Configuration Classes**: A set of classes (`CustomConfig`, `AffixConfig`, `NamedConfig`) used 
within annotations to customize generated method names and behavior.

[pub_badge]: https://img.shields.io/pub/v/preferences_annotation.svg

[pub_link]: https://pub.dev/packages/preferences_annotation

[generator_link]: https://pub.dev/packages/preferences_generator