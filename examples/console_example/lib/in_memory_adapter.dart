import 'package:preferences_annotation/preferences_annotation.dart';

/// A simple, synchronous storage adapter that holds values in an in-memory map.
/// Perfect for testing and console examples.
class InMemoryAdapter implements PrefsAdapter {
  final Map<String, dynamic> _storage = {};

  @override
  Future<T?> get<T>(String key) async {
    final value = _storage[key];
    print('[Adapter] Got "$key" -> ${value ?? 'null'}.');
    return value as T?;
  }

  @override
  Future<void> set<T>(String key, T value) async {
    print('[Adapter] Set "$key" -> $value.');
    _storage[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
    print('[Adapter] Removed "$key".');
  }

  @override
  Future<void> removeAll() async {
    _storage.clear();
    print('[Adapter] Clearing all values.');
  }
}
