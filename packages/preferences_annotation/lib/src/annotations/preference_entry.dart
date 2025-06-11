import 'package:meta/meta.dart';

import '../interfaces/preference_adapter.dart';

/// Annotates a parameter in a @PreferenceModule factory constructor to mark it
/// as a single, persistent preference entry.
@immutable
class PreferenceEntry {
  /// The key to use for storing the preference in the [PreferenceAdapter].
  /// If this is null, the name of the parameter is used as the key.
  final String? key;

  /// The default value for the preference if none is currently stored.
  /// This value must be a compile-time constant. For non-nullable
  /// preference types, a default value is required.
  final Object? defaultValue;

  /// Marks a parameter as a persistent preference entry.
  const PreferenceEntry({this.key, this.defaultValue});
}