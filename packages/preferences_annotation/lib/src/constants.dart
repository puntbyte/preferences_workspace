import 'package:preferences_annotation/preferences_annotation.dart';

/// Convenience alias for `@PrefsModule()` with default settings.
const prefsModule = PrefsModule();

/// Convenience alias for `@PrefsModule.dictionary()`.
const prefsKeyValueModule = PrefsModule.dictionary();

/// Convenience alias for `@PrefsModule.reactive()`.
const prefsReactiveModule = PrefsModule.reactive();

/// Convenience alias for `@PrefsModule.minimal()`.
const prefsMinimalModule = PrefsModule.minimal();

/// Convenience alias for a plain `@PrefEntry` with no overrides.
const prefEntry = PrefEntry<dynamic, dynamic>();
