# Dart Console Example

This package is a command-line application that serves as a **comprehensive showcase** for the 
**v2.0 API** of the `preferences_generator` package. It demonstrates how to use every supported 
type and feature in a pure Dart, non-Flutter environment.

## Core Concepts Demonstrated

- **Comprehensive Schema & Feature Showcase:** The main preference class uses the new declarative 
schema-in-constructor API to define an entry for every supported type and annotation feature, from 
basic primitives and collections to Records, Enums, and custom classes.

- **Exhaustive API Generation (`.testing()` preset):** This example uses the 
`@PrefsModule.testing()` preset. This is a special preset designed to generate 
*all possible method variations* (sync, async, and streams) with predictable names, making it the 
perfect tool for demonstrating and verifying the full capabilities of the generator.

- **Automatic Serialization:** Demonstrates both methods of handling custom types: a reusable 
`PrefConverter` for the `Uri` type and `toStorage`/`fromStorage` functions for a custom `User` 
class. This highlights how the generator automates serialization, keeping the adapter clean.

- **Simple, Primitive-Only Adapter:** The `InMemoryAdapter` is a minimal implementation of 
`PrefsAdapter`, proving the storage-agnostic nature of the library and the simplicity of the new 
adapter contract.

For a full guide on how to use the core packages in your own project, please see the main 
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
   melos run console_example
   ```

### Expected Output

The application will run a series of steps in your console, printing the initial state of each 
preference, the results after setting new values, and the state after removing them, which confirms 
that the generated code is working correctly.

[generator_link]: ../../packages/preferences_generator/README.md