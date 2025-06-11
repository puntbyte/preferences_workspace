# Dart Console Example

This package is a simple command-line application that demonstrates how to use the
`preferences_annotation` and `preferences_generator` packages in a pure Dart, non-Flutter
environment.

## Features Demonstrated

- Implementation of a `PreferenceAdapter` that uses an in-memory `Map` for storage.
- Usage of non-UI data types like `String`, `int`, `double`, `bool`, `Enum`, `Record`, and
  `DateTime`.
- A simple command-line interface to get, set, and clear preferences.

This shows the flexibility of the library outside of a Flutter UI context. For a full guide, please
see the main [Preferences Workspace](../../README.md).

## How to Run

1. Ensure you have bootstrapped the monorepo by running `melos bootstrap` from the root directory.
2. Run `melos generate` to generate the necessary files.
3. Run the application using `melos run app_example`.