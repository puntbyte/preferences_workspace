import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An adapter that connects the preferences system to the `shared_preferences` package.
///
/// This adapter handles the serialization and deserialization of complex types like
/// [DateTime], [Color], [List], [Map], [Enum], and [Record] into primitive types
/// that `shared_preferences` can store (int, double, bool, String, List<String>).
class SharedPreferencesAdapter implements PreferenceAdapter {
  final SharedPreferences _prefs;

  SharedPreferencesAdapter(this._prefs);

  /// A convenience factory for creating an adapter instance.
  /// This is the recommended way to create the adapter.
  static Future<SharedPreferencesAdapter> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesAdapter(prefs);
  }

  @override
  Future<void> clear() async {
    debugPrint('[SharedPrefsAdapter] clear: Clearing all preferences.');
    await _prefs.clear();
  }

  /// Deserializes a value from [SharedPreferences].
  ///
  /// This method is called by the generated code with the expected type [T].
  /// It reads the raw value from storage and converts it back to the rich type.
  @override
  Future<T?> get<T>(String key) async {
    final value = _prefs.get(key);
    debugPrint(
      '[SharedPrefsAdapter] get: Reading key "$key" (requested as $T). Found value: '
      '"$value" of type ${value.runtimeType}.',
    );

    if (value == null) return null;
    if (value is T) return value as T;
    if (T == Duration && value is int)
      return Duration(microseconds: value) as T?;
    if (T == DateTime && value is String) return DateTime.tryParse(value) as T?;
    if ((T.toString().contains('List<') ||
            T.toString().contains('Set<') ||
            T.toString().contains('Map<') ||
            T.toString().startsWith('(')) &&
        value is String) {
      try {
        return jsonDecode(value) as T?;
      } catch (_) {
        return null;
      }
    }

    try {
      return value as T?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> remove(String key) async {
    debugPrint('[SharedPrefsAdapter] remove: Removing key "$key".');
    await _prefs.remove(key);
  }

  /// Serializes a value and stores it in [SharedPreferences].
  ///
  /// This method is called by the generated code with a rich type (like [DateTime]),
  /// and it's this adapter's job to convert it to a storable primitive.
  @override
  Future<void> set<T>(String key, T value) async {
    debugPrint(
      '[SharedPrefsAdapter] set: Writing key "$key" with value "$value" of type '
      '${value.runtimeType}.',
    );

    if (value == null) return await remove(key);

    switch (value) {
      case int():
        await _prefs.setInt(key, value);
      case double():
        await _prefs.setDouble(key, value);
      case bool():
        await _prefs.setBool(key, value);
      case String():
        await _prefs.setString(key, value);
      case Duration():
        await _prefs.setInt(key, value.inMicroseconds);
      case DateTime():
        await _prefs.setString(key, value.toIso8601String());
      case Color():
        await _prefs.setInt(key, value.toARGB32());
      case Enum():
        await _prefs.setString(key, value.name);
      case List() || Set() || Map() || Record():
        await _prefs.setString(key, jsonEncode(value));
      default:
        throw ArgumentError('Unsupported type `${value.runtimeType}`.');
    }
  }
}
