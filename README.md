# Preferences Workspace

[![style: lint][lint_badge]][lint_link]
[![License: MIT][license_badge]][license_link]

This project helps you manage user settings and application state in Dart and Flutter. It's a code 
generator that writes the boring, repetitive settings code for you, so you don't have to.

Stop worrying about typos in storage keys and manually converting data types. This tool creates a 
simple, tailor-made class for your project that makes managing preferences safe and easy.

## Key Benefits

- ✅ **Forget Typos:** All your setting keys are generated for you. Your code editor will catch 
any mistakes at compile-time, not crash your app at runtime.
- ✅ **Use Any Storage:** Works with your favorite storage solution. Whether you use 
`shared_preferences`, Hive, secure storage, or something else, the setup is simple.
- ✅ **Automatic Data Conversion:** Forget about manually converting complex data like dates, 
times, colors, or your own custom classes. The generator handles the conversion to and from a 
storable format for you.
- ✅ **Highly Customizable:** Start with simple presets that match your needs, or fine-tune 
everything. You can even set a project-wide convention, like making all storage keys `snake_case`, 
in a single line of configuration.
- ✅ **Ready for Reactive UIs:** Easily build user interfaces that update automatically whenever a 
setting changes, without needing complex state management code.

## The Simple Workflow

Using the tool is a straightforward, three-step process:

1. **Define a Blueprint**
   You create a single, simple file where you list all the settings you need, like `username` or `
   isDarkMode`, and their starting values. This is your single source of truth.

2. **Run the Generator**
   You run a standard command in your terminal.

3. **Use Your Custom Class**
   The generator instantly creates a class that is perfectly tailored to your blueprint. You can 
   now get and set preferences with simple, easy-to-read methods, and your code editor will help 
   you avoid any mistakes.

## Packages in this Workspace

This project is managed with [Melos](https://melos.invertase.dev/).

| Package                                         | Description                                                                                       |
|-------------------------------------------------|---------------------------------------------------------------------------------------------------|
| **[`preferences_generator`][generator_link]**   | The main tool that generates your code. This is where you'll find the primary user documentation. |
| **[`preferences_annotation`][annotation_link]** | A lightweight helper package that provides the building blocks for your blueprint file.           |

## Examples

| Example                                       | Description                                                                    |
|-----------------------------------------------|--------------------------------------------------------------------------------|
| **[`flutter_example`][flutter_example_link]** | A complete Flutter application demonstrating a reactive settings screen.       |
| **[`console_example`][console_example_link]** | A command-line application showcasing all features in a pure Dart environment. |

## For Contributors

Contributions are welcome! To get started with the development environment for this monorepo, 
follow these steps.

1. **Activate Melos:**
   (You only need to do this once)
   ```bash
   dart pub global activate melos
   ```

2. **Bootstrap the workspace:**
   This command links all local packages together and installs their dependencies.
   ```bash
   melos bootstrap
   ```

3. **Run common tasks:**
   Use these commands to run tasks across all packages in the workspace.
   ```bash
   # Run all tests
   melos test

   # Run the code generator for all packages
   melos generate

   # Run static analysis
   melos analyze
   ```

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

[lint_badge]: https://img.shields.io/badge/style-lint-40c4ff.svg
[lint_link]: https://pub.dev/packages/lint
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[generator_link]: ./packages/preferences_generator
[annotation_link]: ./packages/preferences_annotation
[flutter_example_link]: ./examples/app_example
[console_example_link]: ./examples/console_example
