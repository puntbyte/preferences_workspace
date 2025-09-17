import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:preferences_annotation/preferences_annotation.dart';

class SecureStorageAdapter implements PrefsAdapter {
  final FlutterSecureStorage _storage;
  SecureStorageAdapter(this._storage);

  @override
  Future<T?> get<T>(String key) async {
    final storedString = await _storage.read(key: key);
    debugPrint('[SecureStorage] GET key=$key, value=$storedString');
    if (storedString == null) return null;

    // The generator provides the correct storable type, so we just parse it.
    final typeStr = T.toString().replaceAll('?', '');
    try {
      if (typeStr == 'int') return int.parse(storedString) as T;
      if (typeStr == 'double') return double.parse(storedString) as T;
      if (typeStr == 'bool') return (storedString == 'true') as T;
      if (typeStr.startsWith('Map')) return jsonDecode(storedString) as T;
      return storedString as T; // Default to String
    } catch (e) {
      debugPrint('[SecureStorage] Failed to parse "$storedString" as $T: $e');
      return null;
    }
  }

  @override
  Future<void> remove(String key) {
    debugPrint('[SecureStorage] REMOVE key=$key');
    return _storage.delete(key: key);
  }

  @override
  Future<void> removeAll() {
    debugPrint('[SecureStorage] REMOVE ALL');
    return _storage.deleteAll();
  }

  @override
  Future<void> set<T>(String key, T value) {
    debugPrint('[SecureStorage] SET key=$key, value=$value');
    if (value == null) return remove(key);

    // Secure storage only stores strings, so we convert everything.
    final valueToStore = (value is Map) ? jsonEncode(value) : value.toString();
    return _storage.write(key: key, value: valueToStore);
  }
}
