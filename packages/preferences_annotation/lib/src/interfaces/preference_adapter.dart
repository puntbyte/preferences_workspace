/// An interface for abstracting the underlying storage mechanism.
///
/// Implementations of this interface (e.g., for `shared_preferences`, `flutter_secure_storage`,
/// or an in-memory test store) are passed when initializing the generated preferences class.
///
/// It is the responsibility of the adapter to handle the serialization and deserialization of rich
/// types (like [DateTime] or [Color]) into primitive types that the storage engine can handle
/// (like [String] or [int]).
abstract interface class PreferenceAdapter {
  /// Retrieves a value of type [T] associated with the given [key].
  ///
  /// The adapter should handle deserializing a stored primitive back into the rich type [T]
  /// requested by the generated code. For example, if a [DateTime] is stored as an ISO 8601
  /// string, this method should parse that string back into a [DateTime] object when
  /// `get<DateTime>(...)` is called.
  ///
  /// Should return `null` if the key is not found or if deserialization fails.
  Future<T?> get<T>(String key);

  /// Stores the [value] of type [T] associated with the given [key].
  ///
  /// The adapter is responsible for serializing rich types into primitives that the underlying
  /// storage engine can handle. For example, a [Color] object should be converted to its integer
  /// `value` before being stored.
  ///
  /// If the provided [value] is `null`, the adapter should remove the key.
  Future<void> set<T>(String key, T value);

  /// Removes the preference entry associated with the [key].
  Future<void> remove(String key);

  /// Clears all preferences managed by this storage instance.
  ///
  /// The scope of "all" is defined by the implementation. For an adapter wrapping
  /// `SharedPreferences`, this would typically call `_prefs.clear()`.
  Future<void> clear();
}
