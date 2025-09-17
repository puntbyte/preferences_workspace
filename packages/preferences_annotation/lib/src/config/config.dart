import 'package:meta/meta.dart';

/// The base class for all method generation configurations.
///
/// This is a sealed class, which means all possible subtypes are defined within this file,
/// allowing for exhaustive type checking.
@immutable
sealed class Config {
  /// When set, this value overrides the module-level setting for whether a method is generated.
  /// If left `null` (the default for `CustomConfig`), the module-level setting is inherited.
  final bool? enabled;

  const Config({this.enabled});
}

/// A configuration for generated methods whose names are built from a prefix and/or a suffix
/// (e.g., `set` + `Username`).
///
/// If `enabled` is not specified, it defaults to `true`.
@immutable
class AffixConfig extends Config {
  /// A string to prepend to the entry's name (e.g., `set`, `get`).
  final String? prefix;

  /// A string to append to the entry's name (e.g., `Async`, `Stream`).
  final String? suffix;

  const AffixConfig({
    bool super.enabled = true,
    this.prefix,
    this.suffix,
  });
}

/// A configuration for built-in, module-level methods that have a fixed name which can be
/// overridden by the user (e.g., `removeAll`, `refresh`).
///
/// If `enabled` is not specified, it defaults to `true`.
@immutable
class NamedConfig extends Config {
  /// An explicit name for the generated method.
  final String? name;

  const NamedConfig({
    bool super.enabled = true,
    this.name,
  });
}

/// The most flexible configuration, available inside `@PrefEntry` to override any module-level
/// setting for a specific method.
///
/// It allows specifying a prefix/suffix OR a complete name override. If `enabled` is left `null`,
/// the final resolved value from the module is used.
@immutable
class CustomConfig extends AffixConfig {
  /// An explicit name for the generated method, which takes precedence over any prefix or suffix.
  final String? name;

  const CustomConfig({
    super.enabled,
    super.prefix,
    super.suffix,
    this.name,
  });
}
