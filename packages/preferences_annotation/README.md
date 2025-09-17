# Preferences Annotation

This package provides the public API for the Preferences Suite, including the annotations and 
interfaces required by the `preferences_generator` package.

For full documentation and usage examples, please see the main 
[`preferences_generator` package][generator_link].

## API Components

- **`@PrefsModule`**: A class-level annotation that marks an abstract class as a module. It 
includes powerful presets (`.dictionary()`, `.syncOnly()`, etc.) and configuration options like 
`keyCase`.
- **`@PrefEntry`**: A parameter-level annotation used to provide fine-grained control over a single 
preference, such as setting a custom `key`, overriding method names, or providing custom 
serialization.
- **`PrefsAdapter`**: An abstract interface that you must implement to connect the generated module 
to a storage backend. It has a simple, primitive-only contract.
- **`PrefConverter`**: An interface for creating reusable serialization logic for your custom types.
- **`KeyCase`**: An enum used with `@PrefsModule` or `build.yaml` to define a global key casing 
strategy (e.g., `snake_case`).
- **`Config` Classes**: A set of classes (`CustomConfig`, `AffixConfig`, `NamedConfig`) used within 
annotations to customize generated method names and behavior.

[generator_link]: https://pub.dev/packages/preferences_generator