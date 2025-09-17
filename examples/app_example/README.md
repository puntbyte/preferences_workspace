# Flutter Example App

This package is a comprehensive Flutter application that showcases how to use the **v2.0 API** of
the `preferences_generator` package to build a modern, type-safe, and reactive settings screen.

## Core Concepts Demonstrated

- **Declarative Schema Definition:** Demonstrates the new declarative schema definition using a 
private constructor. This allows for standard Dart default values, making the schema clean and 
intuitive.

- **Reactive UI:** Utilizes the `@PrefsModule.reactive()` preset to automatically generate 
`Stream`s and enable `ChangeNotifier` support, allowing the UI to efficiently rebuild widgets in 
response to preference changes.

- **Simplified, Primitive-Only Adapters:** Showcases simple `PrefsAdapter` implementations for both 
`shared_preferences` and `flutter_secure_storage`. This highlights the generator's powerful 
automatic serialization, as the adapters no longer need to handle complex types.

- **Custom Type Serialization:** Includes an example of handling custom Flutter types 
(like `Color`) with a reusable `PrefConverter`, making the generator extensible to any data type.

- **A Clean, Modern UI:** The settings screen is built with Material 3 components to demonstrate a 
realistic use case.

For a guide on how to use the core packages in your own project, please see the main 
[`preferences_generator` package documentation][generator_link].

## How to Run

This example is part of a Melos monorepo.

1. Ensure you have bootstrapped the monorepo by running `melos bootstrap` from the root directory.

2. Run the code generator. This command executes `build_runner` for all packages.
   ```bash
   melos generate
   ```

3. Run the application.
   ```bash
   melos run app_example
   ```

[generator_link]: ../../packages/preferences_generator/README.md