# preferences_annotation

This package provides the public API for the Preferences Suite, including the annotations and
interfaces required by the `preferences_generator` package.

For full documentation and usage examples, please see the
main [Preferences Workspace](../../README.md).

## API Components

- **`@PreferenceModule`**: A class-level annotation that marks an abstract class as a module of
  related preferences.
- **`@PreferenceEntry`**: A parameter-level annotation used to define a single, persistent
  preference entry.
- **`PreferenceAdapter`**: An abstract interface that you must implement to connect the generated
  module to a storage backend.