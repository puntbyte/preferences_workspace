# Preferences Workspace

This repository is a monorepo containing the `preferences_annotation` and `preferences_generator`
packages, which together provide a powerful, type-safe code generation solution for managing user
settings in Dart and Flutter.

This monorepo is managed with [Melos](https://melos.invertase.dev).

## Packages

| Package                                                       | Description                                                                          |
|:--------------------------------------------------------------|:-------------------------------------------------------------------------------------|
| [`preferences_annotation`](./packages/preferences_annotation) | Defines the public API, including annotations and the `PreferenceAdapter` interface. |
| [`preferences_generator`](./packages/preferences_generator)   | The build-time code generator. This package contains the primary user documentation. |

## Examples

| Example                                         | Description                                                |
|:------------------------------------------------|:-----------------------------------------------------------|
| [`app_example`](./examples/app_example)         | A Flutter application demonstrating a full implementation. |
| [`console_example`](./examples/console_example) | A command-line application demonstrating pure Dart usage.  |

## Contributing

Contributions are welcome!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.