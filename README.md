# Preferences Workspace

[![style: lint][lint_badge]][lint_link]
[![License: MIT][license_badge]][license_link]

A code generator that writes your preference management boilerplate for you.
Define your settings once as a Dart class — get back a fully type-safe,
storage-agnostic API tailored to your project.

## Key Benefits

- ✅ **No typos.** All storage keys are generated constants. Mistakes are
  caught at compile time, not runtime.
- ✅ **Any storage backend.** Works with `shared_preferences`, Hive, secure
  storage, or anything else. The adapter contract is intentionally minimal.
- ✅ **Automatic serialization.** `DateTime`, `Duration`, `Enum`, `Record`, and
  custom classes via `PrefConverter` — the generator handles conversion to and
  from primitives automatically.
- ✅ **Template-based naming.** Method names are configured with readable
  template strings (`'set{{Name}}'`, `'watch{{Name}}Stream'`) rather than
  opaque config objects.
- ✅ **Reactive UIs out of the box.** The `.reactive()` preset generates
  `Stream`s and wires up `ChangeNotifier` automatically.
- ✅ **Fine-grained control.** Override any method name per entry, disable
  individual methods, mark fields read-only — all with a single annotation.

## The Simple Workflow

1. **Define a schema** — write a private constructor listing your preferences
   and their defaults.
2. **Run the generator** — `dart run build_runner build`.
3. **Use your class** — the generator produces a tailored class with exactly
   the methods you configured.

## Packages

| Package                                         | Description                                                     |
|-------------------------------------------------|-----------------------------------------------------------------|
| **[`preferences_generator`][generator_link]**   | The `build_runner` generator. Primary documentation lives here. |
| **[`preferences_annotation`][annotation_link]** | Annotations and interfaces (the runtime dependency).            |

## Examples

| Example                                       | Description                                                                                                                      |
|-----------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| **[`app_example`][flutter_example_link]**     | A complete Flutter app with a reactive settings screen, `ChangeNotifier`, secure storage, and `Color`/custom-type serialization. |
| **[`console_example`][console_example_link]** | A CLI app demonstrating every supported type and annotation feature using the `.exhaustive()` preset.                            |

## Migrating from v2

See **[MIGRATION.md](./MIGRATION.md)** for a step-by-step guide covering every
breaking change in v3.0.0.

## For Contributors

This is a [Melos](https://melos.invertase.dev/) monorepo.

```bash
# One-time setup
dart pub global activate melos
melos bootstrap

# Common tasks
melos test      # run all tests
melos generate  # run build_runner across all packages
melos analyze   # static analysis
```

## License

MIT — see the `LICENSE` file for details.

[lint_badge]: https://img.shields.io/badge/style-lint-40c4ff.svg
[lint_link]: https://pub.dev/packages/lint
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[generator_link]: ./packages/preferences_generator
[annotation_link]: ./packages/preferences_annotation
[flutter_example_link]: ./examples/app_example
[console_example_link]: ./examples/console_example
