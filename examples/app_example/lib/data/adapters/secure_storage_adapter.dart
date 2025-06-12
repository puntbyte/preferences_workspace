import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:preferences_annotation/preferences_annotation.dart';

class SecureStorageAdapter implements PreferenceAdapter {
  final FlutterSecureStorage _storage;
  SecureStorageAdapter(this._storage);

  @override
  Future<void> clear() {
    debugPrint(
      '[SecureStorageAdapter] clear: Clearing all secure preferences.',
    );
    return _storage.deleteAll();
  }

  @override
  Future<T?> get<T>(String key) async {
    final storedString = await _storage.read(key: key);
    debugPrint(
      '[SecureStorageAdapter] get: Reading key "$key" (requested as $T). Found stored '
      'string: "$storedString".',
    );

    if (storedString == null) return null;

    final typeString = T.toString().replaceAll('?', '');

    try {
      if (typeString == 'String') return storedString as T?;
      if (typeString == 'int') return int.parse(storedString) as T?;
      if (typeString == 'double') return double.parse(storedString) as T?;
      if (typeString == 'bool') {
        return (storedString.toLowerCase() == 'true') as T?;
      }
      if (typeString == 'Duration') {
        return Duration(microseconds: int.parse(storedString)) as T?;
      }
      if (typeString == 'DateTime') {
        return DateTime.tryParse(storedString) as T?;
      }
      if (typeString.startsWith('Map') ||
          typeString.startsWith('List') ||
          typeString.startsWith('Set')) {
        return jsonDecode(storedString) as T?;
      }
    } catch (e) {
      debugPrint(
        '[SecureStorageAdapter] ERROR: Failed to parse key "$key" to type $T. Error: $e',
      );
      return null;
    }

    if (T == String || T.toString() == 'String?') return storedString as T?;

    debugPrint(
      '[SecureStorageAdapter] WARNING: Unhandled type $T for key "$key".',
    );
    return null;
  }

  @override
  Future<void> remove(String key) {
    debugPrint('[SecureStorageAdapter] remove: Removing key "$key".');
    return _storage.delete(key: key);
  }

  @override
  Future<void> set<T>(String key, T value) async {
    if (value == null) return remove(key);

    final String valueToStore = switch (value) {
      String() || int() || double() || bool() => value.toString(),
      Duration() => value.inMicroseconds.toString(),
      DateTime() => value.toIso8601String(),
      List() || Set() || Map() => jsonEncode(value),
      _ => value.toString(),
    };

    debugPrint(
      '[SecureStorageAdapter] set: Writing key "$key" with value "$value" (stored as '
      'string: "$valueToStore").',
    );

    await _storage.write(key: key, value: valueToStore);
  }
}
