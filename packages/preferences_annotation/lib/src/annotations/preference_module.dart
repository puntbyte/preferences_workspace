import 'package:meta/meta.dart';

import '../interfaces/preference_adapter.dart';

/// Annotates an abstract class to be processed by `preferences_generator`, marking it as a module
/// of related user preferences.
///
/// The generator will create a concrete implementation of this abstract class that interacts with
/// a [PreferenceAdapter] backend to persist and retrieve preference values.
///
/// ### Example:
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:preferences_annotation/preferences_annotation.dart';
///
/// part 'app_preferences.g.dart';
///
/// @PreferenceModule()
/// abstract class AppPreferences with _$AppPreferences {
///   factory AppPreferences(PreferenceAdapter adapter, {
///     @PreferenceEntry(key: 'theme_mode')
///     final ThemeMode? themeMode,
///
///     @PreferenceEntry(defaultValue: 'en')
///     final String languageCode,
///   }) = _AppPreferences;
/// }
/// ```
@immutable
class PreferenceModule {
  /// Defines a class that will have a preferences implementation generated for it.
  const PreferenceModule();
}
