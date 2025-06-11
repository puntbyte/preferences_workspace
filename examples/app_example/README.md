# Flutter Example App

This package is a comprehensive Flutter application that demonstrates how to use the
`preferences_annotation` and `preferences_generator` packages to build a modern, type-safe settings
screen.

## Features Demonstrated

- Implementation of `PreferenceAdapter` for both `shared_preferences` and `flutter_secure_storage`.
- Usage of all supported data types (`String`, `int`, `Enum`, `Record`, `Color`, etc.).
- Integration with a dependency injection framework (`get_it` and `injectable`).
- A reactive UI that updates efficiently using `ChangeNotifier` and `ListenableBuilder`.
- A clean, modern Material 3 user interface.

For a guide on how to use the core packages in your own project, please see the
main [Preferences Workspace](../../README.md).

## How to Run

1. Ensure you have bootstrapped the monorepo by running `melos bootstrap` from the root directory.
2. Run `melos generate` to generate the necessary files.
3. Run the application using `melos run app_example`.