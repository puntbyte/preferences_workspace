import 'package:flutter/foundation.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesAdapter implements PrefsAdapter {
  final SharedPreferences _prefs;
  SharedPreferencesAdapter(this._prefs);

  @override
  Future<T?> get<T>(String key) async {
    final value = _prefs.get(key);
    debugPrint('[SharedPrefs] GET key=$key, value=$value');
    return value as T?;
  }

  @override
  Future<void> remove(String key) {
    debugPrint('[SharedPrefs] REMOVE key=$key');
    return _prefs.remove(key);
  }

  @override
  Future<void> removeAll() {
    debugPrint('[SharedPrefs] REMOVE ALL');
    return _prefs.clear();
  }

  @override
  Future<void> set<T>(String key, T value) async {
    debugPrint('[SharedPrefs] SET key=$key, value=$value');
    if (value == null) return remove(key);

    // shared_preferences can handle most primitive types directly.
    switch (value) {
      case int():
        await _prefs.setInt(key, value);
      case double():
        await _prefs.setDouble(key, value);
      case bool():
        await _prefs.setBool(key, value);
      case String():
        await _prefs.setString(key, value);
      case List<String>():
        await _prefs.setStringList(key, value);
      default:
        // For any other type (Set, Map, Record, custom objects),
        // the generator provides a storable representation (e.g., int, String).
        // We just need to handle that.
        if (value is int) {
          await _prefs.setInt(key, value);
        } else {
          await _prefs.setString(key, value.toString());
        }
    }
  }
}
