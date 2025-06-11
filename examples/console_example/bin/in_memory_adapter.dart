import 'package:preferences_annotation/preferences_annotation.dart';

/// A simple, synchronous storage adapter that holds values in an in-memory map.
/// Perfect for testing and console examples.
class InMemoryAdapter implements PreferenceAdapter {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> clear() async {
    print('[InMemoryAdapter] Clearing all values.');
    _storage.clear();
  }

  @override
  Future<T?> get<T>(String key) async {
    final value = _storage[key];
    print('[InMemoryAdapter] GET: key="$key", value="$value" (requesting type <$T>)');
    if (value == null) return null;
    return value as T?;
  }

  @override
  Future<void> remove(String key) async {
    print('[InMemoryAdapter] REMOVE: key="$key"');
    _storage.remove(key);
  }

  @override
  Future<void> set<T>(String key, T value) async {
    print('[InMemoryAdapter] SET: key="$key", value="$value"');
    if (value == null) {
      await remove(key);
      return;
    }
    _storage[key] = value;
  }
}